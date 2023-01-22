param([Parameter(Mandatory)][String[]]$Extensions)
$regLocation = 'Software\Policies\Google\Chrome\ExtensionInstallForcelist'
if (!(Test-Path "HKLM:\$regLocation")) {
    [int]$count = 0
    New-Item -Path "HKLM:\$regLocation" -Force
}
foreach($ext in $Extensions) {
    if($ext) {
        [int]$count = (Get-Item "HKLM:\$regLocation").Count
        $regKey = $count + 1
        $regData = "$ext;https://clients2.google.com/service/update2/crx"
        New-ItemProperty -Path "HKLM:\$regLocation" -Name $regKey -Value $regData -PropertyType STRING -Force
    }
}