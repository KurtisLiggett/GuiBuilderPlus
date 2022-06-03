; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formMain.au3
; Description ...: Create the main GUI
; ===============================================================================================================================

#Region formMain
;------------------------------------------------------------------------------
; Title...........: _formMain
; Description.....: Create the blank form designer GUI
;------------------------------------------------------------------------------
Func _formMain()
	Local $main_left, $main_top

	;create the GUI
	Local $sPos = IniRead($sIniPath, "Settings", "posMain", "")
	If $sPos <> "" Then
		Local $aPos = StringSplit($sPos, ",")
		$main_left = $aPos[1]
		$main_top = $aPos[2]
	Else
		$main_left = (@DesktopWidth / 2) - ($oMain.Width / 2)
		$main_top = (@DesktopHeight / 2) - ($oMain.Height / 2)
	EndIf

	$hGUI = GUICreate($oMain.AppName & " - Form (" & $oMain.Width & ", " & $oMain.Height & ')', $oMain.Width, $oMain.Height, $main_left, $main_top, BitOR($WS_SIZEBOX, $WS_SYSMENU, $WS_MINIMIZEBOX), $WS_EX_ACCEPTFILES)

	_getGuiFrameSize()
	WinMove($hGUI, "", Default, Default, $oMain.Width + $iGuiFrameW, $oMain.Height + $iGuiFrameH)

	WinSetTitle($hGUI, "", $oMain.AppName & " - Form (" & $oMain.Width & ", " & $oMain.Height & ")")



	;GUI events
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExit", $hGUI)
	GUISetOnEvent($GUI_EVENT_MINIMIZE, "_onMinimize", $hGUI)
	GUISetOnEvent($GUI_EVENT_RESTORE, "_onRestore")
	GUISetOnEvent($GUI_EVENT_RESIZED, "_onResize", $hGUI)
	GUISetOnEvent($GUI_EVENT_PRIMARYDOWN, "_onMousePrimaryDown", $hGUI)
	GUISetOnEvent($GUI_EVENT_PRIMARYUP, "_onMousePrimaryUp", $hGUI)
	GUISetOnEvent($GUI_EVENT_SECONDARYDOWN, "_onMouseSecondaryDown", $hGUI)
	GUISetOnEvent($GUI_EVENT_SECONDARYUP, "_onMouseSecondaryUp", $hGUI)
	GUISetOnEvent($GUI_EVENT_MOUSEMOVE, "_onMouseMove", $hGUI)

	;Windows Messages
	GUIRegisterMsg($WM_DROPFILES, "_WM_DROPFILES")
	GUIRegisterMsg($WM_SIZE, "_WM_SIZE")
	GUIRegisterMsg($WM_MOVE, "_WM_MOVE")
	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

	;set GUI font
;~ 	GUISetFont(10, -1, -1, "Segoe UI")


	;create the background and context menu
	$background = GUICtrlCreateGraphic(0, 0, $oMain.Width, $oMain.Height) ; used to show a grid --- GUICtrlCreatePic($blank_bmp, 0, 0, 0, 0) ; used to show a grid
;~ 	GUICtrlSetState($background, $GUI_DISABLE)
	$background_contextmenu = GUICtrlCreateContextMenu(GUICtrlCreateDummy())
	$background_contextmenu_paste = GUICtrlCreateMenuItem("Paste", $background_contextmenu)
	;menu events
	GUICtrlSetOnEvent($background_contextmenu_paste, "_onPasteSelected")


	;create the overlay and context menu  <-- overlay used to show control selection
	$overlay = GUICtrlCreateLabel('', -1, -1, 1, 1, $SS_BLACKFRAME, $WS_EX_TOPMOST)

	$overlay_contextmenu = GUICtrlCreateContextMenu(GUICtrlCreateDummy())
	Local $overlay_contextmenu_copy = GUICtrlCreateMenuItem("Copy", $overlay_contextmenu)
	Local $overlay_contextmenu_delete = GUICtrlCreateMenuItem("Delete", $overlay_contextmenu)
	;menu events
	GUICtrlSetOnEvent($overlay_contextmenu_copy, _copy_selected)
	GUICtrlSetOnEvent($overlay_contextmenu_delete, _delete_selected_controls)

	;special menu for tab control
	$overlay_contextmenutab = GUICtrlCreateContextMenu(GUICtrlCreateDummy())
	Local $overlay_contextmenutab_delete = GUICtrlCreateMenuItem("Delete", $overlay_contextmenutab)
	Local $overlay_contextmenutab_newtab = GUICtrlCreateMenuItem("New Tab", $overlay_contextmenutab)
	Local $overlay_contextmenutab_deletetab = GUICtrlCreateMenuItem("Delete Tab", $overlay_contextmenutab)

	GUICtrlSetOnEvent($overlay_contextmenutab_delete, _delete_selected_controls)
	GUICtrlSetOnEvent($overlay_contextmenutab_newtab, "_new_tab")
	GUICtrlSetOnEvent($overlay_contextmenutab_deletetab, "_delete_tab")

EndFunc   ;==>_formMain


;------------------------------------------------------------------------------
; Title...........: _formToolbar
; Description.....: Create the toolbar/properties GUI
;------------------------------------------------------------------------------
Func _formToolbar()
	Local $toolbar_left, $toolbar_top
	Local Const $toolbar_width = 215
	Local Const $toolbar_height = 480
	;create the GUI
	Local $sPos = IniRead($sIniPath, "Settings", "posToolbar", "")
	If $sPos <> "" Then
		Local $aPos = StringSplit($sPos, ",")
		$toolbar_left = $aPos[1]
		$toolbar_top = $aPos[2]
	Else
		$toolbar_left = $oMain.Left - ($toolbar_width + 5)
		$toolbar_top = $oMain.Top
	EndIf

	$hToolbar = GUICreate("Choose Control Type", $toolbar_width, $toolbar_height, $toolbar_left, $toolbar_top, $WS_CAPTION, -1, $hGUI)

	#Region create-menu
	;create up the File menu
	Local $menu_file = GUICtrlCreateMenu("File")
	Local $menu_save_definition = GUICtrlCreateMenuItem("Save GUI" & @TAB & "Ctrl+S", $menu_file) ; Roy add-on
	Local $menu_load_definition = GUICtrlCreateMenuItem("Load GUI" & @TAB & "Ctrl+O", $menu_file) ; Roy add-on
	GUICtrlCreateMenuItem("", $menu_file) ; Roy add-on
	Local $menu_export_au3 = GUICtrlCreateMenuItem("Export to au3", $menu_file)
	GUICtrlCreateMenuItem("", $menu_file)
	Local $menu_exit = GUICtrlCreateMenuItem("Exit", $menu_file)

	GUICtrlSetOnEvent($menu_save_definition, _save_gui_definition)
	GUICtrlSetOnEvent($menu_load_definition, _onload_gui_definition)
	GUICtrlSetOnEvent($menu_export_au3, "_onExportMenuItem")
	GUICtrlSetOnEvent($menu_exit, "_onExit")

	;create the Edit menu
	Local $menu_edit = GUICtrlCreateMenu("Edit")
	Local $menu_copy = GUICtrlCreateMenuItem("Copy" & @TAB & "Ctrl+C", $menu_edit)
	Local $menu_paste = GUICtrlCreateMenuItem("Paste" & @TAB & "Ctrl+V", $menu_edit)
	Local $menu_duplicate = GUICtrlCreateMenuItem("Duplicate" & @TAB & "Ctrl+D", $menu_edit)
	Local $menu_selectall = GUICtrlCreateMenuItem("Select All" & @TAB & "Ctrl+A", $menu_edit)
	GUICtrlCreateMenuItem("", $menu_edit)
	$menu_wipe = GUICtrlCreateMenuItem("Clear All Controls", $menu_edit)
	Local $menu_about = GUICtrlCreateMenuItem("About", $menu_edit)         ; added by: TheSaint

	GUICtrlSetState($menu_wipe, $GUI_DISABLE)

	GUICtrlSetOnEvent($menu_copy, "_copy_selected")
	GUICtrlSetOnEvent($menu_paste, "_onMenuPasteSelected")
	GUICtrlSetOnEvent($menu_duplicate, "_onDuplicate")
	GUICtrlSetOnEvent($menu_selectall, "_onMenuSelectAll")
	GUICtrlSetOnEvent($menu_wipe, _wipe_current_gui)
	GUICtrlSetOnEvent($menu_about, _menu_about)

	;create the View menu
	Local $menu_view = GUICtrlCreateMenu("View")
	$menu_generateCode = GUICtrlCreateMenuItem("Live Generated Code", $menu_view)
	GUICtrlSetOnEvent($menu_generateCode, "_onGenerateCode")
	GUICtrlSetState($menu_generateCode, $GUI_UNCHECKED)
	$menu_ObjectExplorer = GUICtrlCreateMenuItem("Object Explorer", $menu_view)
	GUICtrlSetOnEvent($menu_ObjectExplorer, "_onShowObjectExplorer")
	GUICtrlSetState($menu_ObjectExplorer, $GUI_UNCHECKED)

	;create the Tools menu
	Local $menu_tools = GUICtrlCreateMenu("Tools")
	Local $menu_testForm = GUICtrlCreateMenuItem("Test GUI" & @TAB & "F5", $menu_tools)

	GUICtrlSetOnEvent($menu_testForm, "_onTestGUI")

	;create the Settings menu
	Local $menu_settings = GUICtrlCreateMenu("Settings")
	$menu_show_grid = GUICtrlCreateMenuItem("Show grid" & @TAB & "F7", $menu_settings)
	$menu_grid_snap = GUICtrlCreateMenuItem("Snap to grid" & @TAB & "F3", $menu_settings)
	$menu_paste_pos = GUICtrlCreateMenuItem("Paste at mouse position", $menu_settings)
	$menu_show_ctrl = GUICtrlCreateMenuItem("Show control when moving", $menu_settings)
	$menu_show_hidden = GUICtrlCreateMenuItem("Show hidden controls", $menu_settings)
