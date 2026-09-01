<#
.SYNOPSIS
    Ironworks - Cross-platform skill installer for Windows.

.DESCRIPTION
    Installs Ironworks skills and rules into AI coding platforms.
    https://github.com/rmyndharis/ironworks-skills
    License: MIT - (c) 2026 Rahul Hulsure

.PARAMETER Platform
    Install for a specific platform, or "all" for every detected platform.

.PARAMETER Global
    Install to the user's home directory (where supported).

.PARAMETER Project
    Install to the current project directory (default).

.PARAMETER Uninstall
    Remove previously installed Ironworks files.

.PARAMETER DryRun
    Show what would be done without writing any files.

.PARAMETER List
    List supported platforms and exit.

.EXAMPLE
    .\install.ps1
    Auto-detect platforms and install to the current project.

.EXAMPLE
    .\install.ps1 -Platform cursor
    Install for Cursor only.

.EXAMPLE
    .\install.ps1 -Platform all -Global
    Install for all detected platforms to the home directory.

.EXAMPLE
    .\install.ps1 -Uninstall
    Remove installed Ironworks files.
#>

[CmdletBinding()]
param(
    [string]$Platform = "",
    [switch]$Global,
    [switch]$Project,
    [switch]$Uninstall,
    [switch]$DryRun,
    [switch]$List
)

# ---------------------------------------------------------------------------
# Resolve repo root from script location
# ---------------------------------------------------------------------------
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$PlatformsDir = Join-Path $ScriptDir "platforms"
$SkillsDir    = Join-Path $ScriptDir ".openclaw" "skills"
$PortableFile = Join-Path $PlatformsDir "ironworks-portable.md"

# ---------------------------------------------------------------------------
# Counters
# ---------------------------------------------------------------------------
$script:Installed = 0
$script:Skipped   = 0
$script:Errors    = 0

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
function Write-Info    { param([string]$Msg) Write-Host "[info]  $Msg" -ForegroundColor Cyan }
function Write-Ok      { param([string]$Msg) Write-Host "[ok]    $Msg" -ForegroundColor Green;  $script:Installed++ }
function Write-Skip    { param([string]$Msg) Write-Host "[skip]  $Msg" -ForegroundColor Yellow; $script:Skipped++ }
function Write-Err     { param([string]$Msg) Write-Host "[err]   $Msg" -ForegroundColor Red;    $script:Errors++ }
function Write-Heading { param([string]$Msg) Write-Host "`n$Msg" -ForegroundColor White -BackgroundColor DarkGray }

# ---------------------------------------------------------------------------
# Platform list
# ---------------------------------------------------------------------------
$AllPlatforms = @(
    "claude","cursor","copilot","windsurf","cline","gemini","codex","aider",
    "amazon-q","kiro","roo","continue","junie","trae","augment","kilo","antigravity"
)

if ($List) {
    Write-Host "Supported platforms:"
    Write-Host ("  " + ($AllPlatforms -join "  "))
    exit 0
}

# ---------------------------------------------------------------------------
# Scope
# ---------------------------------------------------------------------------
if ($Global) { $Scope = "global" } else { $Scope = "project" }

# ---------------------------------------------------------------------------
# File helpers
# ---------------------------------------------------------------------------
function Copy-SafeFile {
    param([string]$Src, [string]$Dst)
    if (-not (Test-Path $Src)) {
        Write-Err "Source not found: $Src"
        return
    }
    if ($DryRun) {
        Write-Ok "[dry-run] Would copy $(Split-Path -Leaf $Src) -> $Dst"
        return
    }
    $parent = Split-Path -Parent $Dst
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Copy-Item -Path $Src -Destination $Dst -Force
    Write-Ok "Copied $(Split-Path -Leaf $Src) -> $Dst"
}

function Copy-SafeDir {
    param([string]$Src, [string]$Dst)
    if (-not (Test-Path $Src)) {
        Write-Err "Source directory not found: $Src"
        return
    }
    if ($DryRun) {
        Write-Ok "[dry-run] Would copy directory $(Split-Path -Leaf $Src) -> $Dst"
        return
    }
    if (-not (Test-Path $Dst)) { New-Item -ItemType Directory -Path $Dst -Force | Out-Null }
    Copy-Item -Path "$Src\*" -Destination $Dst -Recurse -Force
    Write-Ok "Copied directory $(Split-Path -Leaf $Src) -> $Dst"
}

