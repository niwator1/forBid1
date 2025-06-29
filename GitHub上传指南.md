# GitHub 上传和自动构建指南

## 🎯 目标
通过 GitHub 的免费在线构建服务，获得完整的 WPF 应用程序，无需本地安装任何开发工具。

## 📋 详细步骤

### 第一步：创建 GitHub 账户
1. **访问**：https://github.com
2. **点击** "Sign up" 注册
3. **填写信息**：
   - 用户名（建议使用英文）
   - 邮箱地址
   - 密码
4. **验证邮箱**并完成注册

### 第二步：创建新仓库
1. **登录 GitHub** 后点击右上角的 "+" 号
2. **选择** "New repository"
3. **填写仓库信息**：
   - Repository name: `website-blocker`
   - Description: `崔子瑾诱捕器 - 网站访问控制工具`
   - 选择 **Public**（免费用户必须选择公开才能使用 Actions）
   - ✅ 勾选 "Add a README file"
4. **点击** "Create repository"

### 第三步：上传项目文件
1. **在仓库页面点击** "Add file" → "Upload files"

2. **准备上传的文件**（从您的项目目录）：
   ```
   需要上传的文件：
   ├── .github/workflows/build.yml    (构建配置)
   ├── Models/                        (模型文件夹)
   ├── Views/                         (界面文件夹)
   ├── ViewModels/                    (视图模型文件夹)
   ├── Services/                      (服务文件夹)
   ├── Resources/                     (资源文件夹)
   ├── App.xaml
   ├── App.xaml.cs
   ├── app.manifest
   ├── 崔子瑾诱捕器.csproj
   ├── README.md
   ├── 使用说明.md
   ├── 安装说明.md
   └── 其他 .md 文档文件
   ```

3. **上传方式**：
   - **方式一**：直接拖拽文件和文件夹到网页
   - **方式二**：点击 "choose your files" 选择文件

4. **提交更改**：
   - 在页面底部填写提交信息：`Initial commit - 上传项目文件`
   - 点击 "Commit changes"

### 第四步：等待自动构建
1. **查看构建状态**：
   - 上传完成后，点击仓库顶部的 **"Actions"** 标签
   - 您会看到一个正在运行的构建任务

2. **构建过程**：
   - 🟡 黄色圆点：正在构建
   - ✅ 绿色勾号：构建成功
   - ❌ 红色叉号：构建失败

3. **构建时间**：通常需要 5-10 分钟

### 第五步：下载构建结果
1. **构建完成后**，点击构建任务名称
2. **滚动到页面底部**，找到 "Artifacts" 部分
3. **下载文件**：
   - `崔子瑾诱捕器-自包含版本.zip`（推荐）
   - `崔子瑾诱捕器-依赖框架版本.zip`

### 第六步：使用应用程序
1. **解压下载的 ZIP 文件**
2. **找到** `崔子瑾诱捕器.exe`
3. **右键点击** → "以管理员身份运行"
4. **使用默认密码** `admin123` 登录

## 🔍 故障排除

### 问题1：构建失败
**可能原因**：
- 文件上传不完整
- `.github/workflows/build.yml` 文件缺失

**解决方案**：
- 检查所有必要文件是否上传
- 重新上传缺失的文件
- 重新触发构建

### 问题2：找不到 Actions 标签
**原因**：仓库设为私有
**解决方案**：
- 进入仓库设置 (Settings)
- 滚动到底部，点击 "Change repository visibility"
- 改为 Public

### 问题3：没有构建产物
**原因**：构建配置问题
**解决方案**：
- 确保 `.github/workflows/build.yml` 文件正确上传
- 检查文件内容是否完整

## 📱 手机操作提示

如果您使用手机：
1. **GitHub 手机版**网站功能完整
2. **文件上传**可能需要分批进行
3. **建议使用电脑**操作更方便

## 🎁 备用方案

如果 GitHub 操作有困难，我可以：
1. **为您预构建**应用程序
2. **提供直接下载链接**
3. **通过其他方式**分享给您

## ✅ 检查清单

上传前请确认：
- [ ] 所有源代码文件已准备
- [ ] `.github/workflows/build.yml` 文件已包含
- [ ] 项目文件 `崔子瑾诱捕器.csproj` 已包含
- [ ] 文档文件已包含

构建完成后确认：
- [ ] 下载了正确的 ZIP 文件
- [ ] 解压后找到了 .exe 文件
- [ ] 能够以管理员身份运行
- [ ] 界面显示正常

## 🚀 开始操作

现在您可以：
1. **访问** https://github.com
2. **按照上述步骤**创建账户和仓库
3. **上传项目文件**
4. **等待构建完成**
5. **下载并使用**应用程序

需要我协助任何具体步骤吗？
