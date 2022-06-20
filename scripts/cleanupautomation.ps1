# Connect to Azure-CLI as Service Principal
az login `
  --service-principal `
  -u $env:ApplicationId `
  -p $env:ClientSecret `
  -t $env:SpTenantId

# Get Subscriptions
$AzSubscriptions = Get-AzSubscription

# Get Current UTC-Time
$CurrentUTCtime = (Get-Date).ToUniversalTime()

# Set Initial Date
$InitialDate = (Get-Date -Year 2022 -Month 06 -Day 15).ToUniversalTime()

# Days until Resources get deleted
$NewerResourceDays = 7
$OlderResourceDays = 14

# Iterate over subscriptions
foreach ($AzSubscription in $AzSubscriptions) {
  Write-Host `
    -ForegroundColor Cyan `
    -NoNewline `
    "Subscription:"
  Write-Host $AzSubscription.Name `n

  # Set Context to current Subscription
  Set-AzContext `
    -Subscription $AzSubscription.Id
  az account set `
    --subscription $AzSubscription.Id

  # Iterate over Resource Groups
  foreach ($AzResourceGroup in Get-AzResourceGroup) {
    Write-Host `
      -ForegroundColor Cyan `
      -NoNewline `
      "Resource Group: "
    Write-Host $AzResourceGroup.ResourceGroupName

    # Get Resources in current Resource Group
    $AzResources = Get-AzResource `
      -ResourceGroupName $AzResourceGroup.ResourceGroupName

    # Iterate over Resources in current Resource Group
    foreach ($AzResource in $AzResources) {
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
      # Add Deletion Date as Tag to Resources
      if ($DaysToDelete -gt 0) {
        Write-Host ($AzCurrentResource.Name, "will be deleted in", $DaysToDelete, "Days")
        $DeletionDate = $CurrentUTCtime.AddDays($DaysToDelete)
        $tags = $AzResource.Tags
        if ( $tags.Keys -contains "DeletionDate" ) {
          $tags.Remove("DeletionDate")
        }
        $tags += @{DeletionDate=$DeletionDate}
        Set-AzResource `
          -ResourceId $AzResource.Id `
          -Tag $tags `
          -Force:$true
      }
      else {
        Remove-AzResource `
          -ResourceId $AzResource.Id `
          -WhatIf:$true
      }
    }
    Write-Host `
      -ForegroundColor Cyan `
      -NoNewline `
      "Done with ResourceGroup "
    Write-Host $AzResourceGroup.ResourceGroupName `n
  }
  Write-Host `
    -ForegroundColor Cyan `
    -NoNewline `
    "Done with Subscription "
  Write-Host $AzSubscription.Name `n
}
