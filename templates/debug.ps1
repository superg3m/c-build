# This build file has been generated by C-Build



$configPath = "c_build_config.json"
$jsonData = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$project_name = $jsonData.'$project_name'

$debug_with_visual_studio = $jsonData.'$debug_with_visual_studio'

Push-Location  "./c-build"
git fetch origin -q
git reset --hard origin/main -q
git pull -q
Pop-Location

Write-Host "|--------------- Started Building $project_name ---------------|" -ForegroundColor Green
$timer = [Diagnostics.Stopwatch]::new() # Create a timer
$timer.Start() # Start the timer
foreach ($key in $jsonData.PSObject.Properties.Name) {
    $value = $jsonData.$key # value is json

    if ($value -is [PSCustomObject]) {     
        $should_build_procedure = $value.'$should_build_procedure'
        $should_execute = $value.'$should_execute'

        if ($should_build_procedure -eq $false) {
            continue
        }

        $jsonValue = $value | ConvertTo-Json -Compress

        if ($should_execute) {
            ./c-build/$compiler_type/debug_procedure.ps1 -project_name $project_name -build_directory $key -build_json $jsonValue -debug_with_visual_studio $debug_with_visual_studio 
        }
    }
}
$timer.Stop()
Write-Host "|--------------- Build time: $($timer.Elapsed.TotalSeconds)s ---------------|" -ForegroundColor Green

