; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formPropertyInspector.au3
; Description ...: Create the property inspector
; ===============================================================================================================================


Global Enum $typeHeading, $typeText, $typeNumber, $typeCheck, $typeColor, $getHeight, $typeReal, $typeComboFW, $typeComboFN
Global $properties_data[100][10], $properties_fontIndex, $properties_borderIndex
Global $properties_data_font[5][10], $properties_data_border[5][10]
;------------------------------------------------------------------------------
; Title...........: formGenerateCode
; Description.....:	Create the code generation GUI
;------------------------------------------------------------------------------
Func _formPropertyInspector($x, $y, $w, $h)
	$w = $w - $__g_aSB_WindowInfo[0][5] / 2
	$h = $h - 25

	;tabs
	Local $labelLine = GUICtrlCreateLabel("", $x, $y, 70 + 50, 1)
	GUICtrlSetBkColor(-1, 0xC5C5C5)

	Local $tabHeight = 20
	$tabProperties = GUICtrlCreateLabel("Properties", $x, $y + 1, 70, $tabHeight - 1, BitOR($GUI_SS_DEFAULT_LABEL, $SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetBkColor(-1, 0xEEEEEE)
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetOnEvent(-1, "_onTabProperties")

	$labelLine = GUICtrlCreateLabel("", $x + 70, $y, 1, $tabHeight)
	GUICtrlSetBkColor(-1, 0xC5C5C5)

	$tabStyles = GUICtrlCreateLabel("Styles", $x + 71, $y + 1, 50, $tabHeight - 1, BitOR($GUI_SS_DEFAULT_LABEL, $SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetBkColor(-1, 0xD6D6D6)
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetOnEvent(-1, "_onTabStyles")

	$labelLine = GUICtrlCreateLabel("", $x + 71 + 50, $y, 1, $tabHeight)
	GUICtrlSetBkColor(-1, 0xC5C5C5)

	$labelLine = GUICtrlCreateLabel("", $x, $y + $tabHeight, $w, 1)
	GUICtrlSetBkColor(-1, 0xC5C5C5)

	$y = $y + $tabHeight
	$h = $h - $tabHeight

	;top line
	$labelLine = GUICtrlCreateLabel("", $x, $y, $w, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	#Region main-properties
	;create the child gui for controls properties
	Local $guiHandle = GUICreate("", $w, $h, $x, $y + 1, $WS_POPUP, $WS_EX_MDICHILD, $hToolbar)
	GUISetBkColor(0xFFFFFF)
	Local $ret = _GUIScrollbars_Generate($guiHandle, $w - 2, $h)
	$oProperties_Main.properties.Hwnd = $guiHandle

	Local $iScrollbarWidth = $__g_aSB_WindowInfo[0][5]

	;End line
	Local $labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1, 0, 1, $h + 20)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;items
	$oProperties_Main.properties.Background.Hwnd = _formPropertyInspector_newitem("Background Color", $typeColor, 20, 1, $w - $iScrollbarWidth - 1, 20, "_main_pick_bkColor")
	$oProperties_Main.properties.Height.Hwnd = _formPropertyInspector_newitem("Height", $typeNumber)
	$oProperties_Main.properties.Left.Hwnd = _formPropertyInspector_newitem("Left", $typeNumber)
	$oProperties_Main.properties.Name.Hwnd = _formPropertyInspector_newitem("Name", $typeText)
	$oProperties_Main.properties.Title.Hwnd = _formPropertyInspector_newitem("Title", $typeText)
	$oProperties_Main.properties.Top.Hwnd = _formPropertyInspector_newitem("Top", $typeNumber)
	$oProperties_Main.properties.Width.Hwnd = _formPropertyInspector_newitem("Width", $typeNumber)

	;vertical line
	Local $itemsHeight = _formPropertyInspector_newitem("", $getHeight)
	$labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1 - 81, 0, 1, $itemsHeight)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	GUICtrlSetOnEvent($oProperties_Main.properties.Title.Hwnd, _main_change_title)
	GUICtrlSetOnEvent($oProperties_Main.properties.Name.Hwnd, _main_change_name)
	GUICtrlSetOnEvent($oProperties_Main.properties.Left.Hwnd, _main_change_left)
	GUICtrlSetOnEvent($oProperties_Main.properties.Top.Hwnd, _main_change_top)
	GUICtrlSetOnEvent($oProperties_Main.properties.Width.Hwnd, _main_change_width)
	GUICtrlSetOnEvent($oProperties_Main.properties.Height.Hwnd, _main_change_height)
	GUICtrlSetOnEvent($oProperties_Main.properties.Background.Hwnd, _main_change_background)

	;populate settings with default values
	$oProperties_Main.properties.Title.value = $oMain.Title
	$oProperties_Main.properties.Name.value = $oMain.Name
	$oProperties_Main.properties.Width.value = $oMain.Width
	$oProperties_Main.properties.Height.value = $oMain.Height
	$oProperties_Main.properties.Left.value = $oMain.Left
	$oProperties_Main.properties.Top.value = $oMain.Top
	$oProperties_Main.properties.Background.value = $oMain.Background

	#EndRegion main-properties


	#Region main-styles
	;create the child gui for controls properties
	_generateStyles($w, $h, $x, $y + 1)

	#EndRegion main-styles



	#Region ctrl-properties
	;create the child gui for controls properties
	$newH = 19 * 15
	$guiHandle = GUICreate("", $w, $h, $x, $y + 1, $WS_POPUP, $WS_EX_MDICHILD, $hToolbar)
	GUISetBkColor(0xFFFFFF)
	_GUIScrollbars_Generate($guiHandle, $w - 2, $newH)
	$oProperties_Ctrls.properties.Hwnd = $guiHandle

	;End line
	Local $labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1, 0, 1, $newH + 20)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;Func _formPropertyInspector_newitem($text, $type = -1, $x = -1, $y = -1, $w = -1, $h = -1, $funcName = -1, $show = 1, $parent = -1)
	;items
	$oProperties_Ctrls.properties.Background.Hwnd = _formPropertyInspector_newitem("Background", $typeColor, 20, 1, $w - $iScrollbarWidth - 1, 20, "_ctrl_pick_bkColor", 1)
	$oProperties_Ctrls.properties.BorderColor.Hwnd = _formPropertyInspector_newitem("Line Color", $typeColor, -1, -1, -1, -1, "_ctrl_pick_borderColor", 1)
	$properties_borderIndex = $properties_data[0][0]
	$oProperties_Ctrls.properties.BorderSize.Hwnd = _formPropertyInspector_newitem("Thickness", $typeNumber, 30, -1, -1, -1, -1, 1, 1, $properties_borderIndex)
	$oProperties_Ctrls.properties.FontName.Hwnd = _formPropertyInspector_newitem("Font", $typeComboFN, 20, -1, -1, -1, -1, 1)
	$properties_fontIndex = $properties_data[0][0]
	$oProperties_Ctrls.properties.FontSize.Hwnd = _formPropertyInspector_newitem("Size", $typeReal, 30, -1, -1, -1, -1, 1, 1, $properties_fontIndex)
	$oProperties_Ctrls.properties.FontWeight.Hwnd = _formPropertyInspector_newitem("Weight", $typeComboFW, 30, -1, -1, -1, -1, 1, 1, $properties_fontIndex)
	$oProperties_Ctrls.properties.Color.Hwnd = _formPropertyInspector_newitem("Color", $typeColor, 30, -1, -1, -1, "_ctrl_pick_Color", 1, 1, $properties_fontIndex)
	$oProperties_Ctrls.properties.Global.Hwnd = _formPropertyInspector_newitem("Global", $typeCheck, 20, -1, -1, -1, -1, 1)
	$oProperties_Ctrls.properties.Height.Hwnd = _formPropertyInspector_newitem("Height", $typeNumber, -1, -1, -1, -1, -1, 1)
	$oProperties_Ctrls.properties.Left.Hwnd = _formPropertyInspector_newitem("Left", $typeNumber, -1, -1, -1, -1, -1, 1)
	$oProperties_Ctrls.properties.Name.Hwnd = _formPropertyInspector_newitem("Name", $typeText, -1, -1, -1, -1, -1, 1)
	$oProperties_Ctrls.properties.Text.Hwnd = _formPropertyInspector_newitem("Text", $typeText, -1, -1, -1, -1, -1, 1)
	$oProperties_Ctrls.properties.Top.Hwnd = _formPropertyInspector_newitem("Top", $typeNumber, -1, -1, -1, -1, -1, 1)
	$oProperties_Ctrls.properties.Width.Hwnd = _formPropertyInspector_newitem("Width", $typeNumber, -1, -1, -1, -1, -1, 1)

	$properties_borderButton = GUICtrlCreateLabel("-", 3, 21, 15, 18, BitOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetFont(-1, 12)
	GUICtrlSetOnEvent(-1, "_onBorderButton")
	Local $aTemp = $properties_data[$properties_borderIndex][0]
	For $i=0 to UBound($aTemp)
		If $aTemp[$i] = 0 Then
			$aTemp[$i] = $properties_borderButton
			ExitLoop
		EndIf
	Next
	$properties_data[$properties_borderIndex][0] = $aTemp

	$properties_fontButton = GUICtrlCreateLabel("-", 3, 61, 15, 18, BitOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetFont(-1, 12)
	GUICtrlSetOnEvent(-1, "_onFontButton")
	$aTemp = $properties_data[$properties_fontIndex][0]
	For $i=0 to UBound($aTemp)
		If $aTemp[$i] = 0 Then
			$aTemp[$i] = $properties_fontButton
			ExitLoop
		EndIf
	Next
	$properties_data[$properties_fontIndex][0] = $aTemp

	_onBorderButton()
	_onFontButton()

	;vertical line
	Local $itemsHeight = _formPropertyInspector_newitem("", $getHeight)
	$labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1 - 81, 0, 1, $itemsHeight)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	GUICtrlSetOnEvent($oProperties_Ctrls.properties.Text.Hwnd, _ctrl_change_text)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.Name.Hwnd, _ctrl_change_name)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.Left.Hwnd, _ctrl_change_left)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.Top.Hwnd, _ctrl_change_top)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.Width.Hwnd, _ctrl_change_width)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.Height.Hwnd, _ctrl_change_height)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.Color.Hwnd, _ctrl_change_Color)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.FontName.Hwnd, _ctrl_change_FontName)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.FontSize.Hwnd, _ctrl_change_FontSize)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.FontWeight.Hwnd, _ctrl_change_FontWeight)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.Background.Hwnd, _ctrl_change_bkColor)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.BorderColor.Hwnd, _ctrl_change_borderColor)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.BorderSize.Hwnd, _ctrl_change_borderSize)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.Global.Hwnd, _ctrl_change_global)
	#EndRegion ctrl-properties



	GUISwitch($hToolbar)

	;bottom line
