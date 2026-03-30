#requires -Version 5.1
# ============================================================
#  WINDOWMASTER INSTALLER + ENGINE (UNIFIED BUILD)
#  Author : Mike's Unboxing
#  Name   : WindowMaster - Window Layout Anchor
#  Version: 1.0.0
# ============================================================

param(
    [switch]$SkipMenu  # internal use only
)

$ErrorActionPreference = "Stop"

# ============================================================
#  SECTION 1 — ASCII UI FRAMEWORK
# ============================================================

function Get-ConsoleInnerWidth {
    try {
        $w = $Host.UI.RawUI.WindowSize.Width
        if ($w -gt 10) { return $w - 4 }
    } catch {}
    return 80
}

function Resize-Console {
    try {
        $ui = $Host.UI.RawUI
        $targetWidth  = 90
        $targetHeight = 35

        $width  = [Math]::Min($targetWidth,  $ui.MaxWindowSize.Width)
        $height = [Math]::Min($targetHeight, $ui.MaxWindowSize.Height)

        if ($width  -lt 80) { $width  = $ui.MaxWindowSize.Width }
        if ($height -lt 25) { $height = $ui.MaxWindowSize.Height }

        $ui.WindowSize = New-Object System.Management.Automation.Host.Size($width, $height)
        $ui.BufferSize = New-Object System.Management.Automation.Host.Size($width, 2000)
    } catch {}
}

function Pad {
    param([string]$Text)
    return (" " * 3) + $Text
}

