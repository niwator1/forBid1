@echo off
echo Trying to build with MSBuild...
echo.

REM Try to find MSBuild in common locations
set MSBUILD_PATH=""

REM Visual Studio 2022
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    goto :found
)

if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
    goto :found
)

if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    goto :found
)

REM Visual Studio 2019
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
    goto :found
)

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
    goto :found
)

REM Build Tools
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    goto :found
)

echo ERROR: MSBuild not found
echo.
echo Please install one of the following:
echo 1. .NET 6.0 SDK (recommended)
echo 2. Visual Studio 2019/2022
echo 3. Visual Studio Build Tools
echo.
pause
exit /b 1

:found
echo Found MSBuild: %MSBUILD_PATH%
echo.

REM Clean
echo Cleaning...
if exist "bin" rmdir /s /q "bin" >nul 2>&1
if exist "obj" rmdir /s /q "obj" >nul 2>&1
if exist "publish" rmdir /s /q "publish" >nul 2>&1

REM Build
echo Building...
%MSBUILD_PATH% "崔子瑾诱捕器.csproj" /p:Configuration=Release /p:Platform="Any CPU" /verbosity:minimal
if %errorlevel% neq 0 (
    echo BUILD FAILED
    pause
    exit /b 1
)

echo.
echo BUILD SUCCESS!
echo.
echo Output: bin\Release\net6.0-windows\
echo.
echo To run: Right-click the .exe file and select "Run as administrator"
echo Default password: admin123
echo.
pause
