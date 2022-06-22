# Connect to Azure-CLI as Service Principal
az login `
  --service-principal `
  -u $env:ApplicationId `
  -p $env:ClientSecret `
  -t $env:SpTenantId

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

  # Get Number of Resources in current Context
  $AzResourceCount = (Get-AzResource).Length

  # Write Info to Host about current Subscription
  Write-Host `
    -ForegroundColor Cyan `
    -NoNewline `
    "Subscription: "
  Write-Host $AzSubscription.Name
  Write-Host `
    -ForegroundColor Cyan `
    -NoNewline `
    "Resource Count: "
  Write-Host $AzResourceCount

  # Add Number of Resources in Subscription to AllAzResourceCount
  $AllAzResourceCount += $AzResourceCount

  # Iterate over Resource Groups
  foreach ($AzResourceGroup in Get-AzResourceGroup) {
    Write-Host `
      -ForegroundColor Cyan `
      -NoNewline `
      "Resource Group: "
    Write-Host $AzResourceGroup.ResourceGroupName

    # Get Resources in current Resource Group
    $AzRgResources = Get-AzResource `
      -ResourceGroupName $AzResourceGroup.ResourceGroupName

    # Iterate over Resources in current Resource Group
    foreach ($AzResource in $AzRgResources) {

      # Get Current Resource Creation Time
      $AzCurrentResource = az resource list `
        --location $AzResource.Location `
        --name $AzResource.Name `
        --query "[].{Name:name, RG:resourceGroup, Created:createdTime, Changed:changedTime}" `
        -o json | ConvertFrom-Json

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
        Write-Host ($AzCurrentResource.Name, "will be deleted in", $DaysToDelete, "Days")
        # Set DeletionDate
        $DeletionDate = $CurrentUTCtime.AddDays($DaysToDelete)
        # Create Tags Object
        $tags = $AzResource.Tags
        # Remove Tag if it is already existing (could be outdated/manipulated)
        if ( $tags.Keys -contains "DeletionDate" ) {
          [void](
            $tags.Remove("DeletionDate")
          )
        }
        # Add DeletionDate Tag
        $tags += @{
          "DeletionDate" = "$DeletionDate UTC"
        }
        [void](
          Set-AzResource `
            -ResourceId $AzResource.Id `
            -Tag $tags `
            -Force:$true
        )
      }
      else {
        # Get Resource Lock
        $AzResourceLock = Get-AzResourceLock `
          -ResourceName $AzResource.Name `
          -ResourceType $AzResource.Type `
          -ResourceGroupName $AzResource.ResourceGroupName
        # Remove Resource Lock if existing
        if ($AzResourceLock) {
          Remove-AzResourceLock `
            -LockId $AzResourceLock.LockId `
            -Force:$true
        }
        # Remove Resource
        Remove-AzResource `
          -ResourceId $AzResource.Id `
          -WhatIf:$true
        # Update Deleted Resource Count
        $DeletedResourceCount ++
      }
    }

    # Write Info to Host that ResourceGroup is done
    Write-Host `
      -ForegroundColor Cyan `
      -NoNewline `
      "Done with ResourceGroup "
    Write-Host $AzResourceGroup.ResourceGroupName `n
  }

  # Write Info to Host that Subscription is done
  Write-Host `
    -ForegroundColor Cyan `
    -NoNewline `
    "Done with Subscription "
  Write-Host $AzSubscription.Name `n
}

# Write Info to Host of Resource-Counts
Write-Host (
  $DeletedResourceCount,
  "of",
  $AllAzResourceCount,
  "Resources where deleted"
)