function Write-Pad {
    param(
        [string]$Text,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    Write-Host (Pad $Text) -ForegroundColor $Color
}

function Write-MenuOption {
    param(
        [int]$Number,
        [string]$Text
    )
    $prefix = Pad("$Number. ")
    Write-Host $prefix -NoNewline -ForegroundColor Green
    Write-Host $Text -ForegroundColor White
}

function Show-Header {
    Resize-Console

    $lines = @(
        @{ Text = "WindowMaster Setup"; Color = "DarkYellow" }   # Orange-ish
        @{ Text = "Window Layout Anchor & Monitor Wake Engine"; Color = "Yellow" }
        @{ Text = "Copyright (c) 2026 Mike's Unboxing."; Color = "White" }
        @{ Text = "All Rights Reserved. For Personal & Non Profit Use Only."; Color = "White" }
    )

    $innerWidth = Get-ConsoleInnerWidth
    if ($innerWidth -lt 40) { $innerWidth = 40 }
    $border = "-" * $innerWidth

    Clear-Host
    Write-Host ""
    Write-Host (" +" + $border + "+") -ForegroundColor Cyan

    foreach ($line in $lines) {
        $pad = [math]::Floor(($innerWidth - $line.Text.Length) / 2)
        if ($pad -lt 0) { $pad = 0 }

        $spaces = " " * $innerWidth
        Write-Host (" |" + $spaces + "|") -ForegroundColor Cyan -NoNewline

        $cursor = $Host.UI.RawUI.CursorPosition
        $cursor.X = 2 + $pad
        $Host.UI.RawUI.CursorPosition = $cursor

        Write-Host $line.Text -ForegroundColor $line.Color
    }

    Write-Host (" +" + $border + "+") -ForegroundColor Cyan
    Write-Host ""
}

function Show-SectionBox {
    param([string]$Title)

    $innerWidth = [Math]::Max($Title.Length + 4, 30)
    $border = "-" * $innerWidth

    Write-Host (" +" + $border + "+") -ForegroundColor Cyan
    $pad = [math]::Floor(($innerWidth - $Title.Length) / 2)
    if ($pad -lt 0) { $pad = 0 }
    $spaces = " " * $innerWidth
    Write-Host (" |" + $spaces + "|") -ForegroundColor Cyan -NoNewline
    $cursor = $Host.UI.RawUI.CursorPosition
    $cursor.X = 2 + $pad
    $Host.UI.RawUI.CursorPosition = $cursor
    Write-Host $Title -ForegroundColor Yellow
    Write-Host (" +" + $border + "+") -ForegroundColor Cyan
    Write-Host ""
}

function Show-DisclaimerBox {
    Resize-Console

    $title = "[DISCLAIMER]"
    $lines = @(
        "This utility restores window positions after monitor sleep and wake.",
        "It makes changes to window layouts only.",
        "The author assumes no liability for data loss or hardware issues."
    )

    $innerWidth = Get-ConsoleInnerWidth
    $maxLen = ($lines + $title | Measure-Object Length -Maximum).Maximum
    if ($innerWidth -lt ($maxLen + 4)) { $innerWidth = $maxLen + 4 }
    if ($innerWidth -lt 40) { $innerWidth = 40 }
    $border = "-" * $innerWidth

    Write-Host (" +" + $border + "+") -ForegroundColor Cyan

    $pad = [math]::Floor(($innerWidth - $title.Length) / 2)
    if ($pad -lt 0) { $pad = 0 }
    $spaces = " " * $innerWidth
    Write-Host (" |" + $spaces + "|") -ForegroundColor Cyan -NoNewline
    $cursor = $Host.UI.RawUI.CursorPosition
    $cursor.X = 2 + $pad
    $Host.UI.RawUI.CursorPosition = $cursor
    Write-Host $title -ForegroundColor Yellow

    foreach ($line in $lines) {
        $pad = [math]::Floor(($innerWidth - $line.Length) / 2)
        if ($pad -lt 0) { $pad = 0 }
        $spaces = " " * $innerWidth
        Write-Host (" |" + $spaces + "|") -ForegroundColor Cyan -NoNewline
        $cursor = $Host.UI.RawUI.CursorPosition
        $cursor.X = 2 + $pad
        $Host.UI.RawUI.CursorPosition = $cursor
        Write-Host $line -ForegroundColor White
    }

    Write-Host (" +" + $border + "+") -ForegroundColor Cyan
    Write-Host ""
}

function Show-ContactFooter {
    Write-Host "[" -NoNewline -ForegroundColor Cyan
    Write-Host "CONTACT & SUPPORT" -NoNewline -ForegroundColor White
    Write-Host "]" -ForegroundColor Cyan

    Write-Host "[ YouTube  ]  " -NoNewline -ForegroundColor Cyan
    Write-Host "https://youtube.com/mikesunboxing" -ForegroundColor Yellow

    Write-Host "[ Discord  ]  " -NoNewline -ForegroundColor Cyan
    Write-Host "https://discord.gg/XtBTGQ6BDu" -ForegroundColor Yellow

    Write-Host "[ Patreon  ]  " -NoNewline -ForegroundColor Cyan
    Write-Host "https://patreon.com/mikesunboxing" -ForegroundColor Yellow

    Write-Host "[ PayPal   ]  " -NoNewline -ForegroundColor Cyan
    Write-Host "https://paypal.me/mikesunboxing" -ForegroundColor Yellow

    Write-Host ""
}

# ============================================================
#  SECTION 2 — INSTALLER CONFIG + UTILITIES
# ============================================================

$AppName        = "WindowMaster"
$BasePath       = Join-Path $env:LOCALAPPDATA $AppName
$MainScriptPath = Join-Path $BasePath "WindowMaster.ps1"
$VbsPath        = Join-Path $BasePath "WindowMaster_Silent.vbs"
$LogPath        = Join-Path $BasePath "WM_Debug.log"
$ConfigPath     = Join-Path $BasePath "WM_Config.json"
$AdaptiveFile   = Join-Path $BasePath "WM_WakeProfile.json"

$TaskFolderPath = "\$AppName\"
$TaskNameMain   = "$AppName-MainLoop"
$TaskNameLogon  = "$AppName-Logon"

$EngineMarkerLine = "# WM_ENGINE_START"

function Ensure-Folder {
    if (-not (Test-Path $BasePath)) {
        New-Item -Path $BasePath -ItemType Directory -Force | Out-Null
    }
}

function Write-Log {
    param([string]$Message)
    try {
        Ensure-Folder
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $line = "[$timestamp] [INSTALLER] $Message"
        Add-Content -Path $LogPath -Value $line
    } catch {}
}

function Load-Config {
    if (Test-Path $ConfigPath) {
        try {
            return (Get-Content $ConfigPath -Raw | ConvertFrom-Json)
        } catch {
            Write-Log "Failed to load config, using defaults."
        }
    }
    return [PSCustomObject]@{
        Mode             = "Adaptive"
        WakeDelay        = 5
        IntervalMinutes  = 2
        AcceptDisclaimer = $false
    }
}

function Save-Config($cfg) {
    try {
        $cfg | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigPath -Encoding UTF8
        Write-Log "Config saved: Mode=$($cfg.Mode), Delay=$($cfg.WakeDelay), IntervalMinutes=$($cfg.IntervalMinutes)"
    } catch {
        Write-Log "Failed to save config: $($_.Exception.Message)"
    }
}

function Reset-AdaptiveData {
    if (Test-Path $AdaptiveFile) {
        Remove-Item $AdaptiveFile -Force
        Write-Pad "Adaptive learning data reset."
        Write-Log "Adaptive data reset by user."
    } else {
        Write-Pad "No adaptive data file found."
    }
}

function Get-ActiveSchemeGuid {
    $raw = powercfg /getactivescheme 2>$null
    if (-not $raw) { return $null }
    $match = [regex]::Match($raw, 'GUID:\s+([0-9a-fA-F\-]+)')
    if ($match.Success) { return $match.Groups[1].Value }
    return $null
}

function Get-DisplayTimeout {
    $scheme = Get-ActiveSchemeGuid
    if (-not $scheme) { return $null }

    $subgroup = "7516b95f-f776-4464-8c53-06167f40cc99"
    $setting  = "3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"

    $raw = powercfg /q $scheme $subgroup $setting 2>$null
    if (-not $raw) { return $null }

    $acLine = $raw | Select-String "AC Power Setting Index"
    $dcLine = $raw | Select-String "DC Power Setting Index"

    $ac = $acLine.ToString().Split(':')[-1].Trim()
    $dc = $dcLine.ToString().Split(':')[-1].Trim()

    return [PSCustomObject]@{
        AC = [math]::Round([int]$ac / 60, 2)
        DC = [math]::Round([int]$dc / 60, 2)
    }
}

function Get-SystemSleepTimeout {
    $scheme = Get-ActiveSchemeGuid
    if (-not $scheme) { return $null }

    $subgroup = "238c9fa8-0aad-41ed-83f4-97be242c8f20"
    $setting  = "29f6c1db-86da-48c5-9fdb-f2b67b1f44da"

    $raw = powercfg /q $scheme $subgroup $setting 2>$null
    if (-not $raw) { return $null }

    $acLine = $raw | Select-String "AC Power Setting Index"
    $dcLine = $raw | Select-String "DC Power Setting Index"

    $ac = $acLine.ToString().Split(':')[-1].Trim()
    $dc = $dcLine.ToString().Split(':')[-1].Trim()

    return [PSCustomObject]@{
        AC = [math]::Round([int]$ac / 60, 2)
        DC = [math]::Round([int]$dc / 60, 2)
    }
}

function Get-ScreensaverTimeout {
    try {
        $val = (Get-ItemProperty "HKCU:\Control Panel\Desktop").ScreenSaveTimeOut
        if (-not $val) { return 0 }
        return [math]::Round([int]$val / 60, 2)
    } catch {
        return 0
    }
}

function Get-MonitorInfo {
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue | Out-Null
        $screens = [System.Windows.Forms.Screen]::AllScreens
        $list = @()
        foreach ($s in $screens) {
            $list += ("{0}x{1}" -f $s.Bounds.Width, $s.Bounds.Height)
        }
        return [PSCustomObject]@{
            Count       = $screens.Count
            Resolutions = ($list -join ", ")
        }
    } catch {
        return [PSCustomObject]@{
            Count       = 0
            Resolutions = "Unknown"
        }
    }
}

