#Purpose: Used to set the ntuser.dat last modified date to that of the last modified date on the user profile folder.
#This is needed because windows cumulative updates are altering the ntuser.dat last modified date which then defeats
#the ability for GPO to delete profiles based on date and USMT migrations based on date.

$ErrorActionPreference = "SilentlyContinue"
$Report = $Null
$Path = "C:\Users"
$UserFolders = $Path | Get-ChildItem -Directory

ForEach ($UserFolder in $UserFolders)
{
$UserName = $UserFolder.Name
If (Test-Path "$Path\$UserName\NTUSer.dat")
    {
    $Dat = Get-Item "$Path\$UserName\NTUSer.dat" -force
    $DatTime = $Dat.LastWriteTime
    If ($UserFolder.Name -ne "default"){
        $Dat.LastWriteTime = $UserFolder.LastWriteTime
    }
    Write-Host $UserName $DatTime
    Write-Host (Get-item $Path\$UserName -Force).LastWriteTime
    $Report = $Report + "$UserName`t$DatTime`r`n"
    $Dat = $Null
    }
}