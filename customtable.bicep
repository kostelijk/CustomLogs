@description('Log Analytics Workspace name')
param laName string

@description('Log Analytics Resource Group name')
param laResourceGroup string

@description('Custom Table Name (without _CL)')
param customTableName string

@description('Resource deployment region')
param location string = resourceGroup().location

@description('KQL Ingestion transformation query')
//param transformKql string = 'source|extend Data = substring(RawData, 22, strlen(RawData))| extend Dynamic = split(Data,":")| extend Computer = tostring(Dynamic[0]), Error = toint(Dynamic[1]), Description = tostring(Dynamic[2])|where Error > 5| project-away RawData, Data, Dynamic'
//param transformKql string = 'source| extend ddata = split(RawData, \' \')| extend TimeGenerated = todatetime(ddata[0]), Computer = tostring(ddata[1]), JournalType = tostring(split(ddata[2],\':\')[1]), AuditType = toint(replace(\'"\',\'\',tostring(split(ddata[8],":")[1]))), Length = toint(replace(\'\\\'\',\'\',tostring(ddata[7]))), DBI = toint(replace(\'"\',\'\',tostring(split(ddata[9],":")[1]))), SesId = tolong(replace(\'"\',\'\',tostring(split(ddata[10],":")[1]))), ClientId = replace(\'"\',\'\',tostring(split(ddata[11],":")[1])), EntryId = toint(replace(\'"\',\'\',tostring(split(ddata[12],":")[1]))), STMTId = toint(replace(\'"\',\'\',tostring(split(ddata[13],":")[1]))), DbUser = replace(\'"\',\'\',tostring(split(ddata[14],":")[1])), CurUser = replace(\'"\',\'\',tostring(split(ddata[15],":")[1])), Action = toint(replace(\'"\',\'\',tostring(split(ddata[16],":")[1]))), RetCode = toint(replace(\'"\',\'\',tostring(split(ddata[17],":")[1]))), Schema = replace(\'"\',\'\',tostring(split(ddata[18],":")[1])), ObjName = replace(\'"\',\'\',tostring(split(ddata[19],":")[1])), PDB_GUID = toguid(replace(\'"\',\'\',tostring(split(ddata[20],":")[1])))| project-away ddata'
param transformKql string

@description('Data Collection Endpoint')
param dceName string

@description('Data Collection Rule')
param dcrName string

@description('Windows log file pattern')
param windowsLogFileFormat string

@description('Linux log file pattern')
param linuxLogFileFormat string

@description('Source Log record schema https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-structure#streamdeclarations')
param streamDeclarations object

@description('Destination Table Schema')
param tableschema array

var customTableName_CL = 'Custom-${customTableName}_CL'
var workspaceResourceId = resourceId(laResourceGroup,'Microsoft.OperationalInsights/workspaces',laName)

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: laName
  location: location
}