;~ 	Local $labelLine = GUICtrlCreateLabel("", $x, $y+$h, $w, 1)
;~ 	GUICtrlSetBkColor(-1, 0xDDDDDD)

EndFunc   ;==>_formPropertyInspector

Func _onFontButton()
	Local $shiftAmount = 60

	Local $hWin = HWnd($oProperties_Ctrls.properties.Hwnd)
	$properties_data[$properties_fontIndex][1] = Not $properties_data[$properties_fontIndex][1]
	For $i = $properties_fontIndex + 1 To $properties_data[0][0]
		If $properties_data[$i][2] = $properties_fontIndex Then
			If $properties_data[$properties_fontIndex][1] Then
				$properties_data[$i][1] = 1
				For $iCtrl In $properties_data[$i][0]
					If $iCtrl = 0 Then ExitLoop
					GUICtrlSetState($iCtrl, $GUI_SHOW)
				Next
				GUICtrlSetData($properties_fontButton, "-")
			Else
				$properties_data[$i][1] = 0
				For $iCtrl In $properties_data[$i][0]
					If $iCtrl = 0 Then ExitLoop
					GUICtrlSetState($iCtrl, $GUI_HIDE)
				Next
				GUICtrlSetData($properties_fontButton, "+")
			EndIf
		Else
			If $properties_data[$properties_fontIndex][1] Then
				For $iCtrl In $properties_data[$i][0]
					If $iCtrl = 0 Then ExitLoop
					Local $aPos = ControlGetPos($hWin, "", $iCtrl)
					ControlMove($hWin, "", $iCtrl, $aPos[0], $aPos[1] + $shiftAmount)
				Next
			Else
				For $iCtrl In $properties_data[$i][0]
					If $iCtrl = 0 Then ExitLoop
					Local $aPos = ControlGetPos($hWin, "", $iCtrl)
					ControlMove($hWin, "", $iCtrl, $aPos[0], $aPos[1] - $shiftAmount)
				Next
			EndIf
		EndIf
	Next

	_WinAPI_RedrawWindow($hWin)
