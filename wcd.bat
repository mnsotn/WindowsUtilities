@echo off

set destDir=%*
set problemWithCd=

if "%destDir%" == "" (
	goto Exit
)

rem See if going to previous directory
if "%destDir%" == "-" (
	set destDir=%prevDir%
)

rem get drive letter of where we are
rem will always work
set currDir=%cd%
call :GetDriveLetter %currDir%
set currDrive=%_drive%

rem get drive letter of where we want to go
call :GetDriveLetter %destDir%
set destDrive=%_drive%

vol %destDrive%: > NUL 2> NUL
if errorlevel 1 (
	rem User didn't give a drive letter -> dest dir is on this drive
	set destDrive=%currDrive%
)

%destDrive%:
cd "%destDir%" 1> NUL 2> NUL
if %errorlevel% == 1 (
	set problemWithCd=true
)

goto Exit

#==============================================================================#
:GetDriveLetter
set _path=%~1

set "_drive=%_path:~0,1%"
FOR %%i IN ("a=A" "b=B" "c=C" "d=D" "Y=y" "Z=z") DO CALL SET "_drive=%%_drive:%%~i%%"

set _path=

exit /b 0
#------------------------------------------------------------------------------#
:Exit


if "%problemWithCd%" == "true" (
	echo Problem going to %destDir%
	exit /b 1
)
if not "%currDir%" == "%cd%" (
	set prevDir=%currDir%
)

set _drive=
set destDrive=
set destDir=
set currDrive=
set currDir=
set problemWithCd=