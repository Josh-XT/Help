gwmi Win32_Product -filter "vendor like '%Travelport%'" | % { $_.Uninstall() } | out-null
gwmi Win32_Product -filter "name like '%Dynamics%'" | % { $_.Uninstall() } | out-null
gwmi Win32_Product -filter "name like '%Tableau%'" | % { $_.Uninstall() } | out-null
gwmi Win32_Product -filter "name like '%Axis%'" | % { $_.Uninstall() } | out-null
gwmi Win32_Product -filter "name like '%AMS%'" | % { $_.Uninstall() } | out-null
Remove-Item -path "c:\fp" -recurse -force
Write-Host "Software from image uninstalled."