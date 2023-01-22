function Get-AzureADBitLockerKeysForUser {
    <#
      .SYNOPSIS
      Retrieve BitLocker keys from all Azure AD devices belonging to a certain user.
      .DESCRIPTION
      Given a user's name or UPN, returns all available BitLocker keys associated with devices belonging to the user. The user running the function needs to have sufficient rights in Azure AD to view BitLocker keys.
      .EXAMPLE
      Get-AzureADBitLockerKeysForUser -Credential (Get-Credential) -SearchString "John Doe" | Format-Table
      .PARAMETER SearchString
      Name or UPN of the user whose keys to retrieve. Passed through to Get-AzureADUser -SearchString.
      .PARAMETER Credential
      If supplied, the credential object for the privileged user retrieving the keys.
      .NOTES
      filename: Get-AzureADBitLockerKeysForUser.ps1
      author: Gerbrand van der Weg
      blog: https://pwsh.nl
      created: 2018-10-26
      Access token code courtesy of Jos Lieben: https://www.lieben.nu/liebensraum/2018/07/retrieving-a-headless-silent-token-for-main-iam-ad-ext-azure-com-using-powershell/
    #>

    Param 
    (
        [parameter(Mandatory = $true)]
        [string]$SearchString,
        [pscredential]$Credential
    )

    Import-Module AzureRM.Profile
    if (Get-Module -Name "AzureADPreview" -ListAvailable) {
        Import-Module AzureADPreview
    } elseif (Get-Module -Name "AzureAD" -ListAvailable) {
        Import-Module AzureAD
    }

    if ($Credential) {
        Try {
            Connect-AzureAD -Credential $Credential -ErrorAction Stop | Out-Null
        } Catch {
            Write-Warning "Couldn't connect to Azure AD non-interactively, trying interactively."
            Connect-AzureAD -TenantId $(($Credential.UserName.Split("@"))[1]) -ErrorAction Stop | Out-Null
        }
    
        Try {
            Login-AzureRmAccount -Credential $Credential -ErrorAction Stop | Out-Null
        } Catch {
            Write-Warning "Couldn't connect to Azure RM non-interactively, trying interactively."
            Login-AzureRmAccount -TenantId $(($Credential.UserName.Split("@"))[1]) -ErrorAction Stop | Out-Null
        }
    } else {
        Connect-AzureAD -ErrorAction Stop | Out-Null
        Login-AzureRmAccount -ErrorAction Stop | Out-Null
    }

    $context = Get-AzureRmContext
    $tenantId = $context.Tenant.Id
    $refreshToken = @($context.TokenCache.ReadItems() | Where-Object {$_.tenantId -eq $tenantId -and $_.ExpiresOn -gt (Get-Date)})[0].RefreshToken
    $body = "grant_type=refresh_token&refresh_token=$($refreshToken)&resource=74658136-14ec-4630-ad9b-26e160ff0fc6"
    $apiToken = Invoke-RestMethod "https://login.windows.net/$tenantId/oauth2/token" -Method POST -Body $body -ContentType 'application/x-www-form-urlencoded'
    $header = @{
        'Authorization'          = 'Bearer ' + $apiToken.access_token
        'X-Requested-With'       = 'XMLHttpRequest'
        'x-ms-client-request-id' = [guid]::NewGuid()
        'x-ms-correlation-id'    = [guid]::NewGuid()
    }

    $userDevices = Get-AzureADUser -SearchString $SearchString | Get-AzureADUserRegisteredDevice -All:$true
    
    $bitLockerKeys = @()

    foreach ($device in $userDevices) {
        $url = "https://main.iam.ad.ext.azure.com/api/Device/$($device.objectId)"
        $deviceRecord = Invoke-RestMethod -Uri $url -Headers $header -Method Get
        if ($deviceRecord.bitlockerKey.count -ge 1) {
            $bitLockerKeys += [PSCustomObject]@{
                Device      = $deviceRecord.displayName
                DriveType   = $deviceRecord.bitLockerKey.driveType
                KeyId       = $deviceRecord.bitLockerKey.keyIdentifier
                RecoveryKey = $deviceRecord.bitLockerKey.recoveryKey
            }
        }
    }

    $bitLockerKeys
}