;~ 	$menu_gui_function = GUICtrlCreateMenuItem("Create GUI in a function", $menu_settings)
	$menu_onEvent_mode = GUICtrlCreateMenuItem("Enable OnEvent mode", $menu_settings)
	$menu_dpi_scaling = GUICtrlCreateMenuItem("Apply DPI scaling factor", $menu_settings)

	GUICtrlSetOnEvent($menu_show_grid, _showgrid)
	GUICtrlSetOnEvent($menu_grid_snap, _gridsnap)
	GUICtrlSetOnEvent($menu_paste_pos, _pastepos)
	GUICtrlSetOnEvent($menu_show_ctrl, _show_control)
	GUICtrlSetOnEvent($menu_show_hidden, _menu_show_hidden)
;~ 	GUICtrlSetOnEvent($menu_gui_function, "_menu_gui_function")
	GUICtrlSetOnEvent($menu_onEvent_mode, "_menu_onEvent_mode")
	GUICtrlSetOnEvent($menu_dpi_scaling, "_menu_dpi_scaling")

	GUICtrlSetState($menu_show_grid, $GUI_CHECKED)
	GUICtrlSetState($menu_grid_snap, $GUI_CHECKED)
	GUICtrlSetState($menu_paste_pos, $GUI_CHECKED)
	GUICtrlSetState($menu_show_ctrl, $GUI_CHECKED)
	GUICtrlSetState($menu_show_hidden, $GUI_UNCHECKED)
	GUICtrlSetState($menu_dpi_scaling, $GUI_UNCHECKED)

	#EndRegion create-menu

	#Region control-creation
	Local Const $contype_btn_w = 40
	Local Const $contype_btn_h = 40

	;create 1st row of buttons
	$oMain.DefaultCursor = GUICtrlCreateRadio('', 5, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 1.ico")
	GUICtrlSetTip(-1, "Cursor")
	GUICtrlSetState(-1, $GUI_CHECKED) ; initial selection
	GUICtrlSetOnEvent(-1, _set_default_mode)

	GUICtrlCreateRadio("Tab", 45, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 2.ico")
	GUICtrlSetTip(-1, "Tab")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Group", 85, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 3.ico")
	GUICtrlSetTip(-1, "Group")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Button", 125, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 4.ico")
	GUICtrlSetTip(-1, "Button")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Checkbox", 165, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 5.ico")
	GUICtrlSetTip(-1, "Checkbox")
	GUICtrlSetOnEvent(-1, _control_type)

	; -----------------------------------------------------------------------------------------------------------

	;create 2nd row of buttons
	GUICtrlCreateRadio("Radio", 5, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 6.ico")
	GUICtrlSetTip(-1, "Radio")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Edit", 45, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 7.ico")
	GUICtrlSetTip(-1, "Edit")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Input", 85, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 8.ico")
	GUICtrlSetTip(-1, "Input")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Label", 125, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 9.ico")
	GUICtrlSetTip(-1, "Label")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Updown", 165, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 10.ico")
	GUICtrlSetTip(-1, "Updown")
	GUICtrlSetOnEvent(-1, _control_type)

	; -----------------------------------------------------------------------------------------------------------

	;create 3rd row of buttons
	GUICtrlCreateRadio("List", 5, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 11.ico")
	GUICtrlSetTip(-1, "List")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Combo", 45, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 12.ico")
	GUICtrlSetTip(-1, "Combo")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Date", 85, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 13.ico")
	GUICtrlSetTip(-1, "Date")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("TreeView", 125, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 14.ico")
	GUICtrlSetTip(-1, "TreeView")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Progress", 165, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 15.ico")
	GUICtrlSetTip(-1, "Progress")
	GUICtrlSetOnEvent(-1, _control_type)

	; -----------------------------------------------------------------------------------------------------------

	;create 4th row of buttons
	GUICtrlCreateRadio("Avi", 5, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 16.ico")
	GUICtrlSetTip(-1, "Avi")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Icon", 45, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 17.ico")
	GUICtrlSetTip(-1, "Icon")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Pic", 85, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 18.ico")
	GUICtrlSetTip(-1, "Pic")
	GUICtrlSetOnEvent(-1, _control_type)

	GUICtrlCreateRadio("Menu", 125, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 19.ico")
	GUICtrlSetTip(-1, "Menu")
	GUICtrlSetOnEvent(-1, _control_type)
;~ 	GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateRadio("ContextMenu", 165, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 20.ico")
	GUICtrlSetTip(-1, "Context Menu")
	GUICtrlSetOnEvent(-1, _control_type)
	GUICtrlSetState(-1, $GUI_DISABLE)

	; -----------------------------------------------------------------------------------------------------------

	;create 5th row of buttons
	GUICtrlCreateRadio("Slider", 5, 165, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	GUICtrlSetImage(-1, $iconset & "\Icon 21.ico")
	GUICtrlSetTip(-1, "Slider")
	GUICtrlSetOnEvent(-1, _control_type)
	#EndRegion control-creation


	;create property inspector
	_formPropertyInspector(0, 215, $toolbar_width, 222)


	$hStatusbar = _GUICtrlStatusBar_Create($hToolbar)

EndFunc   ;==>_formToolbar


;------------------------------------------------------------------------------
; Title...........: _set_accelerators
; Description.....: Set the GUI accelerator keys
;------------------------------------------------------------------------------
Func _set_accelerators()
	Local Const $accel_delete = GUICtrlCreateDummy()
	Local Const $accel_c = GUICtrlCreateDummy()
	Local Const $accel_v = GUICtrlCreateDummy()
	Local Const $accel_d = GUICtrlCreateDummy()
	Local Const $accel_a = GUICtrlCreateDummy()
	Local Const $accel_up = GUICtrlCreateDummy()
	Local Const $accel_down = GUICtrlCreateDummy()
	Local Const $accel_left = GUICtrlCreateDummy()
	Local Const $accel_right = GUICtrlCreateDummy()
	Local Const $accel_Ctrlup = GUICtrlCreateDummy()
	Local Const $accel_Ctrldown = GUICtrlCreateDummy()
	Local Const $accel_Ctrlleft = GUICtrlCreateDummy()
	Local Const $accel_Ctrlright = GUICtrlCreateDummy()
	Local Const $accel_s = GUICtrlCreateDummy()
	Local Const $accel_o = GUICtrlCreateDummy()
	Local Const $accel_F5 = GUICtrlCreateDummy()

	Local Const $accelerators[18][2] = _
			[ _
			["{Delete}", $accel_delete], _
			["^c", $accel_c], _
			["^v", $accel_v], _
			["^d", $accel_d], _
			["^a", $accel_a], _
			["{UP}", $accel_up], _
			["{DOWN}", $accel_down], _
			["{LEFT}", $accel_left], _
			["{RIGHT}", $accel_right], _
			["^{UP}", $accel_Ctrlup], _
			["^{DOWN}", $accel_Ctrldown], _
			["^{LEFT}", $accel_Ctrlleft], _
			["^{RIGHT}", $accel_Ctrlright], _
			["{F3}", $menu_grid_snap], _
			["{F7}", $menu_show_grid], _
			["{F5}", $accel_F5], _
			["^s", $accel_s], _
			["^o", $accel_o] _
			]
	GUISetAccelerators($accelerators, $hGUI)

	GUICtrlSetOnEvent($accel_delete, _delete_selected_controls)
	GUICtrlSetOnEvent($accel_c, _copy_selected)
	GUICtrlSetOnEvent($accel_v, "_onPasteSelected")
	GUICtrlSetOnEvent($accel_d, "_onDuplicate")
	GUICtrlSetOnEvent($accel_a, "_onMenuSelectAll")
	GUICtrlSetOnEvent($accel_up, "_onKeyUp")
	GUICtrlSetOnEvent($accel_down, "_onKeyDown")
	GUICtrlSetOnEvent($accel_left, "_onKeyLeft")
	GUICtrlSetOnEvent($accel_right, "_onKeyRight")
	GUICtrlSetOnEvent($accel_Ctrlup, "_onKeyCtrlUp")
	GUICtrlSetOnEvent($accel_Ctrldown, "_onKeyCtrlDown")
	GUICtrlSetOnEvent($accel_Ctrlleft, "_onKeyCtrlLeft")
	GUICtrlSetOnEvent($accel_Ctrlright, "_onKeyCtrlRight")
	GUICtrlSetOnEvent($accel_s, "_save_gui_definition")
	GUICtrlSetOnEvent($accel_o, "_load_gui_definition")
	GUICtrlSetOnEvent($accel_F5, "_onTestGUI")
EndFunc   ;==>_set_accelerators
#EndRegion formMain


;------------------------------------------------------------------------------
; Title...........: _getGuiFrameSize
; Description.....: find frame size + menu
;------------------------------------------------------------------------------
Func _getGuiFrameSize()
	Local $aWinPos = WinGetPos($hGUI)
	Local $iClientX = 0, $iClientY = 0
	ClientToScreen($iClientX, $iClientY)
	$iGuiFrameW = 2 * ($iClientX - $aWinPos[0])
	$iGuiFrameH = ($iClientY - $aWinPos[1]) + ($iClientX - $aWinPos[0])
EndFunc   ;==>_getGuiFrameSize


#Region grid management
; http://www.autoitscript.com/forum/topic/167612-create-a-grid-using-guictrlcreategraphic/
; Author: UEZ
; Modified: jaberwacky
; Modified: kurtykurtyboy
Func _show_grid(ByRef $grid_ctrl, Const $width, Const $height)
	GUISwitch($hGUI)
	;clear the current grid by deleting the graphic and creating a new empty graphic
	GUICtrlDelete($grid_ctrl)
	$grid_ctrl = GUICtrlCreateGraphic(0, 0, $width, $height)

	;draw the lines on the new graphic
	_display_grid($grid_ctrl, $width, $height)
EndFunc   ;==>_show_grid


Func _hide_grid(ByRef $grid_ctrl)
	GUISwitch($hGUI)
	;clear the grid by deleting the graphic and creating a new empty graphic
	GUICtrlDelete($grid_ctrl)
	$grid_ctrl = GUICtrlCreateGraphic(0, 0, $oMain.Width, $oMain.Height)
EndFunc   ;==>_hide_grid


Func _display_grid(Const $grid_ctrl, Const $width, Const $height)
	Local Const $iColor = 0xDEDEDE
	Local $penSize = 1
	Local Const $width_steps = $width / $grid_ticks
	Local Const $height_steps = $height / $grid_ticks

	GUICtrlSetGraphic($grid_ctrl, $GUI_GR_PENSIZE, $penSize)
	GUICtrlSetGraphic($grid_ctrl, $GUI_GR_COLOR, $iColor)

	;draw vertical lines
	For $x = 0 To $width_steps
		GUICtrlSetGraphic($grid_ctrl, $GUI_GR_MOVE, $x * $grid_ticks, 0)
		GUICtrlSetGraphic($grid_ctrl, $GUI_GR_LINE, $x * $grid_ticks, $height)
	Next

	;draw horizontal lines
	For $x = 0 To $height_steps
		GUICtrlSetGraphic($grid_ctrl, $GUI_GR_MOVE, 0, $x * $grid_ticks)
		GUICtrlSetGraphic($grid_ctrl, $GUI_GR_LINE, $width, $x * $grid_ticks)
	Next

	;refresh the graphic display
	GUICtrlSetGraphic($grid_ctrl, $GUI_GR_REFRESH)
EndFunc   ;==>_display_grid
#EndRegion grid management


#Region events
#Region gui-events
;------------------------------------------------------------------------------
; Title...........: _onExit
; Description.....:	clean up and close the program
; Event...........: close button [X]
;------------------------------------------------------------------------------
Func _onExit()
	If $oCtrls.count > 0 Then
		; mod by: TheSaint
		Switch MsgBox($MB_SYSTEMMODAL + $MB_YESNOCANCEL, "Quit?", "Do you want to save the GUI?")
			Case $IDYES
				_save_code()

			Case $IDCANCEL
				Return
		EndSwitch
	EndIf

	; save window positions in ini file
	_saveWinPositions()

	GUIDelete($hToolbar)
	GUIDelete($hGUI)

	If FileExists($testFileName) Then
		FileDelete($testFileName)
	EndIf

	Exit
EndFunc   ;==>_onExit


;------------------------------------------------------------------------------
; Title...........: _onMinimize
; Description.....:	minimize to taskbar
; Event...........: minimize button [-]
;------------------------------------------------------------------------------
Func _onMinimize()
	_saveWinPositions()

	GUISetState(@SW_MINIMIZE, $hGUI)
	GUISetState(@SW_HIDE, $oProperties_Main.Hwnd)
	GUISetState(@SW_HIDE, $oProperties_Ctrls.Hwnd)
EndFunc   ;==>_onMinimize


;------------------------------------------------------------------------------
; Title...........: _onRestore
; Description.....:	Restore the GUI
; Event...........: taskbar button
;------------------------------------------------------------------------------
Func _onRestore()
	GUISetState(@SW_RESTORE, $hGUI)
	If $oSelected.count > 0 Then
		GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Ctrls.Hwnd)
	Else
		GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Main.Hwnd)
	EndIf
	GUISetState(@SW_SHOWNORMAL, $hGUI)
	GUISwitch($hGUI)

	$bResizedFlag = False
EndFunc   ;==>_onRestore


;------------------------------------------------------------------------------
; Title...........: _WM_SIZE
; Description.....: Set the resize flag to ignore primary click event when resizing
;					This prevents controls from getting selected after a resize
; Events..........: Called while dragging window to resize
;------------------------------------------------------------------------------
Func _WM_SIZE($hWnd, $Msg, $wParam, $lParam)
	If $hWnd <> $hGUI Then Return $GUI_RUNDEFMSG

	$bResizedFlag = 1

	Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_SIZE


;------------------------------------------------------------------------------
; Title...........: _WM_MOVE
; Description.....: Set the resize flag to ignore primary click event when moving GUI
;					This prevents controls from getting selected after a move
; Events..........: Called while dragging window to move
;------------------------------------------------------------------------------
Func _WM_MOVE($hWnd, $Msg, $wParam, $lParam)
	If $hWnd <> $hGUI Then Return $GUI_RUNDEFMSG

	$bResizedFlag = 1

	Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_MOVE


;------------------------------------------------------------------------------
; Title...........: _WM_NOTIFY
; Description.....: handle right-click treeview item
;------------------------------------------------------------------------------
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	$tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	$hWndFrom = DllStructGetData($tNMHDR, "hWndFrom")
	$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")

	Switch $iIDFrom
		Case $lvObjects
			Switch $iCode
				Case $NM_RCLICK
					Local $tPoint = _WinAPI_GetMousePos(True, $hWndFrom), $tHitTest
					$tHitTest = _GUICtrlTreeView_HitTestEx($hWndFrom, DllStructGetData($tPoint, 1), DllStructGetData($tPoint, 2))
					If BitAND(DllStructGetData($tHitTest, "Flags"), $TVHT_ONITEM) Then
						_GUICtrlTreeView_SelectItem($hWndFrom, DllStructGetData($tHitTest, 'Item'))
						_onLvObjectsItem()
					EndIf
			EndSwitch
	EndSwitch

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY


;------------------------------------------------------------------------------
; Title...........: _onResize
; Description.....: Resize the background grid
; Events..........: Called after a window resize
;------------------------------------------------------------------------------
Func _onResize()
	Local $win_client_size = WinGetClientSize($hGUI)

	If _setting_show_grid() Then
		_display_grid($background, $win_client_size[0], $win_client_size[1])
	EndIf

	$oMain.Width = $win_client_size[0]
	$oMain.Height = $win_client_size[1]

	$oProperties_Main.Width.value = $oMain.Width
	If $oCtrls.hasMenu Then
		$oProperties_Main.Height.value = $oMain.Height + _WinAPI_GetSystemMetrics($SM_CYMENU)
	Else
		$oProperties_Main.Height.value = $oMain.Height
	EndIf
	WinSetTitle($hGUI, "", $oMain.AppName & " - Form (" & $oProperties_Main.Width.value & ", " & $oProperties_Main.Height.value & ")")

;~ 	$oSelected.getFirst().grippies.show()
EndFunc   ;==>_onResize


;------------------------------------------------------------------------------
; Title...........: _WM_DROPFILES
; Description.....: Load GUI definition file
; Events..........: drag file onto main GUI
;
; Author: Melba23
; http://www.autoitscript.com/forum/topic/155599-open-file-via-dragndrop-on-gui/?p=1124941
;------------------------------------------------------------------------------
Func _WM_DROPFILES(Const $hWnd, Const $msgID, Const $wParam, Const $lParam)
	#forceref $hWnd, $lParam, $msgID

	Local Const $nSize = DllCall("shell32.dll", "int", "DragQueryFileW", "hwnd", $wParam, "int", 0, "ptr", 0, "int", 0)[0] + 1

	Local Const $pFileName = DllStructCreate("wchar[" & $nSize & "]")

	DllCall("shell32.dll", "int", "DragQueryFileW", "hwnd", $wParam, "int", 0, "ptr", DllStructGetPtr($pFileName), "int", $nSize)

	Local Const $GUI_DragFile = DllStructGetData($pFileName, 1)

	_load_gui_definition($GUI_DragFile)

	Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_DROPFILES
#EndRegion gui-events


;------------------------------------------------------------------------------
; Title...........: _onKeyUp
; Description.....: nudge control 1 space
; Events..........: UP key
;------------------------------------------------------------------------------
Func _onKeyUp()
	_nudgeSelected(0, -1)
EndFunc   ;==>_onKeyUp


;------------------------------------------------------------------------------
; Title...........: _onKeyDown
; Description.....: nudge control 1 space
; Events..........: UP key
;------------------------------------------------------------------------------
Func _onKeyDown()
	_nudgeSelected(0, 1)
EndFunc   ;==>_onKeyDown


;------------------------------------------------------------------------------
; Title...........: _onKeyLeft
; Description.....: nudge control 1 space
; Events..........: UP key
;------------------------------------------------------------------------------
Func _onKeyLeft()
	_nudgeSelected(-1, 0)
EndFunc   ;==>_onKeyLeft


;------------------------------------------------------------------------------
; Title...........: _onKeyRight
; Description.....: nudge control 1 space
; Events..........: UP key
;------------------------------------------------------------------------------
Func _onKeyRight()
	_nudgeSelected(1, 0)
EndFunc   ;==>_onKeyRight


;------------------------------------------------------------------------------
; Title...........: _onKeyCtrlUp
; Description.....: nudge control 1 space
; Events..........: UP key
;------------------------------------------------------------------------------
Func _onKeyCtrlUp()
	_nudgeSelected(0, -10)
EndFunc   ;==>_onKeyCtrlUp


;------------------------------------------------------------------------------
; Title...........: _onKeyCtrlDown
; Description.....: nudge control 1 space
; Events..........: UP key
;------------------------------------------------------------------------------
Func _onKeyCtrlDown()
	_nudgeSelected(0, 10)
EndFunc   ;==>_onKeyCtrlDown


;------------------------------------------------------------------------------
; Title...........: _onKeyCtrlLeft
; Description.....: nudge control 1 space
; Events..........: UP key
;------------------------------------------------------------------------------
Func _onKeyCtrlLeft()
	_nudgeSelected(-10, 0)
EndFunc   ;==>_onKeyCtrlLeft


;------------------------------------------------------------------------------
; Title...........: _onKeyCtrlRight
; Description.....: nudge control 1 space
; Events..........: UP key
;------------------------------------------------------------------------------
Func _onKeyCtrlRight()
	_nudgeSelected(10, 0)
EndFunc   ;==>_onKeyCtrlRight


;------------------------------------------------------------------------------
; Title...........: _nudgeSelected
; Description.....: nudge control 1 space
;------------------------------------------------------------------------------
Func _nudgeSelected($x = 0, $y = 0)
;~ 	Local $nudgeAmount = ($setting_snap_grid) ? $grid_ticks : 1
	Local $nudgeAmount = 1
	Local $adjustmentX = 0, $adjustmentX = 0
	Local $count = $oSelected.count
	For $oCtrl In $oSelected.ctrls

		$adjustmentX = Mod($oCtrl.Left, $nudgeAmount)
		If $adjustmentX > 0 Then
			If $x = 1 Then
				$adjustmentX = -1 * $adjustmentX
			ElseIf $x = -1 Then
				$adjustmentX = -1 * ($nudgeAmount - $adjustmentX)
			EndIf
		EndIf
		$adjustmentY = Mod($oCtrl.Top, $nudgeAmount)
		If $adjustmentY > 0 Then
			If $y = 1 Then
				$adjustmentY = -1 * $adjustmentY
			ElseIf $y = -1 Then
				$adjustmentY = -1 * ($nudgeAmount - $adjustmentY)
			EndIf
		EndIf
		_change_ctrl_size_pos($oCtrl, $oCtrl.Left + $x * ($nudgeAmount + $adjustmentX), $oCtrl.Top + $y * ($nudgeAmount + $adjustmentY), $oCtrl.Width, $oCtrl.Height)

	Next

	;get last control
	Local $oCtrlLast = $oSelected.getLast()
	_populate_control_properties_gui($oCtrlLast)

	_refreshGenerateCode()
EndFunc   ;==>_nudgeSelected


;------------------------------------------------------------------------------
; Title...........: _onPasteSelected
; Description.....: Call the paste selected function
; Events..........: Context menu item, accel key Ctrl+V
;------------------------------------------------------------------------------
Func _onPasteSelected()
	_PasteSelected()
EndFunc   ;==>_onPasteSelected


;------------------------------------------------------------------------------
; Title...........: _onMenuPasteSelected
; Description.....: Call the paste selected function
; Events..........: Edit menu item
;------------------------------------------------------------------------------
Func _onMenuPasteSelected()
	_PasteSelected(True)
EndFunc   ;==>_onMenuPasteSelected


;------------------------------------------------------------------------------
; Title...........: _onDuplicate
; Description.....: Duplicate the selected control
; Events..........: menu item, accel key Ctrl+D
;------------------------------------------------------------------------------
Func _onDuplicate()
	_DuplicateSelected()
EndFunc   ;==>_onDuplicate


;------------------------------------------------------------------------------
; Title...........: _onMenuSelectAll
; Description.....: Select all controls
; Events..........: menu item, accel key Ctrl+A
;------------------------------------------------------------------------------
Func _onMenuSelectAll()
	_selectAll()
EndFunc   ;==>_onMenuSelectAll


#Region mouse events
Func _onMousePrimaryDown()
	ConsoleWrite("Ctrls mode: " & $oCtrls.mode & @CRLF)

	;if main window was resized or moved, then don't process mouse down event
	If $bResizedFlag Then
		$bResizedFlag = 0
		Return
	EndIf

	$left_click = True

	Local $aDrawStartPos = GUIGetCursorInfo($hGUI)
	Local Const $ctrl_hwnd = $aDrawStartPos[4]

	Local $pos

	;if tool is selected and clicking on an existing control (but not resizing), switch to selection
	If Not $initResize And Not $oCtrls.mode = $mode_init_move Then
		If $oCtrls.exists($ctrl_hwnd) And $ctrl_hwnd <> $background Then
			GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
			$oCtrls.mode = $mode_default
		EndIf
	EndIf

	;if hold shift, copy the control
	If _IsPressed("10") And $oCtrls.exists($ctrl_hwnd) Then
		_copy_selected()

		Local Const $smallest = _left_top_union_rect()

		$oMouse.X = $smallest.Left

		$oMouse.Y = $smallest.Top

		_PasteSelected()
	EndIf

	Switch $oCtrls.mode
		Case $mode_draw
			ConsoleWrite("** PrimaryDown: draw **" & @CRLF)
			$initDraw = True

			Local $oCtrl = _create_ctrl()

			If IsObj($oCtrl) Then
				_add_to_selected($oCtrl)

				Switch $oCtrl.Type
					Case "Combo", "Checkbox", "Radio"
						$pos = ControlGetPos($hGUI, '', $oCtrl.grippies.East)

						$oCtrls.mode = $resize_e

						_move_mouse_to_grippy($pos[0], $pos[1])

					Case "Menu"
						_set_default_mode()
						$oCtrls.mode = $mode_default
						_formObjectExplorer_updateList()
						_refreshGenerateCode()
						GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)

					Case Else
						$pos = ControlGetPos($hGUI, '', $oCtrl.grippies.SE)

						$oCtrls.mode = $resize_se

						_move_mouse_to_grippy($pos[0], $pos[1])
				EndSwitch

				_set_current_mouse_pos()
			Else
				GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
				_set_default_mode()
				$oCtrls.mode = $mode_default
			EndIf

		Case $mode_default
			ConsoleWrite("** PrimaryDown: default **" & @CRLF)
			Switch $ctrl_hwnd
				Case $background
					ConsoleWrite("  background" & @CRLF)
					_set_default_mode()

					_set_current_mouse_pos()

					$oCtrls.mode = $mode_init_selection

				Case Else
					If Not $oCtrls.exists($ctrl_hwnd) Then Return
					ConsoleWrite("  control exists" & @CRLF)

					Local $oCtrl = $oCtrls.get($ctrl_hwnd)
					ConsoleWrite("  " & $oCtrl.Type & @CRLF)

					;if ctrl is pressed, add/remove form selection
					Switch _IsPressed("11")
						Case False ; single select
							If Not $oSelected.exists($ctrl_hwnd) Then
								_add_to_selected($oCtrl)

								_set_current_mouse_pos()
							EndIf

						Case True ; multiple select
							Switch _group_select($oCtrl)
								Case True
									_set_current_mouse_pos()

									GUICtrlSetCursor($oCtrl.Hwnd, $SIZE_ALL)

								Case False
									If Not $oSelected.exists($ctrl_hwnd) Then
										_add_to_selected($oCtrl, False)
										_set_current_mouse_pos()
									Else
										_remove_from_selected($oCtrl)
									EndIf
							EndSwitch
					EndSwitch

					If $oSelected.count <= 1 Then
						_setLvSelected($oSelected.getFirst())
					EndIf
			EndSwitch
	EndSwitch

