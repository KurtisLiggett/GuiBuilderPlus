#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/MO

; #HEADER# ======================================================================================================================
; Title .........: GUIBuilderPlus
; AutoIt Version : 3.3.16.0
; Description ...: Build GUI with GUI based heavily on GuiBuilderNxt
;
; Remarks .......:
;
; Author(s) .....: 	- kurtykurtyboy updates to create GUIBuilderPlus based on GUIBuilderNxt ( May 8, 2022 )
;
;
; Credit(s) .....: 	- jaberwacky: updates to create GUIBuilderNxt ( August 17, 2016 )
;					- CyberSlug, Roy, TheSaint, and many others: created/enhanced the original AutoBuilder/GUIBuilder
;
; Latest Revisions
;  05/12/2023 ...:
;					- FIXED:	Code preview not highlighting #Region/#EndRegion
;					- FIXED:	Bugs in AVI control code
;					- ADDED:	Image select button for AVI
;					- UPDATED:	New single Image control replaces Pic, Icon, and AVI controls
;					- UPDATED:	New button icons
;					- UPDATED:	Better tray menu handling
;
; Roadmap .......:	- Finish control properties tabs
;					- Windows' theme support
;					- Use single resize box for multiple selected controls
;
; ===============================================================================================================================

#Region project-settings
#AutoIt3Wrapper_Res_HiDpi=N
#AutoIt3Wrapper_UseX64=N
#AutoIt3Wrapper_Icon=resources\icons\icon.ico
#AutoIt3Wrapper_OutFile=GUIBuilderPlus v1.2.0.exe
#AutoIt3Wrapper_Res_Fileversion=1.2.0
#AutoIt3Wrapper_Res_Description=GUI Builder Plus
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 1.ico,201
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 2.ico,202
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 3.ico,203
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 4.ico,204
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 5.ico,205
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 6.ico,206
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 7.ico,207
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 8.ico,208
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 9.ico,209
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 10.ico,210
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 11.ico,211
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 12.ico,212
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 13.ico,213
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 14.ico,214
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 15.ico,215
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 17.ico,217
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 19.ico,219
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 21.ico,221
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 22.ico,222
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 23.ico,223
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 24.ico,224
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 25.ico,225
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 26.ico,226

Opt("WinTitleMatchMode", 4) ; advanced
Opt("MouseCoordMode", 2)
Opt("GUIOnEventMode", 1)
Opt("GuiEventOptions", 1)
Opt("TrayAutoPause", 0)
Opt("TrayOnEventMode", 1)
Opt("TrayMenuMode", 3)
TraySetClick(8) ; $TRAY_CLICK_SECONDARYDOWN
#EndRegion project-settings

Global $grippy_size = 5
Global $debug = True

#Region ; globals
;GUI components
Global $hGUI, $hToolbar, $hFormGenerateCode, $hFormObjectExplorer, $hStatusbar, $hAbout, $hEvent, $hSettings, $hFormHolder
Global $iGuiFrameH, $iGuiFrameW, $defaultGuiBkColor = 0xF0F0F0
Global $button_graphic
Global $menu_wipe, $contextmenu_lock, $menu_helpchm
;File menu
Global $menu_file, $aMenuRecentList[12]
;Settings menu
Global $menu_show_grid
;View menu
Global $menu_generateCode, $menu_ObjectExplorer
;Background
Global $background, $background_contextmenu, $background_contextmenu_paste
Global $overlay = -1, $overlay_contextmenu, $overlay_contextmenutab
;grippys
;~ Global $NorthWest_Grippy, $North_Grippy, $NorthEast_Grippy, $West_Grippy, $East_Grippy, $SouthWest_Grippy, $South_Grippy, $SouthEast_Grippy
;code generation popup
Global $editCodeGeneration, $radio_msgMode, $radio_eventMode, $check_guiFunc, $labelCodeGeneration
;object explorer popup
Global $lvObjects, $labelObjectCount, $childSelected
;control events popup
Global $editEventCode
;settings popup
Global $settingsChk_snapgrid, $settingsChk_pasteatmouse, $settingsChk_guifunction, $settingsChk_eventmode, $settingsInput_gridsize
;list items popup
Global $hListItems, $editListItems

;Property Inspector
Global $oProperties_Main, $oProperties_Ctrls, $tabSelected, $tabProperties, $tabStyles, $tabStylesHwnd
Global $properties_fontButton, $properties_borderButton

