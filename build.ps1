<#
    MQL5 Build Script for FuzzyLogicBasedOnTan
    Usage: .\build.ps1
#>

# --- CONFIGURATION ---
$CompilerPath = "C:\Program Files\MetaTrader 5\metaeditor64.exe"
$TargetFile   = "FuzzyLogicBasedOnTan.mq5"
$LogFile      = "compile.log"

# --- SETUP PATHS ---
$ScriptDir = $PSScriptRoot
$FullPathTarget = Join-Path $ScriptDir $TargetFile
$FullPathLog    = Join-Path $ScriptDir $LogFile

# --- VALIDATION ---
if (-not (Test-Path $CompilerPath)) {
    Write-Host "Error: MetaEditor not found at: $CompilerPath" -ForegroundColor Red
    Write-Host "Please edit build.ps1 to set the correct path."
    exit 1
}

if (-not (Test-Path $FullPathTarget)) {
    Write-Host "Error: Source file not found: $FullPathTarget" -ForegroundColor Red
    exit 1
}

# --- CLEANUP ---
if (Test-Path $FullPathLog) {
    Remove-Item $FullPathLog
}

# --- COMPILATION ---
Write-Host "Compiling [$TargetFile]..." -ForegroundColor Cyan

$StartInfo = New-Object System.Diagnostics.ProcessStartInfo
$StartInfo.FileName = $CompilerPath
$StartInfo.Arguments = "/compile:`"$FullPathTarget`" /log:`"$FullPathLog`""

$Process = Start-Process -FilePath $CompilerPath -ArgumentList $StartInfo.Arguments -Wait -PassThru

# --- RESULT ---
if (Test-Path $FullPathLog) {
    Write-Host "`n--- Build Log Output ---" -ForegroundColor Gray
    Get-Content $FullPathLog
    Write-Host "------------------------" -ForegroundColor Gray
    
    # Check for success pattern in log (MetaEditor doesn't always return useful exit codes)
    $LogContent = Get-Content $FullPathLog -Raw
    if ($LogContent -match "0 errors") {
        Write-Host "BUILD SUCCESSFUL" -ForegroundColor Green
    } elseif ($LogContent -match "errors") {
        Write-Host "BUILD FAILED" -ForegroundColor Red
    }
} else {
    Write-Host "Warning: No log file generated." -ForegroundColor Yellow
}
