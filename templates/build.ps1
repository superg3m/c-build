# This build file has been generated by C-Build

$configPath = "c_build_config.json"
$jsonData = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$project_name = $jsonData.'$project_name'

Push-Location  ".\C-BUILD"
git stash
git stash drop
git pull
Pop-Location

Write-Host "|--------------- Started Building $value ---------------|" -ForegroundColor Green
$timer = [Diagnostics.Stopwatch]::new() # Create a timer
$timer.Start() # Start the timer
foreach ($key in $jsonData.PSObject.Properties.Name) {
    $value = $jsonData.$key # value is json
    Write-Host "Key: $key, Value: $value"
    
    # If the value is an object, iterate over its properties as well
    if ($value -is [PSCustomObject]) {

        if(!(Test-Path -Path $key)) {
            Write-Host "Creating $value Directory"
            mkdir $key
        }

        foreach ($nestedKey in $value.PSObject.Properties.Name) {
            $nestedValue = $value.$nestedKey

            Write-Host "$nestedKey : $nestedValue"

            if ($nestedValue -is [Array]) {
                Write-Host "Array elements:"
                foreach ($element in $nestedValue) {
                    Write-Host "$element"
                    
                    # Push-Location "$element"
                    # ./C-BUILD/bootstrap.ps1 -preset $preset -compiler_type $compiler_type
                    # ./build.ps1
                    # 
                    # Pop-Location
                }
            }
        }
        
        ./C-BUILD/$preset/$compiler_type/build.ps1 -project_name $project_name -build_directory $key -build_json $value
    }
}

$timer.Stop()
Write-Host "[]==========================================[]"
Write-Host "     $project_name Elapsed time: $($timer.Elapsed.TotalSeconds)s" -ForegroundColor Blue
Write-Host "[]==========================================[]"
Write-Host ""
Write-Host "|--------------- Finished Building $project_name ---------------|" -ForegroundColor Green

