# TDM-Helper-Files

Get up and running with **Test Data Management (TDM)** quickly and easily! This repository provides everything you need to succeed with TDM, especially the **Redgate TDM CLI tools**, regardless of your skill level.

## 🎯 What's Included

Pre-made pipelines, ready-to-use worked examples, and database setup scripts covering the major RDBMS platforms:
- **SQL Server**
- **PostgreSQL**
- **MySQL**
- **Oracle**

Whether you're just getting started or looking for production-ready examples, you'll find practical resources to accelerate your TDM journey.

---

## 📁 Repository Structure

### CLI Worked Examples (`CLI/Chinook/`)
Complete worked examples using the **Chinook sample database** across all major database platforms. Each RDBMS folder contains:
- **Database creation scripts** (both Full with data and Schema-only versions)
- **Subsetting** - Subset your database down to the perfect slice
- **Classification** - Automatically detect sensitive data within your database
- **Mapping** - Automatically map sensitively classified columns to a masking rule
- **Mask** - Mask sensitive columns with production like equivalents 
- **Worked Examples** - Step-by-step examples for running:
  - `rgsubset` - Database subsetting
  - `rganonymize` - Data anonymization/masking
  - Complete end-to-end workflows

Each folder provides everything needed to reset databases and run the CLI examples independently.

### Installer Scripts (`Installer-Helpers/`)
Automated installation scripts to quickly set up the Redgate TDM CLI tools on your machine:
- `InstallTdmClisOnWindows.ps1` - Windows installer for TDM CLI tools

### Pipeline Examples (`Pipelines/`)
Ready-to-use CI/CD pipeline configurations:
- `AzureDevOps/` - Azure DevOps pipeline templates for TDM workflows
  - Subset and anonymization pipeline examples
  - Configuration file templates

---

## 🚀 Getting Started

1. **Install the TDM CLI tools** using the installer scripts in `Installer-Helpers/` or simply install the TDM GUI
2. **Choose your database platform** from the `CLI/Chinook/` examples
3. **Run the database setup scripts** to create the Chinook sample database
4. **Execute the PowerShell examples** to see subsetting and anonymization in action
5. **Adapt the configurations** for your own databases and requirements

---

## 📚 Resources

For more information about Redgate's Test Data Management solutions:
- [Redgate TDM Documentation](https://documentation.red-gate.com/)
- [TDM CLI Tools Documentation](https://documentation.red-gate.com/redgate-test-data-manager)
