[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ArtifactRoot = (Join-Path $PSScriptRoot '..\artifacts')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-PythonCommand {
    foreach ($candidate in @('python', 'python3')) {
        $command = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($null -ne $command) {
            return $command.Source
        }
    }
    throw 'Python is required.'
}

function Assert-Command {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command is unavailable: $Name"
    }
}

function Invoke-AzJson {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments,

        [Parameter(Mandatory)]
        [string]$Description
    )

    $raw = & az @Arguments --only-show-errors --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed.`n$($raw | Out-String)"
    }
    return ($raw | Out-String).Trim()
}

function Invoke-AzRestJson {
    param(
        [Parameter(Mandatory)]
        [string]$Method,

        [Parameter(Mandatory)]
        [string]$Url,

        [Parameter(Mandatory)]
        [string]$Description
    )

    $raw = & az rest --method $Method --url $Url --only-show-errors --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed.`n$($raw | Out-String)"
    }
    return ($raw | Out-String).Trim()
}

function Invoke-PythonScript {
    param(
        [Parameter(Mandatory)]
        [string]$Script,

        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [hashtable]$Environment = @{}
    )

    $previous = @{}
    foreach ($name in $Environment.Keys) {
        $previous[$name] = [Environment]::GetEnvironmentVariable($name)
        [Environment]::SetEnvironmentVariable($name, [string]$Environment[$name])
    }

    try {
        $output = $Script | & $script:PythonCommand - @Arguments 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw (($output | Out-String).Trim())
        }
        return ($output | Out-String).Trim()
    }
    finally {
        foreach ($name in $Environment.Keys) {
            [Environment]::SetEnvironmentVariable($name, $previous[$name])
        }
    }
}

$script:PythonCommand = Resolve-PythonCommand
$resolvedArtifactRoot = (Resolve-Path -LiteralPath $ArtifactRoot -ErrorAction Stop).Path
$requiredFiles = @(
    'control-definition.json'
    'identity/app-registrations.json'
    'identity/key-vault-certificate-binding.json'
    'governance/token-claim-contract.json'
    'runtime/settings.json'
    'runtime/obo_proxy.py'
    'runtime/requirements.txt'
)

Assert-Command -Name 'az'
Assert-Command -Name 'curl'
Assert-Command -Name $script:PythonCommand
foreach ($relativePath in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $resolvedArtifactRoot $relativePath) -PathType Leaf)) {
        throw "Required implementation artifact is missing: $relativePath"
    }
}

$configPython = @'
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

