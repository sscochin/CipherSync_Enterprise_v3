#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <ListBoxConstants.au3>
#include <MsgBoxConstants.au3>
#include <GUIListView.au3>
#include <ListViewConstants.au3>
#include <File.au3>
#include <GUIListView.au3>
#include <ListViewConstants.au3>
#include <File.au3>
#include <GuiListView.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include "Common.au3"


; ==========================================================
; CIPHERSYNC BACKUP SETUP
; PART 1 - GUI
; ==========================================================

Global $hGUI
Global $txtRepoLocation
Global $btnBrowseRepo

Global $txtBackupName

Global $txtPassword
Global $txtPasswordConfirm

Global $lstFolders
Global $btnAddFolder
Global $btnRemoveFolder

Global $txtMorningTime
Global $txtEveningTime

Global $txtExclude

Global $btnCreate
Global $btnExit
Global $btnRestore
Global $btnLoadSnapshots
Global $lvSnapshots
; ==========================================================
; GUI
; ==========================================================

GUICreate($APP_NAME & " - " & $APP_VERSION, $WINDOW_WIDTH, $WINDOW_HEIGHT)

MsgBox(64, "Welcome to CipherSync Backup Setup", _
"Welcome to CipherSync Backup Setup" & @CRLF & @CRLF & _
"CipherSync is a secure and automated backup solution designed to protect important business data." & @CRLF & @CRLF & _
"How It Works:" & @CRLF & _
"1. Enter a unique Backup Container Name" & @CRLF & _
"2. Select one or more folders containing important data" & @CRLF & _
"3. Enter a repository password and keep it safe" & @CRLF & _
"4. Select the repository storage location" & @CRLF & _
"5. Click Create Repository & Backup Job" & @CRLF & @CRLF & _
"Repository Location:" & @CRLF & _
"User Selected (Local Disk, NAS, External Drive or Network Share)" & @CRLF & @CRLF & _
"Do not lose the repository password. It is required for restoring backups." & @CRLF & @CRLF & _
"For Internal Use Only" & @CRLF & _
"Team CipherSync")


; Repository
GUICtrlCreateLabel("Repository Location", 20, 20, 150, 20)

$txtRepoLocation = GUICtrlCreateInput("", 20, 45, 550, 25)

$btnBrowseRepo = GUICtrlCreateButton("Browse", 585, 45, 90, 25)

; Backup Name
GUICtrlCreateLabel("Backup Container Name", 20, 90, 180, 20)

$txtBackupName = GUICtrlCreateInput("", 20, 115, 300, 25)

; Password
GUICtrlCreateLabel("Repository Password", 20, 160, 150, 20)

$txtPassword = GUICtrlCreateInput("", 20, 185, 250, 25, $ES_PASSWORD)

GUICtrlCreateLabel("Confirm Password", 320, 160, 150, 20)

$txtPasswordConfirm = GUICtrlCreateInput("", 320, 185, 250, 25, $ES_PASSWORD)

; Folders
GUICtrlCreateLabel("Folders To Backup", 20, 235, 150, 20)

$lstFolders = GUICtrlCreateList("", 20, 260, 550, 180)

$btnAddFolder = GUICtrlCreateButton("Add Folder", 585, 260, 90, 30)

$btnRemoveFolder = GUICtrlCreateButton("Remove", 585, 300, 90, 30)

; Schedule
GUICtrlCreateLabel("Morning Backup Time (HH:MM)", 20, 460, 220, 20)

$txtMorningTime = GUICtrlCreateInput("08:00", 250, 455, 100, 25)

GUICtrlCreateLabel("Evening Backup Time (HH:MM)", 20, 500, 220, 20)

$txtEveningTime = GUICtrlCreateInput("20:00", 250, 495, 100, 25)

; Exclusions
GUICtrlCreateLabel("Exclude Patterns (one per line)", 20, 540, 250, 20)

$txtExclude = GUICtrlCreateEdit( _
"*.tmp" & @CRLF & _
"*.log" & @CRLF & _
"Thumbs.db", _
20, 565, 400, 60)

; Buttons
$btnRestore = GUICtrlCreateButton("Restore Backup", 500, 515, 170, 35)
$btnLicense = GUICtrlCreateButton("Enter License Key", 500, 475, 170, 35)

$btnCreate = GUICtrlCreateButton("Create Backup Setup", 500, 560, 170, 35)

$btnExit = GUICtrlCreateButton("Exit", 500, 605, 170, 30)

