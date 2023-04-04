; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formAbout.au3
; Description ...: Create and manage the About window
; ===============================================================================================================================

;------------------------------------------------------------------------------
; Title...........: _formAbout
; Description.....: Display popup window
;------------------------------------------------------------------------------
Func _formAbout()
	$w = 350
	$h = 265

	$hAbout = GUICreate("About " & $oMain.AppName, $w, $h, Default, Default, $WS_CAPTION, -1, $hGUI)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitAbout")

	; top section

	GUICtrlCreateLabel("", 0, 0, $w, $h - 32)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateLabel("", 0, $h - 32, $w, 1)
	GUICtrlSetBkColor(-1, 0x000000)

	Local $pic = GUICtrlCreatePic("", 10, 10, 48, 48)
	_memoryToPic($pic, GetIconData(0))

	GUICtrlCreateLabel($oMain.AppName, 70, 10, $w - 15)
	GUICtrlSetFont(-1, 13, 800)

	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlCreateLabel("Version:", 60, 30, 60, -1, $SS_RIGHT)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlCreateLabel($oMain.AppVersion, 125, 30, 65, -1)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	GUICtrlCreateLabel("License:", 60, 46, 60, -1, $SS_RIGHT)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlCreateLabel("GNU GPL v3", 125, 46, 65, -1)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	GUICtrlCreateLabel("", 0, 75, $w, 1)
	GUICtrlSetBkColor(-1, 0x000000)

	$desc = "GuiBuilderPlus is a small, easy to use GUI designer for AutoIt." & @CRLF & @CRLF & _
			"Originally created as AutoBuilder by the user CyberSlug," & @CRLF & _
			"enhanced as GuiBuilder by TheSaint," & @CRLF & _
			"and further enhanced and expanded as GuiBuilderNxt by jaberwacky," & @CRLF & _
			"with additional modifications by kurtykurtyboy as GuiBuilderPlus," & @CRLF & @CRLF & _
			"GuiBuilderPlus is a continuation of the great work started by others," & @CRLF & _
			"with a focus on increased stability and usability followed by new features."
	GUICtrlCreateLabel($desc, 10, 85, $w - 16, 135)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	; bottom section

	$bt_AboutOk = GUICtrlCreateButton("OK", $w - 55, $h - 27, 50, 22)
	GUICtrlSetOnEvent(-1, "_onExitAbout")

	GUISetState(@SW_DISABLE, $hGUI)
	GUISetState(@SW_SHOW, $hAbout)

EndFunc   ;==>_formAbout

Func _onExitAbout()
	GUIDelete($hAbout)
	GUISetState(@SW_ENABLE, $hGUI)
	GUISwitch($hGUI)
EndFunc   ;==>_onExitAbout
