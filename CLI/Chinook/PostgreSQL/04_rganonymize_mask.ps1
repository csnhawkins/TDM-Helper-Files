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
$DB_ENGINE = "PostgreSQL"
$CONNECTION_STRING = "Host=Localhost;Port=5432;Database=chinook_treated;User Id=postgres;Password=Redg@te1;"
$MASKING_FILE = "${scriptDirectory}\masking.json"
$OPTIONS_FILE = "${scriptDirectory}\masking-options.json"
$OUTPUT = "Human" # Human|Json
# https://documentation.red-gate.com/testdatamanager/command-line-interface-cli/anonymization/masking/enabling-deterministic-masking
$DETERMINISTIC_SEED="my-secret-seed" # Can be any string, but must be at least 4 characters long
$LOG_LEVEL = "Verbose"
$LOG_FILE = "${scriptDirectory}\masking_log.json"

Write-Host "Running masking for database engine: $DB_ENGINE"

# Update Database Statistics - This ensures the correct row count is returned by rganonymize if subsetting has previously been done #
Write-Host "PostgreSQL - Updating Stats"
$flywayUpdateStats = flyway -url="jdbc:postgresql://localhost:5432/chinook_treated" -user="postgres" -password="Redg@te1" -initSql="ANALYZE;" info

rganonymize mask `
  --database-engine $DB_ENGINE `
  --connection-string "$CONNECTION_STRING" `
  --masking-file $MASKING_FILE `
  --options-file "$OPTIONS_FILE" `
  --deterministic-seed "$DETERMINISTIC_SEED" `
  --log-level $LOG_LEVEL `
  --log-file $LOG_FILE `
  --output $OUTPUT