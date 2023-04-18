$Location = "westeurope"
$ResourceGroup='rg-customlog'
$TemplateParameterFile = ".\oracleauditdb.parameters.json"
<# Example of passing a transform query as a parameter
$transformKql = @'
source| extend ddata = split(RawData, ' ')| extend Computer = tostring(ddata[1]), JournalType = tostring(split(ddata[2],':')[1]), Oracle_Unified_Audit = toint(replace(']:','',tostring(split(ddata[5],"[")[1]))), AuditType = toint(replace('"','',tostring(split(ddata[8],":")[1]))), Length = toint(replace('\'','',tostring(ddata[7]))), DBI = toint(replace('"','',tostring(split(ddata[9],":")[1]))), SesId = tolong(replace('"','',tostring(split(ddata[10],":")[1]))), ClientId = replace('"','',tostring(split(ddata[11],":")[1])), EntryId = toint(replace('"','',tostring(split(ddata[12],":")[1]))), STMTId = toint(replace('"','',tostring(split(ddata[13],":")[1]))), DbUser = replace('"','',tostring(split(ddata[14],":")[1])), CurUser = replace('"','',tostring(split(ddata[15],":")[1])), Action = toint(replace('"','',tostring(split(ddata[16],":")[1]))), RetCode = toint(replace('"','',tostring(split(ddata[17],":")[1]))), Schema = replace('"','',tostring(split(ddata[18],":")[1])), ObjName = replace('"','',tostring(split(ddata[19],":")[1])), PDB_GUID = toguid(replace('"','',tostring(split(ddata[20],":")[1])))| project-away ddata, RawData
'@
#>

$deploymentname = "customdcr$(get-date -UFormat %y%m%d%H%M)"

New-AzResourceGroup -Location $Location -Name $ResourceGroup -Force

$DeploymentSettings = @{
    Name = $deploymentname
    Mode = "Incremental"
    TemplateFile = ".\customtable.bicep"
    ResourceGroupName = $ResourceGroup
    TemplateParameterFile = $TemplateParameterFile
    Verbose = $true
}

New-AzResourceGroupDeployment @DeploymentSettings