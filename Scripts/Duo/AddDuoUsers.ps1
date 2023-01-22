if((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain) {
    Start-Process -FilePath "wusa.exe" -ArgumentList "WindowsTH-RSAT_WS_1803-x64.msu /quiet /norestart" -Wait
    $domain = (Get-ADDomain).NetBIOSName
    if($domain) {
        $argList = "IKEY=""#" + $ENV:DUO_IKEY + """ SKEY=""#" + $ENV:DUO_SKEY + """ HOST=""#" + $ENV:DUO_HOST + """ AUTOPUSH=""#" + $ENV:AUTOPUSH + """ FAILOPEN=""#" + $ENV:FAILOPEN + """ SMARTCARD=""#" + $ENV:SMARTCARD + """ RDPONLY=""#" + $ENV:RDPONLY + """ UAC_PROTECTMODE=""#" + $ENV:UAC_PROTECTMODE + """ UAC_OFFLINE=""#" + $ENV:UAC_OFFLINE + """ UAC_OFFLINE_ENROLL=""#" + $ENV:UAC_OFFLINE_ENROLL + """ ENABLEOFFLINE=""#" + $ENV:ENABLEOFFLINE + """ USERNAMEFORMAT=""#" + $ENV:USERNAMEFORMAT + """ /qn"
        Start-Process ".\DuoWindowsLogon64.msi" -ArgumentList $argList -Wait
        $users = Get-ADUser -Filter * | Where-Object { $_.ObjectClass -eq "user" -and $_.Enabled -eq "True" -and $_.UserPrincipalName -ne $null }
        $path = "HKLM:\SOFTWARE\Duo Security\DuoCredProv\UsernameMap"
        foreach($p in ($path.split("\"))) {
            if($p -ne "HKLM:") {
                $np = $path.SubString(0,($path.IndexOf($p)-1))
                if(!(Test-Path($np))) {
                    New-Item -Path $np -Name $p
                }
            }
        }
        foreach($user in $users) {
            New-ItemProperty -Path $path -Name "$($domain)\$($user.SamAccountName)" -Value $user.UserPrincipalName -PropertyType "String" -Force | Out-Null
        }
    } else {
        write-host "ERROR: Unable to communicate with domain."
    }
} else {
    $argList = "IKEY=""#" + $ENV:DUO_IKEY + """ SKEY=""#" + $ENV:DUO_SKEY + """ HOST=""#" + $ENV:DUO_HOST + """ AUTOPUSH=""#" + $ENV:AUTOPUSH + """ FAILOPEN=""#" + $ENV:FAILOPEN + """ SMARTCARD=""#" + $ENV:SMARTCARD + """ RDPONLY=""#" + $ENV:RDPONLY + """ UAC_PROTECTMODE=""#" + $ENV:UAC_PROTECTMODE + """ UAC_OFFLINE=""#" + $ENV:UAC_OFFLINE + """ UAC_OFFLINE_ENROLL=""#" + $ENV:UAC_OFFLINE_ENROLL + """ ENABLEOFFLINE=""#" + $ENV:ENABLEOFFLINE + """ USERNAMEFORMAT=""#" + $ENV:USERNAMEFORMAT + """ /qn"
    Start-Process ".\DuoWindowsLogon64.msi" -ArgumentList $argList -Wait
}