function Get-IsDesktopNoBattery {
    try {
        $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
        if (-not $bat) { return $true }
        return $false
    } catch {
        return $false
    }
}

function Get-RecommendedInterval {
    $display = Get-DisplayTimeout
    $sleep   = Get-SystemSleepTimeout
    $ss      = Get-ScreensaverTimeout

    $candidates = @()
    if ($ss -gt 0) { $candidates += $ss }
    if ($display -and $display.AC -gt 0) { $candidates += $display.AC }
    if ($display -and $display.DC -gt 0) { $candidates += $display.DC }
    if ($sleep -and $sleep.AC -gt 0) { $candidates += $sleep.AC }
    if ($sleep -and $sleep.DC -gt 0) { $candidates += $sleep.DC }

    $recommended = 2
    if ($candidates.Count -gt 0) {
        $min = ($candidates | Measure-Object -Minimum).Minimum
        $recommended = [math]::Max(1, [math]::Floor($min - 1))
    }

    return $recommended
}

function Show-ShortStatus {
    $cfg = Load-Config
    $mon = Get-MonitorInfo

    Write-Host "[STATUS]" -ForegroundColor Yellow
    Write-Host ("- Monitors : {0} connected" -f $mon.Count)
    Write-Host ("- Mode     : {0}" -f $cfg.Mode)
    Write-Host ("- Interval : {0} min" -f $cfg.IntervalMinutes)
    Write-Host ""
}

# ============================================================
#  SECTION 3 — INSTALLER MENUS
# ============================================================

function Ensure-DisclaimerAccepted {
    $cfg = Load-Config
    if ($cfg.AcceptDisclaimer) { return }

    while ($true) {
        Show-Header
        Show-DisclaimerBox
        Show-ContactFooter

        $answer = Read-Host (Pad "Do you agree to the terms above? [Y/N]")
        $answer = $answer.Trim().ToUpper()

        if ($answer -eq "Y") {
            $cfg.AcceptDisclaimer = $true
            Save-Config $cfg
            break
        } elseif ($answer -eq "N") {
            Write-Pad "You did not accept the terms. Exiting..."
            Start-Sleep -Seconds 2
            exit
        }
    }
}

