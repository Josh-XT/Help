function Write-Alert
{
    param([string]$Alert)
    Write-Host "<-Start Result->"
    Write-Host "CSMon_Result="$Alert
    Write-Host "<-End Result->"
    exit 1
}

$certs = "Cert:\LocalMachine" | Get-ChildItem
foreach($cert in $certs) {
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store($cert.Name,"LocalMachine")
    $store.Open("ReadOnly")
    for($i = 0; $i -lt $store.Certificates.count; $i++) {
        if(($store.Certificates[$i].NotAfter - (Get-Date)).Days -le 30) {
            $issuer = $($store.Certificates[$i].Issuer.Split(",")[0] -Replace "CN=", "")
            if(!$issuer.Contains("Microsoft")) {
                Write-Host "$($cert.name), $($store.Certificates[$i].Issuer.Split(",")[0] -Replace "CN=", ''), $($store.Certificates[0].FriendlyName), $($store.Certificates[$i].NotAfter)"
            }
        }
    }
}

#ExitWithCode
if ($flag -eq 1) {  
    Write-Alert $outprint
} else {
    exit 0
}

