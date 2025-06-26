using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using System.Windows;
using 崔子瑾诱捕器.Models;
using 崔子瑾诱捕器.Services;

namespace 崔子瑾诱捕器.ViewModels
{
    /// <summary>
    /// 主窗口视图模型
    /// </summary>
    public class MainWindowViewModel : INotifyPropertyChanged
    {
        private readonly ConfigService _configService;
        private readonly HostsFileService _hostsFileService;
        private string _newWebsiteUrl;
        private string _statusMessage;

        public MainWindowViewModel()
        {
            _configService = new ConfigService();
            _hostsFileService = new HostsFileService();
            Websites = new ObservableCollection<Website>();

            // 订阅hosts文件变化事件
            _hostsFileService.HostsFileChanged += OnHostsFileChanged;

            // 加载配置
            LoadConfigAsync();
        }

        /// <summary>
        /// 网站列表
        /// </summary>
        public ObservableCollection<Website> Websites { get; }

        /// <summary>
        /// 新网站URL
        /// </summary>
        public string NewWebsiteUrl
        {
            get => _newWebsiteUrl;
            set
            {
                if (_newWebsiteUrl != value)
                {
                    _newWebsiteUrl = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// 状态消息
        /// </summary>
        public string StatusMessage
        {
            get => _statusMessage;
            set
            {
                if (_statusMessage != value)
                {
                    _statusMessage = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// 被阻止的网站数量
        /// </summary>
        public int BlockedCount => Websites.Count(w => w.IsBlocked);

        /// <summary>
        /// 加载配置
        /// </summary>
        private async void LoadConfigAsync()
        {
            try
            {
                StatusMessage = "正在加载配置...";
                
                var config = await _configService.LoadConfigAsync();
                
                // 清空现有列表
                Websites.Clear();
                
                // 添加配置中的网站
                foreach (var website in config.Websites)
                {
                    website.PropertyChanged += Website_PropertyChanged;
                    Websites.Add(website);
                }
                
                StatusMessage = "配置加载完成";
                OnPropertyChanged(nameof(BlockedCount));
            }
            catch (Exception ex)
            {
                StatusMessage = $"加载配置失败: {ex.Message}";
                MessageBox.Show($"加载配置失败: {ex.Message}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        /// <summary>
        /// 添加网站
        /// </summary>
        public async Task<bool> AddWebsiteAsync(string url)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(url))
                {
                    StatusMessage = "请输入网站地址";
                    return false;
                }

                // 清理URL
                url = CleanUrl(url);
                
                // 检查是否已存在
                if (Websites.Any(w => string.Equals(w.Url, url, StringComparison.OrdinalIgnoreCase)))
                {
                    StatusMessage = "该网站已存在";
                    return false;
                }

                // 创建新网站
                var website = new Website(url);
                website.PropertyChanged += Website_PropertyChanged;
                
                // 添加到列表
                Websites.Add(website);
                
                // 保存配置
                await SaveConfigAsync();
                
                StatusMessage = $"已添加网站: {url}";
                OnPropertyChanged(nameof(BlockedCount));
                
                return true;
            }
            catch (Exception ex)
            {
                StatusMessage = $"添加网站失败: {ex.Message}";
                MessageBox.Show($"添加网站失败: {ex.Message}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }

        /// <summary>
        /// 删除网站
        /// </summary>
        public async Task<bool> RemoveWebsiteAsync(Website website)
        {
            try
            {
                if (website == null) return false;

                // 从列表中移除
                website.PropertyChanged -= Website_PropertyChanged;
                Websites.Remove(website);
                
                // 保存配置
                await SaveConfigAsync();
                
                // 更新hosts文件
                await UpdateHostsFileAsync();
                
                StatusMessage = $"已删除网站: {website.Url}";
                OnPropertyChanged(nameof(BlockedCount));
                
                return true;
            }
            catch (Exception ex)
            {
                StatusMessage = $"删除网站失败: {ex.Message}";
                MessageBox.Show($"删除网站失败: {ex.Message}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }

        /// <summary>
        /// 重置所有设置
        /// </summary>
        public async Task<bool> ResetAllAsync()
        {
            try
            {
                var result = MessageBox.Show(
                    "确定要重置所有设置吗？\n这将清除所有网站列表并恢复hosts文件。", 
                    "确认重置", 
                    MessageBoxButton.YesNo, 
                    MessageBoxImage.Warning);

                if (result != MessageBoxResult.Yes)
                    return false;

                StatusMessage = "正在重置...";

                // 重置hosts文件
                await _hostsFileService.ResetHostsFileAsync();
                
                // 清空网站列表
                foreach (var website in Websites.ToList())
                {
                    website.PropertyChanged -= Website_PropertyChanged;
                }
                Websites.Clear();
                
                // 保存配置
                await SaveConfigAsync();
                
                StatusMessage = "重置完成";
                OnPropertyChanged(nameof(BlockedCount));
                
                MessageBox.Show("重置完成！", "成功", MessageBoxButton.OK, MessageBoxImage.Information);
                return true;
            }
            catch (Exception ex)
            {
                StatusMessage = $"重置失败: {ex.Message}";
                MessageBox.Show($"重置失败: {ex.Message}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }

        /// <summary>
        /// 网站属性变化处理
        /// </summary>
        private async void Website_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            if (e.PropertyName == nameof(Website.IsBlocked))
            {
                try
                {
                    // 更新hosts文件
                    await UpdateHostsFileAsync();
                    
                    // 保存配置
                    await SaveConfigAsync();
                    
                    OnPropertyChanged(nameof(BlockedCount));
                    
                    var website = sender as Website;
                    StatusMessage = website.IsBlocked ? 
                        $"已阻止访问: {website.Url}" : 
                        $"已允许访问: {website.Url}";
                }
                catch (Exception ex)
                {
                    StatusMessage = $"更新失败: {ex.Message}";
                    MessageBox.Show($"更新hosts文件失败: {ex.Message}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        /// <summary>
        /// 更新hosts文件
        /// </summary>
        private async Task UpdateHostsFileAsync()
        {
            await _hostsFileService.UpdateHostsFileAsync(Websites.ToList());
        }

        /// <summary>
        /// 保存配置
        /// </summary>
        private async Task SaveConfigAsync()
        {
            _configService.CurrentConfig.Websites = Websites.ToList();
            await _configService.SaveConfigAsync();
        }

        /// <summary>
        /// 清理URL
        /// </summary>
        private string CleanUrl(string url)
        {
            if (string.IsNullOrWhiteSpace(url))
                return string.Empty;

            url = url.Trim().ToLowerInvariant();
            
            // 移除协议前缀
            url = url.Replace("http://", "").Replace("https://", "");
            
            // 移除www前缀
            if (url.StartsWith("www."))
                url = url.Substring(4);
            
            // 移除路径部分
            var slashIndex = url.IndexOf('/');
            if (slashIndex > 0)
                url = url.Substring(0, slashIndex);
            
            return url;
        }

        /// <summary>
        /// hosts文件变化事件处理
        /// </summary>
        private void OnHostsFileChanged(object sender, string message)
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                StatusMessage = message;
            });
        }

        public event PropertyChangedEventHandler PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
