# 啟用調試模式
$DebugPreference = "Continue"


# 確保腳本以管理員身份運行
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "請以管理員身份運行此腳本"
    exit
}

# 檢查 .NET Framework 版本
Write-Host "檢查 .NET Framework 版本..." -ForegroundColor Yellow
$netFrameworkKey = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\"
if (Test-Path $netFrameworkKey) {
    $netFrameworkVersion = Get-ItemProperty -Path $netFrameworkKey | Select-Object -ExpandProperty Release
    Write-Host ".NET Framework 已安裝，版本號: $netFrameworkVersion" -ForegroundColor Green
}
else {
    Write-Host ".NET Framework 未安裝" -ForegroundColor Red
    Write-Host "請安裝 .NET Framework 4.5 或更新版本" -ForegroundColor Yellow
    Write-Host "下載地址: https://dotnet.microsoft.com/zh-tw/download/dotnet-framework" -ForegroundColor Yellow
    exit
}

# 確認是否開啟WSL功能
Write-Host "確認是否開啟WSL功能..." -ForegroundColor Yellow
$wslFeature = Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online
if ($wslFeature.State -eq "Enabled") {
    Write-Host "WSL 功能已開啟" -ForegroundColor Green
}
else {
    # 啟用 WSL 功能
    Write-Host "啟用 WSL 功能..." -ForegroundColor Yellow
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    Write-Host "WSL 功能已開啟" -ForegroundColor Green
}

# 確認是否開啟虛擬機器平台功能
Write-Host "確認是否開啟虛擬機器平台功能..." -ForegroundColor Yellow
$vmPlatformFeature = Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online
if ($vmPlatformFeature.State -eq "Enabled") {
    Write-Host "虛擬機器平台功能已開啟" -ForegroundColor Green
}
else {
    # 啟用虛擬機器平台功能（WSL 2 需要）
    Write-Host "啟用虛擬機器平台功能..." -ForegroundColor Yellow
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    Write-Host "虛擬機器平台功能已開啟" -ForegroundColor Green
}




Write-Host "檢查是否已經安裝 WSL 2 Linux 內核更新包..." -ForegroundColor Yellow 
Write-Host "請在新終端機輸入 wsl --version 確認是否已安裝 WSL 2 內核更新包。" -ForegroundColor Yellow

$wslKernelVersion = Read-Host "是否已經安裝 WSL 2 內核更新包？ (Y/N)"

if ($wslKernelVersion -eq "N" -or $wslKernelVersion -eq "n") {
    Write-Host "WSL 2 Linux 內核更新包未安裝" -ForegroundColor Red
    Write-Host "下載最新的 WSL 內核更新包..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile "$env:USERPROFILE\Downloads\wsl_update_x64.msi"
    Write-Host "WSL 內核更新包下載完成" -ForegroundColor Green
    # 安裝 WSL 內核更新包
    Write-Host "安裝 WSL 內核更新包..." -ForegroundColor Yellow
    Start-Process -FilePath "$env:USERPROFILE\Downloads\wsl_update_x64.msi" -ArgumentList "/quiet" -Wait
    Write-Host "WSL 內核更新包安裝完成" -ForegroundColor Green
}

# 設定 WSL 2 作為預設版本
Write-Host "設定 WSL 2 作為預設版本..."
wsl --set-default-version 2

# 提示使用者重啟
Write-Host "請重啟電腦以完成安裝。" -ForegroundColor Yellow