::: RetroArch Nightly Updater Script :::
::: Download the latest 64-bit Windows RetroArch nightly release, put the files in the current directory, and clean up the extracted files and downloaded archive. :::
::: Execute this script in the same directory from which you launch RetroArch. On updating, user-created files will be preserved, but RetroArch application files will be overwritten. :::
::: Author: [Your Name] :::
::: Version: 1.0 :::
::: Date: [Current Date] :::

@echo off
setlocal EnableDelayedExpansion

:: Prompt the user before continuing
echo The latest 64-bit RetroArch nightly will be extracted to the current directory. 
echo [91mIt is strongly recommended to run this script in the same directory from which you launch RetroArch.[0m
echo [91mUser-created files will be preserved. RetroArch application files will be overwritten.[0m

set /p confirm=Press enter to continue or ctrl+c to abort.

:: Define the URL and the local filename
set "url=https://buildbot.libretro.com/nightly/windows/x86_64/RetroArch.7z"
set "filename=RetroArch.7z"

:: Check if the file already exists in the current directory
if exist "%filename%" (
    echo %filename% already exists in the current directory. Deleting...
    del "%filename%"
)

:: Download the file from the URL using PowerShell
echo Downloading %url%...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%url%', '%filename%')" || (
    echo Failed to download "%url%".
    exit /b 1
)

:: Check if 7zip executable exists
if not exist "%ProgramFiles%\7-Zip\7z.exe" (
    echo 7zip executable not found. Please install 7zip and try again.
    exit /b 1
)

:: Extract all files from the RetroArch-Win64 directory to the current directory and preserve directory structure
echo Extracting RetroArch-Win64 files...
"%ProgramFiles%\7-Zip\7z.exe" x -y %filename% > 7z.log

if %errorlevel% neq 0 (
    echo Failed to extract files. See 7z.log for more details.
    exit /b 1
)

:: Move all files from RetroArch-Win64 to the current directory and preserve directory structure
echo Moving files to the current directory...
set "threads=1"
for /f "tokens=2 delims==" %%c in ('wmic cpu get NumberOfCores /value') do set /a threads=%%c

:: Redirect the output of robocopy to a log file
robocopy RetroArch-Win64 . /S /E /MOVE /R:0 /W:0 /MT:%threads% > robocopy.log 2>&1

:: Any return code value greater than or equal to 8 indicates that there was at least one failure during the copy operation
if %errorlevel% geq 8 (
    echo Failed to move files. See robocopy.log for more details.
    exit /b 1
)

:: Clean up
echo Cleaning up...
rd /S /Q RetroArch-Win64
del %filename%

echo Done.