EndFunc   ;==>_onFontButton

Func _onBorderButton()
	Local $shiftAmount = 20

	Local $hWin = HWnd($oProperties_Ctrls.properties.Hwnd)
	$properties_data[$properties_borderIndex][1] = Not $properties_data[$properties_borderIndex][1]
	For $i = $properties_borderIndex + 1 To $properties_data[0][0]
		If $properties_data[$i][2] = $properties_borderIndex Then
			If $properties_data[$properties_borderIndex][1] Then
				$properties_data[$i][1] = 1
				For $iCtrl In $properties_data[$i][0]
					If $iCtrl = 0 Then ExitLoop
					GUICtrlSetState($iCtrl, $GUI_SHOW)
				Next
				GUICtrlSetData($properties_borderButton, "-")
			Else
				$properties_data[$i][1] = 0
				For $iCtrl In $properties_data[$i][0]
					If $iCtrl = 0 Then ExitLoop
					GUICtrlSetState($iCtrl, $GUI_HIDE)
				Next
				GUICtrlSetData($properties_borderButton, "+")
			EndIf
		Else
			If $properties_data[$properties_borderIndex][1] Then
				For $iCtrl In $properties_data[$i][0]
					If $iCtrl = 0 Then ExitLoop
					Local $aPos = ControlGetPos($hWin, "", $iCtrl)
					ControlMove($hWin, "", $iCtrl, $aPos[0], $aPos[1] + $shiftAmount)
				Next
			Else
				For $iCtrl In $properties_data[$i][0]
					If $iCtrl = 0 Then ExitLoop
					Local $aPos = ControlGetPos($hWin, "", $iCtrl)
					ControlMove($hWin, "", $iCtrl, $aPos[0], $aPos[1] - $shiftAmount)
				Next
			EndIf
		EndIf
	Next

	_WinAPI_RedrawWindow($hWin)
