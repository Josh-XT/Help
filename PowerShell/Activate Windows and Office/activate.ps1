param($key)
<#
    .FILENAME
        activate.ps1

    .SYNOPSIS
        Activate Microsoft Windows and Office 2016

    .DESCRIPTION
        Install product key for Microsoft Windows, and activate
        Microsoft Office 2016 using a VB script

    .USAGE
        activate.ps1
#>


# Activate Windows.
$computer = Get-Content $env:ComputerName
$service = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer
$service.InstallProductKey($key)
$service.RefreshLicenseStatus()

# Activate Office 2016.
& cscript "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS" /act

Write-Host "Windows 10 and Office 2016 are activated"