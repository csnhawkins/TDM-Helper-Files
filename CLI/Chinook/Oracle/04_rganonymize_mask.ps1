# Mask data using rganonymize
# This script demonstrates how to run the rganonymize CLI command with example values.
# For more details, visit: https://documentation.red-gate.com/testdatamanager
#
# Key Options:
#   --database-engine: The database engine to use (e.g., SqlServer, PostgreSql).
#   --connection-string: Connection string for the database.
#   --masking-file: Path to the JSON file containing masking rules.
#   --log-level: Logging level (e.g., Verbose, Info, Error).

# Detect Script Location
$scriptDirectory = $PSScriptRoot
if (-not $scriptDirectory) {
    $scriptDirectory = Get-Location
    Write-Warning "Unable to detect script location. Using current directory: $scriptDirectory"
}

# Example values
$DB_ENGINE = "Oracle"
$CONNECTION_STRING = "Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=dev1)));User Id=chinook;Password=chinook;"
$MASKING_FILE = "${scriptDirectory}\masking.json"
$OPTIONS_FILE = "${scriptDirectory}\masking-options.json"
$OUTPUT = "Human" # Human|Json
# https://documentation.red-gate.com/testdatamanager/command-line-interface-cli/anonymization/masking/enabling-deterministic-masking
$DETERMINISTIC_SEED="my-secret-seed" # Can be any string, but must be at least 4 characters long
$LOG_LEVEL = "Verbose"
$LOG_FILE = "${scriptDirectory}\masking_log.json"

# Optional - Update Database Statistics - This ensures the correct row count is returned by rganonymize if subsetting has previously been done #
Write-Host "Oracle - Updating Stats"
$flywayUpdateStats = flyway -url="jdbc:oracle:thin:@//localhost:1521/dev1" -user="hr" -password="hr" -initSql="begin DBMS_STATS.GATHER_SCHEMA_STATS (ownname => 'CHINOOK',estimate_percent => 1); end;" info

Write-Host "Running masking for database engine: $DB_ENGINE"

rganonymize mask `
  --database-engine $DB_ENGINE `
  --connection-string "$CONNECTION_STRING" `
  --masking-file $MASKING_FILE `
  --options-file "$OPTIONS_FILE" `
  --deterministic-seed "$DETERMINISTIC_SEED" `
  --log-level $LOG_LEVEL `
  --log-file $LOG_FILE `
  --output $OUTPUT