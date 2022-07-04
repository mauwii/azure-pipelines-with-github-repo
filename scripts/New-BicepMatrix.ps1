# Gef Folders to deploy
$bicepDeployFolders = (
  Get-ChildItem `
    -Path $env:bicepDir `
    -Name
)

# Function to create the Matrix
function New-BicepMatrix() {
  # Begin to output the matrix json as variable
  Write-Host -NoNewline "##vso[task.setVariable variable=legs;isOutput=true]{"
  foreach ($folder in $bicepDeployFolders) {
    $i++

    # if folder containes rg.json file, get ResourceGroupName from there, otherwise use environment
    if (Test-Path -Path "${env:bicepDir}/${folder}/rg.json") {
      $ResourceGroupName = (
        Get-Content `
          -LiteralPath "${env:bicepDir}/${folder}/rg.json" |
        ConvertFrom-Json
      ).ResourceGroupName
    }
    else {
      $ResourceGroupName = $env:resourceGroupName
    }

    Write-Host -NoNewLine "`'$folder`':"
    Write-Host -NoNewLine "{"
    Write-Host -NoNewLine "`'bicepDir`':`'$env:bicepDir`',"
    Write-Host -NoNewline "`'bicepTemplateDir`':`'$folder`',"
    Write-Host -NoNewline "`'bicepParameter`':`'$env:bicepParameter`',"
    Write-Host -NoNewline "`'resourceGroupName`':`'$ResourceGroupName`',"
    Write-Host -NoNewline "`'azureSubscription`':`'$env:azureSubscription`',"
    Write-Host -NoNewline "`'location`':`'$env:location`'"
    Write-Host -NoNewline "}"

    # If last folder has been reached end output of matrix json variable, continue otherwise
    if ($i -eq $bicepDeployFolders.Length) {
      Write-Host "}"
    }
    else {
      Write-Host -NoNewline ","
    }
  }
}

# Function-Call
New-BicepMatrix
