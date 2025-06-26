using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using 崔子瑾诱捕器.Models;

namespace 崔子瑾诱捕器.Services
{
    /// <summary>
    /// 配置管理服务
    /// </summary>
    public class ConfigService
    {
        private readonly string _configFilePath;
        private readonly string _configDirectory;
        private AppConfig _currentConfig;

        public ConfigService()
        {
            _configDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "崔子瑾诱捕器");
            _configFilePath = Path.Combine(_configDirectory, "config.json");
            
            // 确保配置目录存在
            Directory.CreateDirectory(_configDirectory);
        }

        /// <summary>
        /// 当前配置
        /// </summary>
        public AppConfig CurrentConfig => _currentConfig ??= new AppConfig();

        /// <summary>
        /// 加载配置
        /// </summary>
        public async Task<AppConfig> LoadConfigAsync()
        {
            try
            {
                if (File.Exists(_configFilePath))
                {
                    var json = await File.ReadAllTextAsync(_configFilePath, Encoding.UTF8);
                    _currentConfig = JsonConvert.DeserializeObject<AppConfig>(json) ?? new AppConfig();
                }
                else
                {
                    _currentConfig = new AppConfig();
                }

                return _currentConfig;
            }
            catch (Exception ex)
            {
                // 如果加载失败，返回默认配置
                _currentConfig = new AppConfig();
                return _currentConfig;
            }
        }

        /// <summary>
        /// 保存配置
        /// </summary>
        public async Task SaveConfigAsync(AppConfig config = null)
        {
            try
            {
                var configToSave = config ?? _currentConfig ?? new AppConfig();
                var json = JsonConvert.SerializeObject(configToSave, Formatting.Indented);
                await File.WriteAllTextAsync(_configFilePath, json, Encoding.UTF8);
                
                if (config != null)
                {
                    _currentConfig = config;
                }
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"保存配置失败: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// 验证密码
        /// </summary>
        public bool VerifyPassword(string inputPassword)
        {
            if (string.IsNullOrEmpty(CurrentConfig.Password))
            {
                // 如果没有设置密码，使用默认密码
                return inputPassword == "admin123";
            }

            try
            {
                var hashedInput = HashPassword(inputPassword);
                return hashedInput == CurrentConfig.Password;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// 设置密码
        /// </summary>
        public async Task SetPasswordAsync(string password)
        {
            try
            {
                CurrentConfig.Password = HashPassword(password);
                await SaveConfigAsync();
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"设置密码失败: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// 哈希密码
        /// </summary>
        private string HashPassword(string password)
        {
            using (var sha256 = SHA256.Create())
            {
                var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password + "崔子瑾诱捕器_salt"));
                return Convert.ToBase64String(hashedBytes);
            }
        }

        /// <summary>
        /// 重置配置
        /// </summary>
        public async Task ResetConfigAsync()
        {
            try
            {
                _currentConfig = new AppConfig();
                await SaveConfigAsync();
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"重置配置失败: {ex.Message}", ex);
            }
        }
    }
}
