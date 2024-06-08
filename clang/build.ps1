param(
    [Parameter(Mandatory=$true)]
    [string] $project_name,

    [Parameter(Mandatory=$true)]
    [string] $build_directory,

    [Parameter(Mandatory=$true)]
    [string] $build_json,

    [Parameter(Mandatory=$false)]
    [bool] $debug_build,

    [Parameter(Mandatory=$false)]
    [bool] $run_exe
)

$jsonData = $build_json | ConvertFrom-Json

$output_name = $jsonData.'$output_name'
$compile_time_defines = $jsonData.'$compile_time_defines'
$std_version = $jsonData.'$std_version'
$build_lib = $jsonData.'$build_lib'
$include_paths = $jsonData.'$include_paths'
$source_paths = $jsonData.'$source_paths'
$additional_libs = $jsonData.'$additional_libs'

$build_name = $jsonData.'$build_name'
Write-Host "running [$project_name - $build_name] build.ps1..." -ForegroundColor Green

./vars.ps1

if ($run_exe -eq $true -and (Test-Path -Path $build_directory/$output_name)) {
    goto :should_run_exe
}

# Initialize the command with the standard version
$clCommand = "cl /std:$std_version /nologo"

if ($debug_build -eq $true) {
    $clCommand += " /Od"
} else {
    $clCommand += " /O2"
}

if ($debug_build -eq $true) {
    $clCommand += " /Zi"
}

foreach ($define in $compile_time_defines) {
    #$clCommand += " -D$define"
}

if ($build_lib -eq $true) {
    $clCommand += " /c"
} else {
    $clCommand += " /Fe$output_name $additional_libs"
}

# $clCommand += " /I$include_paths"
$clCommand += " /FC $source_paths"

if(Test-Path -Path ".\compilation_errors.txt") {
	Remove-Item -Path "./compilation_errors.txt" -Force -Confirm:$false
}

Push-Location $build_directory
    Invoke-Expression "$clCommand | Out-File -FilePath 'compilation_errors.txt' -Append"
    if ($build_lib -eq $true) {
        lib /OUT:$output_name $additional_libs ".\*.obj" | Out-Null
    }
Pop-Location

./c-build/cl/normalize_path.ps1 -project_name $project_name -build_directory $build_directory -build_json $build_json

:should_run_exe
Push-Location $build_directory
    if ($build_lib -eq $false -and $run_exe -eq $true) {
        & "./$output_name"
    }
Pop-Location