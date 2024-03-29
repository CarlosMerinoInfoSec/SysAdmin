<#
.SYNOPSIS
    This script will check to see if NxLog is installed, if not an attempt to copy Nxlog file from a 
    network share to a local directory, and installation of nxlog will be done.  Nxlog also requires a conf file so 
    we will be replacing the one in the installation directory with the correct one and starting the service.
.DESCRIPTION
    Test locally and ensure the script runs as intended before automating deployments.
    Checks to see if Nxlog is installed if not then checks to see if the Nxlog MSI file is on the local 
    drive, if it is, it will install.  If it is not found locally it will try and connect to the network share 
    to copy and place on the local drive and then will run the installation.  If it can't connect to the remote
    share it will throw an exception and cancel the script.
.NOTES
    File Name       NxLogInstall&ReplaceDefaultConfig.ps1
    Author          :Carlos Merino
    Prerequisite    :If user is not connected to network and does not have msi file locally, script will throw exception.
#>

############# Adjust the settings in this block as needed #############
$networkPath = '\\[remote]\[network]\nxlog-ce.msi'
$networkPath2 = '\\[remote]\[network]\nxlog.conf'
$msiPath = 'C:\Install\nxlog-ce.msi'
$confPath = 'C:\Install\nxlog.conf'
$confPath2 = 'C:\Program Files (x86)\nxlog\conf\nxlog.conf'
$software = "NXLog-ce";
$ServiceName = 'nxlog'
$application = Get-Service -Name $ServiceName
$installed = (Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 
              'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | 
              Where { $_.DisplayName -eq $software }) -ne $null
#######################################################################



If($installed) {
    # Application is installed. Will now exit.
	Write-Host "'$software' is installed."
    $installed = $true
    #Application is NOT installed will run script.
} elseif(Test-Path $msiPath) {
    Write-Output "$software was not found.  Will now run script to install $software"
    Write-Output "MSI is at $msiPath.  Will now begin installation"
    Start-Process -FilePath	msiexec.exe -ArgumentList '/i "C:\Install\nxlog-ce.msi" /qn' -Wait -PassThru -ErrorAction Stop
  #If MSI file is not in directory connect to network share and copy file to local then install.
} elseif(Test-Path -Path $networkPath) {
    Write-Output "MSI could not be found at $msiPath, will now try and copy file from network share"
    Write-Output "Attemting to copy $networkPath to $msiPath"
    Copy-Item -Path $networkPath -Destination $msiPath -Force
    Start-Sleep -Seconds 3
    Write-Output "MSI is at $msiPath.  Will now begin installation"
    Start-Process -FilePath	msiexec.exe -ArgumentList '/i "C:\Install\nxlog-ce.msi" /qn' -Wait -PassThru -ErrorAction Stop
    Start-Sleep -Seconds 5
} else {
    #If unable to reach remote network throw exception stating reason
    throw "$networkPath is not accessible.  Verify computer is connected to network and/or file is at $networkPath"
        }

If($application.Status -ne 'Running') {
    Write-Output "Removing default nxlog.conf file"
    Remove-Item -Path "C:\Program Files (x86)\nxlog\conf\nxlog.conf"
    Start-Sleep -Seconds 5
    Write-Output "Copying remote conf file to local C:\Install folder"
    Copy-Item -Path $networkPath2 -Destination $confPath -Force
    Start-Sleep -Seconds 5
    Write-Output "Copying local conf file to C:\Program Files (x86)\nxlog\conf\nxlog.conf"
    Copy-Item -Path $confPath -Destination $confPath2 -Force
    Start-Sleep -Seconds 5
    Start-Service $ServiceName
    Write-Host 'Started nxlog service'
    Start-Sleep -Seconds 30
    Get-Service -Name $ServiceName
} else {
    Write-Host 'nxlog is' $application.status
}