function Run-InstallOrUpdate {
    $cfg = Load-Config

    # STEP 1: Mode selection
    Show-Header
    Show-SectionBox "[INSTALL / UPDATE]"

    Write-Pad "Choose restore mode:"
    Write-Pad "A) Adaptive (recommended)"
    Write-Pad "   - Learns your monitor wake behaviour over time."
    Write-Pad "   - Automatically adjusts the restore delay."
    Write-Pad "   - Best for multi-monitor and HDMI/DP setups."
    Write-Host ""
    Write-Pad "B) Manual (fixed delay)"
    Write-Pad "   - Uses a fixed delay before restoring windows."
    Write-Pad "   - Useful if your monitors wake consistently."
    Write-Pad "   - If restore fails, increase the delay by 1 or 2 seconds."
    Write-Host ""
    Show-ContactFooter

    $mode = Read-Host (Pad "Choose A or B")
    $mode = $mode.Trim().ToUpper()
    if ($mode -ne "A" -and $mode -ne "B") { $mode = "A" }
    $selectedMode = if ($mode -eq "A") { "Adaptive" } else { "Manual" }

    # STEP 2: Power timeouts + interval
    Show-Header
    Show-SectionBox "[POWER TIMEOUTS]"

    $display   = Get-DisplayTimeout
    $sleep     = Get-SystemSleepTimeout
    $ss        = Get-ScreensaverTimeout
    $isDesktop = Get-IsDesktopNoBattery

    Write-Pad ("Screensaver Timeout : {0} min" -f $ss)

    if ($display) {
        Write-Pad ("Monitor Sleep (AC)  : {0} min" -f $display.AC)
        if ($isDesktop) {
            Write-Pad "Monitor Sleep (DC)  : N/A"
        } else {
            Write-Pad ("Monitor Sleep (DC)  : {0} min" -f $display.DC)
        }
    }

    if ($sleep) {
        Write-Pad ("System Sleep (AC)   : {0} min" -f $sleep.AC)
        if ($isDesktop) {
            Write-Pad "System Sleep (DC)   : N/A"
        } else {
            Write-Pad ("System Sleep (DC)   : {0} min" -f $sleep.DC)
        }
    }

    $recommended = Get-RecommendedInterval
    Write-Host ""
    Write-Pad ("Recommended snapshot interval: {0} minutes" -f $recommended)
    Write-Pad "Set at least 1 minute lower than the earliest timeout."
    Write-Pad "Faster snapshots generally improve restore reliability."
    Write-Host ""
    Show-ContactFooter

    $intervalInput = Read-Host (Pad "Enter interval (or press Enter for recommended)")
    $interval = if ([string]::IsNullOrWhiteSpace($intervalInput)) { $recommended } else { [int]$intervalInput }

    # STEP 3: Wake delay (manual only)
    $wakeDelay = $cfg.WakeDelay
    if ($selectedMode -eq "Manual") {
        Show-Header
        Show-SectionBox "[MANUAL WAKE DELAY]"

        Write-Pad "Some monitors (especially HDMI/DP) take longer to wake."
        Write-Pad "If windows do not restore correctly, increase the delay."
        Write-Host ""
        Show-ContactFooter

        $wakeInput = Read-Host (Pad "Enter wake delay in seconds (default 5)")
        $wakeDelay = if ([string]::IsNullOrWhiteSpace($wakeInput)) { 5 } else { [int]$wakeInput }
    } else {
        $wakeDelay = 0
    }

    # Save config and install
    $cfg.Mode            = $selectedMode
    $cfg.IntervalMinutes = $interval
    $cfg.WakeDelay       = $wakeDelay
    Save-Config $cfg

    Ensure-Folder
    Write-EngineFromSelf
    Write-SilentVbs
    Ensure-TaskFolder
    Remove-ExistingTasks
    Register-MainLoopTask
    Register-LogonTask
    Create-Shortcut

    Show-Header
    Show-SectionBox "[CONFIGURATION SAVED]"
    Write-Pad ("Mode       : {0}" -f $selectedMode)
    if ($selectedMode -eq "Adaptive") {
        Write-Pad "Wake Delay : Auto (Adaptive)"
    } else {
        Write-Pad ("Wake Delay : {0} seconds" -f $wakeDelay)
    }
    Write-Pad ("Interval   : {0} minutes" -f $interval)
    Write-Host ""
    Show-ContactFooter
    Write-Pad "Press Enter to return to the main menu..."
    [void][System.Console]::ReadLine()
}

