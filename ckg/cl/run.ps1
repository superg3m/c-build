./build.ps1

Push-Location ".\examples\cl"
cl /Fe: ".\ckit_test.exe" /Zi "..\*.c" "..\..\build_cl\ckit.lib"
& "./ckit_test.exe"
Pop-Location