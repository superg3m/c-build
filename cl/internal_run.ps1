param(
    [Parameter(Mandatory=$true)]
    [string] $project_name,

    [Parameter(Mandatory=$true)]
    [string] $build_directory,

    [Parameter(Mandatory=$true)]
    [string] $build_json
)

$jsonData = $build_json | ConvertFrom-Json

$output_name = $jsonData.'$output_name'

$should_procedure_rebuild = $jsonData.'$should_procedure_rebuild'

if ((Test-Path -Path "$build_directory/$output_name") -or ($should_procedure_rebuild -eq $true)) {
    Write-Host "building $project_name..." -ForegroundColor Magenta
    ./c-build/cl/internal_build.ps1 -project_name $project_name -build_directory $key -build_json $jsonValue
}

Push-Location $build_directory
    & "./$output_name"
Pop-Location