function Run-DiagnosticsInstaller {
    Show-Header
    Show-SectionBox "[INSTALLER DIAGNOSTICS]"

    $cfg      = Load-Config
    $mon      = Get-MonitorInfo
    $display  = Get-DisplayTimeout
    $sleep    = Get-SystemSleepTimeout
    $ss       = Get-ScreensaverTimeout
    $isDesktop = Get-IsDesktopNoBattery

    Write-Host "[MONITOR STATUS]" -ForegroundColor Yellow
    Write-Host ("- Monitors Detected : {0}" -f $mon.Count)
    Write-Host ("- Resolutions       : {0}" -f $mon.Resolutions)
    Write-Host ""

    Write-Host "[POWER TIMEOUTS]" -ForegroundColor Yellow
    Write-Host ("- Screensaver       : {0} min" -f $ss)
    if ($display) {
        Write-Host ("- Monitor Sleep (AC): {0} min" -f $display.AC)
        if ($isDesktop) {
            Write-Host "- Monitor Sleep (DC): N/A"
        } else {
            Write-Host ("- Monitor Sleep (DC): {0} min" -f $display.DC)
        }
    }
    if ($sleep) {
        Write-Host ("- System Sleep (AC) : {0} min" -f $sleep.AC)
        if ($isDesktop) {
            Write-Host "- System Sleep (DC) : N/A"
        } else {
            Write-Host ("- System Sleep (DC) : {0} min" -f $sleep.DC)
        }
    }
    Write-Host ""

    Write-Host "[CURRENT CONFIG]" -ForegroundColor Yellow
    Write-Host ("- Mode              : {0}" -f $cfg.Mode)
    Write-Host ("- Interval          : {0} min" -f $cfg.IntervalMinutes)
    if ($cfg.Mode -eq "Adaptive") {
        Write-Host "- Wake Delay        : Auto (Adaptive)"
    } else {
        Write-Host ("- Wake Delay        : {0} sec" -f $cfg.WakeDelay)
    }
    Write-Host ""

    Write-Host "[FILES]" -ForegroundColor Yellow
    foreach ($p in @($MainScriptPath,$VbsPath,$ConfigPath,$AdaptiveFile,$LogPath)) {
        $exists = if (Test-Path $p) { "Yes" } else { "No" }
        Write-Host ("- {0} : {1}" -f (Split-Path $p -Leaf), $exists)
    }
    Write-Host ""

    Write-Host "[LOG TAIL]" -ForegroundColor Yellow
    if (Test-Path $LogPath) {
        Get-Content $LogPath -Tail 20
    } else {
        Write-Host "- No log file yet."
    }
    Write-Host ""

    Show-ContactFooter
    Write-Pad "Press Enter to return to the main menu..."
    [void][System.Console]::ReadLine()
}

function Run-Uninstall {
    Show-Header
    Show-SectionBox "[UNINSTALL]"

    Write-Pad "Uninstalling WindowMaster..."
    Remove-ExistingTasks

    if (Test-Path $BasePath) {
        Remove-Item $BasePath -Recurse -Force
    }

    try {
        $desktop = [Environment]::GetFolderPath('Desktop')
        $shortcutPath = Join-Path $desktop "$AppName Setup.lnk"
        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
        }
    } catch {}

    Write-Pad "WindowMaster has been removed."
    Write-Host ""
    Show-ContactFooter
    Write-Pad "Press Enter to exit..."
    [void][System.Console]::ReadLine()
    exit
}

function Show-MainMenu {
    Show-Header
    Show-ShortStatus
    Show-SectionBox "[MAIN MENU]"

    Write-MenuOption 1 "Install / Update WindowMaster"
    Write-MenuOption 2 "Configure Mode / Interval"
    Write-MenuOption 3 "Reset Adaptive Learning Data"
    Write-MenuOption 4 "Diagnostics (Installer)"
    Write-MenuOption 5 "Uninstall WindowMaster"
    Write-MenuOption 6 "Exit"
    Write-Host ""
    Show-ContactFooter
}

function Run-InstallerMenu {
    Ensure-Folder
    Ensure-DisclaimerAccepted

    while ($true) {
        Show-MainMenu
        $choice = Read-Host (Pad "Select an option")

        switch ($choice) {
            "1" { Run-InstallOrUpdate }
            "2" { Run-InstallOrUpdate }
            "3" { Reset-AdaptiveData }
            "4" { Run-DiagnosticsInstaller }
            "5" { Run-Uninstall }
            "6" { break }
            default {
                Write-Pad "Invalid selection."
                Start-Sleep -Seconds 1
            }
        }
    }
}

# ============================================================
#  SECTION 4 — ENGINE EXTRACTION + TASKS
# ============================================================

function Write-EngineFromSelf {
    Write-Log "Extracting engine from combined script."

    $full = $MyInvocation.MyCommand.Definition
    if (-not $full) {
        Write-Log "Unable to read script definition for extraction."
        return
    }

    $idx = $full.IndexOf($EngineMarkerLine)
    if ($idx -lt 0) {
        Write-Log "Engine marker not found. Extraction aborted."
        return
    }

    $afterMarker = $full.Substring($idx)
    $newlineIdx  = $afterMarker.IndexOf("`n")
    if ($newlineIdx -ge 0) {
        $engine = $afterMarker.Substring($newlineIdx + 1)
    } else {
        $engine = ""
    }

    if ([string]::IsNullOrWhiteSpace($engine)) {
        Write-Log "Engine content appears empty after marker."
        return
    }

    Set-Content -Path $MainScriptPath -Value $engine -Encoding UTF8
    Write-Log "Engine written to: $MainScriptPath"
}

function Write-SilentVbs {
    $escaped = $MainScriptPath.Replace('"','""')
    $vbs = @"
Set oShell = CreateObject("WScript.Shell")
oShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""$escaped"" -RunLoop", 0, False
"@
    Set-Content -Path $VbsPath -Value $vbs -Encoding ASCII
    Write-Log "Created silent VBS launcher: $VbsPath"
}

