# 网站阻止器 - 轻量版
# 无需安装任何软件，直接运行

param([string]$Action = "main")

# 检查管理员权限
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "需要管理员权限运行此脚本" -ForegroundColor Red
    Write-Host "请右键点击 PowerShell 并选择'以管理员身份运行'" -ForegroundColor Yellow
    Read-Host "按回车键退出"
    exit 1
}

# 配置
$HostsFile = "C:\Windows\System32\drivers\etc\hosts"
$ConfigDir = "$env:APPDATA\WebsiteBlocker"
$ConfigFile = "$ConfigDir\sites.txt"
$BackupDir = "$ConfigDir\Backups"
$BlockMarker = "# WebsiteBlocker"

# 创建目录
if (-not (Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null }
if (-not (Test-Path $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null }

# 备份hosts文件
function Backup-Hosts {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "$BackupDir\hosts_$timestamp.txt"
    Copy-Item $HostsFile $backupFile
    
    # 保留最新5个备份
    Get-ChildItem "$BackupDir\hosts_*.txt" | Sort-Object CreationTime -Descending | Select-Object -Skip 5 | Remove-Item
    
    Write-Host "已备份到: $backupFile" -ForegroundColor Green
}

# 读取网站列表
function Get-BlockedSites {
    if (Test-Path $ConfigFile) {
        return Get-Content $ConfigFile | Where-Object { $_ -and $_ -notmatch "^#" }
    }
    return @()
}

# 保存网站列表
function Save-BlockedSites {
    param($sites)
    $sites | Set-Content $ConfigFile -Encoding UTF8
}

# 更新hosts文件
function Update-Hosts {
    param($sites)
    
    Backup-Hosts
    
    # 读取现有hosts内容
    $content = Get-Content $HostsFile
    
    # 移除旧的阻止条目
    $newContent = $content | Where-Object { $_ -notmatch $BlockMarker }
    
    # 添加新的阻止条目
    if ($sites.Count -gt 0) {
        $newContent += ""
        $newContent += "$BlockMarker - Start"
        foreach ($site in $sites) {
            $cleanSite = $site.Trim().ToLower() -replace "^https?://" -replace "^www\." -replace "/.*$"
            if ($cleanSite) {
                $newContent += "127.0.0.1`t$cleanSite $BlockMarker"
                $newContent += "127.0.0.1`twww.$cleanSite $BlockMarker"
            }
        }
        $newContent += "$BlockMarker - End"
    }
    
    # 写入hosts文件
    $newContent | Set-Content $HostsFile -Encoding UTF8
    Write-Host "hosts文件已更新" -ForegroundColor Green
}

# 显示主菜单
function Show-Menu {
    Clear-Host
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "       网站访问阻止器" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
    
    $sites = Get-BlockedSites
    
    Write-Host "当前阻止的网站:" -ForegroundColor Yellow
    if ($sites.Count -eq 0) {
        Write-Host "  (无)" -ForegroundColor Gray
    } else {
        for ($i = 0; $i -lt $sites.Count; $i++) {
            Write-Host "  $($i+1). $($sites[$i])" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "操作选项:" -ForegroundColor Yellow
    Write-Host "  1. 添加网站" -ForegroundColor White
    Write-Host "  2. 删除网站" -ForegroundColor White
    Write-Host "  3. 清空所有" -ForegroundColor White
    Write-Host "  4. 刷新DNS" -ForegroundColor White
    Write-Host "  5. 查看备份" -ForegroundColor White
    Write-Host "  6. 退出" -ForegroundColor White
    Write-Host ""
}

# 添加网站
function Add-Site {
    $sites = Get-BlockedSites
    Write-Host ""
    $newSite = Read-Host "输入要阻止的网站 (例如: facebook.com)"
    
    if ([string]::IsNullOrWhiteSpace($newSite)) {
        Write-Host "网站地址不能为空" -ForegroundColor Red
        return
    }
    
    $cleanSite = $newSite.Trim().ToLower() -replace "^https?://" -replace "^www\." -replace "/.*$"
    
    if ($sites -contains $cleanSite) {
        Write-Host "网站已存在: $cleanSite" -ForegroundColor Yellow
        return
    }
    
    $sites += $cleanSite
    Save-BlockedSites $sites
    Update-Hosts $sites
    Write-Host "已添加: $cleanSite" -ForegroundColor Green
}

# 删除网站
function Remove-Site {
    $sites = Get-BlockedSites
    if ($sites.Count -eq 0) {
        Write-Host "没有网站可删除" -ForegroundColor Yellow
        return
    }
    
    Write-Host ""
    $index = Read-Host "输入要删除的网站编号 (1-$($sites.Count))"
    
    try {
        $index = [int]$index - 1
        if ($index -ge 0 -and $index -lt $sites.Count) {
            $removedSite = $sites[$index]
            $sites = $sites | Where-Object { $_ -ne $removedSite }
            Save-BlockedSites $sites
            Update-Hosts $sites
            Write-Host "已删除: $removedSite" -ForegroundColor Green
        } else {
            Write-Host "无效的编号" -ForegroundColor Red
        }
    } catch {
        Write-Host "请输入有效数字" -ForegroundColor Red
    }
}

# 清空所有
function Clear-All {
    Write-Host ""
    $confirm = Read-Host "确定要清空所有阻止的网站吗? (y/N)"
    if ($confirm -eq "y" -or $confirm -eq "Y") {
        Save-BlockedSites @()
        Update-Hosts @()
        Write-Host "已清空所有网站" -ForegroundColor Green
    }
}

# 刷新DNS
function Flush-DNS {
    Write-Host ""
    Write-Host "正在刷新DNS缓存..." -ForegroundColor Yellow
    ipconfig /flushdns | Out-Null
    Write-Host "DNS缓存已刷新" -ForegroundColor Green
}

# 查看备份
function Show-Backups {
    Write-Host ""
    $backups = Get-ChildItem "$BackupDir\hosts_*.txt" | Sort-Object CreationTime -Descending
    if ($backups.Count -eq 0) {
        Write-Host "没有备份文件" -ForegroundColor Yellow
    } else {
        Write-Host "备份文件:" -ForegroundColor Yellow
        for ($i = 0; $i -lt $backups.Count; $i++) {
            Write-Host "  $($i+1). $($backups[$i].Name) - $($backups[$i].CreationTime)" -ForegroundColor White
        }
        Write-Host ""
        $choice = Read-Host "输入编号查看备份内容，或按回车返回"
        if ($choice -match "^\d+$") {
            $index = [int]$choice - 1
            if ($index -ge 0 -and $index -lt $backups.Count) {
                Write-Host ""
                Write-Host "备份内容:" -ForegroundColor Yellow
                Get-Content $backups[$index].FullName | Select-Object -First 20
                if ((Get-Content $backups[$index].FullName).Count -gt 20) {
                    Write-Host "... (显示前20行)" -ForegroundColor Gray
                }
            }
        }
    }
}

# 主程序
function Main {
    do {
        Show-Menu
        $choice = Read-Host "请选择操作 (1-6)"
        
        switch ($choice) {
            "1" { Add-Site }
            "2" { Remove-Site }
            "3" { Clear-All }
            "4" { Flush-DNS }
            "5" { Show-Backups }
            "6" { 
                Write-Host ""
                Write-Host "再见!" -ForegroundColor Green
                exit 0 
            }
            default { 
                Write-Host ""
                Write-Host "无效选择" -ForegroundColor Red 
            }
        }
        
        if ($choice -ne "6") {
            Write-Host ""
            Read-Host "按回车继续"
        }
    } while ($true)
}

# 启动
Main
