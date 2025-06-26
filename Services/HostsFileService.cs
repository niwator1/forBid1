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

                await File.CopyAsync(_hostsFilePath, backupFilePath);
                
                // 清理旧备份文件（保留最新的10个）
                await CleanupOldBackupsAsync();

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
        private async Task CleanupOldBackupsAsync()
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

                // 添加主域名和www子域名
                sb.AppendLine($"{LOCALHOST_IP}\t{url}");
                if (!url.StartsWith("www."))
                {
                    sb.AppendLine($"{LOCALHOST_IP}\twww.{url}");
                }
            }

            sb.AppendLine(BLOCK_COMMENT_END);
            return sb.ToString();
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

                await File.CopyAsync(backupFilePath, _hostsFilePath, true);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"从备份恢复失败: {ex.Message}", ex);
            }
        }
    }

    /// <summary>
    /// File.CopyAsync 扩展方法
    /// </summary>
    public static class FileExtensions
    {
        public static async Task CopyAsync(string sourceFile, string destinationFile, bool overwrite = false)
        {
            using (var sourceStream = new FileStream(sourceFile, FileMode.Open, FileAccess.Read))
            using (var destinationStream = new FileStream(destinationFile, overwrite ? FileMode.Create : FileMode.CreateNew, FileAccess.Write))
            {
                await sourceStream.CopyToAsync(destinationStream);
            }
        }
    }
}
