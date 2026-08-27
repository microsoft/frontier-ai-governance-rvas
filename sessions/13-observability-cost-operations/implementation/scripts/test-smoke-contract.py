#!/usr/bin/env python3
"""Run payload-free mocks against the paired Session 13 smoke contracts."""

from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
IMPLEMENTATION_DIR = SCRIPT_DIR.parent
BASH_SMOKE = SCRIPT_DIR / "smoke.sh"
POWERSHELL_SMOKE = SCRIPT_DIR / "smoke.ps1"
TELEMETRY_CONTRACT = (
    IMPLEMENTATION_DIR / "artifacts" / "telemetry" / "telemetry-contract.json"
)
CONTROL_DEFINITION = IMPLEMENTATION_DIR / "artifacts" / "control-definition.json"


def run(
    command: list[str], script: str, environment: dict[str, str]
) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        command,
        input=script,
        text=True,
        capture_output=True,
        env=environment,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"{' '.join(command)} failed:\n{result.stdout}\n{result.stderr}"
        )
    return result


def test_static_contract() -> None:
    bash = BASH_SMOKE.read_text(encoding="utf-8")
    powershell = POWERSHELL_SMOKE.read_text(encoding="utf-8")
    prohibited = json.loads(TELEMETRY_CONTRACT.read_text(encoding="utf-8"))[
        "prohibitedAttributes"
    ]
    polling = json.loads(CONTROL_DEFINITION.read_text(encoding="utf-8"))[
        "confirmation"
    ]["smokeExecutable"]["ingestionPolling"]
    if polling.get("minimumTimeoutRetryMultiplier") != 2:
        raise RuntimeError("The smoke contract must require timeout >= 2 * retry")
    if polling.get("minimumPassingAttempts") != 3:
        raise RuntimeError("The smoke contract must require three passing attempts")
    if (
        polling.get("attemptCountSemantics")
        != "all telemetry queries across readiness and stability, including the initial and final queries"
        or polling.get("maximumAttemptsFormula")
        != "1 + ceiling(timeoutSeconds / retrySeconds)"
    ):
        raise RuntimeError("The telemetry attempt-count contract is incomplete")
    for name, content in (("Bash", bash), ("PowerShell", powershell)):
        if "******" in content:
            raise RuntimeError(f"{name} smoke script contains a masked bearer token")
        for required in (
            "x-release-commit-sha",
            "releaseCommitSha",
            "release.commit.sha",
            "WorkspaceResourceId",
            "releaseCommitShaVerified",
            "workspaceBindingVerified",
            "normalCorrelationId",
            "failureCorrelationId",
            "telemetryIngestionStable",
            "TelemetryWatermark",
        ):
            if required not in content:
                raise RuntimeError(f"{name} smoke script is missing {required}")
        for attribute in prohibited:
            if attribute not in content:
                raise RuntimeError(
                    f"{name} privacy KQL is missing prohibited property {attribute}"
                )
    if (
        "--config -" not in bash
        or "unset SESSION13_SMOKE_BEARER_TOKEN" not in bash
        or "set +x" not in bash
    ):
        raise RuntimeError("Bash must pass the bearer header through curl standard input")
    if 'commitSha = if ($releaseCommitShaVerified)' not in powershell:
        raise RuntimeError("PowerShell copies commitSha before telemetry verification")
    if "if $release_commit_sha_verified then $commit_sha else null" not in bash:
        raise RuntimeError("Bash copies commitSha before telemetry verification")

    prohibited_set = {item.lower() for item in prohibited}
    for properties in (
        {"http.request.header.authorization": "Bearer mock-secret"},
        {"gen_ai.prompt": "mock-sensitive-input"},
        {"ai.input.content": "mock-sensitive-input"},
    ):
        matched = prohibited_set.intersection(key.lower() for key in properties)
        if not matched:
            raise RuntimeError(f"Mocked dotted leakage was not prohibited: {properties}")


