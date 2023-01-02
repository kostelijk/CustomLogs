

@description('Log Analytics Workspace name')
param laName string = '<LAW Name>'

@description('Log Analytics Resource Group name')
param laResourceGroup string = '<RG-Containing LAW>'

@description('Log Analytics Workspace ID')
param workspaceId string = '<WorkspaceId>'

@description('Custom Table Name (without _CL)')
param customTableName string = '<CustomTableName>'

param location string = resourceGroup().location

var dceName = 'dceSample'
var dcrName = 'dcrSample'
var customTableName_CL = 'Custom-${customTableName}_CL'
var streamDeclarations = { 'Custom-${customTableName}_CL': {
  columns: [
    {
        name: 'TimeGenerated'
        type: 'datetime'
    }
    {
        name: 'RawData'
        type: 'string'
    }
    {
        name: 'Description'
        type: 'string'
    }
    {
        name: 'Error'
        type: 'int'
    }
    {
        name: 'Computer'
        type: 'string'
    }
]
}
}
var workspaceResourceId = resourceId(laResourceGroup,'Microsoft.OperationalInsights/workspaces',laName)


resource runningVMTable 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = {
  name: '${laName}/${customTableName}_CL'
  properties: {
    plan: 'Analytics'
    schema: {
      name: '${customTableName}_CL'
      columns: [
        {
          name: 'TimeGenerated'
          type: 'datetime'
        }
        {
          name: 'RawData'
          type: 'string'
        }
        {
          name: 'Description'
          type: 'string'
        }
        {
          name: 'Error'
          type: 'int'
        }
        {
          name: 'Computer'
          type: 'string'
        }
      ]
    }
  }
}


resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2021-09-01-preview' = {
  name: dceName
  location: location
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: dcrName
  location: location
  properties:{
    dataCollectionEndpointId: dataCollectionEndpoint.id
    streamDeclarations: streamDeclarations
    dataSources: {
      logFiles: [
        {
          streams: [
            customTableName_CL
          ]
          filePatterns: [
            'c:\\temp\\*.log'
          ]
          format: 'text'
          settings: {
            text: {
              recordStartTimestampFormat: 'ISO 8601'
            }
          }
          name: 'myLogFileFormat-Windows'
        }
        {
          streams: [
            customTableName_CL
          ]
          filePatterns: [
            '//var//*.log'
          ]
          format: 'text'
          settings: {
            text: {
              recordStartTimestampFormat: 'ISO 8601'
            }
          }
          name: 'myLogFileFormat-Linux'
        }
      ]
    }
    destinations:{
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: workspaceId
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          customTableName_CL
        ]
        destinations:[
          workspaceId
        ]
        transformKql: 'source|extend Data = substring(RawData, 22, strlen(RawData))| extend Dynamic = split(Data,":")| extend Computer = tostring(Dynamic[0]), Error = toint(Dynamic[1]), Description = tostring(Dynamic[2])|where Error > 5| project-away RawData, Data, Dynamic'
        outputStream: customTableName_CL
      }
    ]
  }
}
