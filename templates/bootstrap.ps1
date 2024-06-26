# This build file has been generated by C-Build

$directoryPath = "./c-build"
$repositoryUrl = "https://github.com/superg3m/c-build.git"

if (-not (Test-Path -Path $directoryPath)) {
    Write-Output "Directory does not exist. Cloning the repository..."
    git clone $repositoryUrl
}

$bootstrapScriptPath = "$directoryPath/bootstrap.ps1"
if (Test-Path -Path $bootstrapScriptPath) {
    & $bootstrapScriptPath
} else {
    Write-Output "Bootstrap script not found at $bootstrapScriptPath"
}
