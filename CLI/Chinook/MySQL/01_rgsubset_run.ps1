# Subset data using rgsubset
# This script demonstrates how to run the rgsubset CLI command with example values.
# For more details, visit: https://documentation.red-gate.com/testdatamanager
#
# Key Options:
#   --database-engine: The database engine to use (e.g., SqlServer, PostgreSql).
#   Connection String Documentation - https://documentation.red-gate.com/testdatamanager/command-line-interface-cli/database-connection-string-formats
#   --source-connection-string: Connection string for the source database. 
#   --target-connection-string: Connection string for the target database.
#   --options-file: Path to the JSON file containing subset options.
#   --log-level: Logging level (e.g., Verbose, Info, Error).

# Detect Script Location
$scriptDirectory = $PSScriptRoot
if (-not $scriptDirectory) {
    $scriptDirectory = Get-Location
    Write-Warning "Unable to detect script location. Using current directory: $scriptDirectory"
}

# Example values
$DB_ENGINE = "MySql"
$SOURCE_CONN_STRING = "Server=localhost;Port=3306;Database=chinook-fullrestore;Uid=root;Pwd=Redg@te1"
$TARGET_CONN_STRING="Server=localhost;Port=3306;Database=chinook-treated;Uid=root;Pwd=Redg@te1"
$OPTIONS_FILE = "${scriptDirectory}\subset-options.json"
$OUTPUT_FILE = "${scriptDirectory}\subset_output.json"
$OUTPUT = "Human" # Human|Json
# Perform a dry-run with no subsetting applied by turning to true
$DRY_RUN="false"
$LOG_LEVEL = "Information"
$LOG_FILE = "${scriptDirectory}\subset_log.json"
$FORCE = "false"

Write-Host "Running subset for database engine: $DB_ENGINE"

rgsubset run `
  --database-engine $DB_ENGINE `
  --source-connection-string "$SOURCE_CONN_STRING" `
  --target-connection-string "$TARGET_CONN_STRING" `
  --target-database-write-mode Overwrite `
  --options-file $OPTIONS_FILE `
  --dry-run $DRY_RUN `
  --log-level $LOG_LEVEL `
  --log-file $LOG_FILE `
  --output-file $OUTPUT_FILE  `
  --output $OUTPUT `
  --force $FORCE