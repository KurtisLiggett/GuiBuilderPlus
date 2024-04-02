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
	Local $h = 575

	Local $currentWinPos = WinGetPos($hToolbar)
	Local $x = $currentWinPos[0] + 100
	$y = $currentWinPos[1] - 50

	Local $sPos = IniRead($sIniPath, "Settings", "posGenerateCode", $x & "," & $y)
	Local $aPos = StringSplit($sPos, ",")
	If Not @error Then
		$x = $aPos[1]
		$y = $aPos[2]
	EndIf

	$sPos = IniRead($sIniPath, "Settings", "sizeGenerateCode", $w & "," & $h)
	$aPos = StringSplit($sPos, ",")
	If Not @error Then
		$w = $aPos[1]
		$h = $aPos[2]
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

	$hFormGenerateCode = GUICreate("Code Viewer", $w, $h, $x, $y, $WS_SIZEBOX, -1, $hToolbar)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitGenerateCode")

	If Not @Compiled Then
		GUISetIcon(@ScriptDir & '\resources\icons\icon.ico')
	EndIf

	Local $titleBarHeight = _WinAPI_GetSystemMetrics($SM_CYCAPTION) + 3

	GUICtrlCreateLabel("", 0, 0, $w, 1)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetBkColor(-1, 0xCCCCCC)
	GUICtrlSetResizing(-1, $GUI_DOCKTOP + $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT)

	$editCodeGeneration = Sci_CreateEditor($hFormGenerateCode, 0, 2, $w, $h - $titleBarHeight - 62)
	_sci_SetData($editCodeGeneration, _code_generation())

	GUICtrlCreateLabel("", 0, $h - $titleBarHeight - 59, $w, 1)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetBkColor(-1, 0xCCCCCC)
	GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM + $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT)


	GUICtrlCreateButton("Copy GUI Region", $w - 15 - 75 * 2 - 5, $h - 50 - $titleBarHeight, 100, 22)
	GUICtrlSetOnEvent(-1, "_onCodeCopyGuiRegion")
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlCreateButton("Copy", $w - 15 - 75 * 2 - 5, $h - 27 - $titleBarHeight, 75, 22)
	GUICtrlSetOnEvent(-1, "_onCodeCopy")
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlCreateButton("Save to file", $w - 15 - 75, $h - 27 - $titleBarHeight, 75, 22)
	GUICtrlSetOnEvent(-1, "_onCodeSave")
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)

	$radio_msgMode = GUICtrlCreateRadio("Msg Mode", 10, $h - 27 - $titleBarHeight - 25, 75, 22)
	GUICtrlSetOnEvent(-1, "_radio_onMsgMode")
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
	$radio_eventMode = GUICtrlCreateRadio("OnEvent Mode", 10 + 75 + 5, $h - 27 - $titleBarHeight - 25, 100, 22)
	GUICtrlSetOnEvent(-1, "_radio_onEventMode")
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)

	$check_guiFunc = GUICtrlCreateCheckbox("Create GUI in a function", 10, $h - 27 - $titleBarHeight, 150, 22)
	GUICtrlSetOnEvent(-1, "_menu_gui_function")
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)

	If $oOptions.eventMode Then
		GUICtrlSetState($radio_eventMode, $GUI_CHECKED)
	Else
		GUICtrlSetState($radio_msgMode, $GUI_CHECKED)
	EndIf

	If $oOptions.guiInFunction Then
		GUICtrlSetState($check_guiFunc, $GUI_CHECKED)
	Else
		GUICtrlSetState($check_guiFunc, $GUI_UNCHECKED)
	EndIf

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
	_sci_SetData($editCodeGeneration, _code_generation())
EndFunc   ;==>_onCodeRefresh


;------------------------------------------------------------------------------
; Title...........: _onCodeSave
; Description.....: Save the code shown in the dialog to file
; Events..........: Save button in code generation dialog
;------------------------------------------------------------------------------
Func _onCodeSave()
	_copy_code_to_output(Sci_GetLines($editCodeGeneration))
EndFunc   ;==>_onCodeSave


;------------------------------------------------------------------------------
; Title...........: _onCodeCopy
; Description.....: Copy the code shown in the dialog to the clipboard
; Events..........: Copy button in code generation dialog
;------------------------------------------------------------------------------
Func _onCodeCopy()
	ClipPut(Sci_GetLines($editCodeGeneration))
	$bStatusNewMessage = True
	_GUICtrlStatusBar_SetText($hStatusbar, "Code copied to the clipboard")
EndFunc   ;==>_onCodeCopy

;------------------------------------------------------------------------------
; Title...........: _onCodeCopyGuiRegion
; Description.....: Copy only the code in the GUI region
; Events..........: Copy button in code generation dialog
;------------------------------------------------------------------------------
Func _onCodeCopyGuiRegion()
	Local $code = Sci_GetLines($editCodeGeneration)
	Local $aCodeLines = StringSplit($code, @CRLF, $STR_ENTIRESPLIT)

	Local $startFlag, $sNewCode
	For $i=1 to $aCodeLines[0]
		$line = $aCodeLines[$i]

		If StringInStr($line, "#Region (=== GUI generated by GuiBuilderPlus") Then
			$startFlag = True
			$sNewCode = $line
		ElseIf $startFlag And StringInStr($line, "#EndRegion (=== GUI generated by GuiBuilderPlus") Then
			$sNewCode &= @CRLF & $line
			$sNewCode &= @CRLF
			ClipPut($sNewCode)
			$bStatusNewMessage = True
			_GUICtrlStatusBar_SetText($hStatusbar, "Region copied to the clipboard")
			Return 0
		ElseIf $startFlag Then
			$sNewCode &= @CRLF & $line
		EndIf
	Next

	ClipPut("")
	$bStatusNewMessage = True
	_GUICtrlStatusBar_SetText($hStatusbar, "Copy failed - check formatting")
	Return 1
EndFunc   ;==>_onCodeCopyGuiRegion



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

	; close the DLL
	MemoryDllClose($hSciLexerDll)
EndFunc   ;==>_onExitGenerateCode
#EndRegion events


;------------------------------------------------------------------------------
; Title...........: _refreshGenerateCode
; Description.....: refresh code for the code generation popup GUI
; Called by.......: any time a control is changed
;------------------------------------------------------------------------------
Func _refreshGenerateCode()
	If IsHWnd($hFormGenerateCode) Then
		_sci_SetData($editCodeGeneration, _code_generation())
	EndIf
EndFunc   ;==>_refreshGenerateCode

Func _sci_SetData($iCtrl, $sData)
	Sci_DelLines($iCtrl)
	Sci_AddLines($iCtrl, $sData, 0)
	Sci_ClearSelections($editCodeGeneration)
EndFunc   ;==>LoadFile