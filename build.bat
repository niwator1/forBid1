@echo off
echo ========================================
echo Build Script
echo ========================================
echo.

dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: .NET SDK not found
    pause
    exit /b 1
)

echo .NET SDK version:
dotnet --version
echo.

echo Cleaning...
if exist "bin" rmdir /s /q "bin"
if exist "obj" rmdir /s /q "obj"
if exist "publish" rmdir /s /q "publish"
echo.

echo Restoring packages...
dotnet restore
if %errorlevel% neq 0 (
    echo Error: Restore failed
    pause
    exit /b 1
)
echo.

echo Building...
dotnet build --configuration Release
if %errorlevel% neq 0 (
    echo Error: Build failed
    pause
    exit /b 1
)
echo.

echo Publishing self-contained version...
dotnet publish --configuration Release --runtime win-x64 --self-contained true --output "publish\win-x64" -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
if %errorlevel% neq 0 (
    echo Error: Publish failed
    pause
    exit /b 1
)
echo.

echo Publishing framework-dependent version...
dotnet publish --configuration Release --runtime win-x64 --self-contained false --output "publish\win-x64-framework-dependent"
if %errorlevel% neq 0 (
    echo Error: Publish failed
    pause
    exit /b 1
)
echo.

echo ========================================
echo Build completed!
echo ========================================
echo.
echo Output files:
echo Self-contained: publish\win-x64\
echo Framework-dependent: publish\win-x64-framework-dependent\
echo.
echo IMPORTANT: Run as administrator!
echo.
pause
