# This build file has been generated by C-Build and is specifically for the MSVC compiler cl

$executable_name = ""

$include_paths = ""
$source_paths = "./source"

$lib_paths = ""
$libs = ""

$std_version = ""
$debug = false; # compile with debug symbols
$generate_object_files = false;

Push-Location  ".\C-BUILD"
git stash
git stash drop
git pull
Pop-Location

./C-BUILD/$compiler_type/build.ps1 $executable_name $std_version $debug $generate_object_files $include_paths $source_paths $lib_paths $libs