def test_bash_contract(environment: dict[str, str]) -> None:
    script = r'''
source "$SMOKE_SH_PATH"
expected_test_token="mock-token"
curl() {
  local config
  config="$(cat)"
  [[ "$config" == *"Authorization: Bearer ${expected_test_token}"* ]] || return 91
  [[ "$config" == *"x-release-commit-sha: abcdef1"* ]] || return 92
  [[ -z "${SESSION13_SMOKE_BEARER_TOKEN+x}" ]] || return 93
  local argument
  for argument in "$@"; do
    [[ "$argument" != *"$expected_test_token"* ]] || return 94
  done
  printf '204'
}
export SESSION13_SMOKE_BEARER_TOKEN="$expected_test_token"
status="$(invoke_smoke_request "$SESSION13_SMOKE_BEARER_TOKEN" "https://example.invalid" "normal" "00-00000000000000000000000000000000-0000000000000001-01" "abcdef1" '{"releaseCommitSha":"abcdef1"}' "unused.headers")"
[[ "$status" == "204" ]]
workspace_binding_matches "/SUBSCRIPTIONS/S/RESOURCEGROUPS/R/providers/Microsoft.OperationalInsights/workspaces/W/" "/subscriptions/s/resourcegroups/r/providers/microsoft.operationalinsights/workspaces/w"
if workspace_binding_matches "/subscriptions/s/resourceGroups/r/providers/Microsoft.OperationalInsights/workspaces/wrong" "/subscriptions/s/resourceGroups/r/providers/Microsoft.OperationalInsights/workspaces/right"; then
  exit 95
fi
correlation_ids_valid_and_distinct "00000000000000000000000000000001" "00000000000000000000000000000002"
if correlation_ids_valid_and_distinct "00000000000000000000000000000001" "00000000000000000000000000000001"; then
  exit 96
fi
poll_timing_valid 30 15
poll_timing_valid 120 60
if poll_timing_valid 30 16 || poll_timing_valid 119 60; then
  exit 99
fi
ready='{"tables":[{"rows":[[1,1,1,1,1,1,1,1,0,0,0,"2026-08-26T11:00:00Z"]]}]}'
commit_mismatch='{"tables":[{"rows":[[1,1,1,1,1,1,1,1,1,0,0,"2026-08-26T11:00:01Z"]]}]}'
sensitive='{"tables":[{"rows":[[1,1,1,1,1,1,1,1,0,0,1,"2026-08-26T11:00:01Z"]]}]}'
telemetry_result_ready "$ready"
telemetry_result_clean "$ready"
if telemetry_result_ready "$commit_mismatch"; then
  exit 97
fi
if telemetry_result_clean "$sensitive"; then
  exit 98
fi
zero='{"tables":[{"rows":[[0,0,0,0,0,0,0,0,0,0,0,""]]}]}'
absent() { query_result="$zero"; }
no_wait() { :; }
poll_status=0
poll_telemetry 30 15 absent no_wait || poll_status=$?
[[ "$poll_status" -eq 1 && "$telemetry_poll_timed_out" == true && "$telemetry_poll_attempts" -eq 3 ]]

query_result="$ready"
telemetry_poll_elapsed_seconds=0
telemetry_poll_attempts=1
telemetry_poll_timed_out=false
same_clean() { query_result="$ready"; }
stabilize_telemetry 30 15 same_clean no_wait
[[ "$telemetry_ingestion_stable" == true && "$telemetry_poll_attempts" -eq 3 ]]

query_result="$ready"
telemetry_poll_elapsed_seconds=0
telemetry_poll_attempts=1
telemetry_poll_timed_out=false
delayed_count=0
delayed_sensitive() {
  delayed_count=$((delayed_count + 1))
  if (( delayed_count == 1 )); then query_result="$ready"; else query_result="$sensitive"; fi
}
stability_status=0
stabilize_telemetry 30 15 delayed_sensitive no_wait || stability_status=$?
[[ "$stability_status" -eq 1 && "$telemetry_ingestion_stable" == false && "$telemetry_poll_timed_out" == true ]]
[[ "$telemetry_poll_attempts" -eq 3 ]]

query_result="$ready"
telemetry_poll_elapsed_seconds=0
telemetry_poll_attempts=1
telemetry_poll_timed_out=false
delayed_count=0
delayed_mismatch() {
  delayed_count=$((delayed_count + 1))
  if (( delayed_count == 1 )); then query_result="$ready"; else query_result="$commit_mismatch"; fi
}
stability_status=0
stabilize_telemetry 30 15 delayed_mismatch no_wait || stability_status=$?
[[ "$stability_status" -eq 1 && "$telemetry_ingestion_stable" == false && "$telemetry_poll_timed_out" == true ]]
[[ "$telemetry_poll_attempts" -eq 3 ]]
'''
    run(["bash"], script, environment)


