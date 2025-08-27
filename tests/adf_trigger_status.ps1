
# Variables
$resourceGroupName = "adf_xberg"
$dataFactoryName = "adfxberg"
$triggerName = "trigger1"

# Get trigger status
$trigger = Get-AzDataFactoryV2Trigger `
  -ResourceGroupName $resourceGroupName `
  -DataFactoryName $dataFactoryName `
  -Name $triggerName

# Display status
$trigger.Properties.RuntimeState


# Variables
$resourceGroupName = "adf_xberg"
$dataFactoryName = "adfxbergtest"
$triggerName = "trigger1"

# Get trigger status
$trigger = Get-AzDataFactoryV2Trigger `
  -ResourceGroupName $resourceGroupName `
  -DataFactoryName $dataFactoryName `
  -Name $triggerName

# Display status
$trigger.Properties.RuntimeState
