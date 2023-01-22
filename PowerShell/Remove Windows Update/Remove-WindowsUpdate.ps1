
Function Remove-WindowsUpdate {
    [CmdletBinding()]  
      param (  
           [parameter(Mandatory=$True)] $RemoveKB
     )

 $Searcher = New-Object -ComObject Microsoft.Update.Searcher
 $RemoveCollection = New-Object -ComObject Microsoft.Update.UpdateColl

 #Gather All Installed Updates
 $SearchResult = $Searcher.Search("IsInstalled=1")

 #Add any of the specified KBs to the RemoveCollection
 $SearchResult.Updates | ? { $_.KBArticleIDs -in $RemoveKB } | % { $RemoveCollection.Add($_) }

 if ($RemoveCollection.Count -gt 0) {
  $Installer = New-Object -ComObject Microsoft.Update.Installer
  $Installer.Updates = $RemoveCollection
  $Installer.Uninstall()
 } else { Write-Warning "No matching Windows Updates found for:`n$($RemoveKB|Out-String)" }
}