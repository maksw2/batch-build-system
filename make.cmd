@echo off
title compiling
setlocal enabledelayedexpansion
if "%~1"=="" (set "execname=main.exe") else set "execname=%~1"
set filelist=filelist.txt
set config=config.txt

if not exist %filelist% (
    goto listmissing
) else if "%filelist%" == "0" ( 
    goto listempty
)

set /a linecount=0
set /a currentline=1
for /f "tokens=*" %%a in (%filelist%) do (
    set line[!currentline!]=%%a
    set /a linecount+=1
    set /a currentline+=1
)

set /a linecount2=0
set /a currentline2=1
for /f "tokens=*" %%a in (%config%) do (
    set configline[!currentline2!]=%%a
    set /a linecount2+=1
    set /a currentline2+=1
)

set "link_files="
:: variable to store all files to link
for /l %%i in (1,1,%linecount%) do (
    set "link_files=!link_files! !line[%%i]!.o"
)

:compile
:: compile part of the program
for /l %%i in (1,1,%linecount%) do (
    set "source_file=!line[%%i]!.cpp"
    set "output_file=!line[%%i]!.o"
    echo compiling !source_file!
    g++ -c "!source_file!" -o "!output_file!" %configline[0]% || goto compileerror
)

goto link

:link
:: link part of the program
echo linking...
g++ -o "%execname%" %link_files% || goto linkerror
:: linked all files
goto strip

:strip
echo stripping...
strip "%execname%"
goto clean

:clean
echo cleaning...
del /Q %link_files%
goto exit

:compileerror
:: a compile error has occurred, exit
echo a compiling error has occurred!
echo press any key to exit..
pause > nul
exit 1

:linkerror
:: a link error has occurred, exit
echo a link error has occurred!
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
:: exit