EndFunc   ;==>_onFontButton

Func _propertiesShowBorder($show = True)
	Local $aCtrl = $properties_data[$properties_borderIndex][0]
	If (BitAND(GUICtrlGetState($aCtrl[0]), $GUI_SHOW) = $GUI_SHOW) = $show Then Return

	Local $shiftSize = 20
	Local $shiftAmount = $shiftSize

	Local $hWin = HWnd($oProperties_Ctrls.properties.Hwnd)

	If $show Then
		For $iCtrl In $properties_data[$properties_borderIndex][0]
			If $iCtrl = 0 Then ExitLoop
			GUICtrlSetState($iCtrl, $GUI_SHOW)
		Next
	Else
		For $iCtrl In $properties_data[$properties_borderIndex][0]
			If $iCtrl = 0 Then ExitLoop
			GUICtrlSetState($iCtrl, $GUI_HIDE)
		Next
	EndIf

	For $i = $properties_borderIndex + 1 To $properties_data[0][0]
		If $show Then
			If $properties_data[$i][2] = $properties_borderIndex Then
				If $properties_data[$properties_borderIndex][1] Then
					$shiftAmount += $shiftSize
					For $iCtrl In $properties_data[$i][0]
						If $iCtrl = 0 Then ExitLoop
						GUICtrlSetState($iCtrl, $GUI_SHOW)
					Next
				Else
					For $iCtrl In $properties_data[$i][0]
						If $iCtrl = 0 Then ExitLoop
						GUICtrlSetState($iCtrl, $GUI_HIDE)
					Next
				EndIf
			Else
				For $iCtrl In $properties_data[$i][0]
					If $iCtrl = 0 Then ExitLoop
					Local $aPos = ControlGetPos($hWin, "", $iCtrl)
					ControlMove($hWin, "", $iCtrl, $aPos[0], $aPos[1] + $shiftAmount)
				Next
			EndIf
		Else
			If $properties_data[$i][2] = $properties_borderIndex Then
				If $properties_data[$i][1] Then
					$shiftAmount += $shiftSize
				EndIf
				For $iCtrl In $properties_data[$i][0]
					If $iCtrl = 0 Then ExitLoop
					GUICtrlSetState($iCtrl, $GUI_HIDE)
				Next
			Else
				For $iCtrl In $properties_data[$i][0]
					If $iCtrl = 0 Then ExitLoop
					Local $aPos = ControlGetPos($hWin, "", $iCtrl)
					ControlMove($hWin, "", $iCtrl, $aPos[0], $aPos[1] - $shiftAmount)
				Next
			EndIf
		EndIf
	Next

	_WinAPI_RedrawWindow($hWin)
EndFunc   ;==>_propertiesShowBorder


Func _formPropertyInspector_newitem($text, $type = -1, $x = -1, $y = -1, $w = -1, $h = -1, $funcName = -1, $ctrlProp = 0, $show = 1, $parent = -1)
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
	Local $labelWidth = $item_w - $editWidth - $item_x

	Local $label = GUICtrlCreateLabel($text, $item_x, $item_y, $labelWidth - 5 - 1, $item_h - 1, $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 8.5)
	GUICtrlSetColor(-1, 0x333333)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetTip(-1, $text)

	Local $aLineIds[10]
	If $ctrlProp Then
		_addLineID($aLineIds, $label)
	EndIf


	Switch $type
		Case $typeNumber
			Local $edit = GUICtrlCreateInput("", $item_w - $editWidth, $item_y, $editWidth, $item_h - 1, BitOR($ES_AUTOHSCROLL, $ES_NUMBER, $SS_CENTERIMAGE), $WS_EX_TRANSPARENT)
			GUICtrlSetFont(-1, 8.5)
			If $ctrlProp Then
				_addLineID($aLineIds, $edit)
			EndIf