resource getAction 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: law
  name: 'get_action'
  properties: {
    etag: '*'
    category: 'Function'
    displayName: 'Get_Action'
    query: '//save as function\r\n// FunctionName Get_Action\r\n// parameter type: int\r\n// parameter name: Action \r\ncase(\r\nAction == 0, "UNKNOWN",\r\nAction == 1, "CREATE TABLE",\r\nAction == 2, "INSERT",\r\nAction == 3, "SELECT",\r\nAction == 4, "CREATE CLUSTER",\r\nAction == 5, "ALTER CLUSTER",\r\nAction == 6, "UPDATE",\r\nAction == 7, "DELETE",\r\nAction == 8, "DROP CLUSTER",\r\nAction == 9, "CREATE INDEX",\r\nAction == 10, "DROP INDEX",\r\nAction == 11, "ALTER INDEX",\r\nAction == 12, "DROP TABLE",\r\nAction == 13, "CREATE SEQUENCE",\r\nAction == 14, "ALTER SEQUENCE",\r\nAction == 15, "ALTER TABLE",\r\nAction == 16, "DROP SEQUENCE",\r\nAction == 17, "GRANT OBJECT",\r\nAction == 18, "REVOKE OBJECT",\r\nAction == 19, "CREATE SYNONYM",\r\nAction == 20, "DROP SYNONYM",\r\nAction == 21, "CREATE VIEW",\r\nAction == 22, "DROP VIEW",\r\nAction == 23, "VALIDATE INDEX",\r\nAction == 24, "CREATE PROCEDURE",\r\nAction == 25, "ALTER PROCEDURE",\r\nAction == 26, "LOCK",\r\nAction == 27, "NO-OP",\r\nAction == 28, "RENAME",\r\nAction == 29, "COMMENT",\r\nAction == 30, "AUDIT OBJECT",\r\nAction == 31, "NOAUDIT OBJECT",\r\nAction == 32, "CREATE DATABASE LINK",\r\nAction == 33, "DROP DATABASE LINK",\r\nAction == 34, "CREATE DATABASE",\r\nAction == 35, "ALTER DATABASE",\r\nAction == 36, "CREATE ROLLBACK SEG",\r\nAction == 37, "ALTER ROLLBACK SEG",\r\nAction == 38, "DROP ROLLBACK SEG",\r\nAction == 39, "CREATE TABLESPACE",\r\nAction == 40, "ALTER TABLESPACE",\r\nAction == 41, "DROP TABLESPACE",\r\nAction == 42, "ALTER SESSION",\r\nAction == 43, "ALTER USER",\r\nAction == 44, "COMMIT",\r\nAction == 45, "ROLLBACK",\r\nAction == 46, "SAVEPOINT",\r\nAction == 47, "PL/SQL EXECUTE",\r\nAction == 48, "SET TRANSACTION",\r\nAction == 49, "ALTER SYSTEM",\r\nAction == 50, "EXPLAIN",\r\nAction == 51, "CREATE USER",\r\nAction == 52, "CREATE ROLE",\r\nAction == 53, "DROP USER",\r\nAction == 54, "DROP ROLE",\r\nAction == 55, "SET ROLE",\r\nAction == 56, "CREATE SCHEMA",\r\nAction == 57, "CREATE CONTROL FILE",\r\nAction == 58, "ALTER TRACING",\r\nAction == 59, "CREATE TRIGGER",\r\nAction == 60, "ALTER TRIGGER",\r\nAction == 61, "DROP TRIGGER",\r\nAction == 62, "ANALYZE TABLE",\r\nAction == 63, "ANALYZE INDEX",\r\nAction == 64, "ANALYZE CLUSTER",\r\nAction == 65, "CREATE PROFILE",\r\nAction == 66, "DROP PROFILE",\r\nAction == 67, "ALTER PROFILE",\r\nAction == 68, "DROP PROCEDURE",\r\nAction == 70, "ALTER RESOURCE COST",\r\nAction == 71, "CREATE MATERIALIZED VIEW LOG",\r\nAction == 72, "ALTER MATERIALIZED VIEW LOG",\r\nAction == 73, "DROP MATERIALIZED VIEW LOG",\r\nAction == 74, "CREATE MATERIALIZED VIEW",\r\nAction == 75, "ALTER MATERIALIZED VIEW",\r\nAction == 76, "DROP MATERIALIZED VIEW",\r\nAction == 77, "CREATE TYPE",\r\nAction == 78, "DROP TYPE",\r\nAction == 79, "ALTER ROLE",\r\nAction == 80, "ALTER TYPE",\r\nAction == 81, "CREATE TYPE BODY",\r\nAction == 82, "ALTER TYPE BODY",\r\nAction == 83, "DROP TYPE BODY",\r\nAction == 84, "DROP LIBRARY",\r\nAction == 85, "TRUNCATE TABLE",\r\nAction == 86, "TRUNCATE CLUSTER",\r\nAction == 88, "ALTER VIEW",\r\nAction == 90, "SET CONSTRAINTS",\r\nAction == 91, "CREATE FUNCTION",\r\nAction == 92, "ALTER FUNCTION",\r\nAction == 93, "DROP FUNCTION",\r\nAction == 94, "CREATE PACKAGE",\r\nAction == 95, "ALTER PACKAGE",\r\nAction == 96, "DROP PACKAGE",\r\nAction == 97, "CREATE PACKAGE BODY",\r\nAction == 98, "ALTER PACKAGE BODY",\r\nAction == 99, "DROP PACKAGE BODY",\r\nAction == 100, "LOGON",\r\nAction == 101, "LOGOFF",\r\nAction == 102, "LOGOFF BY CLEANUP",\r\nAction == 103, "SESSION REC",\r\nAction == 104, "SYSTEM AUDIT",\r\nAction == 105, "SYSTEM NOAUDIT",\r\nAction == 106, "AUDIT DEFAULT",\r\nAction == 107, "NOAUDIT DEFAULT",\r\nAction == 108, "SYSTEM GRANT",\r\nAction == 109, "SYSTEM REVOKE",\r\nAction == 110, "CREATE PUBLIC SYNONYM",\r\nAction == 111, "DROP PUBLIC SYNONYM",\r\nAction == 112, "CREATE PUBLIC DATABASE LINK",\r\nAction == 113, "DROP PUBLIC DATABASE LINK",\r\nAction == 114, "GRANT ROLE",\r\nAction == 115, "REVOKE ROLE",\r\nAction == 116, "EXECUTE PROCEDURE",\r\nAction == 117, "USER COMMENT",\r\nAction == 118, "ENABLE TRIGGER",\r\nAction == 119, "DISABLE TRIGGER",\r\nAction == 120, "ENABLE ALL TRIGGERS",\r\nAction == 121, "DISABLE ALL TRIGGERS",\r\nAction == 122, "NETWORK ERROR",\r\nAction == 123, "EXECUTE TYPE",\r\nAction == 125, "READ DIRECTORY",\r\nAction == 126, "WRITE DIRECTORY",\r\nAction == 128, "FLASHBACK",\r\nAction == 129, "BECOME USER",\r\nAction == 130, "ALTER MINING MODEL",\r\nAction == 131, "SELECT MINING MODEL",\r\nAction == 133, "CREATE MINING MODEL",\r\nAction == 134, "ALTER PUBLIC SYNONYM",\r\nAction == 135, "EXECUTE DIRECTORY",\r\nAction == 136, "SQL*LOADER DIRECT PATH LOAD",\r\nAction == 137, "DATAPUMP DIRECT PATH UNLOAD",\r\nAction == 138, "DATABASE STARTUP",\r\nAction == 139, "DATABASE SHUTDOWN",\r\nAction == 140, "CREATE SQL TXLN PROFILE",\r\nAction == 141, "ALTER SQL TXLN PROFILE",\r\nAction == 142, "USE SQL TXLN PROFILE",\r\nAction == 143, "DROP SQL TXLN PROFILE",\r\nAction == 144, "CREATE MEASURE FOLDER",\r\nAction == 145, "ALTER MEASURE FOLDER",\r\nAction == 146, "DROP MEASURE FOLDER",\r\nAction == 147, "CREATE CUBE BUILD PROCESS",\r\nAction == 148, "ALTER CUBE BUILD PROCESS",\r\nAction == 149, "DROP CUBE BUILD PROCESS",\r\nAction == 150, "CREATE CUBE",\r\nAction == 151, "ALTER CUBE",\r\nAction == 152, "DROP CUBE",\r\nAction == 153, "CREATE CUBE DIMENSION",\r\nAction == 154, "ALTER CUBE DIMENSION",\r\nAction == 155, "DROP CUBE DIMENSION",\r\nAction == 157, "CREATE DIRECTORY",\r\nAction == 158, "DROP DIRECTORY",\r\nAction == 159, "CREATE LIBRARY",\r\nAction == 160, "CREATE JAVA",\r\nAction == 161, "ALTER JAVA",\r\nAction == 162, "DROP JAVA",\r\nAction == 163, "CREATE OPERATOR",\r\nAction == 164, "CREATE INDEXTYPE",\r\nAction == 165, "DROP INDEXTYPE",\r\nAction == 166, "ALTER INDEXTYPE",\r\nAction == 167, "DROP OPERATOR",\r\nAction == 168, "ASSOCIATE STATISTICS",\r\nAction == 169, "DISASSOCIATE STATISTICS",\r\nAction == 170, "CALL METHOD",\r\nAction == 171, "CREATE SUMMARY",\r\nAction == 172, "ALTER SUMMARY",\r\nAction == 173, "DROP SUMMARY",\r\nAction == 174, "CREATE DIMENSION",\r\nAction == 175, "ALTER DIMENSION",\r\nAction == 176, "DROP DIMENSION",\r\nAction == 177, "CREATE CONTEXT",\r\nAction == 178, "DROP CONTEXT",\r\nAction == 179, "ALTER OUTLINE",\r\nAction == 180, "CREATE OUTLINE",\r\nAction == 181, "DROP OUTLINE",\r\nAction == 182, "UPDATE INDEXES",\r\nAction == 183, "ALTER OPERATOR",\r\nAction == 187, "CREATE SPFILE",\r\nAction == 188, "CREATE PFILE",\r\nAction == 189, "MERGE",\r\nAction == 190, "PASSWORD CHANGE",\r\nAction == 192, "ALTER SYNONYM",\r\nAction == 193, "ALTER DISKGROUP",\r\nAction == 194, "CREATE DISKGROUP",\r\nAction == 195, "DROP DISKGROUP",\r\nAction == 197, "PURGE RECYCLEBIN",\r\nAction == 198, "PURGE DBA_RECYCLEBIN",\r\nAction == 199, "PURGE TABLESPACE",\r\nAction == 200, "PURGE TABLE",\r\nAction == 201, "PURGE INDEX",\r\nAction == 202, "UNDROP OBJECT",\r\nAction == 203, "DROP DATABASE",\r\nAction == 204, "FLASHBACK DATABASE",\r\nAction == 205, "FLASHBACK TABLE",\r\nAction == 206, "CREATE RESTORE POINT",\r\nAction == 207, "DROP RESTORE POINT",\r\nAction == 208, "PROXY AUTHENTICATION ONLY",\r\nAction == 209, "DECLARE REWRITE EQUIVALENCE",\r\nAction == 210, "ALTER REWRITE EQUIVALENCE",\r\nAction == 211, "DROP REWRITE EQUIVALENCE",\r\nAction == 212, "CREATE EDITION",\r\nAction == 213, "ALTER EDITION",\r\nAction == 214, "DROP EDITION",\r\nAction == 215, "DROP ASSEMBLY",\r\nAction == 216, "CREATE ASSEMBLY",\r\nAction == 217, "ALTER ASSEMBLY",\r\nAction == 218, "CREATE FLASHBACK ARCHIVE",\r\nAction == 219, "ALTER FLASHBACK ARCHIVE",\r\nAction == 220, "DROP FLASHBACK ARCHIVE",\r\nAction == 221, "DEBUG CONNECT",\r\nAction == 223, "DEBUG PROCEDURE",\r\nAction == 225, "ALTER DATABASE LINK",\r\nAction == 226, "CREATE PLUGGABLE DATABASE",\r\nAction == 227, "ALTER PLUGGABLE DATABASE",\r\nAction == 228, "DROP PLUGGABLE DATABASE",\r\nAction == 229, "CREATE AUDIT POLICY",\r\nAction == 230, "ALTER AUDIT POLICY",\r\nAction == 231, "DROP AUDIT POLICY",\r\nAction == 232, "CODE-BASED GRANT",\r\nAction == 233, "CODE-BASED REVOKE",\r\nAction == 234, "CREATE LOCKDOWN PROFILE",\r\nAction == 235, "DROP LOCKDOWN PROFILE",\r\nAction == 236, "ALTER LOCKDOWN PROFILE",\r\nAction == 237, "TRANSLATE SQL",\r\nAction == 238, "ADMINISTER KEY MANAGEMENT",\r\nAction == 239, "CREATE MATERIALIZED ZONEMAP",\r\nAction == 240, "ALTER MATERIALIZED ZONEMAP",\r\nAction == 241, "DROP MATERIALIZED ZONEMAP",\r\nAction == 242, "DROP MINING MODEL",\r\nAction == 243, "CREATE ATTRIBUTE DIMENSION",\r\nAction == 244, "ALTER ATTRIBUTE DIMENSION",\r\nAction == 245, "DROP ATTRIBUTE DIMENSION",\r\nAction == 246, "CREATE HIERARCHY",\r\nAction == 247, "ALTER HIERARCHY",\r\nAction == 248, "DROP HIERARCHY",\r\nAction == 249, "CREATE ANALYTIC VIEW",\r\nAction == 250, "ALTER ANALYTIC VIEW",\r\nAction == 251, "DROP ANALYTIC VIEW",\r\nAction == 305, "ALTER PUBLIC DATABASE LINK",\r\n"UNKNOWN ACTION")'
    functionAlias: 'Get_Action'
    functionParameters: 'Action:int = 0'
  }
}

resource customTable 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = {
  parent: law
  name: '${customTableName}_CL'
  properties: {
    plan: 'Analytics'
    schema: {
      name: '${customTableName}_CL'
      columns: tableschema
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
    streamDeclarations: { 'Custom-${customTableName}_CL': streamDeclarations}
    dataSources: {
      logFiles: [
        {
          streams: [
            customTableName_CL
          ]
          filePatterns: [
            windowsLogFileFormat
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
            linuxLogFileFormat
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
          name: law.properties.customerId
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          customTableName_CL
        ]
        destinations:[
          law.properties.customerId
        ]
        transformKql: transformKql
        outputStream: customTableName_CL
      }
    ]
  }
}
