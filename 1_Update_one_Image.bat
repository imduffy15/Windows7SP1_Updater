@echo off
COLOR 4F
cls
:Get Windows index from the user
SET /P indexinput=What is the NUMERIC value of the Windows install to patch?
echo %indexinput%

:IMAGEFOUND
TITLE Downloading patch files
.\Program\helpers\wget\wget.exe -N -i .\Program\helpers\data\url_list_cab.txt -P .\User\updates\cab
.\Program\helpers\wget\wget.exe -N -i .\Program\helpers\data\url_list_manual_installs.txt -P .\User\updates\manual
.\Program\helpers\wget\wget.exe -N -i .\Program\helpers\data\url_list_msu.txt -P .\User\updates\msu
.\Program\helpers\wget\wget.exe -N -i .\Program\helpers\data\url_list_wuclient.txt -P .\User\updates\wuclient
.\Program\helpers\wget\wget.exe -N -i .\Program\helpers\data\url_list_lateinstall.txt -P .\User\updates\lateinstall
.\Program\helpers\wget\wget.exe -N -i .\Program\helpers\data\url_list_ie.txt -P .\User\updates\ie
.\Program\helpers\wget\wget.exe -N -i .\Program\helpers\data\url_list_3rd_party_installs.txt -P .\User\updates\manual

::Delete updates once extracted (uncomment line)
::del /Q .\updates\*

::Move the Wim ready for mounting
TITLE Preparing image
move .\User\Windows7_x64\sources\install.wim .\Program\wim\install.wim

::Show and mount Wim info
dism /get-wiminfo /wimfile:.\Program\wim\install.wim /index:%indexinput%
dism /Mount-Wim /WimFile:.\Program\wim\install.wim /index:%indexinput% /MountDir:.\Program\wim\mount


::This makes a directory in the root for installs that can't be integrated
mkdir .\Program\wim\mount\ManualInstalls
copy .\User\updates\manual\*.* .\Program\wim\mount\ManualInstalls

::This makes the setupcomplete.cmd part
mkdir .\User\Windows7_x64\sources\$OEM$\$$\Setup\Scripts\
copy .\Program\helpers\data\SetUpComplete.cmd .\User\Windows7_x64\sources\$OEM$\$$\Setup\Scripts\


::Merge all updates to the image
TITLE Patching the image (long)
::Integrate the MSU files
dism /image:.\Program\wim\mount /add-package /packagepath:.\User\updates\wuclient\
dism /image:.\Program\wim\mount /add-package /packagepath:.\User\updates\msu\
dism /image:.\Program\wim\mount /add-package /packagepath:.\User\updates\cab\
dism /image:.\Program\wim\mount /add-package /packagepath:.\User\updates\ie\
dism /image:.\Program\wim\mount /add-package /packagepath:.\User\updates\lateinstall\

dism /Image:.\Program\wim\mount /Add-Driver /Driver:.\User\drivers /Recurse

::unmount the image
dism /Unmount-Wim /MountDir:.\Program\wim\mount /commit

::cleanup
dism /Cleanup-Wim
::cls
::move the image back to the normal Windows dir
move .\Program\wim\install.wim .\User\Windows7_x64\sources\install.wim
::Copy Autounattend if present
IF EXIST .\User\unattended\Autounattend.xml copy /y .\User\unattended\Autounattend.xml .\User\Windows7_x64\Autounattend.xml
::Delete ei.cfg so all windows versions get shown
IF EXIST .\User\Windows7_x64\sources\ei.cfg del .\User\Windows7_x64\sources\ei.cfg

::Make the ISO
.\Program\helpers\waik\Waik_4\x86\oscdimg.exe -lW7SP1 -t012/16/2011 -m -u2 -b.\User\Windows7_x64\boot\etfsboot.com .\User\Windows7_x64 .\User\FinalISO\W7x64_SP1.iso
ECHO Done!
Pause
