# Chinook Database - Test Data Manager Onboarding

## Overview

The Chinook example provides a complete, cross-platform demonstration of Redgate's Test Data Manager (TDM) Standard tooling for database subsetting and anonymization. This example showcases best practices for using the `rgsubset` and `rganonymize` CLI tools across four major RDBMS platforms: SQL Server (MSSQL), MySQL, Oracle, and PostgreSQL.

## Purpose

When demonstrating or conducting Proof of Concepts (PoCs) with Redgate's Test Data Manager Standard, you need practical examples that show:

- **Subsetting**: How to create smaller, representative datasets from production databases
- **Anonymization**: How to mask sensitive data while maintaining referential integrity
- **Cross-platform consistency**: Same commands and logic work across different database engines
- **Best practices**: Embedded CLI syntax, parameters, and configuration patterns

The Chinook database is a well-known sample database representing a digital music store, making it perfect for demonstrations as it contains realistic data relationships and common sensitive data types.

## What You'll Learn

This example demonstrates:

1. **Database subsetting** with custom filter clauses and relationship handling
2. **Data classification** using both built-in and custom classification rules  
3. **Advanced masking techniques** including:
   - Custom datasets (lists, expressions, conditional, file-based)
   - Deterministic masking for consistency
   - Expression-based masking combining multiple fields
   - Conditional datasets based on related column values
4. **Cross-RDBMS compatibility** with identical logic across platforms
5. **CLI best practices** with proper connection strings and parameters

## Repository Structure

```
Chinook/
├── MSSQL/           # SQL Server examples
├── MySQL/           # MySQL examples  
├── Oracle/          # Oracle examples
└── PostgreSQL/      # PostgreSQL examples
```

Each RDBMS folder contains identical file structures with platform-specific connection strings and SQL syntax.

## Files in Each RDBMS Folder

### PowerShell Scripts (Workflow Steps)
- **`00_rgsubset_explain.ps1`** - Analyzes the database and explains the subset plan
- **`01_rgsubset_run.ps1`** - Executes the subsetting operation
- **`02_rganonymize_classify.ps1`** - Classifies sensitive data columns
- **`03_rganonymize_map.ps1`** - Creates masking plans by mapping to datasets
- **`04_rganonymize_mask.ps1`** - Applies masking to sensitive fields
- **`05_RunAll.ps1`** - Orchestrates the complete workflow with user prompts
- **`99_Database_Setup.ps1`** - Resets target databases using Flyway

### Configuration Files
- **`subset-options.json`** - Subsetting configuration with custom logic
- **`masking-options.json`** - Masking configuration with custom datasets
- **`classification.json`** - Data classification rules
- **`masking.json`** - Generated masking plan (output from step 03)
- **`subset_log.json`** - Subset operation log (output from steps 00/01)

### Database Files
- **`Database_Creation-Chinook_[RDBMS].sql`** - Complete database creation script with sample data

## Database Schema

The Chinook database contains 11 tables representing a music store:

**Core Tables:**
- `Artist` - Music artists
- `Album` - Music albums  
- `Track` - Individual songs
- `Genre` - Music genres
- `MediaType` - File formats (MP3, AAC, etc.)

**Customer & Sales:**
- `Customer` - Customer information (contains PII)
- `Employee` - Staff information (contains PII)
- `Invoice` - Sales transactions
- `InvoiceLine` - Individual line items

**Playlists:**
- `Playlist` - User-created playlists
- `PlaylistTrack` - Many-to-many relationship

## Key Learning Features

### 1. Advanced Subsetting Logic

The `subset-options.json` demonstrates:

```json
{
  "startingTables": [
    {
      "table": { "schema": "dbo", "name": "Invoice" },
      "filterClause": "WHERE InvoiceDate > '2024-11-29'",
      "forwardRelationshipsOnly": false
    }
  ],
  "excludedTables": [
    { "schema": "dbo", "name": "SystemLog" }
  ],
  "staticDataTables": [
    { "schema": "dbo", "name": "AppConfig" }
  ],
  "manualRelationships": [
    {
      "sourceTable": { "schema": "dbo", "name": "TrackReview" },
      "sourceColumns": ["TrackId"],
      "targetTable": { "schema": "dbo", "name": "Track" },
      "targetColumns": ["TrackId"]
    }
  ]
}
```

