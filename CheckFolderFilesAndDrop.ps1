<#

I made this because an application was not able to automatically pull files and drop it off in the folder,
so some functionality did not work.  This first checks to see if the folder exists, if it does then
it will check to see if the files exists.  If they don't exist then pull them from the network and drop off
at the specific location

#>

$checkIfFolderExist = "c:\ProgramData\checkIfFolderExists"
$checkifFileExist0 = "c:\ProgramData\CheckIfFileExists0"
$checkifFileExist1 = "c:\ProgramData\CheckIfFileExists1"

$networkPath0 = "\\RemoteLocation\File_Needed0"
$networkPath1 = "\\RemoteLocation\File_Needed1"

$addFile0 = "c:\ProgramData\DropOffFile.js"
$addFile1 = "c:\ProgramData\AnotherFileThatDidNotExist.js"


If((Test-Path $checkIfFolderExist)) {
    Write-Output "Folder exists returned true"
    if(!(test-path $checkifFileExist0) -or !(Test-Path $checkifFileExist1)) {
        Write-Output "2nd if statement returned true one or more files missing"
        Write-Output "All required files will be copied from sysvol folder"
        Copy-Item -Path $networkPath0 -Destination $addFile0 -Force
        Copy-Item -Path $networkPath1 -Destination $addFile1 -Force
       }
    } else {
# If the folder doesn't exist don't do anything
    Write-Output "Folder does not exist will not copy over files"
}