function Ensure-TaskFolder {
    try {
        New-ScheduledTaskFolder -TaskPath $TaskFolderPath -ErrorAction SilentlyContinue | Out-Null
    } catch {}
}

function Remove-ExistingTasks {
    foreach ($name in @($TaskNameMain, $TaskNameLogon)) {
        Unregister-ScheduledTask -TaskName $name -TaskPath $TaskFolderPath -Confirm:$false -ErrorAction SilentlyContinue
    }
}

function Register-MainLoopTask {
    $action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$VbsPath`""
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
    $trigger.Repetition.Interval = (New-TimeSpan -Minutes 2)
    $trigger.Repetition.Duration = [TimeSpan]::MaxValue
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $TaskNameMain -TaskPath $TaskFolderPath -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    Write-Log "Registered main loop task: $TaskFolderPath$TaskNameMain"
}

function Register-LogonTask {
    $action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$VbsPath`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $TaskNameLogon -TaskPath $TaskFolderPath -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    Write-Log "Registered logon task: $TaskFolderPath$TaskNameLogon"
}

function Create-Shortcut {
    try {
        $ShortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "$AppName Setup.lnk"
        $WScript = New-Object -ComObject WScript.Shell
        $Shortcut = $WScript.CreateShortcut($ShortcutPath)

        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments  = "-NoProfile -ExecutionPolicy Bypass -Command `"irm 'https://raw.githubusercontent.com/Mikesunboxing/WindowMaster/main/WindowMaster.ps1' | iex`""
        $Shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,146"
        $Shortcut.WorkingDirectory = $BasePath
        $Shortcut.Description = "WindowMaster Setup / Configuration"
        $Shortcut.Save()

        Write-Log "Created desktop shortcut: $ShortcutPath"
    } catch {
        Write-Log "Failed to create shortcut: $($_.Exception.Message)"
    }
}

# ============================================================
#  SECTION 5 — ENTRY POINT (INSTALLER)
# ============================================================

if (-not $SkipMenu) {
    Run-InstallerMenu
    return
}

# ============================================================
# === WINDOWMASTER ENGINE (START OF ENGINE FILE) ============
# ============================ WM_ENGINE_START ===============
# ============================================================

param(
    [switch]$RunLoop,
    [switch]$Menu,
    [switch]$Diagnostics
)

$ErrorActionPreference = "Stop"

# ============================================================
#  SECTION 6 — ENGINE CONFIG + LOGGING
# ============================================================

$AppName      = "WindowMaster"
$BasePath     = Join-Path $env:LOCALAPPDATA $AppName
$ConfigPath   = Join-Path $BasePath "WM_Config.json"
$CsvPath      = Join-Path $BasePath "WM_Layout.csv"
$JsonPath     = Join-Path $BasePath "WM_Layout.json"
$AdaptiveFile = Join-Path $BasePath "WM_WakeProfile.json"
$LogPath      = Join-Path $BasePath "WM_Debug.log"
$Version      = "1.0.0"

function Trim-DebugLog {
    $maxLines = 5000
    if (Test-Path $LogPath) {
        $lines = Get-Content $LogPath -ErrorAction SilentlyContinue
        if ($lines.Count -gt $maxLines) {
            $lines[-$maxLines..-1] | Set-Content $LogPath -Encoding UTF8
        }
    }
}

function Write-Diag {
    param([string]$Message)
    Trim-DebugLog
    $stamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    "$stamp`t[ENGINE] $Message" | Add-Content $LogPath
}

function Load-ConfigEngine {
    if (Test-Path $ConfigPath) {
        try {
            return (Get-Content $ConfigPath -Raw | ConvertFrom-Json)
        } catch {
            Write-Diag "Failed to load config: $($_.Exception.Message)"
        }
    }
    return [PSCustomObject]@{
        Mode             = "Adaptive"
        WakeDelay        = 5
        IntervalMinutes  = 2
        AcceptDisclaimer = $false
    }
}

# ============================================================
#  SECTION 7 — ENGINE SNAPSHOT / RESTORE + ADAPTIVE
# ============================================================

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("user32.dll")]
    public static extern int GetSystemMetrics(int nIndex);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(
        IntPtr hWnd,
        IntPtr hWndInsertAfter,
        int X,
        int Y,
        int cx,
        int cy,
        uint uFlags
    );
}

public struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
}
"@

function Add-WakeSample {
    param([double]$Seconds)

    $list = @()
    if (Test-Path $AdaptiveFile) {
        try {
            $list = Get-Content $AdaptiveFile | ConvertFrom-Json
        } catch {}
    }

    $list += [PSCustomObject]@{
        Timestamp = (Get-Date)
        WakeTime  = $Seconds
    }

    if ($list.Count -gt 100) {
        $list = $list[-100..-1]
    }

    $list | ConvertTo-Json | Set-Content $AdaptiveFile
}

