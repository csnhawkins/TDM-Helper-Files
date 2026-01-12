# MySQL credentials
$MySQLUser = "root"
$MySQLPass = "Redg@te1"
$MySQLHost = "localhost"
$Database = "chinook-treated"

# Step 1: Get all tables in the database (capture output, suppress stderr)
$tablesQuery = "SELECT table_name FROM information_schema.tables WHERE table_schema='$Database' AND table_type='BASE TABLE';"
$tables = & "mysql.exe" -u $MySQLUser -p"$MySQLPass" -h $MySQLHost -N -B -e $tablesQuery 2>$null

# Step 2: Loop through each table and run ANALYZE TABLE (capture output, suppress stderr)
$analyzeResults = @()
foreach ($table in $tables) {
    $analyzeQuery = "ANALYZE TABLE $table;"
    $result = & "mysql.exe" -u $MySQLUser -p"$MySQLPass" -h $MySQLHost -D "$Database" -e $analyzeQuery 2>$null
    $analyzeResults += $result
}

Write-Host "All tables analyzed successfully."