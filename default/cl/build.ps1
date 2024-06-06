param(
	[Parameter(Mandatory=$true)]
	[string] $executable_name,

    [Parameter(Mandatory=$true)]
	[string] $std_version,

    [Parameter(Mandatory=$true)]
	[bool] $debug,

    [Parameter(Mandatory=$true)]
	[bool] $generate_object_files,

    [Parameter(Mandatory=$true)]
	[string] $include_paths,

    [Parameter(Mandatory=$true)]
	[string] $source_paths,

    [Parameter(Mandatory=$true)]
	[string] $lib_paths,
    
    [Parameter(Mandatory=$true)]
	[string] $libs
)


./vars.ps1

# Initialize the command with the standard version
$clCommand = "cl /std:$std_version"

if ($debug) {
    $clCommand += " /Od"
} else {
    $clCommand += " /O2"
}

if ($debug) {
    $clCommand += " /Zi"
}

if ($generate_object_files) {
    $clCommand += " /c"
} else {
    $clCommand += " /Fe$executable_name"
}

$clCommand += " /FC /I$include_paths $source_paths /LIBPATH:$lib_paths /link /LIB:$libs"

if(!(Test-Path -Path ".\ckg")) {
    Write-Host "missing ckg"
    git clone https://github.com/superg3m/ckg.git
} else {
    Push-Location  ".\ckg"
    git stash
    git stash drop
    git pull
    Pop-Location
}

if(!(Test-Path -Path ".\build_cl")) {
    mkdir .\build_cl
}

if(Test-Path -Path ".\compilation_errors.txt") {
	Remove-Item -Path "./compilation_errors.txt" -Force -Confirm:$false
}

Write-Host "running CKit build.ps1..." -ForegroundColor Green

$timer = [Diagnostics.Stopwatch]::new() # Create a timer
$timer.Start() # Start the timer

Push-Location ".\build_cl"
# MAKE SURE YOU HAVE AN OPTION FOR DEBUG LIBS
# cl -DCUSTOM_PLATFORM_IMPL /std:c++20 /c "..\source\*.cpp"
cl /std:$std_version /Zi /FC /c $source_paths | Out-File -FilePath "..\compilation_errors.txt" -Append
lib /OUT:".\ckit.lib" "User32.lib" ".\*.obj" | Out-Null
Pop-Location

$timer.Stop()
Write-Host "========================================================"
Write-Host "MSVC Elapsed time: $($timer.Elapsed.TotalSeconds)s" -ForegroundColor Blue
Write-Host "========================================================"
Write-Host ""

./normalize_path.ps1
