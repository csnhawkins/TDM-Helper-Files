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
"-environments.Full.url=jdbc:sqlserver://localhost;databaseName=Chinook_FullRestore;encrypt=false;integratedSecurity=true;trustServerCertificate=true" `
"-environments.Full.user=" `
"-environments.Full.password=" `
-cleanDisabled='false'

flyway deploy `
-environment=Full `
"-environments.Full.url=jdbc:sqlserver://localhost;databaseName=Chinook_FullRestore;encrypt=false;integratedSecurity=true;trustServerCertificate=true" `
"-environments.Full.user=" `
"-environments.Full.password=" `
"-deploy.scriptFilename=${scriptDirectory}\Database_Creation-Chinook_MSSQL-Full.sql"

# Flyway - Create difference script (Treated)

flyway clean `
-environment=Treated `
"-environments.Treated.url=jdbc:sqlserver://localhost;databaseName=Chinook_Treated;encrypt=false;integratedSecurity=true;trustServerCertificate=true" `
"-environments.Treated.user=" `
"-environments.Treated.password=" `
-cleanDisabled='false'

flyway deploy `
-environment=Treated `
"-environments.Treated.url=jdbc:sqlserver://localhost;databaseName=Chinook_Treated;encrypt=false;integratedSecurity=true;trustServerCertificate=true" `
"-environments.Treated.user=" `
"-environments.Treated.password=" `
"-deploy.scriptFilename=${scriptDirectory}\Database_Creation-Chinook_MSSQL-SchemaOnly.sql"