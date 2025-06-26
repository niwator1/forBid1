# 版本信息

## 当前版本：v1.0.0

**发布日期**: 2025年6月26日  
**构建类型**: Release  
**目标框架**: .NET 6.0  
**支持平台**: Windows x64  

## 版本历史

### v1.0.0 (2025-06-26) - 首次发布

#### 🎉 新功能
- **网站访问控制**: 通过修改hosts文件实现网站访问阻止
- **现代化界面**: 苹果风格的简洁美观界面设计
- **密码保护**: 启动时密码验证，默认密码 `admin123`
- **自动备份**: 自动备份hosts文件，保留最近10个备份
- **实时生效**: 网站阻止/允许设置立即生效，无需重启
- **一键重置**: 支持一键清除所有设置并恢复hosts文件
- **批量管理**: 支持添加多个网站并独立控制
- **状态显示**: 实时显示网站数量和阻止状态

#### 🛡️ 安全特性
- **管理员权限验证**: 确保有足够权限修改系统文件
- **密码加密存储**: 使用SHA256加密存储用户密码
- **文件备份机制**: 每次修改前自动备份hosts文件
- **权限检查**: 启动时检查系统兼容性和文件访问权限
- **安全恢复**: 提供多种恢复机制防止系统异常

#### 🎨 界面特性
- **苹果风格设计**: 圆角、柔和色彩、现代化布局
- **响应式界面**: 适配不同屏幕尺寸和分辨率
- **直观操作**: 简单的开关控制和一键操作
- **状态反馈**: 实时状态显示和操作反馈
- **无边框窗口**: 自定义标题栏和窗口控制

#### 🔧 技术特性
- **MVVM架构**: 清晰的代码结构和数据绑定
- **异步操作**: 文件操作使用异步方式，避免界面卡顿
- **错误处理**: 完善的异常处理和用户提示
- **配置管理**: JSON格式配置文件，支持导入导出
- **日志记录**: 详细的操作日志和错误记录

## 技术规格

### 开发环境
- **IDE**: Visual Studio 2022 / Visual Studio Code
- **框架**: .NET 6.0 WPF
- **语言**: C# 10.0
- **UI技术**: XAML + 自定义样式

### 运行环境
- **操作系统**: Windows 7 SP1+ / Windows 8.1+ / Windows 10+ / Windows 11
- **架构**: x64 (64位)
- **运行时**: .NET 6.0 Runtime (依赖框架版本需要)
- **权限**: 管理员权限 (必需)
- **内存**: 最低 512MB，推荐 1GB+
- **存储**: 最低 100MB，推荐 500MB+

### 依赖项
- **Newtonsoft.Json**: 13.0.3 (JSON序列化)
- **Microsoft.WindowsAPICodePack-Shell**: 1.1.0 (系统API)

## 文件结构

### 应用程序文件
```
崔子瑾诱捕器/
├── 崔子瑾诱捕器.exe          # 主程序
├── 崔子瑾诱捕器.dll          # 应用程序库
├── 崔子瑾诱捕器.deps.json    # 依赖项描述
├── 崔子瑾诱捕器.runtimeconfig.json # 运行时配置
├── Newtonsoft.Json.dll       # JSON库
├── README.md                 # 项目说明
├── 使用说明.md               # 使用文档
├── 安装说明.md               # 安装文档
└── [其他运行时文件]
```

### 配置文件位置
```
%AppData%\崔子瑾诱捕器\
├── config.json              # 应用配置
└── Backups/                 # 备份目录
    ├── hosts_backup_20250626_120000.txt
    ├── hosts_backup_20250626_130000.txt
    └── ...
```

### 源代码结构
```
源代码/
├── Models/                  # 数据模型
│   ├── Website.cs
│   └── AppConfig.cs
├── Views/                   # 界面视图
│   ├── LoginWindow.xaml
│   ├── LoginWindow.xaml.cs
│   ├── MainWindow.xaml
│   └── MainWindow.xaml.cs
├── ViewModels/              # 视图模型
│   └── MainWindowViewModel.cs
├── Services/                # 业务服务
│   ├── ConfigService.cs
│   ├── HostsFileService.cs
│   └── PermissionService.cs
├── Resources/               # 资源文件
│   └── Styles.xaml
├── App.xaml                 # 应用程序定义
├── App.xaml.cs              # 应用程序逻辑
├── app.manifest             # 应用程序清单
└── 崔子瑾诱捕器.csproj      # 项目文件
```

## 构建信息

### 构建命令
```bash
# 还原依赖项
dotnet restore

# 构建项目
dotnet build --configuration Release

# 发布自包含版本
dotnet publish --configuration Release --runtime win-x64 --self-contained true --output "publish/self-contained" -p:PublishSingleFile=true

# 发布依赖框架版本
dotnet publish --configuration Release --runtime win-x64 --self-contained false --output "publish/framework-dependent"
```

### 构建脚本
- `build.bat` - 基本构建脚本
- `package.bat` - 完整打包脚本
- `test.bat` - 系统测试脚本

## 已知问题

### v1.0.0 已知问题
- 无已知严重问题

### 限制说明
- 仅支持Windows x64平台
- 需要管理员权限运行
- 不支持IPv6地址阻止
- 不支持通配符域名匹配

## 计划功能

### v1.1.0 计划功能
- 定时任务功能
- 网站分组管理
- 导入/导出网站列表
- 统计和报告功能
- 更多界面主题

### v1.2.0 计划功能
- 网络流量监控
- 白名单模式
- 家长控制功能
- 远程管理接口

## 支持信息

### 技术支持
- 查看使用说明文档
- 检查常见问题解答
- 运行系统测试脚本

### 反馈渠道
- 问题报告：通过GitHub Issues
- 功能建议：通过GitHub Discussions
- 安全问题：通过私有渠道报告

---

**版本**: 1.0.0  
**构建日期**: 2025年6月26日  
**构建环境**: Windows 11 + .NET 6.0 SDK  
**开发团队**: 崔子瑾诱捕器团队
