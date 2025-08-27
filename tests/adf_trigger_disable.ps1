# Variables
$resourceGroupName = "adf_xberg"
$dataFactoryName = "adfxberg"
$triggerName = "trigger1"

Stop-AzDataFactoryV2Trigger `
  -ResourceGroupName $resourceGroupName `
  -DataFactoryName $dataFactoryName `
  -Name $triggerName
  -Force

# Variables
$resourceGroupName = "adf_xberg"
$dataFactoryName = "adfxbergtest"
$triggerName = "trigger1"

Stop-AzDataFactoryV2Trigger `
  -ResourceGroupName $resourceGroupName `
  -DataFactoryName $dataFactoryName `
  -Name $triggerName
  -Force