# Requires environment variables for BLUESHIFT_INTERNAL_SERVER, BLUESHIFT_EXTERNAL_SERVER, and BLUESHIFT_PASSWORD
# You can get those values from the Blueshift package in the XDR Console
# This script will check if the machine is a Windows Server and if it can reach the internal server
# If it can reach the internal server, it will install the local agent
# If it cannot reach the internal server, it will install the remote agent
# The remote agent will be installed on all other machines.
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
if($osInfo.ProductType -eq 3) { # If it is a server
    if(Test-Connection $ENV:BLUESHIFT_INTERNAL_SERVER) { # If it can reach the internal server
        Write-Host "Blueshift local agent install."
        $server = $ENV:BLUESHIFT_INTERNAL_SERVER
    } else { # 
        Write-Host "Blueshift remote agent install."
        $server = $ENV:BLUESHIFT_EXTERNAL_SERVER
    }
} else {
    Write-Host "Blueshift remote agent install."
    $server = $ENV:BLUESHIFT_EXTERNAL_SERVER
}
New-NetFirewallRule -DisplayName "Wazuh Agent" -Direction outbound -Profile Any -Action Allow -LocalPort 1514,1515 -Protocol TCP
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://xdrapi.xdrinc.com/xdr_install/agents/4.2.7-1/windows/wazuh-agent.msi -outfile wazuh-agent.msi
Start-Process 'msiexec.exe' -ArgumentList "/I `"wazuh-agent.msi`" WAZUH_MANAGER=`"$($server)`" WAZUH_REGISTRATION_SERVER=`"$($server)`" WAZUH_REGISTRATION_PASSWORD=`"$($ENV:BLUESHIFT_PASSWORD)`" WAZUH_AGENT_GROUP=`"default`" /qn" -Wait
$Path = Get-ChildItem -Path "C:\Program Files*\ossec-agent\" -include 'local_internal_options.conf' -Recurse -ErrorAction SilentlyContinue
Add-Content $Path "`nwazuh_command.remote_commands=1"
Restart-Service -Name WazuhSvc