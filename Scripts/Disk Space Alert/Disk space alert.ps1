$driveThreshold = $ENV:driveThreshold
if(!$driveThreshold) {
  $driveThreshold = 80
}
if($driveThreshold.Contains("%")) {
  $driveThreshold = ($driveThreshold -replace '[^a-zA-Z0-9]', '')
}
$driveThreshold = 100 - $driveThreshold

$disks = Get-WmiObject win32_logicaldisk
foreach($disk in $disks) {
    $freeSpace = [math]::Round(($disk.FreeSpace / $disk.Size) * 100),1)
    if($freeSpace -le $driveThreshold) {
        $letter = $disk.DeviceID
        $pc = $env:ComputerName
        write-host "<-Start Result->"
        write-host "$pc: $freeSpace% on $letter"
        write-host "<-End Result->"
        exit 1
    }
}

exit 0