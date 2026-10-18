targetScope = 'resourceGroup'

@description('Runtime base URL ending in /endpoint/protocols/openai. Do not commit it.')
param primaryAgentBaseUrl string

@description('Optional secondary runtime base URL. Required only when the approved environment enables it.')
param secondaryAgentBaseUrl string = ''

@description('Existing API Management instance name.')
param apiManagementName string

@description('Existing APIM Application Insights logger name.')
param applicationInsightsLoggerName string

@description('Existing APIM backend ID configured for Azure AI Content Safety.')
param contentSafetyBackendId string

@description('Whether to deploy a distinct secondary Foundry agent backend.')
param secondaryBackendEnabled bool = false

var implementationSession = '06-apim-ai-gateway'
var control = loadJsonContent('../governance/gateway-control.json')
var openApiDocument = loadTextContent('apis/policy-assistant-responses.openapi.json')
var rawPolicy = loadTextContent('policies/policy.xml')
var backendPoolId = '${control.api.id}-pool'
var primaryBackendId = '${control.api.id}-primary'
var secondaryBackendId = '${control.api.id}-secondary'
var openBrace = '{'
var closeBrace = '}'
var partiallyResolvedPolicy = replace(
  replace(
    replace(
      replace(
        replace(
          replace(
            replace(
              replace(
                replace(
                  replace(
                    replace(
                      rawPolicy,
                      '__NAMED_VALUE_ENTRA_TENANT_ID__',
                      '${openBrace}${openBrace}session06-entra-tenant-id${closeBrace}${closeBrace}'
                    ),
                    '__NAMED_VALUE_CLIENT_APPLICATION_ID__',
                    '${openBrace}${openBrace}session06-client-application-id${closeBrace}${closeBrace}'
                  ),
                  '__NAMED_VALUE_API_AUDIENCE__',
                  '${openBrace}${openBrace}session06-api-audience${closeBrace}${closeBrace}'
                ),
                '__NAMED_VALUE_REQUIRED_APP_ROLE__',
                '${openBrace}${openBrace}session06-required-app-role${closeBrace}${closeBrace}'
              ),
              '__REQUEST_MAX_BYTES__',
              string(control.limits.requestMaxBytes)
            ),
            '__TOKENS_PER_MINUTE__',
            string(control.limits.tokensPerMinute)
          ),
          '__TOKEN_QUOTA__',
          string(control.limits.tokenQuota)
        ),
        '__CONTENT_SAFETY_BACKEND_ID__',
        contentSafetyBackendId
      ),
      '__HARM_THRESHOLD__',
      string(control.safety.harmThreshold)
    ),
    '__BACKEND_POOL_ID__',
    backendPoolId
  ),
  '__RETRY_COUNT__',
  string(control.limits.retryCount)
)
var policy = replace(
  partiallyResolvedPolicy,
  '__BACKEND_TIMEOUT_SECONDS__',
  string(control.limits.backendTimeoutSeconds)
)
var backendServices = secondaryBackendEnabled
  ? [
      {
        id: primaryBackend.id
        priority: control.routing.primaryPriority
        weight: 100
      }
      {
        id: secondaryBackend.id
        priority: control.routing.secondaryPriority
        weight: 100
      }
    ]
  : [
      {
        id: primaryBackend.id
        priority: control.routing.primaryPriority
        weight: 100
      }
    ]

resource apim 'Microsoft.ApiManagement/service@2024-05-01' existing = {
  name: apiManagementName
}

resource applicationInsightsLogger 'Microsoft.ApiManagement/service/loggers@2024-05-01' existing = {
  parent: apim
  name: applicationInsightsLoggerName
}

resource tenantId 'Microsoft.ApiManagement/service/namedValues@2024-05-01' = {
  parent: apim
  name: 'session06-entra-tenant-id'
  properties: {
    displayName: 'session06-entra-tenant-id'
    secret: false
    tags: [
      implementationSession
    ]
    value: control.ingressIdentity.tenantId
  }
}

resource clientApplicationId 'Microsoft.ApiManagement/service/namedValues@2024-05-01' = {
  parent: apim
  name: 'session06-client-application-id'
  properties: {
    displayName: 'session06-client-application-id'
    secret: false
    tags: [
      implementationSession
    ]
    value: control.ingressIdentity.clientApplicationId
  }
}

resource apiAudience 'Microsoft.ApiManagement/service/namedValues@2024-05-01' = {
  parent: apim
  name: 'session06-api-audience'
  properties: {
    displayName: 'session06-api-audience'
    secret: false
    tags: [
      implementationSession
    ]
    value: control.ingressIdentity.audience
  }
}

