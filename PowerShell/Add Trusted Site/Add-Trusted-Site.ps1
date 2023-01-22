$url = ($ENV:URL).Split(".")
for($i=0; $i -lt ($url.count-1); $i++) {
    if($i -eq ($url.count - 2)) {
        $domain = "$($url[$i]).$($url[$i+1])"
    } else {
        $subdomain = $url[$i]
    }
}
if(!$subdomain) {
    $subdomain = "*"
}
$path = "HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$($domain)\$($subdomain)"
foreach($p in ($path.split("\"))) {
    if($p -ne "HKLM:") {
        $np = $path.SubString(0,($path.IndexOf($p)-1))
        $nPath = $path.SubString(0,($path.IndexOf($p)-1)) + "\" + $p
        if(!(Test-Path($nPath))) {
            New-Item -Path $np -Name $p
        }
    }
}
New-ItemProperty -Path $path -Name "https" -Value 2 -PropertyType "DWord" -Force | Out-Null
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
$users = (Get-ChildItem "HKU:\" | where-object { !$_.Name.Contains("Classes") }).Name.Replace("HKEY_USERS\","")
foreach($user in $users) {
    $path = "HKU:\$($user)\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$($domain)\$($subdomain)"
    foreach($p in ($path.split("\"))) {
        if($p -ne "HKU:") {
            $np = $path.SubString(0,($path.IndexOf($p)-1))
            $nPath = $path.SubString(0,($path.IndexOf($p)-1)) + "\" + $p
            if(!(Test-Path($nPath))) {
                New-Item -Path $np -Name $p
            }
        }
    }
    New-ItemProperty -Path $path -Name "https" -Value 2 -PropertyType "DWord" -Force | Out-Null
}