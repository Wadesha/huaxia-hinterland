# =============================================================
# Huaxia Hinterland - Publish Script
# -------------------------------------------------------------
# Usage: .\publish.ps1 [-RunPy "gen_destinations.py"] [-Message "xxx"] [-DryRun]
#
# What it does:
#   1. Optional: run a Python generator script
#   2. Scan all .html content pages, update CONTENT_PAGES in index.html
#   3. git add -> commit -> push
#
# Safety: only processes files allowed by .gitignore
# =============================================================

param(
    [string]$Message = "",
    [string]$RunPy = "",
    [switch]$SkipIndexRegen,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Write-Step($msg) { Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "   ok  $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "   !!  $msg" -ForegroundColor Yellow }
function Write-Done($msg) { Write-Host "`n===== $msg =====`n" -ForegroundColor Magenta }

# Step 0: Optional - run Python script
if ($RunPy) {
    Write-Step "Running generator: $RunPy"
    if (Test-Path $RunPy) {
        $py = (Get-Command python -ErrorAction SilentlyContinue)
        if (-not $py) { $py = (Get-Command py -ErrorAction SilentlyContinue) }
        if ($py) {
            & $py.Source $RunPy
            Write-OK "Done"
        } else { Write-Warn "python not found, skipping" }
    } else { Write-Warn "File not found: $RunPy" }
}

# Step 0.5: Auto-inject dense dark theme into content pages
Write-Step "Theme injection (dark dense)..."
$themeFile = "$PSScriptRoot\_dense_theme.css"
$themeInjected = 0
$themeSkipped = 0

if (Test-Path $themeFile) {
    $themeCss = [System.IO.File]::ReadAllText($themeFile, [System.Text.Encoding]::UTF8)
    $htmlFiles = Get-ChildItem -Path . -Filter '*.html' -File |
        Where-Object { $_.Name -ne 'index.html' } |
        Sort-Object Name

    foreach ($f in $htmlFiles) {
        $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)

        # Replace first <style>...</style> block with the latest theme
        $pattern = '(?s)(<style(?:\s[^>]*)?>).*?(</style>)'
        if ($content -match $pattern) {
            $newContent = [regex]::Replace($content, $pattern, {
                param($m) return $m.Groups[1].Value + "`r`n" + $themeCss.TrimEnd() + "`r`n" + $m.Groups[2].Value
            }, 1)
            if ($newContent -ne $content) {
                [System.IO.File]::WriteAllText($f.FullName, $newContent, [System.Text.Encoding]::UTF8)
                $themeInjected++
            } else {
                $themeSkipped++
            }
        }
    }
    Write-OK "Theme injected: $themeInjected | already had: $themeSkipped"
} else {
    Write-Warn "_dense_theme.css not found, skipping theme injection"
}

# Step 1: Scan HTML pages
Write-Step "Scanning content pages..."
$excludePattern = 'index|V1|V2|\u5bf9\u6bd4|\.tmp'

$rootPages = Get-ChildItem -Path . -Filter '*.html' -File |
    Where-Object { $_.Name -notmatch $excludePattern } |
    Sort-Object Name

$allPages = @()
foreach ($p in $rootPages) { $allPages += $p.Name }

Write-OK "Found $($allPages.Count) content pages"

# Step 2: Update CONTENT_PAGES in index.html
if (-not $SkipIndexRegen -and (Test-Path 'index.html')) {
    Write-Step "Updating CONTENT_PAGES in index.html..."

    $lines = foreach ($p in $allPages) { '  "' + $p + '",' }
    $newArray = "const CONTENT_PAGES = [`n" + ($lines -join "`n") + "`n];"

    $html = [System.IO.File]::ReadAllText("$(Resolve-Path 'index.html')", [System.Text.Encoding]::UTF8)
    $pattern = '(?s)const CONTENT_PAGES = \[.*?\];'
    $newHtml = [regex]::Replace($html, $pattern, $newArray)

    if ($newHtml -ne $html) {
        [System.IO.File]::WriteAllText("$(Resolve-Path 'index.html')", $newHtml, [System.Text.Encoding]::UTF8)
        Write-OK "CONTENT_PAGES updated ($($allPages.Count) items)"
    } else {
        Write-OK "CONTENT_PAGES already current"
    }
}

# Step 3: Git
Write-Step "Git status..."
$status = git status --short 2>$null

if (-not $status) {
    Write-Done "No changes to publish"
    return
}

$numChanges = ($status | Measure-Object -Line).Lines
Write-OK "$numChanges files changed"

if ($DryRun) {
    Write-Warn "[DRY RUN] Would commit:"
    $status | ForEach-Object { Write-Host "   $_" }
    Write-Done "Dry run complete"
    return
}

git add .

if (-not $Message) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm"
    $Message = "update: $numChanges files * $ts"
}

Write-Step "Commit: $Message"
git commit -m $Message

$hasRemote = git remote 2>$null
if ($hasRemote) {
    Write-Step "Pushing..."
    git push
    if ($LASTEXITCODE -eq 0) {
        Write-Done "Published! GitHub Pages will deploy in a few minutes."
    } else {
        Write-Warn "Push failed. Check remote and network."
    }
} else {
    Write-Warn "No remote configured."
    Write-Host "  Next: create empty repo on GitHub, then run:" -ForegroundColor DarkGray
    Write-Host "  git remote add origin https://github.com/Wadesha/huaxia-hinterland.git" -ForegroundColor DarkGray
    Write-Host "  git push -u origin main" -ForegroundColor DarkGray
}