EndFunc   ;==>_onMousePrimaryDown


Func _onMousePrimaryUp()
	$left_click = False
	Local $ctrl_hwnd, $oCtrl

	Switch $oCtrls.mode
		Case $mode_init_move
			ConsoleWrite("** PrimaryUp: init_move **" & @CRLF)
			_set_default_mode()

		Case $mode_init_selection
			ConsoleWrite("** PrimaryUp: init_selection **" & @CRLF)
			ToolTip('')

			_recall_overlay()

			$oCtrls.mode = $mode_default

		Case $resize_nw, $resize_n, $resize_ne, $resize_e, $resize_se, $resize_s, $resize_sw, $resize_w
			ConsoleWrite("** PrimaryUp: Resize **" & @CRLF)
			ToolTip('')

			$oCtrlSelectedFirst = $oSelected.getFirst()
			If $initDraw Then    ;if we just started drawing, check to see if drawing or just clicking away from control
				ConsoleWrite("  init draw" & @CRLF)
				$initDraw = False
				;clicking empty space (background), cancel drawing and delete the new control
				Local $tolerance = 5

				Switch $oCtrlSelectedFirst.Type
					Case 'Checkbox', 'Radio', 'Combo', 'Updown'
						$tolerance = 25
					Case Else
						$tolerance = 5
				EndSwitch
				If $oCtrlSelectedFirst.Width < $tolerance And $oCtrlSelectedFirst.Height < $tolerance Then
					ConsoleWrite("  click away" & @CRLF)
					GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
					_delete_selected_controls()
					_set_default_mode()
				EndIf
			EndIf

			If $oCtrlSelectedFirst.Type = 'Pic' Then
				GUICtrlSetImage($oCtrlSelectedFirst.Hwnd, $samplebmp)
			EndIf

			_populate_control_properties_gui($oCtrlSelectedFirst)

			If BitAND(GUICtrlRead($oMain.DefaultCursor), $GUI_CHECKED) = $GUI_CHECKED Then
				$oCtrls.mode = $mode_default
			Else
				$oCtrls.mode = $mode_draw
			EndIf

			_refreshGenerateCode()
			$initResize = False

			;clear graphics glitches (combobox, group)
			_WinAPI_RedrawWindow($hGUI)

			_formObjectExplorer_updateList()

			_setLvSelected($oSelected.getFirst())

		Case Else    ;select single control
			ConsoleWrite("** PrimaryUp: Else **" & @CRLF)
			ToolTip('')

			;we don't care what was dragged, we just want to populate based on latest selection
			;to prevent mouse 'falling off' of control when dropped
			$oCtrl = $oSelected.getLast()
			If IsObj($oCtrl) Then
				_populate_control_properties_gui($oCtrl)
			EndIf

			_refreshGenerateCode()

	EndSwitch
