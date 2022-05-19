<#
.SYNOPSIS
	Quick overview iterate through user profiles and read registry key AutoConfigURL in Internet Settings
.Description
	Use Regex to look for certain profiles, then pull all the interesting information, also make it so 
    path to ntuser.dat is made, load the user profile hive including those not currently logged in,
    for each of the profiles run the commands to check if the path does exist, check the value of,
    the AutoConfigURL registry key, SUPRESS ERRORS, because many may not have the key created.
    This is made to be run from a deployment tool so System will be running it and go through each profile
    without only reading it's own profile
    
#>

# Regex pattern for SIDs
$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'

# Get Username, SID, and location of ntuser.dat for all users
$ProfileList = gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | 
Where-Object {$_.PSChildName -match $PatternSID} | 
Select  @{name="SID";expression={$_.PSChildName}}, 
        @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}}, 
        @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}

# Get all user SIDs found in HKEY_USERS (ntuder.dat files that are loaded)
$LoadedHives = gci Registry::HKEY_USERS | ? {$_.PSChildname -match $PatternSID} | Select @{name="SID";expression={$_.PSChildName}}

# Get all users that are not currently logged
$UnloadedHives = Compare-Object $ProfileList.SID $LoadedHives.SID | Select @{name="SID";expression={$_.InputObject}}, UserHive, Username

# Loop through each profile on the machine
Foreach ($item in $ProfileList) {
    # Load User ntuser.dat if it's not already loaded
    IF ($item.SID -in $UnloadedHives.SID) {
        reg load HKU\$($Item.SID) $($Item.UserHive) | Out-Null
    }

    #####################################################################

    # This is where you can read/modify a users portion of the registry 

 $checkIfRegistryPathExist = "registry::HKEY_USERS\$($Item.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"

    # Word

If((Test-Path $checkIfRegistryPathExist)) {
Write-Output "Paths exists"
    Get-ItemProperty -Path "registry::HKEY_USERS\$($Item.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" | Select-Object -ExpandProperty AutoConfigURL -ErrorAction SilentlyContinue
} else {
Write-Output "does not exist"
} 

    #####################################################################

    # Unload ntuser.dat        

    IF ($item.SID -in $UnloadedHives.SID) {
        ### Garbage collection and closing of ntuser.dat ###
        [gc]::Collect()
        reg unload HKU\$($Item.SID) | Out-Null
    }
}