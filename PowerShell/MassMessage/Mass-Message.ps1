    <#
    .SYNOPSIS
        Send a message to a list of computers

    .DESCRIPTION
        Sends a message to a list of computers that pops
        up a message box on their desktop.

    .USAGE
        Add each computer to the computers.csv file that you would
        like to receive the message, then run "Mass-Message.ps1 [Message]"

    #>

param($Message)
$credential = get-credential
$computersList = Import-CSV ".\computers.csv" | 
ForEach-Object {
    $computer = $_.computer
	if((Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
		Invoke-Command -ComputerName $computer {msg.exe * $Args[0]}
		write-host "Message sent to $computer" -ForegroundColor Green
	} else {
		write-host "ERROR: $computer is OFFLINE" -ForegroundColor Red
	}
}