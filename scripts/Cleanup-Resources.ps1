# az group delete --resource-group $env:RG --yes

if ( ${env:WhatIfPreference} -eq "true" ) {
  $WhatIfPreference = $true
}

Remove-AzResourceGroup `
  -Name ${env:RG} `
  -Force `
  -ErrorAction SilentlyContinue

$KeyVaultToDelete = Get-AzKeyVault -InRemovedState

foreach ($KV in $KeyVaultToDelete) {
  Remove-AzKeyVault `
    -VaultName $KV.VaultName `
    -Location $KV.Location `
    -InRemovedState -Force
}
