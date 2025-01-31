# Script requires that user is already logged in to OC with appropriate credentials
# Correct project must be selected

param (
    [string]$scriptname,
    [string]$delete
)
write-output $scriptname
write-output $delete

# Clean up any open pot binds from previous runs
taskkill /im oc.exe /f

# Get the data pod name from the current namespace
$POSTGRES_DB_POD=oc get pods --selector name=postgresql --field-selector status.phase=Running -o custom-columns=POD:.metadata.name --no-headers
# Launch a new thread with a port bind
$PATH=$Env:Path
# Start-Process "oc-port-forward" cmd /k "SET PATH=$CD;$PATH & oc port-forward $POSTGRES_DB_POD 5432:5432"
Start-Process -FilePath "oc.exe" -ArgumentList "port-forward",$POSTGRES_DB_POD,"5432:5432" -PassThru

# Run Bind Port script and wait for it to run
timeout /t 50

# Push to Table using python script
# i.e. arguments are passed in like so: python.exe push_objstor_to_metabase.py -d

if ($delete){
    Start-Process -FilePath "python.exe" -ArgumentList $scriptname,$delete -Wait
} else {
    Start-Process -FilePath "python.exe" -ArgumentList $scriptname -Wait
}

# Clean up any open pot binds from previous runs
taskkill /im oc.exe /f
