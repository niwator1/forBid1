using System;
using System.Diagnostics;
using System.Security.Principal;
using System.Windows;
using System.Windows.Threading;
using 崔子瑾诱捕器.Services;

namespace 崔子瑾诱捕器
{
    /// <summary>
    /// App.xaml 的交互逻辑
    /// </summary>
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            // 检查系统兼容性
            if (!PermissionService.CheckSystemCompatibility())
            {
                Shutdown();
                return;
            }

            // 检查是否以管理员权限运行
            if (!PermissionService.IsRunAsAdministrator())
            {
                MessageBox.Show("此应用程序需要管理员权限才能运行。\n请右键点击应用程序并选择"以管理员身份运行"。",
                    "需要管理员权限", MessageBoxButton.OK, MessageBoxImage.Warning);
                Shutdown();
                return;
            }

            // 验证hosts文件访问权限
            if (!PermissionService.ValidateHostsFileAccess())
            {
                Shutdown();
                return;
            }

            // 设置全局异常处理
            DispatcherUnhandledException += App_DispatcherUnhandledException;
            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;

            base.OnStartup(e);
        }



        private void App_DispatcherUnhandledException(object sender, DispatcherUnhandledExceptionEventArgs e)
        {
            MessageBox.Show($"应用程序发生错误：\n{e.Exception.Message}", "错误", 
                MessageBoxButton.OK, MessageBoxImage.Error);
            e.Handled = true;
        }

        private void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            MessageBox.Show($"应用程序发生严重错误：\n{((Exception)e.ExceptionObject).Message}", "严重错误", 
                MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }
}
