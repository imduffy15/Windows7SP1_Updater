@echo off
COLOR 4F
cls
:Get waik tools
TITLE Checking / Getting WAIK tools
ECHO Just sorting out some of the prerequisites needed
start /wait .\Program\helpers\getwaiktools\GetWaikTools.exe -win8 -win8Dism -silent -cURL:0 -ontop:0 -folder:./Program/helpers/waik


TITLE Looking for Windows 7 64 bit image
IF EXIST .\User\Windows7_x64\sources GOTO IMAGEFOUND

ECHO I didn't find Windows 7 64bit where I expected
ECHO If you have extracted the ISO then something is wrong - recheck the location
ECHO If you have not extracted an ISO then this fine
SET /P ANSWER=Should I Download a Windows 7 64bit ISO and extract it for you? (Y/N)

if /i {%ANSWER%}=={y} (goto :isodownload) 
if /i {%ANSWER%}=={yes} (goto :isodownload) 
exit /b 0 
:isodownload
cls
TITLE Downloading W7x64
ECHO Downloading W7 64bit from a Microsoft server
.\Program\helpers\wget\wget.exe -N -i .\Program\helpers\data\url_windows7.txt -P .\User\updates\iso
.\Program\helpers\7za\7z.exe x -y .\User\updates\iso\X17-59186.iso -o.\User\Windows7_x64\
cls
:IMAGEFOUND
cls
ECHO On the next screen you will see a list of Windows installs
ECHO Remember the number of the one you want to patch
ECHO This is used in the next step
@pause
dism /get-wiminfo /wimfile:".\User\Windows7_x64\sources\install.wim"
ECHO Use the scrollbar on the right if you can't see them all
ECHO Remember the number, not name!
ECHO Once you know which one, you may run the next batch file
@pause