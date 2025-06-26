@echo off
echo ========================================
echo Website Blocker Build Script
echo ========================================
echo.

REM Check if .NET SDK is installed
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: .NET SDK not detected
    echo Please download and install .NET 6.0 SDK from:
    echo https://dotnet.microsoft.com/download/dotnet/6.0
    echo.
    pause
    exit /b 1
)

echo Detected .NET SDK version:
dotnet --version
echo.

REM Clean previous builds
echo Cleaning previous builds...
if exist "bin" rmdir /s /q "bin"
if exist "obj" rmdir /s /q "obj"
if exist "publish" rmdir /s /q "publish"
echo.

REM Restore NuGet packages
echo Restoring NuGet packages...
dotnet restore
if %errorlevel% neq 0 (
    echo Error: NuGet package restore failed
    pause
    exit /b 1
)
echo.

REM Build project
echo Building project...
dotnet build --configuration Release
if %errorlevel% neq 0 (
    echo Error: Project build failed
    pause
    exit /b 1
)
echo.

REM Publish self-contained version
echo Publishing self-contained version...
dotnet publish --configuration Release --runtime win-x64 --self-contained true --output "publish\win-x64" -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
if %errorlevel% neq 0 (
    echo Error: Self-contained version publish failed
    pause
    exit /b 1
)

REM Publish framework-dependent version
echo Publishing framework-dependent version...
dotnet publish --configuration Release --runtime win-x64 --self-contained false --output "publish\win-x64-framework-dependent"
if %errorlevel% neq 0 (
    echo Error: Framework-dependent version publish failed
    pause
    exit /b 1
)
echo.

echo ========================================
echo Build completed successfully!
echo ========================================
echo.
echo Output files location:
echo Self-contained version: publish\win-x64\
echo Framework-dependent version: publish\win-x64-framework-dependent\
echo.
echo IMPORTANT: The application requires administrator privileges to run!
echo.
pause