MODULE_MARKER = 'optional-module-obo-delegated-access'
REQUIRED_FILES = [
    'control-definition.json',
    'identity/app-registrations.json',
    'identity/key-vault-certificate-binding.json',
    'governance/token-claim-contract.json',
    'runtime/settings.json',
    'runtime/obo_proxy.py',
    'runtime/requirements.txt',
]
REQUIRED_SENTINELS = [
    '__REQUIRED_APPLICATION_OWNER__',
    '__REQUIRED_CERTIFICATE_MOUNT_PATH__',
    '__REQUIRED_CERTIFICATE_THUMBPRINT__',
    '__REQUIRED_CLIENT_APPLICATION_ID__',
    '__REQUIRED_CLIENT_APP_OBJECT_ID__',
    '__REQUIRED_DELIVERY_OWNER__',
    '__REQUIRED_DOWNSTREAM_API_OWNER__',
    '__REQUIRED_DOWNSTREAM_APP_OBJECT_ID__',
    '__REQUIRED_DOWNSTREAM_AUDIENCE__',
    '__REQUIRED_DOWNSTREAM_ENDPOINT__',
    '__REQUIRED_DOWNSTREAM_SCOPE_ID__',
    '__REQUIRED_DOWNSTREAM_SCOPE__',
    '__REQUIRED_IDENTITY_OWNER__',
    '__REQUIRED_KEY_VAULT_CERTIFICATE_URI__',
    '__REQUIRED_MIDDLE_TIER_APPLICATION_ID__',
    '__REQUIRED_MIDDLE_TIER_APP_OBJECT_ID__',
    '__REQUIRED_MIDDLE_TIER_AUDIENCE__',
    '__REQUIRED_MIDDLE_TIER_SCOPE_ID__',
    '__REQUIRED_TENANT_ID__',
]
SENTINEL_PATTERN = re.compile(r'__REQUIRED_[A-Z0-9_]+__')
GUID_PATTERN = re.compile(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
HTTPS_PATTERN = re.compile(r'^https://', re.IGNORECASE)
KEY_VAULT_CERTIFICATE_PATTERN = re.compile(r'^https://[^/]+/certificates/[^/]+(?:/[^/]+)?$', re.IGNORECASE)
THUMBPRINT_PATTERN = re.compile(r'^[0-9A-F]{40}$')


def fail(message: str) -> None:
    raise SystemExit(message)


def read_text(path_value: Path) -> str:
    try:
        return path_value.read_text(encoding='utf-8')
    except OSError as error:
        fail(f'Cannot read artifact {path_value}: {error}')


def read_json(path_value: Path) -> object:
    try:
        return json.loads(read_text(path_value))
    except json.JSONDecodeError as error:
        fail(f'Artifact is not valid JSON: {path_value} ({error})')


def require_guid(value: object, label: str) -> str:
    if not isinstance(value, str) or not GUID_PATTERN.fullmatch(value):
        fail(f'{label} must be a GUID.')
    return value.lower()


def require_non_empty(value: object, label: str) -> str:
    if not isinstance(value, str) or not value.strip():
        fail(f'{label} must be a non-empty string.')
    return value.strip()


def require_https(value: object, label: str) -> str:
    candidate = require_non_empty(value, label)
    if not HTTPS_PATTERN.match(candidate):
        fail(f'{label} must use HTTPS.')
    return candidate


def normalize_thumbprint(value: object, label: str) -> str:
    candidate = require_non_empty(value, label).replace(':', '').replace(' ', '').upper()
    if not THUMBPRINT_PATTERN.fullmatch(candidate):
        fail(f'{label} must be a 40-character SHA-1 thumbprint.')
    return candidate


def normalize_guid_list(value: object, label: str) -> list[str]:
    if not isinstance(value, list) or not value:
        fail(f'{label} must be a non-empty list of GUID strings.')
    normalized: list[str] = []
    for index, item in enumerate(value, start=1):
        normalized.append(require_guid(item, f'{label}[{index}]'))
    return normalized


def ensure_matching_lists(left: list[str], right: list[str], label: str) -> None:
    if sorted(left) != sorted(right):
        fail(f'{label} must match across the implementation files.')


def expected_scope(audience: str, scope_value: str) -> str:
    return audience.rstrip('/') + '/' + scope_value


artifact_root = Path(sys.argv[1]).expanduser().resolve()
for relative in REQUIRED_FILES:
    path_value = artifact_root / relative
    if not path_value.is_file():
        fail(f'Required implementation artifact is missing: {relative}')

combined_text = '\n'.join(read_text(artifact_root / relative) for relative in REQUIRED_FILES)
for sentinel in REQUIRED_SENTINELS:
    if sentinel not in combined_text:
        fail(f'Required OBO decision sentinel is missing from the implementation files: {sentinel}')

sentinel_locations: list[str] = []
for path_value in sorted(artifact_root.rglob('*')):
    if not path_value.is_file():
        continue
    try:
        text = path_value.read_text(encoding='utf-8')
    except UnicodeDecodeError:
        continue
    for line_number, line in enumerate(text.splitlines(), start=1):
        for sentinel in SENTINEL_PATTERN.findall(line):
            sentinel_locations.append(f'{path_value}:{line_number} {sentinel}')
if sentinel_locations:
    fail('Resolve every required module decision before Graph changes:\n' + '\n'.join(sorted(set(sentinel_locations))))

control = read_json(artifact_root / 'control-definition.json')
app_registrations = read_json(artifact_root / 'identity/app-registrations.json')
binding = read_json(artifact_root / 'identity/key-vault-certificate-binding.json')
token_contract = read_json(artifact_root / 'governance/token-claim-contract.json')
settings = read_json(artifact_root / 'runtime/settings.json')

if control.get('implementationSession') != MODULE_MARKER:
    fail(f'control-definition.json must use implementationSession={MODULE_MARKER}.')
if settings.get('implementationSession') != MODULE_MARKER:
    fail(f'runtime/settings.json must use implementationSession={MODULE_MARKER}.')

control_scope = control.get('scope') or {}
owners = control.get('owners') or {}
client = app_registrations.get('client') or {}
middle_tier = app_registrations.get('middleTier') or {}
downstream = app_registrations.get('downstreamApi') or {}
consent = app_registrations.get('consent') or {}
inbound = token_contract.get('inbound') or {}
downstream_contract = token_contract.get('downstream') or {}

required_owner_fields = {
    'identityOwner': '__REQUIRED_IDENTITY_OWNER__',
    'applicationOwner': '__REQUIRED_APPLICATION_OWNER__',
    'downstreamApiOwner': '__REQUIRED_DOWNSTREAM_API_OWNER__',
    'deliveryOwner': '__REQUIRED_DELIVERY_OWNER__',
}
for field_name in required_owner_fields:
    require_non_empty(owners.get(field_name), f'control-definition owners.{field_name}')

control_tenant_id = require_guid(control.get('tenantId'), 'control-definition tenantId')
if require_guid(settings.get('tenantId'), 'runtime settings tenantId') != control_tenant_id:
    fail('Tenant IDs must match between control-definition.json and runtime/settings.json.')

client_object_id = require_guid(client.get('applicationObjectId'), 'identity app-registrations client.applicationObjectId')
middle_tier_object_id = require_guid(middle_tier.get('applicationObjectId'), 'identity app-registrations middleTier.applicationObjectId')
downstream_object_id = require_guid(downstream.get('applicationObjectId'), 'identity app-registrations downstreamApi.applicationObjectId')

if require_guid(control_scope.get('clientApplicationObjectId'), 'control-definition scope.clientApplicationObjectId') != client_object_id:
    fail('Client application object IDs must match between control-definition.json and identity/app-registrations.json.')
if require_guid(control_scope.get('middleTierApplicationObjectId'), 'control-definition scope.middleTierApplicationObjectId') != middle_tier_object_id:
    fail('Middle-tier application object IDs must match between control-definition.json and identity/app-registrations.json.')
if require_guid(control_scope.get('downstreamApplicationObjectId'), 'control-definition scope.downstreamApplicationObjectId') != downstream_object_id:
    fail('Downstream application object IDs must match between control-definition.json and identity/app-registrations.json.')

middle_tier_scope = middle_tier.get('delegatedScope') or {}
downstream_scope = downstream.get('delegatedScope') or {}
middle_tier_scope_id = require_guid(middle_tier_scope.get('id'), 'identity app-registrations middleTier.delegatedScope.id')
downstream_scope_id = require_guid(downstream_scope.get('id'), 'identity app-registrations downstreamApi.delegatedScope.id')
if require_guid(client.get('middleTierDelegatedScopeId'), 'identity app-registrations client.middleTierDelegatedScopeId') != middle_tier_scope_id:
    fail('Client middle-tier delegated scope IDs must match in identity/app-registrations.json.')
if require_guid(middle_tier.get('downstreamDelegatedScopeId'), 'identity app-registrations middleTier.downstreamDelegatedScopeId') != downstream_scope_id:
    fail('Middle-tier downstream delegated scope IDs must match in identity/app-registrations.json.')

middle_tier_audience = require_non_empty(middle_tier.get('identifierUri'), 'identity app-registrations middleTier.identifierUri')
downstream_audience = require_non_empty(downstream.get('identifierUri'), 'identity app-registrations downstreamApi.identifierUri')
if require_non_empty(inbound.get('audience'), 'token-claim contract inbound.audience') != middle_tier_audience:
    fail('Middle-tier audience must match between identity/app-registrations.json and token-claim-contract.json.')
if require_non_empty(settings.get('middleTierAudience'), 'runtime settings middleTierAudience') != middle_tier_audience:
    fail('Middle-tier audience must match between identity/app-registrations.json and runtime/settings.json.')
if require_non_empty(downstream_contract.get('audience'), 'token-claim contract downstream.audience') != downstream_audience:
    fail('Downstream audience must match between identity/app-registrations.json and token-claim-contract.json.')

middle_tier_scope_value = require_non_empty(middle_tier_scope.get('value'), 'identity app-registrations middleTier.delegatedScope.value')
downstream_scope_value = require_non_empty(downstream_scope.get('value'), 'identity app-registrations downstreamApi.delegatedScope.value')
if middle_tier_scope_value != 'access_as_user':
    fail('The middle-tier delegated scope value must remain access_as_user.')
if require_non_empty(settings.get('inboundScope'), 'runtime settings inboundScope') != middle_tier_scope_value:
    fail('Inbound delegated scope must match between identity/app-registrations.json and runtime/settings.json.')
if require_non_empty(inbound.get('requiredScope'), 'token-claim contract inbound.requiredScope') != middle_tier_scope_value:
    fail('Inbound delegated scope must match between identity/app-registrations.json and token-claim-contract.json.')
if require_non_empty(middle_tier_scope.get('type'), 'identity app-registrations middleTier.delegatedScope.type') != 'User':
    fail('The middle-tier delegated scope type must remain User.')

required_downstream_scope = require_non_empty(downstream_contract.get('requiredDelegatedScope'), 'token-claim contract downstream.requiredDelegatedScope')
if downstream_scope_value != required_downstream_scope:
    fail('Downstream delegated scope values must match between identity/app-registrations.json and token-claim-contract.json.')
consent_scope = require_non_empty(consent.get('scope'), 'identity app-registrations consent.scope')
if consent_scope != downstream_scope_value:
    fail('Consent scope must match the downstream delegated scope value.')
if require_non_empty(consent.get('grantType'), 'identity app-registrations consent.grantType') != 'delegated':
    fail('The approved consent grantType must remain delegated.')
require_non_empty(consent.get('owner'), 'identity app-registrations consent.owner')

allowed_caller_ids = normalize_guid_list(settings.get('allowedCallerClientIds'), 'runtime settings allowedCallerClientIds')
token_allowed_caller_ids = normalize_guid_list(inbound.get('allowedClientIds'), 'token-claim contract inbound.allowedClientIds')
ensure_matching_lists(allowed_caller_ids, token_allowed_caller_ids, 'Allowed caller client IDs')
if len(allowed_caller_ids) != 1:
    fail('This module requires exactly one approved client application ID in the runtime and token-claim artifacts.')
client_application_id = allowed_caller_ids[0]

middle_tier_application_id = require_guid(settings.get('middleTierClientId'), 'runtime settings middleTierClientId')

downstream_endpoint = require_https(settings.get('downstreamEndpoint'), 'runtime settings downstreamEndpoint')
requested_scope = require_non_empty(settings.get('downstreamScope'), 'runtime settings downstreamScope')
contract_requested_scope = require_non_empty(downstream_contract.get('requestedScope'), 'token-claim contract downstream.requestedScope')
expected_requested = expected_scope(downstream_audience, downstream_scope_value)
if requested_scope != expected_requested or contract_requested_scope != expected_requested:
    fail('The downstream requested scope must equal the downstream audience plus the approved delegated scope value.')

issuer = require_non_empty(inbound.get('issuer'), 'token-claim contract inbound.issuer')
expected_issuer = f'https://login.microsoftonline.com/{control_tenant_id}/v2.0'
if issuer != expected_issuer:
    fail('The token-claim inbound issuer must use the approved tenant ID.')

key_vault_certificate_uri = require_https(binding.get('keyVaultCertificateUri'), 'key-vault certificate binding keyVaultCertificateUri')
if not KEY_VAULT_CERTIFICATE_PATTERN.match(key_vault_certificate_uri):
    fail('The Key Vault certificate reference must address a certificate resource.')
certificate_thumbprint = normalize_thumbprint(binding.get('certificateThumbprint'), 'key-vault certificate binding certificateThumbprint')
runtime_certificate_path = require_non_empty(binding.get('runtimeCertificatePath'), 'key-vault certificate binding runtimeCertificatePath')
if binding.get('runtimeCertificateFormat') != 'PFX':
    fail('The runtime certificate format must remain PFX.')
if binding.get('keyMustBeExportable') is not True:
    fail('The Key Vault certificate must be recorded as exportable for the mounted PFX pattern.')
if require_non_empty(settings.get('certificatePath'), 'runtime settings certificatePath') != runtime_certificate_path:
    fail('Runtime certificate paths must match between key-vault-certificate-binding.json and runtime/settings.json.')

result = {
    'moduleMarker': MODULE_MARKER,
    'artifactRoot': str(artifact_root),
    'tenantId': control_tenant_id,
    'client': {
        'objectId': client_object_id,
        'applicationId': client_application_id,
        'delegatedScopeId': middle_tier_scope_id,
    },
    'middleTier': {
        'objectId': middle_tier_object_id,
        'applicationId': middle_tier_application_id,
        'audience': middle_tier_audience,
        'delegatedScopeId': middle_tier_scope_id,
        'delegatedScopeValue': middle_tier_scope_value,
    },
    'downstream': {
        'objectId': downstream_object_id,
        'audience': downstream_audience,
        'delegatedScopeId': downstream_scope_id,
        'delegatedScopeValue': downstream_scope_value,
        'requestedScope': expected_requested,
        'endpoint': downstream_endpoint,
    },
    'consent': {
        'scope': consent_scope,
    },
    'keyVault': {
        'certificateUri': key_vault_certificate_uri,
        'thumbprint': certificate_thumbprint,
        'runtimePath': runtime_certificate_path,
    },
}
print(json.dumps(result))
'@

$planPython = @'
from __future__ import annotations

import base64
import copy
import hashlib
import json
import os
import ssl
from pathlib import Path


def fail(message: str) -> None:
    raise SystemExit(message)


def normalize_thumbprint(value: str) -> str:
    return value.replace(':', '').replace(' ', '').upper()


def owner_names(payload: object, label: str) -> list[str]:
    values = payload.get('value') if isinstance(payload, dict) else None
    if not isinstance(values, list) or not values:
        fail(f'{label} must have at least one application owner assigned.')
    result: list[str] = []
    for entry in values:
        if not isinstance(entry, dict):
            continue
        for key in ('displayName', 'userPrincipalName', 'appId', 'id'):
            value = entry.get(key)
            if isinstance(value, str) and value.strip():
                result.append(value.strip())
                break
    if not result:
        fail(f'{label} must expose at least one readable owner identity.')
    return result


def decode_base64_thumbprint(value: str | None) -> str | None:
    if not isinstance(value, str) or not value:
        return None
    try:
        return base64.b64decode(value).hex().upper()
    except Exception:
        return None


def key_vault_thumbprint(payload: dict[str, object]) -> str:
    decoded = decode_base64_thumbprint(payload.get('x509Thumbprint'))
    if decoded:
        return decoded
    for key in ('x509ThumbprintHex', 'thumbprint'):
        value = payload.get(key)
        if isinstance(value, str) and value.strip():
            return normalize_thumbprint(value)
    fail('Key Vault certificate lookup did not return a usable thumbprint value.')


def local_certificate_status(path_value: str, expected_thumbprint: str) -> dict[str, str | None]:
    path = Path(path_value).expanduser().resolve()
    if not path.is_file():
        fail(f'The configured runtime certificate path does not exist on this host: {path}')
    raw = path.read_bytes()
    text = None
    try:
        text = raw.decode('utf-8')
    except UnicodeDecodeError:
        text = None
    thumbprint = None
    detail = 'Runtime certificate file exists; local thumbprint comparison is unavailable for this container format without extra tooling.'
    if text and '-----BEGIN CERTIFICATE-----' in text and '-----END CERTIFICATE-----' in text:
        begin = text.find('-----BEGIN CERTIFICATE-----')
        end = text.find('-----END CERTIFICATE-----', begin)
        if begin >= 0 and end > begin:
            pem_block = text[begin:end + len('-----END CERTIFICATE-----')]
            der_bytes = ssl.PEM_cert_to_DER_cert(pem_block)
            thumbprint = hashlib.sha1(der_bytes).hexdigest().upper()
            detail = 'Runtime certificate file exists and the PEM certificate thumbprint was compared locally.'
    elif path.suffix.lower() in {'.cer', '.crt', '.der'}:
        thumbprint = hashlib.sha1(raw).hexdigest().upper()
        detail = 'Runtime certificate file exists and the DER certificate thumbprint was compared locally.'
    status = 'not_checked'
    if thumbprint:
        if thumbprint != expected_thumbprint:
            fail('The runtime certificate file does not match the approved certificate thumbprint.')
        status = 'matched'
        detail = 'Runtime certificate file exists and matches the approved certificate thumbprint.'
    return {
        'path': str(path),
        'status': status,
        'thumbprint': thumbprint,
        'detail': detail,
    }


def ensure_application(app: dict[str, object], expected_object_id: str, label: str) -> None:
    actual = str(app.get('id', '')).lower()
    if actual != expected_object_id:
        fail(f'{label} object ID does not match the implementation file scope.')
    if not isinstance(app.get('displayName'), str) or not str(app.get('displayName')).strip():
        fail(f'{label} must have a displayName.')
    if not isinstance(app.get('signInAudience'), str) or not str(app.get('signInAudience')).strip():
        fail(f'{label} must expose signInAudience in Microsoft Graph.')


def ensure_identifier_uri(app: dict[str, object], expected_audience: str, label: str) -> None:
    values = app.get('identifierUris') or []
    if expected_audience not in values:
        fail(f'{label} must contain the approved identifier URI / audience.')


def find_scope(app: dict[str, object], scope_id: str, label: str) -> dict[str, object]:
    api = app.get('api') or {}
    scopes = api.get('oauth2PermissionScopes') or []
    for scope in scopes:
        if isinstance(scope, dict) and str(scope.get('id', '')).lower() == scope_id:
            return scope
    fail(f'{label} must expose the approved delegated scope ID.')


def ensure_scope(scope: dict[str, object], expected_value: str, expected_type: str, label: str) -> None:
    if str(scope.get('value', '')) != expected_value:
        fail(f'{label} scope value does not match the implementation file.')
    if str(scope.get('type', '')) != expected_type:
        fail(f'{label} scope type does not match the implementation file.')
    if scope.get('isEnabled') is False:
        fail(f'{label} scope is disabled and cannot participate in OBO.')


def ensure_key_credential(app: dict[str, object], expected_thumbprint: str) -> None:
    for credential in app.get('keyCredentials') or []:
        if not isinstance(credential, dict):
            continue
        candidate = decode_base64_thumbprint(credential.get('customKeyIdentifier'))
        if candidate == expected_thumbprint:
            return
    fail('The middle-tier application registration does not contain the approved certificate credential thumbprint.')


def ensure_service_principal(service_principal: dict[str, object], expected_app_id: str, label: str) -> None:
    if str(service_principal.get('appId', '')).lower() != expected_app_id:
        fail(f'{label} service principal appId does not match the approved application ID.')
    if not isinstance(service_principal.get('id'), str) or not service_principal['id']:
        fail(f'{label} service principal is missing an object ID.')


def merge_required_resource_access(entries: object, resource_app_id: str, scope_id: str) -> tuple[list[dict[str, object]], bool]:
    current = copy.deepcopy(entries or [])
    if not isinstance(current, list):
        fail('requiredResourceAccess must remain a list in Microsoft Graph.')
    matches = [entry for entry in current if str(entry.get('resourceAppId', '')).lower() == resource_app_id]
    if len(matches) > 1:
        fail(f'Microsoft Graph returned multiple requiredResourceAccess entries for resourceAppId {resource_app_id}.')
    changed = False
    if not matches:
        current.append({
            'resourceAppId': resource_app_id,
            'resourceAccess': [{'id': scope_id, 'type': 'Scope'}],
        })
        return current, True
    entry = matches[0]
    resource_access = entry.get('resourceAccess') or []
    if not isinstance(resource_access, list):
        fail(f'resourceAccess for {resource_app_id} must remain a list in Microsoft Graph.')
    seen: set[tuple[str, str]] = set()
    normalized_access: list[dict[str, object]] = []
    has_scope = False
    for access in resource_access:
        access_id = str(access.get('id', '')).lower()
        access_type = str(access.get('type', ''))
        if access_id == scope_id and access_type != 'Scope':
            fail(f'The approved delegated permission ID {scope_id} is present with type {access_type}, not Scope.')
        if access_id == scope_id and access_type == 'Scope':
            has_scope = True
        key = (access_id, access_type)
        if key not in seen:
            seen.add(key)
            normalized_access.append({'id': access_id, 'type': access_type})
    if not has_scope:
        normalized_access.append({'id': scope_id, 'type': 'Scope'})
        changed = True
    entry['resourceAccess'] = normalized_access
    return current, changed


def merge_scope_string(scope_string: str, required_scope: str) -> tuple[str, bool]:
    values = [item for item in scope_string.split() if item]
    if required_scope in values:
        return ' '.join(values), False
    values.append(required_scope)
    return ' '.join(values), True


config = json.loads(os.environ['CONFIG_JSON'])
account = json.loads(os.environ['ACCOUNT_JSON'])
key_vault = json.loads(os.environ['KEYVAULT_JSON'])
client_app = json.loads(os.environ['CLIENT_APP_JSON'])
middle_app = json.loads(os.environ['MIDDLE_APP_JSON'])
downstream_app = json.loads(os.environ['DOWNSTREAM_APP_JSON'])
client_owners = json.loads(os.environ['CLIENT_OWNERS_JSON'])
middle_owners = json.loads(os.environ['MIDDLE_OWNERS_JSON'])
downstream_owners = json.loads(os.environ['DOWNSTREAM_OWNERS_JSON'])
middle_sp = json.loads(os.environ['MIDDLE_SP_JSON'])
downstream_sp = json.loads(os.environ['DOWNSTREAM_SP_JSON'])
grants_payload = json.loads(os.environ['GRANTS_JSON'])

tenant_id = str(account.get('tenantId') or account.get('homeTenantId') or '').lower()
if tenant_id != config['tenantId']:
    fail('Azure CLI is not signed into the approved tenant recorded in the implementation files.')

expected_thumbprint = config['keyVault']['thumbprint']
if key_vault_thumbprint(key_vault) != expected_thumbprint:
    fail('The Key Vault certificate reference does not resolve to the approved certificate thumbprint.')
local_certificate = local_certificate_status(config['keyVault']['runtimePath'], expected_thumbprint)

ensure_application(client_app, config['client']['objectId'], 'Client application')
ensure_application(middle_app, config['middleTier']['objectId'], 'Middle-tier application')
ensure_application(downstream_app, config['downstream']['objectId'], 'Downstream application')

if str(client_app.get('appId', '')).lower() != config['client']['applicationId']:
    fail('The client application appId does not match the approved allowed caller client ID.')
if str(middle_app.get('appId', '')).lower() != config['middleTier']['applicationId']:
    fail('The middle-tier application appId does not match runtime/settings.json.')

ensure_identifier_uri(middle_app, config['middleTier']['audience'], 'Middle-tier application')
ensure_identifier_uri(downstream_app, config['downstream']['audience'], 'Downstream application')
ensure_scope(find_scope(middle_app, config['middleTier']['delegatedScopeId'], 'Middle-tier application'), config['middleTier']['delegatedScopeValue'], 'User', 'Middle-tier application')
ensure_scope(find_scope(downstream_app, config['downstream']['delegatedScopeId'], 'Downstream application'), config['downstream']['delegatedScopeValue'], 'User', 'Downstream application')
ensure_key_credential(middle_app, expected_thumbprint)
ensure_service_principal(middle_sp, config['middleTier']['applicationId'], 'Middle-tier')
ensure_service_principal(downstream_sp, str(downstream_app.get('appId', '')).lower(), 'Downstream')

client_plan, client_changed = merge_required_resource_access(
    client_app.get('requiredResourceAccess'),
    str(middle_app.get('appId', '')).lower(),
    config['middleTier']['delegatedScopeId'],
)
middle_plan, middle_changed = merge_required_resource_access(
    middle_app.get('requiredResourceAccess'),
    str(downstream_app.get('appId', '')).lower(),
    config['downstream']['delegatedScopeId'],
)

matching_grants = [
    grant for grant in (grants_payload.get('value') or [])
    if isinstance(grant, dict)
    and str(grant.get('clientId', '')).lower() == str(middle_sp.get('id', '')).lower()
    and str(grant.get('resourceId', '')).lower() == str(downstream_sp.get('id', '')).lower()
]
all_principals = [grant for grant in matching_grants if str(grant.get('consentType', '')) == 'AllPrincipals']
principal_grants = [grant for grant in matching_grants if str(grant.get('consentType', '')) == 'Principal']
if len(all_principals) > 1:
    fail('Multiple AllPrincipals delegated grants already exist for the middle-tier to downstream API path.')

actions: list[dict[str, object]] = [
    {
        'id': 'client-required-resource-access',
        'title': 'Client application delegated permission merge',
        'changeRequired': client_changed,
        'method': 'PATCH',
        'url': f"https://graph.microsoft.com/v1.0/applications/{client_app['id']}",
        'body': {'requiredResourceAccess': client_plan},
        'notes': [
            'Preserves unrelated requiredResourceAccess entries and merges only the approved middle-tier delegated scope.',
            f"Approved delegated scope: {config['middleTier']['delegatedScopeValue']} ({config['middleTier']['delegatedScopeId']}).",
        ],
    },
    {
        'id': 'middle-tier-required-resource-access',
        'title': 'Middle-tier application delegated permission merge',
        'changeRequired': middle_changed,
        'method': 'PATCH',
        'url': f"https://graph.microsoft.com/v1.0/applications/{middle_app['id']}",
        'body': {'requiredResourceAccess': middle_plan},
        'notes': [
            'Preserves unrelated requiredResourceAccess entries and merges only the approved downstream delegated scope.',
            f"Approved delegated scope: {config['downstream']['delegatedScopeValue']} ({config['downstream']['delegatedScopeId']}).",
        ],
    },
]

if all_principals:
    existing_grant = all_principals[0]
    merged_scope, consent_changed = merge_scope_string(str(existing_grant.get('scope', '') or ''), config['consent']['scope'])
    consent_action = {
        'id': 'middle-tier-admin-consent',
        'title': 'Middle-tier to downstream delegated admin-consent merge',
        'changeRequired': consent_changed,
        'method': 'PATCH',
        'url': f"https://graph.microsoft.com/v1.0/oauth2PermissionGrants/{existing_grant['id']}",
        'body': {'scope': merged_scope},
        'notes': [
            'Explicit confirmation is required before changing the tenant-wide delegated grant.',
            f"Existing AllPrincipals scope string: {str(existing_grant.get('scope', '') or '(empty)')}",
            f"Approved delegated scope to merge: {config['consent']['scope']}",
        ],
    }
else:
    consent_action = {
        'id': 'middle-tier-admin-consent',
        'title': 'Middle-tier to downstream delegated admin-consent creation',
        'changeRequired': True,
        'method': 'POST',
        'url': 'https://graph.microsoft.com/v1.0/oauth2PermissionGrants',
        'body': {
            'clientId': middle_sp['id'],
            'consentType': 'AllPrincipals',
            'resourceId': downstream_sp['id'],
            'scope': config['consent']['scope'],
        },
        'notes': [
            'Explicit confirmation is required before creating the tenant-wide delegated grant.',
            f"Approved delegated scope to grant: {config['consent']['scope']}",
        ],
    }
if principal_grants:
    consent_action['notes'].append(
        f"Preserves {len(principal_grants)} existing Principal-scoped delegated grant(s)."
    )
actions.append(consent_action)

plan = {
    'summary': {
        'tenantId': config['tenantId'],
        'previewSupported': False,
        'client': {
            'displayName': client_app['displayName'],
            'objectId': client_app['id'],
            'applicationId': client_app['appId'],
            'signInAudience': client_app['signInAudience'],
            'owners': owner_names(client_owners, 'Client application'),
        },
        'middleTier': {
            'displayName': middle_app['displayName'],
            'objectId': middle_app['id'],
            'applicationId': middle_app['appId'],
            'signInAudience': middle_app['signInAudience'],
            'owners': owner_names(middle_owners, 'Middle-tier application'),
            'audience': config['middleTier']['audience'],
            'delegatedScope': config['middleTier']['delegatedScopeValue'],
        },
        'downstream': {
            'displayName': downstream_app['displayName'],
            'objectId': downstream_app['id'],
            'applicationId': downstream_app['appId'],
            'signInAudience': downstream_app['signInAudience'],
            'owners': owner_names(downstream_owners, 'Downstream application'),
            'audience': config['downstream']['audience'],
            'delegatedScope': config['downstream']['delegatedScopeValue'],
        },
        'certificate': {
            'thumbprint': expected_thumbprint,
            'runtimePath': local_certificate['path'],
            'runtimeCheckStatus': local_certificate['status'],
            'runtimeCheckDetail': local_certificate['detail'],
        },
    },
    'actions': actions,
}
print(json.dumps(plan))
'@

$configJson = Invoke-PythonScript -Script $configPython -Arguments @($resolvedArtifactRoot)
$config = $configJson | ConvertFrom-Json -Depth 50
$accountJson = Invoke-AzJson -Arguments @('account', 'show') -Description 'Azure CLI account lookup'
$keyVaultJson = Invoke-AzJson -Arguments @('keyvault', 'certificate', 'show', '--id', [string]$config.keyVault.certificateUri) -Description 'Key Vault certificate lookup'
$clientObjectId = [string]$config.client.objectId
$middleTierObjectId = [string]$config.middleTier.objectId
$downstreamObjectId = [string]$config.downstream.objectId
$middleTierApplicationId = [string]$config.middleTier.applicationId

$clientAppJson = Invoke-AzRestJson -Method 'GET' -Url "https://graph.microsoft.com/v1.0/applications/$clientObjectId?`$select=id,appId,displayName,identifierUris,signInAudience,requiredResourceAccess,api,keyCredentials" -Description 'Client application lookup'
$middleTierAppJson = Invoke-AzRestJson -Method 'GET' -Url "https://graph.microsoft.com/v1.0/applications/$middleTierObjectId?`$select=id,appId,displayName,identifierUris,signInAudience,requiredResourceAccess,api,keyCredentials" -Description 'Middle-tier application lookup'
$downstreamAppJson = Invoke-AzRestJson -Method 'GET' -Url "https://graph.microsoft.com/v1.0/applications/$downstreamObjectId?`$select=id,appId,displayName,identifierUris,signInAudience,requiredResourceAccess,api,keyCredentials" -Description 'Downstream application lookup'
$clientOwnersJson = Invoke-AzRestJson -Method 'GET' -Url "https://graph.microsoft.com/v1.0/applications/$clientObjectId/owners?`$select=id,displayName,userPrincipalName,appId&`$top=50" -Description 'Client application owners lookup'
$middleTierOwnersJson = Invoke-AzRestJson -Method 'GET' -Url "https://graph.microsoft.com/v1.0/applications/$middleTierObjectId/owners?`$select=id,displayName,userPrincipalName,appId&`$top=50" -Description 'Middle-tier application owners lookup'
$downstreamOwnersJson = Invoke-AzRestJson -Method 'GET' -Url "https://graph.microsoft.com/v1.0/applications/$downstreamObjectId/owners?`$select=id,displayName,userPrincipalName,appId&`$top=50" -Description 'Downstream application owners lookup'
$middleTierSpJson = Invoke-AzRestJson -Method 'GET' -Url "https://graph.microsoft.com/v1.0/servicePrincipals(appId='$middleTierApplicationId')?`$select=id,appId,displayName,servicePrincipalType" -Description 'Middle-tier service principal lookup'
$downstreamApplication = $downstreamAppJson | ConvertFrom-Json -Depth 50
$downstreamApplicationId = [string]$downstreamApplication.appId
$downstreamSpJson = Invoke-AzRestJson -Method 'GET' -Url "https://graph.microsoft.com/v1.0/servicePrincipals(appId='$downstreamApplicationId')?`$select=id,appId,displayName,servicePrincipalType" -Description 'Downstream service principal lookup'
$middleTierSp = $middleTierSpJson | ConvertFrom-Json -Depth 50
$grantsJson = Invoke-AzRestJson -Method 'GET' -Url "https://graph.microsoft.com/v1.0/oauth2PermissionGrants?`$filter=clientId%20eq%20'$($middleTierSp.id)'&`$select=id,clientId,consentType,principalId,resourceId,scope" -Description 'Delegated grant lookup'

$planJson = Invoke-PythonScript -Script $planPython -Environment @{
    CONFIG_JSON            = $configJson
    ACCOUNT_JSON           = $accountJson
    KEYVAULT_JSON          = $keyVaultJson
    CLIENT_APP_JSON        = $clientAppJson
    MIDDLE_APP_JSON        = $middleTierAppJson
    DOWNSTREAM_APP_JSON    = $downstreamAppJson
    CLIENT_OWNERS_JSON     = $clientOwnersJson
    MIDDLE_OWNERS_JSON     = $middleTierOwnersJson
    DOWNSTREAM_OWNERS_JSON = $downstreamOwnersJson
    MIDDLE_SP_JSON         = $middleTierSpJson
    DOWNSTREAM_SP_JSON     = $downstreamSpJson
    GRANTS_JSON            = $grantsJson
}
$plan = $planJson | ConvertFrom-Json -Depth 100

Write-Host 'Preflight passed.'
Write-Host 'previewSupported=false. Microsoft Graph has no native what-if for these application and delegated-consent changes; this read-only plan is exact.'
Write-Host "Approved tenant: $($plan.summary.tenantId)"
Write-Host 'Approved target scope: Microsoft Entra tenant plus the approved application object IDs.'
foreach ($record in @(
    @{ Label = 'Client application'; Data = $plan.summary.client },
    @{ Label = 'Middle-tier application'; Data = $plan.summary.middleTier },
    @{ Label = 'Downstream application'; Data = $plan.summary.downstream }
)) {
    Write-Host "$($record.Label): $($record.Data.displayName) ($($record.Data.objectId))"
    Write-Host "  Application ID: $($record.Data.applicationId)"
    Write-Host "  signInAudience: $($record.Data.signInAudience)"
    Write-Host "  Owners: $([string]::Join(', ', @($record.Data.owners)))"
    if ($record.Data.PSObject.Properties.Name -contains 'audience') {
        Write-Host "  API audience: $($record.Data.audience)"
        Write-Host "  Delegated scope: $($record.Data.delegatedScope)"
    }
}
Write-Host "Key Vault certificate thumbprint: $($plan.summary.certificate.thumbprint)"
Write-Host ([string]$plan.summary.certificate.runtimeCheckDetail)
Write-Host 'READ-ONLY PLAN'
$index = 1
foreach ($action in @($plan.actions)) {
    Write-Host ("{0}. {1}" -f $index, [string]$action.title)
    if ([bool]$action.changeRequired) {
        Write-Host "   $($action.method) $($action.url)"
        Write-Host '   Body:'
        $bodyJson = $action.body | ConvertTo-Json -Depth 100
        foreach ($line in ($bodyJson -split "`r?`n")) {
            Write-Host "   $line"
        }
    }
    else {
        Write-Host '   No change required.'
    }
    foreach ($note in @($action.notes)) {
        Write-Host "   Note: $note"
    }
    $index++
}