EndFunc   ;==>_onMousePrimaryUp


Func _onMouseSecondaryDown()
	Local Const $ctrl_hwnd = GUIGetCursorInfo($hGUI)[4]

	Switch $ctrl_hwnd
		Case $background
			_set_current_mouse_pos()

		Case Else
			Local $oCtrl = $oCtrls.get($ctrl_hwnd)

			If $oCtrls.exists($ctrl_hwnd) Then
				_add_to_selected($oCtrl)

				_setLvSelected($oSelected.getFirst())
			EndIf
	EndSwitch

	_set_current_mouse_pos()
EndFunc   ;==>_onMouseSecondaryDown


Func _onMouseSecondaryUp()
	Local Const $ctrl_hwnd = GUIGetCursorInfo($hGUI)[4]

	Switch $ctrl_hwnd
		Case $background
			ShowMenu($background_contextmenu, $oMouse.X, $oMouse.Y)

		Case Else
			Local $oCtrl = $oCtrls.get($ctrl_hwnd)

			If $oCtrls.exists($ctrl_hwnd) Then

				If $oCtrl.Type = "Tab" Then
					ShowMenu($overlay_contextmenutab, $oMouse.X, $oMouse.Y)
				Else
					ShowMenu($overlay_contextmenu, $oMouse.X, $oMouse.Y)
				EndIf

			EndIf
	EndSwitch
