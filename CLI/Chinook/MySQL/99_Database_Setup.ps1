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
"-environments.Full.url=jdbc:mysql://localhost:3306?allowPublicKeyRetrieval=true" `
"-environments.Full.schemas=chinook-fullrestore" `
"-environments.Full.user=root" `
"-environments.Full.password=Redg@te1" `
-cleanDisabled='false'

flyway deploy `
-environment=Full `
"-environments.Full.url=jdbc:mysql://localhost:3306?allowPublicKeyRetrieval=true" `
"-environments.Full.schemas=chinook-fullrestore" `
"-environments.Full.user=root" `
"-environments.Full.password=Redg@te1" `
"-deploy.scriptFilename=${scriptDirectory}\Database_Creation-Chinook_MySQL_8-Full.sql"

# Flyway - Create difference script (Treated)

flyway clean `
-environment=Treated `
"-environments.Treated.url=jdbc:mysql://localhost:3306?allowPublicKeyRetrieval=true" `
"-environments.Treated.schemas=chinook-treated" `
"-environments.Treated.user=root" `
"-environments.Treated.password=Redg@te1" `
-cleanDisabled='false'

flyway deploy `
-environment=Treated `
"-environments.Treated.url=jdbc:mysql://localhost:3306?allowPublicKeyRetrieval=true" `
"-environments.Treated.schemas=chinook-treated" `
"-environments.Treated.user=root" `
"-environments.Treated.password=Redg@te1" `
"-deploy.scriptFilename=${scriptDirectory}\Database_Creation-Chinook_MySQL_8-SchemaOnly.sql"