function Remove-SafeItem {
    param([string]$Target)
    if (-not (Test-Path $Target)) {
        Write-Skip "Not found (already clean): $Target"
        return
    }
    if ($DryRun) {
        Write-Ok "[dry-run] Would remove $Target"
        return
    }
    Remove-Item -Path $Target -Recurse -Force -Confirm:$false
    Write-Ok "Removed $Target"
}

# ---------------------------------------------------------------------------
# Platform detection
# ---------------------------------------------------------------------------
function Test-CmdExists { param([string]$Name) $null -ne (Get-Command $Name -ErrorAction SilentlyContinue) }

function Detect-Platform {
    param([string]$Name)
    switch ($Name) {
        "claude"      { return (Test-CmdExists "claude") }
        "cursor"      { return (Test-Path ".cursor") -or (Test-Path "$env:USERPROFILE\.cursor") }
        "copilot"     { return (Test-Path ".github") }
        "windsurf"    { return (Test-Path ".windsurf") -or (Test-Path "$env:USERPROFILE\.windsurf") }
        "cline"       { return (Test-Path ".cline") -or (Test-Path "$env:USERPROFILE\.cline") -or (Test-Path ".clinerules") }
        "gemini"      { return (Test-CmdExists "gemini") -or (Test-Path "$env:USERPROFILE\.gemini") }
        "codex"       { return (Test-CmdExists "codex") }
        "aider"       { return (Test-CmdExists "aider") }
        "amazon-q"    { return (Test-Path ".amazonq") -or (Test-Path "$env:USERPROFILE\.amazonq") }
        "kiro"        { return (Test-Path ".kiro") -or (Test-Path "$env:USERPROFILE\.kiro") }
        "roo"         { return (Test-Path ".roo") -or (Test-Path "$env:USERPROFILE\.roo") }
        "continue"    { return (Test-Path ".continue") -or (Test-Path "$env:USERPROFILE\.continue") }
        "junie"       { return (Test-Path ".junie") }
        "trae"        { return (Test-Path ".trae") -or (Test-Path "$env:USERPROFILE\.trae") }
        "augment"     { return (Test-Path ".augment") -or (Test-Path "$env:USERPROFILE\.augment") -or (Test-Path ".augment-guidelines") }
        "kilo"        { return (Test-Path ".kilo") -or (Test-Path "$env:USERPROFILE\.kilo") }
        "antigravity" { return (Test-Path ".agent") -or (Test-Path "$env:USERPROFILE\.agent") }
        default       { return $false }
    }
}

# ---------------------------------------------------------------------------
# Per-platform install / uninstall
# ---------------------------------------------------------------------------

# --- Claude ---
function Install-Claude {
    if ($Scope -eq "global") { $dst = Join-Path $env:USERPROFILE ".claude" "skills" }
    else                     { $dst = Join-Path "." ".openclaw" "skills" }
    if (Test-Path $SkillsDir) {
        foreach ($d in (Get-ChildItem -Path $SkillsDir -Directory)) {
            Copy-SafeDir $d.FullName (Join-Path $dst $d.Name)
        }
    } else { Write-Err "Skills directory not found: $SkillsDir" }
}
function Uninstall-Claude {
    if ($Scope -eq "global") { $dst = Join-Path $env:USERPROFILE ".claude" "skills" }
    else                     { $dst = Join-Path "." ".openclaw" "skills" }
    if (Test-Path $SkillsDir) {
        foreach ($d in (Get-ChildItem -Path $SkillsDir -Directory)) {
            Remove-SafeItem (Join-Path $dst $d.Name)
        }
    }
}

# --- Cursor ---
function Install-Cursor {
    $src = Join-Path $PlatformsDir "cursor" "rules" "ironworks-discipline.mdc"
    if ($Scope -eq "global") { $dst = Join-Path $env:USERPROFILE ".cursor" "rules" "ironworks-discipline.mdc" }
    else                     { $dst = Join-Path "." ".cursor" "rules" "ironworks-discipline.mdc" }
    Copy-SafeFile $src $dst
}
function Uninstall-Cursor {
    if ($Scope -eq "global") { $t = Join-Path $env:USERPROFILE ".cursor" "rules" "ironworks-discipline.mdc" }
    else                     { $t = Join-Path "." ".cursor" "rules" "ironworks-discipline.mdc" }
    Remove-SafeItem $t
}