EndFunc   ;==>_onMouseSecondaryUp


Func _onMouseMove()
	Switch $oCtrls.mode
		Case $mode_init_move, $mode_default
			Local Const $mouse_pos = _mouse_snap_pos()

			Local Const $delta_x = $oMouse.X - $mouse_pos[0]

			Local Const $delta_y = $oMouse.Y - $mouse_pos[1]

			$oMouse.X = $mouse_pos[0]

			$oMouse.Y = $mouse_pos[1]

			If Not $left_click Then Return

			Local $tooltip

			Local $count = $oSelected.count

			For $oCtrl In $oSelected.ctrls

				_change_ctrl_size_pos($oCtrl, $oCtrl.Left - $delta_x, $oCtrl.Top - $delta_y, Default, Default)

				$tooltip &= $oCtrl.Name & ": X:" & $oCtrl.Left & ", Y:" & $oCtrl.Top & ", W:" & $oCtrl.Width & ", H:" & $oCtrl.Height & @CRLF
			Next

			ToolTip(StringTrimRight($tooltip, 2))

			$oCtrls.mode = $mode_default

		Case $mode_init_selection
			Local Const $oRect = _rect_from_points($oMouse.X, $oMouse.Y, MouseGetPos(0), MouseGetPos(1))
			_display_selection_rect($oRect)
			_add_remove_selected_control($oRect)
			_setLvSelected($oSelected.getFirst())

		Case $resize_nw, $resize_n, $resize_ne, $resize_w, $resize_e, $resize_sw, $resize_s, $resize_se
			For $oCtrlSelect In $oSelected.ctrls
				$oCtrlSelect.grippies.resizing($oCtrls.mode)
			Next

	EndSwitch
EndFunc   ;==>_onMouseMove
#EndRegion mouse events


;------------------------------------------------------------------------------
; Title...........: _onGenerateCode
; Description.....: Call the function for the code generation popup GUI
; Events..........: menu item Generate Code
;------------------------------------------------------------------------------
Func _onGenerateCode()
	If Not IsHWnd($hFormGenerateCode) Then
		GUICtrlSetState($menu_generateCode, $GUI_CHECKED)
		_formGenerateCode()
	Else
		_onExitGenerateCode()
;~ 		GUICtrlSetData($editCodeGeneration, _code_generation())
;~ 		WinActivate($hFormGenerateCode)
	EndIf

	; save state to settings file
	Switch BitAND(GUICtrlRead($menu_generateCode), $GUI_CHECKED) = $GUI_CHECKED
		Case True
			IniWrite($sIniPath, "Settings", "ShowCode", 1)

		Case False
			IniWrite($sIniPath, "Settings", "ShowCode", 0)
	EndSwitch
EndFunc   ;==>_onGenerateCode


;------------------------------------------------------------------------------
; Title...........: _onShowObjectExplorer
; Description.....: Create Object Explorer GUI
; Events..........: menu item Object Explorer
;------------------------------------------------------------------------------
Func _onShowObjectExplorer()
	If Not IsHWnd($hFormObjectExplorer) Then
		GUICtrlSetState($menu_ObjectExplorer, $GUI_CHECKED)
		_formObjectExplorer()
	Else
		_onExitObjectExplorer()
	EndIf

	; save state to settings file
	Switch BitAND(GUICtrlRead($menu_ObjectExplorer), $GUI_CHECKED) = $GUI_CHECKED
		Case True
			IniWrite($sIniPath, "Settings", "ShowObjectExplorer", 1)

		Case False
			IniWrite($sIniPath, "Settings", "ShowObjectExplorer", 0)
	EndSwitch
EndFunc   ;==>_onShowObjectExplorer


;------------------------------------------------------------------------------
; Title...........: _onTestGUI
; Description.....: Run the generated code to test the GUI
; Events..........:	Tools menu item
;------------------------------------------------------------------------------
Func _onTestGUI()
	ConsoleWrite("test" & @CRLF)
	If ProcessExists($TestFilePID) Then
		WinClose(_WinGetByPID($TestFilePID))
		$bReTest = 1
		Return
	EndIf

	Local $code = _code_generation()

	;create temporary file
	$testFileName = _TempFile()
	Local $fTestFile = FileOpen($testFileName, $FO_OVERWRITE)
	If $fTestFile = -1 Then
		MsgBox(1, "Error", "Error creating the test script")
		Return
	EndIf

	Local $ret = FileWrite($fTestFile, $code)
	If $fTestFile = 0 Then
		MsgBox(1, "Error", "Error writing the test script")
		Return
	EndIf
	FileClose($fTestFile)

	;run the temporary file
	If Not FileExists($au3InstallPath) Then
		Local $sFileOpenDialog = FileOpenDialog("Select AutoIt3.exe", @ProgramFilesDir, "(*.exe)", $FD_FILEMUSTEXIST, "AutoIt3.exe")
		If @error Then
			MsgBox(1, "Error", "Could not find AutoIt3.exe")
			Return
		Else
			$au3InstallPath = $sFileOpenDialog
		EndIf
	EndIf
;~ 	Local $filename = StringRegExpReplace($testFileName, "^.*\\", "")
	$TestFilePID = Run($au3InstallPath & ' /AutoIt3ExecuteScript ' & $testFileName, @ScriptDir)

	;monitor process from main loop

EndFunc   ;==>_onTestGUI

;Smoke_N's WinGetByPID
Func _WinGetByPID($iPID, $nArray = 1) ;0 will return 1 base array; leaving it 1 will return the first visible window it finds
	If IsString($iPID) Then $iPID = ProcessExists($iPID)
	Local $aWList = WinList(), $sHold
	For $iCC = 1 To $aWList[0][0]
		If WinGetProcess($aWList[$iCC][1]) = $iPID And _
				BitAND(WinGetState($aWList[$iCC][1]), 2) Then
			If $nArray Then Return $aWList[$iCC][0]
			$sHold &= $aWList[$iCC][0] & Chr(1)
		EndIf
	Next
	If $sHold Then Return StringSplit(StringTrimRight($sHold, 1), Chr(1))
	Return SetError(1, 0, 0)
EndFunc   ;==>_WinGetByPID


;------------------------------------------------------------------------------
; Title........: _onExitChild
; Description..: Close any child window
; Events.......: child window GUI_EVENT_CLOSE, OK/Cancel button
;------------------------------------------------------------------------------
Func _onExitChild()
	$a_ret = DllCall("user32.dll", "int", "DestroyWindow", "hwnd", @GUI_WinHandle)
EndFunc   ;==>_onExitChild


#Region ; control properties window
Func _populate_control_properties_gui(Const $oCtrl, $childHwnd = -1)
	If Not $oCtrls.exists($oCtrl.Hwnd) Then
		Return
	EndIf

	;TEXT
	Local $text = $oCtrl.Text
	If $oCtrl.Type = "Tab" Then
		If $childHwnd <> -1 Then ;this is a child tab
			Local $iTabFocus = _GUICtrlTab_GetCurSel($oCtrl.Hwnd)

			If $iTabFocus >= 0 Then
				$text = $oCtrl.Tabs.at($iTabFocus).Text
			EndIf
		EndIf
	EndIf
	$oProperties_Ctrls.Text.value = $text

	;NAME
	Local $name = $oCtrl.Name
	If $oCtrl.Type = "Tab" Then
		If $childHwnd <> -1 Then ;this is a child tab
			Local $iTabFocus = _GUICtrlTab_GetCurSel($oCtrl.Hwnd)

			If $iTabFocus >= 0 Then
				$name = $oCtrl.Tabs.at($iTabFocus).Name
			EndIf
		EndIf
	EndIf
	$oProperties_Ctrls.Name.value = $name

	$oProperties_Ctrls.Left.value = $oCtrl.Left
	$oProperties_Ctrls.Top.value = $oCtrl.Top
	$oProperties_Ctrls.Width.value = $oCtrl.Width
	$oProperties_Ctrls.Height.value = $oCtrl.Height

	If $oCtrl.Background <> -1 Then
		$oProperties_Ctrls.Background.value = "0x" & Hex($oCtrl.Background, 6)
	Else
		$oProperties_Ctrls.Background.value = ""
	EndIf
	If $oCtrl.Color <> -1 Then
		$oProperties_Ctrls.Color.value = "0x" & Hex($oCtrl.Color, 6)
	Else
		$oProperties_Ctrls.Color.value = ""
	EndIf
