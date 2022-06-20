# Connect to Azure-CLI as Service Principal
az login `
  --service-principal `
  -u $env:ApplicationId `
  -p $env:ClientSecret `
  -t $env:SpTenantId

# Get Subscriptions
$AzSubscriptions = Get-AzSubscription

# Get Current UTC-Time
$currentUTCtime = (Get-Date).ToUniversalTime()

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

  # Get Resource Groups in current Subscription
  $AzResourceGroups = Get-AzResourceGroup

  # Iterate over Resource Groups
  foreach ($AzResourceGroup in $AzResourceGroups) {
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
      # Get Current Resource Age
      $AzCurrentResource = az resource list `
        --location $AzResource.Location `
        --name $AzResource.Name `
        --query "[].{Name:name, RG:resourceGroup, Created:createdTime, Changed:changedTime}" `
        -o json | ConvertFrom-Json
      $AzResourceAge = $currentUTCtime - ($AzCurrentResource.Created).ToUniversalTime()
      Write-Host ($AzCurrentResource.Name, "current Age is", $AzResourceAge.Days, "Days")
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
