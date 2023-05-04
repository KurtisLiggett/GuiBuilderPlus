; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formSettings.au3
; Description ...: Create and manage the Settings window
; ===============================================================================================================================

;------------------------------------------------------------------------------
; Title...........: _formSettings
; Description.....: Display popup window
;------------------------------------------------------------------------------
Func _formSettings()
	Local $w = 210
	Local $h = 178

	Local $aGuiPos = WinGetPos($hToolbar)
	$hSettings = GUICreate("Settings", $w, $h, $aGuiPos[0] + 50, $aGuiPos[1] + 50)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitSettings")

	$label_bg = GUICtrlCreateLabel("", 0, 0, 210, 140)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetState(-1, $GUI_DISABLE)

	$settingsChk_snapgrid = GUICtrlCreateCheckbox("Snap to grid [F3]", 10, 10, 151, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$settingsChk_pasteatmouse = GUICtrlCreateCheckbox("Paste at mouse position", 10, 32.5, 151, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$settingsChk_guifunction = GUICtrlCreateCheckbox("Create GUI in a function", 10, 55, 151, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$settingsChk_eventmode = GUICtrlCreateCheckbox("Enable OnEvent mode", 10, 77.5, 151, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$label_gridsize = GUICtrlCreateLabel("Grid size:", 10, 103, 55, 21)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$settingsInput_gridsize = GUICtrlCreateInput($oOptions.gridSize, 60, 100, 71, 21, $ES_NUMBER)

	If $oOptions.snapGrid Then
		GUICtrlSetState($settingsChk_snapgrid, $GUI_CHECKED)
	EndIf
	If $oOptions.pasteAtMouse Then
		GUICtrlSetState($settingsChk_pasteatmouse, $GUI_CHECKED)
	EndIf
	If $oOptions.guiInFunction Then
		GUICtrlSetState($settingsChk_guifunction, $GUI_CHECKED)
	EndIf
	If $oOptions.eventMode Then
		GUICtrlSetState($settingsChk_eventmode, $GUI_CHECKED)
	EndIf

	$line = GUICtrlCreateLabel("", 0, 139, 211, 1)
	GUICtrlSetBkColor(-1, 0x333333)
	GUICtrlSetState(-1, $GUI_DISABLE)

	$button_save = GUICtrlCreateButton("Save", 150, 150, 51, 21)
	GUICtrlSetOnEvent(-1, "_onSaveSettings")

	$button_cancel = GUICtrlCreateButton("Cancel", 95, 149, 51, 21)
	GUICtrlSetOnEvent(-1, "_onExitSettings")

	GUISetState(@SW_DISABLE, $hGUI)
	GUISetState(@SW_SHOW, $hSettings)
EndFunc   ;==>_formSettings

Func _onSaveSettings()
	Local $bSnapgrid = (BitAND(GUICtrlRead($settingsChk_snapgrid), $GUI_CHECKED) = $GUI_CHECKED)
	Local $bPasteatmouse = (BitAND(GUICtrlRead($settingsChk_pasteatmouse), $GUI_CHECKED) = $GUI_CHECKED)
	Local $bGuifunction = (BitAND(GUICtrlRead($settingsChk_guifunction), $GUI_CHECKED) = $GUI_CHECKED)
	Local $bEventmode = (BitAND(GUICtrlRead($settingsChk_eventmode), $GUI_CHECKED) = $GUI_CHECKED)
	Local $iGridsize = GUICtrlRead($settingsInput_gridsize)

	If $iGridsize < 2 Then
		$bStatusNewMessage = True
		_GUICtrlStatusBar_SetText($hStatusbar, "Grid size too small!")
		Return 0
	EndIf

	GUIDelete($hSettings)
	GUISetState(@SW_ENABLE, $hGUI)
	GUISwitch($hGUI)

	;snap grid
	If $oOptions.snapGrid <> $bSnapgrid Then
		_gridsnap($bSnapgrid)
	EndIf

	;paste at mouse
	If $oOptions.pasteAtMouse <> $bPasteatmouse Then
		If $bPasteatmouse Then
			IniWrite($sIniPath, "Settings", "PastePos", 1)
		Else
			IniWrite($sIniPath, "Settings", "PastePos", 0)
		EndIf
		$oOptions.pasteAtMouse = $bPasteatmouse
	EndIf

	;gui in function
	If $oOptions.guiInFunction <> $bGuifunction Then
		If $bGuifunction Then
			GUICtrlSetState($check_guiFunc, $GUI_CHECKED)
			IniWrite($sIniPath, "Settings", "GuiInFunction", 1)
		Else
			GUICtrlSetState($check_guiFunc, $GUI_UNCHECKED)
			IniWrite($sIniPath, "Settings", "GuiInFunction", 0)
		EndIf
		$oOptions.guiInFunction = $bGuifunction
		_refreshGenerateCode()
	EndIf

	;event mode
	If $oOptions.eventMode <> $bEventmode Then
		_set_onEvent_mode($bEventmode)
	EndIf

	;grid size
	If $oOptions.gridSize <> $iGridsize Then
		$oOptions.gridSize = $iGridsize
		_showgrid(True)
		IniWrite($sIniPath, "Settings", "GridSize", $iGridsize)
	EndIf


EndFunc   ;==>_onSaveSettings

Func _onExitSettings()
	GUIDelete($hSettings)
	GUISetState(@SW_ENABLE, $hGUI)
	GUISwitch($hGUI)
EndFunc   ;==>_onExitSettings


Func _onShowGrid()
	_showgrid()
EndFunc   ;==>_onShowGrid
;------------------------------------------------------------------------------
; Title...........: _showgrid
; Description.....: Show (or hide) the background grid and update INI file
; Events..........: settings menu item select
;------------------------------------------------------------------------------
Func _showgrid($state = Default)
	Local $message = "Grid: "
	Local $newState
	If $state = Default Then
		$newState = Not $oOptions.showGrid
	Else
		$newState = $state
	EndIf

	If Not $newState Then
		GUICtrlSetState($menu_show_grid, $GUI_UNCHECKED)
		_hide_grid($background)
		IniWrite($sIniPath, "Settings", "ShowGrid", 0)
		$message &= "OFF"
	Else
		GUICtrlSetState($menu_show_grid, $GUI_CHECKED)
		_hide_grid($background)
		_show_grid($background, $oMain.Width, $oMain.Height)
		IniWrite($sIniPath, "Settings", "ShowGrid", 1)
		$message &= "ON"
	EndIf

	$oOptions.showGrid = $newState

	If $state = Default Then
		$bStatusNewMessage = True
		_GUICtrlStatusBar_SetText($hStatusbar, $message)
	EndIf
EndFunc   ;==>_showgrid


;------------------------------------------------------------------------------
; Title...........: _pastepos
; Description.....: Update INI setting for paste at mouse position
; Events..........: settings menu item select
;------------------------------------------------------------------------------
Func _pastepos()
	If $oOptions.pasteAtMouse Then
		IniWrite($sIniPath, "Settings", "PastePos", 0)
	Else
		IniWrite($sIniPath, "Settings", "PastePos", 1)
	EndIf

	$oOptions.pasteAtMouse = Not $oOptions.pasteAtMouse
EndFunc   ;==>_pastepos


;------------------------------------------------------------------------------
; Title...........: _gridsnap
; Description.....: Update INI setting for grid snap
; Events..........: settings menu item select
;------------------------------------------------------------------------------
Func _onGridsnap()
	_gridsnap()
EndFunc   ;==>_onGridsnap
Func _gridsnap($state = Default)
	Local $message = "Grid snap: "
	Local $newState
	If $state = Default Then
		$newState = Not $oOptions.snapGrid
	Else
		$newState = $state
	EndIf

	If Not $newState Then
		IniWrite($sIniPath, "Settings", "GridSnap", 0)
		$message &= "OFF"
	Else
		IniWrite($sIniPath, "Settings", "GridSnap", 1)
		$message &= "ON"
	EndIf

	$oOptions.snapGrid = $newState

	If $state = Default Then
		$bStatusNewMessage = True
		_GUICtrlStatusBar_SetText($hStatusbar, $message)
	EndIf
EndFunc   ;==>_gridsnap

;------------------------------------------------------------------------------
; Title...........: _menu_onEvent_mode
; Description.....: Update INI setting
; Events..........: settings menu item
;------------------------------------------------------------------------------
Func _menu_onEvent_mode()
	_set_onEvent_mode()
EndFunc   ;==>_menu_onEvent_mode

Func _radio_onMsgMode()
	_set_onEvent_mode(0)
EndFunc   ;==>_radio_onMsgMode

Func _radio_onEventMode()
	_set_onEvent_mode(1)
EndFunc   ;==>_radio_onEventMode

Func _set_onEvent_mode($iState = Default)
	Local $newState, $IniState

	If $iState = Default Then
		Switch $oOptions.eventMode
			Case True
				$newState = $GUI_UNCHECKED
				$IniState = 0
				$oOptions.eventMode = False

			Case False
				$newState = $GUI_CHECKED
				$IniState = 1
				$oOptions.eventMode = True
		EndSwitch
	ElseIf $iState = 0 Then
		$newState = $GUI_UNCHECKED
		$IniState = 0
		$oOptions.eventMode = False
	ElseIf $iState = 1 Then
		$newState = $GUI_CHECKED
		$IniState = 1
		$oOptions.eventMode = True
	EndIf
	GUICtrlSetState($radio_eventMode, $newState)
	If $newState = $GUI_UNCHECKED Then
		GUICtrlSetState($radio_msgMode, $GUI_CHECKED)
	EndIf
	IniWrite($sIniPath, "Settings", "OnEventMode", $IniState)
	_refreshGenerateCode()
EndFunc   ;==>_set_onEvent_mode


;------------------------------------------------------------------------------
; Title...........: _menu_gui_function
; Description.....: Update INI setting
; Events..........: settings menu item
;------------------------------------------------------------------------------
Func _menu_gui_function()
	Switch $oOptions.guiInFunction
		Case True
			GUICtrlSetState($check_guiFunc, $GUI_UNCHECKED)

			IniWrite($sIniPath, "Settings", "GuiInFunction", 0)

			$oOptions.guiInFunction = False


		Case False
			GUICtrlSetState($check_guiFunc, $GUI_CHECKED)

			IniWrite($sIniPath, "Settings", "GuiInFunction", 1)

			$oOptions.guiInFunction = True

	EndSwitch

	_refreshGenerateCode()
EndFunc   ;==>_menu_gui_function
