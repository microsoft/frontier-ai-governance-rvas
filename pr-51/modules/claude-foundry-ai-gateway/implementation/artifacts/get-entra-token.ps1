Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$tenantId = "__REQUIRED_TENANT_ID__"
$resource = "api://__REQUIRED_GATEWAY_CLIENT_ID__"
if ("$tenantId$resource".Contains("__REQUIRED_")) {
    throw "Configure the gateway tenant and audience before installing this helper."
}
Get-Command az -ErrorAction Stop | Out-Null
$token = & az account get-access-token --tenant $tenantId --resource $resource --query accessToken --output tsv
if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("Gateway token acquisition failed. Signing in to the approved tenant.")
    $loginOutput = & az login --tenant $tenantId --scope "$resource/.default" --output none
    if ($LASTEXITCODE -ne 0) { throw "Azure CLI sign-in failed." }
    if ($loginOutput) { [Console]::Error.WriteLine(($loginOutput -join [Environment]::NewLine)) }
    $token = & az account get-access-token --tenant $tenantId --resource $resource --query accessToken --output tsv
    if ($LASTEXITCODE -ne 0) { throw "Gateway token acquisition failed after sign-in." }
}
if ([string]::IsNullOrWhiteSpace(($token -join ""))) { throw "Azure CLI returned an empty token." }
[Console]::Out.WriteLine(($token -join "").Trim())
