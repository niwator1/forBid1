@echo off
echo ========================================
echo Website Blocker Test Script
echo ========================================
echo.

REM Check administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: This script requires administrator privileges
    echo Please right-click the script and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo [OK] Administrator privileges check passed
echo.

REM Check .NET runtime
dotnet --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] .NET runtime detected:
    dotnet --version
) else (
    echo [WARNING] .NET runtime not detected (not required for self-contained version)
)
echo.

REM Check hosts file
set HOSTS_FILE=C:\Windows\System32\drivers\etc\hosts
if exist "%HOSTS_FILE%" (
    echo [OK] hosts file exists: %HOSTS_FILE%
) else (
    echo [ERROR] hosts file not found: %HOSTS_FILE%
    echo.
    pause
    exit /b 1
)

REM Check hosts file write permission
echo Testing hosts file write permission...
echo # Test write permission >> "%HOSTS_FILE%" 2>nul
if %errorlevel% equ 0 (
    echo [OK] hosts file write permission normal
    REM Remove test line
    powershell -Command "(Get-Content '%HOSTS_FILE%') | Where-Object { $_ -notmatch '# Test write permission' } | Set-Content '%HOSTS_FILE%'" >nul 2>&1
) else (
    echo [ERROR] hosts file write permission insufficient
    echo Please ensure running as administrator
    echo.
    pause
    exit /b 1
)
echo.

REM Check application files
if exist "崔子瑾诱捕器.exe" (
    echo [OK] Application file exists
) else (
    echo [WARNING] Application file not found (may need to build first)
)

if exist "App.xaml" (
    echo [OK] Source code files exist
) else (
    echo [WARNING] Source code files not found
)
echo.

REM Check configuration directory
set CONFIG_DIR=%APPDATA%\崔子瑾诱捕器
echo Configuration directory: %CONFIG_DIR%
if exist "%CONFIG_DIR%" (
    echo [OK] Configuration directory exists
    if exist "%CONFIG_DIR%\config.json" (
        echo [OK] Configuration file exists
    ) else (
        echo [INFO] Configuration file not found (will be created on first run)
    )
    if exist "%CONFIG_DIR%\Backups" (
        echo [OK] Backup directory exists
        dir "%CONFIG_DIR%\Backups\hosts_backup_*.txt" >nul 2>&1
        if %errorlevel% equ 0 (
            echo [OK] Found hosts backup files
        ) else (
            echo [INFO] No hosts backup files found
        )
    ) else (
        echo [INFO] Backup directory not found (will be created on first run)
    )
) else (
    echo [INFO] Configuration directory not found (will be created on first run)
)
echo.

REM Check system compatibility
echo Checking system compatibility...
echo Operating system:
ver
echo.

REM Check system architecture
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo [OK] System architecture: 64-bit (x64)
) else (
    echo [ERROR] System architecture: %PROCESSOR_ARCHITECTURE% (not supported)
    echo This application only supports 64-bit systems
)
echo.

REM Check memory
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| findstr /C:"Total Physical Memory"') do set TOTAL_MEM=%%a
echo System memory:%TOTAL_MEM%
echo.

REM Check disk space
echo Disk space:
dir /-c | findstr "bytes free"
echo.

REM Network connection test
echo Testing network connection...
ping -n 1 8.8.8.8 >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Network connection normal
) else (
    echo [WARNING] Network connection abnormal (may affect DNS resolution test)
)
echo.

REM DNS resolution test
echo Testing DNS resolution...
nslookup google.com >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] DNS resolution normal
) else (
    echo [WARNING] DNS resolution abnormal
)
echo.

REM Windows Firewall check
echo Checking Windows Firewall status...
netsh advfirewall show allprofiles state | findstr "State" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Firewall status check completed
) else (
    echo [WARNING] Unable to check firewall status
)
echo.

echo ========================================
echo Test completed!
echo ========================================
echo.
echo Test results summary:
echo - Administrator privileges: Normal
echo - hosts file access: Normal
echo - System compatibility: Check completed
echo.
echo If all checks pass, the application should run normally.
echo If problems are found, please refer to the troubleshooting section in the user manual.
echo.

REM Ask if start application
if exist "崔子瑾诱捕器.exe" (
    set /p START_APP="Start application for testing? (Y/N): "
    if /i "%START_APP%"=="Y" (
        echo Starting application...
        start "" "崔子瑾诱捕器.exe"
    )
)

pause
