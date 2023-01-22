    <#
    .SYNOPSIS
        Delete User Profiles older than 14 days from a list of computers

    .DESCRIPTION
        Retrieve a list of computers from computers.csv
        and delete user profiles older than 14 days

    .USAGE
        Add each computer to the computers.csv file that you would
        like to scan and remove profiles from, then run Delete-OldProfiles.ps1

    #>

Import-CSV ".\computers.csv" | ForEach-Object {
    $computer = $_.computer
	if((Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
        Get-WMIObject -class Win32_UserProfile -ComputerName $computer | Where-Object {(!$_.Special) -and ($_.ConvertToDateTime($_.LastUseTime) -lt (Get-Date).AddDays(-14))} | Remove-WmiObject
        Write-Host "Removed old profiles from $computer"
	} else {
		write-host "$computer is OFFLINE"
	}
}