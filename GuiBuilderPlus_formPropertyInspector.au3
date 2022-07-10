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
	Local $tabHeight = 20
	GUICtrlCreateLabel("Properties", $x, $y, 70, $tabHeight)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetOnEvent(-1, "_onTabProperties")

	Local $labelLine = GUICtrlCreateLabel("", $x + 70, $y, 1, $tabHeight)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	GUICtrlCreateLabel("Styles", $x+71, $y, 50, $tabHeight)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetOnEvent(-1, "_onTabStyles")

	$labelLine = GUICtrlCreateLabel("", $x + 71 + 50, $y, 1, $tabHeight)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	$labelLine = GUICtrlCreateLabel("", $x, $y + $tabHeight, $w, 1)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

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
	Local $guiHandle = GUICreate("", $w, $h - 2, $x, $y + 1, $WS_POPUP, $WS_EX_MDICHILD, $hToolbar)
	GUISetBkColor(0xFFFFFF)
	Local $ret = _GUIScrollbars_Generate($guiHandle, $w - 2, $h + 300)
	$oProperties_Main.styles.Hwnd = $guiHandle

	Local $iScrollbarWidth = $__g_aSB_WindowInfo[0][5]

	;End line
	Local $labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1, 0, 1, $h + 20)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	;items
	$i = 0
	For $oStyleCtrl In $oProperties_Main.styles.ctrls.Items()
		If $i = 0 Then
			$oStyleCtrl.Hwnd = _formPropertyInspector_newitem($oStyleCtrl.name, $typeCheck, 0, 1, $w - $iScrollbarWidth - 1, 20)
		Else
			$oStyleCtrl.Hwnd = _formPropertyInspector_newitem($oStyleCtrl.name, $typeCheck, -1, -1, -1, -1)
		EndIf
		GUICtrlSetOnEvent($oStyleCtrl.Hwnd, "_onStyleMain")
		$oStyleCtrl.value = $oMain.styles.Item($oStyleCtrl.name)
		$i += 1
	Next

	;vertical line
	Local $itemsHeight = _formPropertyInspector_newitem("", $getHeight)
	$labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1 - 81, 0, 1, $itemsHeight)
	GUICtrlSetBkColor(-1, 0xDDDDDD)

	#EndRegion main-styles



	#Region ctrl-properties
	;create the child gui for controls properties
	$guiHandle = GUICreate("", $w, $h - 1, $x, $y + 1, $WS_POPUP, $WS_EX_MDICHILD, $hToolbar)
	GUISetBkColor(0xFFFFFF)
	_GUIScrollbars_Generate($guiHandle, $w - 2, $h)
	$oProperties_Ctrls.Hwnd = $guiHandle

	;End line
	Local $labelLine = GUICtrlCreateLabel("", $w - $iScrollbarWidth - 1, 0, 1, $h + 20)
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
	$oProperties_Ctrls.Global.Hwnd = _formPropertyInspector_newitem("Global", $typeCheck, -1, -1, -1, -1)

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
	GUICtrlSetOnEvent($oProperties_Ctrls.Global.Hwnd, _ctrl_change_global)
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
	If $oSelected.count > 0 Then
		$props = $props_Ctrls
	Else
		$props = $props_Main
	EndIf

	Switch $props
		Case $props_Main
			Switch $tabSelected
				Case "Properties"
					GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Main.properties.Hwnd)
					GUISetState(@SW_HIDE, $oProperties_Main.styles.Hwnd)
					GUISetState(@SW_HIDE, $oProperties_Ctrls.Hwnd)

				Case "Styles"
					GUISetState(@SW_HIDE, $oProperties_Main.properties.Hwnd)
					GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Main.styles.Hwnd)
					GUISetState(@SW_HIDE, $oProperties_Ctrls.Hwnd)

			EndSwitch

		Case $props_Ctrls
;~ 			If _containsMenus() Then
;~ 				GUICtrlSetState($oProperties_Ctrls.Left.Hwnd, $GUI_DISABLE)
;~ 				GUICtrlSetState($oProperties_Ctrls.Top.Hwnd, $GUI_DISABLE)
;~ 				GUICtrlSetState($oProperties_Ctrls.Width.Hwnd, $GUI_DISABLE)
;~ 				GUICtrlSetState($oProperties_Ctrls.Height.Hwnd, $GUI_DISABLE)
;~ 			Else
;~ 				GUICtrlSetState($oProperties_Ctrls.Left.Hwnd, $GUI_ENABLE)
;~ 				GUICtrlSetState($oProperties_Ctrls.Top.Hwnd, $GUI_ENABLE)
;~ 				GUICtrlSetState($oProperties_Ctrls.Width.Hwnd, $GUI_ENABLE)
;~ 				GUICtrlSetState($oProperties_Ctrls.Height.Hwnd, $GUI_ENABLE)
;~ 			EndIf

			If _isAllLabels() Then
				GUICtrlSetState($oProperties_Ctrls.Color.Hwnd, $GUI_ENABLE)
			Else
				GUICtrlSetState($oProperties_Ctrls.Color.Hwnd, $GUI_DISABLE)
			EndIf

			If _hasBG() Then
				GUICtrlSetState($oProperties_Ctrls.Background.Hwnd, $GUI_ENABLE)
			Else
				GUICtrlSetState($oProperties_Ctrls.Background.Hwnd, $GUI_DISABLE)
			EndIf

			GUISetState(@SW_HIDE, $oProperties_Main.properties.Hwnd)
			GUISetState(@SW_HIDE, $oProperties_Main.styles.Hwnd)
			GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Ctrls.Hwnd)
;~ 			_GUIScrollbars_Generate($oProperties_Ctrls.Hwnd, $w - 2, $h)

		Case Else
			GUISetState(@SW_SHOWNOACTIVATE, $oProperties_Main.properties.Hwnd)
			GUISetState(@SW_HIDE, $oProperties_Main.styles.Hwnd)
			GUISetState(@SW_HIDE, $oProperties_Ctrls.Hwnd)
;~ 			_GUIScrollbars_Generate($oProperties_Main.Hwnd, $w - 2, $h)
	EndSwitch

	GUISwitch($hGUI)
EndFunc   ;==>_showProperties

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
	_showProperties()
EndFunc

Func _onTabStyles()
	$tabSelected = "Styles"
	_showProperties()
EndFunc

Func _onStyleMain()
	Local $value = BitAND(GUICtrlRead(@GUI_CtrlId), $GUI_CHECKED) = $GUI_CHECKED

	For $oCtrl In $oProperties_Main.styles.ctrls.Items()
		If $oCtrl.Hwnd = @GUI_CtrlId Then
			$text = $oCtrl.name
			$oMain.styles.Item($text) = $value
			ExitLoop
		EndIf
	Next

	_refreshGenerateCode()
	$oMain.hasChanged = True

;~ 	$oProperties_Main.styles.ctrls.Item($text).value = $value
;~ 	$oMain.styles.Item($text) = $value
EndFunc
