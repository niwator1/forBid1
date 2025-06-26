using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace 崔子瑾诱捕器.Models
{
    /// <summary>
    /// 网站模型类
    /// </summary>
    public class Website : INotifyPropertyChanged
    {
        private string _url;
        private bool _isBlocked;
        private DateTime _addedDate;
        private DateTime? _lastModified;

        /// <summary>
        /// 网站URL
        /// </summary>
        public string Url
        {
            get => _url;
            set
            {
                if (_url != value)
                {
                    _url = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// 是否被阻止访问
        /// </summary>
        public bool IsBlocked
        {
            get => _isBlocked;
            set
            {
                if (_isBlocked != value)
                {
                    _isBlocked = value;
                    LastModified = DateTime.Now;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// 添加日期
        /// </summary>
        public DateTime AddedDate
        {
            get => _addedDate;
            set
            {
                if (_addedDate != value)
                {
                    _addedDate = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// 最后修改时间
        /// </summary>
        public DateTime? LastModified
        {
            get => _lastModified;
            set
            {
                if (_lastModified != value)
                {
                    _lastModified = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// 显示名称（用于UI显示）
        /// </summary>
        public string DisplayName => Url?.Replace("www.", "").Trim();

        /// <summary>
        /// 状态文本
        /// </summary>
        public string StatusText => IsBlocked ? "已阻止" : "允许访问";

        public Website()
        {
            AddedDate = DateTime.Now;
        }

        public Website(string url) : this()
        {
            Url = url;
        }

        public event PropertyChangedEventHandler PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public override string ToString()
        {
            return $"{Url} ({StatusText})";
        }

        public override bool Equals(object obj)
        {
            if (obj is Website other)
            {
                return string.Equals(Url, other.Url, StringComparison.OrdinalIgnoreCase);
            }
            return false;
        }

        public override int GetHashCode()
        {
            return Url?.ToLowerInvariant().GetHashCode() ?? 0;
        }
    }
}