;~ 			GUICtrlCreateUpdown($edit)
		Case $typeReal
			Local $edit = GUICtrlCreateInput("", $item_w - $editWidth, $item_y, $editWidth, $item_h - 1, BitOR($ES_AUTOHSCROLL, $SS_CENTERIMAGE), $WS_EX_TRANSPARENT)
			GUICtrlSetFont(-1, 8.5)
			If $ctrlProp Then
				_addLineID($aLineIds, $edit)
			EndIf
		Case $typeColor
			Local $edit = GUICtrlCreateInput("", $item_w - $editWidth, $item_y, $editWidth - 15, $item_h - 1, BitOR($ES_AUTOHSCROLL, $SS_CENTERIMAGE), $WS_EX_TRANSPARENT)
			GUICtrlSetFont(-1, 8.5)
			If $ctrlProp Then
				_addLineID($aLineIds, $edit)
			EndIf
			Local $pickButton = GUICtrlCreateButton("...", $item_w - 16, $item_y + 2, 18, $item_h - 4)
			If $funcName <> -1 Then
				GUICtrlSetOnEvent($pickButton, $funcName)
			EndIf
			If $ctrlProp Then
				_addLineID($aLineIds, $pickButton)
			EndIf
		Case $typeCheck
			Local $lab = GUICtrlCreateLabel("", $item_w - $editWidth, $item_y, $editWidth, $item_h - 1)
			GUICtrlSetBkColor(-1, 0xFFFFFF)
			GUICtrlSetState(-1, $GUI_DISABLE)
			If $ctrlProp Then
				_addLineID($aLineIds, $lab)
			EndIf
			Local $edit = GUICtrlCreateCheckbox("", $item_w - 45, $item_y, -1, $item_h - 1, BitOR($SS_CENTERIMAGE, $BS_3STATE))
			GUICtrlSetBkColor(-1, 0xFFFFFF)
			If $ctrlProp Then
				_addLineID($aLineIds, $edit)
			EndIf
		Case $typeComboFN
			Local $edit = GUICtrlCreateCombo("", $item_w - $editWidth, $item_y, $editWidth, $item_h - 1, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
			Local $sData = ""
			Local $aData = _WinAPI_EnumFontFamilies(0, '', $ANSI_CHARSET, BitOR($DEVICE_FONTTYPE, $TRUETYPE_FONTTYPE), '@*', 1)
			If Not @error And $aData[0][0] > 0 Then
				$sData = $aData[1][0]
				For $i = 2 To $aData[0][0]
					$sData &= "|" & $aData[$i][0]
				Next
			EndIf
			GUICtrlSetData($edit, $sData)
			If $ctrlProp Then
				_addLineID($aLineIds, $edit)
			EndIf
		Case $typeComboFW
			Local $edit = GUICtrlCreateCombo("", $item_w - $editWidth, $item_y, $editWidth, $item_h - 1, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
			GUICtrlSetData(-1, "Thin|Extra Light|Light|Normal|Medium|Semi Bold|Bold|Extra Bold|Heavy")
			If $ctrlProp Then
				_addLineID($aLineIds, $edit)
			EndIf
		Case $typeHeading
			Local $aStrings = StringSplit($text, "|", $STR_NOCOUNT)
			GUICtrlSetData($label, $aStrings[0])
			GUICtrlSetFont($label, 8.5, $FW_BOLD)

			Local $edit = GUICtrlCreateLabel(" " & $aStrings[1], $item_w - $editWidth, $item_y, $editWidth, $item_h - 1, $SS_CENTERIMAGE)
			GUICtrlSetColor(-1, 0x333333)
			GUICtrlSetBkColor(-1, 0xFFFFFF)
			GUICtrlSetFont($edit, 8.5, $FW_BOLD)
		Case Else
			Local $edit = GUICtrlCreateInput("", $item_w - $editWidth, $item_y, $editWidth, $item_h - 1, BitOR($ES_AUTOHSCROLL, $SS_CENTERIMAGE), $WS_EX_TRANSPARENT)
			If $ctrlProp Then
				_addLineID($aLineIds, $edit)
			EndIf
	EndSwitch

	Local $labelLine = GUICtrlCreateLabel("", 0, $item_y + $item_h - 1, $item_w, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	If $ctrlProp Then
		_addLineID($aLineIds, $labelLine)
		_addPropertyToGlobalArray($aLineIds, $show, $parent, $item_y)
	EndIf

	Return $edit
EndFunc   ;==>_formPropertyInspector_newitem

Func _addLineID(ByRef $aLineData, $id)
	For $i = 0 To UBound($aLineData) - 1
		If $aLineData[$i] <> 0 Then
			ContinueLoop
		Else
			$aLineData[$i] = $id
			ExitLoop
		EndIf
	Next
EndFunc   ;==>_addLineID

Func _addPropertyToGlobalArray($ctrlID, $show, $parent, $yPos)
	If $properties_data[0][0] + 1 > UBound($properties_data) - 1 Then
		ReDim $properties_data[$properties_data[0][0] + 100][10]
	EndIf

	$properties_data[0][0] = $properties_data[0][0] + 1
	$properties_data[$properties_data[0][0]][0] = $ctrlID
	$properties_data[$properties_data[0][0]][1] = $show
	$properties_data[$properties_data[0][0]][2] = $parent
	$properties_data[$properties_data[0][0]][3] = $yPos
EndFunc   ;==>_addPropertyToGlobalArray


Func _showProperties($props = $props_Main)
	If $oSelected.count > 0 Then
		$props = $props_Ctrls
	Else
		$props = $props_Main
	EndIf

	Switch $props
		Case $props_Main
			GUISetState(@SW_HIDE, $oProperties_Ctrls.properties.Hwnd)

			Switch $tabSelected
				Case "Properties"
					GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Main.properties.Hwnd)
					GUISetState(@SW_HIDE, $tabStylesHwnd)

				Case "Styles"
					_generateStyles()
					GUISetState(@SW_HIDE, $oProperties_Main.properties.Hwnd)
					GUISetState(@SW_SHOWNOACTIVATE, $tabStylesHwnd)

			EndSwitch

		Case $props_Ctrls
			GUISetState(@SW_HIDE, $oProperties_Main.properties.Hwnd)

			Switch $tabSelected
				Case "Properties"
					If _isAllLabels() Then
						GUICtrlSetState($oProperties_Ctrls.properties.Color.Hwnd, $GUI_ENABLE)
					Else
						GUICtrlSetState($oProperties_Ctrls.properties.Color.Hwnd, $GUI_DISABLE)
					EndIf

					If _hasBG() Then
						GUICtrlSetState($oProperties_Ctrls.properties.Background.Hwnd, $GUI_ENABLE)
					Else
						GUICtrlSetState($oProperties_Ctrls.properties.Background.Hwnd, $GUI_DISABLE)
					EndIf

					If _isGraphic() Then
						_propertiesShowBorder(True)
					Else
						_propertiesShowBorder(False)
					EndIf

					GUISetState(@SW_HIDE, $tabStylesHwnd)
					GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Ctrls.properties.Hwnd)

				Case "Styles"
					_generateStyles()
					GUISetState(@SW_SHOWNOACTIVATE, $tabStylesHwnd)
					GUISetState(@SW_HIDE, $oProperties_Ctrls.properties.Hwnd)

			EndSwitch

		Case Else
			GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Main.properties.Hwnd)
			GUISetState(@SW_HIDE, $tabStylesHwnd)
			GUISetState(@SW_HIDE, $oProperties_Ctrls.properties.Hwnd)
