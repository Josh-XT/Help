# Download the zip
Invoke-WebRequest -Uri "https://dl.duosecurity.com/DuoWinLogon_MSIs_Policies_and_Documentation-latest.zip" -OutFile "Duo.zip"

# Extract the zip
Expand-Archive -Path "Duo.zip" -DestinationPath .

# Run the msi
$argList = "IKEY=""#" + $ENV:DUO_IKEY + """ SKEY=""#" + $ENV:DUO_SKEY + """ HOST=""#" + $ENV:DUO_HOST + """ AUTOPUSH=""#" + $ENV:DUO_AUTOPUSH + """ FAILOPEN=""#1"" SMARTCARD=""#0"" RDPONLY=""#0"" UAC_PROTECTMODE=""#2"" UAC_OFFLINE=""#1"" UAC_OFFLINE_ENROLL=""#1"" ENABLEOFFLINE=""#1"" USERNAMEFORMAT=""#0"" /qn"
Start-Process ".\DuoWindowsLogon64.msi" -ArgumentList $argList -Wait