using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace 崔子瑾诱捕器.Models
{
    /// <summary>
    /// 应用程序配置类
    /// </summary>
    public class AppConfig : INotifyPropertyChanged
    {
        private string _password;
        private bool _rememberPassword;
        private bool _autoBackupHosts;
        private int _maxBackupFiles;
        private bool _showNotifications;
        private string _hostsFilePath;
        private List<Website> _websites;

        /// <summary>
        /// 应用程序密码（加密存储）
        /// </summary>
        public string Password
        {
            get => _password;
            set
            {
                if (_password != value)
                {
                    _password = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// 是否记住密码
        /// </summary>
        public bool RememberPassword
        {
            get => _rememberPassword;
            set
            {
                if (_rememberPassword != value)
                {
                    _rememberPassword = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// 是否自动备份hosts文件
        /// </summary>
        public bool AutoBackupHosts
        {
            get => _autoBackupHosts;
            set
            {
                if (_autoBackupHosts != value)
                {
                    _autoBackupHosts = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// 最大备份文件数量
        /// </summary>
        public int MaxBackupFiles
        {
            get => _maxBackupFiles;
            set
            {
                if (_maxBackupFiles != value)
                {
                    _maxBackupFiles = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// 是否显示通知
        /// </summary>
        public bool ShowNotifications
        {
            get => _showNotifications;
            set
            {
                if (_showNotifications != value)
                {
                    _showNotifications = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// hosts文件路径
        /// </summary>
        public string HostsFilePath
        {
            get => _hostsFilePath;
            set
            {
                if (_hostsFilePath != value)
                {
                    _hostsFilePath = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// 网站列表
        /// </summary>
        public List<Website> Websites
        {
            get => _websites;
            set
            {
                if (_websites != value)
                {
                    _websites = value;
                    OnPropertyChanged();
                }
            }
        }

        public AppConfig()
        {
            // 设置默认值
            RememberPassword = false;
            AutoBackupHosts = true;
            MaxBackupFiles = 10;
            ShowNotifications = true;
            HostsFilePath = @"C:\Windows\System32\drivers\etc\hosts";
            Websites = new List<Website>();
        }

        public event PropertyChangedEventHandler PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
