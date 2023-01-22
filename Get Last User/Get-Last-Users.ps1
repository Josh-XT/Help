#param($computer, $user)
$cred = get-credential
add-content .\pcs.csv "computer,user"
Import-CSV ".\computers.csv" | ForEach-Object {
    $computer = $_.computer
	if(test-connection $computer -Quiet) {
		$user = (Get-WmiObject -ComputerName $computer -Class Win32_ComputerSystem -Credential $cred).UserName
	} else {
		$user = "OFFLINE"
	}
	add-content .\pcs.csv "$computer,$user"
}