# --- Copilot ---
function Install-Copilot {
    if ($Scope -eq "global") { Write-Skip "Copilot: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." ".github" "copilot-instructions.md")
}
function Uninstall-Copilot {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." ".github" "copilot-instructions.md")
}

# --- Windsurf ---
function Install-Windsurf {
    if ($Scope -eq "global") { Write-Skip "Windsurf: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." ".windsurf" "rules" "ironworks.md")
}
function Uninstall-Windsurf {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." ".windsurf" "rules" "ironworks.md")
}

# --- Cline ---
function Install-Cline {
    if ($Scope -eq "global") { Write-Skip "Cline: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." ".clinerules" "ironworks.md")
}
function Uninstall-Cline {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." ".clinerules" "ironworks.md")
}

# --- Gemini ---
function Install-Gemini {
    if ($Scope -eq "global") { Copy-SafeFile $PortableFile (Join-Path $env:USERPROFILE ".gemini" "GEMINI.md") }
    else                     { Copy-SafeFile $PortableFile (Join-Path "." "GEMINI.md") }
}
function Uninstall-Gemini {
    if ($Scope -eq "global") { Remove-SafeItem (Join-Path $env:USERPROFILE ".gemini" "GEMINI.md") }
    else                     { Remove-SafeItem (Join-Path "." "GEMINI.md") }
}

# --- Codex ---
function Install-Codex {
    if ($Scope -eq "global") { Copy-SafeFile $PortableFile (Join-Path $env:USERPROFILE ".codex" "AGENTS.md") }
    else                     { Copy-SafeFile $PortableFile (Join-Path "." "AGENTS.md") }
}
function Uninstall-Codex {
    if ($Scope -eq "global") { Remove-SafeItem (Join-Path $env:USERPROFILE ".codex" "AGENTS.md") }
    else                     { Remove-SafeItem (Join-Path "." "AGENTS.md") }
}

# --- Aider ---
function Install-Aider {
    if ($Scope -eq "global") { Write-Skip "Aider: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." "CONVENTIONS.md")
}
function Uninstall-Aider {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." "CONVENTIONS.md")
}

# --- Amazon Q ---
function Install-AmazonQ {
    if ($Scope -eq "global") { Write-Skip "Amazon Q: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." ".amazonq" "rules" "ironworks.md")
}
function Uninstall-AmazonQ {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." ".amazonq" "rules" "ironworks.md")
}

# --- Kiro ---
function Install-Kiro {
    if ($Scope -eq "global") { Write-Skip "Kiro: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." ".kiro" "steering" "ironworks.md")
}
function Uninstall-Kiro {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." ".kiro" "steering" "ironworks.md")
}

# --- Roo ---
function Install-Roo {
    if ($Scope -eq "global") { Write-Skip "Roo: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." ".roo" "rules" "ironworks.md")
}
function Uninstall-Roo {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." ".roo" "rules" "ironworks.md")
}

# --- Continue ---
function Install-Continue {
    if ($Scope -eq "global") { Write-Skip "Continue: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." ".continuerules")
}
function Uninstall-Continue {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." ".continuerules")
}

# --- Junie ---
function Install-Junie {
    if ($Scope -eq "global") { Write-Skip "Junie: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." ".junie" "guidelines.md")
}
function Uninstall-Junie {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." ".junie" "guidelines.md")
}

# --- Trae ---
function Install-Trae {
    if ($Scope -eq "global") { Write-Skip "Trae: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." ".trae" "rules" "ironworks.md")
}
function Uninstall-Trae {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." ".trae" "rules" "ironworks.md")
}

# --- Augment ---
function Install-Augment {
    if ($Scope -eq "global") { Write-Skip "Augment: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." ".augment-guidelines")
}
function Uninstall-Augment {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." ".augment-guidelines")
}

# --- Kilo ---
function Install-Kilo {
    if ($Scope -eq "global") { Write-Skip "Kilo: global install not supported"; return }
    Copy-SafeFile $PortableFile (Join-Path "." ".kilo" "rules" "ironworks.md")
}
function Uninstall-Kilo {
    if ($Scope -eq "global") { return }
    Remove-SafeItem (Join-Path "." ".kilo" "rules" "ironworks.md")
}

