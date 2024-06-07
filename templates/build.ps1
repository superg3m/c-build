# This build file has been generated by C-Build

$configPath = "c_build_config.json"
$jsonData = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$lib_name = $jsonData.'$lib_name'
$executable_name = $jsonData.'$executable_name'
$compile_time_defines = $jsonData.'$compile_time_defines'
$std_version = $jsonData.'$std_version'
$debug_build = $jsonData.'$debug_build'
$build_lib = $jsonData.'$build_lib'
$generate_object_files = $jsonData.'$generate_object_files'
$include_paths = $jsonData.'$include_paths'
$source_paths = $jsonData.'$source_paths'
$additional_libs_for_build = $jsonData.'$additional_libs_for_build'

Push-Location  ".\C-BUILD"
git stash
git stash drop
git pull
Pop-Location

foreach ($key in $jsonData.PSObject.Properties.Name) {
    $value = $object.$key # value is json
    Write-Output "Key: $key, Value: $value"
    
    # If the value is an object, iterate over its properties as well
    if ($value -is [PSCustomObject]) {
        Write-Output "  Nested properties:"
        foreach ($nestedKey in $value.PSObject.Properties.Name) {
            $nestedValue = $value.$nestedKey

            Write-Output "$nestedKey : $nestedValue"

            if ($nestedValue -is [Array]) {
                Write-Output "  Array elements:"
                foreach ($element in $nestedValue) {
                    Write-Output "    $element"
                    
                    # Push-Location "$element"
                    # ./C-BUILD/bootstrap.ps1 -preset $preset -compiler_type $compiler_type
                    # ./build.ps1
                    # 
                    # Pop-Location
                }
            }
        }
    }

    # ./C-BUILD/$preset/$compiler_type/build.ps1 $value
}

