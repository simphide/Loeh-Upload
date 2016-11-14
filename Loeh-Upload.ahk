/*
Code by Simon | sim-phi.de

Capture: 
https://autohotkey.com/board/topic/46722-capture-screenshot-to-jpg/

FTP-Upload:
https://autohotkey.com/docs/commands/FileAppend.htm

NameGen:
https://autohotkey.com/board/topic/84783-functionrandom-string-generator/

*/

;Pre-Start________________________________________________________________________________________________________________________________________________________________________________________________________________________________


#Persistent
#Include %A_ScriptDir%\Includes\encrypt.ahk
#Include %A_ScriptDir%\Includes\namegen.ahk
FileCreateDir, %A_MyDocuments%/Loeh-Upload
FileCreateDir, %A_MyDocuments%/Loeh-Upload/IMG
FileCreateDir, %A_MyDocuments%/Loeh-Upload/Settings
SetWorkingDir %A_MyDocuments%/Loeh-Upload/ ;WorkingDir setzen
FileDelete,%A_ScriptDir%\update.bat
Version := 0.123
TrayTime := 4000
UrlDownloadToFile, http://sim-phi.de/upload_version.txt, temp.txt
Loop, Read, temp.txt
{
if A_index =1
current_version=%A_LoopReadLine%
}
Filedelete, temp.txt
global IsSettingsopen = false
global IsTrayopen = false
global loops := 4
global Animation
Ini_Path= %A_MyDocuments%/Loeh-Upload/Settings/Loeh-Upload.ini

FileInstall, tray.wav, %A_MyDocuments%\Loeh-Upload\IMG\tray.wav, 0
FileInstall, bg.png, %A_MyDocuments%/Loeh-Upload/IMG/bg.png, 1
FileInstall, one-third.ico, %A_MyDocuments%/Loeh-Upload/IMG/one-third.ico, 1
FileInstall, two-third.ico, %A_MyDocuments%/Loeh-Upload/IMG/two-third.ico, 1
FileInstall, full.ico, %A_MyDocuments%/Loeh-Upload/IMG/full.ico, 1
FileInstall, empty.ico, %A_MyDocuments%/Loeh-Upload/IMG/empty.ico, 1
FileInstall, changelog.txt, %A_MyDocuments%/Loeh-Upload/Settings/changelog.txt, 1

Menu, tray, NoStandard
menu, tray, add, Open Loeh-Uploads, OL
menu, tray, add, Open Online-Uploads, OOL
Loop, Read, %A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
{
	if A_index > 5
	break
	upload%A_Index% = %A_LoopReadLine%
}
Menu, Submenu, add, %upload1%, OpenLink1
Menu, Submenu, add, %upload2%, OpenLink2
Menu, Submenu, add, %upload3%, OpenLink3
Menu, Submenu, add, %upload4%, OpenLink4
Menu, Submenu, add, %upload5%, OpenLink5
Menu, tray, add, Last uploads, :Submenu
menu, tray, add, Settings
menu,Tray,Default, Settings
menu, tray, add, 
menu, tray, add, Capture Entire Desktop | Ctrl+Shift+1, Do1
menu, tray, add, Capture Current Window | Ctrl+Shift+2, Do2
menu, tray, add, Capture Desktop | Ctrl+Shift+3, Do3
menu, tray, add, Capture Area | Ctrl+Shift+4, Do4
menu, tray, add, Upload Clipboard | Ctrl+Shift+5, Do5
menu, tray, add, 
menu, tray, add, Reload
menu, tray, add, Exit

IfNotExist, %Ini_Path% ;Erste Benutzung
{
	IniWrite, mein-server.de , %Ini_Path%, Optionen, Server
	IniWrite, Loginname , %Ini_Path%, Optionen, Name
	IniWrite, PA$$W0RT , %Ini_Path%, Optionen, PW
	IniWrite, Loeh-Upload/, %Ini_Path%, Optionen, Server_Pfad
	IniWrite, %A_ProgramFiles%\IrfanView\i_view32.exe, %Ini_Path%, Optionen, IW_Pfad
	IniWrite, 0, %Ini_Path%, Optionen, Autorun
	IniWrite, 80, %Ini_Path%, Optionen, Quality
	IniRead, Animation,%Ini_Path%, Optionen, Animation, 1
	UploadTip("Loeh-Upload", "Complete the settings.", TrayTime, true)
	IniRead, Server,%Ini_Path%, Optionen, Server
	IniRead, Name,%Ini_Path%, Optionen, Name
	IniRead, PW,%Ini_Path%, Optionen, PW
	IniRead, Server_Pfad, %Ini_Path%, Optionen, Server_Pfad
	IniRead, Server_Pfad1,%Ini_Path%, Optionen, Server_Pfad1, %A_Space%
	IniRead, IW_Pfad,%Ini_Path%, Optionen, IW_Pfad, %A_Space%
	IniRead, Autorun,%Ini_Path%, Optionen, Autorun, 0
	IniRead, Quality,%Ini_Path%, Optionen, Quality, 80
	IniRead, subdomain,%Ini_Path%, Optionen, subdomain, %A_Space%
	GoSub, Settings
}

