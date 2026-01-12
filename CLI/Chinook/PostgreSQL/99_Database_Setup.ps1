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
"-environment=Treated" `
"-environments.Treated.url=jdbc:postgresql://localhost:5432/chinook_fullrestore" `
"-environments.Treated.user=postgres" `
"-environments.Treated.password=Redg@te1" `
-schemas="public" `
-cleanDisabled='false'

flyway deploy `
"-environment=Treated" `
"-environments.Treated.url=jdbc:postgresql://localhost:5432/chinook_fullrestore" `
"-environments.Treated.user=postgres" `
"-environments.Treated.password=Redg@te1" `
"-deploy.scriptFilename=${scriptDirectory}\Database-Creation_Chinook_PostgreSQL-Full.sql"

# Flyway - Create difference script (Treated)

flyway clean `
"-environment=Treated" `
"-environments.Treated.url=jdbc:postgresql://localhost:5432/chinook_treated" `
"-environments.Treated.user=postgres" `
"-environments.Treated.password=Redg@te1" `
-schemas="public" `
-cleanDisabled='false'

flyway deploy `
"-environment=Treated" `
"-environments.Treated.url=jdbc:postgresql://localhost:5432/chinook_treated" `
"-environments.Treated.user=postgres" `
"-environments.Treated.password=Redg@te1" `
"-deploy.scriptFilename=${scriptDirectory}\Database-Creation_Chinook_PostgreSQL-SchemaOnly.sql"
