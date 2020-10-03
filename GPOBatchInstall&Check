@echo off

For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%a-%%b-%%c)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a:%%b)

IF EXIST "[InstallLocation]" (
	ECHO %mydate%_%mytime% "[software] is Installed" >> "C:\[software]Install.log"
) ELSE (
	IF NOT EXIST "[InstallLocation]" ECHO %mydate%_%mytime% "[software] has not been installed. Beginning transfer and install" >> "C:\[software]Install.log"
	IF NOT EXIST "C:\Install" ECHO %mydate%_%mytime% "C:\Install does not exist, creating directory now" >> "C:\[software]Install.log"
	IF NOT EXIST "C:\Install" MKDIR C:\Install
	IF EXIST "C:\Install" ECHO %mydate%_%mytime% "C:\Install directory is in place" >> "C:\[software]Install.log"
	IF NOT EXIST "C:\Install\[package].msi" ECHO %mydate%_%mytime% "[package].msi missing from C:\Install folder now copying over file" >> "C:\[software]Install.log"
	IF NOT EXIST "C:\Install\[package]" xcopy "\\remote\location\[fileorfolder]" C:\Install\ 
	TIMEOUT /T 10
	IF EXIST "C:\Install\[package]" ECHO %mydate%_%mytime% "[software] install file located on machine at C:\Install" >> "C:\[software]Install.log"
	IF NOT EXIST "[InstallLocation]" ECHO %mydate%_%mytime% "Will now use MsiExec to install [software]" >> "C:\[software]Install.log"
	IF NOT EXIST "[InstallLocation]" MSIEXEC.EXE /i "C:\Install\[package].msi" /q
	TIMEOUT /T 30
	IF EXIST "[InstallLocation]" ECHO %mydate%_%mytime% "[software] has been Installed" >> "C:\[software]Install.log"
)
