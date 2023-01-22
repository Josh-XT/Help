Param([Parameter(Mandatory=$true, ValueFromPipeline=$true)] $RegexSearchContext)
# Import the Active Directory module for the Get-ADComputer CmdLet
Import-Module ActiveDirectory

# Query Active Directory for computers running a Server operating system
$time = (Get-Date).AddDays(-30)
$Servers = Get-ADComputer -Filter {LastLogonTimeStamp -gt $time}

# Loop through the list to query each server for login sessions
$count = 0
ForEach ($Server in $Servers) {
    $ServerName = $Server.Name
    $count++
    # When running interactively, uncomment the Write-Host line below to show which server is being queried
    Write-Host "Querying $ServerName`t`t($count/"$Servers.Count")"

    # Run the qwinsta.exe and parse the output
    $queryResults = (qwinsta /server:$ServerName | foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv) 

    # Pull the session information from each instance
    ForEach ($queryResult in $queryResults) {
        $RDPUser = $queryResult.USERNAME
        $sessionType = $queryResult.SESSIONNAME

        # We only want to display where a "person" is logged in. Otherwise unused sessions show up as USERNAME as a number
        If (($RDPUser -match $RegexSearchContext) -and ($RDPUser -ne $NULL)) { 
            # When running interactively, uncomment the Write-Host line below to show the output to screen
            Write-Host $ServerName logged in by $RDPUser on $sessionType
            $SessionList = $SessionList + "`n`n" + $ServerName + " logged in by " + $RDPUser + " on " + $sessionType
        }
    }
}


# When running interactively, uncomment the Write-Host line below to see the full list on screen
$SessionList