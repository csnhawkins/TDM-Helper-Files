param(
    [switch]$All  # Optional: run all steps without prompts
)

Write-Host "Starting 05_RunAll.ps1..." -ForegroundColor Green

# Known RDBMS (for banner only)
$KnownRdbms = @('MSSQL','MySQL','Oracle','PostgreSQL')

# Define steps with descriptions
$steps = @(
    @{ Name = '99_Database_Setup.ps1';    Description = 'This step resets the target databases' },
    @{ Name = '00_rgsubset_explain.ps1';  Description = 'Analyse target database and explain the subset plan (Check subset_log.json)' },
    @{ Name = '01_rgsubset_run.ps1';      Description = 'Create a subset into the _treated database' },
    @{ Name = '02_rganonymize_classify.ps1'; Description = 'Classify the _treated database' },
    @{ Name = '03_rganonymize_map.ps1';   Description = 'Create a plan for masking sensitive columns by mapping to datasets' },
    @{ Name = '04_rganonymize_mask.ps1';  Description = 'Apply masking to sensitive fields' }
)

# Determine base folder
if ($PSScriptRoot) {
    $basePath = $PSScriptRoot
} else {
    Write-Host "Cannot determine script location (likely running in VS Code selection mode)." -ForegroundColor Yellow
    $basePath = Read-Host "Please enter the full path to the folder containing the step scripts"
}

# Validate base folder
if (-not (Test-Path -LiteralPath $basePath)) {
    Write-Host "ERROR: The path '$basePath' does not exist." -ForegroundColor Red
    exit 1
}

# Auto-detect Dataset (parent folder) and RDBMS (this folder)
$leaf    = Split-Path -Path $basePath -Leaf
$parent  = Split-Path -Path $basePath -Parent
$dataset = Split-Path -Path $parent -Leaf
$rdbms   = $leaf

Write-Host ("Dataset: {0}  |  RDBMS: {1}" -f $dataset, $rdbms) -ForegroundColor Magenta
Write-Host ("Step folder: {0}" -f $basePath) -ForegroundColor DarkGray

# Check that all steps exist before starting
foreach ($step in $steps) {
    $filePath = Join-Path -Path $basePath -ChildPath $step.Name
    if (-not (Test-Path -LiteralPath $filePath)) {
        Write-Host "ERROR: Missing step script '$($step.Name)' in '$basePath'." -ForegroundColor Red
        exit 1
    }
}

# Run steps
foreach ($step in $steps) {
    $stepPath = Join-Path -Path $basePath -ChildPath $step.Name

    if (-not $All) {
        Write-Host ""
        Write-Host "Step: $($step.Name)" -ForegroundColor Cyan
        Write-Host "Description: $($step.Description)" -ForegroundColor DarkGray
        $resp = Read-Host "Run this step? (Y/N, default=Y)"

        # Default to Yes if Enter pressed; only skip on explicit 'N' or 'No'
        if (-not [string]::IsNullOrWhiteSpace($resp) -and $resp -notmatch '^(?i:y|yes)$') {
            Write-Host "Skipping step: $($step.Name)" -ForegroundColor Yellow
            continue
        }
    }

    Write-Host "Running step: $($step.Name) - $($step.Description)" -ForegroundColor Green

    # Execute step and determine outcome robustly
    $stepSucceeded = $true
    $exitCode = 0

    try {
        # Reset LASTEXITCODE so we don't carry over stale non-zero values
        $LASTEXITCODE = 0

        & $stepPath

        # Capture any exit code set by the step
        if ($LASTEXITCODE -ne $null) {
            $exitCode = [int]$LASTEXITCODE
        }

        # If last command failed, mark as failure
        if (-not $?) {
            $stepSucceeded = $false
            if ($exitCode -eq 0) { $exitCode = 1 }
        }

        # Non-zero exit code indicates failure too
        if ($exitCode -ne 0) {
            $stepSucceeded = $false
        }
    }
    catch {
        $stepSucceeded = $false
        if ($exitCode -eq 0) { $exitCode = 1 }
        Write-Host ("Exception: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }

    if (-not $stepSucceeded) {
        Write-Host "ERROR: Step $($step.Name) failed. ExitCode=$exitCode" -ForegroundColor Red
        exit $exitCode
    }

    Write-Host "Step $($step.Name) completed." -ForegroundColor Green
}

Write-Host "`nTDM CLIs - Subset and Masking Complete!" -ForegroundColor Green
