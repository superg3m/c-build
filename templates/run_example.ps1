# This build file has been generated by C-Build

$configPath = "config.json"
$jsonData = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$executable_name = $jsonData.'$executable_name'
$compile_time_defines = $jsonData.'$compile_time_defines'
$std_version = $jsonData.'$std_version'
$debug_build = $jsonData.'$debug_build'
$debug_build = $jsonData.'$debug_build'
$generate_object_files = $jsonData.'$generate_object_files'
$source_example_paths = $jsonData.'$source_example_paths'
$additional_libs_for_example = $jsonData.'$additional_libs_for_example'

Push-Location  ".\C-BUILD"
git stash
git stash drop
git pull
Pop-Location

./C-BUILD/$preset/$compiler_type/run_example.ps1 `
    -executable_name $executable_name `
    -compile_time_defines $compile_time_defines `
    -std_version $std_version `
    -debug_build $debug_build `
    -generate_object_files $generate_object_files `
    -include_paths $include_paths `
    -source_example_paths $source_example_paths `
    -additional_libs_for_example $additional_libs_for_example

