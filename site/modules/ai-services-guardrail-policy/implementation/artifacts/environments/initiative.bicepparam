using '../policy/initiative.bicep'

var decisions = loadJsonContent('../policy/guardrail-decisions.json')

param initiativeName = decisions.initiativeName
