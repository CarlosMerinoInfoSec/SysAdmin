<#
.SYNOPSIS
	Quick overview iterate through profiles and replace specific file
.Description
	This script first copies the file from the network location to the local machine
	Then it goes through the list of users on the machine looking for the specific path
	in this case I wanted to look for a specific file in each of the users profile
	After it goes through the profiles and has the location of each one it then goes to each
	location and renames the files and then moves the new file into the location
	Utilizes the environment variables to give correct path
	Testing the path to iterate on a machine
	$_.FullName
	$_.DirectoryName
.Notes
	Author          : Carlos Merino
    Prerequisite    : User needs to be connected to network path
#>

$networkPath="\\configNEW.json"
$tempPath= "C:\Install\config.json"

# Copy file locally
Copy-Item -Path $networkPath -Destination $tempPath -Force

# Go through the user profiles looking for this specific file
Get-ItemProperty -Path 'C:\Users\*\file_we_want_to_replace_config.json' |

ForEach-Object {
# For each user profile that has the file rename it to old in case we need to revert
Rename-Item -Path $_.FullName -NewName "configOLD.json"
# From our temp path copy to the directories of the users
Copy-Item -Path $tempPath -Destination $_.DirectoryName
}