GUISetState(@SW_SHOW)

; ==========================================================
; EVENT LOOP
; ==========================================================
; ==========================================================
; PART 2
; ==========================================================

Global $aFolders[0]
Func _ShowSnapshots($sRepo, $sPwdFile)

    Local $hSnap = GUICreate("CipherSync Snapshots", 700, 400)

    Local $lvSnapshots = GUICtrlCreateListView( _
    "ID|Time|Host|Paths", _
    10, 10, 670, 300, _
    BitOR($LVS_SHOWSELALWAYS, $LVS_SINGLESEL))


Local $btnRestoreNow = GUICtrlCreateButton( _
    "Restore Selected", _
    400, 330, 140, 30)
Local $btnClose = GUICtrlCreateButton( _
    "Close", _
    560, 330, 120, 30)

    Local $sOutFile = @TempDir & "\CipherSyncSnapshots.txt"

    Local $sCmd = '"C:\CipherSync\CipherSync.exe" snapshots --repo "' & _
    $sRepo & '" --password-file "' & _
    $sPwdFile & '"'

RunWait(@ComSpec & _
    ' /c "' & $sCmd & ' > "' & $sOutFile & '" 2>&1"', _
    "", _
    @SW_HIDE)

Local $aLines
_FileReadToArray($sOutFile, $aLines)

If Not @error Then

    For $i = 1 To $aLines[0]

        If StringStripWS($aLines[$i], 8) <> "" Then
            GUICtrlCreateListViewItem($aLines[$i], $lvSnapshots)
        EndIf

    Next

Else

    MsgBox(16, "Error", _
        "Unable to read snapshot information." & @CRLF & _
        $sOutFile)



    EndIf

    GUISetState(@SW_SHOW, $hSnap)

    While 1

        Switch GUIGetMsg()

            Case $GUI_EVENT_CLOSE
                GUIDelete($hSnap)
Case $btnRestoreNow

    If Not _CheckRestoreLicense() Then ContinueLoop

    Local $sRestoreFolder = FileSelectFolder( _
        "Select Restore Location", "")

    If $sRestoreFolder = "" Then ContinueLoop

    Local $hLV = GUICtrlGetHandle($lvSnapshots)

    Local $iIndex = _GUICtrlListView_GetNextItem($hLV)

    If $iIndex = -1 Then
        MsgBox(16, "Restore", "Please select a snapshot.")
        ContinueLoop
    EndIf

    Local $sRow = _GUICtrlListView_GetItemText($hLV, $iIndex, 0)

Local $aParts = StringSplit(StringStripWS($sRow, 7), " ")

If $aParts[0] < 1 Then
    MsgBox(16, "Restore", "Unable to determine Snapshot ID.")
    ContinueLoop
EndIf

Local $sSnapshotID = $aParts[1]

    If $sSnapshotID = "" Then
        MsgBox(16, "Restore", "Unable to determine Snapshot ID.")
        ContinueLoop
    EndIf

    Local $sCmd = _
        '"C:\CipherSync\CipherSync.exe" restore ' & _
        $sSnapshotID & _
        ' --repo "' & $sRepo & '"' & _
        ' --password-file "' & $sPwdFile & '"' & _
        ' --target "' & $sRestoreFolder & '"'
	

    Local $iResult = RunWait(@ComSpec & _
        ' /c "' & $sCmd & '"', _
        "", _
        @SW_SHOW)

    _IncrementRestoreCount()

    MsgBox(64, _
        "Restore Complete", _
             "Restored To: " & $sRestoreFolder)

    FileDelete($sPwdFile)
    GUIDelete($hSnap)
    Return

Case $btnClose

    FileDelete($sPwdFile)
    GUIDelete($hSnap)
    Return

        EndSwitch

    WEnd

EndFunc
Func _LoadSnapshots($sRepo, $lvSnapshots)

    _GUICtrlListView_DeleteAllItems( _
        GUICtrlGetHandle($lvSnapshots))

    Local $sOut = @TempDir & "\CipherSyncSnapshots.txt"

   Local $sCmd = _
    '"C:\CipherSync\CipherSync.exe" snapshots --repo "' & _
    $sRepo & _
    '" --password-file "' & $sPwdFile & '"'

    RunWait(@ComSpec & _
        ' /c ' & $sCmd & ' > "' & $sOut & '"', _
        "", @SW_HIDE)

    Local $aLines

    _FileReadToArray($sOut, $aLines)

    If @error Then Return

    For $i = 6 To $aLines[0]

        If StringStripWS($aLines[$i], 8) = "" Then ContinueLoop

       GUICtrlCreateListViewItem( _
    $sID & "|" & $sTime & "|" & $sHost & "|" & $sPath, _
    $lvSnapshots)

    Next

