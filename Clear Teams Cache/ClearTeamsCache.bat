@echo off
taskkill -f -im teams.exe
rmdir /S /Q "%appdata%\Microsoft\Teams\Application Cache"
rmdir /S /Q "%appdata%\Microsoft\Teams\Blob_storage"
rmdir /S /Q "%appdata%\Microsoft\Teams\Cache"
rmdir /S /Q "%appdata%\Microsoft\Teams\Databases"
rmdir /S /Q "%appdata%\Microsoft\Teams\GPUCache"
rmdir /S /Q "%appdata%\Microsoft\Teams\IndexedDB"
rmdir /S /Q "%appdata%\Microsoft\Teams\Local Storage"
rmdir /S /Q "%appdata%\Microsoft\Teams\Temp"
rmdir /S /Q "%appdata%\Microsoft\Teams\TMP"