# --- Antigravity ---
function Install-Antigravity {
    if ($Scope -eq "global") { $dst = Join-Path $env:USERPROFILE ".gemini" "antigravity" "skills" }
    else                     { $dst = Join-Path "." ".agent" "skills" }
    if (Test-Path $SkillsDir) {
        foreach ($d in (Get-ChildItem -Path $SkillsDir -Directory)) {
            Copy-SafeDir $d.FullName (Join-Path $dst $d.Name)
        }
    } else {
        Copy-SafeFile $PortableFile (Join-Path $dst "ironworks.md")
    }
}
function Uninstall-Antigravity {
    if ($Scope -eq "global") { Remove-SafeItem (Join-Path $env:USERPROFILE ".gemini" "antigravity" "skills") }
    else                     { Remove-SafeItem (Join-Path "." ".agent" "skills") }
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
function Invoke-Platform {
    param([string]$Name, [string]$Action)
    $funcName = $Name -replace '-',''
    # Capitalize for function name
    $parts = $funcName -split '(?=[A-Z])'
    switch ($Action) {
        "install" {
            switch ($Name) {
                "claude"      { Install-Claude }
                "cursor"      { Install-Cursor }
                "copilot"     { Install-Copilot }
                "windsurf"    { Install-Windsurf }
                "cline"       { Install-Cline }
                "gemini"      { Install-Gemini }
                "codex"       { Install-Codex }
                "aider"       { Install-Aider }
                "amazon-q"    { Install-AmazonQ }
                "kiro"        { Install-Kiro }
                "roo"         { Install-Roo }
                "continue"    { Install-Continue }
                "junie"       { Install-Junie }
                "trae"        { Install-Trae }
                "augment"     { Install-Augment }
                "kilo"        { Install-Kilo }
                "antigravity" { Install-Antigravity }
                default       { Write-Err "Unknown platform: $Name" }
            }
        }
        "uninstall" {
            switch ($Name) {
                "claude"      { Uninstall-Claude }
                "cursor"      { Uninstall-Cursor }
                "copilot"     { Uninstall-Copilot }
                "windsurf"    { Uninstall-Windsurf }
                "cline"       { Uninstall-Cline }
                "gemini"      { Uninstall-Gemini }
                "codex"       { Uninstall-Codex }
                "aider"       { Uninstall-Aider }
                "amazon-q"    { Uninstall-AmazonQ }
                "kiro"        { Uninstall-Kiro }
                "roo"         { Uninstall-Roo }
                "continue"    { Uninstall-Continue }
                "junie"       { Uninstall-Junie }
                "trae"        { Uninstall-Trae }
                "augment"     { Uninstall-Augment }
                "kilo"        { Uninstall-Kilo }
                "antigravity" { Uninstall-Antigravity }
                default       { Write-Err "Unknown platform: $Name" }
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Build target list
# ---------------------------------------------------------------------------
$Targets = @()

if ($Platform -ne "") {
    if ($Platform -eq "all") {
        foreach ($p in $AllPlatforms) {
            if (Detect-Platform $p) { $Targets += $p }
        }
        if ($Targets.Count -eq 0) {
            Write-Err "No platforms detected. Use -Platform <name> to install for a specific platform."
            exit 1
        }
    } else {
        if ($AllPlatforms -notcontains $Platform) {
            Write-Err "Unknown platform: $Platform"
            Write-Host "Run .\install.ps1 -List for supported platforms."
            exit 1
        }
        $Targets = @($Platform)
    }
} else {
    # auto-detect
    foreach ($p in $AllPlatforms) {
        if (Detect-Platform $p) { $Targets += $p }
    }
    if ($Targets.Count -eq 0) {
        Write-Err "No platforms detected. Use -Platform <name> to install for a specific platform."
        exit 1
    }
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
Write-Heading "Ironworks Skill Installer"
if ($DryRun) { Write-Info "Dry-run mode - no files will be written" }
Write-Info "Scope: $Scope"
Write-Info "Platforms: $($Targets -join ', ')"

if ($Uninstall) { $Action = "uninstall"; Write-Heading "Uninstalling..." }
else            { $Action = "install";   Write-Heading "Installing..." }

foreach ($t in $Targets) {
    Write-Info "--- $t ---"
    Invoke-Platform -Name $t -Action $Action
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Heading "Summary"
Write-Host "  Installed/Removed: $($script:Installed)" -ForegroundColor Green
Write-Host "  Skipped:           $($script:Skipped)"   -ForegroundColor Yellow
Write-Host "  Errors:            $($script:Errors)"     -ForegroundColor Red

if ($script:Errors -gt 0) { exit 1 }
exit 0
