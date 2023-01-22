param([string]$PCName,[string]$Domain,[string]$OU)
# Get credentials to join the domain with.
$cred = get-credential

# Add the computer to the domain in its correct OU path
Add-Computer -DomainName $Domain -Credential $cred -OUPath $OU

# Rename the PC (has to happen in this order or it doesn't work unfortunately.)
$Computer = Get-WmiObject Win32_ComputerSystem
$r = $Computer.Rename($PCName, $cred.GetNetworkCredential().Password, $cred.Username)