function Get-AdaptiveDelay {
    if (-not (Test-Path $AdaptiveFile)) {
        return 0
    }

    try {
        $data = Get-Content $AdaptiveFile | ConvertFrom-Json
        if (-not $data -or $data.Count -lt 5) { return 0 }

        $avg = ($data | Measure-Object -Property WakeTime -Average).Average
        return [math]::Round($avg * 0.6, 2)
    } catch {
        return 0
    }
}

function Wait-ForMonitors {
    $MaxWait = 30
    $Elapsed = 0
    $Start   = Get-Date

    Write-Diag "Waiting for monitors to become ready..."

    while ($Elapsed -lt $MaxWait) {
        $Width  = [User32]::GetSystemMetrics(0)
        $Height = [User32]::GetSystemMetrics(1)

        if ($Width -ge 800 -and $Height -ge 600) {
            $duration = (Get-Date) - $Start
            $seconds  = [math]::Round($duration.TotalSeconds, 2)
            Write-Diag "Monitors ready after $seconds seconds."
            Add-WakeSample -Seconds $seconds
            return
        }

        Start-Sleep -Seconds 1
        $Elapsed++
    }

    Write-Diag "Monitor wake timeout reached."
    Add-WakeSample -Seconds $MaxWait
}

function Invoke-Snapshot {
    try {
        Write-Diag "Snapshot operation started."

        $windows = @()

        Get-Process | Where-Object {
            $_.MainWindowHandle -ne 0 -and
            $_.MainWindowTitle  -ne "" -and
            [User32]::IsWindowVisible($_.MainWindowHandle)
        } | ForEach-Object {
            $rect = New-Object RECT
            if ([User32]::GetWindowRect($_.MainWindowHandle, [ref]$rect)) {
                $width  = $rect.Right  - $rect.Left
                $height = $rect.Bottom - $rect.Top

                if ($width -gt 0 -and $height -gt 0) {
                    $windows += [PSCustomObject]@{
                        Process = $_.ProcessName
                        Title   = $_.MainWindowTitle
                        X       = $rect.Left
                        Y       = $rect.Top
                        W       = $width
                        H       = $height
                    }
                }
            }
        }

        if ($windows.Count -gt 0) {
            $windows | Select-Object Process,Title,X,Y,W,H |
                Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8

            $obj = [PSCustomObject]@{
                Timestamp = Get-Date
                Version   = $Version
                Windows   = $windows
            }
            $obj | ConvertTo-Json -Depth 5 | Set-Content -Path $JsonPath -Encoding UTF8

            Write-Diag "Snapshot saved: $($windows.Count) windows."
        } else {
            Write-Diag "Snapshot found no visible windows."
        }
    } catch {
        Write-Diag "Snapshot ERROR: $($_.Exception.Message)"
    }
}

function Invoke-Restore {
    try {
        Write-Diag "Restore operation starting."

        $cfg = Load-ConfigEngine
        $mode     = $cfg.Mode
        $delay    = [int]$cfg.WakeDelay
        $interval = [int]$cfg.IntervalMinutes

        Write-Diag "Restore mode: $mode"
        Write-Diag "Configured wake delay: $delay"
        Write-Diag "IntervalMinutes: $interval"

        $adaptive = 0
        if ($mode -eq "Adaptive") {
            $adaptive = Get-AdaptiveDelay
            Write-Diag "Adaptive delay calculated: $adaptive"
        }

        if ($mode -eq "Adaptive" -and $adaptive -gt 0) {
            Write-Diag "Applying adaptive delay: $adaptive seconds."
            Start-Sleep -Seconds $adaptive
        } elseif ($mode -eq "Manual" -and $delay -gt 0) {
            Write-Diag "Applying manual delay: $delay seconds."
            Start-Sleep -Seconds $delay
        } else {
            Write-Diag "No wake delay applied."
        }

        Wait-ForMonitors

        if (-not (Test-Path $CsvPath)) {
            Write-Diag "Restore aborted: no CSV layout file found."
            return
        }

        $SavedData = Import-Csv $CsvPath
        Write-Diag "Restoring $($SavedData.Count) windows..."

        foreach ($Item in $SavedData) {
            Get-Process -Name $Item.Process -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.MainWindowHandle -ne 0) {
                    [User32]::SetWindowPos(
                        $_.MainWindowHandle,
                        [IntPtr]0,
                        [int]$Item.X,
                        [int]$Item.Y,
                        [int]$Item.W,
                        [int]$Item.H,
                        0x0040
                    ) | Out-Null
                }
            }
        }

        Write-Diag "Restore completed."
    } catch {
        Write-Diag "Restore ERROR: $($_.Exception.Message)"
    }
}

# ============================================================
#  SECTION 8 — ENGINE UI + DIAGNOSTICS
# ============================================================

