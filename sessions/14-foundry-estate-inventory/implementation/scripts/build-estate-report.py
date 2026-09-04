#!/usr/bin/env python3
"""Build an Azure AI estate report with lifecycle and retirement findings."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import date, datetime, timedelta, timezone
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scope-path", type=Path, required=True)
    parser.add_argument("--account-query-path", type=Path, required=True)
    parser.add_argument("--service-health-query-path", type=Path, required=True)
    parser.add_argument("--advisor-query-path", type=Path, required=True)
    parser.add_argument("--output-path", type=Path)
    return parser.parse_args()


def run_az(args: list[str]):
    result = subprocess.run(
        ["az", *args], capture_output=True, text=True, check=False
    )
    if result.returncode != 0:
        raise SystemExit(
            f"Azure CLI call failed: az {' '.join(args)}\n{result.stderr.strip()}"
        )
    return json.loads(result.stdout) if result.stdout.strip() else None


def read_graph(query: str, management_group: str) -> list[dict]:
    records: list[dict] = []
    skip_token = None
    while True:
        args = [
            "graph",
            "query",
            "--graph-query",
            query,
            "--management-groups",
            management_group,
            "--first",
            "1000",
            "--output",
            "json",
        ]
        if skip_token:
            args += ["--skip-token", skip_token]
        page = run_az(args) or {}
        records.extend(page.get("data", []))
        skip_token = page.get("skip_token") or page.get("skipToken")
        if not skip_token:
            return records


def parse_retirement_date(value: object) -> date | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(str(value).replace("Z", "+00:00")).date()
    except ValueError:
        return None


def model_entry_matches(
    candidate: dict, account_kind: str, deployment: dict
) -> bool:
    model = candidate.get("model") or {}
    return (
        str(candidate.get("kind", "")).casefold() == account_kind.casefold()
        and str(model.get("name", "")).casefold()
        == str(deployment.get("modelName", "")).casefold()
        and str(model.get("format", "")).casefold()
        == str(deployment.get("modelFormat", "")).casefold()
        and str(model.get("version", "")).casefold()
        == str(deployment.get("modelVersion", "")).casefold()
    )


def lifecycle_record(
    account: dict,
    deployment: dict,
    model_catalog: list[dict],
    owner_tag_key: str,
    warning_cutoff: date,
) -> tuple[dict, str | None]:
    matching = next(
        (
            candidate
            for candidate in model_catalog
            if model_entry_matches(candidate, account["accountKind"], deployment)
        ),
        None,
    )
    owner = (account.get("tags") or {}).get(owner_tag_key)
    record = {
        "accountName": account["name"],
        "deploymentName": deployment["deploymentName"],
        "modelName": deployment["modelName"],
        "modelFormat": deployment["modelFormat"],
        "modelVersion": deployment["modelVersion"],
        "owner": owner,
        "lifecycleStatus": None,
        "inferenceRetirementDate": None,
        "skuRetirementDate": None,
    }
    if not matching:
        return record, (
            f"{account['name']}/{deployment['deploymentName']} is absent from the "
            "regional Models API response; the lifecycle owner must check it manually."
        )

    model = matching.get("model") or {}
    retirement_date = parse_retirement_date(
        (model.get("deprecation") or {}).get("inference")
    )
    sku = next(
        (
            candidate
            for candidate in model.get("skus") or []
            if str(candidate.get("name", "")).casefold()
            == str(deployment.get("skuName", "")).casefold()
        ),
        {},
    )
    sku_retirement_date = parse_retirement_date(sku.get("deprecationDate"))
    effective_retirement_date = sku_retirement_date or retirement_date
    lifecycle_status = str(model.get("lifecycleStatus", ""))
    record.update(
        {
            "lifecycleStatus": lifecycle_status or None,
            "inferenceRetirementDate": retirement_date.isoformat()
            if retirement_date
            else None,
            "skuRetirementDate": sku_retirement_date.isoformat()
            if sku_retirement_date
            else None,
        }
    )
    deployment_label = f"{account['name']}/{deployment['deploymentName']}"
    if lifecycle_status.casefold() == "deprecated" or (
        effective_retirement_date and effective_retirement_date < date.today()
    ):
        return record, f"{deployment_label} is retired and must be replaced or removed."
    if lifecycle_status.casefold() == "deprecating":
        return record, f"{deployment_label} is deprecated and needs a replacement plan."
    if effective_retirement_date and effective_retirement_date <= warning_cutoff:
        return record, (
            f"{deployment_label} retires on {effective_retirement_date.isoformat()} "
            "and needs a replacement plan."
        )
    return record, None


def main() -> None:
    args = parse_args()
    scope = json.loads(args.scope_path.read_text(encoding="utf-8"))
    account_query = args.account_query_path.read_text(encoding="utf-8")
    service_health_query = args.service_health_query_path.read_text(encoding="utf-8")
    advisor_query = args.advisor_query_path.read_text(encoding="utf-8")
    in_scope_kinds = {
        kind.casefold() for kind in scope["inScopeAccountKinds"]
    }
    approved_regions = {
        region.casefold() for region in scope["approvedRegions"]
    }
    exceptions = {
        entry["accountName"].casefold()
        for entry in scope.get("recordedExceptions", [])
    }

    accounts: list[dict] = []
    service_health_signals: list[dict] = []
    advisor_findings: list[dict] = []
    seen_account_ids: set[str] = set()
    seen_signal_ids: set[tuple[str, str]] = set()
    seen_advisor_ids: set[str] = set()
    for management_group in scope["managementGroups"]:
        for account in read_graph(account_query, management_group):
            account_id = account["id"].casefold()
            if account_id not in seen_account_ids:
                seen_account_ids.add(account_id)
                accounts.append(account)
        for signal in read_graph(service_health_query, management_group):
            signal_id = (str(signal.get("trackingId", "")), str(signal.get("title", "")))
            if signal_id not in seen_signal_ids:
                seen_signal_ids.add(signal_id)
                service_health_signals.append(signal)
        for finding in read_graph(advisor_query, management_group):
            resource_id = str(finding.get("resourceId", "")).casefold()
            if resource_id and resource_id not in seen_advisor_ids:
                seen_advisor_ids.add(resource_id)
                advisor_findings.append(finding)

    in_scope: list[dict] = []
    adjacent: list[dict] = []
    findings: list[str] = []
    cost_tag_values: set[str] = set()
    for account in accounts:
        tags = account.get("tags") or {}
        kind = str(account.get("accountKind", "")).casefold()
        if kind not in in_scope_kinds:
            adjacent.append(account)
            if account["name"].casefold() not in exceptions:
                findings.append(
                    f"{account['name']} uses account kind "
                    f"'{account.get('accountKind')}', which is neither in scope "
                    "nor a recorded exception."
                )
            continue

        in_scope.append(account)
        missing = [
            key for key in scope["requiredTagKeys"]
            if not str(tags.get(key, "")).strip()
        ]
        if missing:
            findings.append(
                f"{account['name']} is missing required tag(s): {', '.join(missing)}."
            )
        if str(account.get("location", "")).casefold() not in approved_regions:
            findings.append(
                f"{account['name']} is in region '{account.get('location')}', "
                "which is not approved."
            )
        cost_value = tags.get(scope["costTagKey"])
        if cost_value:
            cost_tag_values.add(str(cost_value))

    model_catalogs: dict[tuple[str, str], list[dict]] = {}
    lifecycle_records: list[dict] = []
    warning_cutoff = date.today() + timedelta(
        days=scope["modelRetirementWarningDays"]
    )
    for account in in_scope:
        deployments = run_az(
            [
                "cognitiveservices",
                "account",
                "deployment",
                "list",
                "--name",
                account["name"],
                "--resource-group",
                account["resourceGroup"],
                "--subscription",
                account["subscriptionId"],
                "--output",
                "json",
            ]
        ) or []
        account["modelDeployments"] = [
            {
                "deploymentName": deployment.get("name"),
                "modelName": (deployment.get("properties", {}).get("model") or {}).get("name"),
                "modelFormat": (deployment.get("properties", {}).get("model") or {}).get("format"),
                "modelVersion": (deployment.get("properties", {}).get("model") or {}).get("version"),
                "skuName": (deployment.get("sku") or {}).get("name"),
                "skuCapacity": (deployment.get("sku") or {}).get("capacity"),
            }
            for deployment in deployments
        ]
        catalog_key = (account["subscriptionId"], account["location"])
        if catalog_key not in model_catalogs:
            model_catalogs[catalog_key] = (
                run_az(
                    [
                        "rest",
                        "--method",
                        "get",
                        "--url",
                        "https://management.azure.com/subscriptions/"
                        f"{account['subscriptionId']}/providers/Microsoft.CognitiveServices/"
                        f"locations/{account['location']}/models?api-version=2024-10-01",
                        "--output",
                        "json",
                    ]
                )
                or {}
            ).get("value", [])
        for deployment in account["modelDeployments"]:
            record, lifecycle_finding = lifecycle_record(
                account,
                deployment,
                model_catalogs[catalog_key],
                scope["ownerTagKey"],
                warning_cutoff,
            )
            lifecycle_records.append(record)
            if lifecycle_finding:
                findings.append(lifecycle_finding)

    in_scope_ids = {account["id"].casefold() for account in in_scope}
    advisor_findings = [
        finding
        for finding in advisor_findings
        if str(finding.get("resourceId", "")).casefold() in in_scope_ids
    ]
    for signal in service_health_signals:
        findings.append(
            "Service Health retirement advisory "
            f"'{signal.get('title')}' needs lifecycle-owner review."
        )
    for finding in advisor_findings:
        findings.append(
            "Azure Advisor retirement recommendation for "
            f"'{finding.get('resourceId')}' needs lifecycle-owner review."
        )

    report = {
        "approvedScope": scope["approvedScope"],
        "inventoryOwner": scope["inventoryOwner"],
        "lifecycleOwner": scope["lifecycleOwner"],
        "modelRetirementWarningDays": scope["modelRetirementWarningDays"],
        "accountsInScope": in_scope,
        "adjacentAccounts": [
            {"name": account["name"], "accountKind": account.get("accountKind")}
            for account in adjacent
        ],
        "modelDeploymentCount": len(lifecycle_records),
        "modelLifecycle": lifecycle_records,
        "serviceHealthRetirementSignals": service_health_signals,
        "advisorRetirementFindings": advisor_findings,
        "costTagKey": scope["costTagKey"],
        "costTagValues": sorted(cost_tag_values),
        "findings": findings,
    }
    if args.output_path:
        args.output_path.write_text(
            json.dumps(report, indent=2) + "\n", encoding="utf-8"
        )
        print(f"Report written to {args.output_path}")

    print(
        f"Read {len(accounts)} Azure AI account(s): {len(in_scope)} in scope, "
        f"{len(adjacent)} of another kind, with {len(lifecycle_records)} model deployment(s)."
    )
    print(
        f"Found {len(service_health_signals)} Service Health retirement signal(s) and "
        f"{len(advisor_findings)} Azure Advisor retirement finding(s)."
    )
    if findings:
        print(f"FAIL: {len(findings)} finding(s) need an owner:")
        for finding in findings:
            print(f"  - {finding}")
        raise SystemExit(1)
    print(
        "PASS: Every in-scope account has the required tags, an approved region, "
        "a recorded kind, and no lifecycle finding."
    )


if __name__ == "__main__":
    main()