;~ 			_GUIScrollbars_Generate($oProperties_Main.Hwnd, $w - 2, $h)
	EndSwitch

	GUISwitch($hGUI)
EndFunc   ;==>_showProperties

Func _generateStyles($w = Default, $h = Default, $x = Default, $y = Default)
	Static $left, $top, $width, $height

	If $w = Default Then
		GUIDelete($tabStylesHwnd)
	EndIf

	If $x <> Default Then $left = $x
	If $y <> Default Then $top = $y
	If $w <> Default Then $width = $w
	If $h <> Default Then $height = $h

	$tabStylesHwnd = GUICreate("", $width, $height - 2, $left, $top + 1, $WS_POPUP, $WS_EX_MDICHILD, $hToolbar)
	GUISetBkColor(0xFFFFFF)
	Local $ret = _GUIScrollbars_Generate($tabStylesHwnd, $width - 2, $height + 350)

	Local $iScrollbarWidth = $__g_aSB_WindowInfo[0][5]

	;End line
	Local $labelLine = GUICtrlCreateLabel("", $width - $iScrollbarWidth - 1, 0, 1, $height + 20)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	Local $props
	If $oSelected.count > 0 Then
		$props = $props_Ctrls
	Else
		$props = $props_Main
	EndIf

	;items - generated dynamically based on current selection
	Local $isVisible = BitAND(WinGetState($tabStylesHwnd), $WIN_STATE_VISIBLE)
	If $isVisible Then
		_SendMessage($tabStylesHwnd, $WM_SETREDRAW, False)
	EndIf

	;loop through and generate common styles
	Switch $props
		Case $props_Main
			Local $i = 0, $objProp
			$oProperties_Main.styles.RemoveAll()
			For $sStyleString In $oMain.styles.Keys()
				$objProp = _objProperty($sStyleString, "Checkbox")
				If $i = 0 Then
					$objProp.Hwnd = _formPropertyInspector_newitem($sStyleString, $typeCheck, 5, 1, $width - $iScrollbarWidth - 1, 20)
				Else
					$objProp.Hwnd = _formPropertyInspector_newitem($sStyleString, $typeCheck, -1, -1, -1, -1)
				EndIf
				GUICtrlSetOnEvent($objProp.Hwnd, "_onStyleChange")
