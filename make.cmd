@echo off
title compiling
setlocal enabledelayedexpansion
if "%~1"=="" (set "execname=main.exe") else set "execname=%~1"
:: sets basic things
set filelist=filelist.txt
:: set the filelist variable

if not exist %filelist% (
    goto listmissing
) else if "%~z1" == "0" ( 
    goto listempty
)

set /a linecount=0
set /a currentline=1
for /f "tokens=*" %%a in (%filelist%) do (
    set line[!currentline!]=%%a
    set /a linecount+=1
    set /a currentline+=1
)

:: reads the file list and puts them into a variable
:: also stores how many variables/lines there are
set "link_files="
:: variable to store all files to link
for /l %%i in (1,1,%linecount%) do (
    set "link_files=!link_files! !line[%%i]!.o"
)
goto compile

:compile
:: compile part of the program
for /l %%i in (1,1,%linecount%) do (
    echo compiling !line[%%i]!.cpp
    g++ -c !line[%%i]!.cpp || goto compileerror
)
:: compiled all files
goto link

:link
:: link part of the program
:: links all files together to an exe
echo linking...
g++ -o %execname% %link_files% || goto linkerror
:: linked all files
goto clean

:clean
echo cleaning...
del /Q %link_files%
goto exit

:compileerror
:: a compile error has occured, exit
echo a compiling error has occured!
echo press any key to exit..
pause > nul
exit 1

:linkerror
:: a link error has occured, exit
echo a link error has occured!
echo press any key to exit..
pause > nul
exit 1

:listmissing
:: file list is missing, exit
echo file list is missing!
echo press any key to exit..
pause > nul
exit 1

:listempty
:: file list is empty, exit
echo file list is empty!
echo press any key to exit..
pause > nul
exit 1

:exit
echo press any key to exit..
pause > nul
exit