;GUI Constants
Global Const $iconset = @ScriptDir & "\resources\Icons\" ; Added by: TheSaint
Global Enum $mode_default, $mode_draw, $mode_drawing, $mode_init_move, $mode_init_selection, $mode_paste, _
		$resize_nw, $resize_n, $resize_ne, $resize_e, $resize_se, $resize_s, $resize_sw, $resize_w
Global Enum $props_Main, $props_Ctrls
; Cursor Consts - added by: Jaberwacky
Global Const $ARROW = 2, $CROSS = 3, $SIZE_ALL = 9, $SIZENESW = 10, $SIZENS = 11, $SIZENWSE = 12, $SIZEWS = 13
Global Enum $action_nudgeCtrl, $action_moveCtrl, $action_resizeCtrl, $action_deleteCtrl, $action_createCtrl, $action_renameCtrl, $action_changeColor, $action_changeBkColor, $action_pasteCtrl, _
		$action_changeText, $action_changeCode, $action_drawCtrl, $action_changeBorderColor, $action_changeBorderSize

;other variables
Global $bStatusNewMessage
Global $guiFontName
Global $right_click = False
Global $left_click = False, $ctrlClicked = False
Global $bResizedFlag
Global $testFileName, $TestFilePID = 0, $bReTest = 0, $aTestGuiPos, $hTestGui
Global $au3InstallPath
Global $initDraw, $initResize
Global $hSelectionGraphic = -1
Global $dblClickTime

;Control Objects
Global $oMain, $oCtrls, $oSelected, $oClipboard, $oMouse, $oOptions
Global $aStackUndo[0], $aStackRedo[0]

; added by: TheSaint (most are my own, others just not declared)
Global $AgdOutFile, $lfld, $mygui

Global $sampleavi = @ScriptDir & "\resources\sampleAVI.avi"
Global $samplebmp = @ScriptDir & "\resources\SampleImage.jpg"
Global $sampleicon = @ScriptDir & "\resources\icons\icon.ico"
Global $sIniPath = @ScriptDir & "\storage\GUIBuilderPlus.ini"
#EndRegion ; globals

#Region ; includes
#include "UDFs\AutoItObject.au3"
#include "UDFs\oLinkedList.au3"
_AutoItObject_StartUp()

#include <Array.au3>
#include <AVIConstants.au3>
#include <ButtonConstants.au3>
#include <Constants.au3>
#include <FileConstants.au3>
#include <FontConstants.au3>
#include <GuiConstantsEx.au3>
#include <ComboConstants.au3>
#include <GuiComboBox.au3>
#include <GuiTab.au3>
#include <GuiListView.au3>
#include <GuiIPAddress.au3>
#include <Misc.au3>
#include <GDIPlus.au3>
#include <WinAPIGdi.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <StaticConstants.au3>
#include <ListViewConstants.au3>
#include <TreeViewConstants.au3>
#include <UpDownConstants.au3>
#include <File.au3>
#include <WinAPI.au3>
#include <WinAPIMisc.au3>
#include <WinAPISys.au3>
#include <WindowsConstants.au3>
#include <WinAPIvkeysConstants.au3>
#include <GuiMenu.au3>
#include <GuiEdit.au3>
#include <GuiTreeView.au3>
#include "UDFS\Json\json.au3"
#include "UDFS\GUIScrollbars_Ex.au3"
#include "UDFs\StringSize.au3"
#include "UDFs\RESH.au3"
#include "GuiBuilderPlus_objOptions.au3"
#include "GuiBuilderPlus_objCtrl.au3"
#include "GuiBuilderPlus_objProperties.au3"
#include "GuiBuilderPlus_CtrlMgmt.au3"
#include "GuiBuilderPlus_definitionMgmt.au3"
#include "GuiBuilderPlus_codeGeneration.au3"
#include "GuiBuilderPlus_formMain.au3"
#include "GuiBuilderPlus_formPropertyInspector.au3"
#include "GuiBuilderPlus_formGenerateCode.au3"
#include "GuiBuilderPlus_formObjectExplorer.au3"
#include "GuiBuilderPlus_formAbout.au3"
#include "GuiBuilderPlus_formEventCode.au3"
#include "GuiBuilderPlus_formSettings.au3"
#include "GuiBuilderPlus_formListItems.au3"
#EndRegion ; includes


;~ Global $oMyError = ObjEvent("AutoIt.Error", "MyErrFunc")
Func MyErrFunc($oError)
	SetError(1)
	MsgBox(1, "COM Error", "COM Erorr" & @CRLF & "Error Number: " & Hex($oError.number) & @CRLF & $oError.windescription)
EndFunc   ;==>MyErrFunc

;start up the logger
_log("", True)

