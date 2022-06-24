# Create Credential
$User = $env:ApplicationId
$PWord = ConvertTo-SecureString -String $env:ClientSecret -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

# Connect to Azure Powershell as Service Principal
Connect-AzAccount `
  -ServicePrincipal `
  -Credential $Credential `
  -TenantId $env:SpTenantId
