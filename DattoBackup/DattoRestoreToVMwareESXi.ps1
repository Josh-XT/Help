# Define the hostname for the VM to restore
$vmHostname = "hostname"

# Define the NFS share details
$nfsServer = "nfs.server.com"
$nfsPath = "/nfs/share"

# Define the datastore and folder details
$datastoreName = "datastore"
$vmFolderPath = "/vm/folder"

# Load the VMware ESXi PowerShell module
Import-Module VMware.VimAutomation.Core

# Connect to VMware ESXi host
$esxiHost = "esxi.server.com"
$esxiCredential = Get-Credential
Connect-VIServer -Server $esxiHost -Credential $esxiCredential

# Get the last verified backup of the specified hostname
$apiKey = "yourApiKey"
$apiSecret = "yourApiSecret"
$dattoUrl = "https://backupify.dattodrive.com/api/1.0"
$headers = @{
    Authorization = "Bearer $($apiKey):$($apiSecret)"
}
$backupListUrl = "$dattoUrl/backups?hostname=$vmHostname&verified_only=true"
$backupList = Invoke-RestMethod -Method Get -Uri $backupListUrl -Headers $headers
$lastBackupId = $backupList[0].id

# Create an image export as VMDK to NFS share
$exportUrl = "$dattoUrl/backups/$lastBackupId/export"
$exportBody = @{
    format = "vmdk"
    nfs_server = $nfsServer
    nfs_path = $nfsPath
}
Invoke-RestMethod -Method Post -Uri $exportUrl -Headers $headers -Body $exportBody

# Copy the files from NFS share to VMware ESXi
$vmName = "restored_vm"
$vmxFilePath = "$nfsPath/$vmName/$vmName.vmx"
$vmFolderPathOnEsxi = "$vmFolderPath/$vmName"
$vmxFilePathOnEsxi = "$vmFolderPathOnEsxi/$vmName.vmx"
New-Datastore -Nfs -VMHost $esxiHost -Name $datastoreName -Path $nfsServer
New-Item -ItemType Directory -Path $vmFolderPathOnEsxi
Copy-DatastoreItem -Item "$vmxFilePath" -Destination "$vmxFilePathOnEsxi" -VMHost $esxiHost

# Modify the vmx to modify the first drive to C, second to E, third to F, etc.
$vm = Get-VM -Name $vmName
$vmxPath = $vm.ExtensionData.Config.Files.VmPathName
$vmxContents = Get-Content $vmxPath
$disks = Get-HardDisk -VM $vm
$i = 0
foreach ($disk in $disks) {
    $driveLetter = [char]([int][char]'C' + $i)
    $vmxContents = $vmxContents -replace "scsi0:0\.fileName = \`".+\`"`", `"scsi0:$i.fileName = `"$($vmFolderPathOnEsxi)/$($vmName)/$($driveLetter).vmdk\`""
    $i++
}
Set-Content $vmxPath -Value $vmxContents

# Disconnect from VMware ESXi host
Disconnect-VIServer -Server $esxiHost -Confirm:$false
