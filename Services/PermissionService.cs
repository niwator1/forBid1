using System;
using System.Diagnostics;
using System.IO;
using System.Security.Principal;
using System.Windows;

namespace 崔子瑾诱捕器.Services
{
    /// <summary>
    /// 权限管理服务
    /// </summary>
    public class PermissionService
    {
        /// <summary>
        /// 检查是否以管理员权限运行
        /// </summary>
        public static bool IsRunAsAdministrator()
        {
            try
            {
                WindowsIdentity identity = WindowsIdentity.GetCurrent();
                WindowsPrincipal principal = new WindowsPrincipal(identity);
                return principal.IsInRole(WindowsBuiltInRole.Administrator);
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// 检查文件是否可写
        /// </summary>
        public static bool CanWriteToFile(string filePath)
        {
            try
            {
                if (!File.Exists(filePath))
                    return false;

                using (var fs = File.OpenWrite(filePath))
                {
                    return true;
                }
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// 检查目录是否可写
        /// </summary>
        public static bool CanWriteToDirectory(string directoryPath)
        {
            try
            {
                if (!Directory.Exists(directoryPath))
                    return false;

                var testFile = Path.Combine(directoryPath, $"test_{Guid.NewGuid()}.tmp");
                File.WriteAllText(testFile, "test");
                File.Delete(testFile);
                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// 请求管理员权限重启应用
        /// </summary>
        public static void RestartAsAdministrator()
        {
            try
            {
                var result = MessageBox.Show(
                    "此应用程序需要管理员权限才能修改hosts文件。\n是否以管理员身份重新启动？",
                    "需要管理员权限",
                    MessageBoxButton.YesNo,
                    MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    var processInfo = new ProcessStartInfo
                    {
                        FileName = Process.GetCurrentProcess().MainModule.FileName,
                        UseShellExecute = true,
                        Verb = "runas" // 以管理员身份运行
                    };

                    Process.Start(processInfo);
                    Application.Current.Shutdown();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"无法以管理员身份启动应用程序：\n{ex.Message}",
                    "错误",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
            }
        }

        /// <summary>
        /// 验证hosts文件访问权限
        /// </summary>
        public static bool ValidateHostsFileAccess(string hostsFilePath = null)
        {
            hostsFilePath ??= @"C:\Windows\System32\drivers\etc\hosts";

            try
            {
                // 检查文件是否存在
                if (!File.Exists(hostsFilePath))
                {
                    MessageBox.Show(
                        $"hosts文件不存在：{hostsFilePath}",
                        "文件不存在",
                        MessageBoxButton.OK,
                        MessageBoxImage.Error);
                    return false;
                }

                // 检查是否有写入权限
                if (!CanWriteToFile(hostsFilePath))
                {
                    if (!IsRunAsAdministrator())
                    {
                        MessageBox.Show(
                            "无法写入hosts文件，需要管理员权限。\n请以管理员身份运行此应用程序。",
                            "权限不足",
                            MessageBoxButton.OK,
                            MessageBoxImage.Warning);
                        return false;
                    }
                    else
                    {
                        MessageBox.Show(
                            "即使以管理员身份运行，仍无法写入hosts文件。\n请检查文件是否被其他程序占用或系统保护。",
                            "文件访问错误",
                            MessageBoxButton.OK,
                            MessageBoxImage.Error);
                        return false;
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"验证hosts文件访问权限时发生错误：\n{ex.Message}",
                    "验证失败",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
                return false;
            }
        }

        /// <summary>
        /// 创建hosts文件备份目录
        /// </summary>
        public static bool EnsureBackupDirectory(string backupPath)
        {
            try
            {
                if (!Directory.Exists(backupPath))
                {
                    Directory.CreateDirectory(backupPath);
                }

                return CanWriteToDirectory(backupPath);
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"无法创建备份目录：\n{ex.Message}",
                    "目录创建失败",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
                return false;
            }
        }

        /// <summary>
        /// 检查系统兼容性
        /// </summary>
        public static bool CheckSystemCompatibility()
        {
            try
            {
                // 检查操作系统版本
                var osVersion = Environment.OSVersion;
                if (osVersion.Platform != PlatformID.Win32NT)
                {
                    MessageBox.Show(
                        "此应用程序仅支持Windows操作系统。",
                        "系统不兼容",
                        MessageBoxButton.OK,
                        MessageBoxImage.Error);
                    return false;
                }

                // 检查.NET版本（通过尝试访问某些API）
                try
                {
                    var _ = Environment.Version;
                }
                catch
                {
                    MessageBox.Show(
                        "系统缺少必要的.NET运行时组件。",
                        "运行时错误",
                        MessageBoxButton.OK,
                        MessageBoxImage.Error);
                    return false;
                }

                return true;
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"系统兼容性检查失败：\n{ex.Message}",
                    "兼容性检查失败",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
                return false;
            }
        }
    }
}
