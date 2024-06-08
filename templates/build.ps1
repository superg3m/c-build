# This build file has been generated by C-Build

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$PSNativeCommandUseErrorActionPreference = $true

$configPath = "c_build_config.json"
$project_is_built_path = "c_build_is_build.flag"
$jsonData = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$project_name = $jsonData.'$project_name'

Push-Location  "./c-build"
git fetch origin -q
git reset --hard origin/main -q
git pull -q
Pop-Location

Write-Host "|--------------- Started Building $project_name ---------------|" -ForegroundColor Blue
$timer = [Diagnostics.Stopwatch]::new() # Create a timer
$timer.Start() # Start the timer
foreach ($key in $jsonData.PSObject.Properties.Name) {
    $value = $jsonData.$key # value is json

    # If the value is json, iterate over its properties as well
    if ($value -is [PSCustomObject]) {     
        $build_procedure_name = $value.'$build_procedure_name'
        $should_build_procedure = $value.'$should_build_procedure'
        $should_procedure_rebuild = $value.'$should_procedure_rebuild'
        $should_fully_rebuild_project_depedencies = $value.'$should_fully_rebuild_project_depedencies'

        if ($should_build_procedure -eq $false) {
            Write-Host "Skipping $build_procedure_name..." -ForegroundColor Magenta
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
                    continue
                }
                
                Write-Host "[$build_procedure_name] depends on: " -ForegroundColor Blue
                foreach ($element in $nestedValue) {
                    Write-Host "  - $element" -ForegroundColor Blue

                    if(!(Test-Path -Path $element)) {
                        Write-Host "missing $element"
                        git clone https://github.com/superg3m/$element.git
                    } else {
                        Push-Location $element
                        git fetch origin -q
                        git reset --hard origin/main -q
                        git pull -q
                        Pop-Location
                    }
                    
                    Push-Location "$element"
                    if(!(Test-Path -Path "c-build")) {
                        git clone "https://github.com/superg3m/c-build.git"
                    } else {
                        Push-Location  "./c-build"
                        git fetch origin -q
                        git reset --hard origin/main -q
                        git pull -q
                        Pop-Location
                    }

                    if ($should_fully_rebuild_project_depedencies -eq $true) {
                        if (Test-Path -Path $project_is_built_path) {
                            Remove-Item -Path $project_is_built_path > $null
                        }
                        ./c-build/bootstrap.ps1 -compiler_type $compiler_type
                    }
                    
                    if (Test-Path -Path $project_is_built_path) {
                        Write-Host "$element Depedency Already Build Skipping..." -ForegroundColor Magenta
                    } else {
                        ./build.ps1
                        New-Item -Path $project_is_built_path > $null
                    }
                    
                    Pop-Location
                }
                Write-Host ""
            }
        }

        # Serialize the $value object to a JSON string
        $jsonValue = $value | ConvertTo-Json -Compress

        if ($should_procedure_rebuild -eq $true) {
            ./c-build/$compiler_type/internal_build.ps1 -project_name $project_name -build_directory $key -build_json $jsonValue
        } else {
            Write-Host "Procedure Already Built Skipping $build_procedure_name..." -ForegroundColor Magenta
        }
    }
}
$timer.Stop()
Write-Host "|--------------- Build time: $($timer.Elapsed.TotalSeconds)s ---------------|" -ForegroundColor Blue

