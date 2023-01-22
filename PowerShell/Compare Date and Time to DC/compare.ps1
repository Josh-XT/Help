$dc = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History" -Name "DCName").DCName.Split(".")[0]
$dc = $dc.SubString(2,$dc.Length-2)
$dcDT = (Invoke-Command -ComputerName $dc -Command { Get-Date })
$currentDT = (Get-Date)
if($currentDT -eq $dcDT) {
    write-host "Date and time are correct."
    write-host "DC time: $($dcDT) vs PC time: $($currentDT)"
} else {
    write-host "Date and time are wrong!"
    write-host "DC time: $($dcDT) vs PC time: $($currentDT)"
}