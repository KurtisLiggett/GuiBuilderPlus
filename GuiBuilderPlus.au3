#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/MO

; #HEADER# ======================================================================================================================
; Title .........: GUIBuilderPlus
; AutoIt Version : 3.3.14.5
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
;  03/31/2023 ...:	- ADDED:	Add events to controls (right-click menu or double click)
;					- ADDED:	Add options to code preview window for convenience
;					- FIXED:	Could not 'undo' drawing of new control
;
;  09/19/2022 ...:	- CHANGED:	More sophisticated handling of AutoIt3.exe location
;  03/29/2023 ...:	- ADDED:	Undo / redo functionality
;					- ADDED:	Change window title to match Title property
;					- FIXED:	Jumping while resizing
;					- UPDATED:	Updated About dialog
;
; Roadmap .......:	- Finish control properties tabs
;					- Windows' theme support
;					- Use single resize box for multiple selected controls
;
; ===============================================================================================================================

#Region project-settings
#AutoIt3Wrapper_Res_HiDpi=y
#AutoIt3Wrapper_UseX64=N
#AutoIt3Wrapper_Icon=resources\icons\icon.ico
#AutoIt3Wrapper_OutFile=GUIBuilderPlus v1.0.0-beta5.exe
#AutoIt3Wrapper_Res_Fileversion=1.0.0
#AutoIt3Wrapper_Res_Description=GUI Builder Plus
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 1.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 2.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 3.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 4.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 5.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 6.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 7.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 8.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 9.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 10.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 11.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 12.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 13.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 14.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 15.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 16.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 17.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 18.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 19.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 20.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 21.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 22.ico
#AutoIt3Wrapper_Res_Icon_Add=resources\icons\icon 23.ico

Opt("WinTitleMatchMode", 4) ; advanced
Opt("MouseCoordMode", 2)
Opt("GUIOnEventMode", 1)
Opt("GuiEventOptions", 1)
#EndRegion project-settings

Global $grippy_size = 5
Global $debug = True

#Region ; globals
;GUI components
Global $hGUI, $hToolbar, $hFormGenerateCode, $hFormObjectExplorer, $hStatusbar, $hAbout, $hEvent
Global $iGuiFrameH, $iGuiFrameW, $defaultGuiBkColor = 0xF0F0F0
Global $menu_wipe, $contextmenu_lock
;Settings menu
Global $menu_show_grid, $menu_grid_snap, $menu_paste_pos, $menu_show_ctrl, $menu_show_hidden, $menu_dpi_scaling, $menu_gui_function, $menu_onEvent_mode
;View menu
Global $menu_generateCode, $menu_ObjectExplorer
;Background
Global $background, $background_contextmenu, $background_contextmenu_paste
Global $overlay = -1, $overlay_contextmenu, $overlay_contextmenutab
;grippys
;~ Global $NorthWest_Grippy, $North_Grippy, $NorthEast_Grippy, $West_Grippy, $East_Grippy, $SouthWest_Grippy, $South_Grippy, $SouthEast_Grippy
;code generation popup
Global $editCodeGeneration, $radio_msgMode, $radio_eventMode, $check_guiFunc
;object explorer popup
Global $lvObjects, $labelObjectCount, $childSelected
;control events popup
Global $editEventCode

;Property Inspector
Global $oProperties_Main, $oProperties_Ctrls, $tabSelected, $tabProperties, $tabStyles, $tabStylesHwnd

;GUI Constants
Global Const $grid_ticks = 10
Global Const $iconset = @ScriptDir & "\resources\Icons\" ; Added by: TheSaint
Global Enum $mode_default, $mode_draw, $mode_drawing, $mode_init_move, $mode_init_selection, $mode_paste, _
		$resize_nw, $resize_n, $resize_ne, $resize_e, $resize_se, $resize_s, $resize_sw, $resize_w
Global Enum $props_Main, $props_Ctrls
; Cursor Consts - added by: Jaberwacky
Global Const $ARROW = 2, $CROSS = 3, $SIZE_ALL = 9, $SIZENESW = 10, $SIZENS = 11, $SIZENWSE = 12, $SIZEWS = 13
Global Enum $action_nudgeCtrl, $action_moveCtrl, $action_resizeCtrl, $action_deleteCtrl, $action_createCtrl, $action_renameCtrl, $action_changeColor, $action_changeBkColor, $action_pasteCtrl, $action_changeText, $action_changeCode, $action_drawCtrl

;other variables
Global $bStatusNewMessage
Global $right_click = False
Global $left_click = False, $ctrlClicked = False
Global $bResizedFlag
Global $testFileName, $TestFilePID = 0, $bReTest = 0, $aTestGuiPos, $hTestGui
Global $au3InstallPath
Global $initDraw, $initResize
Global $hSelectionGraphic = -1
Global $dblClickTime

;Control Objects
Global $oMain, $oCtrls, $oSelected, $oClipboard, $oMouse
Global $aStackUndo[0], $aStackRedo[0]