;run the main loop
_main()

;------------------------------------------------------------------------------
; Title...........: _main
; Description.....: Create the main GUI and run the main program loop.
;------------------------------------------------------------------------------
Func _main()
	_log("Startup")
	_GDIPlus_Startup()
	$dblClickTime = _GetDoubleClickTime()

	;create the main program data objects
	$oMouse = _objCreateMouse()
	$oCtrls = _objCtrls()
	$oCtrls.mode = $mode_default
	$oSelected = _objCtrls(True)
	$oClipboard = _objCtrls()
	$oMain = _objMain()
	$oMain.AppName = "GuiBuilderPlus"
	$oMain.AppVersion = "1.2.0"
	$oMain.Title = StringTrimRight(StringTrimLeft(_get_script_title(), 1), 1)
	$oMain.Name = "hGUI"
	$oMain.Width = 400
	$oMain.Height = 350
	$oMain.Left = -1
	$oMain.Top = -1
	$oMain.Background = ""
	$tabSelected = "Properties"

	;create properties objects
	$oProperties_Main = _objProperties()
	$oProperties_Ctrls = _objProperties()

	;create options object
	$oOptions = _objOptions()

	;make the toolbar/properties GUI
	_formToolbar()

	;make the form GUI
	_formMain()

	_set_accelerators()

	;check if ran with parameters to load definition file
	_check_command_line()

	_initialize_settings()


	;load the extra toolbars
	If $oOptions.ShowObjectExplorer Then
		_formObjectExplorer()
	EndIf

	If $oOptions.showCodeViewer Then
		_formGenerateCode()
	EndIf

	GUISetState(@SW_SHOWNORMAL, $hToolbar)
	GUISetState(@SW_SHOWNORMAL, $oProperties_Main.properties.Hwnd)
	GUISwitch($hGUI)
	GUISetState(@SW_SHOWNORMAL, $hGUI)
	$bResizedFlag = 0
	GUISetState(@SW_SHOWNOACTIVATE, $hFormObjectExplorer)
	GUISetState(@SW_SHOWNOACTIVATE, $hFormGenerateCode)
	GUISwitch($hGUI)

	;check au3 exe path
	$au3InstallPath = IniRead($sIniPath, "Settings", "AutoIt3FullPath", "")
	If StringInStr(@AutoItExe, "\AutoIt3.exe") Or StringInStr(@AutoItExe, "\AutoIt3_x64.exe") Then $au3InstallPath = @AutoItExe

	Local $statusDelay = 3000
	Static $startTimer = False
	Do
		If $bStatusNewMessage Then
			$tStatusbarTimer = TimerInit()
			$bStatusNewMessage = False
			$startTimer = True
		EndIf
		If $startTimer = True And TimerDiff($tStatusbarTimer) > $statusDelay Then
			_GUICtrlStatusBar_SetText($hStatusbar, "")
			$startTimer = False
		EndIf
		If $TestFilePID <> 0 Then
			If Not ProcessExists($TestFilePID) Then
				$TestFilePID = 0
				If $bReTest Then
					$bReTest = 0
					_onTestGUI()
				Else
					FileDelete($testFileName)
				EndIf
;~ 			Else
;~ 				$aTestGuiPos = WinGetPos(_WinGetByPID($TestFilePID))
			EndIf
		EndIf

		_GUIScrollbars_EventMonitor()

		Sleep(100)
	Until False
EndFunc   ;==>_main


#Region functions
;------------------------------------------------------------------------------
; Title...........: _check_command_line
; Description.....: Load .agd file from cmdLine parameters (or drag onto exe)
; Author..........:	TheSaint
;------------------------------------------------------------------------------
Func _check_command_line()
	If $CmdLine[0] > 0 Then
		If StringRight($CmdLine[1], 4) = ".agd" Then
			Local $AgdInfile = FileGetLongName($CmdLine[1])
			_load_gui_definition($AgdInfile)
		EndIf
	EndIf
EndFunc   ;==>_check_command_line