;~ 				$objProp.value = $oMain.styles.Item($sStyleString)
				$objProp.value = (StringRegExp($oMain.styleString, '(?:^|,\s)\$' & $sStyleString & '(?:,|$)')) ? $GUI_CHECKED : $GUI_UNCHECKED
				$oProperties_Main.styles.Add($sStyleString, $objProp)
				$i += 1
			Next

		Case $props_Ctrls
			;find selected control with fewest styles
			Local $stylesObj
			For $oCtrl In $oSelected.ctrls.Items()
				If Not IsObj($stylesObj) Then
					$stylesObj = $oCtrl
				Else
					If $oCtrl.styles.Count < $stylesObj.styles.Count Then
						$stylesObj = $oCtrl
					EndIf
				EndIf
			Next

			Local $aStyles[100], $addStyle = True, $i = 0
			;build list of common styles
			For $sStyleString In $stylesObj.styles.Keys()
				For $oCtrl In $oSelected.ctrls.Items()
					If Not $oCtrl.styles.Exists($sStyleString) Then
						$addStyle = False
						ExitLoop
					EndIf
				Next
				If $addStyle Then
					$aStyles[$i] = $sStyleString
					$i += 1
				EndIf
			Next
;~ 			_ArrayDisplay($aStyles)

			;loop through and generate common styles
			$i = 0
			Local $objProp
			$oProperties_Ctrls.styles.RemoveAll()
			For $sStyleString In $aStyles
				If $sStyleString = "" Then ExitLoop
				$objProp = _objProperty($sStyleString, "Checkbox")
				If $i = 0 Then
					$objProp.Hwnd = _formPropertyInspector_newitem($sStyleString, $typeCheck, 5, 1, $width - $iScrollbarWidth - 1, 20)
				Else
					$objProp.Hwnd = _formPropertyInspector_newitem($sStyleString, $typeCheck, -1, -1, -1, -1)
				EndIf
				GUICtrlSetOnEvent($objProp.Hwnd, "_onStyleChange")

				;get checked state form controls
				Local $checkValue = -1
				For $oCtrl In $oSelected.ctrls.Items()
;~ 					If $oCtrl.styles.Item($sStyleString) Then
					If StringRegExp($oCtrl.styleString, '(?:^|,\s)\$' & $sStyleString & '(?:,|$)') Then
						If $checkValue = $GUI_UNCHECKED Then
							$checkValue = $GUI_INDETERMINATE
							ExitLoop
						Else
							$checkValue = $GUI_CHECKED
						EndIf
					Else
						If $checkValue = $GUI_CHECKED Then
							$checkValue = $GUI_INDETERMINATE
							ExitLoop
						Else
							$checkValue = $GUI_UNCHECKED
						EndIf
					EndIf
				Next
				$objProp.value = $checkValue
				$oProperties_Ctrls.styles.Add($sStyleString, $objProp)
				$i += 1
			Next

	EndSwitch

	;vertical line
	Local $itemsHeight = _formPropertyInspector_newitem("", $getHeight)
	$labelLine = GUICtrlCreateLabel("", $width - $iScrollbarWidth - 1 - 81, 0, 1, $itemsHeight)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	If $isVisible Then
		_SendMessage($tabStylesHwnd, $WM_SETREDRAW, True)
		_WinAPI_RedrawWindow($tabStylesHwnd)
	EndIf

	GUISwitch($hGUI)
;~ 	GUISwitch($hToolbar)
EndFunc   ;==>_generateStyles

Func _isAllLabels()
	If $oSelected.count > 0 Then
		For $oCtrl In $oSelected.ctrls.Items()
			Switch $oCtrl.Type
				Case "Label", "Input", "Edit"
					ContinueLoop

				Case Else
					Return False

			EndSwitch
		Next
	EndIf

	Return True
EndFunc   ;==>_isAllLabels

Func _isGraphic()
	If $oSelected.count > 0 Then
		For $oCtrl In $oSelected.ctrls.Items()
			Switch $oCtrl.Type
				Case "Rect", "Ellipse", "Line"
					ContinueLoop

				Case Else
					Return False

			EndSwitch
		Next
	EndIf

	Return True
EndFunc   ;==>_isGraphic


Func _hasBG()
	If $oSelected.count > 0 Then
		For $oCtrl In $oSelected.ctrls.Items()
			Switch $oCtrl.Type
				Case "Label", "Checkbox", "Radio", "Edit", "Input", "Rect", "Ellipse"
					ContinueLoop

				Case Else
					Return False

			EndSwitch
		Next
	EndIf

	Return True
EndFunc   ;==>_hasBG


Func _containsMenus()
	If $oSelected.count > 0 Then
		For $oCtrl In $oSelected.ctrls.Items()
			If $oCtrl.Type <> "Menu" Then
				Return True
			EndIf
		Next
	EndIf

	Return False
EndFunc   ;==>_containsMenus

Func _onTabProperties()
	$tabSelected = "Properties"
	GUICtrlSetBkColor($tabProperties, 0xEEEEEE)
	GUICtrlSetBkColor($tabStyles, 0xD6D6D6)
	_showProperties()
