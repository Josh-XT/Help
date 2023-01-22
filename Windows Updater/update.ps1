$thisComputer = $env:COMPUTERNAME

#Search for relevant updates.
$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$SearchResult = $Searcher.Search("IsInstalled=0 and Type='Software'").Updates

# Make sure Search result is not null
if(!$SearchResult) {
	#Download updates.
	Write-Host "Downloading updates..."
	$Session = New-Object -ComObject Microsoft.Update.Session
	$Downloader = $Session.CreateUpdateDownloader()
	$Downloader.Updates = $SearchResult
	$Downloader.Download()

	#Install updates.
	Write-Host "Installing updates..."
	$Installer = New-Object -ComObject Microsoft.Update.Installer
	$Installer.Updates = $SearchResult
	$Result = $Installer.Install()

	#Reboot if required by updates.
	If ($Result.rebootRequired) {
		
		$timeStamp = get-date -Format hh:mm
		$todaysDate = get-date -format D
		$Message.Body = $RebootResult
		shutdown.exe /t 0 /r 
	}
	If (!$Result.rebootRequired) {
		$timeStamp = get-date -Format hh:mm
		$todaysDate = get-date -format D
		Write-Host $thisComputer + " has installed its updates and did not require a reboot."
	}
} else { #If there are no updates, inform the user.
	Write-Host "No updates to install"
}