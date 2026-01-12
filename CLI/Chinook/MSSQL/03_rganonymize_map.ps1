# Map data using rganonymize
# This script demonstrates how to run the rganonymize CLI command with example values.
# For more details, visit: https://documentation.red-gate.com/testdatamanager
#
# Key Options:
#   --classification-file: Path to the JSON file containing classification rules.
#   --masking-file: Path to the JSON file where masking rules will be generated.

# Detect Script Location
$scriptDirectory = $PSScriptRoot
if (-not $scriptDirectory) {
    $scriptDirectory = Get-Location
    Write-Warning "Unable to detect script location. Using current directory: $scriptDirectory"
}

# Example values
$CLASSIFICATION_FILE = "${scriptDirectory}\classification.json"
$MASKING_FILE = "${scriptDirectory}\masking.json"
$OPTIONS_FILE = "${scriptDirectory}\masking-options.json"
$OUTPUT = "Human" # Human|Json

Write-Host "Running mapping from classification file to masking file"

rganonymize map `
  --classification-file $CLASSIFICATION_FILE `
  --masking-file $MASKING_FILE `
  --options-file $OPTIONS_FILE `
  --output $OUTPUT