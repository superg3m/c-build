# This build file has been generated by C-Build
if ($PSVersionTable.Platform -eq "Unix") {
    Set-Alias python python3
}

. ./c-build/validate_temp_files.ps1 $MyInvocation.MyCommand.Name

Push-Location  "./c-build"
git fetch origin -q
git reset --hard origin/main -q
git pull -q
Pop-Location

if ($args[0] -eq "-debug") {
    python ./c-build/scripts/build_with_debug.py
} else {
    python ./c-build/scripts/build.py
}



