<#
.SYNOPSIS
    Builds the HdpOAuthConnect Power BI connector.

.DESCRIPTION
    Downloads the Power Query SDK tools via NuGet (if not already cached) and
    compiles the connector to a .mez file. Works on any Windows machine and on
    TeamCity build agents - no VS Code or Docker required.

.PARAMETER Configuration
    Build configuration: Debug (default) or Release.

.PARAMETER SdkVersion
    Version of Microsoft.PowerQuery.SdkTools to use. Defaults to 2.152.3.

.EXAMPLE
    .\build.ps1
    .\build.ps1 -Configuration Release

.NOTES
    Output: HdpOAuthConnect\bin\<Configuration>\HdpOAuthConnect.mez
#>
param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Debug",

    [string]$SdkVersion = "2.152.3"
)

$ErrorActionPreference = "Stop"

$repoRoot     = $PSScriptRoot
$connectorDir = Join-Path $repoRoot "HdpOAuthConnect"
$outputDir    = Join-Path $connectorDir "bin\$Configuration"
$toolsDir     = Join-Path $repoRoot ".packages"
$nugetExe     = Join-Path $toolsDir "nuget.exe"
$sdkDir       = Join-Path $toolsDir "Microsoft.PowerQuery.SdkTools.$SdkVersion"
$makePqx      = Join-Path $sdkDir "tools\MakePQX.exe"

# Create directories
New-Item -ItemType Directory -Path $toolsDir  -Force | Out-Null
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# Download nuget.exe if needed
if (-not (Test-Path $nugetExe)) {
    Write-Host "Downloading nuget.exe..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" `
                      -OutFile $nugetExe
}

# Restore SDK tools package if needed
if (-not (Test-Path $makePqx)) {
    Write-Host "Restoring Microsoft.PowerQuery.SdkTools $SdkVersion..." -ForegroundColor Cyan
    & $nugetExe install Microsoft.PowerQuery.SdkTools `
        -Version $SdkVersion `
        -OutputDirectory $toolsDir `
        -NonInteractive
    if ($LASTEXITCODE -ne 0) { throw "NuGet restore failed." }
}

# The NuGet package ships System.Threading.Tasks.Extensions v4.2.1.0 but
# MakePQX.exe was compiled against v4.2.0.1. The shipped MakePQX.exe.config
# has other binding redirects but is missing this one - add it if needed.
$makePqxConfig = Join-Path (Split-Path $makePqx) "MakePQX.exe.config"
if ((Test-Path $makePqxConfig) -and ((Get-Content $makePqxConfig -Raw) -notmatch "System\.Threading\.Tasks\.Extensions")) {
    Write-Host "Patching MakePQX.exe.config with missing binding redirect..." -ForegroundColor Cyan
    [xml]$cfg = Get-Content $makePqxConfig
    $ns      = "urn:schemas-microsoft-com:asm.v1"
    $runtime = $cfg.configuration.runtime
    $binding = $cfg.CreateElement("assemblyBinding", $ns)
    $dep     = $cfg.CreateElement("dependentAssembly", $ns)
    $ident   = $cfg.CreateElement("assemblyIdentity", $ns)
    $ident.SetAttribute("name", "System.Threading.Tasks.Extensions")
    $ident.SetAttribute("publicKeyToken", "cc7b13ffcd2ddd51")
    $ident.SetAttribute("culture", "neutral")
    $redir   = $cfg.CreateElement("bindingRedirect", $ns)
    $redir.SetAttribute("oldVersion", "0.0.0.0-4.2.1.0")
    $redir.SetAttribute("newVersion", "4.2.1.0")
    $dep.AppendChild($ident) | Out-Null
    $dep.AppendChild($redir) | Out-Null
    $binding.AppendChild($dep) | Out-Null
    $runtime.AppendChild($binding) | Out-Null
    $cfg.Save($makePqxConfig)
}

# Compile the connector
Write-Host "Compiling connector ($Configuration)..." -ForegroundColor Cyan
Push-Location $connectorDir
try {
    & $makePqx compile --directory $outputDir
    if ($LASTEXITCODE -ne 0) { throw "MakePQX compile failed." }
} finally {
    Pop-Location
}

Write-Host "`nBuild succeeded. Output in: $outputDir" -ForegroundColor Green
Get-ChildItem $outputDir | Select-Object Name, Length, LastWriteTime
