# This build file has been generated by C-Build
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$PSNativeCommandUseErrorActionPreference = $true

$configPath = "c_build_config.json"
$jsonData = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$project_name = $jsonData.'$project_name'

Push-Location  ".\C-BUILD"
git stash
git stash drop
git pull
Pop-Location

Write-Host "|--------------- Started Building $project_name ---------------|" -ForegroundColor Green
$timer = [Diagnostics.Stopwatch]::new() # Create a timer
$timer.Start() # Start the timer
foreach ($key in $jsonData.PSObject.Properties.Name) {
    $value = $jsonData.$key # value is json


    # If the value is an object, iterate over its properties as well
    if ($value -is [PSCustomObject]) {     
        $should_run = $value.'$should_run'

        if ($should_run -eq $false) {
            continue
        }

        if(!(Test-Path -Path $key)) {
            Write-Host "Creating $value Directory"
            mkdir $key
        }

        foreach ($nestedKey in $value.PSObject.Properties.Name) {
            $nestedValue = $value.$nestedKey

            if ($nestedValue -is [Array]) {
                if (!$nestedValue) {
                    Write-Host "Depends on Nothing!" -ForegroundColor Blue
                    Write-Host ""
                    continue
                }
                
                Write-Host "Depends on: " -ForegroundColor Blue
                foreach ($element in $nestedValue) {
                    Write-Host "  - $element" -ForegroundColor Blue

                    if(!(Test-Path -Path $element)) {
                        Write-Host "missing $element"
                        git clone https://github.com/superg3m/$element.git
                    } else {
                        Push-Location "$element"
                        git stash
                        git stash drop
                        git pull
                        Pop-Location-Location ..
                    }
                    
                    Push-Location "$element"
                    if(!(Test-Path -Path "c-build")) {
                        Write-Host "missing c-build"
                        git clone "https://github.com/superg3m/c-build.git"
                    } else {
                        Push-Location "c-build"
                        git stash
                        git stash drop
                        git pull
                        Pop-Location-Location ..
                    }
                    ./C-BUILD/bootstrap.ps1 -preset -compiler_type $compiler_type
                    ./build.ps1
                    Pop-Location
                }
                Write-Host ""
            }
        }

        # Serialize the $value object to a JSON string
        $jsonValue = $value | ConvertTo-Json -Compress

        ./C-BUILD/$compiler_type/build.ps1 -project_name $project_name -build_directory $key -build_json $jsonValue
    }
}
$timer.Stop()
Write-Host "|--------------- Build time: $($timer.Elapsed.TotalSeconds)s ---------------|" -ForegroundColor Green

