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
	;tabs
	Local $labelLine = GUICtrlCreateLabel("", $x, $y, 70+50, 1)
	GUICtrlSetBkColor(-1, 0xC5C5C5)

	Local $tabHeight = 20
	$tabProperties = GUICtrlCreateLabel("Properties", $x, $y+1, 70, $tabHeight-1, BitOR($GUI_SS_DEFAULT_LABEL, $SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetBkColor(-1, 0xEEEEEE)
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetOnEvent(-1, "_onTabProperties")

	$labelLine = GUICtrlCreateLabel("", $x + 70, $y, 1, $tabHeight)
	GUICtrlSetBkColor(-1, 0xC5C5C5)

	$tabStyles = GUICtrlCreateLabel("Styles", $x+71, $y+1, 50, $tabHeight-1, BitOR($GUI_SS_DEFAULT_LABEL, $SS_CENTER, $SS_CENTERIMAGE))
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
	Local $guiHandle = GUICreate("", $w, $h - 2, $x, $y + 1, $WS_POPUP, $WS_EX_MDICHILD, $hToolbar)
	GUISetBkColor(0xFFFFFF)
	Local $ret = _GUIScrollbars_Generate($guiHandle, $w - 2, $h + 20)
	$oProperties_Main.properties.Hwnd = $guiHandle

	Local $iScrollbarWidth = $__g_aSB_WindowInfo[0][5]

	;End line
	Local $labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1, 0, 1, $h + 20)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;items
	$oProperties_Main.properties.Title.Hwnd = _formPropertyInspector_newitem("Title", $typeText, 0, 1, $w - $iScrollbarWidth - 1, 20)
	$oProperties_Main.properties.Name.Hwnd = _formPropertyInspector_newitem("Name", $typeText)
	$oProperties_Main.properties.Left.Hwnd = _formPropertyInspector_newitem("Left", $typeNumber)
	$oProperties_Main.properties.Top.Hwnd = _formPropertyInspector_newitem("Top", $typeNumber)
	$oProperties_Main.properties.Width.Hwnd = _formPropertyInspector_newitem("Width", $typeNumber)
	$oProperties_Main.properties.Height.Hwnd = _formPropertyInspector_newitem("Height", $typeNumber)
	$oProperties_Main.properties.Background.Hwnd = _formPropertyInspector_newitem("Background", $typeColor, -1, -1, -1, -1, "_main_pick_bkColor")

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
	_generateStyles($w, $h - 2, $x, $y + 1)

	#EndRegion main-styles



	#Region ctrl-properties
	;create the child gui for controls properties
	$guiHandle = GUICreate("", $w, $h - 1, $x, $y + 1, $WS_POPUP, $WS_EX_MDICHILD, $hToolbar)
	GUISetBkColor(0xFFFFFF)
	_GUIScrollbars_Generate($guiHandle, $w - 2, $h)
	$oProperties_Ctrls.properties.Hwnd = $guiHandle

	;End line
	Local $labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1, 0, 1, $h + 20)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;items
	$oProperties_Ctrls.properties.Text.Hwnd = _formPropertyInspector_newitem("Text", $typeText, 0, 1, $w - $iScrollbarWidth - 1, 20)
	$oProperties_Ctrls.properties.Name.Hwnd = _formPropertyInspector_newitem("Name", $typeText)
	$oProperties_Ctrls.properties.Left.Hwnd = _formPropertyInspector_newitem("Left", $typeNumber)
	$oProperties_Ctrls.properties.Top.Hwnd = _formPropertyInspector_newitem("Top", $typeNumber)
	$oProperties_Ctrls.properties.Width.Hwnd = _formPropertyInspector_newitem("Width", $typeNumber)
	$oProperties_Ctrls.properties.Height.Hwnd = _formPropertyInspector_newitem("Height", $typeNumber)
	$oProperties_Ctrls.properties.Color.Hwnd = _formPropertyInspector_newitem("Font Color", $typeColor, -1, -1, -1, -1, "_ctrl_pick_Color")
	$oProperties_Ctrls.properties.Background.Hwnd = _formPropertyInspector_newitem("Background", $typeColor, -1, -1, -1, -1, "_ctrl_pick_bkColor")
	$oProperties_Ctrls.properties.Global.Hwnd = _formPropertyInspector_newitem("Global", $typeCheck, -1, -1, -1, -1)

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
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.Background.Hwnd, _ctrl_change_bkColor)
	GUICtrlSetOnEvent($oProperties_Ctrls.properties.Global.Hwnd, _ctrl_change_global)
	#EndRegion ctrl-properties



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
	GUICtrlSetTip(-1, $text)

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
		Local $edit = GUICtrlCreateCheckbox("", $item_x + $item_w - 45, $item_y, -1, $item_h - 1, BitOR($SS_CENTERIMAGE, $BS_3STATE))
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
	_SendMessage($tabStylesHwnd, $WM_SETREDRAW, False)

	;loop through and generate common styles
	Switch $props
		Case $props_Main
			Local $i = 0, $objProp
			$oProperties_Main.styles.RemoveAll()
			For $sStyleString In $oMain.styles.Keys()
				$objProp = _objProperty($sStyleString, "Checkbox")
				If $i = 0 Then
					$objProp.Hwnd = _formPropertyInspector_newitem($sStyleString, $typeCheck, 0, 1, $width - $iScrollbarWidth - 1, 20)
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
					$objProp.Hwnd = _formPropertyInspector_newitem($sStyleString, $typeCheck, 0, 1, $width - $iScrollbarWidth - 1, 20)
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

	_SendMessage($tabStylesHwnd, $WM_SETREDRAW, True)
	_WinAPI_RedrawWindow($tabStylesHwnd)

	GUISwitch($hGUI)
;~ 	GUISwitch($hToolbar)
EndFunc

Func _isAllLabels()
	If $oSelected.count > 0 Then
		For $oCtrl In $oSelected.ctrls.Items()
			If $oCtrl.Type <> "Label" Then
				Return False
			EndIf
		Next
	EndIf

	Return True
EndFunc   ;==>_isAllLabels


Func _hasBG()
	If $oSelected.count > 0 Then
		For $oCtrl In $oSelected.ctrls.Items()
			Switch $oCtrl.Type
				Case "Label", "Checkbox", "Radio"
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
EndFunc

Func _onTabStyles()
	$tabSelected = "Styles"
	GUICtrlSetBkColor($tabProperties, 0xD6D6D6)
	GUICtrlSetBkColor($tabStyles, 0xEEEEEE)
	_showProperties()
EndFunc

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
EndFunc

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
EndFunc