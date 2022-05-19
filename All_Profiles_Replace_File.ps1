# Quick overview iterate through profiles and replace specific file
# This script first copies the file from the network location to the local machine
# Then it goes through the list of users on the machine looking for the specific path
# in this case I wanted to look for a specific file in each of the users profile
# After it goes through the profiles and has the location of each one it then goes to each
# location and renames the files and then moves the new file into the location
# Utilizes the environment variables to give correct path

$networkPath="\\file_that_will_replace"
$localPath= "C:\File_location.json"

Copy-Item -Path $networkPath -Destination $jsonPath -Force
Get-ItemProperty -Path 'C:\Users\*\file_we_want_to_replace' |
ForEach-Object {
Rename-Item -Path $_.FullName -NewName "quest_login_settingsOLD.json"
Copy-Item -Path $localPath -Destination $_.DirectoryName
# Testing the path to iterate on a machine
# $_.Name
# $_.FullName
# $_.DirectoryName
}