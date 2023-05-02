; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formListItems.au3
; Description ...: Create and manage the Settings window
; ===============================================================================================================================

;------------------------------------------------------------------------------
; Title...........: _formListItems
; Description.....: Display popup window
;------------------------------------------------------------------------------
Func _formListItems()
	If $oSelected.getFirst().Type = "ListView" Then
		_showFormListViewItems()
	Else
		_showFormListItems()
	EndIf
EndFunc   ;==>_formListItems

Func _showFormListItems()
	$w = 300
	$h = 265
	$footH = 32

	Local $aGuiPos = WinGetPos($hGUI)

	$hListItems = GUICreate("Items", $w, $h, $aGuiPos[0] + $aGuiPos[2] / 2 - $w / 2, $aGuiPos[1] + $aGuiPos[3] / 2 - $h / 2, $WS_CAPTION, -1, $hGUI)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitListItems")

	; top section

	GUICtrlCreateLabel("", 0, 0, $w, $h - 32)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateLabel("", 5, 5, $w - 10, $h - $footH - 10)
	GUICtrlSetBkColor(-1, 0x555555)
	GUICtrlSetState(-1, $GUI_DISABLE)

	$sItems = _items_GetList($oSelected.getFirst().Items)

	$editListItems = GUICtrlCreateEdit($sItems, 5 + 1, 5 + 1, $w - 12, $h - $footH - 12, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL), 0)
	_GUICtrlEdit_SetPadding($editListItems, 2, 2)

	; bottom section

	GUICtrlCreateLabel("", 0, $h - $footH, $w, 1)
	GUICtrlSetBkColor(-1, 0x000000)

	Local $bt_Save = GUICtrlCreateButton("Save", $w - 55, $h - $footH + 5, 50, 22)
	GUICtrlSetOnEvent(-1, "_onSaveListItems")

	Local $bt_Exit = GUICtrlCreateButton("Cancel", $w - 55 - 55, $h - $footH + 5, 50, 22)
	GUICtrlSetOnEvent(-1, "_onExitListItems")

	GUISetState(@SW_DISABLE, $hGUI)
	GUISetState(@SW_SHOW, $hListItems)
	_GUICtrlEdit_SetSel($editListItems, -1, -1)
EndFunc   ;==>_showFormListItems

Func _onSaveListItems()
	Local $sItems = GUICtrlRead($editListItems)
	$sItems = _items_GetList($sItems, @CRLF, "|")

	GUIDelete($hListItems)
	GUISetState(@SW_ENABLE, $hGUI)
	GUISwitch($hGUI)

	For $oThisCtrl In $oSelected.ctrls.Items()
		$oThisCtrl.Items = $sItems
		GuiCtrlSetData($oThisCtrl.Hwnd, "|" & $oThisCtrl.Items)
	Next

	$oProperties_Ctrls.properties.Items.value = $sItems

	_refreshGenerateCode()
EndFunc   ;==>_onSaveListItems

Func _onExitListItems()
	GUIDelete($hListItems)
	GUISetState(@SW_ENABLE, $hGUI)
	GUISwitch($hGUI)
EndFunc   ;==>_onExitListItems

Func _items_GetList($sItems, $char = "|", $sep = @CRLF)
	If $sItems <> "" Then
		Local $aItems = StringSplit($sItems, $char)
		If $aItems[0] > 0 Then
			$sItems = ""
			If $aItems[1] <> "" Then
				$sItems = $aItems[1]
			EndIf
		EndIf

		If $aItems[0] > 1 Then
			For $i = 2 To $aItems[0]
				If $aItems[$i] <> "" Then
					If $sItems <> "" Then
						$sItems &= $sep
					EndIf
					$sItems &= $aItems[$i]
				EndIf
			Next
		EndIf
		If $sep = @CRLF Then
			$sItems &= $sep
		EndIf
	EndIf

	Return $sItems
EndFunc   ;==>_items_GetList


Func _showFormListViewItems()
	MsgBox($MB_ICONWARNING, "Feature not available", "This feature is not yet available.")
EndFunc   ;==>_showFormListViewItems
