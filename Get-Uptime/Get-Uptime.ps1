#requires -version 2

<#
.SYNOPSIS
Outputs the last bootup time and uptime for one or more computers.

.PARAMETER ComputerName
One or more computer names. The default is the current computer. Wildcards are not supported.

.PARAMETER Credential
Specifies credentials that have permission to connect to the remote computer. This parameter is ignored for the current computer.

.OUTPUTS
PSObjects containing the computer name, the last bootup time, and the uptime.
#>

[CmdletBinding()]
param(
  [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    $ComputerName,
  [System.Management.Automation.PSCredential]
    $Credential
)

begin {
  function Out-Object {
    param(
      [System.Collections.Hashtable[]] $hashData
    )
    $order = @()
    $result = @{}
    $hashData | ForEach-Object {
      $order += ($_.Keys -as [Array])[0]
      $result += $_
    }
    New-Object PSObject -Property $result | Select-Object $order
  }

  function Format-TimeSpan {
    process {
      "{0:0}d {1:0}h {2:0}m {3:0}s" -f $_.Days,$_.Hours,$_.Minutes,$_.Seconds
    }
  }

  function Get-Uptime {
    param(
      $computerName,
      $credential
    )
    # In case pipeline input contains ComputerName property
    if ( $computerName.ComputerName ) {
      $computerName = $computerName.ComputerName
    }
    if ( (-not $computerName) -or ($computerName -eq ".") ) {
      $computerName = [Net.Dns]::GetHostName()
    }
    $params = @{
      "Class" = "Win32_OperatingSystem"
      "ComputerName" = $computerName
      "Namespace" = "root\CIMV2"
    }
    if ( $credential ) {
      # Ignore -Credential for current computer
      if ( $computerName -ne [Net.Dns]::GetHostName() ) {
        $params.Add("Credential", $credential)
      }
    }
    try {
      $wmiOS = Get-WmiObject @params -ErrorAction Stop
    }
    catch {
      Write-Error -Exception (New-Object $_.Exception.GetType().FullName `
        ("Cannot connect to the computer '$computerName' due to the following error: '$($_.Exception.Message)'",
        $_.Exception))
      return
    }
    $lastBootTime = [Management.ManagementDateTimeConverter]::ToDateTime($wmiOS.LastBootUpTime)
    Out-Object `
      @{"Computer Name" = $computerName},
      @{"Last Boot Time" = $lastBootTime},
      @{"Uptime"       = (Get-Date) - $lastBootTime | Format-TimeSpan} | Format-List
  }
}

process {
  if ( $ComputerName ) {
    foreach ( $computerNameItem in $ComputerName ) {
      Get-Uptime $computerNameItem $Credential
    }
  }
  else {
    Get-Uptime "."
  }
}