IniRead, Server,%Ini_Path%, Optionen, Server
IniRead, Name,%Ini_Path%, Optionen, Name
IniRead, PW,%Ini_Path%, Optionen, PW
DriveGet, Serial, Serial, C:
PW:=StrDecrypt(PW,Serial)
IniRead, Server_Pfad, %Ini_Path%, Optionen, Server_Pfad
IniRead, Server_Pfad1,%Ini_Path%, Optionen, Server_Pfad1, %A_Space%
IniRead, IW_Pfad,%Ini_Path%, Optionen, IW_Pfad, %A_Space%
IniRead, Autorun,%Ini_Path%, Optionen, Autorun, 0
IniRead, Quality,%Ini_Path%, Optionen, Quality, 80
IniRead, Animation,%Ini_Path%, Optionen, Animation, 1
IniRead, subdomain,%Ini_Path%, Optionen, subdomain, %A_Space%
if Server_Pfad1 = ;fall fuer meinen FTP
Server_Pfad1 :=Server_Pfad
RegRead, ExistReg, HKEY_LOCAL_MACHINE, Software\Microsoft\Windows\CurrentVersion\Run, LoehUpload
if Autorun=1
{
	if !RegRead
		RegWrite,REG_SZ,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Run,LoehUpload,"%A_ScriptDir%\%A_ScriptName%"
}
else
{
	if RegRead!=""
		RegDelete,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Run,LoehUpload
}

return


;Hotkeys________________________________________________________________________________________________________________________________________________________________________________________________________________________________

Do1:
^+1::
Temp_name := SC_RandomString(" M6 U D")
File_Upload_Name=%Temp_name%.jpg ;Dateinname
Upload_Dir := A_MyDocuments "\Loeh-Upload\" File_Upload_Name ;Pfad zu der Datei
IW_Command=/capture=0 /convert=%File_Upload_Name% /jpgq=%Quality% ;Befehl fuer IW
ifexist,%IW_Pfad% ; Richtiger Pfad?
{
	runwait,%IW_Pfad% %IW_Command% ;Screenshot aufnehmen
	Upload_Dir := RegExReplace(Upload_Dir, "\\", "/") ;Pfad anpassen
	Upload_Done := FTPUpload(Upload_Dir, File_Upload_Name, Server, Name, PW, Server_Pfad1) ;FTP Upload
	if (Upload_Done=1) ;Upload erfolgreich?
	{
		UploadTip("Loeh-Upload", File_Upload_Name " was uploaded successfully.", TrayTime, true)
		if subdomain != 
		clipboard = http://%subdomain%.%Server%/%Server_Pfad%%File_Upload_Name%
		else
		clipboard = http://%Server%/%Server_Pfad%%File_Upload_Name% ;In den Zwischenspeicher
	}
	else ;Fehler
	UploadTip("Loeh-Upload", File_Upload_Name " - Error while uploading.", TrayTime)
	FileRead, pre_links ,%A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	FormatTime, TS, , dddd, HH:mm
	if subdomain != 
	link_string = http://%subdomain%.%Server%/%Server_Pfad%%File_Upload_Name% | %TS%`n%pre_links%
	else
	link_string = http://%Server%/%Server_Pfad%%File_Upload_Name% | %TS%`n%pre_links%
	FileDelete, %A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	FileAppend, %link_string%,%A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	gosub UpdateTrayMenu
}
else ; IW nicht gefunden
{
MSGBOX IrfanView couldnt be found!
IniWrite, %A_Space%, %Ini_Path%, Optionen, IW_Pfad
GoSub Settings
Exitapp
}
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Do2:
^+2::
Temp_name := SC_RandomString(" M6 U D")

