# This build file has been generated by C-Build

$lib_name = ""

$include_paths = ""
$source_paths = "./source"

$lib_paths = ""
$libs = ""

$std_version = "c11"
$debug = $false; # compile with debug symbols

Push-Location  ".\C-BUILD"
git stash
git stash drop
git pull
Pop-Location

./C-BUILD/$preset/$compiler_type/build_lib.ps1 $lib_name $std_version $debug $include_paths $source_paths $lib_paths $libs