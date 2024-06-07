param(
    [Parameter(Mandatory=$true)]
    [string] $build_json,
)

$jsonData = $build_json | ConvertFrom-Json

$debug_with_visual_studio = $jsonData.'$debug_with_visual_studio'

if (!(Test-Path -Path $executable_name)) {
    Write-Host "ERROR: Can't find exe, building..." -ForegroundColor Red

    ./C-BUILD/default/cl/build.ps1 -build_json $jsonData -debug_build $true
    
    Push-Location "./build_cl"
    if ($debug_with_visual_studio -eq $true) {
        ./vars.ps1
        devenv $executable_name
    } else {
        #& "raddbg" $executable_name
    }
    Pop-Location
} else {
    Push-Location "./build_cl"
    if ($debug_with_visual_studio -eq $true) {
        ./vars.ps1
        devenv $executable_name
    } else {
        #& "raddbg" $executable_name
    }
    Pop-Location
}