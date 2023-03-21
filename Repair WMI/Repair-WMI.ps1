# Run PowerShell as an administrator to perform these steps
# Stop the WMI service
Stop-Service winmgmt -Force
# Rename the WMI repository folder
Rename-Item C:\Windows\System32\wbem\Repository Repository.old -Force
# Restart the WMI service
Start-Service winmgmt
# Re-register the WMI modules
Get-ChildItem -Path C:\Windows\System32\wbem -Filter *.dll -Recurse | ForEach-Object {regsvr32 /s $_.FullName}
