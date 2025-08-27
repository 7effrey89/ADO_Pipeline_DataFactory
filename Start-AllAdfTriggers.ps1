#Example usage: pwsh -File .\Start-AllAdfTriggers.ps1 -ResourceGroupName adf_carlsberg -DataFactoryName adfcarlsbergtest

param(
    [Parameter(Mandatory = $true)] [string] $ResourceGroupName,
    [Parameter(Mandatory = $true)] [string] $DataFactoryName,
    [string[]] $Include = @(),
    [string[]] $Exclude = @()
)

# Logging helpers: unify all output via Write-Host so ADO shows it consistently
function Write-Info {
    param([Parameter(ValueFromRemainingArguments = $true)] [object[]] $Message)
    Write-Host ($Message -join ' ')
}
function Write-Warn {
    param([Parameter(ValueFromRemainingArguments = $true)] [object[]] $Message)
    Write-Host ("##[warning] " + ($Message -join ' '))
}
function Write-Err {
    param([Parameter(ValueFromRemainingArguments = $true)] [object[]] $Message)
    Write-Host ("##[error] " + ($Message -join ' '))
}

# Fetch triggers from the target factory
Write-Info "Fetching triggers from factory '$DataFactoryName' in resource group '$ResourceGroupName'..."
$triggers = Get-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName

if (-not $triggers) {
    Write-Warn "No triggers found."
    return
}

# Filter by Include/Exclude if provided
if ($Include.Count -gt 0) {
    $triggers = $triggers | Where-Object { $_.Name -in $Include }
}
if ($Exclude.Count -gt 0) {
    $triggers = $triggers | Where-Object { $_.Name -notin $Exclude }
}

# Skip already started
$toStart = $triggers | Where-Object { $_.RuntimeState -ne 'Started' }

if (-not $toStart -or $toStart.Count -eq 0) {
    Write-Info "All selected triggers are already Started."
    return
}

Write-Info ("Will start {0} trigger(s): {1}" -f $toStart.Count, ($toStart.Name -join ', '))

$ok = 0; $fail = 0
foreach ($t in $toStart) {
    try {
        $name = $t.Name
        $typeName = $t.Properties.GetType().Name

        if ($typeName -eq 'BlobEventsTrigger') {
            Write-Info "[$name] BlobEventsTrigger: subscribing to events..."
            $status = Add-AzDataFactoryV2TriggerSubscription -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $name
            while ($status.Status -ne 'Enabled') {
                Start-Sleep -Seconds 15
                $status = Get-AzDataFactoryV2TriggerSubscriptionStatus -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $name
                Write-Info "[$name] Waiting for event subscription to become Enabled (current: $($status.Status))..."
            }
        }

        Write-Info "[$name] Starting trigger..."
        Start-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $name -Force -Confirm:$false | Out-Null
        Write-Info "[$name] Started."
        $ok++
    }
    catch {
        $fail++
        Write-Err "[$($t.Name)] Failed to start. $_"
    }
}

Write-Info "Done. Started: $ok, Failed: $fail"
if ($fail -gt 0) { throw "One or more triggers failed to start." }