EndFunc

Func _RestoreSnapshot($sRepo, $sID, $sTarget)

    Local $sCmd = _
        '"C:\CipherSync\CipherSync.exe" restore ' & _
        $sID & _
        ' --repo "' & $sRepo & '"' & _
        ' --target "' & $sTarget & '"' & _
        ' --password-file "C:\CipherSync\CipherSync-password.txt"'

    If MsgBox(36, _
        "Restore", _
        "Restore snapshot " & $sID & "?") <> 6 Then Return

    RunWait($sCmd)

    MsgBox(64, _
        "Completed", _
        "Restore completed successfully.")

EndFunc


Func _AddFolder()

    ; MsgBox(64, "Debug", "_AddFolder called")

    Local $sFolder = FileSelectFolder( _
        "Select Folder To Backup", "")

    If $sFolder = "" Then Return

    ReDim $aFolders[UBound($aFolders) + 1]
    $aFolders[UBound($aFolders) - 1] = $sFolder

    _RefreshFolderList()

EndFunc

Func _RefreshFolderList()

    GUICtrlSetData($lstFolders, "")

    Local $sList = ""

    For $i = 0 To UBound($aFolders) - 1
        $sList &= $aFolders[$i] & "|"
    Next

    GUICtrlSetData($lstFolders, $sList)

EndFunc

Func _RemoveFolder()

    Local $sSelected = GUICtrlRead($lstFolders)

    If $sSelected = "" Then
        MsgBox(48, "Remove Folder", "Select a folder first.")
        Return
    EndIf

    Local $aTemp[0]

    For $i = 0 To UBound($aFolders) - 1

        If $aFolders[$i] <> $sSelected Then

            ReDim $aTemp[UBound($aTemp) + 1]
            $aTemp[UBound($aTemp) - 1] = $aFolders[$i]

        EndIf

    Next

    $aFolders = $aTemp

    _RefreshFolderList()

EndFunc

Func _Validate()

    Local $sRepoRoot = StringStripWS(GUICtrlRead($txtRepoLocation), 3)
    Local $sBackupName = StringStripWS(GUICtrlRead($txtBackupName), 3)

    Local $sPwd1 = GUICtrlRead($txtPassword)
    Local $sPwd2 = GUICtrlRead($txtPasswordConfirm)

    If $sRepoRoot = "" Then
        MsgBox(16, "Validation", "Repository location required.")
        Return False
    EndIf

    If $sBackupName = "" Then
        MsgBox(16, "Validation", "Backup name required.")
        Return False
    EndIf

    If $sPwd1 = "" Then
        MsgBox(16, "Validation", "Password required.")
        Return False
    EndIf

    If $sPwd1 <> $sPwd2 Then
        MsgBox(16, "Validation", "Passwords do not match.")
        Return False
    EndIf

    If UBound($aFolders) = 0 Then
        MsgBox(16, "Validation", "Select at least one folder.")
        Return False
    EndIf

    Return True

EndFunc

Func _CreateRepository()

    If Not _Validate() Then Return

    Local $sRepoRoot = GUICtrlRead($txtRepoLocation)
    Local $sBackupName = GUICtrlRead($txtBackupName)

    Local $sRepo = $sRepoRoot & "\" & $sBackupName

    Local $sPassword = GUICtrlRead($txtPassword)

    DirCreate("C:\CipherSync")
	FileCopy(@ScriptDir & "\CipherSync.exe", "C:\CipherSync\CipherSync.exe", 9)
	Local $sCipherSyncExe = "C:\CipherSync\CipherSync.exe"
    DirCreate($sRepo)

    FileDelete("C:\CipherSync\CipherSync-password.txt")
    FileWrite("C:\CipherSync\CipherSync-password.txt", $sPassword)
