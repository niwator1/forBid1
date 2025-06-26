@echo off
echo ========================================
echo System Check for Website Blocker
echo ========================================
echo.

echo Checking .NET SDK...
dotnet --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] .NET SDK found:
    dotnet --version
    echo You can use: quick-build.bat
) else (
    echo [X] .NET SDK not found
)
echo.

echo Checking .NET Runtime...
dotnet --list-runtimes >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] .NET Runtime found:
    dotnet --list-runtimes | findstr "Microsoft.WindowsDesktop.App 6."
    if %errorlevel% equ 0 (
        echo [OK] .NET 6.0 Desktop Runtime available
    ) else (
        echo [X] .NET 6.0 Desktop Runtime not found
    )
) else (
    echo [X] .NET Runtime not found
)
echo.

echo Checking Visual Studio...
set VS_FOUND=0

if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    echo [OK] Visual Studio 2022 Community found
    set VS_FOUND=1
)

if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    echo [OK] Visual Studio 2022 Professional found
    set VS_FOUND=1
)

if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    echo [OK] Visual Studio 2022 Enterprise found
    set VS_FOUND=1
)

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
    echo [OK] Visual Studio 2019 Community found
    set VS_FOUND=1
)

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    echo [OK] Visual Studio 2019 Professional found
    set VS_FOUND=1
)

if %VS_FOUND% equ 1 (
    echo You can try: build-msbuild.bat
) else (
    echo [X] Visual Studio not found
)
echo.

echo Checking system architecture...
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo [OK] 64-bit system detected
) else (
    echo [X] 32-bit system detected (not supported)
)
echo.

echo Checking Windows version...
ver
echo.

echo ========================================
echo Recommendations:
echo ========================================
echo.

dotnet --version >nul 2>&1
if %errorlevel% equ 0 (
    echo 1. Use quick-build.bat (recommended)
    echo 2. Use build-en.bat for full build
) else (
    if %VS_FOUND% equ 1 (
        echo 1. Try build-msbuild.bat
        echo 2. Install .NET 6.0 SDK for better experience
    ) else (
        echo 1. Install .NET 6.0 SDK (recommended)
        echo    Download from: https://dotnet.microsoft.com/download/dotnet/6.0
        echo 2. Or install Visual Studio 2022 Community (free)
        echo    Download from: https://visualstudio.microsoft.com/
    )
)
echo.

echo ========================================
echo Download Links:
echo ========================================
echo.
echo .NET 6.0 SDK:
echo https://dotnet.microsoft.com/download/dotnet/6.0
echo.
echo Visual Studio 2022 Community (Free):
echo https://visualstudio.microsoft.com/vs/community/
echo.
echo .NET 6.0 Desktop Runtime (for running only):
echo https://dotnet.microsoft.com/download/dotnet/6.0/runtime
echo.

pause