function Show-EngineHeader {
    Resize-Console

    $lines = @(
        @{ Text = "WindowMaster Engine"; Color = "DarkYellow" }
        @{ Text = "Window Layout Anchor"; Color = "Yellow" }
        @{ Text = "Version $Version"; Color = "White" }
    )

    $innerWidth = Get-ConsoleInnerWidth
    if ($innerWidth -lt 40) { $innerWidth = 40 }
    $border = "-" * $innerWidth

    Clear-Host
    Write-Host ""
    Write-Host (" +" + $border + "+") -ForegroundColor Cyan

    foreach ($line in $lines) {
        $pad = [math]::Floor(($innerWidth - $line.Text.Length) / 2)
        if ($pad -lt 0) { $pad = 0 }
        $spaces = " " * $innerWidth
        Write-Host (" |" + $spaces + "|") -ForegroundColor Cyan -NoNewline
        $cursor = $Host.UI.RawUI.CursorPosition
        $cursor.X = 2 + $pad
        $Host.UI.RawUI.CursorPosition = $cursor
        Write-Host $line.Text -ForegroundColor $line.Color
    }

    Write-Host (" +" + $border + "+") -ForegroundColor Cyan
    Write-Host ""
}

function Show-EngineFooter {
    Show-ContactFooter
}

function Run-DiagnosticsEngine {
    Show-EngineHeader

    $cfg = Load-ConfigEngine
    Write-Host "[ENGINE CONFIG]" -ForegroundColor Yellow
    Write-Host ("- Mode              : {0}" -f $cfg.Mode)
    Write-Host ("- Wake Delay        : {0} sec" -f $cfg.WakeDelay)
    Write-Host ("- Interval          : {0} min" -f $cfg.IntervalMinutes)
    Write-Host ""

    Write-Host "[FILES]" -ForegroundColor Yellow
    foreach ($p in @($CsvPath,$JsonPath,$AdaptiveFile,$LogPath)) {
        $exists = if (Test-Path $p) { "Yes" } else { "No" }
        Write-Host ("- {0} : {1}" -f (Split-Path $p -Leaf), $exists)
    }
    Write-Host ""

    Write-Host "[LOG TAIL]" -ForegroundColor Yellow
    if (Test-Path $LogPath) {
        Get-Content $LogPath -Tail 20
    } else {
        Write-Host "- No log file yet."
    }
    Write-Host ""

    Show-EngineFooter
}

function Show-EngineMenu {
    Write-Host "[MAIN MENU]" -ForegroundColor Yellow
    Write-Host "  1. Take Snapshot Now"
    Write-Host "  2. Restore Layout Now"
    Write-Host "  3. Diagnostics"
    Write-Host "  4. View Log (tail)"
    Write-Host "  5. Exit"
    Write-Host ""
    Show-EngineFooter
}

function Run-EngineMenu {
    Show-EngineHeader
    while ($true) {
        Show-EngineMenu
        $choice = Read-Host "Select an option"
        switch ($choice) {
            "1" {
                Invoke-Snapshot
                Write-Host ""
                Write-Host "Snapshot taken." -ForegroundColor Green
                Write-Host ""
            }
            "2" {
                Invoke-Restore
                Write-Host ""
                Write-Host "Restore attempted." -ForegroundColor Green
                Write-Host ""
            }
            "3" {
                Run-DiagnosticsEngine
            }
            "4" {
                Write-Host ""
                Write-Host "Log tail:" -ForegroundColor Cyan
                Write-Host ""
                if (Test-Path $LogPath) {
                    Get-Content $LogPath -Tail 40
                } else {
                    Write-Host "No log file yet."
                }
                Write-Host ""
                Show-EngineFooter
            }
            "5" { break }
            default {
                Write-Host "Invalid selection." -ForegroundColor Yellow
                Write-Host ""
            }
        }
        if ($choice -ne "5") {
            Read-Host "Press Enter to return to menu" | Out-Null
            Show-EngineHeader
        }
    }
}

# ============================================================
#  SECTION 9 — ENGINE MAIN LOOP
# ============================================================

function Run-MainLoop {
    Write-Diag "Main loop started."
    while ($true) {
        Invoke-Snapshot
        Start-Sleep -Seconds 5
        Invoke-Restore

        $cfg = Load-ConfigEngine
        $interval = [int]$cfg.IntervalMinutes
        if ($interval -lt 1) { $interval = 1 }

        Write-Diag "Main loop sleeping for $interval minutes."
        Start-Sleep -Seconds ($interval * 60)
    }
}

# ============================================================
#  SECTION 10 — ENGINE ENTRY POINT
# ============================================================

try {
    if ($Diagnostics) {
        Run-DiagnosticsEngine
        return
    }

    if ($RunLoop) {
        Run-MainLoop
        return
    }

    if ($Menu -or $Host.Name -eq "ConsoleHost") {
        Run-EngineMenu
    } else {
        Run-MainLoop
    }
} catch {
    Write-Diag "Unhandled engine error: $($_.Exception.Message)"
}


    
