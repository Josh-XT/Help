gwmi Win32_Product -filter "name like 'Java%' AND vendor like 'Oracl%'" | % { $_.Uninstall() } | out-null
Write-Host "All versions of java uninstalled."
Start-Process -FilePath "install\jre-8u102-windows-i586.exe" -ArgumentList "/s" -wait
Write-Host "Install of Java 8u102 complete."
Copy-Item ".\install\lib" -Destination "C:\Program Files (x86)\java\jre1.8.0_102" -Recurse -Force
Copy-Item ".\install\bin" -Destination "C:\Program Files (x86)\java\jre1.8.0_102" -Recurse -Force
Write-Host "Installed LiveLink."