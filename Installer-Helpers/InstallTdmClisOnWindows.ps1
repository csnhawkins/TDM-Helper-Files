# Config
$defaultInstallLocation = "$env:ProgramFiles\Red Gate\Test Data Manager"
$clisToInstall = @(
    "rganonymize",
    "rgclone",
    "rggenerate",
    "rgsubset"
)

# -----------------------------
# Helpers
# -----------------------------
function Find-LatestVersion {
    param (
        [Parameter(Position=0,mandatory=$true)]$xml
    )
    $versions = @()
    ($xml -Split "<Key>") | ForEach-Object {
        $versions += ((($_ -split ".zip")[0] -split "_")[1])
    }
    $uniqueVersions = $versions | Select-Object -Unique
    $sortedVersions = $uniqueVersions | Sort-Object {
        [System.Version]::Parse($_)
    } -Descending
    return $sortedVersions[0]
}

Function Test-LatestVersion {
    param (
        [Parameter(Position=0,mandatory=$true)]
        [ValidateSet("rgclone","rganonymize","rgsubset","rggenerate")]
        [string]$cli
    )

    if ($cli -eq "rgclone") {
        $rgcloneVersion = (rgclone version | Out-String).Trim()
        if ($rgcloneVersion -notlike "*WARNING - Your current version * of the rgclone CLI is outdated.*") {
            return $true
        }
    }
    else {
        switch ($cli){
            "rganonymize" { $latestVersionXml = "https://redgate-download.s3.eu-west-1.amazonaws.com/?delimiter=/&prefix=EAP/AnonymizeWin64/" }
            "rgsubset"    { $latestVersionXml = "https://redgate-download.s3.eu-west-1.amazonaws.com/?delimiter=/&prefix=EAP/SubsetterWin64/" }
            "rggenerate"  { $latestVersionXml = "https://redgate-download.s3.eu-west-1.amazonaws.com/?delimiter=/&prefix=EAP/RGGenerateWin64/" }
        }

        $latestVersionData = (Invoke-WebRequest -Uri $latestVersionXml -UseBasicParsing -ErrorAction Stop -TimeoutSec 30).Content
        $latestsVersion = Find-LatestVersion $latestVersionData
        $currentVersion = (& $cli --version | Out-String).Trim()
        Write-Verbose "Testing $cli version..."
        Write-Verbose "  - Installed version: $currentVersion"
        Write-Verbose "  - Latest version:    $latestsVersion"
        if ($currentVersion -like "*$latestsVersion*") {
            return $true
        }
    }
    return $false
}

Function Get-ExistingCliLocation {
    param (
        [Parameter(Position=0,mandatory=$true)]
        [ValidateSet("rgclone","rganonymize","rgsubset","rggenerate")]
        [string]$cli
    )
    $cliExe = (Get-Command $cli -ErrorAction SilentlyContinue).Source
    if ($cliExe) {
        return (Split-Path -Parent $cliExe)
    }
    return $false
}

