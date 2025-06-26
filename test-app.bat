@echo off
echo ========================================
echo 崔子瑾诱捕器 - 启动测试
echo ========================================
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 需要管理员权限
    echo 请右键点击此文件并选择"以管理员身份运行"
    pause
    exit /b 1
)

echo [成功] 管理员权限检查通过
echo.

REM 检查.NET运行时
echo 检查.NET运行时...
dotnet --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [成功] 检测到.NET运行时:
    dotnet --version
) else (
    echo [警告] 未检测到.NET运行时
    echo 如果使用依赖框架版本，请安装.NET 6.0 Desktop Runtime
)
echo.

REM 检查hosts文件
echo 检查hosts文件访问权限...
set HOSTS_FILE=C:\Windows\System32\drivers\etc\hosts
if exist "%HOSTS_FILE%" (
    echo [成功] hosts文件存在
    echo # 测试写入权限 >> "%HOSTS_FILE%" 2>nul
    if %errorlevel% equ 0 (
        echo [成功] hosts文件写入权限正常
        REM 移除测试行
        powershell -Command "(Get-Content '%HOSTS_FILE%') | Where-Object { $_ -notmatch '# 测试写入权限' } | Set-Content '%HOSTS_FILE%'" >nul 2>&1
    ) else (
        echo [错误] hosts文件写入权限不足
    )
) else (
    echo [错误] hosts文件不存在
)
echo.

REM 查找应用程序文件
echo 查找应用程序文件...
if exist "崔子瑾诱捕器.exe" (
    echo [成功] 找到应用程序: 崔子瑾诱捕器.exe
    
    echo.
    echo 尝试启动应用程序...
    echo 如果应用程序无法启动，请查看下面的错误信息：
    echo ----------------------------------------
    
    REM 尝试启动应用程序
    "崔子瑾诱捕器.exe"
    
    echo ----------------------------------------
    echo 应用程序已退出，退出代码: %errorlevel%
    
) else (
    echo [错误] 未找到应用程序文件
    echo 请确保此脚本与 崔子瑾诱捕器.exe 在同一目录
)

echo.
echo 测试完成！
pause
