using System;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using 崔子瑾诱捕器.Models;
using 崔子瑾诱捕器.ViewModels;

namespace 崔子瑾诱捕器.Views
{
    /// <summary>
    /// MainWindow.xaml 的交互逻辑
    /// </summary>
    public partial class MainWindow : Window
    {
        private readonly MainWindowViewModel _viewModel;

        public MainWindow()
        {
            InitializeComponent();
            
            _viewModel = new MainWindowViewModel();
            DataContext = _viewModel;
            
            // 绑定状态消息
            _viewModel.PropertyChanged += (s, e) =>
            {
                if (e.PropertyName == nameof(MainWindowViewModel.StatusMessage))
                {
                    StatusTextBlock.Text = _viewModel.StatusMessage ?? "就绪";
                }
            };
        }

        // 窗口控制事件
        private void Window_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (e.LeftButton == MouseButtonState.Pressed)
            {
                this.DragMove();
            }
        }

        private void MinimizeButton_Click(object sender, RoutedEventArgs e)
        {
            this.WindowState = WindowState.Minimized;
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            Application.Current.Shutdown();
        }

        // 添加网站相关事件
        private async void AddWebsiteButton_Click(object sender, RoutedEventArgs e)
        {
            await AddWebsiteAsync();
        }

        private async void AddWebsiteTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                await AddWebsiteAsync();
            }
        }

        private async Task AddWebsiteAsync()
        {
            var url = AddWebsiteTextBox.Text?.Trim();
            if (await _viewModel.AddWebsiteAsync(url))
            {
                AddWebsiteTextBox.Clear();
                AddWebsiteTextBox.Focus();
            }
        }

        // 网站列表相关事件
        private void BlockToggle_Click(object sender, RoutedEventArgs e)
        {
            // ToggleButton的状态变化会自动触发数据绑定
            // ViewModel会处理IsBlocked属性的变化
        }

        private async void DeleteWebsiteButton_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag is Website website)
            {
                var result = MessageBox.Show(
                    $"确定要删除网站 '{website.DisplayName}' 吗？", 
                    "确认删除", 
                    MessageBoxButton.YesNo, 
                    MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    await _viewModel.RemoveWebsiteAsync(website);
                }
            }
        }

        // 重置按钮事件
        private async void ResetAllButton_Click(object sender, RoutedEventArgs e)
        {
            await _viewModel.ResetAllAsync();
        }

        // 窗口加载完成事件
        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            // 设置焦点到添加网站输入框
            AddWebsiteTextBox.Focus();
        }

        // 窗口关闭事件
        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            // 可以在这里添加保存确认逻辑
        }
    }
}