FileSetAttrib("C:\CipherSync\CipherSync-password.txt", "+H")
    Local $sIni = "C:\CipherSync\Config.ini"

    IniWrite($sIni, "Repository", "Root", $sRepoRoot)
    IniWrite($sIni, "Repository", "Name", $sBackupName)

    IniWrite($sIni, "Schedule", "Morning", _
        GUICtrlRead($txtMorningTime))

    IniWrite($sIni, "Schedule", "Evening", _
        GUICtrlRead($txtEveningTime))

    Local $sCipherSyncExe = @ScriptDir & "\CipherSync.exe"

    If Not FileExists($sCipherSyncExe) Then

        MsgBox(16, _
            "Error", _
            "CipherSync.exe not found in:" & @CRLF & _
            $sCipherSyncExe)

        Return

    EndIf

    If Not FileExists($sRepo & "\config") Then



  Local $sPwdFile = "C:\CipherSync\CipherSync-password.txt"

Local $sCmd = '"' & $sCipherSyncExe & '"' & _
    ' init --repo "' & $sRepo & '"' & _
    ' --password-file "' & $sPwdFile & '"'


Local $iResult = RunWait($sCmd, "", @SW_SHOW)

; MsgBox(64, "Return Code", $iResult)

RunWait($sCmd, "", @SW_HIDE)

      

       ; Initialize only if not already initialized
If Not FileExists($sRepo & "\config") Then

    Local $sPwdFile = "C:\CipherSync\CipherSync-password.txt"

    Local $sCmd = '"' & $sCipherSyncExe & '"' & _
        ' init --repo "' & $sRepo & '"' & _
        ' --password-file "' & $sPwdFile & '"'

    Local $iResult = RunWait($sCmd, "", @SW_HIDE)

EndIf

; Verify repository
If FileExists($sRepo & "\config") Then

    MsgBox(64, _
        "Success", _
        "Repository ready." & @CRLF & _
        "Location: " & $sRepo)

Else

    MsgBox(16, _
        "Repository Error", _
        "Repository initialization failed.")

    Return

EndIf

        EndIf

    

    MsgBox(64, _
        "Success", _
        "Repository ready." & @CRLF & @CRLF & _
        "Repository:" & @CRLF & _
        $sRepo & @CRLF & @CRLF & _
        "Folders Selected: " & _
        UBound($aFolders))
_CreateBackupBat($sRepo, $sCipherSyncExe)

_CreateSchedule()

If MsgBox(36, _
    "Initial Backup", _
    "Repository created successfully." & @CRLF & _
    "Run first backup now?") = 6 Then

    _RunFirstBackup()

EndIf

MsgBox(64, _
    "Completed", _
    "Backup setup completed successfully." & @CRLF & _
    "Repository : " & $sRepo & @CRLF & _
    "BAT File : C:\CipherSync\BackupNow.bat" & @CRLF & _
    "Log File : C:\CipherSync\Backup.log")
