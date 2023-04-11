

@description('Log Analytics Workspace name')
param laName string = '<LAW Name>'

@description('Log Analytics Resource Group name')
param laResourceGroup string = '<RG-Containing LAW>'

@description('Log Analytics Workspace ID')
param workspaceId string = '<WorkspaceId>'

@description('Custom Table Name (without _CL)')
param customTableName string = '<CustomTableName>'

param location string = resourceGroup().location

@description('KQL Ingestion transformation query')
//param transformKql string = 'source|extend Data = substring(RawData, 22, strlen(RawData))| extend Dynamic = split(Data,":")| extend Computer = tostring(Dynamic[0]), Error = toint(Dynamic[1]), Description = tostring(Dynamic[2])|where Error > 5| project-away RawData, Data, Dynamic'
//param transformKql string = 'source| extend ddata = split(RawData, \' \')| extend TimeGenerated = todatetime(ddata[0]), Computer = tostring(ddata[1]), JournalType = tostring(split(ddata[2],\':\')[1]), AuditType = toint(replace(\'"\',\'\',tostring(split(ddata[8],":")[1]))), Length = toint(replace(\'\\\'\',\'\',tostring(ddata[7]))), DBI = toint(replace(\'"\',\'\',tostring(split(ddata[9],":")[1]))), SesId = tolong(replace(\'"\',\'\',tostring(split(ddata[10],":")[1]))), ClientId = replace(\'"\',\'\',tostring(split(ddata[11],":")[1])), EntryId = toint(replace(\'"\',\'\',tostring(split(ddata[12],":")[1]))), STMTId = toint(replace(\'"\',\'\',tostring(split(ddata[13],":")[1]))), DbUser = replace(\'"\',\'\',tostring(split(ddata[14],":")[1])), CurUser = replace(\'"\',\'\',tostring(split(ddata[15],":")[1])), Action = toint(replace(\'"\',\'\',tostring(split(ddata[16],":")[1]))), RetCode = toint(replace(\'"\',\'\',tostring(split(ddata[17],":")[1]))), Schema = replace(\'"\',\'\',tostring(split(ddata[18],":")[1])), ObjName = replace(\'"\',\'\',tostring(split(ddata[19],":")[1])), PDB_GUID = toguid(replace(\'"\',\'\',tostring(split(ddata[20],":")[1])))| project-away ddata'
param transformKql string = 'source| extend ddata = split(RawData, \' \')| extend Computer = tostring(ddata[1]), JournalType = tostring(split(ddata[2],\':\')[1]), Oracle_Unified_Audit = toint(replace(\']:\',\'\',tostring(split(ddata[5],"[")[1]))), AuditType = toint(replace(\'"\',\'\',tostring(split(ddata[8],":")[1]))), Length = toint(replace(\'\\\'\',\'\',tostring(ddata[7]))), DBI = toint(replace(\'"\',\'\',tostring(split(ddata[9],":")[1]))), SesId = tolong(replace(\'"\',\'\',tostring(split(ddata[10],":")[1]))), ClientId = replace(\'"\',\'\',tostring(split(ddata[11],":")[1])), EntryId = toint(replace(\'"\',\'\',tostring(split(ddata[12],":")[1]))), STMTId = toint(replace(\'"\',\'\',tostring(split(ddata[13],":")[1]))), DbUser = replace(\'"\',\'\',tostring(split(ddata[14],":")[1])), CurUser = replace(\'"\',\'\',tostring(split(ddata[15],":")[1])), Action = toint(replace(\'"\',\'\',tostring(split(ddata[16],":")[1]))), RetCode = toint(replace(\'"\',\'\',tostring(split(ddata[17],":")[1]))), Schema = replace(\'"\',\'\',tostring(split(ddata[18],":")[1])), ObjName = replace(\'"\',\'\',tostring(split(ddata[19],":")[1])), PDB_GUID = toguid(replace(\'"\',\'\',tostring(split(ddata[20],":")[1])))| project-away ddata, RawData'

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
          name: 'Computer'
          type: 'string'
        }
        {
          name: 'JournalType'
          type: 'string'
        }
        {
          name: 'Oracle_Unified_Audit'
          type: 'int'
        }
        {
          name: 'AuditType'
          type: 'int'
        }
        {
          name: 'Length'
          type: 'int'
        }
        {
          name: 'DBI'
          type: 'int'
        }
        {
          name: 'SesId'
          type: 'long'
        }
        {
          name: 'EntryId'
          type: 'int'
        }
        {
          name: 'STMTId'
          type: 'int'
        }
        {
          name: 'DbUser'
          type: 'string'
        }
        {
          name: 'CurUser'
          type: 'string'
        }
        {
          name: 'Action'
          type: 'int'
        }
        {
          name: 'RetCode'
          type: 'int'
        }
        {
          name: 'PDB_GUID'
          type: 'guid'
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
            'c:\\temp\\dbaudit*.log'
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
            '//var//dbaudit*.log'
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
        transformKql: transformKql
        outputStream: customTableName_CL
      }
    ]
  }
}
