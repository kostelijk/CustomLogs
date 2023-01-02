$Location = "westeurope"
$LAName='law-custom'
$LAResourceGroup='rg-customlog'
$CustomTableName='mycustomtable'
$deploymentname = get-date -UFormat %y%m%d%H%M

New-AzResourceGroup -Location $Location -Name $LAResourceGroup -Force
New-AzOperationalInsightsWorkspace -Location $Location -Name $LAName -ResourceGroupName $LAResourceGroup

New-AzResourceGroupDeployment -Name $deploymentname -Mode Incremental -ResourceGroupName $LAResourceGroup -TemplateFile .\customtable.bicep -laname $LaName -laresourcegroup $LAResourceGroup -workspaceid $WorkSpace.CustomerId -customtablename $CustomTableName -verbose