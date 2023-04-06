; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formSettings.au3
; Description ...: Create and manage the Settings window
; ===============================================================================================================================

;------------------------------------------------------------------------------
; Title...........: _formSettings
; Description.....: Display popup window
;------------------------------------------------------------------------------
Func _formSettings()
	$hSettings = GUICreate("Settings", 210, 178, 763, 361)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitSettings")

	$label_bg = GUICtrlCreateLabel("", 0, 0, 210, 140)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetState(-1, $GUI_DISABLE)

	$settingsChk_snapgrid = GUICtrlCreateCheckbox("Snap to grid", 10, 10, 151, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$settingsChk_pasteatmouse = GUICtrlCreateCheckbox("Paste at mouse position", 10, 32.5, 151, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$settingsChk_guifunction = GUICtrlCreateCheckbox("Create GUI in a function", 10, 55, 151, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$settingsChk_eventmode = GUICtrlCreateCheckbox("Enable OnEvent mode", 10, 77.5, 151, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$label_gridsize = GUICtrlCreateLabel("Grid size:", 10, 103, 141, 21)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$settingsInput_gridsize = GUICtrlCreateInput("", 60, 100, 71, 21)

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
	GUIDelete($hSettings)
	GUISetState(@SW_ENABLE, $hGUI)
	GUISwitch($hGUI)
EndFunc   ;==>_onSaveSettings

Func _onExitSettings()
	GUIDelete($hSettings)
	GUISetState(@SW_ENABLE, $hGUI)
	GUISwitch($hGUI)
EndFunc   ;==>_onExitSettings
