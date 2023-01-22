# This function will create a new Json file based on 
function splitJson($filePath, $sourceJsonFileName, $exportFileName, $apiPath) {
    $api = Get-Content -Raw -Path "$($filePath)\$($sourceJsonFileName)" | ConvertFrom-Json -AsHashTable
    $apiKeys = (Get-Content -Raw -Path "$($filePath)\$($sourceJsonFileName)" | ConvertFrom-Json -AsHashTable).paths.keys
    foreach($key in $apiKeys) {
        if(!$key.Contains($apiPath)) {
            $api.paths.Remove($key)
        }
    }
    ConvertTo-Json $api -Depth 100 | Set-Content "$($filePath)\$($exportFileName)"
    Write-Host "$($filePath)\$($exportFileName) was created."
}

$apiKeys = (Get-Content -Raw -Path "$($filePath)\$($sourceJsonFileName)" | ConvertFrom-Json -AsHashTable).paths.keys
foreach($key in $apiKeys) {
    $key.SubString(0,$key.IndexOf("/")[1])
}
splitJson -filePath "C:\temp" -sourceJsonFileName "CWM.json" -exportFileName "CWM-Company.json" -apiPath "/company/"