def test_powershell_contract(environment: dict[str, str]) -> None:
    script = r'''
$ErrorActionPreference = "Stop"
function global:az {
  $global:LASTEXITCODE=0
  if($args[0] -eq "account"){return '{"id":"s"}'}
  if($args[0] -eq "resource"){
    return '{"type":"Microsoft.Insights/components","properties":{"WorkspaceResourceId":"/SUBSCRIPTIONS/S/RESOURCEGROUPS/R/providers/Microsoft.OperationalInsights/workspaces/W/"}}'
  }
  if($args[0] -eq "rest"){
    return '{"tables":[{"rows":[[1,1,1,1,1,1,1,1,0,0,0,"2026-08-26T11:00:00Z"]]}]}'
  }
  throw "Unexpected az call: $args"
}
function global:Invoke-WebRequest {
  param([string]$Uri,[string]$Method,[hashtable]$Headers,[string]$ContentType,[string]$Body,[switch]$SkipHttpErrorCheck)
  if($Headers.Authorization -ne "Bearer mock-token"){throw "PowerShell did not send the bearer token"}
  if($Headers["x-release-commit-sha"] -ne "abcdef1" -or $Body -notmatch '"releaseCommitSha":"abcdef1"'){throw "Release SHA binding failed"}
  $traceId=if($Headers["x-session13-smoke-mode"] -eq "normal"){"00000000000000000000000000000001"}else{"00000000000000000000000000000002"}
  [pscustomobject]@{StatusCode=204;Headers=@{traceparent="00-$traceId-0000000000000001-01"}}
}
function global:Start-Sleep {param([int]$Seconds)}
$env:SESSION13_SMOKE_URL="https://normal.example.invalid"
$env:SESSION13_SMOKE_FAILURE_URL="https://failure.example.invalid"
$env:SESSION13_AI_RESOURCE_ID="/subscriptions/s/resourceGroups/r/providers/Microsoft.Insights/components/a"
$env:SESSION13_LOG_ANALYTICS_WORKSPACE_ID="/subscriptions/s/resourceGroups/r/providers/Microsoft.OperationalInsights/workspaces/w"
$env:SESSION13_SMOKE_BEARER_TOKEN="mock-token"

foreach($boundary in @(@{Timeout=30;Retry=15},@{Timeout=120;Retry=60})){
  $env:SESSION13_SMOKE_TIMEOUT_SECONDS=[string]$boundary.Timeout
  $env:SESSION13_SMOKE_RETRY_SECONDS=[string]$boundary.Retry
  $resultPath=Join-Path $env:SMOKE_TEST_ROOT ".smoke-contract-$($boundary.Timeout)-$($boundary.Retry).json"
  Remove-Item $resultPath -Force -ErrorAction SilentlyContinue
  & $env:SMOKE_PS_PATH -Mode Pipeline -Environment nonproduction -CommitSha abcdef1 -ResultPath $resultPath
  $result=Get-Content $resultPath -Raw|ConvertFrom-Json
  if($result.status -ne "passed" -or [int]$result.checks.telemetryPollAttempts -ne 3 -or
     [int]$result.checks.telemetryPollTimeoutSeconds -ne [int]$boundary.Timeout -or
     [int]$result.checks.telemetryPollRetrySeconds -ne [int]$boundary.Retry -or
     -not [bool]$result.checks.telemetryIngestionStable -or [bool]$result.checks.telemetryPollTimedOut){
    throw "PowerShell recorded inconsistent attempts or polling settings"
  }
  Remove-Item $resultPath -Force
}
foreach($boundary in @(@{Timeout=30;Retry=16},@{Timeout=119;Retry=60})){
  $env:SESSION13_SMOKE_TIMEOUT_SECONDS=[string]$boundary.Timeout
  $env:SESSION13_SMOKE_RETRY_SECONDS=[string]$boundary.Retry
  $errorText=""
  try{& $env:SMOKE_PS_PATH -Mode Pipeline -Environment nonproduction -CommitSha abcdef1 -ResultPath (Join-Path $env:SMOKE_TEST_ROOT ".smoke-contract-invalid.json")}
  catch{$errorText=$_.Exception.Message}
  if($errorText -notlike "*at least twice*"){throw "PowerShell accepted an invalid timeout/retry boundary"}
}
'''
    result = run(
        ["pwsh", "-NoLogo", "-NoProfile", "-NonInteractive", "-Command", "-"],
        script,
        environment,
    )
    if "mock-token" in result.stdout or "mock-token" in result.stderr:
        raise RuntimeError("PowerShell exposed the bearer token in process output")


def main() -> int:
    environment = os.environ.copy()
    environment["SMOKE_SH_PATH"] = str(BASH_SMOKE)
    environment["SMOKE_PS_PATH"] = str(POWERSHELL_SMOKE)
    environment["SMOKE_TEST_ROOT"] = str(SCRIPT_DIR)
    test_static_contract()
    test_bash_contract(environment)
    test_powershell_contract(environment)
    print(
        "PASS: paired smoke mocks, complete PowerShell runtime, timing boundaries, "
        "attempt counts, and failure-path checks."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
