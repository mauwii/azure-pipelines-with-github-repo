# Connect to Azure-CLI as Service Principal
az login `
  --service-principal `
  -u $env:ApplicationId `
  -p $env:ClientSecret `
  -t $env:SpTenantId

# Get Subscriptions
$AzSubscriptions = Get-AzSubscription

$currentUTCtime = (Get-Date).ToUniversalTime()

foreach ($AzSubscription in $AzSubscriptions) {
  Write-Host `
    -ForegroundColor Cyan `
    -NoNewline `
    "Subscription:"
  Write-Host $AzSubscription.Name `n

  Set-AzContext `
    -Subscription $AzSubscription.Id

  az account set --subscription $AzSubscription.Id

  $AzResourceGroups = Get-AzResourceGroup

  foreach ($AzResourceGroup in $AzResourceGroups) {
    $AzResources = Get-AzResource `
      -ResourceGroupName $AzResourceGroup.ResourceGroupName
    Write-Host `
      -ForegroundColor Cyan `
      -NoNewline `
      "Resource Group: "
    Write-Host $AzResourceGroup.ResourceGroupName

    foreach ($AzResource in $AzResources) {
      $AzCurrentResource = az resource list `
        --location $AzResource.Location `
        --name $AzResource.Name `
        --query "[].{Name:name, RG:resourceGroup, Created:createdTime, Changed:changedTime}" `
        -o json |
      ConvertFrom-Json
      $AzResourceAge = $currentUTCtime - $AzCurrentResource.Created
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
