# Step 1 - Reset Target environment
# This is to ensure we have a schema only target to subset and anonymize #
# There are many methods of creating a schema only database - In this example we use Flyway to achieve this #

# Detect Script Location
$scriptDirectory = $PSScriptRoot
if (-not $scriptDirectory) {
    $scriptDirectory = Get-Location
    Write-Warning "Unable to detect script location. Using current directory: $scriptDirectory"
}

# Flyway - Create difference script (FullRestore)

flyway clean `
-environment=Full `
"-environments.Full.url=jdbc:oracle:thin:@//localhost:1521/pdbprod" `
"-environments.Full.schemas=CHINOOK" `
"-environments.Full.user=chinook" `
"-environments.Full.password=chinook" `
-cleanDisabled='false'

flyway deploy `
-environment=Full `
"-environments.Full.url=jdbc:oracle:thin:@//localhost:1521/pdbprod" `
"-environments.Full.schemas=CHINOOK" `
"-environments.Full.user=chinook" `
"-environments.Full.password=chinook" `
"-deploy.scriptFilename=${scriptDirectory}\Database_Creation-Chinook_Oracle-Full.sql"

# Flyway - Create difference script (Treated)

flyway clean `
-environment=Treated `
"-environments.Treated.url=jdbc:oracle:thin:@//localhost:1521/dev1" `
"-environments.Treated.schemas=CHINOOK" `
"-environments.Treated.user=chinook" `
"-environments.Treated.password=chinook" `
-cleanDisabled='false'

flyway deploy `
-environment=Treated `
"-environments.Treated.url=jdbc:oracle:thin:@//localhost:1521/dev1" `
"-environments.Treated.schemas=CHINOOK" `
"-environments.Treated.user=chinook" `
"-environments.Treated.password=chinook" `
"-deploy.scriptFilename=${scriptDirectory}\Database_Creation-Chinook_Oracle-SchemaOnly.sql"
