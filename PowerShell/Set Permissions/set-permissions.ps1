$folders = Get-ChildItem "D:\users\redirected" -Directory
foreach ($user in $folders) {
	$dir = "D:\users\redirected\" + $user
	$Acl = Get-Acl -Path $dir;
    $Everyone = $Acl.Access.Where({ $PSItem.IdentityReference -eq 'Everyone' });
    foreach ($Ace in $Everyone) {
        [void] $Acl.RemoveAccessRule($Ace);
    }
    Set-Acl -Path $user.FullName -AclObject $Acl;
	$ad = ([ADSISearcher] "(sAMAccountName=$user)").FindOne()
	if($ad -ne $null) {
		$Acl = Get-Acl $dir
		$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($user, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
		$Acl.SetAccessRuleProtection($True, $True)
		$Acl.SetAccessRule($Ar)
		Set-Acl $dir $Acl
		Add-Content ".\successlog.txt" "Permissions set for $user for $dir"
		write-host "Permissions set for $user for $dir"
	} else {
		Add-Content ".\errlog.txt" "$user does not exist in AD."
		$archivedir = "D:\users\redirected\Archive\" + $user
		Move-Item $dir $archivedir
		write-host "$user does not exist in AD."
	}
}

