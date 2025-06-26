@echo off
echo Building Website Blocker...
echo.

REM Check .NET SDK
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: .NET SDK not found
    echo Please install .NET 6.0 SDK
    pause
    exit /b 1
)

REM Clean
echo Cleaning...
if exist "bin" rmdir /s /q "bin" >nul 2>&1
if exist "obj" rmdir /s /q "obj" >nul 2>&1
if exist "publish" rmdir /s /q "publish" >nul 2>&1

REM Restore
echo Restoring packages...
dotnet restore >nul 2>&1

REM Build
echo Building...
dotnet build --configuration Release >nul 2>&1
if %errorlevel% neq 0 (
    echo BUILD FAILED
    pause
    exit /b 1
)

REM Publish
echo Publishing...
dotnet publish --configuration Release --runtime win-x64 --self-contained true --output "publish" -p:PublishSingleFile=true >nul 2>&1
if %errorlevel% neq 0 (
    echo PUBLISH FAILED
    pause
    exit /b 1
)

echo.
echo BUILD SUCCESS!
echo.
echo Output: publish\
echo.
echo To run: Right-click the .exe file and select "Run as administrator"
echo Default password: admin123
echo.
pause
