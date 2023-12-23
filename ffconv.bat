@echo off
rem Wrapper for Windows' ffmpeg function

setlocal EnableDelayedExpansion

set exitVal=0

set cwd=%cd%
set converter=ffmpeg

set miNombre=%0

for %%F in (%miNombre%) do (
	set logFileName=%%~nF.log
)

rem Clean out previous log files

set logFile="%cwd%\%logFileName%"
if exist %logFile% (
	del %logFile%
)

if '%1' == '' goto USAGE
if '%2' == '' goto USAGE

set tempLogFile="%TEMP%\%logFileName%"
if exist %tempLogFile% (
	del %tempLogFile%
)

rem Get Args in the right places -----------------------------------------------

set inFile=%3
set outExt=%2
set delArg=%1

if "%inFile%" == "" (
	set inFile=%outExt%
	set outExt=%delArg%
	set delArg=
) else (
    rem Delete arg exists. Check it.
	if not %delArg% == -delete if not %delArg% == -del if not %delArg% == -d goto USAGE
)

rem ----------------------------------------------------------------------------

if not exist %inFile% (
	echo %inFile% does not exist
	goto EXIT
)

rem ----------------------------------------------------------------------------

for %%F in (%inFile%) do (
	set dotExt=%%~xF
)
set inExt=%dotExt:~1%

if %inExt% == %outExt% (
	echo Input file extension "%inExt%" is same as output extension. No conversion.
	goto EXIT
)

for %%F in (%inFile%) do (
	set outName="%%~nF"
)
set outFile="%outName:"=%.%outExt%"

if exist %outFile% (
	set overwrite=
	set /p overwrite=Output file !outfile! already exists. Overwrite? [y/n] 
	if NOT "!overwrite:~0,1!" == "y" if NOT "!overwrite:~0,1!" == "Y" goto EXIT
	echo Deleting !outfile!
	del /f !outFile!
)

echo Converting %inFile% to %outExt%
echo ^>%converter% -i %inFile% %outFile% 1>> %tempLogFile% 2>&1
%converter% -i %inFile% %outFile% 1>> %tempLogFile% 2>&1
set exitVal=%errorlevel%

if not %exitVal% equ 0 (
	copy %tempLogFile% %logFile% 1> NUL
) else if exist %tempLogFile% (
	del %tempLogFile%
)

if not exist %outFile% (
	echo %outFile% does not exist
	goto EXIT
)

if NOT "%delArg%" == "" (
	echo Removing %inFile%
	del %inFile%
)

echo %outFile% created
goto EXIT

rem ============================================================================

:USAGE
echo USAGE: %0 [-delete] outType inFile
echo   If error occurs, output from ffmpeg will appear in %logFile%
goto EXIT


:EXIT
if not %exitVal% == 0 (
	echo Error occurred. See %logFile% for more info
)

exit /b %exitVal%