; added by: TheSaint (most are my own, others just not declared)
Global $AgdOutFile, $lfld, $mygui
Global $setting_snap_grid, $setting_paste_pos, $setting_show_control, $setting_show_hidden, $setting_dpi_scaling, $setting_gui_function, $setting_onEvent_mode

Global $sampleavi = @ScriptDir & "\resources\sampleAVI.avi"
Global $samplebmp = @ScriptDir & "\resources\SampleImage.bmp"
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
#include "GuiBuilderPlus_objCtrl.au3"
#include "GuiBuilderPlus_objProperties.au3"
#include "GuiBuilderPlus_CtrlMgmt.au3"
#include "GuiBuilderPlus_definitionMgmt.au3"
#include "GuiBuilderPlus_codeGeneration.au3"
#include "GuiBuilderPlus_formMain.au3"
#include "GuiBuilderPlus_formPropertyInspector.au3"
#include "GuiBuilderPlus_formGenerateCode.au3"
#include "GuiBuilderPlus_formObjectExplorer.au3"
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
	$oMain.AppVersion = "1.0.0-beta4"
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

	;make the main program GUI
	_formMain()

	;make the toolbar/properties GUI
	_formToolbar()

	_set_accelerators()

	;check if ran with parameters to load definition file
	_check_command_line()

	_initialize_settings()


	;load the extra toolbars
	If BitAND(GUICtrlRead($menu_ObjectExplorer), $GUI_CHECKED) = $GUI_CHECKED Then
		_formObjectExplorer()
	EndIf

	If BitAND(GUICtrlRead($menu_generateCode), $GUI_CHECKED) = $GUI_CHECKED Then
		_formGenerateCode()
	EndIf

	GUISetState(@SW_SHOWNORMAL, $hToolbar)
	GUISetState(@SW_SHOWNORMAL, $oProperties_Main.properties.Hwnd)
	GUISwitch($hGUI)
	GUISetState(@SW_SHOWNORMAL, $hGUI)
	$bResizedFlag = 0
	GUISetState(@SW_SHOWNOACTIVATE, $hFormObjectExplorer)
	GUISetState(@SW_SHOWNOACTIVATE, $hFormGenerateCode)
	_GUICtrlEdit_SetSel($editCodeGeneration, 0, 0)
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
;~ 	_disable_control_properties_gui()

	Local $bShowGrid = True
	Local $bPastePos = True
	Local $bGridSnap = True
	Local $bShowControl = True
	Local $bShowHidden = False
	Local $bShowCode = False
	Local $bShowObjectExplorer = False
	Local $bDpiScaling = False
	Local $bGuiFunction = False
	Local $bOnEventMode = False

	Local $aSettings = IniReadSection($sIniPath, "Settings")
	If Not @error Then
		For $i = 1 To $aSettings[0][0]
			Switch $aSettings[$i][0]
				Case "ShowGrid"
					$bShowGrid = ($aSettings[$i][1] = 1) ? True : False
				Case "PastePos"
					$bPastePos = ($aSettings[$i][1] = 1) ? True : False
				Case "GridSnap"
					$bGridSnap = ($aSettings[$i][1] = 1) ? True : False
				Case "ShowControl"
					$bShowControl = ($aSettings[$i][1] = 1) ? True : False
				Case "ShowHidden"
					$bShowHidden = ($aSettings[$i][1] = 1) ? True : False
				Case "ShowCode"
					$bShowCode = ($aSettings[$i][1] = 1) ? True : False
				Case "ShowObjectExplorer"
					$bShowObjectExplorer = ($aSettings[$i][1] = 1) ? True : False
				Case "DpiScaling"
					$bDpiScaling = ($aSettings[$i][1] = 1) ? True : False
				Case "GuiInFunction"
					$bGuiFunction = ($aSettings[$i][1] = 1) ? True : False
				Case "OnEventMode"
					$bOnEventMode = ($aSettings[$i][1] = 1) ? True : False
			EndSwitch
		Next
	EndIf

	If $bShowGrid Then
		_show_grid($background, $oMain.Width, $oMain.Height)
	Else
		_hide_grid($background)
	EndIf
	_setting_show_grid(True, $bShowGrid)

	_setCheckedState($menu_show_grid, $bShowGrid)
	_setCheckedState($menu_paste_pos, $bPastePos)
	_setCheckedState($menu_grid_snap, $bGridSnap)
	_setCheckedState($menu_show_ctrl, $bShowControl)
	_setCheckedState($menu_show_hidden, $bShowHidden)
	_setCheckedState($menu_generateCode, $bShowCode)
	_setCheckedState($menu_ObjectExplorer, $bShowObjectExplorer)
	_setCheckedState($menu_dpi_scaling, $bDpiScaling)
	_setCheckedState($menu_onEvent_mode, $bOnEventMode)
	_setCheckedState($menu_gui_function, $bGuiFunction)

	$setting_paste_pos = $bPastePos
	$setting_snap_grid = $bGridSnap
	$setting_show_control = $bShowControl
	$setting_show_hidden = $bShowHidden
	$setting_dpi_scaling = $bDpiScaling
	$setting_onEvent_mode = $bOnEventMode
	$setting_gui_function = $bGuiFunction

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
