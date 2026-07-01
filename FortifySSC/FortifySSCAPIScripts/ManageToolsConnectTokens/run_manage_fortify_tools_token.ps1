# PowerShell script that creates or updates a Fortify 'ToolsConnectToken'
# for the user specified via input.

# Define the full path to the Python executable
$pythonPath = "C:\Python313\python.exe"

# Define the full path to the Python script (located in the same directory as this .ps1 file)
$scriptPath = Join-Path $PSScriptRoot "ManageFortifyToolsToken.py"

# Execute the Python script
& $pythonPath $scriptPath