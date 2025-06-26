@echo off
echo ========================================
echo 崔子瑾诱捕器 打包脚本
echo ========================================
echo.

REM 设置变量
set APP_NAME=崔子瑾诱捕器
set VERSION=1.0.0
set BUILD_DIR=publish
set PACKAGE_DIR=packages

REM 检查是否安装了.NET SDK
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：未检测到.NET SDK
    echo 请从以下地址下载并安装.NET 6.0 SDK：
    echo https://dotnet.microsoft.com/download/dotnet/6.0
    echo.
    pause
    exit /b 1
)

echo 检测到.NET SDK版本：
dotnet --version
echo.

REM 清理之前的构建
echo 正在清理之前的构建...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
if exist "bin" rmdir /s /q "bin"
if exist "obj" rmdir /s /q "obj"
echo.

REM 创建目录
mkdir "%BUILD_DIR%"
mkdir "%PACKAGE_DIR%"

REM 还原NuGet包
echo 正在还原NuGet包...
dotnet restore
if %errorlevel% neq 0 (
    echo 错误：NuGet包还原失败
    pause
    exit /b 1
)
echo.

REM 构建项目
echo 正在构建项目...
dotnet build --configuration Release
if %errorlevel% neq 0 (
    echo 错误：项目构建失败
    pause
    exit /b 1
)
echo.

REM 发布自包含版本
echo 正在发布自包含版本...
dotnet publish --configuration Release --runtime win-x64 --self-contained true --output "%BUILD_DIR%\self-contained" -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
if %errorlevel% neq 0 (
    echo 错误：自包含版本发布失败
    pause
    exit /b 1
)

REM 发布依赖框架版本
echo 正在发布依赖框架版本...
dotnet publish --configuration Release --runtime win-x64 --self-contained false --output "%BUILD_DIR%\framework-dependent"
if %errorlevel% neq 0 (
    echo 错误：依赖框架版本发布失败
    pause
    exit /b 1
)
echo.

REM 复制文档文件到发布目录
echo 正在复制文档文件...
copy "README.md" "%BUILD_DIR%\self-contained\"
copy "使用说明.md" "%BUILD_DIR%\self-contained\"
copy "安装说明.md" "%BUILD_DIR%\self-contained\"

copy "README.md" "%BUILD_DIR%\framework-dependent\"
copy "使用说明.md" "%BUILD_DIR%\framework-dependent\"
copy "安装说明.md" "%BUILD_DIR%\framework-dependent\"
echo.

REM 创建自包含版本压缩包
echo 正在创建自包含版本压缩包...
powershell -Command "Compress-Archive -Path '%BUILD_DIR%\self-contained\*' -DestinationPath '%PACKAGE_DIR%\%APP_NAME%-v%VERSION%-自包含版本.zip' -Force"
if %errorlevel% neq 0 (
    echo 警告：自包含版本压缩失败，请手动压缩
)

REM 创建依赖框架版本压缩包
echo 正在创建依赖框架版本压缩包...
powershell -Command "Compress-Archive -Path '%BUILD_DIR%\framework-dependent\*' -DestinationPath '%PACKAGE_DIR%\%APP_NAME%-v%VERSION%-依赖框架版本.zip' -Force"
if %errorlevel% neq 0 (
    echo 警告：依赖框架版本压缩失败，请手动压缩
)
echo.

REM 创建源代码压缩包
echo 正在创建源代码压缩包...
powershell -Command "Compress-Archive -Path '*.cs','*.xaml','*.csproj','*.md','*.bat','Models\*','Views\*','ViewModels\*','Services\*','Resources\*','app.manifest' -DestinationPath '%PACKAGE_DIR%\%APP_NAME%-v%VERSION%-源代码.zip' -Force"
if %errorlevel% neq 0 (
    echo 警告：源代码压缩失败，请手动压缩
)
echo.

REM 显示文件大小信息
echo ========================================
echo 打包完成！
echo ========================================
echo.
echo 输出目录：
echo 自包含版本：%BUILD_DIR%\self-contained\
echo 依赖框架版本：%BUILD_DIR%\framework-dependent\
echo.
echo 压缩包：
dir "%PACKAGE_DIR%\*.zip" /b
echo.

REM 显示文件大小
for %%f in ("%PACKAGE_DIR%\*.zip") do (
    echo %%~nf: %%~zf 字节
)
echo.

echo 重要提示：
echo 1. 运行应用程序需要管理员权限
echo 2. 自包含版本无需安装.NET运行时
echo 3. 依赖框架版本需要.NET 6.0运行时
echo 4. 请测试两个版本确保正常工作
echo.

REM 询问是否打开输出目录
set /p OPEN_DIR="是否打开输出目录？(Y/N): "
if /i "%OPEN_DIR%"=="Y" (
    explorer "%PACKAGE_DIR%"
)

pause
