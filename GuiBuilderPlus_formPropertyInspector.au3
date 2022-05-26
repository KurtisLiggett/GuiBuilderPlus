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
	;top line
	Local $labelLine = GUICtrlCreateLabel("", $x, $y, $w, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)


	#Region properties-tab-main
	;create the child gui for controls properties
	Local $guiHandle = GUICreate("", $w, $h-2, $x, $y+1, $WS_POPUP, $WS_EX_MDICHILD, $hToolbar)
	GUISetBkColor(0xFFFFFF)
	Local $ret = _GUIScrollbars_Generate($guiHandle, $w - 2, $h+20)
	$oProperties_Main.Hwnd = $guiHandle

	Local $iScrollbarWidth = $__g_aSB_WindowInfo[0][5]

	;End line
	Local $labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1, 0, 1, $h+20)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;items
	$oProperties_Main.Title.Hwnd = _formPropertyInspector_newitem("Title", $typeText, 0, 1, $w - $iScrollbarWidth - 1, 20)
	$oProperties_Main.Name.Hwnd = _formPropertyInspector_newitem("Name", $typeText)
	$oProperties_Main.Left.Hwnd = _formPropertyInspector_newitem("Left", $typeNumber)
	$oProperties_Main.Top.Hwnd = _formPropertyInspector_newitem("Top", $typeNumber)
	$oProperties_Main.Width.Hwnd = _formPropertyInspector_newitem("Width", $typeNumber)
	$oProperties_Main.Height.Hwnd = _formPropertyInspector_newitem("Height", $typeNumber)
	$oProperties_Main.Background.Hwnd = _formPropertyInspector_newitem("Background", $typeColor, -1, -1, -1, -1, "_main_pick_bkColor")

	;vertical line
	Local $itemsHeight = _formPropertyInspector_newitem("", $getHeight)
	$labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1 - 81, 0, 1, $itemsHeight)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	GUICtrlSetOnEvent($oProperties_Main.Title.Hwnd, _main_change_title)
	GUICtrlSetOnEvent($oProperties_Main.Name.Hwnd, _main_change_name)
	GUICtrlSetOnEvent($oProperties_Main.Left.Hwnd, _main_change_left)
	GUICtrlSetOnEvent($oProperties_Main.Top.Hwnd, _main_change_top)
	GUICtrlSetOnEvent($oProperties_Main.Width.Hwnd, _main_change_width)
	GUICtrlSetOnEvent($oProperties_Main.Height.Hwnd, _main_change_height)
	GUICtrlSetOnEvent($oProperties_Main.Background.Hwnd, _main_change_background)

	;populate settings with default values
	$oProperties_Main.Title.value = $oMain.Title
	$oProperties_Main.Name.value = $oMain.Name
	$oProperties_Main.Width.value = $oMain.Width
	$oProperties_Main.Height.value = $oMain.Height
	$oProperties_Main.Left.value = $oMain.Left
	$oProperties_Main.Top.value = $oMain.Top
	$oProperties_Main.Background.value = $oMain.Background

	#EndRegion properties-tab-main



	#Region properties-tab-controls
	;create the child gui for controls properties
	$guiHandle = GUICreate("", $w, $h-1, $x, $y+1, $WS_POPUP, $WS_EX_MDICHILD, $hToolbar)
	GUISetBkColor(0xFFFFFF)
	_GUIScrollbars_Generate($guiHandle, $w - 2, $h)
	$oProperties_Ctrls.Hwnd = $guiHandle

	;End line
	Local $labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1, 0, 1, $h+20)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;items
	$oProperties_Ctrls.Text.Hwnd = _formPropertyInspector_newitem("Text", $typeText, 0, 1, $w - $iScrollbarWidth - 1, 20)
	$oProperties_Ctrls.Name.Hwnd = _formPropertyInspector_newitem("Name", $typeText)
	$oProperties_Ctrls.Left.Hwnd = _formPropertyInspector_newitem("Left", $typeNumber)
	$oProperties_Ctrls.Top.Hwnd = _formPropertyInspector_newitem("Top", $typeNumber)
	$oProperties_Ctrls.Width.Hwnd = _formPropertyInspector_newitem("Width", $typeNumber)
	$oProperties_Ctrls.Height.Hwnd = _formPropertyInspector_newitem("Height", $typeNumber)
	$oProperties_Ctrls.Color.Hwnd = _formPropertyInspector_newitem("Font Color", $typeColor, -1, -1, -1, -1, "_ctrl_pick_Color")
	$oProperties_Ctrls.Background.Hwnd = _formPropertyInspector_newitem("Background", $typeColor, -1, -1, -1, -1, "_ctrl_pick_bkColor")

	;vertical line
	Local $itemsHeight = _formPropertyInspector_newitem("", $getHeight)
	$labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1 - 81, 0, 1, $itemsHeight)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	GUICtrlSetOnEvent($oProperties_Ctrls.Text.Hwnd, _ctrl_change_text)
	GUICtrlSetOnEvent($oProperties_Ctrls.Name.Hwnd, _ctrl_change_name)
	GUICtrlSetOnEvent($oProperties_Ctrls.Left.Hwnd, _ctrl_change_left)
	GUICtrlSetOnEvent($oProperties_Ctrls.Top.Hwnd, _ctrl_change_top)
	GUICtrlSetOnEvent($oProperties_Ctrls.Width.Hwnd, _ctrl_change_width)
	GUICtrlSetOnEvent($oProperties_Ctrls.Height.Hwnd, _ctrl_change_height)
	GUICtrlSetOnEvent($oProperties_Ctrls.Color.Hwnd, _ctrl_change_Color)
	GUICtrlSetOnEvent($oProperties_Ctrls.Background.Hwnd, _ctrl_change_bkColor)
	#EndRegion properties-tab-controls



	GUISwitch($hToolbar)

	;bottom line
;~ 	Local $labelLine = GUICtrlCreateLabel("", $x, $y+$h, $w, 1)
;~ 	GUICtrlSetBkColor(-1, 0xDDDDDD)

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
			GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Main.Hwnd)
			GUISetState(@SW_HIDE, $oProperties_Ctrls.Hwnd)
;~ 			_GUIScrollbars_Generate($oProperties_Main.Hwnd, $w - 2, $h)

		Case $props_Ctrls
			If _isAllLabels() Then
				GUICtrlSetState($oProperties_Ctrls.Color.Hwnd, $GUI_ENABLE)
				GUICtrlSetState($oProperties_Ctrls.Background.Hwnd, $GUI_ENABLE)
			Else
				GUICtrlSetState($oProperties_Ctrls.Color.Hwnd, $GUI_DISABLE)
				GUICtrlSetState($oProperties_Ctrls.Background.Hwnd, $GUI_DISABLE)
			EndIf
			GUISetState(@SW_HIDE, $oProperties_Main.Hwnd)
			GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Ctrls.Hwnd)
;~ 			_GUIScrollbars_Generate($oProperties_Ctrls.Hwnd, $w - 2, $h)

		Case Else
			GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Main.Hwnd)
			GUISetState(@SW_HIDE, $oProperties_Ctrls.Hwnd)
;~ 			_GUIScrollbars_Generate($oProperties_Main.Hwnd, $w - 2, $h)
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