param (
  [System.String]$Organization,
  [System.String]$Project,
  [System.Int16]$DefinitionId,
  [System.String]$Stage,
  [System.Int16]$top
)

if (-not($Organization)) {
  Write-Host -ForegroundColor Yellow "Please define a DevOps Organization with -Organization"
  $exit = 1
}

if (-not($Project)) {
  Write-Host -ForegroundColor Yellow "Please define a DevOps Project with -Project"
  $exit = 1
}

if (-not($DefinitionId)) {
  Write-Host -ForegroundColor Yellow "Please define a Release DefinitionId with -DefinitionId"
  $exit = 1
}

if (-not($DefinitionId)) {
  Write-Host -ForegroundColor Yellow "Please define a Stage with -Stage"
  $exit = 1
}

if ($exit -eq 1) {
  exit
}

if (-not($top)) {
  Write-Host "Will check last 10 Releases since -top was not set"
  $top = 10
}

$success = 0
$canceled = 0
$rejected = 0

# get last $top releases
$releases = az pipelines release list `
  --organization $Organization `
  --project $Project `
  --definition-id $DefinitionId `
  --top $top `
  --output json | ConvertFrom-Json

# iterate over releases
foreach ($r in $releases) {
  # get detailed release information
  $release = az pipelines release show `
    --organization $Organization `
    --project $Project `
    --id $r.id `
    --output json | ConvertFrom-Json
  foreach ($environment in $release.environments) {
    if ($environment.name -eq $Stage) {
      if ($environment.status -eq "succeeded") {
        Write-Host `
          -NoNewline `
          "Release $($release.id) succeeded`t"
        $success++
      }
      elseif ($environment.status -eq "canceled") {
        Write-Host `
          -NoNewline `
          "Release $($release.id) was canceled"
        $canceled++
      }
      else {
        Write-Host `
          -NoNewline `
          "Release $($release.id) was rejected"
        $rejected++
      }
      Write-Host ("`t", $release.description)
    }
  }
}

Write-Host "`nRejected:`t${rejected}`nCanceled:`t${canceled}`nSuccess:`t${success}"
