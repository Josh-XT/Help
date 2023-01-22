    <#
    .SYNOPSIS
        Disables a user account

    .PARAMETER $computer
        Name of the computer where the account resides

    .PARAMETER $username
        Username of the account to be disabled

    .USAGE
        disableAccount.ps1 [computer] [username]

    #>

param([string]$computer,[string]$username)

# Get user on the computer and disable it.
$User = [ADSI]"WinNT://$computer/$username,user"
$User.AccountDisabled = $true
$User.SetInfo()

# Get listing of local user accounts on the remote computer to confirm the account is disabled.
Get-WmiObject -Query "Select * from Win32_UserAccount Where LocalAccount = 'True'" -ComputerName $computer | Select-Object -ExpandProperty Name