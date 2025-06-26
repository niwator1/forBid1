@echo off
echo ========================================
echo 崔子瑾诱捕器 测试脚本
echo ========================================
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：此脚本需要管理员权限运行
    echo 请右键点击脚本并选择"以管理员身份运行"
    echo.
    pause
    exit /b 1
)

echo ✓ 管理员权限检查通过
echo.

REM 检查.NET运行时
dotnet --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 检测到.NET运行时版本：
    dotnet --version
) else (
    echo ⚠ 未检测到.NET运行时（自包含版本不需要）
)
echo.

REM 检查hosts文件
set HOSTS_FILE=C:\Windows\System32\drivers\etc\hosts
if exist "%HOSTS_FILE%" (
    echo ✓ hosts文件存在：%HOSTS_FILE%
) else (
    echo ✗ hosts文件不存在：%HOSTS_FILE%
    echo.
    pause
    exit /b 1
)

REM 检查hosts文件权限
echo 正在检查hosts文件写入权限...
echo # 测试写入权限 >> "%HOSTS_FILE%" 2>nul
if %errorlevel% equ 0 (
    echo ✓ hosts文件写入权限正常
    REM 移除测试行
    powershell -Command "(Get-Content '%HOSTS_FILE%') | Where-Object { $_ -notmatch '# 测试写入权限' } | Set-Content '%HOSTS_FILE%'"
) else (
    echo ✗ hosts文件写入权限不足
    echo 请确保以管理员身份运行
    echo.
    pause
    exit /b 1
)
echo.

REM 检查应用程序文件
if exist "崔子瑾诱捕器.exe" (
    echo ✓ 应用程序文件存在
) else (
    echo ⚠ 应用程序文件不存在（可能需要先构建）
)

if exist "App.xaml" (
    echo ✓ 源代码文件存在
) else (
    echo ⚠ 源代码文件不存在
)
echo.

REM 检查配置目录
set CONFIG_DIR=%APPDATA%\崔子瑾诱捕器
echo 配置目录：%CONFIG_DIR%
if exist "%CONFIG_DIR%" (
    echo ✓ 配置目录已存在
    if exist "%CONFIG_DIR%\config.json" (
        echo ✓ 配置文件存在
    ) else (
        echo ⚠ 配置文件不存在（首次运行时会创建）
    )
    if exist "%CONFIG_DIR%\Backups" (
        echo ✓ 备份目录存在
        dir "%CONFIG_DIR%\Backups\hosts_backup_*.txt" >nul 2>&1
        if %errorlevel% equ 0 (
            echo ✓ 发现hosts备份文件
        ) else (
            echo ⚠ 未发现hosts备份文件
        )
    ) else (
        echo ⚠ 备份目录不存在（首次运行时会创建）
    )
) else (
    echo ⚠ 配置目录不存在（首次运行时会创建）
)
echo.

REM 检查系统兼容性
echo 正在检查系统兼容性...
echo 操作系统：
ver
echo.

REM 检查系统架构
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo ✓ 系统架构：64位 (x64)
) else (
    echo ✗ 系统架构：%PROCESSOR_ARCHITECTURE% (不支持)
    echo 此应用程序仅支持64位系统
)
echo.

REM 检查内存
for /f "tokens=2 delims=:" %%a in ('systeminfo ^| findstr /C:"总物理内存"') do set TOTAL_MEM=%%a
echo 系统内存：%TOTAL_MEM%
echo.

REM 检查磁盘空间
echo 磁盘空间：
dir /-c | findstr "可用字节"
echo.

REM 网络连接测试
echo 正在测试网络连接...
ping -n 1 8.8.8.8 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 网络连接正常
) else (
    echo ⚠ 网络连接异常（可能影响DNS解析测试）
)
echo.

REM DNS解析测试
echo 正在测试DNS解析...
nslookup google.com >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ DNS解析正常
) else (
    echo ⚠ DNS解析异常
)
echo.

REM 防火墙检查
echo 正在检查Windows防火墙状态...
netsh advfirewall show allprofiles state | findstr "状态" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 防火墙状态检查完成
) else (
    echo ⚠ 无法检查防火墙状态
)
echo.

echo ========================================
echo 测试完成！
echo ========================================
echo.
echo 测试结果总结：
echo - 管理员权限：正常
echo - hosts文件访问：正常
echo - 系统兼容性：检查完成
echo.
echo 如果所有检查都通过，应用程序应该能够正常运行。
echo 如果发现问题，请参考《使用说明.md》中的故障排除部分。
echo.

REM 询问是否启动应用程序
if exist "崔子瑾诱捕器.exe" (
    set /p START_APP="是否启动应用程序进行测试？(Y/N): "
    if /i "%START_APP%"=="Y" (
        echo 正在启动应用程序...
        start "" "崔子瑾诱捕器.exe"
    )
)

pause