EndFunc   ;==>_onTabProperties

Func _onTabStyles()
	$tabSelected = "Styles"
	GUICtrlSetBkColor($tabProperties, 0xD6D6D6)
	GUICtrlSetBkColor($tabStyles, 0xEEEEEE)
	_showProperties()
EndFunc   ;==>_onTabStyles

Func _onStyleChange()
;~ 	Local $value = BitAND(GUICtrlRead(@GUI_CtrlId), $GUI_CHECKED) = $GUI_CHECKED
	Local $value = GUICtrlRead(@GUI_CtrlId)

	If BitAND($value, $GUI_UNCHECKED) = $GUI_UNCHECKED Then
		GUICtrlSetState(@GUI_CtrlId, $GUI_CHECKED)
		$value = $GUI_CHECKED
	Else
		GUICtrlSetState(@GUI_CtrlId, $GUI_UNCHECKED)
		$value = $GUI_UNCHECKED
	EndIf

	Local $props
	If $oSelected.count > 0 Then
		$props = $props_Ctrls
	Else
		$props = $props_Main
	EndIf

	Switch $props
		Case $props_Main
			For $oCtrl In $oProperties_Main.styles.Items()
				If $oCtrl.Hwnd = @GUI_CtrlId Then
					$text = $oCtrl.name
;~ 					If $oMain.styles.Item($text) <> $value Then
					If StringRegExp($oMain.styleString, '(?:^|,\s)\$' & $text & '(?:,|$)') <> ($value = $GUI_CHECKED) Then
;~ 						$oMain.styles.Item($text) = $value
						If ($value = $GUI_CHECKED) Then
							If $oMain.styleString = "" Then
								$oMain.styleString = "$" & $text
							ElseIf Not StringInStr($oMain.styleString, $text) Then
								$oMain.styleString &= ", " & "$" & $text
							EndIf
						Else
							;middle of string
							$oMain.styleString = StringRegExpReplace($oMain.styleString, '(\$' & $text & ', )', "")
							;start or end of string
							$oMain.styleString = StringRegExpReplace($oMain.styleString, '((?:^|,\s)\$' & $text & '$)', "")
						EndIf
					EndIf
					ExitLoop
				EndIf
			Next

		Case $props_Ctrls
			Local $iOldStyle, $oThisCtrl, $CtrlValue
			For $oCtrl In $oProperties_Ctrls.styles.Items()
				If $oCtrl.Hwnd = @GUI_CtrlId Then
					$text = $oCtrl.name

					For $oThisCtrl In $oSelected.ctrls.Items()
						$CtrlValue = StringRegExp($oThisCtrl.styleString, '(?:^|,\s)\$' & $text & '(?:,|$)')
						If $CtrlValue <> ($value = $GUI_CHECKED) Then
;~ 							$oThisCtrl.styles.Item($text) = $value
							$iOldStyle = _WinAPI_GetWindowLong(GUICtrlGetHandle($oThisCtrl.Hwnd), $GWL_STYLE)
							If ($value = $GUI_CHECKED) Then
								If $oThisCtrl.styleString = "" Then
									$oThisCtrl.styleString = "$" & $text
								ElseIf Not StringRegExp($oThisCtrl.styleString, '(?:^|,\s)\$' & $text & '(?:,|$)') Then
									$oThisCtrl.styleString &= ", " & "$" & $text
								EndIf
								GUICtrlSetStyle($oThisCtrl.Hwnd, BitOR($iOldStyle, Eval($text)))
							Else
								;middle of string
								$oThisCtrl.styleString = StringRegExpReplace($oThisCtrl.styleString, '(\$' & $text & ', )', "")
								;start or end of string
								$oThisCtrl.styleString = StringRegExpReplace($oThisCtrl.styleString, '((?:^|,\s)\$' & $text & '$)', "")
								GUICtrlSetStyle($oThisCtrl.Hwnd, BitXOR($iOldStyle, Eval($text)))
							EndIf
						EndIf
					Next

					ExitLoop
				EndIf
			Next

	EndSwitch

	_refreshGenerateCode()
	$oMain.hasChanged = True

;~ 	$oProperties_Main.styles.ctrls.Item($text).value = $value
;~ 	$oMain.styles.Item($text) = $value
EndFunc   ;==>_onStyleChange

Func _onCheckboxChange($ctrlID)
	Local $value = GUICtrlRead($ctrlID)

	If BitAND($value, $GUI_UNCHECKED) = $GUI_UNCHECKED Then
		GUICtrlSetState($ctrlID, $GUI_CHECKED)
		$value = $GUI_CHECKED
	Else
		GUICtrlSetState($ctrlID, $GUI_UNCHECKED)
		$value = $GUI_UNCHECKED
	EndIf

	Return $value
EndFunc   ;==>_onCheckboxChange
