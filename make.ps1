#!/usr/bin/env pwsh

# Clear screen and title
if ($Host.UI.RawUI -is [System.Management.Automation.Host.Coordinates]) {
    Clear-Host
    $host.UI.RawUI.WindowTitle = "powershell build system"
}

# Argument parsing
$nowait = $false
if ($args.Count -gt 0 -and $args[0] -eq "--no-wait") {
    $nowait = $true
}

# ANSI escape codes for colors
$ESC = "`e"
$RESET = "${ESC}[0m"
$RED = "${ESC}[31m"
$GREEN = "${ESC}[32m"
$YELLOW = "${ESC}[33m"
$CYAN = "${ESC}[36m"
$BANNER_COLOR = "${ESC}[1;94m"
$SUB_COLOR = "${ESC}[2;37m"

# Banner
Write-Host ""
Write-Host "$BANNER_COLOR"
Write-Host "           _           _       _        _           _ _     _                  _"
Write-Host "          | |         | |     | |      | |         (_) |   | |                | |"
Write-Host "   __ _   | |__   __ _| |_ ___| |__    | |__  _   _ _| | __| |   ___ _   _ ___| |_ ___ _ __ ___"
Write-Host "  / _\` |  | '_ \ / _\` | __/ __| '_ \   | '_ \| | | | | |/ _\` |  / __| | | / __| __/ _ \ '_ \` _ \\"
Write-Host " | (_| |  | |_) | (_| | |_| (__| | | |  | |_) | |_| | | | (_| |  \__ \ |_| \__ \ ||  __/ | | | | |"
Write-Host "  \__,_|  |_.__/ \__,_|\__\___|_| |_|  |_.__/ \__,_|_|_|\__,_|  |___/\__, |___/\__\___|_| |_| |_|"
Write-Host "                                                                  __/ |"
Write-Host "                                                                 |___/"
Write-Host "$RESET`n"

# Defaults
$execname = "main.exe"
$filelist = "filelist.txt"
$config = "config.txt"

# Check file list exists
if (-not (Test-Path $filelist)) {
    Write-Host "${RED}Error: File list '$filelist' is missing!$RESET"
    if (-not $nowait) {
        Read-Host -Prompt "${YELLOW}Press Enter to exit...$RESET"
    }
    exit 1
}

# Read config (first line only)
$flags = ""
if (Test-Path $config) {
    $flags = Get-Content $config -TotalCount 1
}

# Compile source files
$objFiles = @()
Get-Content $filelist | ForEach-Object {
    $src = $_.Trim()
    if ($src -eq "") { return }

    $obj = "$src.o"
    Write-Host "${CYAN}Compiling $src...$RESET"
    & g++ -c "$src" -o "$obj" $flags
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${RED}Error: Failed to compile $src$RESET"
        if (-not $nowait) {
            Read-Host -Prompt "${YELLOW}Press Enter to exit...$RESET"
        }
        exit 1
    }
    $objFiles += $obj
}

# Linking
Write-Host "${CYAN}Linking into '$execname'...$RESET"
& g++ -o "$execname" @objFiles
if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Error: Linking failed!$RESET"
    if (-not $nowait) {
        Read-Host -Prompt "${YELLOW}Press Enter to exit...$RESET"
    }
    exit 1
}

# Stripping binary
Write-Host "${CYAN}Stripping binary...$RESET"
& strip "$execname"

# Cleaning
Write-Host "${CYAN}Cleaning up...$RESET"
$objFiles | ForEach-Object { Remove-Item $_ -Force -ErrorAction SilentlyContinue }

# Done
Write-Host "${GREEN}Done!$RESET"
if (-not $nowait) {
    Start-Sleep -Seconds 2
}