### 2. Custom Masking Datasets

The `masking-options.json` includes several advanced dataset types:

**Expression Dataset:**
```json
{
  "name": "CustomEmailAddresses",
  "type": "Expression", 
  "expression": "$(GivenNames($[FirstName])).$(FamilyNames($[LastName]))@$(Domains)"
}
```

**Conditional Dataset:**
```json
{
  "name": "CustomCities",
  "type": "Conditional",
  "conditions": [
    { "if": "$[Country] == \"United Kingdom\"", "then": "UKCities" },
    { "if": "$[Country] == \"USA\"", "then": "USCities" },
    { "otherwise": "Cities" }
  ]
}
```

**File-based Dataset:**
```json
{
  "name": "UKCities",
  "type": "File",
  "file": "C:\\git\\Demos\\TDM-Helper-Files\\Datasets\\UKCities.txt"
}
```

### 3. Custom Classifications

Custom classification rules for business-specific data:

```json
{
  "type": "CompanyNames",
  "confidence": "High", 
  "condition": "Column.Name contains 'Company' AND Column.Name contains 'Name'"
}
```

## Prerequisites

- **Test Data Manager CLI tools** (`rgsubset` and `rganonymize`)
- **Database access** to your chosen RDBMS platform
- **Flyway** (for database setup scripts)
- **PowerShell** (scripts tested on Windows PowerShell/PowerShell Core)

## Quick Start

1. **Choose your RDBMS platform** (MSSQL, MySQL, Oracle, or PostgreSQL)
2. **Update connection strings** in the PowerShell scripts to match your environment
3. **Run database setup**: `.\99_Database_Setup.ps1`
4. **Execute complete workflow**: `.\05_RunAll.ps1 -All`

Or run steps individually:
```powershell
.\00_rgsubset_explain.ps1   # Analyze subset plan
.\01_rgsubset_run.ps1       # Execute subset  
.\02_rganonymize_classify.ps1 # Classify sensitive data
.\03_rganonymize_map.ps1    # Create masking plan
.\04_rganonymize_mask.ps1   # Apply masking
```

## Customization

### Connection Strings
Update the connection string variables in each PowerShell script to match your environment. Connection string formats are documented [here](https://documentation.red-gate.com/testdatamanager/command-line-interface-cli/database-connection-string-formats).

### Subset Logic  
Modify `subset-options.json` to:
- Change date ranges in filter clauses
- Add/remove excluded tables
- Modify starting tables and relationships
- Adjust desired subset size

### Masking Configuration
Customize `masking-options.json` to:
- Add custom datasets for your specific data types
- Modify conditional logic
- Enable/disable built-in classifications
- Create custom classification rules

### File Paths
Update file paths in `masking-options.json` datasets to point to your local `Datasets` folder:
```json
"file": "C:\\your\\path\\to\\TDM-Helper-Files\\Datasets\\UKCities.txt"
```

## Expected Output

After running the complete workflow, you'll have:

1. **Two databases:**
   - `Chinook_FullRestore` - Original data (production simulation)
   - `Chinook_Treated` - Subsetted and anonymized data

2. **Log files:**
   - `subset_log.json` - Details of the subsetting operation
   - Various console outputs showing classification and masking results

3. **Generated configurations:**
   - `masking.json` - The masking plan created by step 03

## Learning Outcomes

By working through this example, you'll understand:

- How to configure complex subsetting scenarios with custom relationships
- Advanced masking techniques using conditional and expression-based datasets
- Cross-platform compatibility considerations
- Best practices for CLI parameter usage
- How to integrate TDM tools into automated workflows

## Documentation

For complete Test Data Manager documentation, visit:
https://documentation.red-gate.com/testdatamanager

## Support

This example is designed for demonstration and learning purposes. For production implementations, consider:

- Security best practices for connection strings
- Environment-specific configuration management  
- Integration with your CI/CD pipelines
- Backup and recovery procedures for target environments