EndFunc
Func _CreateBackupBat($sRepo, $sCipherSyncExe)

    Local $sBat = "C:\CipherSync\BackupNow.bat"
    Local $sLog = "C:\CipherSync\Backup.log"

    FileDelete($sBat)

    FileWriteLine($sBat, "@echo off")
    FileWriteLine($sBat, "set RESTIC_REPOSITORY=" & $sRepo)
    FileWriteLine($sBat, "set RESTIC_PASSWORD_FILE=C:\CipherSync\CipherSync-password.txt")
    FileWriteLine($sBat, "")

    FileWriteLine($sBat, "echo ===================================== >> """ & $sLog & """")
    FileWriteLine($sBat, "echo Backup Started : %date% %time% >> """ & $sLog & """")
    FileWriteLine($sBat, "echo ===================================== >> """ & $sLog & """")

    Local $sCmd = '"' & $sCipherSyncExe & '" backup '

    ; Add folders
    For $i = 0 To UBound($aFolders) - 1
        $sCmd &= '"' & $aFolders[$i] & '" '
    Next

    ; Add exclusions
    Local $sExclude = GUICtrlRead($txtExclude)
    Local $aExclude = StringSplit(StringStripCR($sExclude), @LF)

    For $i = 1 To $aExclude[0]
        If StringStripWS($aExclude[$i], 8) <> "" Then
            $sCmd &= '--exclude "' & $aExclude[$i] & '" '
        EndIf
    Next

    $sCmd &= '--verbose >> "' & $sLog & '" 2>&1'

    FileWriteLine($sBat, $sCmd)

    FileWriteLine($sBat, "")
    FileWriteLine($sBat, "echo ===================================== >> """ & $sLog & """")
    FileWriteLine($sBat, "echo Backup Finished : %date% %time% >> """ & $sLog & """")
    FileWriteLine($sBat, "echo ===================================== >> """ & $sLog & """")

EndFunc
Func _CreateSchedule()

    Local $sBat = "C:\CipherSync\BackupNow.bat"

    Local $sMorning = GUICtrlRead($txtMorningTime)
    Local $sEvening = GUICtrlRead($txtEveningTime)

    RunWait(@ComSpec & _
        ' /c schtasks /delete /tn "CipherSync_Morning" /f', "", @SW_HIDE)

    RunWait(@ComSpec & _
        ' /c schtasks /delete /tn "CipherSync_Evening" /f', "", @SW_HIDE)

    RunWait(@ComSpec & _
        ' /c schtasks /create /sc daily /tn "CipherSync_Morning" /tr "' & _
        $sBat & '" /st ' & $sMorning & ' /f', "", @SW_HIDE)

    RunWait(@ComSpec & _
        ' /c schtasks /create /sc daily /tn "CipherSync_Evening" /tr "' & _
        $sBat & '" /st ' & $sEvening & ' /f', "", @SW_HIDE)

EndFunc



Func _RunFirstBackup()

    Local $sBat = "C:\CipherSync\BackupNow.bat"

    RunWait($sBat)

EndFunc

While 1

    Switch GUIGetMsg()
Case $btnLicense
            _EnterLicenseKey()
       Case $GUI_EVENT_CLOSE
		Case $GUI_EVENT_CLOSE

    GUIDelete($hSnap)

    Return

            Exit

        Case $btnExit
            Exit

        Case $btnBrowseRepo

            Local $sRepo = FileSelectFolder( _
                "Select Repository Location", _
                "")

            If $sRepo <> "" Then
                GUICtrlSetData($txtRepoLocation, $sRepo)
            EndIf

   
 
Case $btnAddFolder

    _AddFolder()
           


   Case $btnRemoveFolder

    _RemoveFolder()
Case $btnRestore

    

    Local $sRepo = FileSelectFolder( _
        "Select CipherSync Repository", "")

   If $sRepo = "" Then ContinueLoop

    Local $sPwd = InputBox( _
        "Repository Password", _
        "Enter repository password:", _
        "", "*")

    If @error Or $sPwd = "" Then Return

    ; Create temporary password file
    Local $sPwdFile = @TempDir & "\CipherSyncRestorePwd.txt"

    FileDelete($sPwdFile)
    FileWrite($sPwdFile, $sPwd)

    _ShowSnapshots($sRepo, $sPwdFile)
	
        Case $btnCreate
    _CreateRepository()

    EndSwitch

WEnd

; ===== CipherSync License Functions =====
Func _GetMachineID()
    Local $sDrive = DriveGetSerial("C:\")
    Return @ComputerName & "-" & Hex($sDrive)
EndFunc

Func _CheckRestoreLicense()
    If _HasValidLicense() Then Return True
    Local $sDir = @AppDataDir & "\CipherSync"
    Local $sFile = $sDir & "\restorecount.dat"
    DirCreate($sDir)

    Local $iCount = 0
    If FileExists($sFile) Then $iCount = Number(FileRead($sFile))

    If $iCount >= 3 Then
        MsgBox(48, "License Required", _
            "The free edition allows up to 3 restore operations." & @CRLF & @CRLF & _
            "Machine ID: " & _GetMachineID() & @CRLF & @CRLF & _
            "Please email this Machine ID to:" & @CRLF & _
            "anishkumarn@gmail.com")
        Return False
    EndIf
    Return True
EndFunc

Func _IncrementRestoreCount()
    Local $sDir = @AppDataDir & "\CipherSync"
    Local $sFile = $sDir & "\restorecount.dat"
    DirCreate($sDir)

    Local $iCount = 0
    If FileExists($sFile) Then $iCount = Number(FileRead($sFile))
    $iCount += 1

    FileDelete($sFile)
    FileWrite($sFile, $iCount)
EndFunc
; =======================================


Func _EnterLicenseKey()
    Local $sKey = InputBox("License Activation", "Enter the license key received from Team CipherSync")
    If @error Then Return

    DirCreate(@AppDataDir & "\CipherSync")
    FileDelete(@AppDataDir & "\CipherSync\license.key")
    FileWrite(@AppDataDir & "\CipherSync\license.key", $sKey)

    MsgBox(64, "License Saved", "License key saved successfully." & @CRLF & "Please restart CipherSync.")
EndFunc

Func _HasValidLicense()
    Return FileExists(@AppDataDir & "\CipherSync\license.key")
EndFunc
