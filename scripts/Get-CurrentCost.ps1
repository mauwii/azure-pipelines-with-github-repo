param([System.Int16]$Days)
if (-not($Days)) {
  $Days = 7
}
foreach ($AzSubscription in Get-AzSubscription) {
  [void](
    Set-AzContext `
      -Subscription $AzSubscription.Id `
      -Tenant $AzSubscription.TenantId
  )
  $startDate = (Get-Date).AddDays(-$Days)
  $endDate = Get-Date
  try {
    $currentCost = Get-AzConsumptionUsageDetail `
      -StartDate $startDate `
      -EndDate $endDate | `
      Measure-Object -Property PretaxCost -Sum
  }
  catch [System.Net.WebException] {
    "Cannot get Cost for ($AzSubscription.Name)"
  }
  if ($currentCost) {
    Write-Host "Cost of $($AzSubscription.Name) for last $Days Days: $($currentCost.Sum)"
  }
}
