<#
.Description
	Revert the changes we made in All_Profiles_Replace_File.ps1
#>

# In the first script we renamed the config to OLD in case we
# needed to revert changes.  We need to identify which profiles
# have the old files
Get-ItemProperty -Path 'C:\Users\*\configOLD.json' |

ForEach-Object {
# For each user profile first delete the new config.json
Remove-Item -Path 'C:\Users\*\config.json'
# then use the full path file name and rename it back to the original
Rename-Item -Path $_.FullName -NewName "config.json" 
}
