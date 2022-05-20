; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formPropertyInspector.au3
; Description ...: Create the property inspector
; ===============================================================================================================================


Global Enum $typeHeading, $typeText, $typeNumber, $typeCheck, $typeColor, $getHeight
;------------------------------------------------------------------------------
; Title...........: formGenerateCode
; Description.....:	Create the code generation GUI
;------------------------------------------------------------------------------
Func _formPropertyInspector($x, $y, $w, $h)

	#Region properties-tab-main
	;create the child gui for controls properties
	$hPropGUI_Main = GUICreate("", $w, $h, $x, $y, $WS_POPUPWINDOW, $WS_EX_MDICHILD, $toolbar)
	GUISetBkColor(0xFFFFFF)
	_GUIScrollbars_Generate($hPropGUI_Main, $w - 2, $h)

	Local $iScrollbarWidth = $__g_aSB_WindowInfo[0][5]

	;top line
	Local $labelLine = GUICtrlCreateLabel("", 0, 0, $w, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)
	;bottom line
	Local $labelLine = GUICtrlCreateLabel("", 0, $h - 1, $w, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)
	;Left line
	Local $labelLine = GUICtrlCreateLabel("", 0, 0, 1, $h)
	GUICtrlSetBkColor(-1, 0xDDDDDD)
	;Right line
	Local $labelLine = GUICtrlCreateLabel("", $w - 1, 0, 1, $h)
	GUICtrlSetBkColor(-1, 0xDDDDDD)
	;End line
	Local $labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1, 0, 1, $h)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;items
	$h_form_text = _formPropertyInspector_newitem("Title", $typeText, 0, 1, $w - $iScrollbarWidth - 1, 20)
	$h_form_name = _formPropertyInspector_newitem("Name", $typeText)
	$h_form_left = _formPropertyInspector_newitem("Left", $typeNumber)
	$h_form_top = _formPropertyInspector_newitem("Top", $typeNumber)
	$h_form_width = _formPropertyInspector_newitem("Width", $typeNumber)
	$h_form_height = _formPropertyInspector_newitem("Height", $typeNumber)
	$h_form_bkColor = _formPropertyInspector_newitem("Background", $typeColor, -1, -1, -1, -1, "_ctrl_pick_bkColor")

	;vertical line
	Local $itemsHeight = _formPropertyInspector_newitem("", $getHeight)
	$labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1 - 81, 0, 1, $itemsHeight)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	GUICtrlSetOnEvent($h_form_text, _ctrl_change_text)
	GUICtrlSetOnEvent($h_form_name, _ctrl_change_name)
	GUICtrlSetOnEvent($h_form_left, _ctrl_change_left)
	GUICtrlSetOnEvent($h_form_top, _ctrl_change_top)
	GUICtrlSetOnEvent($h_form_width, _ctrl_change_width)
	GUICtrlSetOnEvent($h_form_fittowidth, _ctrl_fit_to_width)
	GUICtrlSetOnEvent($h_form_height, _ctrl_change_height)
	GUICtrlSetOnEvent($h_form_Color, _ctrl_change_Color)
	GUICtrlSetOnEvent($h_form_bkColor, _ctrl_change_bkColor)
	#EndRegion properties-tab-main


	#Region properties-tab-controls
	;create the child gui for controls properties
	$hPropGUI_Ctrls = GUICreate("", $w, $h, $x, $y, $WS_POPUPWINDOW, $WS_EX_MDICHILD, $toolbar)
	GUISetBkColor(0xFFFFFF)
	_GUIScrollbars_Generate($hPropGUI_Ctrls, $w - 2, $h)

	;top line
	Local $labelLine = GUICtrlCreateLabel("", 0, 0, $w, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)
	;bottom line
	Local $labelLine = GUICtrlCreateLabel("", 0, $h - 1, $w, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)
	;Left line
	Local $labelLine = GUICtrlCreateLabel("", 0, 0, 1, $h)
	GUICtrlSetBkColor(-1, 0xDDDDDD)
	;Right line
	Local $labelLine = GUICtrlCreateLabel("", $w - 1, 0, 1, $h)
	GUICtrlSetBkColor(-1, 0xDDDDDD)
	;End line
	Local $labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1, 0, 1, $h)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;items
	$h_form_text = _formPropertyInspector_newitem("Text", $typeText, 0, 1, $w - $iScrollbarWidth - 1, 20)
	$h_form_name = _formPropertyInspector_newitem("Name", $typeText)
	$h_form_left = _formPropertyInspector_newitem("Left", $typeNumber)
	$h_form_top = _formPropertyInspector_newitem("Top", $typeNumber)
	$h_form_width = _formPropertyInspector_newitem("Width", $typeNumber)
	$h_form_height = _formPropertyInspector_newitem("Height", $typeNumber)
	$h_form_Color = _formPropertyInspector_newitem("Font Color", $typeColor, -1, -1, -1, -1, "_ctrl_pick_Color")
	$h_form_bkColor = _formPropertyInspector_newitem("Background", $typeColor, -1, -1, -1, -1, "_ctrl_pick_bkColor")

	;vertical line
	Local $itemsHeight = _formPropertyInspector_newitem("", $getHeight)
	$labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1 - 81, 0, 1, $itemsHeight)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	GUICtrlSetOnEvent($h_form_text, _ctrl_change_text)
	GUICtrlSetOnEvent($h_form_name, _ctrl_change_name)
	GUICtrlSetOnEvent($h_form_left, _ctrl_change_left)
	GUICtrlSetOnEvent($h_form_top, _ctrl_change_top)
	GUICtrlSetOnEvent($h_form_width, _ctrl_change_width)
	GUICtrlSetOnEvent($h_form_fittowidth, _ctrl_fit_to_width)
	GUICtrlSetOnEvent($h_form_height, _ctrl_change_height)
	GUICtrlSetOnEvent($h_form_Color, _ctrl_change_Color)
	GUICtrlSetOnEvent($h_form_bkColor, _ctrl_change_bkColor)
	#EndRegion properties-tab-controls



	GUISwitch($toolbar)

