# Reference: {'a':{'myvar':'A'}, 'b':{'myvar':'B'}}
$bicepDeployFolders = Get-ChildItem -Path $env:bicepDir -Name

function New-BicepMatrix() {
  Write-Host -NoNewline "##vso[task.setVariable variable=legs;isOutput=true]"
  Write-Host -NoNewline '{'
  foreach ($folder in $bicepDeployFolders) {
    $i++
    Write-Host -NoNewLine `'$folder`'`:
    Write-Host -NoNewLine '{'
    Write-Host -NoNewLine `'bicepDir`'`:`'$env:bicepDir`'', '
    Write-Host -NoNewline `'bicepTemplateDir`'`:`'$folder`'', '
    Write-Host -NoNewline `'bicepParameter`'`:`'$env:bicepParameter`'', '
    Write-Host -NoNewline `'resourceGroupName`'`:`'$env:resourceGroupName`'', '
    Write-Host -NoNewline `'azureSubscription`'`:`'$env:azureSubscription`'', '
    Write-Host -NoNewline `'location`'`:`'$env:location`'
    Write-Host -NoNewline '}'
    if ($i -eq $bicepDeployFolders.Length) {
      Write-Host '}'
    }
    else {
      Write-Host -NoNewline ', '
    }
  }
}

New-BicepMatrix