File_Upload_Name=%Temp_name%.jpg ;Dateinname
Upload_Dir := A_MyDocuments "\Loeh-Upload\" File_Upload_Name ;Pfad zu der Datei
IW_Command=/capture=2 /convert=%File_Upload_Name% /jpgq=%Quality% ;Befehl fuer IW
ifexist,%IW_Pfad% ; Richtiger Pfad?
{
	runwait,%IW_Pfad% %IW_Command% ;Screenshot aufnehmen
	Upload_Dir := RegExReplace(Upload_Dir, "\\", "/") ;Pfad anpassen
	Upload_Done := FTPUpload(Upload_Dir, File_Upload_Name, Server, Name, PW, Server_Pfad1) ;FTP Upload
	if (Upload_Done=1) ;Upload erfolgreich?
	{
		UploadTip("Loeh-Upload", File_Upload_Name " was uploaded successfully.", TrayTime, true)
		if subdomain != 
		clipboard = http://%subdomain%.%Server%/%Server_Pfad%%File_Upload_Name%
		else
		clipboard = http://%Server%/%Server_Pfad%%File_Upload_Name% ;In den Zwischenspeicher
	}
	else ;Fehler
		UploadTip("Loeh-Upload", File_Upload_Name " - Error while uploading.", TrayTime)
	FileRead, pre_links ,%A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	FormatTime, TS, , dddd, HH:mm
	if subdomain != 
	link_string = http://%subdomain%.%Server%/%Server_Pfad%%File_Upload_Name% | %TS%`n%pre_links%
	else
	link_string = http://%Server%/%Server_Pfad%%File_Upload_Name% | %TS%`n%pre_links%
	FileDelete, %A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	FileAppend, %link_string%,%A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	gosub UpdateTrayMenu
}
else ; IW nicht gefunden
{
MSGBOX IrfanView couldnt be found!
IniWrite, %A_Space%, %Ini_Path%, Optionen, IW_Pfad
GoSub Settings
}
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Do3:
^+3::
Temp_name := SC_RandomString(" M6 U D")

File_Upload_Name=%Temp_name%.jpg ;Dateinname
Upload_Dir := A_MyDocuments "\Loeh-Upload\" File_Upload_Name ;Pfad zu der Datei
IW_Command=/capture=1 /convert=%File_Upload_Name% /jpgq=%Quality% ;Befehl fuer IW
ifexist,%IW_Pfad% ; Richtiger Pfad?
{
	runwait,%IW_Pfad% %IW_Command% ;Screenshot aufnehmen
	Upload_Dir := RegExReplace(Upload_Dir, "\\", "/") ;Pfad anpassen
	Upload_Done := FTPUpload(Upload_Dir, File_Upload_Name, Server, Name, PW, Server_Pfad1) ;FTP Upload
	if (Upload_Done=1) ;Upload erfolgreich?
	{
		UploadTip("Loeh-Upload", File_Upload_Name " was uploaded successfully.", TrayTime, true)
		if subdomain != 
		clipboard = http://%subdomain%.%Server%/%Server_Pfad%%File_Upload_Name%
		else
		clipboard = http://%Server%/%Server_Pfad%%File_Upload_Name% ;In den Zwischenspeicher
	}
	else ;Fehler
	UploadTip("Loeh-Upload", File_Upload_Name " - Error while uploading.", TrayTime)
	FileRead, pre_links ,%A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	FormatTime, TS, , dddd, HH:mm
	if subdomain != 
	link_string = http://%subdomain%.%Server%/%Server_Pfad%%File_Upload_Name% | %TS%`n%pre_links%
	else
	link_string = http://%Server%/%Server_Pfad%%File_Upload_Name% | %TS%`n%pre_links%
	FileDelete, %A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	FileAppend, %link_string%,%A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	gosub UpdateTrayMenu
	
}
else ; IW nicht gefunden
{
MSGBOX IrfanView couldnt be found!
IniWrite, %A_Space%, %Ini_Path%, Optionen, IW_Pfad
GoSub Settings
}
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Do4:
^+4::
Temp_name := SC_RandomString(" M6 U D")

