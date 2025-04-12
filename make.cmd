@echo off
title batch build system
setlocal enabledelayedexpansion

:: Set ESC variable
call :setESC

:: Predefine common colors using delayed expansion-safe syntax
set "RESET=!ESC![0m"
set "RED=!ESC![31m"
set "GREEN=!ESC![32m"
set "YELLOW=!ESC![33m"
set "CYAN=!ESC![36m"

:: Fancy header
set "BANNER_COLOR=!ESC![1;94m"  :: bold blue
set "SUB_COLOR=!ESC![2;37m"     :: dim white
set "RESET=!ESC![0m"

cls
echo !BANNER_COLOR!
echo            _           _       _        _           _ _     _                  _
echo           ^| ^|         ^| ^|     ^| ^|      ^| ^|         (_) ^|   ^| ^|                ^| ^|
echo    __ _   ^| ^|__   __ _^| ^|_ ___^| ^|__    ^| ^|__  _   _ _^| ^| __^| ^|   ___ _   _ ___^| ^|_ ___ _ __ ___
echo   / _` ^|  ^| '_ \ / _` ^| __/ __^| '_ \   ^| '_ \^| ^| ^| ^| ^| ^|/ _` ^|  / __^| ^| ^| / __^| __/ _ \ '_ ` _ \
echo  ^| (_^| ^|  ^| ^|_) ^| (_^| ^| ^|^| (__^| ^| ^| ^|  ^| ^|_) ^| ^|_^| ^| ^| ^| (_^| ^|  \__ \ ^|_^| \__ \ ^|^|  __/ ^| ^| ^| ^| ^|
echo   \__,_^|  ^|_.__/ \__,_^|\__\___^|_^| ^|_^|  ^|_.__/ \__,_^|_^|_^|\__,_^|  ^|___/\__, ^|___/\__\___^|_^| ^|_^| ^|_^|
echo                                                                       __/ ^|
echo                                                                      ^|___/
echo !RESET!
echo.

:: Default executable name
set "execname=main.exe"
if not "%~1"=="" set "execname=%~1"

set "filelist=filelist.txt"
set "config=config.txt"

:: Check if file list exists
if not exist "%filelist%" (
    echo !RED!Error: File list "%filelist%" is missing!%RESET%
    goto waitexit
)

:: Read config flags (first line only)
set "flags="
for /f "usebackq tokens=*" %%c in ("%config%") do (
    set "flags=%%c"
    goto :breakcfg
)
:breakcfg

:: Compile source files
set "obj_files="
for /f "usebackq tokens=*" %%f in ("%filelist%") do (
    set "src=%%f"
    set "obj=%%f.o"
    echo !CYAN!Compiling !src!...!RESET!
    g++ -c "!src!" -o "!obj!" !flags!
    if errorlevel 1 (
        echo !RED!Error: Failed to compile !src!!RESET!
        goto waitexit
    )
    set "obj_files=!obj_files! !obj!"
)

:: Linking
echo !CYAN!Linking into "%execname%"...!RESET!
g++ -o "%execname%" !obj_files!
if errorlevel 1 (
    echo !RED!Error: Linking failed!%RESET%
    goto waitexit
)

:: Stripping
echo !CYAN!Stripping binary...!RESET!
strip "%execname%"

:: Cleaning
echo !CYAN!Cleaning up...!RESET!
del /Q !obj_files!

:: The exit
echo !GREEN!Done!RESET!
timeout /t 2 /nobreak > NUL
goto :eof

:waitexit
echo !YELLOW!Press any key to exit...!RESET!
pause >nul
exit /b

:setESC
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
  exit /B 0
)
exit /B 0
