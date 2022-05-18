; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formPropertyInspector.au3
; Description ...: Create the property inspector
; ===============================================================================================================================


Global Enum $typeText, $typeNumber, $typeCheck, $typeColor, $getHeight
Global $hLvEdit, $bLvEditOpen, $aLvRect
Global $pEditCallback, $pGuiCallback, $aColLeftEdgePosAcc, $aColumnWidths
;------------------------------------------------------------------------------
; Title...........: formGenerateCode
; Description.....:	Create the code generation GUI
;------------------------------------------------------------------------------
Func _formPropertyInspector($x, $y, $w, $h)

	GUICtrlCreateTab($x, $y, $w, $h)
	GUICtrlSetBkColor(-1, 0xEEEEEE)

	#Region properties-tab-main
	GUICtrlCreateTabItem("Main")

	;top line
	Local $labelLine = GUICtrlCreateLabel("", $x + 1, $y + 23, $w - 4, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;items
	$h_form_text = _formPropertyInspector_newitem("Text", $typeText, $x, $y + 24, $w - 3, 20)
	$h_form_name = _formPropertyInspector_newitem("Name", $typeText)
	$h_form_left = _formPropertyInspector_newitem("Left", $typeNumber)
	$h_form_top = _formPropertyInspector_newitem("Top", $typeNumber)
	$h_form_width = _formPropertyInspector_newitem("Width", $typeNumber)
	$h_form_height = _formPropertyInspector_newitem("Height", $typeNumber)
	$h_form_Color = _formPropertyInspector_newitem("Font Color", $typeColor, -1, -1, -1, -1, "_ctrl_pick_Color")
	$h_form_bkColor = _formPropertyInspector_newitem("Background", $typeColor, -1, -1, -1, -1, "_ctrl_pick_bkColor")

	;vertical line
	Local $itemsHeight = _formPropertyInspector_newitem("", $getHeight)
	$labelLine = GUICtrlCreateLabel("", $x + $w - 4 - 81, $y + 23, 1, $itemsHeight - ($y + 24))
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

	#Region properties-tab-state
	GUICtrlCreateTabItem("State")

	;top line
	$labelLine = GUICtrlCreateLabel("", $x + 1, $y + 23, $w - 4, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;items
	$h_form_visible = _formPropertyInspector_newitem("Visible", $typeCheck, $x, $y + 24, $w - 3)
	$h_form_enabled = _formPropertyInspector_newitem("Enabled", $typeCheck)
	$h_form_ontop = _formPropertyInspector_newitem("OnTop", $typeCheck)
	$h_form_dropaccepted = _formPropertyInspector_newitem("Drop Accepted", $typeCheck)
	$h_form_focus = _formPropertyInspector_newitem("Focus", $typeCheck)

	;vertical line
	$itemsHeight = _formPropertyInspector_newitem("", $getHeight)
	$labelLine = GUICtrlCreateLabel("", $x + $w - 4 - 81, $y + 23, 1, $itemsHeight - ($y + 24))
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	GUICtrlSetOnEvent($h_form_visible, _ctrl_change_visible)
	GUICtrlSetOnEvent($h_form_enabled, _ctrl_change_enabled)
	GUICtrlSetOnEvent($h_form_ontop, _ctrl_change_ontop)
	GUICtrlSetOnEvent($h_form_dropaccepted, _ctrl_change_dropaccepted)
	GUICtrlSetOnEvent($h_form_focus, _ctrl_change_focus)
	#EndRegion properties-tab-state

	#Region properties-tab-style
	GUICtrlCreateTabItem("Style")

	;top line
	Local $labelLine = GUICtrlCreateLabel("", $x + 1, $y + 23, $w - 4, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;items
	$h_form_style_autocheckbox = _formPropertyInspector_newitem("AutoCheckBox", $typeCheck, $x, $y + 24, $w - 3)
	$h_form_style_top = _formPropertyInspector_newitem("Top", $typeCheck)

	;vertical line
	$itemsHeight = _formPropertyInspector_newitem("", $getHeight)
	$labelLine = GUICtrlCreateLabel("", $x + $w - 4 - 81, $y + 23, 1, $itemsHeight - ($y + 24))
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	GUICtrlSetOnEvent($h_form_style_autocheckbox, _ctrl_change_style_autocheckbox)
	GUICtrlSetOnEvent($h_form_style_top, _ctrl_change_style_top)
	#EndRegion properties-tab-style

	#Region properties-tab-exstyle
	GUICtrlCreateTabItem("ExStyle")

	;top line
	Local $labelLine = GUICtrlCreateLabel("", $x + 1, $y + 23, $w - 4, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)
	#EndRegion properties-tab-exstyle

	GUICtrlCreateTabItem("")

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

	Local $label = GUICtrlCreateLabel($text, $item_x + 5, $item_y, $labelWidth, $item_h - 1, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, 0xF7F9FE)

	If $type = $typeNumber Then
		Local $edit = GUICtrlCreateInput("", $item_x + $item_w - $editWidth, $item_y, $editWidth, $item_h - 1, BitOR($ES_NUMBER, $SS_CENTERIMAGE), $WS_EX_TRANSPARENT)
		GUICtrlCreateUpdown($edit, $UDS_ARROWKEYS)
		GUICtrlSetState(-1, $GUI_HIDE)
	ElseIf $type = $typeColor Then
		Local $edit = GUICtrlCreateInput("", $item_x + $item_w - $editWidth, $item_y, $editWidth - 20, $item_h - 1, $SS_CENTERIMAGE, $WS_EX_TRANSPARENT)
		GUICtrlCreateUpdown($edit, $UDS_ARROWKEYS)
		GUICtrlSetState(-1, $GUI_HIDE)
		Local $pickButton = GUICtrlCreateButton("...", $item_x + $item_w - 19, $item_y + 2, 18, $item_h - 4)
		If $funcName <> -1 Then
			GUICtrlSetOnEvent($pickButton, $funcName)
		EndIf
	ElseIf $type = $typeCheck Then
		GUICtrlCreateLabel("", $item_x + $item_w - $editWidth, $item_y, $editWidth, $item_h - 1)
		GUICtrlSetBkColor(-1, 0xF7F9FE)
		GUICtrlSetState(-1, $GUI_DISABLE)
		Local $edit = GUICtrlCreateCheckbox("", $item_x + $item_w - 45, $item_y, -1, $item_h - 1, $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, 0xF7F9FE)
	Else
		Local $edit = GUICtrlCreateInput("", $item_x + $item_w - $editWidth, $item_y, $editWidth, $item_h - 1, BitOR($ES_AUTOHSCROLL, $SS_CENTERIMAGE), $WS_EX_TRANSPARENT)
	EndIf

	Local $labelLine = GUICtrlCreateLabel("", $item_x + 1, $item_y + $item_h - 1, $item_w, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	Return $edit
EndFunc   ;==>_formPropertyInspector_newitem
