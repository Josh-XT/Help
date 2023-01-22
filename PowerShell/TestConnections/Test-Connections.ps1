$db = Import-Csv ".\computerlist.csv" |
ForEach-Object {
    $computer = $_.computer
    if (Test-Connection -ComputerName $computer -Quiet) {
        Write-Host "ALIVE: $computer"
        Add-Content ".\log.txt" "ALIVE: $computer"
    } else {
        Write-Host "DEAD: $computer"
        Add-Content ".\log.txt" "ALIVE: $computer"
    }
}