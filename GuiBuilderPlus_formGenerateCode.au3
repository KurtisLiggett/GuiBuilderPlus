; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formGenerateCode.au3
; Description ...: Create the code generation popup GUI
; ===============================================================================================================================


#Region formGenerateCode
;------------------------------------------------------------------------------
; Title...........: formGenerateCode
; Description.....:	Create the code generation GUI
;------------------------------------------------------------------------------
Func _formGenerateCode()
	Local $w = 450
	Local $h = 550

	Local $currentWinPos = WinGetPos($hToolbar)
	Local $x = $currentWinPos[0] + 100
		$y = $currentWinPos[1] - 50

	Local $sPos = IniRead($sIniPath, "Settings", "posGenerateCode", $x & "," & $y)
	Local $aPos = StringSplit($sPos, ",")
	If Not @error Then
		$x = $aPos[1]
		$y = $aPos[2]
	EndIf

	;make sure not set off screen
	Local $ixCoordMin = _WinAPI_GetSystemMetrics(76)
	Local $iyCoordMin = _WinAPI_GetSystemMetrics(77)
	Local $iFullDesktopWidth = _WinAPI_GetSystemMetrics(78)
	Local $iFullDesktopHeight = _WinAPI_GetSystemMetrics(79)
	If ($x + $w) > ($ixCoordMin + $iFullDesktopWidth) Then
		$x = $iFullDesktopWidth - $w
	ElseIf $x < $ixCoordMin Then
		$x = 1
	EndIf
	If ($y + $h) > ($iyCoordMin + $iFullDesktopHeight) Then
		$y = $iFullDesktopHeight - $h
	ElseIf $y < $iyCoordMin Then
		$y = 1
	EndIf

	$hFormGenerateCode = GUICreate("Live Generated Code", $w, $h, $x, $y, $WS_SIZEBOX, -1, $hGUI)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitGenerateCode")
	Local $titleBarHeight = _WinAPI_GetSystemMetrics($SM_CYCAPTION) + 3

	GUICtrlCreateLabel("", 0, 0, $w, $h - $titleBarHeight - 32)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

	$editCodeGeneration = _GUICtrlRichEdit_Create($hFormGenerateCode, "", 10, 10, $w - 20, $h - $titleBarHeight - 53, BitOR($ES_MULTILINE, $WS_VSCROLL, $WS_HSCROLL, $ES_AUTOVSCROLL))
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
	_GUICtrlRichEdit_SetText($editCodeGeneration, _code_generation())
	_RESH_SyntaxHighlight($editCodeGeneration)


	GUICtrlCreateButton("Copy", $w - 20 - 75 * 2 - 5 * 1, $h - 27 - $titleBarHeight, 75, 22)
	GUICtrlSetOnEvent(-1, "_onCodeCopy")
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlCreateButton("Save to file", $w - 20 - 75 - 5, $h - 27 - $titleBarHeight, 75, 22)
	GUICtrlSetOnEvent(-1, "_onCodeSave")
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)

	GUISetState(@SW_SHOW, $hFormGenerateCode)
	_GUICtrlRichEdit_SetSel($editCodeGeneration, 0, -1)

	GUISwitch($hGUI)
EndFunc   ;==>_formGenerateCode
#EndRegion formGenerateCode


#Region events
;------------------------------------------------------------------------------
; Title...........: _onCodeRefresh
; Description.....: Update the generated code shown in the dialog
; Events..........: Refresh button in code generation dialog
;------------------------------------------------------------------------------
Func _onCodeRefresh()
	_GUICtrlRichEdit_SetText($editCodeGeneration, _code_generation())
	_RESH_SyntaxHighlight($editCodeGeneration)
EndFunc   ;==>_onCodeRefresh


;------------------------------------------------------------------------------
; Title...........: _onCodeSave
; Description.....: Save the code shown in the dialog to file
; Events..........: Save button in code generation dialog
;------------------------------------------------------------------------------
Func _onCodeSave()
	_copy_code_to_output(_GUICtrlRichEdit_GetText($editCodeGeneration))
EndFunc   ;==>_onCodeSave


;------------------------------------------------------------------------------
; Title...........: _onCodeCopy
; Description.....: Copy the code shown in the dialog to the clipboard
; Events..........: Copy button in code generation dialog
;------------------------------------------------------------------------------
Func _onCodeCopy()
	ClipPut(_GUICtrlRichEdit_GetText($editCodeGeneration))
EndFunc   ;==>_onCodeCopy


;------------------------------------------------------------------------------
; Title...........: _onExitGenerateCode
; Description.....: close the GUI
; Events..........: close button or menu item
;------------------------------------------------------------------------------
Func _onExitGenerateCode()
	_saveWinPositions()

	GUIDelete($hFormGenerateCode)
	GUICtrlSetState($menu_generateCode, $GUI_UNCHECKED)

	GUISwitch($hGUI)

	; save state to settings file
	IniWrite($sIniPath, "Settings", "ShowCode", 0)
EndFunc   ;==>_onExitGenerateCode
#EndRegion events


;------------------------------------------------------------------------------
; Title...........: _refreshGenerateCode
; Description.....: refresh code for the code generation popup GUI
; Called by.......: any time a control is changed
;------------------------------------------------------------------------------
Func _refreshGenerateCode()
	If IsHWnd($hFormGenerateCode) Then
		Local $iStart = _GUICtrlRichEdit_GetFirstCharPosOnLine($editCodeGeneration)
		Local $aScroll = _GUICtrlRichEdit_GetScrollPos($editCodeGeneration)

		Local $sCode = _code_generation()
		_GUICtrlRichEdit_PauseRedraw($editCodeGeneration)
		_GUICtrlRichEdit_SetSel($editCodeGeneration, 0, -1, True)
		_GUICtrlRichEdit_ReplaceText($editCodeGeneration, '')

		_GUICtrlRichEdit_SetFont($editCodeGeneration, 9, 'Courier New')

		_GUICtrlRichEdit_SetLimitOnText($editCodeGeneration, Round(StringLen($sCode) * 1.5))
		_GUICtrlRichEdit_AppendText($editCodeGeneration, $sCode)

;~ 		_GUICtrlRichEdit_SetText($editCodeGeneration, _code_generation())
		_RESH_SyntaxHighlight($editCodeGeneration)

		_GUICtrlRichEdit_GotoCharPos($editCodeGeneration, $iStart)
		_GUICtrlRichEdit_SetScrollPos($editCodeGeneration, $aScroll[0], $aScroll[1])
		_GUICtrlRichEdit_ResumeRedraw($editCodeGeneration)
	EndIf
EndFunc   ;==>_refreshGenerateCode