EndFunc   ;==>_populate_control_properties_gui


#Region change-properties-main
Func _main_change_title()
	Local Const $new_text = $oProperties_Main.Title.value
	$oMain.Title = $new_text

	_refreshGenerateCode()
EndFunc   ;==>_main_change_title


Func _main_change_name()
	Local $new_name = $oProperties_Main.Name.value
	$new_name = StringReplace($new_name, " ", "_")
	$oProperties_Main.Name.value = $new_name
	$oMain.Name = $new_name

	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_main_change_name


Func _main_change_left()
	Local Const $new_text = $oProperties_Main.Left.value
	$oMain.Left = $new_text

	_refreshGenerateCode()
EndFunc   ;==>_main_change_left


Func _main_change_top()
	Local Const $new_text = $oProperties_Main.Top.value
	$oMain.Top = $new_text

	_refreshGenerateCode()
EndFunc   ;==>_main_change_top


Func _main_change_width()
	Local Const $newValue = $oProperties_Main.Width.value

	WinMove($hGUI, "", Default, Default, $newValue + $iGuiFrameW, Default)

	Local $aWinPos = WinGetClientSize($hGUI)
	WinSetTitle($hGUI, "", $oMain.AppName & " - Form (" & $aWinPos[0] & ", " & $aWinPos[1] & ")")

	$oMain.Width = $aWinPos[0]

	If _setting_show_grid() Then
		_display_grid($background, $aWinPos[0], $aWinPos[1])
	EndIf

	_refreshGenerateCode()
EndFunc   ;==>_main_change_width


Func _main_change_height()
	Local Const $newValue = $oProperties_Main.Height.value

	WinMove($hGUI, "", Default, Default, Default, $newValue + $iGuiFrameH)

	Local $aWinPos = WinGetClientSize($hGUI)
	WinSetTitle($hGUI, "", $oMain.AppName & " - Form (" & $aWinPos[0] & ", " & $aWinPos[1] & ")")

	$oMain.Height = $aWinPos[1]

	If _setting_show_grid() Then
		_display_grid($background, $aWinPos[0], $aWinPos[1])
	EndIf

	_refreshGenerateCode()
EndFunc   ;==>_main_change_height


Func _main_pick_bkColor()
	Local $color = _ChooseColor(2)

	If $color = -1 Then Return 0
	$oProperties_Main.Background.value = $color

	_main_change_background()
EndFunc   ;==>_main_pick_bkColor


Func _main_change_background()
	Local $colorInput = $oProperties_Main.Background.value
	If $colorInput = "" Or $colorInput = -1 Then
		$colorInput = $defaultGuiBkColor
	Else
		$colorInput = Dec(StringReplace($colorInput, "0x", ""))
	EndIf
	$oMain.Background = $oProperties_Main.Background.value

	GUISetBkColor($colorInput, $hGUI)

	_refreshGenerateCode()
EndFunc   ;==>_main_change_background
#EndRegion change-properties-main


#Region change-properties-ctrls
Func _onPropertyChange($sPropertyName, $value)
	ConsoleWrite($sPropertyName & " " & $value & @CRLF)
EndFunc   ;==>_onPropertyChange

Func _ctrl_change_text()
	Local Const $new_text = $oProperties_Ctrls.Text.value

	Local Const $sel_count = $oSelected.count

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls

				If $oCtrl.Type = "Combo" Then
					GUICtrlSetData($oCtrl.Hwnd, $new_text, $new_text)
					$oCtrl.Text = $new_text
				ElseIf $oCtrl.Type = "Tab" Then
					If $childSelected Then
						Local $iTabFocus = _GUICtrlTab_GetCurSel($oCtrl.Hwnd)

						If $iTabFocus >= 0 Then
							_GUICtrlTab_SetItemText($oCtrl.Hwnd, $iTabFocus, $new_text)
							$oCtrl.Tabs.at($iTabFocus).Text = $new_text
						EndIf
					Else
						$oCtrl.Text = $new_text
					EndIf
				ElseIf $oCtrl.Type = "Menu" Then
					If $childSelected Then
						Local $hSelected = _getLvSelectedHwnd()
						Local $oCtrl = $oCtrls.get($hSelected)
						If Not IsObj($oCtrl) Then Return -1
						GUICtrlSetData($oCtrl.Hwnd, $new_text)
						$oCtrl.Text = $new_text
					Else
						GUICtrlSetData($oCtrl.Hwnd, $new_text)
						$oCtrl.Text = $new_text
					EndIf
				Else
					GUICtrlSetData($oCtrl.Hwnd, $new_text)
					$oCtrl.Text = $new_text
				EndIf
			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_text


Func _ctrl_change_name()
	ConsoleWrite("change name" & @CRLF)
	Local $new_name = $oProperties_Ctrls.Name.value
	$new_name = StringReplace($new_name, " ", "_")
	$oProperties_Ctrls.Name.value = $new_name

	Local Const $sel_count = $oSelected.count

	If $sel_count = 1 Then
		Local $oCtrl = $oSelected.getFirst()

		If $oCtrl.Type = "Tab" Then
			If $childSelected Then
				Local $iTabFocus = _GUICtrlTab_GetCurSel($oCtrl.Hwnd)

				If $iTabFocus >= 0 Then
					$oCtrl.Tabs.at($iTabFocus).Name = $new_name
				Else
					$oCtrl.Name = $new_name
				EndIf
			Else
				$oCtrl.Name = $new_name
			EndIf
		ElseIf $oCtrl.Type = "Menu" Then
			If $childSelected Then
				Local $hSelected = _getLvSelectedHwnd()
				Local $oCtrl = $oCtrls.get($hSelected)
				If Not IsObj($oCtrl) Then Return -1
				$oCtrl.Name = $new_name
			Else
				$oCtrl.Name = $new_name
			EndIf
		Else
			$oCtrl.Name = $new_name
		EndIf
	EndIf

	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_ctrl_change_name


Func _ctrl_change_left()
	Local $new_data = $oProperties_Ctrls.Left.value
	If $new_data = "" Then
		$new_data = 0
		$oProperties_Ctrls.Left.value = $new_data
	EndIf

	Local Const $sel_count = $oSelected.count

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls

				;move the selected control
				GUICtrlSetPos($oCtrl.Hwnd, $new_data, $oCtrl.Top, $oCtrl.Width, $oCtrl.Height)
				;update the selected property
				$oCtrl.Left = $new_data

				$oCtrl.grippies.show()

			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_left


Func _ctrl_change_top()
	Local $new_data = $oProperties_Ctrls.Top.value
	If $new_data = "" Then
		$new_data = 0
		$oProperties_Ctrls.Top.value = $new_data
	EndIf

	Local Const $sel_count = $oSelected.count

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls

				;move the selected control
				GUICtrlSetPos($oCtrl.Hwnd, $oCtrl.Left, $new_data, $oCtrl.Width, $oCtrl.Height)
				;update the selected property
				$oCtrl.Top = $new_data

				$oCtrl.grippies.show()
			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_top


Func _ctrl_change_width()
	Local $new_data = $oProperties_Ctrls.Width.value
	If $new_data = "" Then
		$new_data = 0
		$oProperties_Ctrls.Width.value = $new_data
	EndIf

	Local Const $sel_count = $oSelected.count

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls

				;move the selected control
				GUICtrlSetPos($oCtrl.Hwnd, $oCtrl.Left, $oCtrl.Top, $new_data, $oCtrl.Height)
				;update the selected property
				$oCtrl.Width = $new_data

				$oCtrl.grippies.show()
			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_width


Func _ctrl_change_height()
	Local $new_data = $oProperties_Ctrls.Height.value
	If $new_data = "" Then
		$new_data = 0
		$oProperties_Ctrls.Height.value = $new_data
	EndIf

	Local Const $sel_count = $oSelected.count

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls

				;move the selected control
				GUICtrlSetPos($oCtrl.Hwnd, $oCtrl.Left, $oCtrl.Top, $oCtrl.Width, $new_data)
				;update the selected property
				$oCtrl.Height = $new_data

				$oCtrl.grippies.show()
			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_height


Func _ctrl_pick_bkColor()
	Local $color = _ChooseColor(2)

	If $color = -1 Then Return 0
	$oProperties_Ctrls.Background.value = $color

	_ctrl_change_bkColor()
EndFunc   ;==>_ctrl_pick_bkColor


Func _ctrl_change_bkColor()
	Local $colorInput = $oProperties_Ctrls.Background.value
	If $colorInput = "" Then
		$colorInput = -1
	Else
		$colorInput = Dec(StringReplace($colorInput, "0x", ""))
	EndIf

	Local Const $sel_count = $oSelected.count

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls

				;convert string to color then apply
				If $oCtrl.Type <> "Label" Then Return 0

				If $colorInput <> -1 Then
					GUICtrlSetBkColor($oCtrl.Hwnd, $colorInput)
				Else
					GUICtrlDelete($oCtrl.Hwnd)
					$oCtrl.Hwnd = GUICtrlCreateLabel($oCtrl.Text, $oCtrl.Left, $oCtrl.Top, $oCtrl.Width, $oCtrl.Height)
					$oCtrl.Background = -1
					If $oCtrl.Color <> -1 Then
						GUICtrlSetColor($oCtrl.Hwnd, $oCtrl.Color)
					EndIf
				EndIf

				$oCtrl.Background = $colorInput
			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_bkColor


Func _ctrl_pick_Color()
	Local $color = _ChooseColor(2)

	If $color = -1 Then Return 0
	$oProperties_Ctrls.Color.value = $color

	_ctrl_change_Color()
EndFunc   ;==>_ctrl_pick_Color


