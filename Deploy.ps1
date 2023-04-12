$Location = "westeurope"
$LAName='lawcustom'
$LAResourceGroup='rg-customlog'
#$WorkSpace = '579bdd0f-ad8c-4769-81d9-5e01002ce48d'
$CustomTableName='oracleaudit'
$DCEName = 'dceSample'
$DCRName = 'dcrSample'
$WindowsLogFileFormat = 'c:\temp\dbaudit*.log'
$LinuxLogFileFormat =  '/var/dbaudit*.log'
$transformKql = @'
source| extend ddata = split(RawData, ' ')| extend Computer = tostring(ddata[1]), JournalType = tostring(split(ddata[2],':')[1]), Oracle_Unified_Audit = toint(replace(']:','',tostring(split(ddata[5],"[")[1]))), AuditType = toint(replace('"','',tostring(split(ddata[8],":")[1]))), Length = toint(replace('\'','',tostring(ddata[7]))), DBI = toint(replace('"','',tostring(split(ddata[9],":")[1]))), SesId = tolong(replace('"','',tostring(split(ddata[10],":")[1]))), ClientId = replace('"','',tostring(split(ddata[11],":")[1])), EntryId = toint(replace('"','',tostring(split(ddata[12],":")[1]))), STMTId = toint(replace('"','',tostring(split(ddata[13],":")[1]))), DbUser = replace('"','',tostring(split(ddata[14],":")[1])), CurUser = replace('"','',tostring(split(ddata[15],":")[1])), Action = toint(replace('"','',tostring(split(ddata[16],":")[1]))), RetCode = toint(replace('"','',tostring(split(ddata[17],":")[1]))), Schema = replace('"','',tostring(split(ddata[18],":")[1])), ObjName = replace('"','',tostring(split(ddata[19],":")[1])), PDB_GUID = toguid(replace('"','',tostring(split(ddata[20],":")[1])))| project-away ddata, RawData
'@

$deploymentname = get-date -UFormat %y%m%d%H%M

New-AzResourceGroup -Location $Location -Name $LAResourceGroup -Force

#New-AzOperationalInsightsWorkspace -Location $Location -Name $LAName -ResourceGroupName $LAResourceGroup -OutVariable WorkSpace
Get-AzOperationalInsightsWorkspace -Name $LAName -ResourceGroupName $LAResourceGroup -OutVariable WorkSpace

$DeploymentSettings = @{
    laName = $LAName
    laResourceGroup = $LAResourceGroup
    workspaceId = $Workspace.CustomerId
    customTableName = $CustomTableName
    Location = $Location
    transformKql = $transformKql
    dceName = $DCEName
    dcrName = $DCRName
    windowsLogFileFormat = $WindowsLogFileFormat
    linuxLogFileFormat = $LinuxLogFileFormat
    Name = $deploymentname
    Mode = "Incremental"
    ResourceGroupName = $LAResourceGroup
    TemplateFile = ".\customtable.bicep"
    Verbose = $true
}

#New-AzResourceGroupDeployment -Name $deploymentname -Mode Incremental -ResourceGroupName $LAResourceGroup -TemplateFile .\customtable.bicep -laname $LaName -laresourcegroup $LAResourceGroup -workspaceid $WorkSpace.CustomerId -customtablename $CustomTableName -verbose
New-AzResourceGroupDeployment @DeploymentSettings

#New-AzResourceGroupDeployment -Name $deploymentname -Mode Incremental -ResourceGroupName $LAResourceGroup -TemplateFile .\customtable.bicep -laname $LaName -laresourcegroup $LAResourceGroup -workspaceid $WorkSpace -customtablename $CustomTableName -verbose