EndFunc   ;==>_formPropertyInspector


Func _formPropertyInspector_newitem($text, $type = -1, $x = -1, $y = -1, $w = -1, $h = -1, $funcName = -1)
	Static $item_x, $item_y, $item_w, $item_h, $count = 0

	If $type = $getHeight Then
		Return $item_y + $item_h
	EndIf

	If $x <> -1 Then
		$item_x = $x
	Else
		If $count = 0 Then
			$item_x = 0
		EndIf
	EndIf

	If $x <> -1 Then
		$item_x = $x
	Else
		If $count = 0 Then
			$item_x = 0
		EndIf
	EndIf

	If $y <> -1 Then
		$item_y = $y
	Else
		If $count = 0 Then
			$item_y = 0
		Else
			$item_y += $item_h
		EndIf
	EndIf

	If $w <> -1 Then
		$item_w = $w
	Else
		If $count = 0 Then
			$item_w = 0
		EndIf
	EndIf

	If $h <> -1 Then
		$item_h = $h
	Else
		If $count = 0 Then
			$item_h = 0
		EndIf
	EndIf


	$count += 1

	Local $editWidth = 80
	Local $labelWidth = $item_w - $editWidth

	Local $label = GUICtrlCreateLabel($text, $item_x + 5, $item_y, $labelWidth - 5 - 1, $item_h - 1, $SS_CENTERIMAGE)
	GUICtrlSetColor(-1, 0x333333)
	GUICtrlSetBkColor(-1, 0xFFFFFF)

	If $type = $typeNumber Then
		Local $edit = GUICtrlCreateInput("", $item_x + $item_w - $editWidth, $item_y, $editWidth, $item_h - 1, BitOR($ES_AUTOHSCROLL, $ES_NUMBER, $SS_CENTERIMAGE), $WS_EX_TRANSPARENT)
		GUICtrlCreateUpdown($edit)
	ElseIf $type = $typeColor Then
		Local $edit = GUICtrlCreateInput("", $item_x + $item_w - $editWidth, $item_y, $editWidth - 15, $item_h - 1, BitOR($ES_AUTOHSCROLL, $SS_CENTERIMAGE), $WS_EX_TRANSPARENT)
		Local $pickButton = GUICtrlCreateButton("...", $item_x + $item_w - 16, $item_y + 2, 18, $item_h - 4)
		If $funcName <> -1 Then
			GUICtrlSetOnEvent($pickButton, $funcName)
		EndIf
	ElseIf $type = $typeCheck Then
		GUICtrlCreateLabel("", $item_x + $item_w - $editWidth, $item_y, $editWidth, $item_h - 1)
		GUICtrlSetBkColor(-1, 0xFFFFFF)
		GUICtrlSetState(-1, $GUI_DISABLE)
		Local $edit = GUICtrlCreateCheckbox("", $item_x + $item_w - 45, $item_y, -1, $item_h - 1, $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, 0xFFFFFF)
	ElseIf $type = $typeHeading Then
		Local $aStrings = StringSplit($text, "|", $STR_NOCOUNT)
		GUICtrlSetData($label, $aStrings[0])
		GUICtrlSetFont($label, 9, $FW_BOLD)

		Local $edit = GUICtrlCreateLabel(" " & $aStrings[1], $item_x + $item_w - $editWidth, $item_y, $editWidth, $item_h - 1, $SS_CENTERIMAGE)
		GUICtrlSetColor(-1, 0x333333)
		GUICtrlSetBkColor(-1, 0xFFFFFF)
		GUICtrlSetFont($edit, 9, $FW_BOLD)
	Else
		Local $edit = GUICtrlCreateInput("", $item_x + $item_w - $editWidth, $item_y, $editWidth, $item_h - 1, BitOR($ES_AUTOHSCROLL, $SS_CENTERIMAGE), $WS_EX_TRANSPARENT)
	EndIf

	Local $labelLine = GUICtrlCreateLabel("", $item_x + 1, $item_y + $item_h - 1, $item_w, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	Return $edit
EndFunc   ;==>_formPropertyInspector_newitem


Func _showProperties($props = $props_Main)
	Switch $props
		Case $props_Main
			GUISetState(@SW_SHOWNOACTIVATE, $hPropGUI_Main)
			GUISetState(@SW_HIDE, $hPropGUI_Ctrls)

		Case $props_Ctrls
			If _isAllLabels() Then
				GUICtrlSetState($h_form_Color, $GUI_ENABLE)
				GUICtrlSetState($h_form_bkColor, $GUI_ENABLE)
			Else
				GUICtrlSetState($h_form_Color, $GUI_DISABLE)
				GUICtrlSetState($h_form_bkColor, $GUI_DISABLE)
			EndIf
			GUISetState(@SW_HIDE, $hPropGUI_Main)
			GUISetState(@SW_SHOWNOACTIVATE, $hPropGUI_Ctrls)

		Case Else
			GUISetState(@SW_SHOWNOACTIVATE, $hPropGUI_Main)
			GUISetState(@SW_HIDE, $hPropGUI_Ctrls)
	EndSwitch

	GUISwitch($hGUI)
EndFunc

Func _isAllLabels()
	If $oSelected.count > 0 Then
		For $oCtrl in $oSelected.ctrls
			If $oCtrl.Type <> "Label" Then
				Return False
			EndIf
		Next
	EndIf

	Return True
EndFunc