resource requiredAppRole 'Microsoft.ApiManagement/service/namedValues@2024-05-01' = {
  parent: apim
  name: 'session06-required-app-role'
  properties: {
    displayName: 'session06-required-app-role'
    secret: false
    tags: [
      implementationSession
    ]
    value: control.ingressIdentity.requiredAppRole
  }
}

resource primaryBackend 'Microsoft.ApiManagement/service/backends@2024-05-01' = {
  parent: apim
  name: primaryBackendId
  properties: {
    type: 'Single'
    protocol: 'http'
    url: primaryAgentBaseUrl
    title: 'Session 06 primary Foundry agent backend'
    description: 'implementationSession=${implementationSession}; priority=${control.routing.primaryPriority}'
    circuitBreaker: {
      rules: [
        {
          name: 'agent-runtime-errors'
          acceptRetryAfter: true
          failureCondition: {
            count: control.routing.circuitBreakerErrorCount
            interval: control.routing.circuitBreakerInterval
            statusCodeRanges: [
              {
                min: 429
                max: 429
              }
              {
                min: 500
                max: 599
              }
            ]
          }
          tripDuration: control.routing.circuitBreakerTripDuration
        }
      ]
    }
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

resource secondaryBackend 'Microsoft.ApiManagement/service/backends@2024-05-01' = if (secondaryBackendEnabled) {
  parent: apim
  name: secondaryBackendId
  properties: {
    type: 'Single'
    protocol: 'http'
    url: secondaryAgentBaseUrl
    title: 'Session 06 secondary Foundry agent backend'
    description: 'implementationSession=${implementationSession}; priority=${control.routing.secondaryPriority}'
    circuitBreaker: {
      rules: [
        {
          name: 'agent-runtime-errors'
          acceptRetryAfter: true
          failureCondition: {
            count: control.routing.circuitBreakerErrorCount
            interval: control.routing.circuitBreakerInterval
            statusCodeRanges: [
              {
                min: 429
                max: 429
              }
              {
                min: 500
                max: 599
              }
            ]
          }
          tripDuration: control.routing.circuitBreakerTripDuration
        }
      ]
    }
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

resource backendPool 'Microsoft.ApiManagement/service/backends@2024-05-01' = {
  parent: apim
  name: backendPoolId
  properties: {
    type: 'Pool'
    title: 'Session 06 governed agent backend pool'
    description: 'implementationSession=${implementationSession}; primary-first routing'
    pool: {
      services: backendServices
    }
  }
}

resource api 'Microsoft.ApiManagement/service/apis@2024-05-01' = {
  parent: apim
  name: control.api.id
  properties: {
    apiType: 'http'
    type: 'http'
    displayName: control.api.displayName
    description: 'implementationSession=${implementationSession}; owner=${control.product.owner}'
    path: control.api.path
    protocols: [
      'https'
    ]
    subscriptionRequired: true
    format: 'openapi+json'
    value: openApiDocument
  }
}

resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2024-05-01' = {
  parent: api
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: policy
  }
}

resource product 'Microsoft.ApiManagement/service/products@2024-05-01' = {
  parent: apim
  name: control.product.id
  properties: {
    displayName: control.product.displayName
    description: 'implementationSession=${implementationSession}; owner=${control.product.owner}; Entra token and product subscription required'
    state: control.product.published ? 'published' : 'notPublished'
    subscriptionRequired: control.product.subscriptionRequired
  }
}

resource productApi 'Microsoft.ApiManagement/service/products/apis@2024-05-01' = {
  parent: product
  name: api.name
}

resource apiDiagnostic 'Microsoft.ApiManagement/service/apis/diagnostics@2024-05-01' = {
  parent: api
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    loggerId: applicationInsightsLogger.id
    metrics: true
    httpCorrelationProtocol: 'W3C'
    logClientIp: control.telemetry.clientIpLogged
    operationNameFormat: 'Name'
    sampling: {
      samplingType: 'fixed'
      percentage: control.telemetry.samplingPercentage
    }
    verbosity: 'information'
    frontend: {
      request: {
        body: {
          bytes: control.telemetry.requestBodyBytesLogged
        }
        headers: [
          control.telemetry.correlationHeader
        ]
      }
      response: {
        body: {
          bytes: control.telemetry.responseBodyBytesLogged
        }
        headers: [
          control.telemetry.correlationHeader
        ]
      }
    }
    backend: {
      request: {
        body: {
          bytes: control.telemetry.requestBodyBytesLogged
        }
        headers: [
          control.telemetry.correlationHeader
        ]
      }
      response: {
        body: {
          bytes: control.telemetry.responseBodyBytesLogged
        }
        headers: [
          control.telemetry.correlationHeader
        ]
      }
    }
  }
}

output apiId string = api.id
output gatewayPath string = 'https://${apiManagementName}.azure-api.net/${control.api.path}${control.api.operationPath}'
output productId string = product.id
output backendPoolResourceId string = backendPool.id
