@echo off

set sdir=%CD%

rem === SOURCE ===

set sfile=%1

if X%sfile%X == XX (
goto NOFILE
)

if not exist %sfile% (
  goto NOEXISTSFILE
)

for /f %%a in ( "%sfile%" ) do set name=%%~na
for /f %%a in ( "%sfile%" ) do set ext=%%~xa

set spath=%sdir%\%name%%ext%

if not exist %spath% (
   goto NOEXISTSPATH
)

rem === DESTINATION ===

set ddir=%sdir%\old

if not exist %ddir% (
   echo Creating %ddir%
   mkdir %ddir%
   if not exist %ddir% (
      goto NOEXISTDDIR
   )
)

set today=%date:~10,4%%date:~4,2%%date:~7,2%

set dfile=%name%_%today%%ext%

set dpath=%ddir%\%dfile%

if exist %dpath% (
   goto EXISTDPATH
)

copy %spath% %dpath% > NUL

if not exist %dpath% (
  goto BADCOPY
)

echo Archive %dpath% created

goto END

:BADCOPY
echo Problem archiving %name%
goto END

:EXISTDPATH
echo Destination %dpath% exists
goto END

:NOEXISTDDIR
echo Destination directory %ddir% does not exist
goto END

:NOEXISTSFILE
echo Source file %sfile% does not exist
goto END

:NOEXISTSPATH
echo Source %spath% does not exist
goto END

:NOFILE
echo No file specified
goto END

:END