Func _ctrl_change_Color()
	Local $colorInput = $oProperties_Ctrls.Color.value
	If $colorInput = "" Then
		$colorInput = -1
	Else
		$colorInput = Dec(StringReplace($colorInput, "0x", ""))
	EndIf

	Local Const $sel_count = $oSelected.count

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls
				;convert string to color then apply
				If $oCtrl.Type <> "Label" Then Return 0

				If $colorInput <> -1 Then
					GUICtrlSetColor($oCtrl.Hwnd, $colorInput)
				Else
					GUICtrlDelete($oCtrl.Hwnd)
					$oCtrl.Hwnd = GUICtrlCreateLabel($oCtrl.Text, $oCtrl.Left, $oCtrl.Top, $oCtrl.Width, $oCtrl.Height)
					$oCtrl.Color = -1
					If $oCtrl.Background <> -1 Then
						GUICtrlSetBkColor($oCtrl.Hwnd, $oCtrl.Background)
					EndIf
				EndIf

				$oCtrl.Color = $colorInput
			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_Color


#Region ; states
Func _ctrl_change_visible()

EndFunc   ;==>_ctrl_change_visible


Func _ctrl_change_enabled()

EndFunc   ;==>_ctrl_change_enabled


Func _ctrl_change_focus()

EndFunc   ;==>_ctrl_change_focus


Func _ctrl_change_ontop()

EndFunc   ;==>_ctrl_change_ontop

Func _ctrl_change_dropaccepted()

EndFunc   ;==>_ctrl_change_dropaccepted
#EndRegion ; states


#Region ; styles
Func _ctrl_change_style_autocheckbox()

EndFunc   ;==>_ctrl_change_style_autocheckbox


Func _ctrl_change_style_top()

EndFunc   ;==>_ctrl_change_style_top
#EndRegion ; styles
#EndRegion change-properties-ctrls
#EndRegion ; control properties window
#EndRegion events


#Region functions

;------------------------------------------------------------------------------
; Title...........: _wipe_current_gui
; Description.....:	clear all controls from the form designer
;------------------------------------------------------------------------------
Func _wipe_current_gui()
	Switch @GUI_CtrlId
		Case $menu_wipe
			Switch MsgBox($MB_SYSTEMMODAL + $MB_YESNO + $MB_ICONWARNING, "Alert", "Are You Sure?  This action can not be undone.")
				Case $IDNO
					Return
			EndSwitch
	EndSwitch

	GUICtrlSetState($menu_wipe, $GUI_DISABLE)

	Local Const $count = $oCtrls.count

	For $oCtrl In $oCtrls.ctrls

		Switch $oCtrl.Type
			Case "Updown"
				GUICtrlDelete($oCtrl.Hwnd1)

				GUICtrlDelete($oCtrl.Hwnd2)

			Case Else
				GUICtrlDelete($oCtrl.Hwnd)
		EndSwitch
	Next

	$oCtrls.removeAll()

	_set_default_mode()

	_WinAPI_RedrawWindow($hGUI)

	$oCtrls.ButtonCount = 0
	$oCtrls.GroupCount = 0
	$oCtrls.CheckboxCount = 0
	$oCtrls.RadioCount = 0
	$oCtrls.EditCount = 0
	$oCtrls.InputCount = 0
	$oCtrls.LabelCount = 0
	$oCtrls.ListCount = 0
	$oCtrls.ComboCount = 0
	$oCtrls.DateCount = 0
	$oCtrls.SliderCount = 0
	$oCtrls.TabCount = 0
	$oCtrls.TreeViewCount = 0
	$oCtrls.UpdownCount = 0
	$oCtrls.ProgressCount = 0
	$oCtrls.PicCount = 0
	$oCtrls.AviCount = 0
	$oCtrls.IconCount = 0

	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_wipe_current_gui


;------------------------------------------------------------------------------
; Title...........: ClientToScreen
; Description.....: Convert the client (GUI) coordinates to screen (desktop) coordinates.
;					taken from the helpfile
;					updated by kurtykurtyboy
;------------------------------------------------------------------------------
Func ClientToScreen(ByRef $x, ByRef $y)
	Local $tPoint = DllStructCreate("int X;int Y")
	DllStructSetData($tPoint, "X", $x)
	DllStructSetData($tPoint, "Y", $y)
	_WinAPI_ClientToScreen($hGUI, $tPoint)
	$x = DllStructGetData($tPoint, "X")
	$y = DllStructGetData($tPoint, "Y")
EndFunc   ;==>ClientToScreen


#Region ; mouse management
Func _mouse_snap_pos()
	Return _snap_to_grid(MouseGetPos())
EndFunc   ;==>_mouse_snap_pos

Func _snap_to_grid($coords)
	If $setting_snap_grid Then
		$coords[0] = $grid_ticks * Int($coords[0] / $grid_ticks - 0.5) + $grid_ticks

		$coords[1] = $grid_ticks * Int($coords[1] / $grid_ticks - 0.5) + $grid_ticks
	EndIf

	Return $coords
EndFunc   ;==>_snap_to_grid

Func _set_current_mouse_pos()
	Local Const $mouse_snap_pos = _mouse_snap_pos()

	$oMouse.X = $mouse_snap_pos[0]
	$oMouse.Y = $mouse_snap_pos[1]
EndFunc   ;==>_set_current_mouse_pos

Func _cursor_out_of_bounds(Const $cursor_pos)
	If __WinAPI_PtInRectEx($cursor_pos[0], $cursor_pos[1], 0, 0, $oMain.Width, $oMain.Height) Then
		Return False
	EndIf

	Return True
EndFunc   ;==>_cursor_out_of_bounds
#EndRegion ; mouse management


;------------------------------------------------------------------------------
; Title...........: _set_default_mode
; Description.....:	Resets the form selection and properties panel
;					- hide grippies
;					- recall (hide) the overlay
;					- Clear selected list
;					- Clear and disable properties panel
;------------------------------------------------------------------------------
Func _set_default_mode()
	_recall_overlay()

	_remove_all_from_selected()

	_showProperties($props_Main)

	;clear listview selections
	_setLvSelected(0)

	$oCtrls.mode = $mode_default
EndFunc   ;==>_set_default_mode


#Region ; rectangle management
Func __WinAPI_CreateRect(Const $left, Const $top, Const $right, Const $bottom)
	; Author.........: Yashied
	; Modified.......: Jaberwacky

	Local Static $tRECT = DllStructCreate($tagRECT)

	With $tRECT
		.Left = $left
		.Top = $top
		.Right = $right
		.Bottom = $bottom
	EndWith

	Return $tRECT
EndFunc   ;==>__WinAPI_CreateRect

Func __WinAPI_CreatePoint(Const $x, Const $y)
	; Author.........: Yashied
	; Modified.......: Jaberwacky

	Local Static $tPoint = DllStructCreate($tagPOINT)

	With $tPoint
		.X = $x
		.Y = $y
	EndWith

	Return $tPoint
EndFunc   ;==>__WinAPI_CreatePoint

Func __WinAPI_PtInRectEx(Const $x, Const $y, Const $left, Const $top, Const $width, Const $height)
	; Author.........: Yashied
	; Modified.......: JPM, Jaberwacky
	; Modified.......: kurtykurtyboy

	Local Const $right = $left + $width

	Local Const $bottom = $top + $height

	Local $tRECT = __WinAPI_CreateRect($left, $top, $right, $bottom)

	Local $tPoint = __WinAPI_CreatePoint($x, $y)

	Local Const $aRet = _WinAPI_PtInRect($tRECT, $tPoint)

	Return @error ? SetError(@error, @extended, False) : $aRet
EndFunc   ;==>__WinAPI_PtInRectEx

Func _rect_from_points(Const $a1, Const $a2, Const $b1, Const $b2)
	Local $oRect = _objCreateRect()

	$oRect.Left = ($a1 < $b1) ? $a1 : $b1

	$oRect.Top = ($a2 < $b2) ? $a2 : $b2

	$oRect.Width = ($b1 > $a1) ? ($b1 - $oRect.Left) : ($a1 - $oRect.Left)

	$oRect.Height = ($b2 > $a2) ? ($b2 - $oRect.Top) : ($a2 - $oRect.Top)

	Return $oRect
EndFunc   ;==>_rect_from_points
#EndRegion ; rectangle management


Func _setting_show_grid(Const $toggle = False, Const $value = '')
	Local Static $setting_show_grid = False

	Switch $toggle
		Case True
			$setting_show_grid = $value
	EndSwitch

	Return $setting_show_grid
EndFunc   ;==>_setting_show_grid



#EndRegion functions


#Region ; menu bar items
;------------------------------------------------------------------------------
; Title...........: _onExportMenuItem
; Description.....: Display the save dialog to save code to au3 file
; Events..........: file menu item
;------------------------------------------------------------------------------
Func _onExportMenuItem()
	_save_code()
EndFunc   ;==>_onExportMenuItem


;------------------------------------------------------------------------------
; Title...........: ShowMenu
; Description.....: Show context menu (right click) for control or GUI
;------------------------------------------------------------------------------
Func ShowMenu(Const $context, $x, $y)
	Local Const $hMenu = GUICtrlGetHandle($context)

	ClientToScreen($x, $y)

	_GUICtrlMenu_TrackPopupMenu($hMenu, $hGUI, $x, $y)
EndFunc   ;==>ShowMenu


;------------------------------------------------------------------------------
; Title...........: _showgrid
; Description.....: Show (or hide) the background grid and update INI file
; Events..........: settings menu item select
;------------------------------------------------------------------------------
Func _showgrid()
	Local Const $show_grid_data = GUICtrlRead($menu_show_grid)

	Select
		Case BitAND($show_grid_data, $GUI_CHECKED) = $GUI_CHECKED
			GUICtrlSetState($menu_show_grid, $GUI_UNCHECKED)

			_hide_grid($background)

			IniWrite($sIniPath, "Settings", "ShowGrid", 0)

		Case BitAND($show_grid_data, $GUI_UNCHECKED) = $GUI_UNCHECKED
			GUICtrlSetState($menu_show_grid, $GUI_CHECKED)

			_show_grid($background, $oMain.Width, $oMain.Height)

			IniWrite($sIniPath, "Settings", "ShowGrid", 1)
	EndSelect
