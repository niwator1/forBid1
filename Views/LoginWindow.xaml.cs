using System;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using 崔子瑾诱捕器.Services;

namespace 崔子瑾诱捕器.Views
{
    /// <summary>
    /// LoginWindow.xaml 的交互逻辑
    /// </summary>
    public partial class LoginWindow : Window
    {
        private readonly ConfigService _configService;
        private int _failedAttempts = 0;
        private const int MAX_FAILED_ATTEMPTS = 3;

        public LoginWindow()
        {
            InitializeComponent();
            _configService = new ConfigService();
            
            // 设置焦点到密码框
            Loaded += (s, e) => PasswordBox.Focus();
            
            // 加载配置
            LoadConfigAsync();
        }

        private async void LoadConfigAsync()
        {
            try
            {
                await _configService.LoadConfigAsync();
                RememberPasswordCheckBox.IsChecked = _configService.CurrentConfig.RememberPassword;
            }
            catch (Exception ex)
            {
                ShowError($"加载配置失败: {ex.Message}");
            }
        }

        private async void LoginButton_Click(object sender, RoutedEventArgs e)
        {
            await AttemptLoginAsync();
        }

        private async void PasswordBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                await AttemptLoginAsync();
            }
        }

        private async Task AttemptLoginAsync()
        {
            var password = PasswordBox.Password;
            
            if (string.IsNullOrWhiteSpace(password))
            {
                ShowError("请输入密码");
                return;
            }

            try
            {
                // 禁用控件防止重复点击
                SetControlsEnabled(false);
                
                // 验证密码
                if (_configService.VerifyPassword(password))
                {
                    // 保存记住密码设置
                    _configService.CurrentConfig.RememberPassword = RememberPasswordCheckBox.IsChecked == true;
                    await _configService.SaveConfigAsync();

                    // 登录成功，打开主窗口
                    var mainWindow = new MainWindow();
                    mainWindow.Show();
                    this.Close();
                }
                else
                {
                    _failedAttempts++;
                    
                    if (_failedAttempts >= MAX_FAILED_ATTEMPTS)
                    {
                        ShowError($"密码错误次数过多，应用程序将关闭");
                        await Task.Delay(2000);
                        Application.Current.Shutdown();
                        return;
                    }
                    
                    ShowError($"密码错误 ({_failedAttempts}/{MAX_FAILED_ATTEMPTS})");
                    PasswordBox.Clear();
                    PasswordBox.Focus();
                }
            }
            catch (Exception ex)
            {
                ShowError($"登录过程中发生错误: {ex.Message}");
            }
            finally
            {
                SetControlsEnabled(true);
            }
        }

        private void SetControlsEnabled(bool enabled)
        {
            LoginButton.IsEnabled = enabled;
            PasswordBox.IsEnabled = enabled;
            RememberPasswordCheckBox.IsEnabled = enabled;
        }

        private void ShowError(string message)
        {
            ErrorMessageTextBlock.Text = message;
            ErrorMessageTextBlock.Visibility = Visibility.Visible;
            
            // 3秒后自动隐藏错误消息
            var timer = new System.Windows.Threading.DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(3)
            };
            timer.Tick += (s, e) =>
            {
                ErrorMessageTextBlock.Visibility = Visibility.Collapsed;
                timer.Stop();
            };
            timer.Start();
        }

        // 窗口控制事件处理
        private void Window_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (e.LeftButton == MouseButtonState.Pressed)
            {
                this.DragMove();
            }
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            Application.Current.Shutdown();
        }
    }
}
