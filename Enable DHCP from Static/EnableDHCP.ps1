$NICs = Get-NetIPInterface -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like "Ethernet*"}
foreach($nic in $NICs) {
    <#if($nic.Dhcp = "Enabled") {
        $interface = Get-NetIPInterface -InterfaceAlias $nic.InterfaceAlias -AddressFamily IPv4
        $interface | Remove-NetRoute -AddressFamily IPv4 -Confirm:$false
        $interface | Set-NetIPInterface -Dhcp Enabled
        $interface | Set-DnsClientServerAddress -ResetServerAddresses
    }
    #>
    if($nic.Dhcp -eq "Disabled") {
        Write-Host $nic.InterfaceAlias "is set to" $nic.Dhcp "on $ENV:COMPUTERNAME"
    }
}