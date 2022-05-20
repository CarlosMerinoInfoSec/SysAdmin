<#
Show the Chassis type of the machine cross reference with Microsft at this URL
https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-systemenclosure
#>

Get-CimInstance Win32_SystemEnclosure |
Select-Object -Property ChassisTypes