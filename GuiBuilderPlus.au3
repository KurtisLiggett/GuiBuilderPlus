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
; Revisions
;  05/17/2022 ...: 	- UPDATE:	Converted maps to objects using AutoItObject UDF
;					- FIXED:	Delete certain tab items caused a program crash
;					- FIXED:	Pasted control offset from mouse position
;					- ADDED:	Added setting to apply a DPI scaling factor to the size and position properties (includes function to get DPI factor)
;					- ADDED:	Added 'New Tab' and 'Delete Tab' items in Object Explorer right-click context menu
;					- KNOWN ISSUE: Property tabs other than 'Main' are temporarily disabled (don't do anything)
;
;  05/13/2022 ...: 	- FIXED:	Tab control not showing when grid is on
;					- FIXED:	Tab control and tab item creation now should work properly
;					- FIXED:	Right-click menu deletes wrong item
;					- FIXED:	Right-click context menu showing wrong/duplicate items
;					- FIXED:	Fixed crash when changing properties of multiple controls at once (now works great for aligning controls!)
;					- FIXED:	Text and name properties were limited to only the characters that could fit in the box
;					- FIXED:	Spaces in Name property will now be replaced with underscores _
;					- ADDED:	New tab and delete tab context menu items
;					- ADDED:	Text color property for labels (works on multiple selection)
;					- ADDED:	Background color property for labels (works on multiple selection)
;					- ADDED:	New statusbar to show messages instead of popups and splash screens
;					- UPDATED:	Better positioning of extra tool windows
;					- UPDATED:	Arrow keys will now "nudge" the controls by 1 px, Ctrl+arrow key will move the controls by 10px
;					- UPDATED:	Copy+Paste should not change the control text
;					- UPDATED:	Changed object explorer from listview to treeview to show tab items
;					- KNOWN ISSUE:	Deleting a Tab control also deletes the property inspector!
;
;  05/11/2022 ...: 	- FIXED: object explorer and code viewer not updated after .agd load
;					- FIXED: object explorer not updated after copy/paste
;					- FIXED: properties not disabled after finish drawing (also caused property crash)
;					- FIXED: All "Main" properties now function properly - other tabs still not implemented yet (will most likely crash)
;					- FIXED: skipped mouse click after closing one of the tool windows
;					- FIXED: Drag move of selection broken after last update
;					- ADDED: Copy menu item (edit menu)
;					- ADDED: Paste menu item (edit menu)
;					- ADDED: Duplicate menu item (edit menu or Ctrl+D) <- copy+paste with offset (try it and see)
;					- ADDED: Minimize/restore the program
;					- ADDED: Increase/decrease properties with arrow keys or mouse scroll
;					- ADDED: Keyboard shortcut (F5) to run/test the form
;					- ADDED: First pass at function description template (insert comment for function title based on template file)
;					- UPDATED: Changed the look of the properties inspector (still a work in progress)
;					- UPDATED: Changed icon to be more in line with original GuiBuilder
;					- UPDATED: Modified code generation to cleaner layout (in my opinion)
;					- UPDATED: Modified test function to use _TempFile()
;					- REMOVED: Vals menu item (edit menu) - superseded by new object explorer
;
;  05/10/2022 ...: 	- ADDED: Object Explorer window to display the list of objects (view, select, and delete from list)
;					- ADDED: Last tool stays selected for multiple creation. Clicking away stops drawing.
;					- ADDED: "_" back for default control names
;					- FIXED: Issue with controls getting mixed up after deleting
;					- FIXED: More intuitive/responsive clicking on and away from controls
;					- FIXED: Graphic glitch when creating a new combobox
;					- FIXED: Graphic glitch when clearing all controls
;					- FIXED: Updown control invalid generated code
;					- FIXED: Weird selection behavior when Updown control exists
;					- FIXED: Pic control not showing the bitmap on drawing or generated GUI
;					- FIXED: View Code dialog state not saved when clicking close[X] button
;					- Other: Changed default text from Button1 to Button 1 (space)
;
;  05/08/2022 ...: 	- FIXED BUG: last control was always selected and moved after resizing or moving the GUI
;					- FIXED BUG: minor formatting issues with generated GUICtrlCreate function names
;					- FIXED BUG: crash/failure when dragging .adb definition file onto compiled exe
;					- FIXED BUG: cannot properly change text or name properties
;					- FIXED BUG(?): generated code did not match control names in the properties toolbar
;					- FIXED BUG: if ini directory did not exist, could not write to ini file
;					- ADDED: Live Generated Code dialog to view/save the generated code (View menu)
;					- ADDED: Test GUI to preview the GUI (Tools menu)
;					- ADDED: Nudge controls by 1 pixel (or nearest grid space) with arrow keys
;					- ADDED: Keyboard shortcut to turn grid on/off
;					- ADDED: Keyboard shortcut to turn grid snap on/off
;					- More efficient INI file reading
;					- New program icon
;					- Removed MouseOnEvent UDF for now, causing crashes when clicking on anything - didn't want to investigate
;					- Updated/cleaned up AutoIt3Wrapper options
;					- Fixed some Local Const declaration issues
;					- Fixed 'state' tab vertical spacing
;					- Tidy'd code
;					- Started organizing code, breaking up into manageable chunks
;					- Started reigning in the sporadic use of Global/local variables
;					- Started documenting functions
;					- Removed/updated some antiquated references and functions
;					- Updated to latest StringSize UDF
;
; Roadmap .......:	- Finish investigating and documenting the code
;					- Add custom multiplier to controls' position and size (for DPI scaling)
;					- Add option to make GUI in separate function
;					- Add options for declaring controls as global or local
;					- Support for Msg or OnEvent mode attached to controls (still debating)
;					- Add IP control
;					- Add GUI options like background color, width, height, position
;					- Add control alignment buttons (left, right, top, bottom)
;					- Finish control properties tabs
;					- Make group selection more robust
;					- Add shortcut to select all controls (for moving, deleting)
;					- creating controls on top of TAB will place them inside the tab
;					- Undo / Redo functionality
;					- Make grippies into Objects, so we may have multiple
;
; Known Issues ..:	- Property Inspector gets deleted when deleting TAB control
;					- State, style, and ex style properties not implemented yet
;					- Menu control not implemented yet
; ===============================================================================================================================

#Region project-settings
;~ #AutoIt3Wrapper_Run_Au3Stripper=y
#AutoIt3Wrapper_Res_HiDpi=y
#AutoIt3Wrapper_UseX64=N
#AutoIt3Wrapper_Icon=resources\icons\icon.ico
#AutoIt3Wrapper_OutFile=GUIBuilderPlus v0.22.exe
#AutoIt3Wrapper_Res_Fileversion=0.22.0.0
#AutoIt3Wrapper_Res_Description=GUI Builder Plus

Opt("WinTitleMatchMode", 4) ; advanced
Opt("MouseCoordMode", 2)
Opt("GUIOnEventMode", 1)
Opt("GuiEventOptions", 1)
#EndRegion project-settings

#Region ; globals
Const $grid_ticks = 10

;GUI components
Global $hGUI, $hFormGenerateCode, $toolbar, $hFormObjectExplorer, $hStatusbar, $bStatusNewMessage
Global $menu_wipe
Global $menu_testForm
Global $overlay_contextmenu_newtab, $overlay_contextmenu_deletetab, $hoverlay_contextmenu_newtab, $hoverlay_contextmenu_deletetab, $hoverlay_contextmenu
Global $menu_show_grid, $menu_grid_snap, $menu_paste_pos, $menu_show_ctrl, $menu_show_hidden, $menu_dpi_scaling
Global $menu_generateCode, $menu_ObjectExplorer
Global $background, $background_contextmenu, $background_contextmenu_paste
Global $overlay, $overlay_contextmenu, $overlay_contextmenutab
;grippys
Global $NorthWest_Grippy, $North_Grippy, $NorthEast_Grippy, $West_Grippy, $East_Grippy, $SouthWest_Grippy, $South_Grippy, $SouthEast_Grippy
;main tab
Global $h_form_text, $h_form_name, $h_form_left, $h_form_top, $h_form_width, $h_form_fittowidth, $h_form_height, $h_form_Color, $h_form_bkColor
;state tab
Global $h_form_visible, $h_form_enabled, $h_form_ontop, $h_form_dropaccepted, $h_form_focus
;style tab
Global $h_form_style_autocheckbox, $h_form_style_top
;code generation popup
Global $editCodeGeneration
;object explorer popup
Global $lvObjects, $labelObjectCount, $childSelected
;background graphics
;~ Global $hBgGraphic

;Property Inspector


;GUI Constants
Global Const $main_width = 400
Global Const $main_height = 350
Global Const $main_left = (@DesktopWidth / 2) - ($main_width / 2)
Global Const $main_top = (@DesktopHeight / 2) - ($main_height / 2)
Global Const $toolbar_width = 215
Global Const $toolbar_height = 480
Global Const $toolbar_left = $main_left - ($toolbar_width + 5)
Global Const $toolbar_top = $main_top
Global Const $iconset = @ScriptDir & "\resources\Icons\" ; Added by: TheSaint
Global Const $grippy_size = 5
Const $default = 0, $draw = 1, $init_move = 2, $move = 3, $init_selection = 4, $selection = 5, _
		$resize_nw = 6, $resize_n = 7, $resize_ne = 8, $resize_e = 9, $resize_se = 10, $resize_s = 11, $resize_sw = 12, $resize_w = 13
; Cursor Consts - added by: Jaberwacky
Global Const $ARROW = 2, $CROSS = 3, $SIZE_ALL = 9, $SIZENESW = 10, $SIZENS = 11, $SIZENWSE = 12, $SIZEWS = 13


;other variables
Global $progName = "GUIBuilderPlus"
Global $progVersion = "v0.22"
Global $default_cursor
Global $win_client_size
Global $mode = $default
Global $right_click = False
Global $left_click = False
Global $bResizedFlag
Global $bGuiClick, $mainName = ""
Global $testFileName
Global $TestFilePID = 0, $bReTest = 0, $aTestGuiPos, $hTestGui
Global $au3InstallPath = @ProgramFilesDir & "\AutoIt3\AutoIt3.exe"
Global $initDraw, $initResize

;Control Objects
Global $oCtrls, $oSelected, $oClipboard
Global $mMouse[]

; added by: TheSaint (most are my own, others just not declared)
Global $AgdInfile, $AgdOutFile, $gdtitle, $lfld, $mygui
Global $setting_snap_grid, $setting_paste_pos, $setting_show_control, $setting_show_hidden, $setting_dpi_scaling

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
#include <Misc.au3>
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
#include "UDFS\Functions.au3"
#include "UDFs\StringSize.au3"
#include "GuiBuilderPlus_objCtrl.au3"
#include "GuiBuilderPlus_CtrlMgmt.au3"
#include "GuiBuilderPlus_definitionMgmt.au3"
#include "GuiBuilderPlus_codeGeneration.au3"
#include "GuiBuilderPlus_formMain.au3"
#include "GuiBuilderPlus_formPropertyInspector.au3"
#include "GuiBuilderPlus_formGenerateCode.au3"
#include "GuiBuilderPlus_formObjectExplorer.au3"
#EndRegion ; includes


;run the main loop
_main()


;------------------------------------------------------------------------------
; Title...........: _main
; Description.....: Create the main GUI and run the main program loop.
;------------------------------------------------------------------------------
Func _main()
	;create the controls container objects
	$oCtrls = _objCtrls()
	$oSelected = _objCtrls()
	$oClipboard = _objCtrls()

	;make the main program GUI
	_formMain()

	;make the toolbar/properties GUI
	_formToolbar()

	_set_accelerators()

	;check if ran with parameters to load definition file
	_check_command_line()

	_get_script_title()

	_initialize_settings()

	;load the extra toolbars
	If BitAND(GUICtrlRead($menu_ObjectExplorer), $GUI_CHECKED) = $GUI_CHECKED Then
		_formObjectExplorer()
	EndIf

	If BitAND(GUICtrlRead($menu_generateCode), $GUI_CHECKED) = $GUI_CHECKED Then
		_formGenerateCode()
	EndIf

	GUISetState(@SW_SHOWNORMAL, $toolbar)
	GUISetState(@SW_SHOWNORMAL, $hGUI)
	$bResizedFlag = 0

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
			Else
				$aTestGuiPos = WinGetPos(_WinGetByPID($TestFilePID))
			EndIf
		EndIf

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
			$AgdInfile = FileGetLongName($CmdLine[1])
			MsgBox(0, "", $AgdInfile)
			_load_gui_definition($AgdInfile)
		EndIf
	EndIf
EndFunc   ;==>_check_command_line


;------------------------------------------------------------------------------
; Title...........: _get_script_title
; Description.....: Get/create the script title
;------------------------------------------------------------------------------
Func _get_script_title()
	If $AgdInfile = "" Then
		$gdtitle = WinGetTitle("classname=SciTEWindow", "")
	Else
		$gdtitle = $AgdOutFile
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
EndFunc   ;==>_get_script_title


;------------------------------------------------------------------------------
; Title...........: _initialize_settings
; Description.....: Read and initialize INI file settings
;------------------------------------------------------------------------------
Func _initialize_settings()
	_disable_control_properties_gui()

	Local $bShowGrid = True
	Local $bPastePos = True
	Local $bGridSnap = True
	Local $bShowControl = True
	Local $bShowHidden = False
	Local $bShowCode = False
	Local $bShowObjectExplorer = False
	Local $bDpiScaling = False

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
			EndSwitch
		Next
	EndIf

	If $bShowGrid Then
		_show_grid($background, $win_client_size[0], $win_client_size[1])
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

	$setting_paste_pos = $bPastePos
	$setting_snap_grid = $bGridSnap
	$setting_show_control = $bShowControl
	$setting_show_hidden = $bShowHidden
	$setting_dpi_scaling = $bDpiScaling

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
