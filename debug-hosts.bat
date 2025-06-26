@echo off
echo ========================================
echo 崔子瑾诱捕器 - Hosts文件调试工具
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

set HOSTS_FILE=C:\Windows\System32\drivers\etc\hosts

echo 当前hosts文件内容：
echo ========================================
type "%HOSTS_FILE%"
echo ========================================
echo.

echo 查找崔子瑾诱捕器相关条目：
echo ========================================
findstr /C:"崔子瑾诱捕器" "%HOSTS_FILE%" 2>nul
if %errorlevel% neq 0 (
    echo [警告] 未找到崔子瑾诱捕器相关条目
    echo 这可能意味着：
    echo 1. 应用程序没有正确写入hosts文件
    echo 2. 没有添加任何被阻止的网站
    echo 3. hosts文件权限问题
) else (
    echo [成功] 找到崔子瑾诱捕器相关条目
)
echo ========================================
echo.

echo 测试网站解析：
echo ========================================
echo 测试 www.baidu.com:
nslookup www.baidu.com
echo.
echo 测试 www.google.com:
nslookup www.google.com
echo ========================================
echo.

echo 手动测试阻止功能：
echo ========================================
echo 添加测试条目到hosts文件...
echo # === 手动测试 开始 === >> "%HOSTS_FILE%"
echo 127.0.0.1	test.example.com >> "%HOSTS_FILE%"
echo # === 手动测试 结束 === >> "%HOSTS_FILE%"
echo.
echo 测试 test.example.com 解析：
nslookup test.example.com
echo.
echo 清理测试条目...
powershell -Command "(Get-Content '%HOSTS_FILE%') | Where-Object { $_ -notmatch '手动测试' -and $_ -notmatch 'test.example.com' } | Set-Content '%HOSTS_FILE%'" >nul 2>&1
echo [完成] 测试条目已清理
echo ========================================
echo.

echo 检查DNS缓存：
echo ========================================
echo 清理DNS缓存...
ipconfig /flushdns
echo [完成] DNS缓存已清理
echo ========================================
echo.

echo 调试完成！
echo.
echo 如果网站阻止功能不工作，可能的原因：
echo 1. 应用程序没有管理员权限
echo 2. hosts文件写入失败
echo 3. 浏览器使用了DNS over HTTPS (DoH)
echo 4. 使用了代理服务器
echo 5. 网站使用了CDN，需要阻止更多域名
echo.
pause
