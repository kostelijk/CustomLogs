$Location = "westeurope"
$LAName='tjk-law-custom'
$LAResourceGroup='rg-lacustomlog'
#$WorkSpace = '579bdd0f-ad8c-4769-81d9-5e01002ce48d'
$CustomTableName='oaudit'
$deploymentname = get-date -UFormat %y%m%d%H%M

New-AzResourceGroup -Location $Location -Name $LAResourceGroup -Force
New-AzOperationalInsightsWorkspace -Location $Location -Name $LAName -ResourceGroupName $LAResourceGroup -OutVariable WorkSpace

New-AzResourceGroupDeployment -Name $deploymentname -Mode Incremental -ResourceGroupName $LAResourceGroup -TemplateFile .\customtable.bicep -laname $LaName -laresourcegroup $LAResourceGroup -workspaceid $WorkSpace.CustomerId -customtablename $CustomTableName -verbose

#New-AzResourceGroupDeployment -Name $deploymentname -Mode Incremental -ResourceGroupName $LAResourceGroup -TemplateFile .\customtable.bicep -laname $LaName -laresourcegroup $LAResourceGroup -workspaceid $WorkSpace -customtablename $CustomTableName -verbose