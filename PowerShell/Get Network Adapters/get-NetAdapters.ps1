add-content ".\log.csv" "Computer,Adapter Name,AdapterType,Enabled"
$computersList = Import-CSV ".\computers.csv" | 
ForEach-Object {
    $computer = $_.computer
	if (Test-Connection -ComputerName $computer -Quiet) {
		$adapters = (Get-WmiObject -Class Win32_NetworkAdapter -ComputerName $computer | select Name,AdapterType,NetEnabled)
		foreach($adapter in $adapters) {
			$adapterName = $adapter.Name
			$adapterType = $adapter.AdapterType
			$adapterEnabled = $adapter.NetEnabled
			add-content ".\log.csv" "$computer,$adapterName,$adapterType,$adapterEnabled"
		}
	} else {
		add-content ".\log.csv" "$computer is offline."
	}
}