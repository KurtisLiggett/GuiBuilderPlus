; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formEventCode.au3
; Description ...: Create and manage the event code window
; ===============================================================================================================================

;------------------------------------------------------------------------------
; Title...........: _formEventCode
; Description.....: Display popup window
;------------------------------------------------------------------------------
Func _formEventCode()
	$w = 350
	$h = 265
	$footH = 32

	$hEvent = GUICreate("Event Code", $w, $h, Default, Default, $WS_CAPTION, -1, $hGUI)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onEventExit")

	; top section

	GUICtrlCreateLabel("", 0, 0, $w, $h - 32)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateLabel("", 5, 5, $w - 10, $h - $footH - 10)
	GUICtrlSetBkColor(-1, 0x555555)
	GUICtrlSetState(-1, $GUI_DISABLE)

	$editEventCode = GUICtrlCreateEdit($oSelected.getFirst().CodeString, 5 + 1, 5 + 1, $w - 12, $h - $footH - 12, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL), 0)

	; bottom section

	GUICtrlCreateLabel("", 0, $h - $footH, $w, 1)
	GUICtrlSetBkColor(-1, 0x000000)

	Local $bt_Save = GUICtrlCreateButton("Save", $w - 55, $h - $footH + 5, 50, 22)
	GUICtrlSetOnEvent(-1, "_onEventSave")

	Local $bt_Exit = GUICtrlCreateButton("Cancel", $w - 55 - 55, $h - $footH + 5, 50, 22)
	GUICtrlSetOnEvent(-1, "_onEventExit")

	Local $bt_InsertCode = GUICtrlCreateButton("Insert ConsoleWrite", 5, $h - $footH + 5, 100, 22)
	GUICtrlSetOnEvent(-1, "_onEventInsert1")

	Local $bt_InsertMsgBox = GUICtrlCreateButton("Insert MsgBox", 110, $h - $footH + 5, 85, 22)
	GUICtrlSetOnEvent(-1, "_onEventInsert2")

	GUISetState(@SW_DISABLE, $hGUI)
	GUISetState(@SW_SHOW, $hEvent)
EndFunc

Func _onEventInsert1()
	_GUICtrlEdit_AppendText(GUICtrlGetHandle($editEventCode), 'ConsoleWrite("Event: $' & $oSelected.getFirst().Name & '" & @CRLF)')
EndFunc

Func _onEventInsert2()
	_GUICtrlEdit_AppendText(GUICtrlGetHandle($editEventCode), 'MsgBox(0, "Event Message", "Event: $' & $oSelected.getFirst().Name & '")')
EndFunc

Func _onEventSave()
	Local $sCode = GUICtrlRead($editEventCode)

	;update the undo action stack
	Local $oAction = _objAction()
	$oAction.action = $action_changeCode
	$oAction.ctrls = $oSelected.ctrls.Items()
	Local $aParams[$oSelected.ctrls.Count]
	Local $aParam[2]
	For $i = 0 To UBound($oAction.ctrls) - 1
		$aParam[0] = $oAction.ctrls[$i].CodeString
		$aParam[1] = $sCode
		$aParams[$i] = $aParam
	Next
	$oAction.parameters = $aParams
	_updateActionStacks($oAction)


	For $oCtrl In $oSelected.ctrls.Items()
		$oCtrl.CodeString = $sCode
	Next

	_onEventExit()
	_refreshGenerateCode()
EndFunc   ;==>_onEventSave

Func _onEventExit()
	GUIDelete($hEvent)
	GUISetState(@SW_ENABLE, $hGUI)
	GUISwitch($hGUI)
EndFunc   ;==>_onEventExit
