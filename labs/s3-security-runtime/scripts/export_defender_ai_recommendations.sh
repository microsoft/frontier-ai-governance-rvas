#!/usr/bin/env bash
set -euo pipefail

OUT_FILE="${1:-./evidence/defender-ai-recommendations.json}"
QUERY="securityresources
| where type =~ 'microsoft.security/assessments'
| where tostring(properties.displayName) has 'AI'
    or tostring(properties.metadata.displayName) has 'AI'
    or tostring(properties.description) has 'AI'
| project id, name, subscriptionId, resourceGroup, status=tostring(properties.status.code), displayName=tostring(coalesce(properties.displayName, properties.metadata.displayName)), severity=tostring(properties.metadata.severity), resourceDetails=properties.resourceDetails"

mkdir -p "$(dirname "$OUT_FILE")"
az graph query --first 1000 --query "$QUERY" --output json > "$OUT_FILE"
echo "Defender AI recommendation export written to $OUT_FILE"
