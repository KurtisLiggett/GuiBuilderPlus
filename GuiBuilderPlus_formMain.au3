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
	Local $main_left = (@DesktopWidth / 2) - ($oMain.Width / 2)
	Local $main_top = (@DesktopHeight / 2) - ($oMain.Height / 2)

	;create the GUI
	Local $sPos = IniRead($sIniPath, "Settings", "posMain", $main_left & "," & $main_top)
	Local $aPos = StringSplit($sPos, ",")
	If Not @error Then
		$main_left = $aPos[1]
		$main_top = $aPos[2]
	EndIf

	Local $ixCoordMin = _WinAPI_GetSystemMetrics(76)
	Local $iyCoordMin = _WinAPI_GetSystemMetrics(77)
	Local $iFullDesktopWidth = _WinAPI_GetSystemMetrics(78)
	Local $iFullDesktopHeight = _WinAPI_GetSystemMetrics(79)
	If ($main_left + $oMain.Width) > ($ixCoordMin + $iFullDesktopWidth) Then
		$main_left = $iFullDesktopWidth - $oMain.Width
	ElseIf $main_left < $ixCoordMin Then
		$main_left = 0
	EndIf
	If ($main_top + $oMain.Height) > ($iyCoordMin + $iFullDesktopHeight) Then
		$main_top = $iFullDesktopHeight - $oMain.Height
	ElseIf $main_top < $iyCoordMin Then
		$main_top = 0
	EndIf

	$oMain.Left = $main_left
	$oMain.Top = $main_top

	;create an invisible parent for forms, to prevent showing in the taskbar
	$hFormHolder = GUICreate("GBP form holder", 10, 10, -1, -1, -1, -1, $hToolbar)
	$hGUI = GUICreate($oMain.Title & " - Form (" & $oMain.Width & ", " & $oMain.Height & ')', $oMain.Width, $oMain.Height, $main_left, $main_top, BitOR($WS_SIZEBOX, $WS_CAPTION), BitOR($WS_EX_ACCEPTFILES, $WS_EX_COMPOSITED), $hFormHolder)

	_getGuiFrameSize()
	WinMove($hGUI, "", Default, Default, $oMain.Width + $iGuiFrameW, $oMain.Height + $iGuiFrameH)

	WinSetTitle($hGUI, "", $oMain.Title & " - Form (" & $oMain.Width & ", " & $oMain.Height & ")")



	;GUI events
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitForm", $hGUI)
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
	GUICtrlSetOnEvent($background_contextmenu_paste, "_onContextMenuPasteSelected")

	$overlay_contextmenu = GUICtrlCreateContextMenu(GUICtrlCreateDummy())
	Local $overlay_contextmenu_cut = GUICtrlCreateMenuItem("Cut", $overlay_contextmenu)
	Local $overlay_contextmenu_copy = GUICtrlCreateMenuItem("Copy", $overlay_contextmenu)
	Local $overlay_contextmenu_delete = GUICtrlCreateMenuItem("Delete", $overlay_contextmenu)
	GUICtrlCreateMenuItem("", $overlay_contextmenu)
	$contextmenu_lock = GUICtrlCreateMenuItem("Lock Control", $overlay_contextmenu)
	GUICtrlCreateMenuItem("", $overlay_contextmenu)
	Local $contextmenu_arrange = GUICtrlCreateMenu("Arrange", $overlay_contextmenu)
;~ 	Local $contextmenu_arrange_back = GUICtrlCreateMenuItem("Send to Back", $contextmenu_arrange)
;~ 	Local $contextmenu_arrange_front = GUICtrlCreateMenuItem("Bring to Front", $contextmenu_arrange)
;~ 	GUICtrlCreateMenuItem("", $contextmenu_arrange)
	Local $contextmenu_arrange_left = GUICtrlCreateMenuItem("Align Left", $contextmenu_arrange)
	Local $contextmenu_arrange_center = GUICtrlCreateMenuItem("Align Center", $contextmenu_arrange)
	Local $contextmenu_arrange_right = GUICtrlCreateMenuItem("Align Right", $contextmenu_arrange)
	GUICtrlCreateMenuItem("", $contextmenu_arrange)
	Local $contextmenu_arrange_top = GUICtrlCreateMenuItem("Align Top", $contextmenu_arrange)
	Local $contextmenu_arrange_middle = GUICtrlCreateMenuItem("Align Middle", $contextmenu_arrange)
	Local $contextmenu_arrange_bottom = GUICtrlCreateMenuItem("Align Bottom", $contextmenu_arrange)
	GUICtrlCreateMenuItem("", $contextmenu_arrange)
	Local $contextmenu_arrange_centerPoints = GUICtrlCreateMenuItem("Align Center Points", $contextmenu_arrange)
	GUICtrlCreateMenuItem("", $contextmenu_arrange)
	Local $contextmenu_arrange_spaceVertical = GUICtrlCreateMenuItem("Space Vertical", $contextmenu_arrange)
	Local $contextmenu_arrange_spaceHorizontal = GUICtrlCreateMenuItem("Space Horizontal", $contextmenu_arrange)
	GUICtrlCreateMenuItem("", $overlay_contextmenu)
	Local $contextmenu_event = GUICtrlCreateMenuItem("Set control event", $overlay_contextmenu)

	;menu events
	GUICtrlSetOnEvent($overlay_contextmenu_cut, _cut_selected)
	GUICtrlSetOnEvent($overlay_contextmenu_copy, _copy_selected)
	GUICtrlSetOnEvent($overlay_contextmenu_delete, _delete_selected_controls)
	GUICtrlSetOnEvent($contextmenu_lock, "_onLockControl")
;~ 	GUICtrlSetOnEvent($contextmenu_arrange_back, "_onAlignMenu_Back")
;~ 	GUICtrlSetOnEvent($contextmenu_arrange_front, "_onAlignMenu_Front")
	GUICtrlSetOnEvent($contextmenu_arrange_left, "_onAlignMenu_Left")
	GUICtrlSetOnEvent($contextmenu_arrange_center, "_onAlignMenu_Center")
	GUICtrlSetOnEvent($contextmenu_arrange_right, "_onAlignMenu_Right")
	GUICtrlSetOnEvent($contextmenu_arrange_top, "_onAlignMenu_Top")
	GUICtrlSetOnEvent($contextmenu_arrange_middle, "_onAlignMenu_Middle")
	GUICtrlSetOnEvent($contextmenu_arrange_bottom, "_onAlignMenu_Bottom")
	GUICtrlSetOnEvent($contextmenu_arrange_centerPoints, "_onAlignMenu_CenterPoints")
	GUICtrlSetOnEvent($contextmenu_arrange_spaceVertical, "_onAlignMenu_SpaceVertical")
	GUICtrlSetOnEvent($contextmenu_arrange_spaceHorizontal, "_onAlignMenu_SpaceHorizontal")
	GUICtrlSetOnEvent($contextmenu_event, "_onContextMenu_Event")

	;special menu for tab control
	$overlay_contextmenutab = GUICtrlCreateContextMenu(GUICtrlCreateDummy())
	Local $overlay_contextmenutab_delete = GUICtrlCreateMenuItem("Delete", $overlay_contextmenutab)
	Local $overlay_contextmenutab_newtab = GUICtrlCreateMenuItem("New Tab", $overlay_contextmenutab)
	Local $overlay_contextmenutab_deletetab = GUICtrlCreateMenuItem("Delete Tab", $overlay_contextmenutab)

	GUICtrlSetOnEvent($overlay_contextmenutab_delete, _delete_selected_controls)
	GUICtrlSetOnEvent($overlay_contextmenutab_newtab, "_onNewTab")
	GUICtrlSetOnEvent($overlay_contextmenutab_deletetab, "_onDeleteTab")

EndFunc   ;==>_formMain


;------------------------------------------------------------------------------
; Title...........: _formToolbar
; Description.....: Create the toolbar/properties GUI
;------------------------------------------------------------------------------
Func _formToolbar()
	Local Const $toolbar_width = 215
	Local Const $toolbar_height = 480

	Local $toolbar_left = $oMain.Left - ($toolbar_width + 5)
	Local $toolbar_top = $oMain.Top

	Local $sPos = IniRead($sIniPath, "Settings", "posToolbar", $toolbar_left & "," & $toolbar_top)
	Local $aPos = StringSplit($sPos, ",")
	If Not @error Then
		$toolbar_left = $aPos[1]
		$toolbar_top = $aPos[2]
	EndIf

	Local $ixCoordMin = _WinAPI_GetSystemMetrics(76)
	Local $iyCoordMin = _WinAPI_GetSystemMetrics(77)
	Local $iFullDesktopWidth = _WinAPI_GetSystemMetrics(78)
	Local $iFullDesktopHeight = _WinAPI_GetSystemMetrics(79)
	If ($toolbar_left + $toolbar_width) > ($ixCoordMin + $iFullDesktopWidth) Then
		$toolbar_left = $iFullDesktopWidth - $toolbar_width
	ElseIf $toolbar_left < $ixCoordMin Then
		$toolbar_left = 0
	EndIf
	If ($toolbar_top + $toolbar_height) > ($iyCoordMin + $iFullDesktopHeight) Then
		$toolbar_top = $iFullDesktopHeight - $toolbar_height
	ElseIf $toolbar_top < $iyCoordMin Then
		$toolbar_top = 0
	EndIf

	$hToolbar = GUICreate($oMain.AppName, $toolbar_width, $toolbar_height, $toolbar_left, $toolbar_top, BitOR($WS_SYSMENU, $WS_MINIMIZEBOX))

	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExit", $hToolbar)
	GUISetOnEvent($GUI_EVENT_MINIMIZE, "_onMinimize", $hToolbar)
	GUISetOnEvent($GUI_EVENT_RESTORE, "_onRestore", $hToolbar)

	#Region create-menu
	;create up the File menu
	$menu_file = GUICtrlCreateMenu("File")
	Local $menu_save_definition = GUICtrlCreateMenuItem("Save" & @TAB & "Ctrl+S", $menu_file)
	Local $menu_saveas_definition = GUICtrlCreateMenuItem("Save As..." & @TAB & "Ctrl+S", $menu_file)
	Local $menu_load_definition = GUICtrlCreateMenuItem("Open" & @TAB & "Ctrl+O", $menu_file)
	GUICtrlCreateMenuItem("", $menu_file)
	Local $menu_import_au3 = GUICtrlCreateMenuItem("Import from au3", $menu_file)
	Local $menu_export_au3 = GUICtrlCreateMenuItem("Export to au3", $menu_file)

	;look for recent files and generate menus
	Local $aRecentFiles = IniReadSection($sIniPath, "Recent")
	If Not @error Then
		GUICtrlCreateMenuItem("", $menu_file)
		For $i = 1 To $aRecentFiles[0][0]
			$aMenuRecentList[$i - 1] = GUICtrlCreateMenuItem($i & " " & $aRecentFiles[$i][1], $menu_file)
			GUICtrlSetOnEvent(-1, "_onMenuRecent")
		Next
	EndIf

	$aMenuRecentList[10] = GUICtrlCreateMenuItem("", $menu_file)
	$aMenuRecentList[11] = GUICtrlCreateMenuItem("Exit", $menu_file)
	GUICtrlSetOnEvent(-1, "_onExit")


	GUICtrlSetOnEvent($menu_save_definition, "_onSaveGui")
	GUICtrlSetOnEvent($menu_saveas_definition, "_onSaveAsGui")
	GUICtrlSetOnEvent($menu_load_definition, "_onload_gui_definition")
	GUICtrlSetOnEvent($menu_import_au3, "_onImportMenuItem")
	GUICtrlSetOnEvent($menu_export_au3, "_onExportMenuItem")

	;create the Edit menu
	Local $menu_edit = GUICtrlCreateMenu("Edit")
	Local $menu_undo = GUICtrlCreateMenuItem("Undo" & @TAB & "Ctrl+Z", $menu_edit)
	Local $menu_redo = GUICtrlCreateMenuItem("Redo" & @TAB & "Ctrl+Y", $menu_edit)
	GUICtrlCreateMenuItem("", $menu_edit)
	Local $menu_cut = GUICtrlCreateMenuItem("Cut" & @TAB & "Ctrl+X", $menu_edit)
	Local $menu_copy = GUICtrlCreateMenuItem("Copy" & @TAB & "Ctrl+C", $menu_edit)
	Local $menu_paste = GUICtrlCreateMenuItem("Paste" & @TAB & "Ctrl+V", $menu_edit)
	Local $menu_duplicate = GUICtrlCreateMenuItem("Duplicate" & @TAB & "Ctrl+D", $menu_edit)
	Local $menu_selectall = GUICtrlCreateMenuItem("Select All" & @TAB & "Ctrl+A", $menu_edit)
	GUICtrlCreateMenuItem("", $menu_edit)
	$menu_wipe = GUICtrlCreateMenuItem("Clear All Controls", $menu_edit)

	GUICtrlSetState($menu_wipe, $GUI_DISABLE)

	GUICtrlSetOnEvent($menu_undo, "_onUndo")
	GUICtrlSetOnEvent($menu_redo, "_onRedo")
	GUICtrlSetOnEvent($menu_copy, "_copy_selected")
	GUICtrlSetOnEvent($menu_paste, "_onMenuPasteSelected")
	GUICtrlSetOnEvent($menu_duplicate, "_onDuplicate")
	GUICtrlSetOnEvent($menu_selectall, "_onMenuSelectAll")
	GUICtrlSetOnEvent($menu_wipe, _wipe_current_gui)

	GUICtrlCreateMenuItem("", $menu_edit)
	Local $menu_arrange = GUICtrlCreateMenu("Arrange", $menu_edit)
	Local $menu_arrange_left = GUICtrlCreateMenuItem("Align Left", $menu_arrange)
	Local $menu_arrange_center = GUICtrlCreateMenuItem("Align Center", $menu_arrange)
	Local $menu_arrange_right = GUICtrlCreateMenuItem("Align Right", $menu_arrange)
	GUICtrlCreateMenuItem("", $menu_arrange)
	Local $menu_arrange_top = GUICtrlCreateMenuItem("Align Top", $menu_arrange)
	Local $menu_arrange_middle = GUICtrlCreateMenuItem("Align Middle", $menu_arrange)
	Local $menu_arrange_bottom = GUICtrlCreateMenuItem("Align Bottom", $menu_arrange)
	GUICtrlCreateMenuItem("", $menu_arrange)
	Local $menu_arrange_centerPoints = GUICtrlCreateMenuItem("Align Center Points", $menu_arrange)
	GUICtrlCreateMenuItem("", $menu_arrange)
	Local $menu_arrange_spaceVertical = GUICtrlCreateMenuItem("Space Vertical", $menu_arrange)
	Local $menu_arrange_spaceHorizontal = GUICtrlCreateMenuItem("Space Horizontal", $menu_arrange)

	GUICtrlSetOnEvent($menu_arrange_left, "_onAlignMenu_Left")
	GUICtrlSetOnEvent($menu_arrange_center, "_onAlignMenu_Center")
	GUICtrlSetOnEvent($menu_arrange_right, "_onAlignMenu_Right")
	GUICtrlSetOnEvent($menu_arrange_top, "_onAlignMenu_Top")
	GUICtrlSetOnEvent($menu_arrange_middle, "_onAlignMenu_Middle")
	GUICtrlSetOnEvent($menu_arrange_bottom, "_onAlignMenu_Bottom")
	GUICtrlSetOnEvent($menu_arrange_centerPoints, "_onAlignMenu_CenterPoints")
	GUICtrlSetOnEvent($menu_arrange_spaceVertical, "_onAlignMenu_SpaceVertical")
	GUICtrlSetOnEvent($menu_arrange_spaceHorizontal, "_onAlignMenu_SpaceHorizontal")

	;create the View menu
	Local $menu_view = GUICtrlCreateMenu("View")
	$menu_show_grid = GUICtrlCreateMenuItem("Show grid" & @TAB & "F7", $menu_view)
	GUICtrlSetOnEvent($menu_show_grid, _onShowGrid)
	GUICtrlSetState($menu_show_grid, $GUI_CHECKED)
	$menu_generateCode = GUICtrlCreateMenuItem("Live Generated Code", $menu_view)
	GUICtrlSetOnEvent($menu_generateCode, "_onGenerateCode")
	GUICtrlSetState($menu_generateCode, $GUI_UNCHECKED)
	$menu_ObjectExplorer = GUICtrlCreateMenuItem("Object Explorer", $menu_view)
	GUICtrlSetOnEvent($menu_ObjectExplorer, "_onShowObjectExplorer")
	GUICtrlSetState($menu_ObjectExplorer, $GUI_UNCHECKED)
