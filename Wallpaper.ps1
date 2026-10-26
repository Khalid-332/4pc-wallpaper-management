
# 4-PC Wallpaper Management Project
# Downloads and applies wallpaper for the current user

$ErrorActionPreference = "Stop"

$WallpaperURL = "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1920&q=80"
$WallpaperPath = "$env:LOCALAPPDATA\4PCProject\wallpaper.jpg"

try {
    New-Item -ItemType Directory `
        -Path (Split-Path $WallpaperPath) `
        -Force | Out-Null

    Invoke-WebRequest -Uri $WallpaperURL `
        -OutFile $WallpaperPath `
        -ErrorAction Stop

    # Verify the downloaded file is a valid image
    Add-Type -AssemblyName System.Drawing
    $Image = [System.Drawing.Image]::FromFile($WallpaperPath)
    $Image.Dispose()

    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Desktop" `
        -Name Wallpaper `
        -Value $WallpaperPath

    if (-not ("WallpaperAPI" -as [type])) {
        Add-Type @'
using System.Runtime.InteropServices;
public class WallpaperAPI {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(
        int action, int param, string path, int flags);
}
'@
    }

    $Result = [WallpaperAPI]::SystemParametersInfo(
        20, 0, $WallpaperPath, 3
    )

    if ($Result -eq 0) {
        throw "Windows could not apply the wallpaper."
    }

    Write-Host "SUCCESS: Wallpaper downloaded and applied." `
        -ForegroundColor Green
}
catch {
    Write-Host "FAILED: $($_.Exception.Message)" `
        -ForegroundColor Red
}
