$intune = Import-CSV ".\intune.csv"
$sccm = Import-CSV ".\sccm.csv" | 
ForEach-Object {
    $computer = $_.computer
	$intuneComputer = $intune | where-object { $computer -in $_.computer }
	if($intuneComputer) {
		# Matches
	} else {
		write-host $computer
		add-content "missing-from-intune.csv" $computer
	}
}