Function Install-TdmCli {
    param (
        [Parameter(Position=0,mandatory=$true)]
        [ValidateSet("rgclone","rganonymize","rgsubset","rggenerate")]
        [string]$cli,

        [string]$installLocation = "$env:ProgramFiles\Red Gate\Test Data Manager",
        [string]$rgcloneEndpoint = ""
    )

    # rgclone endpoint handling
    if (($cli -eq "rgclone") -and [string]::IsNullOrEmpty($rgcloneEndpoint)) {
        if ($env:RGCLONE_API_ENDPOINT) {
            $rgcloneEndpoint = $env:RGCLONE_API_ENDPOINT
            Write-Verbose "Using RGCLONE_API_ENDPOINT from environment: $rgcloneEndpoint"
        }
        else {
            Write-Error "rgclone requires RGCLONE_API_ENDPOINT (param or env var). Skipping."
            return $false
        }
    }

    # Download URL
    switch ($cli) {
        "rgclone"     { $downloadUrl = $rgcloneEndpoint + "cloning-api/download/cli/windows-amd64" }
        "rganonymize" { $downloadUrl = "https://download.red-gate.com/EAP/AnonymizeWin64.zip" }
        "rgsubset"    { $downloadUrl = "https://download.red-gate.com/EAP/SubsetterWin64.zip" }
        "rggenerate"  { $downloadUrl = "https://download.red-gate.com/EAP/RGGenerateWin64.zip" }
    }

    $executablePath = Join-Path $installLocation "$cli.exe"
    $tempPath       = Join-Path $installLocation "temp"
    $zipPath        = Join-Path $tempPath "$cli.zip"
    $unzipPath      = Join-Path $tempPath "${cli}_extracted"
    $backupPath     = "$executablePath.bak"

    Write-Verbose "Installing: $cli"
    Write-Verbose "Download URL: $downloadUrl"
    Write-Verbose "Install dir: $installLocation"

    try {
        # Ensure directories
        if (-not (Test-Path $installLocation)) { New-Item -ItemType Directory -Path $installLocation | Out-Null }
        if (Test-Path $tempPath) { Remove-Item $tempPath -Recurse -Force }
        New-Item -ItemType Directory -Path $tempPath | Out-Null

        # Download with Invoke-WebRequest (fast mode)
        Write-Verbose "Downloading $cli to $zipPath"
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing -ErrorAction Stop -TimeoutSec 60

        # Extract with .NET ZipFile (faster than Expand-Archive)
        Write-Verbose "Extracting to $unzipPath"
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        if (Test-Path $unzipPath) { Remove-Item $unzipPath -Recurse -Force }
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $unzipPath)

        # Backup existing
        if (Test-Path $executablePath) {
            Write-Verbose "Backing up existing $cli.exe"
            Copy-Item $executablePath $backupPath -Force
        }

        # Copy new exe
        $extractedCli = Get-ChildItem -Path $unzipPath -Filter "$cli*.exe" -Recurse | Select-Object -First 1
        if (-not $extractedCli) { throw "Could not find extracted $cli executable." }

        Copy-Item $extractedCli.FullName $executablePath -Force

        # Cleanup temp
        Remove-Item $tempPath -Recurse -Force

        # PATH handling
        try {
            $target = "Machine"
            $currentPath = [System.Environment]::GetEnvironmentVariable("Path", $target)
            if ($currentPath -and $currentPath -notlike "*$installLocation*") {
                [System.Environment]::SetEnvironmentVariable("Path", "$installLocation;$currentPath", $target)
                Write-Verbose "$cli install location added to PATH."
            }
        } catch {
            Write-Warning "Failed to update PATH. Please ensure $installLocation is in PATH manually."
        }

        # Refresh PATH for current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("Path","User")

        Write-Output "$cli installed successfully at $executablePath"
        return $true
    }
    catch {
        Write-Error "Failed to install $cli - $($_.Exception.Message)"
        if (Test-Path $backupPath) {
            Write-Output "Restoring backup..."
            Copy-Item $backupPath $executablePath -Force
        }
        return $false
    }
}

# -----------------------------
# Install Loop
# -----------------------------
ForEach ($cli in $clisToInstall) {
    $installLocation = Get-ExistingCliLocation -cli $cli
    if ($installLocation) {
        if (Test-LatestVersion $cli -Verbose) {
            Write-Output "$cli is already installed at $installLocation. It's up to date and available to PATH. No action necessary."
            $installRequired = $false
        }
        else {
            Write-Output "$cli is already installed, but not up to date. Will install latest version in existing location: $installLocation"
            $installRequired = $true
        }
    }
    else {
        Write-Output "$cli is not available to PATH. Will perform a fresh install to the default location: $defaultInstallLocation"
        $installLocation = $defaultInstallLocation
        $installRequired = $true
    }

    if ($installRequired) {
        if ($cli -eq "rgclone") {
            if ($env:RGCLONE_API_ENDPOINT) {
                Write-Output "  Installing latest version of rgclone..."
                Install-TdmCli rgclone -installLocation $installLocation -Verbose
            }
            else {
                Write-Warning "rgclone install/update required, but %RGCLONE_API_ENDPOINT% not provided. Skipping rgclone install."
            }
        }
        else {
            Write-Output "  Installing latest version of $cli to $installLocation..."
            if (Install-TdmCli $cli -installLocation $installLocation -Verbose) {
                Write-Output "  $cli installed successfully"
            }
            else {
                Write-Error "Failed to install $cli"
            }
        }
    }
}