EndFunc   ;==>_showgrid


;------------------------------------------------------------------------------
; Title...........: _pastepos
; Description.....: Update INI setting for paste at mouse position
; Events..........: settings menu item select
;------------------------------------------------------------------------------
Func _pastepos()
	If BitAND(GUICtrlRead($menu_paste_pos), $GUI_CHECKED) = $GUI_CHECKED Then
		GUICtrlSetState($menu_paste_pos, $GUI_UNCHECKED)

		IniWrite($sIniPath, "Settings", "PastePos", 0)
	Else
		GUICtrlSetState($menu_paste_pos, $GUI_CHECKED)

		IniWrite($sIniPath, "Settings", "PastePos", 1)
	EndIf

	$setting_paste_pos = Not $setting_paste_pos
EndFunc   ;==>_pastepos


;------------------------------------------------------------------------------
; Title...........: _gridsnap
; Description.....: Update INI setting for grid snap
; Events..........: settings menu item select
;------------------------------------------------------------------------------
Func _gridsnap()
	If BitAND(GUICtrlRead($menu_grid_snap), $GUI_CHECKED) = $GUI_CHECKED Then
		GUICtrlSetState($menu_grid_snap, $GUI_UNCHECKED)

		IniWrite($sIniPath, "Settings", "GridSnap", 0)
	Else
		GUICtrlSetState($menu_grid_snap, $GUI_CHECKED)

		IniWrite($sIniPath, "Settings", "GridSnap", 1)
	EndIf

	$setting_snap_grid = Not $setting_snap_grid
EndFunc   ;==>_gridsnap


;------------------------------------------------------------------------------
; Title...........: _show_control
; Description.....: Update INI setting for show control
; Events..........: settings menu item select
;------------------------------------------------------------------------------
Func _show_control()
	Switch BitAND(GUICtrlRead($menu_show_ctrl), $GUI_CHECKED) = $GUI_CHECKED
		Case True
			GUICtrlSetState($menu_show_ctrl, $GUI_UNCHECKED)

			IniWrite($sIniPath, "Settings", "ShowControl", 0)

			$setting_show_control = False

		Case False
			GUICtrlSetState($menu_show_ctrl, $GUI_CHECKED)

			IniWrite($sIniPath, "Settings", "ShowControl", 1)

			$setting_show_control = True
	EndSwitch
EndFunc   ;==>_show_control


;------------------------------------------------------------------------------
; Title...........: _menu_show_hidden
; Description.....: Update INI setting for show hidden
;					show/hide controls based on setting
; Events..........: settings menu item select
;------------------------------------------------------------------------------
Func _menu_show_hidden()
	Switch BitAND(GUICtrlRead($menu_show_hidden), $GUI_CHECKED) = $GUI_CHECKED
		Case True
			GUICtrlSetState($menu_show_hidden, $GUI_UNCHECKED)

			IniWrite($sIniPath, "Settings", "ShowHidden", 0)

			$setting_show_hidden = False

			For $oCtrl In $oCtrls.ctrls

				If Not $oCtrl.Visible Then
					GUICtrlSetState($oCtrl.Hwnd, $GUI_HIDE)
				EndIf
			Next

			_recall_overlay()

		Case False
			GUICtrlSetState($menu_show_hidden, $GUI_CHECKED)

			IniWrite($sIniPath, "Settings", "ShowHidden", 1)

			$setting_show_hidden = True

			For $oCtrl In $oCtrls.ctrls

				If Not $oCtrl.Visible Then
					GUICtrlSetState($oCtrl.Hwnd, $GUI_SHOW)
				EndIf
			Next

	EndSwitch
EndFunc   ;==>_menu_show_hidden


;------------------------------------------------------------------------------
; Title...........: _menu_dpi_scaling
; Description.....: Update INI setting for dpi scaling
; Events..........: settings menu item select
;------------------------------------------------------------------------------
Func _menu_dpi_scaling()
	Switch BitAND(GUICtrlRead($menu_dpi_scaling), $GUI_CHECKED) = $GUI_CHECKED
		Case True
			GUICtrlSetState($menu_dpi_scaling, $GUI_UNCHECKED)

			IniWrite($sIniPath, "Settings", "DpiScaling", 0)

			$setting_dpi_scaling = False


		Case False
			GUICtrlSetState($menu_dpi_scaling, $GUI_CHECKED)

			IniWrite($sIniPath, "Settings", "DpiScaling", 1)

			$setting_dpi_scaling = True

	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_menu_dpi_scaling


;------------------------------------------------------------------------------
; Title...........: _menu_onEvent_mode
; Description.....: Update INI setting
; Events..........: settings menu item
;------------------------------------------------------------------------------
Func _menu_onEvent_mode()
	Switch BitAND(GUICtrlRead($menu_onEvent_mode), $GUI_CHECKED) = $GUI_CHECKED
		Case True
			GUICtrlSetState($menu_onEvent_mode, $GUI_UNCHECKED)

			IniWrite($sIniPath, "Settings", "OnEventMode", 0)

			$setting_onEvent_mode = False


		Case False
			GUICtrlSetState($menu_onEvent_mode, $GUI_CHECKED)

			IniWrite($sIniPath, "Settings", "OnEventMode", 1)

			$setting_onEvent_mode = True

	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_menu_onEvent_mode


;------------------------------------------------------------------------------
; Title...........: _menu_gui_function
; Description.....: Update INI setting
; Events..........: settings menu item
;------------------------------------------------------------------------------
Func _menu_gui_function()
	Switch BitAND(GUICtrlRead($menu_gui_function), $GUI_CHECKED) = $GUI_CHECKED
		Case True
			GUICtrlSetState($menu_gui_function, $GUI_UNCHECKED)

			IniWrite($sIniPath, "Settings", "GuiInFunction", 0)

			$setting_gui_function = False


		Case False
			GUICtrlSetState($menu_gui_function, $GUI_CHECKED)

			IniWrite($sIniPath, "Settings", "GuiInFunction", 1)

			$setting_gui_function = True

	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_menu_gui_function



;------------------------------------------------------------------------------
; Title...........: _menu_about
; Description.....: Display popup with program description
;------------------------------------------------------------------------------
Func _menu_about()
	MsgBox(0, "About " & $oMain.AppName, $oMain.AppVersion & @CRLF & _
			"Originally created by CyberSlug (as AutoBuilder)," & @CRLF & _
			"and modified by Roy, TheSaint, and others (as GuiBuilder)," & @CRLF & _
			"and Jaberwacky (as GuiBuilderNxt)," & @CRLF & _
			"with additional modifications by kurtykurtyboy (as GuiBuilderPlus)." & @CRLF & @CRLF & _
			"Program Information" & @CRLF & _
			"When you exit " & $oMain.AppName & ", you will be prompted" & @CRLF & _
			"to save what you may have created as an au3 file.")
EndFunc   ;==>_menu_about

Func _menu_vals()
	Local Const $ctrl_count = $oCtrls.count

	Local $values = "Total Of Controls = " & $ctrl_count & @CRLF & @CRLF

	For $oCtrl In $oCtrls.ctrls

		$values &= "Handle = " & Hex($oCtrl.Hwnd) & @CRLF & _
				"Type   = " & $oCtrl.Type & @CRLF & _
				"Name   = " & $oCtrl.Name & @CRLF & @CRLF
	Next

	MsgBox($MB_ICONINFORMATION, "Current Code Values", $values)
EndFunc   ;==>_menu_vals


#EndRegion ; menu bar items


; #FUNCTION# ====================================================================================================================
; Name ..........: GUIGetBkColor
; Description ...: Retrieves the RGB value of the GUI background.
; Syntax ........: GUIGetBkColor($hWnd)
; Parameters ....: $hWnd                - A handle of the GUI.
; Return values .: Success - RGB value
;                  Failure - 0
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func GUIGetBkColor($hWnd)
	Local $iColor = 0
	If IsHWnd($hWnd) Then
		Local $hDC = _WinAPI_GetDC($hWnd)
		$iColor = _WinAPI_GetBkColor($hDC)
		_WinAPI_ReleaseDC($hWnd, $hDC)
	EndIf
	Return $iColor
EndFunc   ;==>GUIGetBkColor


;------------------------------------------------------------------------------
; Title...........: _saveWinPositions
; Description.....: Save current window positions to ini file
;------------------------------------------------------------------------------
Func _saveWinPositions()
	If Not BitAND(WinGetState($hGUI), $WIN_STATE_MINIMIZED) Then
		Local $currentWinPos = WinGetPos($hGUI)
		IniWrite($sIniPath, "Settings", "posMain", $currentWinPos[0] & "," & $currentWinPos[1])

		$currentWinPos = WinGetPos($hToolbar)
		IniWrite($sIniPath, "Settings", "posToolbar", $currentWinPos[0] & "," & $currentWinPos[1])

		If IsHWnd($hFormGenerateCode) Then
			$currentWinPos = WinGetPos($hFormGenerateCode)
			IniWrite($sIniPath, "Settings", "posGenerateCode", $currentWinPos[0] & "," & $currentWinPos[1])
		EndIf

		If IsHWnd($hFormObjectExplorer) Then
			$currentWinPos = WinGetPos($hFormObjectExplorer)
			IniWrite($sIniPath, "Settings", "posObjectExplorer", $currentWinPos[0] & "," & $currentWinPos[1])
		EndIf
	EndIf
EndFunc   ;==>_saveWinPositions
