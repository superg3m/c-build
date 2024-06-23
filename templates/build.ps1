

Push-Location  "./c-build"
git fetch origin -q
git reset --hard origin/main -q
git pull -q
Pop-Location

function Parse_JsonFile($file_path) {
    if (!(Test-Path -Path $file_path)) {
        throw "Configuration file not found: $file_path"
    }
    
    $json_object = Get-Content -Path $file_path -Raw

    return ConvertFrom-Json -InputObject $json_object
}

$json_config_path = "c_build_config.json"
$jsonData = Parse_JsonFile($json_config_path);
$project = [Project]::new($jsonData, "$compiler_type")

Write-Host "|--------------- Started Building $($project.name) ---------------|" -ForegroundColor Blue
Write-Host "Compiler: $compiler_type"
$timer = [Diagnostics.Stopwatch]::new()
$timer.Start()

$project.BuildProjectDependencies()
$project.BuildProcedures()

$timer.Stop()
Write-Host "|--------------- Build time: $($timer.Elapsed.TotalSeconds)s ---------------|" -ForegroundColor Blue