param(
  [Switch]$LocalTest
)
if ($LocalTest) {
  $LocalTest = $true
}
else {
  $LocalTest = $false
}

# Connect to Azure-CLI as Service Principal
[void](
  az login `
    --service-principal `
    -u $env:ApplicationId `
    -p $env:ClientSecret `
    -t $env:SpTenantId
)

# Get Current UTC-Time
$CurrentUTCtime = (Get-Date).ToUniversalTime()

# Set Initial Date
$InitialDate = (Get-Date -Year 2022 -Month 06 -Day 15).ToUniversalTime()

# Days until Resources get deleted
$NewerResourceDays = 7
$OlderResourceDays = 14

# Initialize Variable to count Resources
$AllAzResourceCount = 0
$DeletedResourceCount = 0

# Function to Print Information
function Write-Info {
  param (
    [System.String]$Title,
    [System.String]$Value,
    [Switch]$InitialNewLine,
    [Switch]$FinalNewLine
  )
  $Title = "${Title}: "
  $Value = "`t${Value}"
  if ($InitialNewLine) {
    $Title = "`n${Title}"
  }
  if ($FinalNewLine) {
    $Value = "${Value}`n"
  }
  Write-Host `
    -ForegroundColor Cyan `
    -NoNewline `
    $Title
  Write-Host $Value
}

# Iterate over subscriptions
foreach ($AzSubscription in Get-AzSubscription) {

  # Set Context to current Subscription
  [void](
    Set-AzContext `
      -Subscription $AzSubscription.Id
  )
  [void](az account set `
      --subscription $AzSubscription.Id
  )
  $AzResourceGroups = Get-AzResourceGroup
  # Get Number of Resources in current Context
  $AzResourceCount = (Get-AzResource).Length

  # Write Info to Host about current Subscription
  Write-Info `
    -InitialNewLine `
    -Title "Subscription Name" `
    -Value $AzSubscription.Name
  Write-Info `
    -Title "Resourcegroups" `
    -Value $AzResourceGroups.Length
  Write-Info `
    -Title "Resource Count" `
    -Value "$AzResourceCount" `
    -FinalNewLine

  # Add Number of Resources in Subscription to AllAzResourceCount
  $AllAzResourceCount += $AzResourceCount

  # Iterate over Resource Groups
  foreach ($AzResourceGroup in $AzResourceGroups) {

    # Get Resources in current Resource Group
    $AzRgResources = Get-AzResource `
      -ResourceGroupName $AzResourceGroup.ResourceGroupName

    # Write Info to Host about Current Resource Group
    Write-Info `
      -Title "Resource Group" `
      -Value $AzResourceGroup.ResourceGroupName
    Write-Info `
      -Title "Resource Count" `
      -Value $AzRgResources.Length

    # Iterate over Resources in current Resource Group
    foreach ($AzRgResource in $AzRgResources) {

      # Get Current Resource Creation Time
      $AzCurrentResource = (
        az resource list `
          --location $AzRgResource.Location `
          --name $AzRgResource.Name `
          --query "[].{Name:name, RG:resourceGroup, Created:createdTime, Changed:changedTime}" `
          -o json | ConvertFrom-Json
      )

      # Check if Resource was created before or after initial date to give devs more days to react on older resources
      if (($AzCurrentResource.Created).ToUniversalTime() -gt $InitialDate) {
        $AzResourceAge = $CurrentUTCtime - ($AzCurrentResource.Created).ToUniversalTime()
        $DaysToDelete = $NewerResourceDays - $AzResourceAge.Days
      }
      else {
        $AzResourceAge = $CurrentUTCtime - $InitialDate
        $DaysToDelete = $OlderResourceDays - $AzResourceAge.Days
      }

      # Add/update Tag "DeletionDate" of Resource, or Delete it if defined age has been reached
      if ($DaysToDelete -gt 0) {

        # Write Info to Host when Resource will be deleted
        Write-Host `
          -NoNewline `
          $AzCurrentResource.Name, "will be deleted in $DaysToDelete "
        if ($DaysToDelete -gt 1) {
          Write-Host "Days"
        }
        else {
          Write-Host "Day"
        }

        # Set DeletionDate
        $DeletionDate = $CurrentUTCtime.AddDays($DaysToDelete)

        # Create Tag
        $Tag = @{"DeletionDate" = "$DeletionDate UTC"; }
        [void](
          Update-AzTag `
            -ResourceId $AzRgResource.Id `
            -Tag $Tag `
            -Operation Merge `
            -WhatIf:$LocalTest
        )
      }
      else {

        # Get Resource Lock
        $AzResourceLock = Get-AzResourceLock `
          -ResourceName $AzRgResource.Name `
          -ResourceType $AzRgResource.Type `
          -ResourceGroupName $AzRgResource.ResourceGroupName

        # Remove Resource Lock if existing
        if ($AzResourceLock) {
          Remove-AzResourceLock `
            -LockId $AzResourceLock.LockId `
            -Force:$true `
            -WhatIf:$LocalTest
        }

        # Remove Resource
        Remove-AzResource `
          -ResourceId $AzRgResource.Id `
          -WhatIf:$LocalTest

        # Update Deleted Resource Count
        $DeletedResourceCount++
      }
    }

    # Write Info to Host that ResourceGroup is done
    Write-Info `
      -Title "Resourcegroup Done" `
      -Value $AzResourceGroup.ResourceGroupName `
      -FinalNewLine
  }

  # Write Info to Host that Subscription is done
  Write-Info `
    -Title "Subscription Done" `
    -Value $AzSubscription.Name `
    -FinalNewLine
}

# Write Info to Host of Resource-Counts
Write-Info `
  -Title "Resources deleted" `
  -Value "$DeletedResourceCount of $AllAzResourceCount"