;~ 	GUICtrlCreateMenuItem("", $menu_view)
;~ 	Local $menu_resetLayout = GUICtrlCreateMenuItem("Reset window layout", $menu_view)


	;create the Tools menu
	Local $menu_tools = GUICtrlCreateMenu("Tools")
	Local $menu_testForm = GUICtrlCreateMenuItem("Test GUI" & @TAB & "F5", $menu_tools)
	Local $menu_settings = GUICtrlCreateMenuItem("Settings", $menu_tools)

	GUICtrlSetOnEvent($menu_testForm, "_onTestGUI")
	GUICtrlSetOnEvent($menu_settings, "_onSettings")

	;create the Help menu
	Local $menu_help = GUICtrlCreateMenu("Help")
	$menu_helpchm = GUICtrlCreateMenuItem("Help" & @TAB & "F1", $menu_help)
	Local $menu_github = GUICtrlCreateMenuItem("Github Repository", $menu_help)
	Local $menu_about = GUICtrlCreateMenuItem("About", $menu_help)         ; added by: TheSaint

	GUICtrlSetOnEvent($menu_about, _menu_about)
	GUICtrlSetOnEvent($menu_github, _onGithubItem)
	GUICtrlSetOnEvent($menu_helpchm, _onHelpItem)

	#EndRegion create-menu

	#Region control-creation
	Local Const $contype_btn_w = 40
	Local Const $contype_btn_h = 40

	;create 1st row of buttons
	Local $toolButton
	$toolButton = GUICtrlCreateRadio('', 5, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 1.ico", 201)
	GUICtrlSetTip(-1, "Cursor")
	GUICtrlSetState(-1, $GUI_CHECKED) ; initial selection
	GUICtrlSetOnEvent(-1, _set_default_mode)
	$oMain.DefaultCursor = $toolButton

	$toolButton = GUICtrlCreateRadio("Tab", 45, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 2.ico", 202)
	GUICtrlSetTip(-1, "Tab")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Group", 85, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 3.ico", 203)
	GUICtrlSetTip(-1, "Group")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Button", 125, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 4.ico", 204)
	GUICtrlSetTip(-1, "Button")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Checkbox", 165, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 5.ico", 205)
	GUICtrlSetTip(-1, "Checkbox")
	GUICtrlSetOnEvent(-1, _control_type)

	; -----------------------------------------------------------------------------------------------------------

	;create 2nd row of buttons
	$toolButton = GUICtrlCreateRadio("Radio", 5, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 6.ico", 206)
	GUICtrlSetTip(-1, "Radio")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Edit", 45, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 7.ico", 207)
	GUICtrlSetTip(-1, "Edit")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Input", 85, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 8.ico", 208)
	GUICtrlSetTip(-1, "Input")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Label", 125, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 9.ico", 209)
	GUICtrlSetTip(-1, "Label")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Updown", 165, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 10.ico", 210)
	GUICtrlSetTip(-1, "Updown")
	GUICtrlSetOnEvent(-1, _control_type)

	; -----------------------------------------------------------------------------------------------------------

	;create 3rd row of buttons
	$toolButton = GUICtrlCreateRadio("List", 5, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 11.ico", 211)
	GUICtrlSetTip(-1, "List")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Combo", 45, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 12.ico", 212)
	GUICtrlSetTip(-1, "Combo")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Date", 85, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 13.ico", 213)
	GUICtrlSetTip(-1, "Date")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("TreeView", 125, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 14.ico", 214)
	GUICtrlSetTip(-1, "TreeView")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Progress", 165, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 15.ico", 215)
	GUICtrlSetTip(-1, "Progress")
	GUICtrlSetOnEvent(-1, _control_type)

	; -----------------------------------------------------------------------------------------------------------

	;create 4th row of buttons
	$toolButton = GUICtrlCreateRadio("Avi", 5, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 16.ico", 216)
	GUICtrlSetTip(-1, "Avi")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Icon", 45, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 17.ico", 217)
	GUICtrlSetTip(-1, "Icon")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Pic", 85, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 18.ico", 218)
	GUICtrlSetTip(-1, "Pic")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Menu", 125, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 19.ico", 219)
	GUICtrlSetTip(-1, "Menu")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("Graphic", 165, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 24.ico", 224)
	GUICtrlSetTip(-1, "Graphic")
	GUICtrlSetOnEvent(-1, _control_type)

	; -----------------------------------------------------------------------------------------------------------

	;create 5th row of buttons
	$toolButton = GUICtrlCreateRadio("Slider", 5, 165, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 21.ico", 221)
	GUICtrlSetTip(-1, "Slider")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("IP", 45, 165, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 22.ico", 222)
	GUICtrlSetTip(-1, "IP Address")
	GUICtrlSetOnEvent(-1, _control_type)

	$toolButton = GUICtrlCreateRadio("ListView", 85, 165, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
	_setIconFromResource($toolButton, "Icon 23.ico", 223)
	GUICtrlSetTip(-1, "ListView")
	GUICtrlSetOnEvent(-1, _control_type)
	#EndRegion control-creation


	;create property inspector
	_formPropertyInspector(0, 210, $toolbar_width, 222)


	$hStatusbar = _GUICtrlStatusBar_Create($hToolbar)

EndFunc   ;==>_formToolbar


;------------------------------------------------------------------------------
; Title...........: _set_accelerators
; Description.....: Set the GUI accelerator keys
;------------------------------------------------------------------------------
Func _set_accelerators()
	Local Const $accel_delete = GUICtrlCreateDummy()
	Local Const $accel_x = GUICtrlCreateDummy()
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
	Local Const $accel_F3 = GUICtrlCreateDummy()
	Local Const $accel_F5 = GUICtrlCreateDummy()
	Local Const $accel_z = GUICtrlCreateDummy()
	Local Const $accel_y = GUICtrlCreateDummy()
	Local Const $accel_F1 = GUICtrlCreateDummy()

	Local Const $accelerators[22][2] = _
			[ _
			["{Delete}", $accel_delete], _
			["^x", $accel_x], _
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
			["{F3}", $accel_F3], _
			["{F7}", $menu_show_grid], _
			["{F5}", $accel_F5], _
			["^s", $accel_s], _
			["^o", $accel_o], _
			["^z", $accel_z], _
			["^y", $accel_y], _
			["{F1}", $menu_helpchm] _
			]
	GUISetAccelerators($accelerators, $hGUI)

	Local Const $acceleratorsToolbar[6][2] = _
			[ _
			["{F3}", $accel_F3], _
			["{F7}", $menu_show_grid], _
			["{F5}", $accel_F5], _
			["^s", $accel_s], _
			["^o", $accel_o], _
			["{F1}", $menu_helpchm] _
			]
	GUISetAccelerators($accelerators, $hToolbar)
	GUISetAccelerators($accelerators, $oProperties_Main.properties.Hwnd)

	GUICtrlSetOnEvent($accel_delete, _delete_selected_controls)
	GUICtrlSetOnEvent($accel_x, _cut_selected)
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
	GUICtrlSetOnEvent($accel_s, "_onSaveGui")
	GUICtrlSetOnEvent($accel_o, "_onload_gui_definition")
	GUICtrlSetOnEvent($accel_F5, "_onTestGUI")
	GUICtrlSetOnEvent($accel_F3, "_onGridsnap")
	GUICtrlSetOnEvent($accel_z, "_onUndo")
	GUICtrlSetOnEvent($accel_y, "_onRedo")
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
	Local Const $width_steps = $width / $oOptions.gridSize
	Local Const $height_steps = $height / $oOptions.gridSize

	GUICtrlSetGraphic($grid_ctrl, $GUI_GR_PENSIZE, $penSize)
	GUICtrlSetGraphic($grid_ctrl, $GUI_GR_COLOR, $iColor)

	;draw vertical lines
	For $x = 0 To $width_steps
		GUICtrlSetGraphic($grid_ctrl, $GUI_GR_MOVE, $x * $oOptions.gridSize, 0)
		GUICtrlSetGraphic($grid_ctrl, $GUI_GR_LINE, $x * $oOptions.gridSize, $height)
	Next

	;draw horizontal lines
	For $x = 0 To $height_steps
		GUICtrlSetGraphic($grid_ctrl, $GUI_GR_MOVE, 0, $x * $oOptions.gridSize)
		GUICtrlSetGraphic($grid_ctrl, $GUI_GR_LINE, $width, $x * $oOptions.gridSize)
	Next

	;refresh the graphic display
	GUICtrlSetGraphic($grid_ctrl, $GUI_GR_REFRESH)

	;resize the control for click detection
	GUICtrlSetPos($grid_ctrl, Default, Default, $width, $height)
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
	If $oMain.hasChanged Then
		; mod by: TheSaint
		Switch MsgBox($MB_SYSTEMMODAL + $MB_YESNOCANCEL, "Quit?", "Do you want to save the GUI?")
			Case $IDYES
;~ 				_save_code()
				$ret = _save_gui_definition()
				Switch $ret
					Case -1
						$bStatusNewMessage = True
						_GUICtrlStatusBar_SetText($hStatusbar, "Save cancelled.")
						Return

					Case -2
						$bStatusNewMessage = True
						_GUICtrlStatusBar_SetText($hStatusbar, "Save failed.")
						Return

				EndSwitch

			Case $IDCANCEL
				Return
		EndSwitch
	EndIf

	; save window positions in ini file
	_saveWinPositions()

	If $hSelectionGraphic <> -1 Then
		_GDIPlus_GraphicsDispose($hSelectionGraphic)
	EndIf
	GUIDelete($hToolbar)
	GUIDelete($hGUI)

	If FileExists($testFileName) Then
		FileDelete($testFileName)
	EndIf

	Exit
EndFunc   ;==>_onExit

Func _onExitForm()
	;for now, close the program. In the future, close this form.
	_onExit()
EndFunc   ;==>_onExitForm


;------------------------------------------------------------------------------
; Title...........: _onMinimize
; Description.....:	minimize to taskbar
; Event...........: minimize button [-]
;------------------------------------------------------------------------------
Func _onMinimize()
	_saveWinPositions()

	GUISetState(@SW_MINIMIZE, $hToolbar)
	GUISetState(@SW_HIDE, $oProperties_Main.properties.Hwnd)
	GUISetState(@SW_HIDE, $oProperties_Ctrls.properties.Hwnd)
	GUISetState(@SW_HIDE, $tabStylesHwnd)
;~ 	GUISetState(@SW_HIDE, $hGUI)
EndFunc   ;==>_onMinimize


;------------------------------------------------------------------------------
; Title...........: _onRestore
; Description.....:	Restore the GUI
; Event...........: taskbar button
;------------------------------------------------------------------------------
Func _onRestore()
	GUISetState(@SW_RESTORE, $hToolbar)
	If $oSelected.count > 0 Then
		Switch $tabSelected
			Case "Properties"
				GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Ctrls.properties.Hwnd)

			Case "Styles"
				GUISetState(@SW_SHOWNOACTIVATE, $tabStylesHwnd)
		EndSwitch
	Else
		Switch $tabSelected
			Case "Properties"
				GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Main.properties.Hwnd)

			Case "Styles"
				GUISetState(@SW_SHOWNOACTIVATE, $tabStylesHwnd)
		EndSwitch
	EndIf
	GUISetState(@SW_SHOWNORMAL, $hToolbar)
;~ 	GUISetState(@SW_SHOWNORMAL, $hGUI)
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

	If $oOptions.showGrid Then
		_display_grid($background, $win_client_size[0], $win_client_size[1])
	EndIf

	$oMain.Width = $win_client_size[0]
	$oMain.Height = $win_client_size[1]

	$oProperties_Main.properties.Width.value = $oMain.Width
	If $oCtrls.hasMenu Then
		$oProperties_Main.properties.Height.value = $oMain.Height + _WinAPI_GetSystemMetrics($SM_CYMENU)
	Else
		$oProperties_Main.properties.Height.value = $oMain.Height
	EndIf
	WinSetTitle($hGUI, "", $oMain.Title & " - Form (" & $oProperties_Main.properties.Width.value & ", " & $oProperties_Main.properties.Height.value & ")")

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
	_nudgeSelected(0, -1 * $oOptions.GridSize)
EndFunc   ;==>_onKeyCtrlUp


;------------------------------------------------------------------------------
; Title...........: _onKeyCtrlDown
; Description.....: nudge control 1 space
; Events..........: UP key
;------------------------------------------------------------------------------
Func _onKeyCtrlDown()
	_nudgeSelected(0, $oOptions.GridSize)
EndFunc   ;==>_onKeyCtrlDown


;------------------------------------------------------------------------------
; Title...........: _onKeyCtrlLeft
; Description.....: nudge control 1 space
; Events..........: UP key
;------------------------------------------------------------------------------
Func _onKeyCtrlLeft()
	_nudgeSelected(-1 * $oOptions.GridSize, 0)
EndFunc   ;==>_onKeyCtrlLeft


;------------------------------------------------------------------------------
; Title...........: _onKeyCtrlRight
; Description.....: nudge control 1 space
; Events..........: UP key
;------------------------------------------------------------------------------
Func _onKeyCtrlRight()
	_nudgeSelected($oOptions.GridSize, 0)
EndFunc   ;==>_onKeyCtrlRight


;------------------------------------------------------------------------------
; Title...........: _nudgeSelected
; Description.....: nudge control 1 space
;------------------------------------------------------------------------------
Func _nudgeSelected($x = 0, $y = 0, $aUndoCtrls = 0)
	GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
	$oCtrls.mode = $mode_default

;~ 	Local $nudgeAmount = ($oOptions.snapGrid) ? $oOptions.gridSize : 1
	Local $nudgeAmount = 1
	Local $adjustmentX = 0, $adjustmentX = 0

	Local $aCtrls
	If IsArray($aUndoCtrls) Then
		$aCtrls = $aUndoCtrls
	Else
		$aCtrls = $oSelected.ctrls.Items()
	EndIf

	For $oCtrl In $aCtrls
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

		Switch $oCtrl.Type
			Case "Tab"
				_moveTabCtrls($oCtrl, -1 * $x * ($nudgeAmount + $adjustmentX), -1 * $y * ($nudgeAmount + $adjustmentY), Default, Default)

			Case "Group"
				_moveGroupCtrls($oCtrl, -1 * $x * ($nudgeAmount + $adjustmentX), -1 * $y * ($nudgeAmount + $adjustmentY), Default, Default)

		EndSwitch
	Next

	;get last control
	Local $oCtrlLast = $oSelected.getLast()
	_populate_control_properties_gui($oCtrlLast)

	;store the undo action
	If Not IsArray($aUndoCtrls) Then
		Local $oAction = _objAction()
		$oAction.action = $action_nudgeCtrl
		$oAction.ctrls = $aCtrls
		Local $aParams[2] = [$x, $y]
		$oAction.parameters = $aParams
		_updateActionStacks($oAction)
	EndIf

	_refreshGenerateCode()
EndFunc   ;==>_nudgeSelected


;------------------------------------------------------------------------------
; Title...........: _onLockControl
; Description.....: Lock selected controls
; Events..........: Context menu item
;------------------------------------------------------------------------------
Func _onLockControl()
	If $oSelected.count = 0 Then Return 0

	_SendMessage($hGUI, $WM_SETREDRAW, False)
	For $oCtrl In $oSelected.ctrls.Items()
		$oCtrl.Locked = True
		$oCtrl.grippies.show()
	Next
	_SendMessage($hGUI, $WM_SETREDRAW, True)
	_WinAPI_RedrawWindow($hGUI)
EndFunc   ;==>_onLockControl

;------------------------------------------------------------------------------
; Title...........: _onUnlockControl
; Description.....: Unlock selected controls
; Events..........: Context menu item
;------------------------------------------------------------------------------
Func _onUnlockControl()
	If $oSelected.count = 0 Then Return 0

	_SendMessage($hGUI, $WM_SETREDRAW, False)
	For $oCtrl In $oSelected.ctrls.Items()
		$oCtrl.Locked = False
		$oCtrl.grippies.show()
	Next
	_SendMessage($hGUI, $WM_SETREDRAW, True)
	_WinAPI_RedrawWindow($hGUI)
EndFunc   ;==>_onUnlockControl


;------------------------------------------------------------------------------
; Title...........: _onAlignMenu_Left
; Description.....: Align selected items
; Events..........: Context menu item
;------------------------------------------------------------------------------
Func _onAlignMenu_Left()
	If $oSelected.count = 0 Then Return 0
	Local $value = $oSelected.getFirst().Left
	For $oCtrl In $oSelected.ctrls.Items()
		_change_ctrl_size_pos($oCtrl, $value, Default, Default, Default)
	Next
EndFunc   ;==>_onAlignMenu_Left

Func _onAlignMenu_Center()
	If $oSelected.count = 0 Then Return 0
	Local $oCtrlValue = $oSelected.getFirst()
	Local $value = $oCtrlValue.Left + $oCtrlValue.Width / 2
	For $oCtrl In $oSelected.ctrls.Items()
		_change_ctrl_size_pos($oCtrl, $value - $oCtrl.Width / 2, Default, Default, Default)
	Next
EndFunc   ;==>_onAlignMenu_Center

Func _onAlignMenu_Right()
	If $oSelected.count = 0 Then Return 0
	Local $oCtrlValue = $oSelected.getFirst()
	Local $value = $oCtrlValue.Left + $oCtrlValue.Width
	For $oCtrl In $oSelected.ctrls.Items()
		_change_ctrl_size_pos($oCtrl, $value - $oCtrl.Width, Default, Default, Default)
	Next
EndFunc   ;==>_onAlignMenu_Right

Func _onAlignMenu_Top()
	If $oSelected.count = 0 Then Return 0
	Local $value = $oSelected.getFirst().Top
	For $oCtrl In $oSelected.ctrls.Items()
		_change_ctrl_size_pos($oCtrl, Default, $value, Default, Default)
	Next
EndFunc   ;==>_onAlignMenu_Top

Func _onAlignMenu_Middle()
	If $oSelected.count = 0 Then Return 0
	Local $oCtrlValue = $oSelected.getFirst()
	Local $value = $oCtrlValue.Top + $oCtrlValue.Height / 2
	For $oCtrl In $oSelected.ctrls.Items()
		_change_ctrl_size_pos($oCtrl, Default, $value - $oCtrl.Height / 2, Default, Default)
	Next
EndFunc   ;==>_onAlignMenu_Middle

Func _onAlignMenu_Bottom()
	If $oSelected.count = 0 Then Return 0
	Local $oCtrlValue = $oSelected.getFirst()
	Local $value = $oCtrlValue.Top + $oCtrlValue.Height
	For $oCtrl In $oSelected.ctrls.Items()
		_change_ctrl_size_pos($oCtrl, Default, $value - $oCtrl.Height, Default, Default)
	Next
EndFunc   ;==>_onAlignMenu_Bottom

Func _onAlignMenu_CenterPoints()
	If $oSelected.count = 0 Then Return 0
	Local $oCtrlValue = $oSelected.getFirst()
	Local $valueCenter = $oCtrlValue.Left + $oCtrlValue.Width / 2
	Local $valueMiddle = $oCtrlValue.Top + $oCtrlValue.Height / 2
	For $oCtrl In $oSelected.ctrls.Items()
		_change_ctrl_size_pos($oCtrl, $valueCenter - $oCtrl.Width / 2, $valueMiddle - $oCtrl.Height / 2, Default, Default)
	Next
EndFunc   ;==>_onAlignMenu_CenterPoints

Func _onAlignMenu_SpaceVertical()
	If $oSelected.count = 0 Then Return 0
	Local $oCtrlFirst, $oCtrlLast
	Local $aCtrls[1], $firstObj = True

	;first find the order
	For $oCtrl In $oSelected.ctrls.Items()
		For $i = 0 To UBound($aCtrls) - 1
			If $firstObj Then
				$aCtrls[0] = $oCtrl
				$firstObj = False
				ExitLoop
			ElseIf $oCtrl.Top < $aCtrls[$i].Top Then
				_ArrayInsert($aCtrls, $i, $oCtrl)
				ExitLoop
			ElseIf $i = UBound($aCtrls) - 1 Then
				_ArrayAdd($aCtrls, $oCtrl, 0, "|", @CRLF, $ARRAYFILL_FORCE_SINGLEITEM)
			EndIf
		Next
	Next

	;calculate the spacing
	Local $posTop = $aCtrls[0].Top + $aCtrls[0].Height / 2
	Local $posBottom = $aCtrls[$oSelected.count - 1].Top + $aCtrls[$oSelected.count - 1].Height / 2
	Local $spacing = ($posBottom - $posTop) / ($oSelected.count - 1)

	;set the new positions
	Local $pos = $aCtrls[0].Top + $aCtrls[0].Height / 2
	For $oCtrl In $aCtrls
		_change_ctrl_size_pos($oCtrl, Default, $pos - $oCtrl.Height / 2, Default, Default)
		$pos += $spacing
	Next

EndFunc   ;==>_onAlignMenu_SpaceVertical

Func _onAlignMenu_SpaceHorizontal()
	If $oSelected.count = 0 Then Return 0
	Local $oCtrlFirst, $oCtrlLast
	Local $aCtrls[1], $firstObj = True

	;first find the order
	For $oCtrl In $oSelected.ctrls.Items()
		For $i = 0 To UBound($aCtrls) - 1
			If $firstObj Then
				$aCtrls[0] = $oCtrl
				$firstObj = False
				ExitLoop
			ElseIf $oCtrl.Left < $aCtrls[$i].Left Then
				_ArrayInsert($aCtrls, $i, $oCtrl)
				ExitLoop
			ElseIf $i = UBound($aCtrls) - 1 Then
				_ArrayAdd($aCtrls, $oCtrl, 0, "|", @CRLF, $ARRAYFILL_FORCE_SINGLEITEM)
			EndIf
		Next
	Next

	;calculate the spacing
	Local $posLeft = $aCtrls[0].Left + $aCtrls[0].Width / 2
	Local $posRight = $aCtrls[$oSelected.count - 1].Left + $aCtrls[$oSelected.count - 1].Width / 2
	Local $spacing = ($posRight - $posLeft) / ($oSelected.count - 1)

	;set the new positions
	Local $pos = $aCtrls[0].Left + $aCtrls[0].Width / 2
	For $oCtrl In $aCtrls
		_change_ctrl_size_pos($oCtrl, $pos - $oCtrl.Width / 2, Default, Default, Default)
		$pos += $spacing
	Next
EndFunc   ;==>_onAlignMenu_SpaceHorizontal

Func _onAlignMenu_Back()
	If $oSelected.count = 0 Then Return 0
	For $oCtrl In $oSelected.ctrls.Items()
		_WinAPI_SetWindowPos(GUICtrlGetHandle($oCtrl.Hwnd), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	Next
EndFunc   ;==>_onAlignMenu_Back

Func _onAlignMenu_Front()
	If $oSelected.count = 0 Then Return 0
	For $oCtrl In $oSelected.ctrls.Items()
		_WinAPI_SetWindowPos(GUICtrlGetHandle($oCtrl.Hwnd), $HWND_BOTTOM, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	Next
EndFunc   ;==>_onAlignMenu_Front

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

Func _onContextMenuPasteSelected()
	_PasteSelected(False, True)
EndFunc   ;==>_onContextMenuPasteSelected

;------------------------------------------------------------------------------
; Title...........: _onMenuSelectAll
; Description.....: Select all controls
; Events..........: menu item, accel key Ctrl+A
;------------------------------------------------------------------------------
Func _onMenuSelectAll()
	_selectAll()
EndFunc   ;==>_onMenuSelectAll


Func _onUndo()
	_undo()
EndFunc   ;==>_onUndo

Func _onRedo()
	_redo()
EndFunc   ;==>_onRedo




#Region mouse events
Func _GetDoubleClickTime()
	Local $aDllRet = DllCall("user32.dll", "uint", "GetDoubleClickTime")
	If Not @error Then Return $aDllRet[0]
EndFunc   ;==>_GetDoubleClickTime

Func _onMousePrimaryDown()
;~ 	_WinAPI_Window($hGUI)

	;if main window was resized or moved, then don't process mouse down event
	If $bResizedFlag Then
		_log("** PrimaryDown: resizedflag **")
		$bResizedFlag = 0
		Return
	EndIf

	$left_click = True

	Local $aDrawStartPos = GUIGetCursorInfo($hGUI)
	Local $ctrl_hwnd = $aDrawStartPos[4]

	Local $aMousePos = MouseGetPos()
	;check if over an IP control as it has no ID
	If $ctrl_hwnd = 0 And $oCtrls.hasIP Then
		For $oThisCtrl In $oCtrls.ctrls.Items()
			If $oThisCtrl.Type = "IP" Then
				If $aDrawStartPos[0] > $oThisCtrl.Left And $aDrawStartPos[0] < $oThisCtrl.Left + $oThisCtrl.Width And $aDrawStartPos[1] > $oThisCtrl.Top And $aDrawStartPos[1] < $oThisCtrl.Top + $oThisCtrl.Height Then
					$ctrl_hwnd = $oThisCtrl.Hwnd
					ExitLoop
				EndIf
			EndIf
		Next
	EndIf

	$oCtrls.clickedCtrl = $oCtrls.get($ctrl_hwnd)

	Local $pos

	;if tool is selected and clicking on an existing control (but not resizing), switch to selection
	If (Not $initResize And Not $oCtrls.mode = $mode_init_move) And Not $oCtrls.mode = $mode_draw Then
		If $oCtrls.exists($ctrl_hwnd) And $ctrl_hwnd <> $background And $ctrl_hwnd <> 0 Then
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
			_log("** PrimaryDown: draw **")

			$initDraw = True
			_set_current_mouse_pos()
			$oMouse.StartX = $oMouse.X
			$oMouse.StartY = $oMouse.Y

			$oCtrls.drawHwnd = $ctrl_hwnd

			If $oCtrls.CurrentType = "Menu" Then
				Local $oCtrl = _create_ctrl(0, 0, $oMouse.StartX, $oMouse.StartY)

				If IsObj($oCtrl) Then
					_set_default_mode()
					$oCtrls.mode = $mode_default
					_formObjectExplorer_updateList()
					_refreshGenerateCode()
					GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
				Else
					GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
					_set_default_mode()
					$oCtrls.mode = $mode_default
				EndIf
			Else
				$oCtrls.mode = $mode_drawing
			EndIf

		Case $mode_default
			_log("** PrimaryDown: default **")
			Switch $ctrl_hwnd
				Case $background, 0
					_log("  background")
					_set_default_mode()
					_set_current_mouse_pos(1)

					$oCtrls.clickedCtrl = 0

					$oCtrls.mode = $mode_init_selection

					Local $aMousePos = MouseGetPos()
					$oMouse.StartX = $aMousePos[0]
					$oMouse.StartY = $aMousePos[1]

				Case Else
					_log("  other control")
					If Not $oCtrls.exists($ctrl_hwnd) Then
						$oCtrls.clickedCtrl = 0
						Return
					EndIf

					Local $aMousePos = MouseGetPos()
					$oMouse.StartX = $aMousePos[0]
					$oMouse.StartY = $aMousePos[1]

					;handle double click detection
					Static Local $clickTime, $prevCtrl
					If $ctrl_hwnd = $prevCtrl And TimerDiff($clickTime) <= $dblClickTime Then
						_formEventCode()
						Return
					EndIf
					$prevCtrl = $ctrl_hwnd
					$clickTime = TimerInit()

					Local $oCtrl = $oCtrls.get($ctrl_hwnd)

					;if ctrl is pressed, add/remove from selection
					Switch _IsPressed("11")
						Case False ; single select
							If Not $oSelected.exists($ctrl_hwnd) Then
								_add_to_selected($oCtrl, True, False)

								_set_current_mouse_pos()
							EndIf

						Case True ; multiple select
							Switch _group_select($oCtrl)
								Case True
									_set_current_mouse_pos()

									GUICtrlSetCursor($oCtrl.Hwnd, $SIZE_ALL)

								Case False
									If Not $oSelected.exists($ctrl_hwnd) Then
										_add_to_selected($oCtrl, False, False)
										_set_current_mouse_pos()
									Else
										_remove_from_selected($oCtrl, False)
									EndIf
							EndSwitch
					EndSwitch

					If $oSelected.count <= 1 Then
						_setLvSelected($oSelected.getFirst())
					EndIf

;~ 					If IsObj($oCtrl) Then
;~ 						If $oCtrl.Locked Then
;~ 							$oCtrls.mode = $mode_init_selection
;~ 						EndIf
;~ 					EndIf
			EndSwitch

		Case $mode_paste
			_log("** PrimaryDown: paste **")
			$left_click = False
			ToolTip('')
			_recall_overlay()
			$oCtrls.mode = $mode_default

		Case Else
			_log("** PrimaryDown: case else **")
			GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
			_set_current_mouse_pos()
	EndSwitch

EndFunc   ;==>_onMousePrimaryDown


Func _onMousePrimaryUp()
	$left_click = False
	Local $ctrl_hwnd, $oCtrl, $updateObjectExplorer
	$oCtrls.clickedCtrl = 0

	Switch $oCtrls.mode
		Case $mode_drawing
			_log("** PrimaryUp: draw **")
			GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
			_set_default_mode()
			_showProperties()
			$initDraw = False

		Case $mode_init_move
			_log("** PrimaryUp: init_move **")
			ToolTip('')

			Local $aMousePos = MouseGetPos()

			;update the undo action stack
			Local $oAction = _objAction()
			$oAction.action = $action_moveCtrl
			$oAction.ctrls = $oSelected.ctrls.Items()
			Local $aParams[2] = [$aMousePos[0] - $oMouse.StartX, $aMousePos[1] - $oMouse.StartY]
			$oAction.parameters = $aParams
			_updateActionStacks($oAction)

;~ 			_set_default_mode()
			$oCtrls.mode = $mode_default

			;we don't care what was dragged, we just want to populate based on latest selection
			;to prevent mouse 'falling off' of control when dropped
			$oCtrl = $oSelected.getLast()
			If IsObj($oCtrl) Then
				_populate_control_properties_gui($oCtrl)
			EndIf

			If $oSelected.count > 0 Then
				_refreshGenerateCode()
			EndIf
			_showProperties()

		Case $mode_init_selection
			_log("** PrimaryUp: init_selection **")
			ToolTip('')

			_recall_overlay()

			$oCtrls.mode = $mode_default

			_showProperties()
			_populate_control_properties_gui($oSelected.getLast())

		Case $resize_nw, $resize_n, $resize_ne, $resize_e, $resize_se, $resize_s, $resize_sw, $resize_w
			_log("** PrimaryUp: Resize **")

			ToolTip('')

			For $oCtrl In $oSelected.ctrls.Items()
				$oCtrl.isResizeMaster = False
			Next

			$oCtrlSelectedFirst = $oSelected.getFirst()
			If $initDraw Then    ;if we just started drawing, check to see if drawing or just clicking away from control
				_log("  init draw")
				$initDraw = False
				;clicking empty space (background), cancel drawing and delete the new control
				Local $tolerance = 5

				If $oCtrlSelectedFirst.Type = "Tab" Then
					GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
				EndIf

				If Abs($oMouse.X - $oMouse.StartX) < $tolerance And Abs($oMouse.Y - $oMouse.StartY) < $tolerance Then
					_log("  click away")
					GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
					_delete_selected_controls()
					_set_default_mode()
				Else
					;update the undo action stack
					Local $oAction = _objAction()
					$oAction.action = $action_drawCtrl
					$oAction.ctrls = $oSelected.ctrls.Items()
					Local $aParams[$oSelected.ctrls.Count]
					Local $aParam[1]
					For $i = 0 To UBound($oAction.ctrls) - 1
						$aParam[0] = $oAction.ctrls[$i].Hwnd
						$aParams[$i] = $aParam
					Next
					$oAction.parameters = $aParams
					_updateActionStacks($oAction)
				EndIf
			Else
				_log("** PrimaryUp: Else **")
				;update the undo action stack
				Local $oAction = _objAction()
				$oAction.action = $action_resizeCtrl
				$oAction.ctrls = $oSelected.ctrls.Items()
				Local $aParams[$oSelected.ctrls.Count]
				Local $aParam[8]
				For $i = 0 To UBound($oAction.ctrls) - 1
					$aParam[0] = $oAction.ctrls[$i].PrevWidth
					$aParam[1] = $oAction.ctrls[$i].PrevHeight
					$aParam[2] = $oAction.ctrls[$i].Width
					$aParam[3] = $oAction.ctrls[$i].Height
					$aParam[4] = $oAction.ctrls[$i].PrevLeft
					$aParam[5] = $oAction.ctrls[$i].PrevTop
					$aParam[6] = $oAction.ctrls[$i].Left
					$aParam[7] = $oAction.ctrls[$i].Top
					$aParams[$i] = $aParam
				Next
				$oAction.parameters = $aParams
				_updateActionStacks($oAction)
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

			$updateObjectExplorer = True

			_setLvSelected($oSelected.getFirst())

		Case Else    ;select single control
			_log("** PrimaryUp: Else **")
			ToolTip('')

			;we don't care what was dragged, we just want to populate based on latest selection
			;to prevent mouse 'falling off' of control when dropped
			$oCtrl = $oSelected.getLast()
			If IsObj($oCtrl) Then
				_populate_control_properties_gui($oCtrl)
			EndIf

			If $oSelected.count > 0 Then
				_refreshGenerateCode()
			EndIf
			_showProperties()

	EndSwitch

	If $oSelected.hasIP Then
		For $oCtrl In $oCtrls.ctrls.Items()
			If $oCtrl.Type = "IP" And $oCtrl.Dirty Then
				_updateIP($oCtrl)
				$oCtrl.Dirty = False
			EndIf
		Next
		$updateObjectExplorer = True
	EndIf

	If $updateObjectExplorer Then
		_formObjectExplorer_updateList()
	EndIf

EndFunc   ;==>_onMousePrimaryUp


Func _onMouseSecondaryDown()
	Local Const $ctrl_hwnd = GUIGetCursorInfo($hGUI)[4]

	Switch $ctrl_hwnd
		Case $background
			_log("** SecondaryDown: background **")
			_set_current_mouse_pos()

		Case Else
			_log("** SecondaryDown: control **")
			Local $oCtrl = $oCtrls.get($ctrl_hwnd)

			If $oCtrls.exists($ctrl_hwnd) Then
				If Not $oSelected.exists($ctrl_hwnd) Then
					_add_to_selected($oCtrl)
				EndIf

				_setLvSelected($oSelected.getFirst())
			EndIf
	EndSwitch

	_set_current_mouse_pos()
EndFunc   ;==>_onMouseSecondaryDown


Func _onMouseSecondaryUp()
	Local Const $ctrl_hwnd = GUIGetCursorInfo($hGUI)[4]

	Switch $ctrl_hwnd
		Case $background
			_log("** SecondaryUp: background **")
			$oMouse.StartX = $oMouse.X
			$oMouse.StartY = $oMouse.Y
			ShowMenu($background_contextmenu, $oMouse.X, $oMouse.Y)

		Case Else
			_log("** SecondaryUp: control **")
			Local $oCtrl = $oCtrls.get($ctrl_hwnd)

			If $oCtrls.exists($ctrl_hwnd) Then

				If $oCtrl.Type = "Tab" Then
					ShowMenu($overlay_contextmenutab, $oMouse.X, $oMouse.Y)
				Else
					Local $hasLocked = False
					For $oSelectedCtrl In $oSelected.ctrls.Items()
						If $oCtrl.Locked Then
							$hasLocked = True
							ExitLoop
						EndIf
					Next

					If $hasLocked Then
						GUICtrlSetData($contextmenu_lock, "Unlock Control")
						GUICtrlSetOnEvent($contextmenu_lock, "_onUnlockControl")
					Else
						GUICtrlSetData($contextmenu_lock, "Lock Control")
						GUICtrlSetOnEvent($contextmenu_lock, "_onLockControl")
					EndIf

					ShowMenu($overlay_contextmenu, $oMouse.X, $oMouse.Y)
				EndIf

			EndIf
	EndSwitch
EndFunc   ;==>_onMouseSecondaryUp


Func _onMouseMove()
	Static $timeMove = TimerInit()

	If TimerDiff($timeMove) < 20 Then
		Return 0
	EndIf

	Switch $oCtrls.mode
		Case $mode_drawing
			_log("MOVE:  Drawing")
			Local $oCtrl = _create_ctrl(0, 0, $oMouse.StartX, $oMouse.StartY, $oCtrls.drawHwnd)

			If IsObj($oCtrl) Then
				_add_to_selected($oCtrl)

				Switch $oCtrl.Type
					Case "Combo", "Checkbox", "Radio"
						$pos = ControlGetPos($hGUI, '', $oCtrl.grippies.East)

						$oSelected.StartResizing()
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

						$oSelected.StartResizing()
						$oCtrls.mode = $resize_se

						_move_mouse_to_grippy($pos[0], $pos[1])
				EndSwitch
			Else
				GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
				_set_default_mode()
				$oCtrls.mode = $mode_default
			EndIf

		Case $mode_default
;~ 			_log("MOVE:  Default")
			If IsObj($oCtrls.clickedCtrl) Then
				$oCtrls.mode = $mode_init_move
				$oMouse.X = $oMouse.StartX
				$oMouse.Y = $oMouse.StartY
			EndIf

		Case $mode_init_move, $mode_paste
;~ 			_log("MOVE:  Moving")
			Local $mouse_prevpos[2] = [$oMouse.X, $oMouse.Y]
			$mouse_prevpos = _snap_to_grid($mouse_prevpos)

			Local Const $mouse_pos = _mouse_snap_pos()

			Local Const $delta_x = $mouse_prevpos[0] - $mouse_pos[0]

			Local Const $delta_y = $mouse_prevpos[1] - $mouse_pos[1]

			$oMouse.X = $mouse_pos[0]
			$oMouse.Y = $mouse_pos[1]

			If Not $left_click And Not $oCtrls.mode = $mode_paste Then
				Return
			EndIf

			Local $tooltip

			Local $count = $oSelected.count

			If IsObj($oCtrls.clickedCtrl) Then
				If $oCtrls.clickedCtrl.Locked Then
					$oCtrls.mode = $mode_default
					Return
				EndIf
			EndIf

			_SendMessage($hGUI, $WM_SETREDRAW, False)
			For $oCtrl In $oSelected.ctrls.Items()
				_change_ctrl_size_pos($oCtrl, $oCtrl.Left - $delta_x, $oCtrl.Top - $delta_y, Default, Default)
				$tooltip &= $oCtrl.Name & ": X:" & $oCtrl.Left & ", Y:" & $oCtrl.Top & ", W:" & $oCtrl.Width & ", H:" & $oCtrl.Height & @CRLF

				If $oCtrls.mode = $mode_init_move Then
					$oCtrl.Dirty = True
				EndIf

				Switch $oCtrl.Type
					Case "Tab"
						_moveTabCtrls($oCtrl, $delta_x, $delta_y, Default, Default)

					Case "Group"
						_moveGroupCtrls($oCtrl, $delta_x, $delta_y, Default, Default)

				EndSwitch
			Next

			_SendMessage($hGUI, $WM_SETREDRAW, True)

			If $oSelected.count < 5 Then
				ToolTip(StringTrimRight($tooltip, 2))
			Else
				ToolTip("")
			EndIf

;~ 			If Not $oCtrls.mode = $mode_paste Then
;~ 				$oCtrls.mode = $mode_default
;~ 			EndIf

		Case $mode_init_selection
			_log("MOVE:  Selection")
			Local Const $oRect = _rect_from_points($oMouse.X, $oMouse.Y, MouseGetPos(0), MouseGetPos(1))
			_display_selection_rect($oRect)
			_add_remove_selected_control($oRect)
;~ 			_setLvSelected($oSelected.getFirst())
			Return

		Case $resize_nw, $resize_n, $resize_ne, $resize_w, $resize_e, $resize_sw, $resize_s, $resize_se
;~ 			_log("MOVE:  Resizing")
			Local $tooltip

			_SendMessage($hGUI, $WM_SETREDRAW, False)
			For $oCtrlSelect In $oSelected.ctrls.Items()
				$oCtrlSelect.grippies.resizing($oCtrls.mode)
				$tooltip &= $oCtrlSelect.Name & ": X:" & $oCtrlSelect.Left & ", Y:" & $oCtrlSelect.Top & ", W:" & $oCtrlSelect.Width & ", H:" & $oCtrlSelect.Height & @CRLF

				If $oCtrls.mode = $mode_init_move Then
					$oCtrl.Dirty = True
				EndIf
			Next
			_SendMessage($hGUI, $WM_SETREDRAW, True)

			If $oSelected.count < 5 Then
				ToolTip(StringTrimRight($tooltip, 2))
			Else
				ToolTip("")
			EndIf

			$oMain.hasChanged = True

	EndSwitch

	_WinAPI_RedrawWindow($hGUI)
	$timeMove = TimerInit()

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
		GUISetState(@SW_SHOWNOACTIVATE, $hFormGenerateCode)
		GUISwitch($hGUI)
	Else
		_onExitGenerateCode()
;~ 		GUICtrlSetData($editCodeGeneration, _code_generation())
;~ 		WinActivate($hFormGenerateCode)
	EndIf

	; save state to settings file
	Switch BitAND(GUICtrlRead($menu_generateCode), $GUI_CHECKED) = $GUI_CHECKED
		Case True
			IniWrite($sIniPath, "Settings", "ShowCode", 1)
			$oOptions.showCodeViewer = True

		Case False
			IniWrite($sIniPath, "Settings", "ShowCode", 0)
			$oOptions.showCodeViewer = False

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
		GUISetState(@SW_SHOWNOACTIVATE, $hFormObjectExplorer)
		GUISwitch($hGUI)
	Else
		_onExitObjectExplorer()
	EndIf

	; save state to settings file
	Switch BitAND(GUICtrlRead($menu_ObjectExplorer), $GUI_CHECKED) = $GUI_CHECKED
		Case True
			IniWrite($sIniPath, "Settings", "ShowObjectExplorer", 1)
			$oOptions.ShowObjectExplorer = True

		Case False
			IniWrite($sIniPath, "Settings", "ShowObjectExplorer", 0)
			$oOptions.ShowObjectExplorer = False

	EndSwitch
EndFunc   ;==>_onShowObjectExplorer


;------------------------------------------------------------------------------
; Title...........: _onResetLayout
; Description.....: Set GUI windows to default positions
; Events..........: view menu item
;------------------------------------------------------------------------------
Func _onResetLayout()
	;form gui
	$oMain.Width = 400
	$oMain.Height = 300

	$oMain.Left = (@DesktopWidth / 2) - ($oMain.Width / 2)
	$oMain.Top = (@DesktopHeight / 2) - ($oMain.Height / 2)

	WinMove($hGUI, "", $oMain.Left, $oMain.Top, $oMain.Width + $iGuiFrameW, $oMain.Height + $iGuiFrameH)
	WinSetTitle($hGUI, "", $oMain.Title & " - Form (" & $oMain.Width & ", " & $oMain.Height & ")")

	;toolbar
	Local Const $toolbar_width = 215
	Local Const $toolbar_height = 480

	Local $toolbar_left = $oMain.Left - ($toolbar_width + 5)
	Local $toolbar_top = $oMain.Top

	WinMove($hToolbar, "", $toolbar_left, $toolbar_top, $toolbar_width, $toolbar_height)

	;object explorer
	If IsHWnd($hFormObjectExplorer) Then
		Local $w = 250
		Local $h = 500

		Local $x = $oMain.Left + ($oMain.Width + 5)
		Local $y = $oMain.Top

		WinMove($hFormObjectExplorer, "", $x, $y, $w, $h)
	EndIf

	;code preview
	If IsHWnd($hFormGenerateCode) Then
		Local $w = 450
		Local $h = 550

		Local $x = $oMain.Left + 100
		Local $y = $oMain.Top - 50

		WinMove($hFormGenerateCode, "", $x, $y, $w, $h)
	EndIf
EndFunc   ;==>_onResetLayout


;------------------------------------------------------------------------------
; Title...........: _onTestGUI
; Description.....: Run the generated code to test the GUI
; Events..........:	Tools menu item
;------------------------------------------------------------------------------
Func _onTestGUI()
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
		If Not FileExists(@ProgramFilesDir & "\AutoIt3\AutoIt3.exe") Then
			Local $sFileOpenDialog = FileOpenDialog("Select AutoIt3.exe", @ProgramFilesDir, "(*.exe)", $FD_FILEMUSTEXIST, "AutoIt3.exe")
			If @error Then
				MsgBox(1, "Error", "Could not find AutoIt3.exe")
				Return
			Else
				$au3InstallPath = $sFileOpenDialog
				IniWrite($sIniPath, "Settings", "AutoIt3FullPath", $au3InstallPath)
			EndIf
		Else
			$au3InstallPath = @ProgramFilesDir & "\AutoIt3\AutoIt3.exe"
		EndIf
	EndIf
;~ 	Local $filename = StringRegExpReplace($testFileName, "^.*\\", "")
	$TestFilePID = Run($au3InstallPath & ' /AutoIt3ExecuteScript ' & $testFileName, @ScriptDir)

	;monitor process from main loop

EndFunc   ;==>_onTestGUI

Func _onSettings()
	_formSettings()
EndFunc   ;==>_onSettings


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
	If Not IsObj($oCtrl) Then Return
	If Not $oCtrls.exists($oCtrl.Hwnd) Then
		Return
	EndIf

	;TEXT
	Local $text = $oCtrl.Text
	If $oCtrl.Type = "Tab" Then
		If $childHwnd <> -1 Then ;this is a child tab
			Local $iTabFocus = _GUICtrlTab_GetCurSel($oCtrl.Hwnd)

			If $iTabFocus >= 0 Then
				$tabID = $oCtrl.Tabs.at($iTabFocus)
				$text = $oCtrls.get($tabID).Text
			EndIf
		EndIf
	EndIf
	$oProperties_Ctrls.properties.Text.value = $text

	;NAME
	Local $name = $oCtrl.Name
	If $oCtrl.Type = "Tab" Then
		If $childHwnd <> -1 Then ;this is a child tab
			Local $iTabFocus = _GUICtrlTab_GetCurSel($oCtrl.Hwnd)

			If $iTabFocus >= 0 Then
				$tabID = $oCtrl.Tabs.at($iTabFocus)
				$name = $oCtrls.get($tabID).Name
			EndIf
		EndIf
	EndIf
	$oProperties_Ctrls.properties.Name.value = $name

	$oProperties_Ctrls.properties.Left.value = $oCtrl.Left
	$oProperties_Ctrls.properties.Top.value = $oCtrl.Top
	$oProperties_Ctrls.properties.Width.value = $oCtrl.Width
	$oProperties_Ctrls.properties.Height.value = $oCtrl.Height

	If $oCtrl.FontSize <> -1 Then
		$oProperties_Ctrls.properties.FontSize.value = $oCtrl.FontSize
	Else
		$oProperties_Ctrls.properties.FontSize.value = 8.5
	EndIf

	If $oCtrl.Background <> -1 Then
		$oProperties_Ctrls.properties.Background.value = "0x" & Hex($oCtrl.Background, 6)
	Else
		$oProperties_Ctrls.properties.Background.value = ""
	EndIf
	If $oCtrl.Color <> -1 Then
		$oProperties_Ctrls.properties.Color.value = "0x" & Hex($oCtrl.Color, 6)
	Else
		$oProperties_Ctrls.properties.Color.value = ""
	EndIf


	$oProperties_Ctrls.properties.Global.value = $oCtrl.Global

	;font weight
	Local $iFw
	Switch $oCtrl.FontWeight
		Case 100
			$iFw = 0
		Case 200
			$iFw = 1
		Case 300
			$iFw = 2
		Case 400
			$iFw = 3
		Case 500
			$iFw = 4
		Case 600
			$iFw = 5
		Case 700
			$iFw = 6
		Case 800
			$iFw = 7
		Case 900
			$iFw = 8
		Case Else
			$iFw = 3
	EndSwitch
	_GUICtrlComboBox_SetCurSel(GUICtrlGetHandle($oProperties_Ctrls.properties.FontWeight.Hwnd), $iFw)
;~ 	ControlCommand(HWnd($oProperties_Ctrls.properties.Hwnd), "", $oProperties_Ctrls.properties.FontWeight.Hwnd, "SetCurrentSelection", $iFw)

	;font name
	If $oCtrl.FontName = "" Then
		_GUICtrlComboBox_SetCurSel(GUICtrlGetHandle($oProperties_Ctrls.properties.FontName.Hwnd), -1)
	Else
		Local $selection = ControlCommand(HWnd($oProperties_Ctrls.properties.Hwnd), "", $oProperties_Ctrls.properties.FontName.Hwnd, "FindString", $oCtrl.FontName)
		_GUICtrlComboBox_SetCurSel(GUICtrlGetHandle($oProperties_Ctrls.properties.FontName.Hwnd), $selection)
	EndIf

EndFunc   ;==>_populate_control_properties_gui


#Region change-properties-main
Func _main_change_title()
	Local Const $new_text = $oProperties_Main.properties.Title.value
	$oMain.Title = $new_text

	_refreshGenerateCode()
	$oMain.hasChanged = True

	WinSetTitle($hGUI, "", $oMain.Title & " - Form (" & $oMain.Width & ", " & $oMain.Height & ")")
EndFunc   ;==>_main_change_title


Func _main_change_name()
	Local $new_name = $oProperties_Main.properties.Name.value
	$new_name = StringReplace($new_name, " ", "_")
	$oProperties_Main.properties.Name.value = $new_name
	$oMain.Name = $new_name

	_refreshGenerateCode()
	_formObjectExplorer_updateList()
	$oMain.hasChanged = True
EndFunc   ;==>_main_change_name


Func _main_change_left()
	Local Const $new_text = $oProperties_Main.properties.Left.value
	$oMain.Left = $new_text

	_refreshGenerateCode()
	$oMain.hasChanged = True
EndFunc   ;==>_main_change_left


Func _main_change_top()
	Local Const $new_text = $oProperties_Main.properties.Top.value
	$oMain.Top = $new_text

	_refreshGenerateCode()
	$oMain.hasChanged = True
EndFunc   ;==>_main_change_top


Func _main_change_width()
	Local Const $newValue = $oProperties_Main.properties.Width.value

	WinMove($hGUI, "", Default, Default, $newValue + $iGuiFrameW, Default)

	Local $aWinPos = WinGetClientSize($hGUI)
	WinSetTitle($hGUI, "", $oMain.Title & " - Form (" & $aWinPos[0] & ", " & $aWinPos[1] & ")")

	$oMain.Width = $aWinPos[0]

	If $oOptions.showGrid Then
		_display_grid($background, $aWinPos[0], $aWinPos[1])
	EndIf

	_refreshGenerateCode()
	$oMain.hasChanged = True
EndFunc   ;==>_main_change_width


Func _main_change_height()
	Local Const $newValue = $oProperties_Main.properties.Height.value

	WinMove($hGUI, "", Default, Default, Default, $newValue + $iGuiFrameH)

	Local $aWinPos = WinGetClientSize($hGUI)
	WinSetTitle($hGUI, "", $oMain.Title & " - Form (" & $aWinPos[0] & ", " & $aWinPos[1] & ")")

	$oMain.Height = $aWinPos[1]

	If $oOptions.showGrid Then
		_display_grid($background, $aWinPos[0], $aWinPos[1])
	EndIf

	_refreshGenerateCode()
	$oMain.hasChanged = True
EndFunc   ;==>_main_change_height


Func _main_pick_bkColor()
	Local $color = _ChooseColor(2)

	If $color = -1 Then Return 0
	$oProperties_Main.properties.Background.value = $color

	_main_change_background()
	$oMain.hasChanged = True
EndFunc   ;==>_main_pick_bkColor


Func _main_change_background()
	Local $colorInput = $oProperties_Main.properties.Background.value
	If $colorInput = "" Or $colorInput = -1 Then
		$colorInput = $defaultGuiBkColor
	Else
		$colorInput = Dec(StringReplace($colorInput, "0x", ""))
	EndIf
	$oMain.Background = $oProperties_Main.properties.Background.value

	GUISetBkColor($colorInput, $hGUI)

	_refreshGenerateCode()
	$oMain.hasChanged = True
EndFunc   ;==>_main_change_background
#EndRegion change-properties-main


#Region change-properties-ctrls

Func _ctrl_change_text()
	Local Const $new_text = $oProperties_Ctrls.properties.Text.value

	Local Const $sel_count = $oSelected.count

	;update the undo action stack
	Local $oAction = _objAction()
	$oAction.action = $action_changeText
	$oAction.ctrls = $oSelected.ctrls.Items()
	Local $aParams[$oSelected.ctrls.Count]
	Local $aParam[2]
	For $i = 0 To UBound($oAction.ctrls) - 1
		$aParam[0] = $oAction.ctrls[$i].Text
		$aParam[1] = $oProperties_Ctrls.properties.Text.value
		$aParams[$i] = $aParam
	Next
	$oAction.parameters = $aParams
	_updateActionStacks($oAction)

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls.Items()
				If $oCtrl.Locked Then ContinueLoop

				If $oCtrl.Type = "Combo" Then
					GUICtrlSetData($oCtrl.Hwnd, $new_text, $new_text)
					$oCtrl.Text = $new_text
				ElseIf $oCtrl.Type = "Tab" Then
					If $childSelected Then
						Local $iTabFocus = _GUICtrlTab_GetCurSel($oCtrl.Hwnd)

						If $iTabFocus >= 0 Then
							_GUICtrlTab_SetItemText($oCtrl.Hwnd, $iTabFocus, $new_text)
							$tabID = $oCtrl.Tabs.at($iTabFocus)
							$oCtrls.get($tabID).Text = $new_text
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
				ElseIf $oCtrl.Type = "IP" Then
					_GUICtrlIpAddress_Set($oCtrl.Hwnd, $new_text)
					$oCtrl.Text = $new_text
				Else
					GUICtrlSetData($oCtrl.Hwnd, $new_text)
					$oCtrl.Text = $new_text
				EndIf
			Next
	EndSwitch

	_refreshGenerateCode()
	$oMain.hasChanged = True
EndFunc   ;==>_ctrl_change_text


Func _ctrl_change_name()
	Local $new_name = $oProperties_Ctrls.properties.Name.value
	$new_name = StringReplace($new_name, " ", "_")
	$oProperties_Ctrls.properties.Name.value = $new_name

	Local Const $sel_count = $oSelected.count

	;update the undo action stack
	Local $oAction = _objAction()
	$oAction.action = $action_renameCtrl
	$oAction.ctrls = $oSelected.ctrls.Items()
	Local $aParams[2] = [$oAction.ctrls[0].Name, $oProperties_Ctrls.properties.Name.value]
	$oAction.parameters = $aParams
	_updateActionStacks($oAction)

	If $sel_count = 1 Then
		Local $oCtrl = $oSelected.getFirst()
		If $oCtrl.Locked Then Return

		If $oCtrl.Type = "Tab" Then
			If $childSelected Then
				Local $iTabFocus = _GUICtrlTab_GetCurSel($oCtrl.Hwnd)

				If $iTabFocus >= 0 Then
					$tabID = $oCtrl.Tabs.at($iTabFocus)
					$oCtrls.get($tabID).Name = $new_name
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
	$oMain.hasChanged = True
EndFunc   ;==>_ctrl_change_name


Func _ctrl_change_left()
	Local $new_data = $oProperties_Ctrls.properties.Left.value
	If $new_data = "" Then
		$new_data = 0
		$oProperties_Ctrls.properties.Left.value = $new_data
	EndIf

	Local Const $sel_count = $oSelected.count

	;update the undo action stack
	Local $oAction = _objAction()
	$oAction.action = $action_resizeCtrl
	$oAction.ctrls = $oSelected.ctrls.Items()
	Local $aParams[$oSelected.ctrls.Count]
	Local $aParam[8]
	For $i = 0 To UBound($oAction.ctrls) - 1
		$aParam[0] = $oAction.ctrls[$i].Width
		$aParam[1] = $oAction.ctrls[$i].Height
		$aParam[2] = $oAction.ctrls[$i].Width
		$aParam[3] = $oAction.ctrls[$i].Height
		$aParam[4] = $oAction.ctrls[$i].Left
		$aParam[5] = $oAction.ctrls[$i].Top
		$aParam[6] = $oProperties_Ctrls.properties.Left.value
		$aParam[7] = $oAction.ctrls[$i].Top
		$aParams[$i] = $aParam
	Next
	$oAction.parameters = $aParams
	_updateActionStacks($oAction)

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls.Items()
				If $oCtrl.Locked Then ContinueLoop

				Switch $oCtrl.Type
					Case "Tab"
						_moveTabCtrls($oCtrl, $oCtrl.Left - $new_data, Default, Default, Default)

					Case "Group"
						_moveGroupCtrls($oCtrl, $oCtrl.Left - $new_data, Default, Default, Default)

				EndSwitch

				;move the selected control
				_change_ctrl_size_pos($oCtrl, $new_data, Default, Default, Default)
				;update the selected property
				$oCtrl.Left = $new_data

				If $oSelected.hasIP Then
					For $oCtrl In $oSelected.ctrls.Items()
						If $oCtrl.Type = "IP" Then
							_updateIP($oCtrl)
						EndIf
					Next
					_formObjectExplorer_updateList()
				EndIf

				$oCtrl.grippies.show()

			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_left


Func _ctrl_change_top()
	Local $new_data = $oProperties_Ctrls.properties.Top.value
	If $new_data = "" Then
		$new_data = 0
		$oProperties_Ctrls.properties.Top.value = $new_data
	EndIf

	Local Const $sel_count = $oSelected.count

	;update the undo action stack
	Local $oAction = _objAction()
	$oAction.action = $action_resizeCtrl
	$oAction.ctrls = $oSelected.ctrls.Items()
	Local $aParams[$oSelected.ctrls.Count]
	Local $aParam[8]
	For $i = 0 To UBound($oAction.ctrls) - 1
		$aParam[0] = $oAction.ctrls[$i].Width
		$aParam[1] = $oAction.ctrls[$i].Height
		$aParam[2] = $oAction.ctrls[$i].Width
		$aParam[3] = $oAction.ctrls[$i].Height
		$aParam[4] = $oAction.ctrls[$i].Left
		$aParam[5] = $oAction.ctrls[$i].Top
		$aParam[6] = $oAction.ctrls[$i].Left
		$aParam[7] = $oProperties_Ctrls.properties.Top.value
		$aParams[$i] = $aParam
	Next
	$oAction.parameters = $aParams
	_updateActionStacks($oAction)

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls.Items()
				If $oCtrl.Locked Then ContinueLoop

				Switch $oCtrl.Type
					Case "Tab"
						_moveTabCtrls($oCtrl, Default, $oCtrl.Top - $new_data, Default, Default)

					Case "Group"
						_moveGroupCtrls($oCtrl, Default, $oCtrl.Top - $new_data, Default, Default)

				EndSwitch

				;move the selected control
				_change_ctrl_size_pos($oCtrl, Default, $new_data, Default, Default)
				;update the selected property
				$oCtrl.Top = $new_data

				If $oSelected.hasIP Then
					For $oCtrl In $oSelected.ctrls.Items()
						If $oCtrl.Type = "IP" Then
							_updateIP($oCtrl)
						EndIf
					Next
					_formObjectExplorer_updateList()
				EndIf

				$oCtrl.grippies.show()
			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_top


Func _ctrl_change_width()
	Local $new_data = $oProperties_Ctrls.properties.Width.value
	If $new_data = "" Then
		$new_data = 0
		$oProperties_Ctrls.properties.Width.value = $new_data
	EndIf

	Local Const $sel_count = $oSelected.count

	;update the undo action stack
	Local $oAction = _objAction()
	$oAction.action = $action_resizeCtrl
	$oAction.ctrls = $oSelected.ctrls.Items()
	Local $aParams[$oSelected.ctrls.Count]
	Local $aParam[8]
	For $i = 0 To UBound($oAction.ctrls) - 1
		$aParam[0] = $oAction.ctrls[$i].Width
		$aParam[1] = $oAction.ctrls[$i].Height
		$aParam[2] = $oProperties_Ctrls.properties.Width.value
		$aParam[3] = $oAction.ctrls[$i].Height
		$aParam[4] = $oAction.ctrls[$i].Left
		$aParam[5] = $oAction.ctrls[$i].Top
		$aParam[6] = $oAction.ctrls[$i].Left
		$aParam[7] = $oAction.ctrls[$i].Top
		$aParams[$i] = $aParam
	Next
	$oAction.parameters = $aParams
	_updateActionStacks($oAction)

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls.Items()
				If $oCtrl.Locked Then ContinueLoop

				;move the selected control
				_change_ctrl_size_pos($oCtrl, Default, Default, $new_data, Default)
				;update the selected property
				$oCtrl.Width = $new_data

				If $oSelected.hasIP Then
					For $oCtrl In $oSelected.ctrls.Items()
						If $oCtrl.Type = "IP" Then
							_updateIP($oCtrl)
						EndIf
					Next
					_formObjectExplorer_updateList()
				EndIf

				$oCtrl.grippies.show()
			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_width


Func _ctrl_change_height()
	Local $new_data = $oProperties_Ctrls.properties.Height.value
	If $new_data = "" Then
		$new_data = 0
		$oProperties_Ctrls.properties.Height.value = $new_data
	EndIf

	Local Const $sel_count = $oSelected.count

	;update the undo action stack
	Local $oAction = _objAction()
	$oAction.action = $action_resizeCtrl
	$oAction.ctrls = $oSelected.ctrls.Items()
	Local $aParams[$oSelected.ctrls.Count]
	Local $aParam[8]
	For $i = 0 To UBound($oAction.ctrls) - 1
		$aParam[0] = $oAction.ctrls[$i].Width
		$aParam[1] = $oAction.ctrls[$i].Height
		$aParam[2] = $oAction.ctrls[$i].Width
		$aParam[3] = $oProperties_Ctrls.properties.Height.value
		$aParam[4] = $oAction.ctrls[$i].Left
		$aParam[5] = $oAction.ctrls[$i].Top
		$aParam[6] = $oAction.ctrls[$i].Left
		$aParam[7] = $oAction.ctrls[$i].Top
		$aParams[$i] = $aParam
	Next
	$oAction.parameters = $aParams
	_updateActionStacks($oAction)

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls.Items()
				If $oCtrl.Locked Then ContinueLoop

				;move the selected control
				_change_ctrl_size_pos($oCtrl, Default, Default, Default, $new_data)
				;update the selected property
				$oCtrl.Height = $new_data

				If $oSelected.hasIP Then
					For $oCtrl In $oSelected.ctrls.Items()
						If $oCtrl.Type = "IP" Then
							_updateIP($oCtrl)
						EndIf
					Next
					_formObjectExplorer_updateList()
				EndIf

				$oCtrl.grippies.show()
			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_height


Func _ctrl_pick_bkColor()
	Local $color = _ChooseColor(2)

	If $color = -1 Then Return 0
	$oProperties_Ctrls.properties.Background.value = $color

	_ctrl_change_bkColor()
	$oMain.hasChanged = True
EndFunc   ;==>_ctrl_pick_bkColor


Func _ctrl_change_bkColor()
	Local $colorInput = $oProperties_Ctrls.properties.Background.value
	Local $newColor = $colorInput
	If $colorInput = "" Then
		$colorInput = -1
		$oProperties_Ctrls.properties.Background.value = -1
	Else
		$colorInput = Dec(StringReplace($colorInput, "0x", ""))
	EndIf

	Local Const $sel_count = $oSelected.count

	;update the undo action stack
	Local $oAction = _objAction()
	$oAction.action = $action_changeBkColor
	$oAction.ctrls = $oSelected.ctrls.Items()
	Local $aParams[$oSelected.ctrls.Count]
	Local $aParam[2]
	For $i = 0 To UBound($oAction.ctrls) - 1
		$aParam[0] = $oAction.ctrls[$i].Background
		$aParam[1] = $colorInput
		$aParams[$i] = $aParam
	Next
	$oAction.parameters = $aParams
	_updateActionStacks($oAction)

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls.Items()
				If $oCtrl.Locked Then ContinueLoop

				;convert string to color then apply
				Switch $oCtrl.Type
					Case "Label", "Checkbox", "Radio", "Input", "Edit"
						If $colorInput <> -1 Then
							GUICtrlSetBkColor($oCtrl.Hwnd, $colorInput)
						Else
;~ 							GUICtrlDelete($oCtrl.Hwnd)
;~ 							$oCtrl.Hwnd = GUICtrlCreateLabel($oCtrl.Text, $oCtrl.Left, $oCtrl.Top, $oCtrl.Width, $oCtrl.Height)
							GUICtrlSetBkColor($oCtrl.Hwnd, $defaultGuiBkColor)
							$oCtrl.Background = -1
;~ 							If $oCtrl.Color <> -1 Then
;~ 								GUICtrlSetColor($oCtrl.Hwnd, $oCtrl.Color)
;~ 							EndIf
						EndIf

						$oCtrl.Background = $colorInput

					Case "Graphic"
						$oCtrl.Background = $colorInput
						_updateGraphic($oCtrl)

					Case Else
						ContinueLoop

				EndSwitch
			Next
	EndSwitch

	_refreshGenerateCode()
	$oMain.hasChanged = True
EndFunc   ;==>_ctrl_change_bkColor


Func _ctrl_change_global()
	Local $new_data = _onCheckboxChange(@GUI_CtrlId)
;~ 	Local $new_data = $oProperties_Ctrls.properties.Global.value


	Local Const $sel_count = $oSelected.count

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls.Items()
				If $oCtrl.Locked Then ContinueLoop

				;update the property
				$oCtrl.Global = $new_data
			Next
	EndSwitch

	_refreshGenerateCode()
	$oMain.hasChanged = True
EndFunc   ;==>_ctrl_change_global


Func _ctrl_change_FontSize()
	Local $new_data = $oProperties_Ctrls.properties.FontSize.value
	If $new_data = "" Or $new_data = "8.5" Then
		$oProperties_Ctrls.properties.FontSize.value = 8.5
		$new_data = -1
	ElseIf Not StringRegExp($new_data, '^[1-9]\d*(\.\d+)?$') Then
		$oProperties_Ctrls.properties.FontSize.value = ""
		Return -1
	EndIf

	Local Const $sel_count = $oSelected.count

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls.Items()
				If $oCtrl.Locked Then ContinueLoop

				;update the selected control
				If $oCtrl.Type = "IP" Then
					_GUICtrlIpAddress_SetFont($oCtrl.Hwnd, "Arial", $new_data)
				Else
					GUICtrlSetFont($oCtrl.Hwnd, $new_data, $oCtrl.FontWeight)
				EndIf

				;update the selected property
				$oCtrl.FontSize = $new_data

			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_FontSize

Func _ctrl_change_FontWeight()
	Local $new_data = $oProperties_Ctrls.properties.FontWeight.value

	Switch $new_data
		Case "Thin"
			$new_data = 100
		Case "Extra Light"
			$new_data = 200
		Case "Light"
			$new_data = 300
		Case "Normal"
			$new_data = 400
		Case "Medium"
			$new_data = 500
		Case "Semi Bold"
			$new_data = 600
		Case "Bold"
			$new_data = 700
		Case "Extra Bold"
			$new_data = 800
		Case "Heavy"
			$new_data = 900
		Case Else
			$new_data = 400
	EndSwitch

	Local Const $sel_count = $oSelected.count


	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls.Items()
				If $oCtrl.Locked Then ContinueLoop

				;update the selected control
				If $oCtrl.Type = "IP" Then
					_GUICtrlIpAddress_SetFont($oCtrl.Hwnd, "Arial", $oCtrl.FontSize, $new_data)
				Else
					GUICtrlSetFont($oCtrl.Hwnd, $oCtrl.FontSize, $new_data)
				EndIf

				;update the selected property
				$oCtrl.FontWeight = $new_data

			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_FontWeight

Func _ctrl_change_FontName()
	Local $new_data = $oProperties_Ctrls.properties.FontName.value

	Local Const $sel_count = $oSelected.count

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls.Items()
				If $oCtrl.Locked Then ContinueLoop

				;update the selected control
				If $oCtrl.Type = "IP" Then
					_GUICtrlIpAddress_SetFont($oCtrl.Hwnd, $new_data, $oCtrl.FontSize, $oCtrl.FontWeight)
				Else
					GUICtrlSetFont($oCtrl.Hwnd, $oCtrl.FontSize, $oCtrl.FontWeight, $GUI_FONTNORMAL, $new_data)
				EndIf

				;update the selected property
				$oCtrl.FontName = $new_data

			Next
	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_ctrl_change_FontName


Func _ctrl_pick_Color()
	Local $color = _ChooseColor(2)

	If $color = -1 Then Return 0
	$oProperties_Ctrls.properties.Color.value = $color

	_ctrl_change_Color()
EndFunc   ;==>_ctrl_pick_Color


Func _ctrl_change_Color()
	Local $colorInput = $oProperties_Ctrls.properties.Color.value
	Local $newColor = $colorInput
	If $colorInput = "" Then
		$colorInput = -1
		$oProperties_Ctrls.properties.Color.value = -1
	Else
		$colorInput = Dec(StringReplace($colorInput, "0x", ""))
	EndIf

	Local Const $sel_count = $oSelected.count

	;update the undo action stack
	Local $oAction = _objAction()
	$oAction.action = $action_changeColor
	$oAction.ctrls = $oSelected.ctrls.Items()
	Local $aParams[$oSelected.ctrls.Count]
	Local $aParam[2]
	For $i = 0 To UBound($oAction.ctrls) - 1
		$aParam[0] = $oAction.ctrls[$i].Color
		$aParam[1] = $colorInput
		$aParams[$i] = $aParam
	Next
	$oAction.parameters = $aParams
	_updateActionStacks($oAction)

	Switch $sel_count >= 1
		Case True
			For $oCtrl In $oSelected.ctrls.Items()
				If $oCtrl.Locked Then ContinueLoop

				;convert string to color then apply
				Switch $oCtrl.Type
					Case "Label", "Edit", "Input"
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

					Case "Graphic"
						$oCtrl.Color = $colorInput
						_updateGraphic($oCtrl)

					Case Else
						Return 0
				EndSwitch
			Next
	EndSwitch

	_refreshGenerateCode()
	$oMain.hasChanged = True
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

	For $oCtrl In $oCtrls.ctrls.Items()

		_delete_ctrl($oCtrl, True)

	Next

	_formObjectExplorer_updateList()

;~ 	$oCtrls.removeAll()

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

	_updateActionStacks()
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

;------------------------------------------------------------------------------
; Title...........: ScreenToClient
; Description.....: Convert the screen (desktop) coordinates to client (GUI) coordinates.
;					taken from the helpfile
;					updated by kurtykurtyboy
;------------------------------------------------------------------------------
Func ScreenToClient(ByRef $x, ByRef $y)
	Local $tPoint = DllStructCreate("int X;int Y")
	DllStructSetData($tPoint, "X", $x)
	DllStructSetData($tPoint, "Y", $y)
	_WinAPI_ScreenToClient($hGUI, $tPoint)
	$x = DllStructGetData($tPoint, "X")
	$y = DllStructGetData($tPoint, "Y")
EndFunc   ;==>ScreenToClient


#Region ; mouse management
Func _mouse_snap_pos()
	Return _snap_to_grid(MouseGetPos())
EndFunc   ;==>_mouse_snap_pos

Func _snap_to_grid($coords)
	If $oOptions.snapGrid Then
		$coords[0] = $oOptions.gridSize * Int($coords[0] / $oOptions.gridSize - 0.5) + $oOptions.gridSize

		$coords[1] = $oOptions.gridSize * Int($coords[1] / $oOptions.gridSize - 0.5) + $oOptions.gridSize
	EndIf

	Return $coords
EndFunc   ;==>_snap_to_grid

Func _set_current_mouse_pos($noSnap = False)
	Local $mouse_snap_pos
	If $noSnap Then
		$mouse_snap_pos = MouseGetPos()
	Else
		$mouse_snap_pos = _mouse_snap_pos()
	EndIf

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

;~ 	_showProperties($props_Main)

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

Func _CtrlInRect(Const $x, Const $y, Const $w, Const $h, Const $left, Const $top, Const $width, Const $height)
	; Author.........: kurtykurtyboy

	If $x > $left And $y > $top And $x + $w < $left + $width And $y + $h < $top + $height Then
		Return True
	Else
		Return False
	EndIf

EndFunc   ;==>_CtrlInRect

Func _CtrlCrossRect(Const $x, Const $y, Const $w, Const $h, Const $left, Const $top, Const $width, Const $height)
	; Author.........: kurtykurtyboy

	If ($left < ($x + $w) And $top < ($y + $h)) And (($left + $width) > $x And ($top + $height) > $y) Then
		Return True
	Else
		Return False
	EndIf

EndFunc   ;==>_CtrlCrossRect

Func _rect_from_points(Const $a1, Const $a2, Const $b1, Const $b2)
	Local $oRect = _objCreateRect()

	$oRect.Left = ($a1 < $b1) ? $a1 : $b1

	$oRect.Top = ($a2 < $b2) ? $a2 : $b2

	$oRect.Width = ($b1 > $a1) ? ($b1 - $oRect.Left) : ($a1 - $oRect.Left)

	$oRect.Height = ($b2 > $a2) ? ($b2 - $oRect.Top) : ($a2 - $oRect.Top)

	Return $oRect
EndFunc   ;==>_rect_from_points
#EndRegion ; rectangle management

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
; Title...........: _onHelpItem
; Description.....: Open the help file
;------------------------------------------------------------------------------
Func _onHelpItem()
	ShellExecute(@ScriptDir & "\storage\GuiBuilderPlus.chm")
EndFunc   ;==>_onHelpItem

;------------------------------------------------------------------------------
; Title...........: _onGithubItem
; Description.....: Open browser and go to GitHub page
;------------------------------------------------------------------------------
Func _onGithubItem()
	ShellExecute('https://github.com/KurtisLiggett/GuiBuilderPlus')
EndFunc   ;==>_onGithubItem

;------------------------------------------------------------------------------
; Title...........: _menu_about
; Description.....: Display popup with program description
;------------------------------------------------------------------------------
Func _menu_about()
	_formAbout()
EndFunc   ;==>_menu_about

;------------------------------------------------------------------------------
; Title...........: _onContextMenu_Event
; Description.....: Call the context menu event function
; Events..........: Context menu item
;------------------------------------------------------------------------------
Func _onContextMenu_Event()
	_formEventCode()
EndFunc   ;==>_onContextMenu_Event


;------------------------------------------------------------------------------
; Title...........: _onMenuRecent
; Description.....: Call the menu event function
; Events..........: menu item
;------------------------------------------------------------------------------
Func _onMenuRecent()
	Local $sText = GUICtrlRead(@GUI_CtrlId, $GUI_READ_EXTENDED)
	Local $sFilename = StringRegExpReplace($sText, '^\d+ ', "", 1)

	_load_gui_definition($sFilename)
EndFunc   ;==>_onMenuRecent

#EndRegion ; menu bar items


Func _addToRecentFiles($sFilename)
	;delete previous menu items and separator + exit
	For $i = 0 To UBound($aMenuRecentList) - 1
		If $aMenuRecentList[$i] <> 0 Then
			GUICtrlDelete($aMenuRecentList[$i])
		EndIf
	Next

	;rearrange the recent files list
	Local $aRecentFiles = IniReadSection($sIniPath, "Recent")
	If Not @error Then
		Local $aNewList[$aRecentFiles[0][0] + 1][2]
		$aNewList[0][0] = $aRecentFiles[0][0]
		$aNewList[1][0] = 1
		$aNewList[1][1] = $sFilename
		Local $index = 2
		Local $exists = False

		For $i = 1 To $aRecentFiles[0][0]
			If $index > $aRecentFiles[0][0] Then
				If $aRecentFiles[0][0] < 10 And $aRecentFiles[$i][1] <> $sFilename Then
					ReDim $aNewList[$aNewList[0][0] + 2][2]
					$aNewList[0][0] = $aRecentFiles[0][0] + 1
					$aNewList[$index][0] = $index
					$aNewList[$index][1] = $aRecentFiles[$i][1]
				EndIf
				ExitLoop
			EndIf
			If $aRecentFiles[$i][1] <> $sFilename Then
				$aNewList[$index][0] = $index
				$aNewList[$index][1] = $aRecentFiles[$i][1]
				$index += 1
			EndIf
		Next
	Else
		Local $aNewList[2][2]
		$aNewList[0][0] = 1
		$aNewList[1][0] = 1
		$aNewList[1][1] = $sFilename
	EndIf

	;build menu from new list
	For $i = 1 To 10
		If $i > $aNewList[0][0] Then
			$aMenuRecentList[$i - 1] = 0
		Else
			$aMenuRecentList[$i - 1] = GUICtrlCreateMenuItem($i & " " & $aNewList[$i][1], $menu_file)
			GUICtrlSetOnEvent(-1, "_onMenuRecent")
		EndIf
	Next
	$aMenuRecentList[10] = GUICtrlCreateMenuItem("", $menu_file)
	$aMenuRecentList[11] = GUICtrlCreateMenuItem("Exit", $menu_file)
	GUICtrlSetOnEvent(-1, "_onExit")

	;write list to ini file
	IniWriteSection($sIniPath, "Recent", $aNewList)
EndFunc   ;==>_addToRecentFiles


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
;~ 			$currentWinPos = WinGetClientSize($hFormGenerateCode)
;~ 			IniWrite($sIniPath, "Settings", "sizeGenerateCode", $currentWinPos[0] & "," & $currentWinPos[1])
		EndIf

		If IsHWnd($hFormObjectExplorer) Then
			$currentWinPos = WinGetPos($hFormObjectExplorer)
			IniWrite($sIniPath, "Settings", "posObjectExplorer", $currentWinPos[0] & "," & $currentWinPos[1])
;~ 			$currentWinPos = WinGetClientSize($hFormObjectExplorer)
;~ 			IniWrite($sIniPath, "Settings", "sizeObjectExplorer", $currentWinPos[0] & "," & $currentWinPos[1])
		EndIf
	EndIf
EndFunc   ;==>_saveWinPositions


Func _setIconFromResource($ctrlID, $sIconName, $iIcon)
	If @Compiled = 1 Then
		GUICtrlSetImage($ctrlID, @ScriptFullPath, $iIcon)
	Else
		GUICtrlSetImage($ctrlID, $iconset & "\" & $sIconName)
	EndIf
EndFunc   ;==>_setIconFromResource

Func GetIconData($iconSel)
	Local $icondData
	Switch $iconSel
		Case 0
			$icondData = '' & _
					'iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAMAAABg3Am1AAAByFBMVEX///8AAP8A' & _
					'AAAACwAAqgAABwD+/v8DA//5+f/09PTx8fHCwsJeYF7q6uri4uJrbWtZWVm2tv+m' & _
					'pqaOjo6C1YJoamixsf+Z3ZkOrw729v+trf/8/f3X8tdmZmYCAgLU1P/R0f+hof8u' & _
					'Lv8hIf8TE/8PD//39/cGBgb7+//z8//t7f/X1//Hx/92dv9OTv/5+fnc3NxjY2NR' & _
					'UVFKSkobGxsKCgrv7//r6//e3v/a2v/Ly/+lpf+Jif95ef9YWP86Ov8zM/8pKf8e' & _
					'Hv8MDP8KCv8HB/+8vLwuLi7n5//i4v+/v/+pqf+dnf9wcP9jY/9LS/8lJf8bG/8W' & _
					'Fv/m5ubU79TOzs6RkZGLi4uIiIhBQUE+Pj4SEhLOzv+4uP+Tk/+Ojv99ff9zc/9n' & _
					'Z/9cXP9RUf83N/8ZGf/Y2NjV1dXR0dHIyMi3t7etra2hoaGampqVlZWEhIRycnJp' & _
					'aWlVVVU4ODg1NTUiIiIWFhYAoA8IqwuGhv+EhP9AQP8NDf9fYfzs7OwADezg7uDg' & _
					'4ODe3t7O6M7A2sA9bbe1tbUAM7Oy5bKysrIAOKpSlpkARJkAU4M0h4J/1H9Wx1ZO' & _
					'xE5BwEE1vDUAijAnJycApwXm4IuGAAADT0lEQVRIx72W11rbQBCFR46QRAlghyhg' & _
					'E2yKwdh003sJmN57SWih9xIgvfdeXzdnJQtJxjZ3/De738452pnRymu6CjpuMkoo' & _
					'KrmKaJsYN66BmHjSSXPO2e3W2UrSiYthqoQwBqG7L0vkVAb75bRLDGl3szkTOQ2d' & _
					'UQxC5oomvNOmbdP2UAo1xABmqBpQFEOLdT5JEDzV8kKLspDlYwaGaoi9zigmVysH' & _
					'HlsF0qltFNkmMgmKKI4MFLgRyrZSCK77WBbr6AJOpm/MV5s+ZhufGN9adRBwvP30' & _
					'nBNlCsHLutPAshE6DissKjMJHQ5K5/mvyMpHZhqhLyQwdmQxcrQGwzcRlUtkRIa+' & _
					'iD1/N4/J8gL+Q39AmZ6M8nzKPMKPyIBnkONWvJhMMs2DnVi1fTZ/hsXyBgZPE95M' & _
					'J+nU4QmsEVtMn5SrB8am817DQC6RZazThByR0PUZ6PfIiFCSzgy0hFOSRho12CAT' & _
					'4z70Zbr4e6oCz5+lpp6dnv6xk8Y9ZJiP1492Vozohh+8iX9PSaMILcKwgw0OSGf0' & _
					'FiOF539i+PzlfStpDHFcPYYyGOIpFLUGmkPaVdoHhrkVYzkyckQydEJUQCrVmDvR' & _
					'dmxwTJEMAhqrVe2CoYuoxNCjzWQNW9BAOeik2bAOQzKpJFs08kaDBjcM5pTWDDuU' & _
					'Ws558ev3By0lc9EvEZ0mlUSbwhSWYkmhy1A0tSptzcVJKycTt3WDFQav4cUNYPiL' & _
					'8KtIhgZ8v+ajoSY+EcmQxXH9RIaqe4k+sm+hOLyhFhJ76PEuLkd8MryhEcdb0gM9' & _
					'6vneZX2PD2eYRVMbSMeDn7jhKnIcQ1Dx7qJBwo/Tk+DR05s24KGSEygyElYFYjji' & _
					'A0FDIccab2IJS30CraMMWAIHk+N7CeocXehFsFkiE5WDWFwQaMRvMZFRCj0KcNdQ' & _
					'CL4cOJYrSdicyjiXz5RukMTyEa10gVrmGJKR/ohtv2xq2l86sVGM5WYst/eQgbhE' & _
					'Ri45sznQJBuSFQqWRay5reRQRM/MF4q3iGMM92e6KiUp32fvwyNAc41+oYRcWT2t' & _
					'XJD2dm3mrpeiXootnInhee9l125BYXPw6WLLolWKcu3qSDXdstztzI9wsXckMS77' & _
					'66CItukK+A86y3aCrkROIwAAAABJRU5ErkJggg=='

	EndSwitch

	Return _Base64Decode($icondData)
EndFunc   ;==>GetIconData

Func _Base64Decode($input_string)

	Local $struct = DllStructCreate("int")

	$a_Call = DllCall("Crypt32.dll", "int", "CryptStringToBinary", _
			"str", $input_string, _
			"int", 0, _
			"int", 1, _
			"ptr", 0, _
			"ptr", DllStructGetPtr($struct, 1), _
			"ptr", 0, _
			"ptr", 0)

	If @error Or Not $a_Call[0] Then
		Return SetError(1, 0, "") ; error calculating the length of the buffer needed
	EndIf

	Local $a = DllStructCreate("byte[" & DllStructGetData($struct, 1) & "]")

	$a_Call = DllCall("Crypt32.dll", "int", "CryptStringToBinary", _
			"str", $input_string, _
			"int", 0, _
			"int", 1, _
			"ptr", DllStructGetPtr($a), _
			"ptr", DllStructGetPtr($struct, 1), _
			"ptr", 0, _
			"ptr", 0)

	If @error Or Not $a_Call[0] Then
		Return SetError(2, 0, "") ; error decoding
	EndIf

	Return DllStructGetData($a, 1)

EndFunc   ;==>_Base64Decode

Func _memoryToPic($idPic, $name)
	$hBmp = _GDIPlus_BitmapCreateFromMemory(Binary($name), 1)
	_WinAPI_DeleteObject(GUICtrlSendMsg($idPic, 0x0172, 0, $hBmp))
	_WinAPI_DeleteObject($hBmp)
	Return 0
EndFunc   ;==>_memoryToPic


Func _display_selection_rect(Const $oRect)
	GUISwitch($hGUI)
	If GUICtrlGetHandle($overlay) <> -1 Then
		GUICtrlDelete($overlay)
		$overlay = -1
	EndIf
	$overlay = GUICtrlCreateGraphic($oRect.Left, $oRect.Top, $oRect.Width, $oRect.Height)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetGraphic($overlay, $GUI_GR_RECT, 0, 0, $oRect.Width, $oRect.Height)
	GUICtrlSetGraphic($overlay, $GUI_GR_REFRESH)
	GUICtrlSetGraphic($background, $GUI_GR_REFRESH)
	GUISwitch($hGUI)
EndFunc   ;==>_display_selection_rect

Func _recall_overlay()
	GUISwitch($hGUI)

	If $overlay <> -1 Then
		ConsoleWrite("delete overlay" & @CRLF)
		GUICtrlDelete($overlay)
		$overlay = -1

		$overlay = GUICtrlCreateGraphic(0, 0, 0, 0)
		GUICtrlSetState(-1, $GUI_DISABLE)
	EndIf
	GUISwitch($hGUI)
EndFunc   ;==>_recall_overlay