;------------------------------------------------------------------------------
; Title...........: _get_script_title
; Description.....: Get/create the script title
;------------------------------------------------------------------------------
Func _get_script_title()
	Local $AgdInfile = ""
	If $CmdLine[0] > 0 Then
		If StringRight($CmdLine[1], 4) = ".agd" Then
			$AgdInfile = FileGetLongName($CmdLine[1])
		EndIf
	EndIf

	Local $gdtitle
	If $AgdOutFile <> "" Then
		$gdtitle = $AgdOutFile
	ElseIf $AgdInfile = "" Then
		$gdtitle = $AgdInfile
	Else
		$gdtitle = WinGetTitle("classname=SciTEWindow", "")
	EndIf

	If $gdtitle <> "" Then
		Local $gdvar = StringSplit($gdtitle, "\")

		$lfld = StringLeft($gdtitle, StringInStr($gdtitle, $gdvar[$gdvar[0]]) - 2)

		$gdtitle = $gdvar[$gdvar[0]]

		If $AgdInfile = "" Then
			$gdvar = StringInStr($gdtitle, ".au3")
		Else
			$gdvar = StringInStr($gdtitle, ".agd")
		EndIf

		$gdtitle = StringLeft($gdtitle, $gdvar - 1)
	Else
		$gdtitle = "MyGUI"
	EndIf

	$mygui = $gdtitle & ".au3"

	$gdtitle = '"' & $gdtitle & '"'
	Return $gdtitle
EndFunc   ;==>_get_script_title


;------------------------------------------------------------------------------
; Title...........: _initialize_settings
; Description.....: Read and initialize INI file settings
;------------------------------------------------------------------------------
Func _initialize_settings()

	$oOptions.GridSize = 5
	Local $aSettings = IniReadSection($sIniPath, "Settings")

	If Not @error Then
		For $i = 1 To $aSettings[0][0]
			Switch $aSettings[$i][0]
				Case "ShowGrid"
					$oOptions.showGrid = ($aSettings[$i][1] = 1) ? True : False
				Case "PastePos"
					$oOptions.pasteAtMouse = ($aSettings[$i][1] = 1) ? True : False
				Case "GridSnap"
					$oOptions.snapGrid = ($aSettings[$i][1] = 1) ? True : False
				Case "ShowCode"
					$oOptions.showCodeViewer = ($aSettings[$i][1] = 1) ? True : False
				Case "ShowObjectExplorer"
					$oOptions.showObjectExplorer = ($aSettings[$i][1] = 1) ? True : False
				Case "GuiInFunction"
					$oOptions.guiInFunction = ($aSettings[$i][1] = 1) ? True : False
				Case "OnEventMode"
					$oOptions.eventMode = ($aSettings[$i][1] = 1) ? True : False
				Case "GridSize"
					$oOptions.GridSize = $aSettings[$i][1]
			EndSwitch
		Next
	Else
		$oOptions.showGrid = True
		$oOptions.pasteAtMouse = True
		$oOptions.guiInFunction = True
		$oOptions.eventMode = False
	EndIf

	If $oOptions.showGrid Then
		_show_grid($background, $oMain.Width, $oMain.Height)
	Else
		_hide_grid($background)
	EndIf

	_setCheckedState($menu_show_grid, $oOptions.showGrid)
	_setCheckedState($menu_generateCode, $oOptions.showCodeViewer)
	_setCheckedState($menu_ObjectExplorer, $oOptions.ShowObjectExplorer)

	If Not FileExists("storage") Then
		DirCreate("storage")
	EndIf
EndFunc   ;==>_initialize_settings


;------------------------------------------------------------------------------
; Title...........: _setCheckedState
; Description.....: Set control checked state from BOOL/INT
;------------------------------------------------------------------------------
Func _setCheckedState($ctrlID, $bState)
	If $bState Then
		GUICtrlSetState($ctrlID, $GUI_CHECKED)
	Else
		GUICtrlSetState($ctrlID, $GUI_UNCHECKED)
	EndIf
EndFunc   ;==>_setCheckedState
#EndRegion functions


Func _objCreateMouse()
	Local $oSelf = _AutoItObject_Create()

	_AutoItObject_AddProperty($oSelf, "X", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oSelf, "Y", $ELSCOPE_PUBLIC, 0)

	_AutoItObject_AddProperty($oSelf, "StartX", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oSelf, "StartY", $ELSCOPE_PUBLIC, 0)

	Return $oSelf
EndFunc   ;==>_objCreateMouse


Func _log($sMessage, $startup = False)
	Static $tTimer = TimerInit()

	If $startup Or Not $debug Then Return

	Local $iTime = Floor(TimerDiff($tTimer))
	Local $sTime = StringFormat("%d:%.2d:%06.3f", (Floor($iTime / 3600000)), (Floor(Mod($iTime, 3600000) / 60000)), (Mod(Mod($iTime, 3600000), 60000) / 1000))

	If $sMessage == "" Then
		ConsoleWrite(@CRLF)
	Else
		ConsoleWrite($sTime & ":  " & $sMessage & @CRLF)
	EndIf
EndFunc   ;==>_log
