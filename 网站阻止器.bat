@echo off
chcp 65001 >nul
title 崔子瑾诱捕器 - 网站访问控制

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：需要管理员权限运行此程序
    echo 请右键点击此文件并选择"以管理员身份运行"
    pause
    exit /b 1
)

REM 配置
set HOSTS_FILE=C:\Windows\System32\drivers\etc\hosts
set CONFIG_DIR=%APPDATA%\WebsiteBlocker
set CONFIG_FILE=%CONFIG_DIR%\sites.txt
set BACKUP_DIR=%CONFIG_DIR%\Backups
set BLOCK_MARKER=# WebsiteBlocker

REM 创建目录
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM 密码验证
set DEFAULT_PASSWORD=admin123
set /p INPUT_PASSWORD=请输入密码 (默认: %DEFAULT_PASSWORD%): 
if "%INPUT_PASSWORD%"=="" set INPUT_PASSWORD=%DEFAULT_PASSWORD%
if not "%INPUT_PASSWORD%"=="%DEFAULT_PASSWORD%" (
    echo 密码错误！
    pause
    exit /b 1
)

:MAIN_MENU
cls
echo ========================================
echo           崔子瑾诱捕器
echo        网站访问控制工具
echo ========================================
echo.

echo 当前阻止的网站:
echo ----------------------------------------
if exist "%CONFIG_FILE%" (
    set /a COUNT=0
    for /f "tokens=*" %%a in (%CONFIG_FILE%) do (
        set /a COUNT+=1
        echo   !COUNT!. %%a
    )
    if !COUNT!==0 echo   (无)
) else (
    echo   (无)
)

echo.
echo 操作选项:
echo   1. 添加网站
echo   2. 删除网站  
echo   3. 清空所有
echo   4. 刷新DNS
echo   5. 查看备份
echo   6. 退出
echo.

set /p CHOICE=请选择操作 (1-6): 

if "%CHOICE%"=="1" goto ADD_SITE
if "%CHOICE%"=="2" goto REMOVE_SITE
if "%CHOICE%"=="3" goto CLEAR_ALL
if "%CHOICE%"=="4" goto FLUSH_DNS
if "%CHOICE%"=="5" goto SHOW_BACKUPS
if "%CHOICE%"=="6" goto EXIT
echo 无效选择，请重试
pause
goto MAIN_MENU

:ADD_SITE
echo.
set /p NEW_SITE=输入要阻止的网站 (例如: facebook.com): 
if "%NEW_SITE%"=="" (
    echo 网站地址不能为空
    pause
    goto MAIN_MENU
)

REM 清理URL
set CLEAN_SITE=%NEW_SITE%
set CLEAN_SITE=%CLEAN_SITE:http://=%
set CLEAN_SITE=%CLEAN_SITE:https://=%
set CLEAN_SITE=%CLEAN_SITE:www.=%
for /f "tokens=1 delims=/" %%a in ("%CLEAN_SITE%") do set CLEAN_SITE=%%a

REM 检查是否已存在
if exist "%CONFIG_FILE%" (
    findstr /i /c:"%CLEAN_SITE%" "%CONFIG_FILE%" >nul
    if !errorlevel!==0 (
        echo 网站已存在: %CLEAN_SITE%
        pause
        goto MAIN_MENU
    )
)

REM 添加到配置文件
echo %CLEAN_SITE% >> "%CONFIG_FILE%"

REM 更新hosts文件
call :UPDATE_HOSTS
echo 已添加: %CLEAN_SITE%
pause
goto MAIN_MENU

:REMOVE_SITE
if not exist "%CONFIG_FILE%" (
    echo 没有网站可删除
    pause
    goto MAIN_MENU
)

echo.
echo 选择要删除的网站:
set /a COUNT=0
for /f "tokens=*" %%a in (%CONFIG_FILE%) do (
    set /a COUNT+=1
    echo   !COUNT!. %%a
    set SITE_!COUNT!=%%a
)

if %COUNT%==0 (
    echo 没有网站可删除
    pause
    goto MAIN_MENU
)

set /p DEL_NUM=输入要删除的网站编号 (1-%COUNT%): 
if "%DEL_NUM%"=="" goto MAIN_MENU

REM 删除指定网站
set TEMP_FILE=%CONFIG_DIR%\temp.txt
if exist "%TEMP_FILE%" del "%TEMP_FILE%"

set /a CURRENT=0
for /f "tokens=*" %%a in (%CONFIG_FILE%) do (
    set /a CURRENT+=1
    if not !CURRENT!==%DEL_NUM% echo %%a >> "%TEMP_FILE%"
)

if exist "%TEMP_FILE%" (
    move "%TEMP_FILE%" "%CONFIG_FILE%" >nul
) else (
    del "%CONFIG_FILE%" 2>nul
)

call :UPDATE_HOSTS
echo 网站已删除
pause
goto MAIN_MENU

:CLEAR_ALL
echo.
set /p CONFIRM=确定要清空所有阻止的网站吗? (y/N): 
if /i not "%CONFIRM%"=="y" goto MAIN_MENU

if exist "%CONFIG_FILE%" del "%CONFIG_FILE%"
call :UPDATE_HOSTS
echo 已清空所有网站
pause
goto MAIN_MENU

:FLUSH_DNS
echo.
echo 正在刷新DNS缓存...
ipconfig /flushdns >nul
echo DNS缓存已刷新
pause
goto MAIN_MENU

:SHOW_BACKUPS
echo.
echo 备份文件:
dir "%BACKUP_DIR%\hosts_*.txt" /b 2>nul
if %errorlevel% neq 0 echo 没有备份文件
pause
goto MAIN_MENU

:UPDATE_HOSTS
REM 备份hosts文件
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
copy "%HOSTS_FILE%" "%BACKUP_DIR%\hosts_%TIMESTAMP%.txt" >nul

REM 读取现有hosts内容，移除旧的阻止条目
set TEMP_HOSTS=%CONFIG_DIR%\temp_hosts.txt
if exist "%TEMP_HOSTS%" del "%TEMP_HOSTS%"

set IN_BLOCK=0
for /f "usebackq tokens=*" %%a in ("%HOSTS_FILE%") do (
    set LINE=%%a
    echo !LINE! | findstr /c:"%BLOCK_MARKER%" >nul
    if !errorlevel!==0 (
        echo !LINE! | findstr /c:"Start" >nul
        if !errorlevel!==0 set IN_BLOCK=1
        echo !LINE! | findstr /c:"End" >nul
        if !errorlevel!==0 set IN_BLOCK=0
    ) else (
        if !IN_BLOCK!==0 echo !LINE! >> "%TEMP_HOSTS%"
    )
)

REM 添加新的阻止条目
if exist "%CONFIG_FILE%" (
    echo. >> "%TEMP_HOSTS%"
    echo %BLOCK_MARKER% - Start >> "%TEMP_HOSTS%"
    for /f "tokens=*" %%a in (%CONFIG_FILE%) do (
        echo 127.0.0.1	%%a %BLOCK_MARKER% >> "%TEMP_HOSTS%"
        echo 127.0.0.1	www.%%a %BLOCK_MARKER% >> "%TEMP_HOSTS%"
    )
    echo %BLOCK_MARKER% - End >> "%TEMP_HOSTS%"
)

REM 替换hosts文件
move "%TEMP_HOSTS%" "%HOSTS_FILE%" >nul
echo hosts文件已更新
goto :eof

:EXIT
echo.
echo 感谢使用崔子瑾诱捕器！
pause
exit /b 0
