@echo off
echo ========================================
echo Website Blocker Package Script
echo ========================================
echo.

set APP_NAME=WebsiteBlocker
set VERSION=1.0.0
set BUILD_DIR=publish
set PACKAGE_DIR=packages

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
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
if exist "bin" rmdir /s /q "bin"
if exist "obj" rmdir /s /q "obj"
echo.

REM Create directories
mkdir "%BUILD_DIR%"
mkdir "%PACKAGE_DIR%"

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
dotnet publish --configuration Release --runtime win-x64 --self-contained true --output "%BUILD_DIR%\self-contained" -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
if %errorlevel% neq 0 (
    echo Error: Self-contained version publish failed
    pause
    exit /b 1
)

REM Publish framework-dependent version
echo Publishing framework-dependent version...
dotnet publish --configuration Release --runtime win-x64 --self-contained false --output "%BUILD_DIR%\framework-dependent"
if %errorlevel% neq 0 (
    echo Error: Framework-dependent version publish failed
    pause
    exit /b 1
)
echo.

REM Copy documentation files
echo Copying documentation files...
copy "README.md" "%BUILD_DIR%\self-contained\" >nul 2>&1
copy "使用说明.md" "%BUILD_DIR%\self-contained\" >nul 2>&1
copy "安装说明.md" "%BUILD_DIR%\self-contained\" >nul 2>&1

copy "README.md" "%BUILD_DIR%\framework-dependent\" >nul 2>&1
copy "使用说明.md" "%BUILD_DIR%\framework-dependent\" >nul 2>&1
copy "安装说明.md" "%BUILD_DIR%\framework-dependent\" >nul 2>&1
echo.

REM Create self-contained version zip
echo Creating self-contained version zip...
powershell -Command "Compress-Archive -Path '%BUILD_DIR%\self-contained\*' -DestinationPath '%PACKAGE_DIR%\%APP_NAME%-v%VERSION%-SelfContained.zip' -Force" >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: Self-contained version zip creation failed
)

REM Create framework-dependent version zip
echo Creating framework-dependent version zip...
powershell -Command "Compress-Archive -Path '%BUILD_DIR%\framework-dependent\*' -DestinationPath '%PACKAGE_DIR%\%APP_NAME%-v%VERSION%-FrameworkDependent.zip' -Force" >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: Framework-dependent version zip creation failed
)
echo.

REM Create source code zip
echo Creating source code zip...
powershell -Command "Compress-Archive -Path '*.cs','*.xaml','*.csproj','*.md','*.bat','Models\*','Views\*','ViewModels\*','Services\*','Resources\*','app.manifest' -DestinationPath '%PACKAGE_DIR%\%APP_NAME%-v%VERSION%-SourceCode.zip' -Force" >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: Source code zip creation failed
)
echo.

echo ========================================
echo Packaging completed!
echo ========================================
echo.
echo Output directories:
echo Self-contained version: %BUILD_DIR%\self-contained\
echo Framework-dependent version: %BUILD_DIR%\framework-dependent\
echo.
echo Zip packages:
dir "%PACKAGE_DIR%\*.zip" /b 2>nul
echo.

echo Important notes:
echo 1. Application requires administrator privileges
echo 2. Self-contained version does not need .NET runtime
echo 3. Framework-dependent version requires .NET 6.0 runtime
echo 4. Please test both versions to ensure they work properly
echo.

set /p OPEN_DIR="Open output directory? (Y/N): "
if /i "%OPEN_DIR%"=="Y" (
    explorer "%PACKAGE_DIR%"
)

pause
