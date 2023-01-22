    <#
    .SYNOPSIS
        Get the Operating System version from a computer

    .PARAMETER $computer
        Name of the computer you want to retrieve the
        OS version from.

    #>
param([string]$Computer)

(Get-WmiObject -Computer $Computer -Class Win32_OperatingSystem).Caption