File_Upload_Name=%Temp_name%.jpg ;Dateinname
Upload_Dir := A_MyDocuments "\Loeh-Upload\" File_Upload_Name ;Pfad zu der Datei
IW_Command=/capture=4 /convert=%File_Upload_Name% /jpgq=%Quality% ;Befehl fuer IW
ifexist,%IW_Pfad% ; Richtiger Pfad?
{
	runwait,%IW_Pfad% %IW_Command% ;Screenshot aufnehmen
	Upload_Dir := RegExReplace(Upload_Dir, "\\", "/") ;Pfad anpassen
	Upload_Done := FTPUpload(Upload_Dir, File_Upload_Name, Server, Name, PW, Server_Pfad1) ;FTP Upload
	if (Upload_Done=1) ;Upload erfolgreich?
	{
		UploadTip("Loeh-Upload", File_Upload_Name " was uploaded successfully.", TrayTime, true)
		if subdomain != 
		clipboard = http://%subdomain%.%Server%/%Server_Pfad%%File_Upload_Name%
		else
		clipboard = http://%Server%/%Server_Pfad%%File_Upload_Name% ;In den Zwischenspeicher
	}
	else ;Fehler
		UploadTip("Loeh-Upload", File_Upload_Name " - Error while uploading.", TrayTime)
	FileRead, pre_links ,%A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	FormatTime, TS, , dddd, HH:mm
	if subdomain != 
	link_string = http://%subdomain%.%Server%/%Server_Pfad%%File_Upload_Name% | %TS%`n%pre_links%
	else
	link_string = http://%Server%/%Server_Pfad%%File_Upload_Name% | %TS%`n%pre_links%
	FileDelete, %A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	FileAppend, %link_string%,%A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	gosub UpdateTrayMenu
}
else ; IW nicht gefunden
{
MSGBOX IrfanView couldnt be found!
IniWrite, %A_Space%, %Ini_Path%, Optionen, IW_Pfad
GoSub Settings
}
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Do5:
^+5::
if clipboard != "" ;Nichts im Zwischenspeicher
{
	Temp_name := SC_RandomString(" M6 U D")
	
	File_Upload_Name=%Temp_name%.txt ;Dateinname fuer Text
	Upload_Dir := A_MyDocuments "\Loeh-Upload\" File_Upload_Name ;Pfad zur Datei
	IfExist, %clipboard% ;Gibt es die Datei?
	{
		Upload_Dir := clipboard ;Wenn ja ist das der Pfad
		file_loop_name := StrSplit(clipboard, "\") ;Dateinname ermitteln
		Loop % file_loop_name.MaxIndex()
		{
			File_Upload_Name := file_loop_name[a_index]
		}
		file_typ_name := StrSplit(File_Upload_Name, ".") ;Dateinname ermitteln
		Loop % file_typ_name.MaxIndex()
		{
			file_typ := file_typ_name[a_index]
		}
		if (file_typ =="php")
		{
			MsgBox,
			(
			WARNING!
You are trying to upload a PHP-file!
This is very risky and therefore prohibited!
			)
			return
		}
		FileGetSize, SelectedFileSize, %Upload_Dir%, K
		if(SelectedFileSize>10000)
		{
			MsgBox, 4, , %File_Upload_Name% is %SelectedFileSize%KB. Do you want to continue?
			IfMsgBox No
			{
			UploadTip("Loeh-Upload", "Upload canceled.", TrayTime)
			return
			}
			UploadTip("Loeh-Upload", "The upload may take a little time.", TrayTime)
			
		}
	}
	else
	FileAppend, %clipboard% , %File_Upload_Name% ;Text zu Datei hinzufuegen
	Upload_Dir := RegExReplace(Upload_Dir, "\\", "/") ;Pfad anpassen
	Upload_Done := FTPUpload(Upload_Dir, File_Upload_Name, Server, Name, PW, Server_Pfad1) ;FTP Upload
	if (Upload_Done=1) ;Upload erfolgreich?
	{
		UploadTip("Loeh-Upload", File_Upload_Name " was uploaded successfully.", TrayTime, true)
		File_Upload_Name := RegExReplace(File_Upload_Name, " ", "%20")
		if subdomain != 
		clipboard = http://%subdomain%.%Server%/%Server_Pfad%%File_Upload_Name%
		else
		clipboard = http://%Server%/%Server_Pfad%%File_Upload_Name%
	}
	else ; Falls nicht
	UploadTip("Loeh-Upload", File_Upload_Name " - Error while uploading.", TrayTime)
	FileRead, pre_links ,%A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	FormatTime, TS, , dddd, HH:mm
	if subdomain != 
	link_string = http://%subdomain%.%Server%/%Server_Pfad%%File_Upload_Name% | %TS%`n%pre_links%
	else
	link_string = http://%Server%/%Server_Pfad%%File_Upload_Name% | %TS%`n%pre_links%
	FileDelete, %A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	FileAppend, %link_string%,%A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
	gosub UpdateTrayMenu
	
}
return

;Labels________________________________________________________________________________________________________________________________________________________________________________________________________________________________

IconChanger:
Menu, Tray, Icon, %A_MyDocuments%/Loeh-Upload/IMG/one-third.ico
sleep, 200
Menu, Tray, Icon, %A_MyDocuments%/Loeh-Upload/IMG/two-third.ico
sleep, 200
Menu, Tray, Icon, %A_MyDocuments%/Loeh-Upload/IMG/full.ico
sleep, 200
Menu, Tray, Icon, %A_MyDocuments%/Loeh-Upload/IMG/empty.ico
sleep, 200

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Move:
PostMessage, 0xA1, 2,,, A
Return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Slideout:
UploadTip("Loeh-Upload", "Software is running in the background.", TrayTime)
Gui, Destroy
Gui, 3: Destroy
IsSettingsopen =false
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

OOL:
Run ftp://%Name%@%server%/%Server_Pfad1%
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

OL:
Run %A_MyDocuments%/Loeh-Upload/
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

OpenLink1:
Listarray := StrSplit(upload1, " | ")
link1 := Listarray[1]
if (A_GuiEvent = "RightClick")
Clipboard = %link1%
else
Run %link1%
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

OpenLink2:
Listarray := StrSplit(upload2, " | ")
link1 := Listarray[1]
Run %link1%
return
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

OpenLink3:
Listarray := StrSplit(upload3, " | ")
link1 := Listarray[1]
Run %link1%
return
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

OpenLink4:
Listarray := StrSplit(upload4, " | ")
link1 := Listarray[1]
Run %link1%
return
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

OpenLink5:
Listarray := StrSplit(upload5, " | ")
link1 := Listarray[1]
Run %link1%
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Update:
UploadTip("Loeh-Upload", "Downloading update.", TrayTime)
UrlDownloadToFile,http://www.sim-phi.de/Loeh-Upload.exe, %A_ScriptFullPath%.new
BatchFile=
(
Ping 127.0.0.1
Del "%A_ScriptFullPath%"
Move "%A_ScriptFullPath%.new" "%A_ScriptFullPath%"
"%A_ScriptFullPath%"
)
FileAppend,%BatchFile%,%A_ScriptDir%\update.bat
Run,%A_ScriptDir%\update.bat,,hide
Run http://www.sim-phi.de/changelog.txt
ExitApp
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Settings:
if IsSettingsopen=true
return
IsSettingsopen =true
Gui, 2: -caption
Gui 2: Add, Picture, x0 y0 w800 h400 , %A_MyDocuments%/Loeh-Upload/IMG/bg.png
Gui, 2: Add, Text, x767 y35 w33 h36 +BackgroundTrans gMove,
Gui, 2: Add, Text, x0 y0 w767 h71 +BackgroundTrans gMove,
Gui, 2: Add, Text, x767 y8 w27 h27 +BackgroundTrans gSlideout,


Gui, 2:Add, Text, x460 y80 w200 h20 +BackgroundTrans, FTP-Log:
Gui, 2:Add, Text, x60 y80 w200 h20 +BackgroundTrans, FTP Settings:

Gui, 2:Add, Text, x60 y120 w200 h20 +BackgroundTrans, Serveradress:
Gui, 2: Add, Edit, x135 y118 w140 h20 vServer_GUI, %Server%
Gui, 2:Add, Text, x60 y150 w200 h20 +BackgroundTrans, Loginname:
Gui, 2: Add, Edit, x135 y148 w140 h20 vName_GUI, %Name%
Gui, 2:Add, Text, x60 y180 w200 h20 +BackgroundTrans, Password:
Gui, 2: Add, Edit, x135 y178 w140 h20 vPW_GUI Password, %PW%
Gui, 2:Add, Text, x60 y210 w200 h20 +BackgroundTrans, Server-Path:
Gui, 2: Add, Edit, x135 y208 w140 h20 vServer_Pfad_GUI, %Server_Pfad%
Gui, 2: Add,Button, x280 y208 h20 w20 gPfad_Info, ?
Gui, 2:Add, Text, x60 y240 w200 h20 +BackgroundTrans, IrfanView-Path:
Gui, 2: Add, Edit, x135 y238 w140 h20 vIW_Pfad_GUI, %IW_Pfad%
Gui, 2: Add, Button, x280 y238 w40 h20 gFind_IW Default, Find
Gui, 2:Add, Text, x60 y270 w200 h20 +BackgroundTrans, JPG Quality:
Gui, 2: Add, Slider, x135 y270 w140 h20 vQuality_GUI TickInterval10 +BackgroundTrans, %Quality%
Gui, 2:Add, Text, x60 y300 w200 h20 +BackgroundTrans, Start with Windows?:
Gui, 2:Add, CheckBox, x170 y300 w13 h13 vAutorun_GUI Checked%Autorun%


Gui, 2: Add, Button, x60 y330 w100 h20 gSave Default, Save Settings
Gui, 2: Add, Button, x175 y330 w100 h20 gCS Default, Test Settings
if (version<current_version)
Gui, 2:Add, Text, x60 y360 w300 h20 +BackgroundTrans gUpdate cRed, New Version available (V%current_version%)!
else
Gui, 2:Add, Text, x60 y360 w300 h20 +BackgroundTrans, Current Version: (V%version%)


FileRead, FTPlog, %A_MyDocuments%/Loeh-Upload/Settings/FTPLog.txt ;Logdatei.txt
Gui, 2: Add, Edit, x440 y100 w320 h260 vFTPLog +ReadOnly, %FTPlog%
xpos := A_ScreenWidth / 2 -400
ypos := A_ScreenHeight / 2 -200
Gui, 2: Show, x%xpos% y%ypos% h400 w800, Loeh-Upload - Version: %Version%

;Run %A_MyDocuments%/Loeh-Upload/%Ini_Path%
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Find_IW:
FileSelectFile, IW_new_Pfad , , %A_ProgramFiles%\IrfanView\, , Anwendung (*.exe)
If IW_new_Pfad != 
GuiControl,  ,IW_Pfad_GUI, %IW_new_Pfad%
Return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Pfad_Info:
Gui, 3: +ToolWindow
Gui, 3: +AlwaysOnTop
Gui, 3: -caption
Gui, 3: Add, Picture, x-450 y0 w800 h400 , %A_MyDocuments%/Loeh-Upload/IMG/bg.png
Gui, 3: Add, Text, x317 y8 w27 h27 +BackgroundTrans gHide_Tip,
Gui, 3: font, s16
Gui, 3: Add, Text, x30 y20 w250 h36 +BackgroundTrans cwhite, Info
Gui, 3: font,
Gui, 3: Add, Text, x30 y80 w280 h100 +BackgroundTrans, The server-path is the relative path of the targetfolder you want to upload to.
Gui, 3: Add, Text, x30 y115 w280 h100 +BackgroundTrans, For Example:
Gui, 3: Add, Text, x30 y130 w280 h100 +BackgroundTrans, www.my-server.com/ 
Gui, 3: font, bold
Gui, 3: Add, Text, x130 y130 w280 h100 +BackgroundTrans, Loeh-Upload/
Gui, 3: font,
Gui, 3: Add, Text, x30 y150 w280 h100 +BackgroundTrans, If the rootdir of your ftp-account isnt the same as the webdirroot you have to use the Server_Pfad1 in the config file.
Gui, 3: Show, NA  h200 w350, Loeh-Tip
Return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Gui_Anim:
loops--
if loops=0
Settimer Gui_Anim, off
WinGetPos,,,tw, th, ahk_class Shell_TrayWnd
xpos := A_ScreenWidth -380 
ypos := A_ScreenHeight -100 -th
temp_y := (ypos+(3*loops))
Gui, 1: Show, NA x%xpos% y%temp_y% h70 w350, Loeh-Tip
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Hide_Tip:
Settimer Gui_Anim, off
Settimer, Hide_Tip, off
Gui, 1: Destroy
Gui, 3: Destroy
IsTrayopen = false
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

OpenLink:
if subdomain != 
Run, http://%subdomain%.%Server%/%Server_Pfad%%File_Upload_Name%
else
Run, http://%Server%/%Server_Pfad%%File_Upload_Name%
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Exit:
ExitApp
Return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Save:
Gui, 2: Submit, NoHide
IniWrite, %Server_GUI% , %Ini_Path%, Optionen, Server
IniWrite, %Name_GUI% , %Ini_Path%, Optionen, Name
DriveGet, Serial, Serial, C:
PW_GUI:=StrEncrypt(PW_GUI,Serial,2)
IniWrite, %PW_GUI% , %Ini_Path%, Optionen, PW
IniWrite, %Server_Pfad_GUI%, %Ini_Path%, Optionen, Server_Pfad
IniWrite, %IW_Pfad_GUI%, %Ini_Path%, Optionen, IW_Pfad
IniWrite, %Autorun_GUI%, %Ini_Path%, Optionen, Autorun
IniWrite, %Quality_GUI%, %Ini_Path%, Optionen, Quality
reload
Return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Reload:
Reload
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

UpdateTrayMenu:
Menu, Submenu, DeleteAll
Loop, Read, %A_MyDocuments%/Loeh-Upload/Settings/upload_list.txt
{
	if A_index > 5
	break
	upload%A_Index% = %A_LoopReadLine%
}
Menu, Submenu, add, %upload1%, OpenLink1
Menu, Submenu, add, %upload2%, OpenLink2
Menu, Submenu, add, %upload3%, OpenLink3
Menu, Submenu, add, %upload4%, OpenLink4
Menu, Submenu, add, %upload5%, OpenLink5
return

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CS:
temp_string =
Settimer, IconChanger, 200
Gui, 2: Submit, NoHide
if Server_Pfad1 != ;fall fuer meinen FTP
Server_Pfad_GUI := Server_Pfad1
found = false ;Fuer Fehelrausgabe
FTPCommandFile = %A_Temp%\FTPCommands.txt ;Commands
FTPLogFile = %A_MyDocuments%/Loeh-Upload/Settings/FTPLog.txt ;Logdatei
FileDelete %FTPCommandFile%  ; Alte Datei loeschen
FileAppend, 
(
Dies ist ein Test.
), temp_test.txt
FileAppend,  ;  Befehle fuer FTP.exe
(
open %Server_GUI%
%Name_GUI%
%PW_GUI%
binary
cd %Server_Pfad_GUI%.
put temp_test.txt
ls -l
quit
), %FTPCommandFile%
RunWait %comspec% /c ftp.exe -s:"%FTPCommandFile%" >"%FTPLogFile%", ,Hide ;FTP versteckt ausfuehren
FileDelete %FTPCommandFile%  ; Loeschen da Daten in dieser Datei
;Run %FTPLogFile%  ; Zum debuggen
Loop, read, %FTPLogFile% ;Check if upload erfolgreich
{
	If (InStr(A_LoopReadLine, "Transfer complete."))
	{
		found = true
	}
	else If (InStr(A_LoopReadLine, "File successfully transferred"))
	{
		found = true
	}
	else if (InStr(A_LoopReadLine, "is not supported. Use PASV/EPSV instead of this"))
	{
		MsgBox %A_LoopReadLine%
		found =false
		break
	}
		else if (InStr(A_LoopReadLine, "Ungltiger Befehl"))
	{
		MsgBox %A_LoopReadLine%
		found =false
		break
	}
}

if found=true
	temp_string = Testfile successfully uploaded.
else 
	temp_string = The testfile file could not be uploaded.
	
if subdomain != 
	UrlDownloadToFile, http://%subdomain%.%Server%/%Server_Pfad%temp_test.txt, check_test.txt
else
	UrlDownloadToFile, http://%Server%/%Server_Pfad%temp_test.txt, check_test.txt
FileRead, test1, temp_test.txt
FileRead, test2, check_test.txt
if(test1!=test2)
{
	FileRead, FTPlog, FTPLog.txt
	GuiControl, , FTPLog, %FTPlog%
	temp_string = %temp_string%`nFile has been tampered.
}
else 
	temp_string =  %temp_string%`nThe configuration appears to work.
FileAppend,  ;  Befehle fuer FTP.exe
(
open %Server_GUI%
%Name_GUI%
%PW_GUI%
binary
cd %Server_Pfad_GUI%.
delete temp_test.txt
ls -l
quit
), %FTPCommandFile%
RunWait %comspec% /c ftp.exe -s:"%FTPCommandFile%" >"%FTPLogFile%", ,Hide ;FTP versteckt ausfuehren
FileDelete %FTPCommandFile%  ; Loeschen da Daten in dieser Datei
FileDelete check_test.txt
FileDelete temp_test.txt
If isSettingsopen=true
{
FileRead, FTPlog, %A_MyDocuments%/Loeh-Upload/Settings/FTPLog.txt ;Logdatei.txt
GuiControl, , FTPLog, %FTPlog%
}
UploadTip("Loeh-Upload", temp_string, 8000)
Settimer, IconChanger, off
return




;Funktionen________________________________________________________________________________________________________________________________________________________________________________________________________________________________



FTPUpload(filename, file_check, Server, Name, PW, Server_Pfad1){ ;FTP Upload
Settimer, IconChanger, 200
found = false ;Fuer Fehelrausgabe
FTPCommandFile = %A_Temp%\FTPCommands.txt ;Commands
FTPLogFile = %A_MyDocuments%/Loeh-Upload/Settings/FTPLog.txt ;Logdatei
FileDelete %FTPCommandFile%  ; Alte Datei loeschen
FileAppend,  ;  Vefehle fuer FTP.exe
(
open %Server%
%Name%
%PW%
binary
cd %Server_Pfad1%.
ls -l
quit
), %FTPCommandFile%
RunWait %comspec% /c ftp.exe -s:"%FTPCommandFile%" >"%FTPLogFile%", ,Hide ;FTP versteckt ausfuehren
FileDelete %FTPCommandFile%  ; Loeschen da Daten in dieser Datei
Loop, read, %FTPLogFile% ;Check if upload erfolgreich
{
	If (InStr(A_LoopReadLine, file_check))
	{
			MsgBox, 4, , %file_check% already exists. Do you want to continue?
			IfMsgBox No
			{
			UploadTip("Loeh-Upload", "Upload canceled.", TrayTime)
			Settimer, IconChanger, off
			return 0
			}
			UploadTip("Loeh-Upload", "The file will be replaced.", TrayTime)
	}
}
FileAppend,  ;  Vefehle fuer FTP.exe
(
open %Server%
%Name%
%PW%
binary
cd %Server_Pfad1%.
put "%filename%"
ls -l
quit
), %FTPCommandFile%
RunWait %comspec% /c ftp.exe -s:"%FTPCommandFile%" >"%FTPLogFile%", ,Hide ;FTP versteckt ausfuehren
FileDelete %FTPCommandFile%  ; Loeschen da Daten in dieser Datei
;Run %FTPLogFile%  ; Zum debuggen
Loop, read, %FTPLogFile% ;Check if upload erfolgreich
{
	If (InStr(A_LoopReadLine, "Transfer complete.") || InStr(A_LoopReadLine, "File successfully transferred"))
	{
		found = true
	}
	else if (InStr(A_LoopReadLine, "is not supported. Use PASV/EPSV instead of this"))
	{
		MsgBox %A_LoopReadLine%
		found =false
		break
	}
		else if (InStr(A_LoopReadLine, "Ungltiger Befehl"))
	{
		MsgBox %A_LoopReadLine%
		found =false
		Run %A_MyDocuments%/Loeh-Upload/%Ini_Path%
		break
	}
}
If isSettingsopen=true
{
FileRead, FTPlog, %A_MyDocuments%/Loeh-Upload/Settings/FTPLog.txt ;Logdatei.txt
GuiControl, , FTPLog, %FTPlog%
}
Settimer, IconChanger, off
if found=true
	return 1
else 
	return 0
}

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

UploadTip(header ,text, time, action = false)
{
if time = 0
	return
if IsTrayopen = true
{
	Settimer Gui_Anim, off
	Gui, 1: Destroy
	IsTrayopen = false
	UploadTip(header ,text, time, action)
	return
}
IsTrayopen = true
Settimer, Hide_Tip, %time%
SoundPlay, %A_MyDocuments%\Loeh-Upload\IMG\tray.wav
Gui, 1: +ToolWindow
Gui, 1: +AlwaysOnTop
Gui, 1: -caption
Gui, 1: Add, Picture, x-450 y0 w800 h400 , %A_MyDocuments%/Loeh-Upload/IMG/bg.png
Gui, 1: Add, Text, x317 y8 w27 h27 +BackgroundTrans gHide_Tip,
Gui, 1: font,bold
Gui, 1: Add, Text, x20 y10 w250 h36 +BackgroundTrans cwhite, %header%
Gui, 1: font,
if action = 1
	Gui, 1: Add, Text, x30 y35 w300 h36 +BackgroundTrans gOpenLink cwhite , %text%
else
	Gui, 1: Add, Text, x30 y35 w300 h36 +BackgroundTrans cwhite , %text%

if Animation = 1
{
	loops :=40
	Settimer Gui_Anim, 20
}
else
{
	WinGetPos,,,tw, th, ahk_class Shell_TrayWnd
	xpos := A_ScreenWidth -380 
	ypos := A_ScreenHeight -100 -th
	Gui, 1: Show, NA x%xpos% y%ypos% h70 w350, Loeh-Tip
}
return 1
}