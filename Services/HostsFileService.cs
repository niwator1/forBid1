using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using 崔子瑾诱捕器.Models;

namespace 崔子瑾诱捕器.Services
{
    /// <summary>
    /// hosts文件操作服务
    /// </summary>
    public class HostsFileService
    {
        private const string BLOCK_COMMENT_START = "# === 崔子瑾诱捕器 开始 ===";
        private const string BLOCK_COMMENT_END = "# === 崔子瑾诱捕器 结束 ===";
        private const string LOCALHOST_IP = "127.0.0.1";

        private readonly string _hostsFilePath;
        private readonly string _backupDirectory;

        public HostsFileService(string hostsFilePath = null)
        {
            _hostsFilePath = hostsFilePath ?? @"C:\Windows\System32\drivers\etc\hosts";
            _backupDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "崔子瑾诱捕器", "Backups");

            // 确保备份目录存在
            PermissionService.EnsureBackupDirectory(_backupDirectory);
        }

        /// <summary>
        /// 检查hosts文件是否可访问
        /// </summary>
        public bool IsHostsFileAccessible()
        {
            return PermissionService.ValidateHostsFileAccess(_hostsFilePath);
        }

        /// <summary>
        /// 备份hosts文件
        /// </summary>
        public async Task<string> BackupHostsFileAsync()
        {
            try
            {
                var backupFileName = $"hosts_backup_{DateTime.Now:yyyyMMdd_HHmmss}.txt";
                var backupFilePath = Path.Combine(_backupDirectory, backupFileName);

                File.Copy(_hostsFilePath, backupFilePath);
                
                // 清理旧备份文件（保留最新的10个）
                CleanupOldBackupsAsync();

                return backupFilePath;
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"备份hosts文件失败: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// 清理旧备份文件
        /// </summary>
        private void CleanupOldBackupsAsync()
        {
            try
            {
                var backupFiles = Directory.GetFiles(_backupDirectory, "hosts_backup_*.txt")
                    .Select(f => new FileInfo(f))
                    .OrderByDescending(f => f.CreationTime)
                    .Skip(10)
                    .ToList();

                foreach (var file in backupFiles)
                {
                    file.Delete();
                }
            }
            catch
            {
                // 忽略清理错误
            }
        }

        /// <summary>
        /// 读取hosts文件内容
        /// </summary>
        public async Task<string> ReadHostsFileAsync()
        {
            try
            {
                return await File.ReadAllTextAsync(_hostsFilePath, Encoding.UTF8);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"读取hosts文件失败: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// 更新hosts文件
        /// </summary>
        public async Task UpdateHostsFileAsync(List<Website> websites)
        {
            try
            {
                // 先备份
                await BackupHostsFileAsync();

                // 读取现有内容
                var content = await ReadHostsFileAsync();
                
                // 移除之前的阻止条目
                content = RemoveBlockedEntries(content);
                
                // 添加新的阻止条目
                var blockedWebsites = websites.Where(w => w.IsBlocked).ToList();
                if (blockedWebsites.Any())
                {
                    var blockEntries = GenerateBlockEntries(blockedWebsites);
                    content = content.TrimEnd() + Environment.NewLine + Environment.NewLine + blockEntries;
                }

                // 写入文件
                await File.WriteAllTextAsync(_hostsFilePath, content, Encoding.UTF8);

                // 清理DNS缓存以确保更改立即生效
                FlushDnsCache();
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"更新hosts文件失败: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// 移除之前的阻止条目
        /// </summary>
        private string RemoveBlockedEntries(string content)
        {
            var lines = content.Split(new[] { Environment.NewLine }, StringSplitOptions.None).ToList();
            
            var startIndex = lines.FindIndex(line => line.Contains(BLOCK_COMMENT_START));
            var endIndex = lines.FindIndex(line => line.Contains(BLOCK_COMMENT_END));

            if (startIndex >= 0 && endIndex >= 0 && endIndex > startIndex)
            {
                lines.RemoveRange(startIndex, endIndex - startIndex + 1);
            }

            return string.Join(Environment.NewLine, lines);
        }

        /// <summary>
        /// 生成阻止条目
        /// </summary>
        private string GenerateBlockEntries(List<Website> blockedWebsites)
        {
            var sb = new StringBuilder();
            sb.AppendLine(BLOCK_COMMENT_START);
            sb.AppendLine($"# 由崔子瑾诱捕器自动生成 - {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            sb.AppendLine("#");

            foreach (var website in blockedWebsites)
            {
                var url = website.Url.ToLowerInvariant();

                // 移除协议前缀
                url = url.Replace("http://", "").Replace("https://", "");

                // 移除路径部分
                var slashIndex = url.IndexOf('/');
                if (slashIndex > 0)
                {
                    url = url.Substring(0, slashIndex);
                }

                // 移除端口号
                var colonIndex = url.IndexOf(':');
                if (colonIndex > 0)
                {
                    url = url.Substring(0, colonIndex);
                }

                // 生成更全面的阻止条目
                var domains = GenerateDomainsToBlock(url);
                foreach (var domain in domains)
                {
                    sb.AppendLine($"{LOCALHOST_IP}\t{domain}");
                }
            }

            sb.AppendLine(BLOCK_COMMENT_END);
            return sb.ToString();
        }

        /// <summary>
        /// 生成需要阻止的域名列表
        /// </summary>
        private List<string> GenerateDomainsToBlock(string domain)
        {
            var domains = new List<string>();

            // 添加原始域名
            domains.Add(domain);

            // 添加www子域名
            if (!domain.StartsWith("www."))
            {
                domains.Add($"www.{domain}");
            }

            // 添加常见子域名
            var commonSubdomains = new[]
            {
                "m", "mobile", "app", "api", "cdn", "static", "assets",
                "img", "images", "media", "video", "audio", "download",
                "mail", "email", "login", "auth", "account", "user",
                "admin", "dashboard", "panel", "console", "manage",
                "blog", "news", "support", "help", "docs", "wiki",
                "shop", "store", "pay", "payment", "checkout",
                "search", "analytics", "tracking", "ads", "ad"
            };

            foreach (var subdomain in commonSubdomains)
            {
                domains.Add($"{subdomain}.{domain}");
            }

            // 如果是知名网站，添加特定的子域名
            if (domain.Contains("youtube.com") || domain.Contains("youtu.be"))
            {
                domains.AddRange(new[]
                {
                    "youtube.com", "www.youtube.com", "m.youtube.com",
                    "youtu.be", "www.youtu.be",
                    "youtubei.googleapis.com", "youtube.googleapis.com",
                    "yt3.ggpht.com", "ytimg.com", "i.ytimg.com"
                });
            }
            else if (domain.Contains("facebook.com") || domain.Contains("fb.com"))
            {
                domains.AddRange(new[]
                {
                    "facebook.com", "www.facebook.com", "m.facebook.com",
                    "fb.com", "www.fb.com", "fbcdn.net", "facebook.net"
                });
            }
            else if (domain.Contains("twitter.com") || domain.Contains("x.com"))
            {
                domains.AddRange(new[]
                {
                    "twitter.com", "www.twitter.com", "mobile.twitter.com",
                    "x.com", "www.x.com", "t.co", "twimg.com"
                });
            }
            else if (domain.Contains("instagram.com"))
            {
                domains.AddRange(new[]
                {
                    "instagram.com", "www.instagram.com",
                    "cdninstagram.com", "instagramstatic-a.akamaihd.net"
                });
            }
            else if (domain.Contains("tiktok.com"))
            {
                domains.AddRange(new[]
                {
                    "tiktok.com", "www.tiktok.com", "m.tiktok.com",
                    "tiktokcdn.com", "musical.ly"
                });
            }

            return domains.Distinct().ToList();
        }

        /// <summary>
        /// 清理DNS缓存
        /// </summary>
        private void FlushDnsCache()
        {
            try
            {
                var process = new System.Diagnostics.Process
                {
                    StartInfo = new System.Diagnostics.ProcessStartInfo
                    {
                        FileName = "ipconfig",
                        Arguments = "/flushdns",
                        UseShellExecute = false,
                        RedirectStandardOutput = true,
                        CreateNoWindow = true
                    }
                };

                process.Start();
                process.WaitForExit();
            }
            catch
            {
                // 忽略DNS缓存清理错误
            }
        }

        /// <summary>
        /// 重置hosts文件（移除所有阻止条目）
        /// </summary>
        public async Task ResetHostsFileAsync()
        {
            try
            {
                // 先备份
                await BackupHostsFileAsync();

                // 读取现有内容并移除阻止条目
                var content = await ReadHostsFileAsync();
                content = RemoveBlockedEntries(content);

                // 写入文件
                await File.WriteAllTextAsync(_hostsFilePath, content, Encoding.UTF8);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"重置hosts文件失败: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// 获取备份文件列表
        /// </summary>
        public List<FileInfo> GetBackupFiles()
        {
            try
            {
                return Directory.GetFiles(_backupDirectory, "hosts_backup_*.txt")
                    .Select(f => new FileInfo(f))
                    .OrderByDescending(f => f.CreationTime)
                    .ToList();
            }
            catch
            {
                return new List<FileInfo>();
            }
        }

        /// <summary>
        /// 从备份恢复hosts文件
        /// </summary>
        public async Task RestoreFromBackupAsync(string backupFilePath)
        {
            try
            {
                if (!File.Exists(backupFilePath))
                {
                    throw new FileNotFoundException("备份文件不存在");
                }

                File.Copy(backupFilePath, _hostsFilePath, true);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"从备份恢复失败: {ex.Message}", ex);
            }
        }
    }


}
