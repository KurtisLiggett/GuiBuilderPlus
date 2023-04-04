#Region ; *** Dynamically added Include files ***
#include <GuiRichEdit.au3>                                   ; added:04/03/23 22:31:21
#EndRegion ; *** Dynamically added Include files ***
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

	$hFormGenerateCode = GUICreate("Live Generated Code", $w, $h, $x, $y, $WS_SIZEBOX, -1, $hGUI)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitGenerateCode")

	Local $titleBarHeight = _WinAPI_GetSystemMetrics($SM_CYCAPTION) + 3

	GUICtrlCreateLabel("", 0, 0, $w, $h - $titleBarHeight - 57)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

	$editCodeGeneration = _GUICtrlRichEdit_Create($hFormGenerateCode, "", 10, 10, $w - 20, $h - $titleBarHeight - 78, BitOR($ES_MULTILINE, $WS_VSCROLL, $WS_HSCROLL, $ES_AUTOVSCROLL))
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
	GUICtrlSetFont(-1, 9, -1, -1, "Courier New")
;~ 	_GUICtrlEdit_SetTabStops($editCodeGeneration, 4)
;~ 	GUICtrlSetData($editCodeGeneration, _code_generation())
	_RESH_SyntaxHighlight($editCodeGeneration, 0, _code_generation())


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

	If $setting_onEvent_mode Then
		GUICtrlSetState($radio_eventMode, $GUI_CHECKED)
	Else
		GUICtrlSetState($radio_msgMode, $GUI_CHECKED)
	EndIf

	If $setting_gui_function Then
		GUICtrlSetState($check_guiFunc, $GUI_CHECKED)
	Else
		GUICtrlSetState($check_guiFunc, $GUI_UNCHECKED)
	EndIf

	Local Const $accel_selectAll = GUICtrlCreateDummy()
	Local Const $accelerators[1][2] = [["^a", $accel_selectAll]]
	GUISetAccelerators($accelerators, $hFormGenerateCode)
	GUICtrlSetOnEvent($accel_selectAll, "_onSelectAll")

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
;~ 	GUICtrlSetData($editCodeGeneration, _code_generation())
	_RESH_SyntaxHighlight($editCodeGeneration, 0, _code_generation())
;~ 	_GUICtrlEdit_SetSel($editCodeGeneration, 0, 0)
EndFunc   ;==>_onCodeRefresh


;------------------------------------------------------------------------------
; Title...........: _onCodeSave
; Description.....: Save the code shown in the dialog to file
; Events..........: Save button in code generation dialog
;------------------------------------------------------------------------------
Func _onCodeSave()
	_copy_code_to_output(GUICtrlRead($editCodeGeneration))
EndFunc   ;==>_onCodeSave


;------------------------------------------------------------------------------
; Title...........: _onCodeCopy
; Description.....: Copy the code shown in the dialog to the clipboard
; Events..........: Copy button in code generation dialog
;------------------------------------------------------------------------------
Func _onCodeCopy()
	ClipPut(GUICtrlRead($editCodeGeneration))
EndFunc   ;==>_onCodeCopy

Func _onSelectAll()
	_GUICtrlEdit_SetSel($editCodeGeneration, 0, -1)
EndFunc   ;==>_onSelectAll

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
;~ 		GUICtrlSetData($editCodeGeneration, _code_generation())
		_RESH_SyntaxHighlight($editCodeGeneration, 0, _code_generation())
	EndIf
EndFunc   ;==>_refreshGenerateCode
