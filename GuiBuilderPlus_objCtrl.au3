; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_objCtrl.au3
; Description ...: Create and manage objects for control components
; ===============================================================================================================================


#Region objCtrls
;------------------------------------------------------------------------------
; Title...........: _objCtrls
; Description.....:	Main container for all controls
;					with additional properties and methods
;------------------------------------------------------------------------------
Func _objCtrls($isSelection = False)
	Local $oObject = _AutoItObject_Create()

	Local $oDict = ObjCreate("Scripting.Dictionary")

	_AutoItObject_AddProperty($oObject, "mode", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "resizeStartLeft", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "resizeStartTop", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "CurrentType", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "menuCount", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "hasMenu", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "IPCount", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "hasIP", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "hasTab", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "isSelection", $ELSCOPE_PUBLIC, $isSelection)
	_AutoItObject_AddProperty($oObject, "drawHwnd", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "clickedCtrl", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "styleList", $ELSCOPE_PUBLIC, _Styles_Main)
	;actual list of controls
	_AutoItObject_AddProperty($oObject, "ctrls", $ELSCOPE_PUBLIC, $oDict)

	Local $oTypeCountList = ObjCreate("Scripting.Dictionary")
	$oTypeCountList.Add("Button", 0)
	$oTypeCountList.Add("Group", 0)
	$oTypeCountList.Add("Checkbox", 0)
	$oTypeCountList.Add("Radio", 0)
	$oTypeCountList.Add("Edit", 0)
	$oTypeCountList.Add("Input", 0)
	$oTypeCountList.Add("Label", 0)
	$oTypeCountList.Add("List", 0)
	$oTypeCountList.Add("Combo", 0)
	$oTypeCountList.Add("Date", 0)
	$oTypeCountList.Add("Slider", 0)
	$oTypeCountList.Add("Tab", 0)
	$oTypeCountList.Add("Menu", 0)
	$oTypeCountList.Add("TreeView", 0)
	$oTypeCountList.Add("Updown", 0)
	$oTypeCountList.Add("Progress", 0)
	$oTypeCountList.Add("Pic", 0)
	$oTypeCountList.Add("Avi", 0)
	$oTypeCountList.Add("Icon", 0)
	$oTypeCountList.Add("IP", 0)
	$oTypeCountList.Add("ListView", 0)
	$oTypeCountList.Add("Rect", 0)
	$oTypeCountList.Add("Ellipse", 0)
	$oTypeCountList.Add("Line", 0)
	_AutoItObject_AddProperty($oObject, "typeCounts", $ELSCOPE_PUBLIC, $oTypeCountList)

	_AutoItObject_AddMethod($oObject, "createNew", "_objCtrls_createNew")
	_AutoItObject_AddMethod($oObject, "count", "_objCtrls_count")
	_AutoItObject_AddMethod($oObject, "add", "_objCtrls_add")
	_AutoItObject_AddMethod($oObject, "remove", "_objCtrls_remove")
	_AutoItObject_AddMethod($oObject, "removeAll", "_objCtrls_removeAll")
	_AutoItObject_AddMethod($oObject, "get", "_objCtrls_get")
	_AutoItObject_AddMethod($oObject, "getFirst", "_objCtrls_getFist")
	_AutoItObject_AddMethod($oObject, "getLast", "_objCtrls_getLast")
	_AutoItObject_AddMethod($oObject, "getCopy", "_objCtrls_getCopy")
	_AutoItObject_AddMethod($oObject, "exists", "_objCtrls_exists")
	_AutoItObject_AddMethod($oObject, "incTypeCount", "_objCtrls_incTypeCount")
	_AutoItObject_AddMethod($oObject, "decTypeCount", "_objCtrls_decTypeCount")
	_AutoItObject_AddMethod($oObject, "getTypeCount", "_objCtrls_getTypeCount")
	_AutoItObject_AddMethod($oObject, "moveUp", "_objCtrls_moveUp")
	_AutoItObject_AddMethod($oObject, "moveDown", "_objCtrls_moveDown")
	_AutoItObject_AddMethod($oObject, "startResizing", "_objCtrls_startResizing")

	Return $oObject
EndFunc   ;==>_objCtrls

Func _objCtrls_createNew($oSelf)
	#forceref $oSelf
	Local $oObject = _objCtrl($oSelf)

	Return $oObject
EndFunc   ;==>_objCtrls_createNew

Func _objCtrls_count($oSelf)
	Return $oSelf.ctrls.Count
EndFunc   ;==>_objCtrls_count

Func _objCtrls_add($oSelf, $objCtrl, $hParent = -1)
	#forceref $oSelf

	If $oSelf.isSelection Then
		_AutoItObject_AddProperty($objCtrl, "grippies", $ELSCOPE_PUBLIC, _objGrippies($objCtrl, $oSelf))
	EndIf

	Switch $objCtrl.Type
		Case "Tab"
			$objCtrl.styles = _Styles_Tab()
		Case "Group"
			$objCtrl.styles = _Styles_Group()
		Case "Button"
			$objCtrl.styles = _Styles_Button()
		Case "Checkbox"
			$objCtrl.styles = _Styles_Checkbox()
		Case "Radio"
			$objCtrl.styles = _Styles_Radio()
		Case "Edit"
			$objCtrl.styles = _Styles_Edit()
		Case "Input"
			$objCtrl.styles = _Styles_Input()
		Case "Label"
			$objCtrl.styles = _Styles_Label()
			$objCtrl.styles.Item("SS_CENTER") = True
		Case "Updown"
			$objCtrl.styles = _Styles_UpDown()
		Case "List"
			$objCtrl.styles = _Styles_List()
		Case "Combo"
			$objCtrl.styles = _Styles_Combo()
		Case "Date"
			$objCtrl.styles = _Styles_Date()
		Case "TreeView"
			$objCtrl.styles = _Styles_TreeView()
		Case "Progress"
			$objCtrl.styles = _Styles_Progress()
		Case "Avi"
			$objCtrl.styles = _Styles_Avi()
		Case "Icon"
			$objCtrl.styles = _Styles_Icon()
		Case "Pic"
			$objCtrl.styles = _Styles_Pic()
		Case "Slider"
			$objCtrl.styles = _Styles_Slider()
		Case "IP"
			$objCtrl.styles = _Styles_IP()
		Case "ListView"
			$objCtrl.styles = _Styles_ListView()
		Case "Rect", "Ellipse", "Line"
			$objCtrl.styles = _Styles_Label()
	EndSwitch

	$oSelf.ctrls.Add($objCtrl.Hwnd, $objCtrl)

	If $objCtrl.Type = "Menu" Then
		$oSelf.menuCount = $oSelf.menuCount + 1
		$oSelf.hasMenu = True
	EndIf

	If $objCtrl.Type = "IP" Then
		$oSelf.IPCount = $oSelf.IPCount + 1
		$oSelf.hasIP = True
	EndIf

	If $objCtrl.Type = "Tab" Then
		$oSelf.hasTab = True
	EndIf

	If $hParent <> -1 Then
		For $oThisCtrl In $oSelf.ctrls.Items()
			If $oThisCtrl.Hwnd = $hParent Then
				Switch $oThisCtrl.Type
					Case "Tab"
						Local $iTabFocus = _GUICtrlTab_GetCurSel($oThisCtrl.Hwnd)
						If $iTabFocus >= 0 Then

							Local $tabID = $oThisCtrl.Tabs.at($iTabFocus)
							$oTabItem = $oCtrls.get($tabID)

							$oTabItem.ctrls.Add($objCtrl.Hwnd, $objCtrl)
							$objCtrl.CtrlParent = $oTabItem.Hwnd
							$oTabItem.CtrlParent = $oThisCtrl.Hwnd
						EndIf

					Case "Group"
						$oThisCtrl.ctrls.Add($objCtrl.Hwnd, $objCtrl)
						$objCtrl.CtrlParent = $oThisCtrl.Hwnd

				EndSwitch
			EndIf
		Next
	EndIf

	$oSelf.incTypeCount($objCtrl.Type)

	Return $oSelf.count

EndFunc   ;==>_objCtrls_add

Func _objCtrls_remove($oSelf, $Hwnd)
	#forceref $oSelf

	Local $bFoundItem = $oSelf.ctrls.Exists($Hwnd)

	Local $type

	If $bFoundItem Then
		Local $thisCtrl = $oSelf.ctrls.Item($Hwnd)

		If Not $oSelf.isSelection Then
			; if this control was on a tab, remove the tracking
			If $thisCtrl.CtrlParent <> 0 Then
				Local $oTabItem = $oCtrls.get($thisCtrl.CtrlParent)
				If IsObj($oTabItem) Then
					$oTabItem.ctrls.Remove($thisCtrl.Hwnd)
				EndIf
			EndIf
		EndIf

		If $thisCtrl.Type = "Menu" Then
			$oSelf.menuCount = $oSelf.menuCount - 1
			If $oSelf.menuCount >= 1 Then
				$oSelf.hasMenu = True
			Else
				$oSelf.hasMenu = False
			EndIf
		ElseIf $thisCtrl.Type = "IP" Then
			$oSelf.IPCount = $oSelf.IPCount - 1
			If $oSelf.IPCount >= 1 Then
				$oSelf.hasIP = True
			Else
				$oSelf.hasIP = False
			EndIf
		ElseIf $thisCtrl.Type = "Tab" Then
			$oSelf.hasTab = False
		EndIf

		If $oSelf.isSelection Then
			$thisCtrl.grippies.delete()
		EndIf
		$type = $thisCtrl.Type
		$oSelf.ctrls.Remove($Hwnd)
	EndIf

	If Not @error Then
		$oSelf.decTypeCount($type)
		Return $oSelf.count
	Else
		Return -1
	EndIf

EndFunc   ;==>_objCtrls_remove

Func _objCtrls_removeAll($oSelf)
	#forceref $oSelf

	;loop through and delete all the grippies
	For $oItem In $oSelf.ctrls.Items()
		If $oSelf.isSelection Then
			$oItem.grippies.delete()
		EndIf
	Next

	$oSelf.ctrls = 0
	$oSelf.ctrls = ObjCreate("Scripting.Dictionary")
	$oSelf.menuCount = 0
	$oSelf.hasMenu = False
	$oSelf.hasTab = False
EndFunc   ;==>_objCtrls_removeAll

Func _objCtrls_get($oSelf, $Hwnd)
	#forceref $oSelf

	If $oSelf.ctrls.Exists($Hwnd) Then
		Return $oSelf.ctrls.Item($Hwnd)
	Else
		Return -1
	EndIf
EndFunc   ;==>_objCtrls_get

Func _objCtrls_getFist($oSelf)
	#forceref $oSelf
	Local $aItems = $oSelf.ctrls.Items()

	If IsArray($aItems) And UBound($aItems) > 0 Then
		Return $aItems[0]
	Else
		Return -1
	EndIf
EndFunc   ;==>_objCtrls_getFist

Func _objCtrls_getLast($oSelf)
	#forceref $oSelf

	Local $aItems = $oSelf.ctrls.Items()

	If IsArray($aItems) And UBound($aItems) > 0 Then
		Return $aItems[$oSelf.ctrls.Count - 1]
	Else
		Return -1
	EndIf
EndFunc   ;==>_objCtrls_getLast

Func _objCtrls_getCopy($oSelf, $Hwnd)
	#forceref $oSelf

	Local $oCtrl = $oSelf.get($Hwnd)
	If IsObj($oCtrl) Then
		Return _AutoItObject_Create($oCtrl)
	Else
		Return -1
	EndIf
EndFunc   ;==>_objCtrls_getCopy

Func _objCtrls_exists($oSelf, $Hwnd)
	#forceref $oSelf

	If $oSelf.ctrls.Exists($Hwnd) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>_objCtrls_exists

Func _objCtrls_incTypeCount($oSelf, $sType)
	#forceref $oSelf

	Local $value = $oSelf.typeCounts.Item($sType)
	$oSelf.typeCounts.Item($sType) = $value + 1
	Return $oSelf.typeCounts.Item($sType)
EndFunc   ;==>_objCtrls_incTypeCount

Func _objCtrls_decTypeCount($oSelf, $sType)
	#forceref $oSelf

	Local $value = $oSelf.typeCounts.Item($sType)
	$oSelf.typeCounts.Item($sType) = $value - 1
	Return $oSelf.typeCounts.Item($sType)
EndFunc   ;==>_objCtrls_decTypeCount

Func _objCtrls_getTypeCount($oSelf, $sType)
	#forceref $oSelf

	Return $oSelf.typeCounts.Item($sType)
EndFunc   ;==>_objCtrls_getTypeCount

Func _objCtrls_moveUp($oSelf, $oCtrlStart)
	#forceref $oSelf

	;find start and end index
	Local $iStart = -1, $iEnd = -1
	Local $i = 0
	;if root element
	If $oCtrlStart.CtrlParent = 0 Then
		For $oCtrl In $oSelf.ctrls.Items()
			If $oCtrl.Hwnd <> $oCtrlStart.Hwnd Then
				If $oCtrl.CtrlParent = 0 Then
					$iEnd = $i
				EndIf
			Else
				$iStart = $i
				ExitLoop
			EndIf

			$i += 1
		Next

		If $iStart = -1 Or $iEnd > $oSelf.count - 1 Or $iEnd < 0 Then Return 1

		Local $oCtrlsTemp = ObjCreate("Scripting.Dictionary")

		;loop through items, creating new order in temp list
		$i = 0
		For $oCtrl In $oSelf.ctrls.Items()
			If $i <> $iStart Then
				If $i = $iEnd Then
					$oCtrlsTemp.Add($oCtrlStart.Hwnd, $oCtrlStart)
				EndIf
				$oCtrlsTemp.Add($oCtrl.Hwnd, $oCtrl)
			EndIf
			$i += 1
		Next

		;clear ctrls list
		$oSelf.ctrls = 0

		;move temp list to our list
		$oSelf.ctrls = $oCtrlsTemp
	Else    ;if child element
		Local $oParent = $oSelf.get($oCtrlStart.CtrlParent)
		Switch $oCtrlStart.Type
			Case "TabItem"
				;for later

			Case Else
				For $oCtrl In $oParent.ctrls.Items()
					If $oCtrl.Hwnd <> $oCtrlStart.Hwnd Then
						If $oCtrl.CtrlParent = $oCtrlStart.CtrlParent Then
							$iEnd = $i
						EndIf
					Else
						$iStart = $i
						ExitLoop
					EndIf

					$i += 1
				Next

				If $iStart = -1 Or $iEnd > $oParent.ctrls.Count - 1 Or $iEnd < 0 Then Return 1

				Local $oCtrlsTemp = ObjCreate("Scripting.Dictionary")

				;loop through items, creating new order in temp list
				$i = 0
				For $oCtrl In $oParent.ctrls.Items()
					If $i <> $iStart Then
						If $i = $iEnd Then
							$oCtrlsTemp.Add($oCtrlStart.Hwnd, $oCtrlStart)
						EndIf
						$oCtrlsTemp.Add($oCtrl.Hwnd, $oCtrl)
					EndIf
					$i += 1
				Next

				;clear ctrls list
				$oParent.ctrls = 0

				;move temp list to our list
				$oParent.ctrls = $oCtrlsTemp

		EndSwitch
	EndIf

	Return $oCtrlStart
EndFunc   ;==>_objCtrls_moveUp


Func _objCtrls_moveDown($oSelf, $oCtrlStart)
	#forceref $oSelf

	;find start and end index
	Local $iStart = -1, $iEnd = -1
	Local $i = 0
	If $oCtrlStart.CtrlParent = 0 Then
		For $oCtrl In $oSelf.ctrls.Items()
			If $oCtrl.Hwnd = $oCtrlStart.Hwnd Then
				$iStart = $i
			Else
				If $iStart <> -1 And $oCtrl.CtrlParent = 0 Then
					$iEnd = $i
					ExitLoop
				EndIf
			EndIf

			$i += 1
		Next

		If $iStart = -1 Or $iEnd > $oSelf.count - 1 Or $iEnd < 0 Then Return 1

		Local $oCtrlsTemp = ObjCreate("Scripting.Dictionary")

		;loop through items, creating new order in temp list
		$i = 0
		For $oCtrl In $oSelf.ctrls.Items()
			If $i <> $iStart Then
				$oCtrlsTemp.Add($oCtrl.Hwnd, $oCtrl)
				If $i = $iEnd Then
					$oCtrlsTemp.Add($oCtrlStart.Hwnd, $oCtrlStart)
				EndIf
			EndIf
			$i += 1
		Next

		;clear ctrls list
		$oSelf.ctrls = 0

		;move temp list to our list
		$oSelf.ctrls = $oCtrlsTemp
	Else
		Local $oParent = $oSelf.get($oCtrlStart.CtrlParent)
		Switch $oCtrlStart.Type
			Case "TabItem"
				;for later

			Case Else
				For $oCtrl In $oParent.ctrls.Items()
					If $oCtrl.Hwnd = $oCtrlStart.Hwnd Then
						$iStart = $i
					Else
						If $iStart <> -1 And $oCtrl.CtrlParent = $oCtrlStart.CtrlParent Then
							$iEnd = $i
							ExitLoop
						EndIf
					EndIf

					$i += 1
				Next

				If $iStart = -1 Or $iEnd > $oParent.ctrls.Count - 1 Or $iEnd < 0 Then Return 1

				Local $oCtrlsTemp = ObjCreate("Scripting.Dictionary")

				;loop through items, creating new order in temp list
				$i = 0
				For $oCtrl In $oParent.ctrls.Items()
					If $i <> $iStart Then
						$oCtrlsTemp.Add($oCtrl.Hwnd, $oCtrl)
						If $i = $iEnd Then
							$oCtrlsTemp.Add($oCtrlStart.Hwnd, $oCtrlStart)
						EndIf
					EndIf
					$i += 1
				Next

				;clear ctrls list
				$oParent.ctrls = 0

				;move temp list to our list
				$oParent.ctrls = $oCtrlsTemp

		EndSwitch
	EndIf

	Return $oCtrlStart
EndFunc   ;==>_objCtrls_moveDown


Func _objCtrls_startResizing($oSelf)
	#forceref $oSelf

	Local $mouse_pos = _mouse_snap_pos()
	For $oCtrl In $oSelf.ctrls.Items()
		$oCtrl.resizePrevLeft = $mouse_pos[0]
		$oCtrl.resizePrevTop = $mouse_pos[1]
		$oCtrl.resizeStartLeft = $mouse_pos[0]
		$oCtrl.resizeStarTop = $mouse_pos[1]
		$oCtrl.PrevWidth = $oCtrl.Width
		$oCtrl.PrevHeight = $oCtrl.Height
		$oCtrl.PrevLeft = $oCtrl.Left
		$oCtrl.PrevTop = $oCtrl.Top
	Next
EndFunc   ;==>_objCtrls_startResizing
#EndRegion objCtrls


#Region objCtrl
;------------------------------------------------------------------------------
; Title...........: _objCtrl
; Description.....:	Ctrl object
;------------------------------------------------------------------------------
Func _objCtrl($oParent)
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "parent", $ELSCOPE_PUBLIC, $oParent)
	_AutoItObject_AddProperty($oObject, "isResizeMaster", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "resizePrevLeft", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "resizePrevTop", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "resizeStartLeft", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "resizeStartTop", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Hwnd", $ELSCOPE_PUBLIC)
	_AutoItObject_AddProperty($oObject, "Hwnd", $ELSCOPE_PUBLIC)
	_AutoItObject_AddProperty($oObject, "Hwnd1", $ELSCOPE_PUBLIC)
	_AutoItObject_AddProperty($oObject, "Hwnd2", $ELSCOPE_PUBLIC)
	_AutoItObject_AddProperty($oObject, "Name", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Text", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "HwndCount", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Type", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Left", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Top", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Width", $ELSCOPE_PUBLIC, 1)
	_AutoItObject_AddProperty($oObject, "Height", $ELSCOPE_PUBLIC, 1)
	_AutoItObject_AddProperty($oObject, "PrevWidth", $ELSCOPE_PUBLIC, 1)
	_AutoItObject_AddProperty($oObject, "PrevHeight", $ELSCOPE_PUBLIC, 1)
	_AutoItObject_AddProperty($oObject, "PrevLeft", $ELSCOPE_PUBLIC, 1)
	_AutoItObject_AddProperty($oObject, "PrevTop", $ELSCOPE_PUBLIC, 1)
	_AutoItObject_AddProperty($oObject, "Visible", $ELSCOPE_PUBLIC, True)
	_AutoItObject_AddProperty($oObject, "Enabled", $ELSCOPE_PUBLIC, True)
	_AutoItObject_AddProperty($oObject, "Focus", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "OnTop", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "DropAccepted", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "DefButton", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "Color", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "FontSize", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "FontName", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "FontWeight", $ELSCOPE_PUBLIC, 400)
	_AutoItObject_AddProperty($oObject, "Background", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Global", $ELSCOPE_PUBLIC, True)
	_AutoItObject_AddProperty($oObject, "TabCount", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Tabs", $ELSCOPE_PUBLIC, LinkedList())
	_AutoItObject_AddProperty($oObject, "MenuItems", $ELSCOPE_PUBLIC, LinkedList())
	_AutoItObject_AddProperty($oObject, "ctrls", $ELSCOPE_PUBLIC, ObjCreate("Scripting.Dictionary"))
	_AutoItObject_AddProperty($oObject, "Dirty", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "CtrlParent", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Locked", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "styleString", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "styles", $ELSCOPE_PUBLIC, ObjCreate("Scripting.Dictionary"))
	_AutoItObject_AddProperty($oObject, "CodeString", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "BorderColor", $ELSCOPE_PUBLIC, '0x000000')
	_AutoItObject_AddProperty($oObject, "BorderSize", $ELSCOPE_PUBLIC, 1)
	Local $aCoord1[2] = [0, 0]
	Local $aCoord2[2] = [1, 1]
	_AutoItObject_AddProperty($oObject, "Coord1", $ELSCOPE_PUBLIC, $aCoord1)
	_AutoItObject_AddProperty($oObject, "Coord2", $ELSCOPE_PUBLIC, $aCoord2)
	_AutoItObject_AddProperty($oObject, "Items", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Img", $ELSCOPE_PUBLIC, "")

	Return $oObject
EndFunc   ;==>_objCtrl
#EndRegion objCtrl


;~ Func _objTab($oParent)
;~ 	Local $oObject = _objCtrl($oParent)

;~ 	_AutoItObject_AddProperty($oObject, "ctrls", $ELSCOPE_PUBLIC, ObjCreate("Scripting.Dictionary"))

;~ 	Return $oObject
;~ EndFunc

Func _objGroup($oParent)
	Local $oObject = _objCtrl($oParent)

	_AutoItObject_AddProperty($oObject, "ctrls", $ELSCOPE_PUBLIC, ObjCreate("Scripting.Dictionary"))

	Return $oObject
EndFunc   ;==>_objGroup



#Region misc-objects
Func _objCreateRect()
	Local $oSelf = _AutoItObject_Create()

	_AutoItObject_AddProperty($oSelf, "Left", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oSelf, "Top", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oSelf, "Width", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oSelf, "Height", $ELSCOPE_PUBLIC, 0)

	Return $oSelf
EndFunc   ;==>_objCreateRect


;example by ProgAndy
Func _CreateListItem($name, $value)
	Local $oSelf = _AutoItObject_Create()

	_AutoItObject_AddProperty($oSelf, "Name", $ELSCOPE_PUBLIC, $name)
	_AutoItObject_AddProperty($oSelf, "Value", $ELSCOPE_PUBLIC, $value)

	Return $oSelf
EndFunc   ;==>_CreateListItem



;------------------------------------------------------------------------------
; Title...........: _objMain
; Description.....:	Main GUI object
;------------------------------------------------------------------------------
Func _objMain()
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "Hwnd", $ELSCOPE_PUBLIC)
	_AutoItObject_AddProperty($oObject, "Title", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Name", $ELSCOPE_PUBLIC, "hGUI")
	_AutoItObject_AddProperty($oObject, "Text", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Left", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Top", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Width", $ELSCOPE_PUBLIC, 400)
	_AutoItObject_AddProperty($oObject, "Height", $ELSCOPE_PUBLIC, 350)
	_AutoItObject_AddProperty($oObject, "Background", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "AppName", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "AppVersion", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "DefaultCursor", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "hasChanged", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "styles", $ELSCOPE_PUBLIC, _Styles_Main())
	_AutoItObject_AddProperty($oObject, "styleString", $ELSCOPE_PUBLIC, "")


	Return $oObject
EndFunc   ;==>_objMain
#EndRegion misc-objects



#Region grippies
;------------------------------------------------------------------------------
; Title...........: _objGrippies
; Description.....:	Grippies (selection handles) for a control
;------------------------------------------------------------------------------
Func _objGrippies($oParent, $oGrandParent)
	Local $oObject = _AutoItObject_Create()

	;add parent as property
	_AutoItObject_AddProperty($oObject, "parent", $ELSCOPE_PUBLIC, $oParent)

	;create the labels to represent the grippy handles
	Local $grippy_size = 5
	Local $NW = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, -1, $WS_EX_TOPMOST)
	Local $N = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, -1, $WS_EX_TOPMOST)
	Local $NE = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, -1, $WS_EX_TOPMOST)
	Local $W = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, -1, $WS_EX_TOPMOST)
	Local $East = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, -1, $WS_EX_TOPMOST)
	Local $SW = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, -1, $WS_EX_TOPMOST)
	Local $S = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, -1, $WS_EX_TOPMOST)
	Local $SE = GUICtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, -1, $WS_EX_TOPMOST)

	;set mouse cursor for each grippy
	GUICtrlSetCursor($NW, $SIZENWSE)
	GUICtrlSetCursor($N, $SIZENS)
	GUICtrlSetCursor($NE, $SIZENESW)
	GUICtrlSetCursor($East, $SIZEWS)
	GUICtrlSetCursor($SE, $SIZENWSE)
	GUICtrlSetCursor($S, $SIZENS)
	GUICtrlSetCursor($SW, $SIZENESW)
	GUICtrlSetCursor($W, $SIZEWS)

	;set events for each grippy
	GUICtrlSetOnEvent($NW, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($N, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($NE, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($SW, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($S, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($SE, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($W, "_objGrippies_mouseClickEvent")
	GUICtrlSetOnEvent($East, "_objGrippies_mouseClickEvent")

	;add the label IDs to object properties
	_AutoItObject_AddProperty($oObject, "size", $ELSCOPE_PUBLIC, $grippy_size)
	_AutoItObject_AddProperty($oObject, "NW", $ELSCOPE_PUBLIC, $NW)
	_AutoItObject_AddProperty($oObject, "N", $ELSCOPE_PUBLIC, $N)
	_AutoItObject_AddProperty($oObject, "NE", $ELSCOPE_PUBLIC, $NE)
	_AutoItObject_AddProperty($oObject, "SW", $ELSCOPE_PUBLIC, $SW)
	_AutoItObject_AddProperty($oObject, "S", $ELSCOPE_PUBLIC, $S)
	_AutoItObject_AddProperty($oObject, "SE", $ELSCOPE_PUBLIC, $SE)
	_AutoItObject_AddProperty($oObject, "W", $ELSCOPE_PUBLIC, $W)
	_AutoItObject_AddProperty($oObject, "East", $ELSCOPE_PUBLIC, $East)

	;add methods to object
	_AutoItObject_AddMethod($oObject, "mouseClick", "_objGrippies_mouseClick")
	_AutoItObject_AddMethod($oObject, "show", "_objGrippies_show")
	_AutoItObject_AddMethod($oObject, "hide", "_objGrippies_hide")
	_AutoItObject_AddMethod($oObject, "delete", "_objGrippies_delete")
	_AutoItObject_AddMethod($oObject, "resizing", "_objGrippies_resizing")

	;set the event handler to reference this object
	_objGrippies_mouseClickEvent($oGrandParent)

	Return $oObject
EndFunc   ;==>_objGrippies


;------------------------------------------------------------------------------
; Title...........: _objGrippies_mouseClickEvent
; Description.....:	when a grippy is clicked, this event handler passes the ctrlID
;					to the object method
; Credits.........: IsDeclared technique by TheDcoder
; Link............: https://www.autoitscript.com/forum/topic/139260-autoit-snippets/?do=findComment&comment=1373669
;------------------------------------------------------------------------------
Func _objGrippies_mouseClickEvent($oObject = 0)
	Static $oParentObject
	Local $isEvent = IsDeclared("oObject") = $DECLARED_LOCAL

	If $isEvent Then
		$oParentObject = $oObject
	Else
		If IsObj($oParentObject) Then
			For $oCtrl In $oParentObject.ctrls.Items()
				Switch @GUI_CtrlId
					Case $oCtrl.grippies.NW, $oCtrl.grippies.N, $oCtrl.grippies.NE, $oCtrl.grippies.SE, $oCtrl.grippies.S, $oCtrl.grippies.SW, $oCtrl.grippies.W, $oCtrl.grippies.East
						$oCtrl.grippies.mouseClick(@GUI_CtrlId)
				EndSwitch
			Next
		Else
			Return -1
		EndIf
	EndIf

EndFunc   ;==>_objGrippies_mouseClickEvent

;------------------------------------------------------------------------------
; Title...........: _objGrippies_mouseClick
; Description.....:	when a grippy is clicked, set the flag
;------------------------------------------------------------------------------
Func _objGrippies_mouseClick($oSelf, $CtrlID)
	If $oSelf.parent.Locked Then Return

;~ 	$oSelf.parent.resizePrevLeft = $oMouse.X
;~ 	$oSelf.parent.resizePrevTop = $oMouse.Y

	Switch $CtrlID
		Case $oSelf.NW
			$oSelf.parent.parent.mode = $resize_nw

		Case $oSelf.N
			$oSelf.parent.parent.mode = $resize_n

		Case $oSelf.NE
			$oSelf.parent.parent.mode = $resize_ne

		Case $oSelf.East
			$oSelf.parent.parent.mode = $resize_e

		Case $oSelf.SE
			$oSelf.parent.parent.mode = $resize_se

		Case $oSelf.S
			$oSelf.parent.parent.mode = $resize_s

		Case $oSelf.SW
			$oSelf.parent.parent.mode = $resize_sw

		Case $oSelf.W
			$oSelf.parent.parent.mode = $resize_w

	EndSwitch

	$oSelf.parent.isResizeMaster = True
	$oSelf.parent.parent.StartResizing()

	$initResize = True
;~ 	_hide_selected_controls()

EndFunc   ;==>_objGrippies_mouseClick


Func _objGrippies_resizing($oSelf, $mode)
	Local $oCtrl = $oSelf.parent
	Local $left, $top, $right, $bottom

	Switch $mode
		Case $resize_nw
			$left = $oCtrl.Left + ($oMouse.X - $oCtrl.resizePrevLeft)
			$top = $oCtrl.Top + ($oMouse.Y - $oCtrl.resizePrevTop)
			$right = $oCtrl.Width + ($oCtrl.resizePrevLeft - $oMouse.X)
			$bottom = $oCtrl.Height + ($oCtrl.resizePrevTop - $oMouse.Y)

		Case $resize_n
			$left = $oCtrl.Left
			$top = $oCtrl.Top + ($oMouse.Y - $oCtrl.resizePrevTop)
			$right = $oCtrl.Width
			$bottom = $oCtrl.Height + ($oCtrl.resizePrevTop - $oMouse.Y)

		Case $resize_ne
			$left = $oCtrl.Left
			$top = $oCtrl.Top + ($oMouse.Y - $oCtrl.resizePrevTop)
			$right = $oCtrl.Width + ($oMouse.X - $oCtrl.resizePrevLeft)
			$bottom = $oCtrl.Height + ($oCtrl.resizePrevTop - $oMouse.Y)

		Case $resize_w
			$left = $oCtrl.Left + ($oMouse.X - $oCtrl.resizePrevLeft)
			$top = $oCtrl.Top
			$right = $oCtrl.Width + ($oCtrl.resizePrevLeft - $oMouse.X)
			$bottom = $oCtrl.Height

		Case $resize_e
			$left = $oCtrl.Left
			$top = $oCtrl.Top
			$right = $oCtrl.Width + ($oMouse.X - $oCtrl.resizePrevLeft)
			$bottom = $oCtrl.Height

		Case $resize_sw
			$left = $oCtrl.Left + ($oMouse.X - $oCtrl.resizePrevLeft)
			$top = $oCtrl.Top
			$right = $oCtrl.Width + ($oCtrl.resizePrevLeft - $oMouse.X)
			$bottom = $oCtrl.Height + ($oMouse.Y - $oCtrl.resizePrevTop)

		Case $resize_s
			$left = $oCtrl.Left
			$top = $oCtrl.Top
			$right = $oCtrl.Width
			$bottom = $oCtrl.Height + ($oMouse.Y - $oCtrl.resizePrevTop)

		Case $resize_se
			$left = $oCtrl.Left
			$top = $oCtrl.Top
			$right = $oCtrl.Width + ($oMouse.X - $oCtrl.resizePrevLeft)
			$bottom = $oCtrl.Height + ($oMouse.Y - $oCtrl.resizePrevTop)

	EndSwitch

	$oCtrl.resizePrevLeft = $oMouse.X
	$oCtrl.resizePrevTop = $oMouse.Y

	_set_current_mouse_pos()

	Switch $oCtrl.Type
		Case "Slider"
			GUICtrlSendMsg($oCtrl.Hwnd, 27 + 0x0400, $oCtrl.Height - 20, 0) ; TBS_SETTHUMBLENGTH
	EndSwitch


	_change_ctrl_size_pos($oCtrl, $left, $top, $right, $bottom)
;~ 	$oCtrl.grippies.show()
;~ 	ToolTip($oCtrl.Name & ": X:" & $oCtrl.Left & ", Y:" & $oCtrl.Top & ", W:" & $oCtrl.Width & ", H:" & $oCtrl.Height)
EndFunc   ;==>_objGrippies_resizing


;------------------------------------------------------------------------------
; Title...........: _objGrippies_show
; Description.....:	show the grippies
;------------------------------------------------------------------------------
Func _objGrippies_show($oSelf)
;~ 	_log("show grippies for " & $oSelf.parent.Name)
	;set lock=red, or unlock=black
	Local $lockColor = 0xFF0000
	Local $unlockColor = 0x333333
	If $oSelf.parent.Locked Then
		GUICtrlSetBkColor($oSelf.NW, $lockColor)
		GUICtrlSetBkColor($oSelf.N, $lockColor)
		GUICtrlSetBkColor($oSelf.NE, $lockColor)
		GUICtrlSetBkColor($oSelf.East, $lockColor)
		GUICtrlSetBkColor($oSelf.SE, $lockColor)
		GUICtrlSetBkColor($oSelf.S, $lockColor)
		GUICtrlSetBkColor($oSelf.SW, $lockColor)
		GUICtrlSetBkColor($oSelf.W, $lockColor)

		;set mouse cursor for each grippy
		GUICtrlSetCursor($oSelf.NW, -1)
		GUICtrlSetCursor($oSelf.N, -1)
		GUICtrlSetCursor($oSelf.NE, -1)
		GUICtrlSetCursor($oSelf.East, -1)
		GUICtrlSetCursor($oSelf.SE, -1)
		GUICtrlSetCursor($oSelf.S, -1)
		GUICtrlSetCursor($oSelf.SW, -1)
		GUICtrlSetCursor($oSelf.W, -1)
	Else
		GUICtrlSetBkColor($oSelf.NW, $unlockColor)
		GUICtrlSetBkColor($oSelf.N, $unlockColor)
		GUICtrlSetBkColor($oSelf.NE, $unlockColor)
		GUICtrlSetBkColor($oSelf.East, $unlockColor)
		GUICtrlSetBkColor($oSelf.SE, $unlockColor)
		GUICtrlSetBkColor($oSelf.S, $unlockColor)
		GUICtrlSetBkColor($oSelf.SW, $unlockColor)
		GUICtrlSetBkColor($oSelf.W, $unlockColor)

		;set mouse cursor for each grippy
		GUICtrlSetCursor($oSelf.NW, $SIZENWSE)
		GUICtrlSetCursor($oSelf.N, $SIZENS)
		GUICtrlSetCursor($oSelf.NE, $SIZENESW)
		GUICtrlSetCursor($oSelf.East, $SIZEWS)
		GUICtrlSetCursor($oSelf.SE, $SIZENWSE)
		GUICtrlSetCursor($oSelf.S, $SIZENS)
		GUICtrlSetCursor($oSelf.SW, $SIZENESW)
		GUICtrlSetCursor($oSelf.W, $SIZEWS)
	EndIf

	;show
	GUICtrlSetState($oSelf.NW, $GUI_SHOW)
	GUICtrlSetState($oSelf.N, $GUI_SHOW)
	GUICtrlSetState($oSelf.NE, $GUI_SHOW)
	GUICtrlSetState($oSelf.East, $GUI_SHOW)
	GUICtrlSetState($oSelf.SE, $GUI_SHOW)
	GUICtrlSetState($oSelf.S, $GUI_SHOW)
	GUICtrlSetState($oSelf.SW, $GUI_SHOW)
	GUICtrlSetState($oSelf.W, $GUI_SHOW)

	;set on top
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.NW), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.N), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.NE), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.W), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.East), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.SW), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.S), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($oSelf.SE), $HWND_TOP, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)

	Local Const $grippy_size = $oSelf.size

	Local Const $l = $oSelf.parent.Left
	Local Const $t = $oSelf.parent.Top
	Local Const $W = $oSelf.parent.Width
	Local Const $h = $oSelf.parent.Height

	Local $offsetX = 0, $offsetY = 0
	If $W < 0 Then $offsetX = $grippy_size
	If $h < 0 Then $offsetY = $grippy_size

	Local Const $nw_left = $l - $grippy_size + $offsetX
	Local Const $nw_top = $t - $grippy_size + $offsetY
	Local Const $n_left = $l + ($W - $grippy_size) / 2
	Local Const $n_top = $nw_top
	Local Const $ne_left = $l + $W - $offsetX
	Local Const $ne_top = $nw_top
	Local Const $e_left = $ne_left
	Local Const $e_top = $t + ($h - $grippy_size) / 2
	Local Const $se_left = $ne_left
	Local Const $se_top = $t + $h - $offsetY
	Local Const $s_left = $n_left
	Local Const $s_top = $se_top
	Local Const $sw_left = $nw_left
	Local Const $sw_top = $se_top
	Local Const $w_left = $nw_left
	Local Const $w_top = $e_top

	Switch $oSelf.parent.Type
		Case "Combo", "Checkbox", "Radio"
			GUICtrlSetPos($oSelf.East, $e_left, $e_top, Default, Default)
			GUICtrlSetPos($oSelf.W, $w_left, $w_top, Default, Default)

		Case Else
			GUICtrlSetPos($oSelf.NW, $nw_left, $nw_top, Default, Default)
			GUICtrlSetPos($oSelf.N, $n_left, $n_top, Default, Default)
			GUICtrlSetPos($oSelf.NE, $ne_left, $ne_top, Default, Default)
			GUICtrlSetPos($oSelf.East, $e_left, $e_top, Default, Default)
			GUICtrlSetPos($oSelf.SE, $se_left, $se_top, Default, Default)
			GUICtrlSetPos($oSelf.S, $s_left, $s_top, Default, Default)
			GUICtrlSetPos($oSelf.SW, $sw_left, $sw_top, Default, Default)
			GUICtrlSetPos($oSelf.W, $w_left, $w_top, Default, Default)
	EndSwitch
EndFunc   ;==>_objGrippies_show


;------------------------------------------------------------------------------
; Title...........: _objGrippies_hide
; Description.....:	hide the grippies
;------------------------------------------------------------------------------
Func _objGrippies_hide($oSelf)
	GUICtrlSetState($oSelf.NW, $GUI_HIDE)
	GUICtrlSetState($oSelf.N, $GUI_HIDE)
	GUICtrlSetState($oSelf.NE, $GUI_HIDE)
	GUICtrlSetState($oSelf.East, $GUI_HIDE)
	GUICtrlSetState($oSelf.SE, $GUI_HIDE)
	GUICtrlSetState($oSelf.S, $GUI_HIDE)
	GUICtrlSetState($oSelf.SW, $GUI_HIDE)
	GUICtrlSetState($oSelf.W, $GUI_HIDE)
EndFunc   ;==>_objGrippies_hide

Func _objGrippies_delete($oSelf)
	GUICtrlDelete($oSelf.NW)
	GUICtrlDelete($oSelf.N)
	GUICtrlDelete($oSelf.NE)
	GUICtrlDelete($oSelf.East)
	GUICtrlDelete($oSelf.SW)
	GUICtrlDelete($oSelf.S)
	GUICtrlDelete($oSelf.SE)
	GUICtrlDelete($oSelf.W)
EndFunc   ;==>_objGrippies_delete
#EndRegion grippies



;------------------------------------------------------------------------------
; Title...........: _StyleList_Main
; Description.....:	array containing gui or control property IDs
;------------------------------------------------------------------------------
Func _Styles_Main()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_GUI", False)
	$oDict.Add("WS_BORDER", False)
	$oDict.Add("WS_POPUP", False)
	$oDict.Add("WS_CAPTION", False)
	$oDict.Add("WS_CLIPCHILDREN", False)
	$oDict.Add("WS_CLIPSIBLINGS", False)
	$oDict.Add("WS_DISABLED", False)
	$oDict.Add("WS_DLGFRAME", False)
	$oDict.Add("WS_HSCROLL", False)
	$oDict.Add("WS_MAXIMIZE", False)
	$oDict.Add("WS_MAXIMIZEBOX", False)
	$oDict.Add("WS_MINIMIZE", False)
	$oDict.Add("WS_MINIMIZEBOX", False)
	$oDict.Add("WS_OVERLAPPED", False)
	$oDict.Add("WS_OVERLAPPEDWINDOW", False)
	$oDict.Add("WS_POPUPWINDOW", False)
	$oDict.Add("WS_SIZEBOX", False)
	$oDict.Add("WS_SYSMENU", False)
	$oDict.Add("WS_THICKFRAME", False)
	$oDict.Add("WS_VSCROLL", False)
	$oDict.Add("WS_VISIBLE", False)
	$oDict.Add("WS_CHILD", False)
	$oDict.Add("WS_GROUP", False)
	$oDict.Add("WS_TABSTOP", False)
	$oDict.Add("DS_MODALFRAME", False)
	$oDict.Add("DS_SETFOREGROUND", False)
	$oDict.Add("DS_CONTEXTHELP", False)

	Return $oDict
EndFunc   ;==>_Styles_Main


Func _Styles_Tab()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_TAB", False)
	$oDict.Add("TCS_SCROLLOPPOSITE", False)
	$oDict.Add("TCS_BOTTOM", False)
	$oDict.Add("TCS_RIGHT", False)
	$oDict.Add("TCS_MULTISELECT", False)
	$oDict.Add("TCS_FLATBUTTONS", False)
	$oDict.Add("TCS_FORCEICONLEFT", False)
	$oDict.Add("TCS_FORCELABELLEFT", False)
	$oDict.Add("TCS_HOTTRACK", False)
	$oDict.Add("TCS_VERTICAL", False)
	$oDict.Add("TCS_TABS", False)
	$oDict.Add("TCS_BUTTONS", False)
	$oDict.Add("TCS_SINGLELINE", False)
	$oDict.Add("TCS_MULTILINE", False)
	$oDict.Add("TCS_RIGHTJUSTIFY", False)
	$oDict.Add("TCS_FIXEDWIDTH", False)
	$oDict.Add("TCS_RAGGEDRIGHT", False)
	$oDict.Add("TCS_FOCUSONBUTTONDOWN", False)
	$oDict.Add("TCS_OWNERDRAWFIXED", False)
	$oDict.Add("TCS_TOOLTIPS", False)
	$oDict.Add("TCS_FOCUSNEVER", False)

	Return $oDict
EndFunc   ;==>_Styles_Tab


Func _Styles_Group()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("WS_BORDER", False)
	$oDict.Add("WS_POPUP", False)
	$oDict.Add("WS_CAPTION", False)
	$oDict.Add("WS_CLIPCHILDREN", False)
	$oDict.Add("WS_CLIPSIBLINGS", False)
	$oDict.Add("WS_DISABLED", False)
	$oDict.Add("WS_DLGFRAME", False)
	$oDict.Add("WS_HSCROLL", False)
	$oDict.Add("WS_MAXIMIZE", False)
	$oDict.Add("WS_MAXIMIZEBOX", False)
	$oDict.Add("WS_MINIMIZE", False)
	$oDict.Add("WS_MINIMIZEBOX", False)
	$oDict.Add("WS_OVERLAPPED", False)
	$oDict.Add("WS_OVERLAPPEDWINDOW", False)
	$oDict.Add("WS_POPUPWINDOW", False)
	$oDict.Add("WS_SIZEBOX", False)
	$oDict.Add("WS_SYSMENU", False)
	$oDict.Add("WS_THICKFRAME", False)
	$oDict.Add("WS_VSCROLL", False)
	$oDict.Add("WS_VISIBLE", False)
	$oDict.Add("WS_CHILD", False)
	$oDict.Add("WS_GROUP", False)
	$oDict.Add("WS_TABSTOP", False)
	$oDict.Add("DS_MODALFRAME", False)
	$oDict.Add("DS_SETFOREGROUND", False)
	$oDict.Add("DS_CONTEXTHELP", False)

	Return $oDict
EndFunc   ;==>_Styles_Group


Func _Styles_Button()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_BUTTON", False)
	$oDict.Add("BS_LEFT", False)
	$oDict.Add("BS_CENTER", False)
	$oDict.Add("BS_RIGHT", False)
	$oDict.Add("BS_BOTTOM", False)
	$oDict.Add("BS_VCENTER", False)
	$oDict.Add("BS_TOP", False)
	$oDict.Add("BS_DEFPUSHBUTTON", False)
	$oDict.Add("BS_MULTILINE", False)
	$oDict.Add("BS_ICON", False)
	$oDict.Add("BS_BITMAP", False)
	$oDict.Add("BS_FLAT", False)
	$oDict.Add("BS_NOTIFY", False)

	Return $oDict
EndFunc   ;==>_Styles_Button

Func _Styles_Checkbox()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_CHECKBOX", False)
	$oDict.Add("BS_3STATE", False)
	$oDict.Add("BS_AUTO3STATE", False)
	$oDict.Add("BS_AUTOCHECKBOX", False)
	$oDict.Add("BS_CHECKBOX", False)
	$oDict.Add("BS_LEFT", False)
	$oDict.Add("BS_PUSHLIKE", False)
	$oDict.Add("BS_RIGHT", False)
	$oDict.Add("BS_RIGHTBUTTON", False)
	$oDict.Add("BS_GROUPBOX", False)
	$oDict.Add("BS_AUTORADIOBUTTON", False)

	Return $oDict
EndFunc   ;==>_Styles_Checkbox

Func _Styles_Radio()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_RADIO", False)
	$oDict.Add("BS_BOTTOM", False)
	$oDict.Add("BS_CENTER", False)
	$oDict.Add("BS_DEFPUSHBUTTON", False)
	$oDict.Add("BS_MULTILINE", False)
	$oDict.Add("BS_TOP", False)
	$oDict.Add("BS_VCENTER", False)
	$oDict.Add("BS_ICON", False)
	$oDict.Add("BS_BITMAP", False)
	$oDict.Add("BS_FLAT", False)
	$oDict.Add("BS_NOTIFY", False)

	Return $oDict
EndFunc   ;==>_Styles_Radio

Func _Styles_Edit()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_EDIT", False)
	$oDict.Add("ES_AUTOHSCROLL", False)
	$oDict.Add("ES_AUTOVSCROLL", False)
	$oDict.Add("ES_CENTER", False)
	$oDict.Add("ES_LOWERCASE", False)
	$oDict.Add("ES_NOHIDESEL", False)
	$oDict.Add("ES_NUMBER", False)
	$oDict.Add("ES_OEMCONVERT", False)
	$oDict.Add("ES_MULTILINE", False)
	$oDict.Add("ES_PASSWORD", False)
	$oDict.Add("ES_READONLY", False)
	$oDict.Add("ES_RIGHT", False)
	$oDict.Add("ES_UPPERCASE", False)
	$oDict.Add("ES_WANTRETURN", False)

	Return $oDict
EndFunc   ;==>_Styles_Edit

Func _Styles_Input()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("ES_AUTOHSCROLL", False)
	$oDict.Add("ES_AUTOVSCROLL", False)
	$oDict.Add("ES_CENTER", False)
	$oDict.Add("ES_LOWERCASE", False)
	$oDict.Add("ES_NOHIDESEL", False)
	$oDict.Add("ES_NUMBER", False)
	$oDict.Add("ES_OEMCONVERT", False)
	$oDict.Add("ES_MULTILINE", False)
	$oDict.Add("ES_PASSWORD", False)
	$oDict.Add("ES_READONLY", False)
	$oDict.Add("ES_RIGHT", False)
	$oDict.Add("ES_UPPERCASE", False)
	$oDict.Add("ES_WANTRETURN", False)

	Return $oDict
EndFunc   ;==>_Styles_Input

Func _Styles_Label()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_LABEL", False)
	$oDict.Add("SS_BLACKFRAME", False)
	$oDict.Add("SS_BLACKRECT", False)
	$oDict.Add("SS_CENTER", False)
	$oDict.Add("SS_CENTERIMAGE", False)
	$oDict.Add("SS_ETCHEDFRAME", False)
	$oDict.Add("SS_ETCHEDHORZ", False)
	$oDict.Add("SS_ETCHEDVERT", False)
	$oDict.Add("SS_GRAYFRAME", False)
	$oDict.Add("SS_GRAYRECT", False)
	$oDict.Add("SS_LEFT", False)
	$oDict.Add("SS_LEFTNOWORDWRAP", False)
	$oDict.Add("SS_NOPREFIX", False)
	$oDict.Add("SS_NOTIFY", False)
	$oDict.Add("SS_RIGHT", False)
	$oDict.Add("SS_RIGHTJUST", False)
	$oDict.Add("SS_SIMPLE", False)
	$oDict.Add("SS_SUNKEN", False)
	$oDict.Add("SS_WHITEFRAME", False)
	$oDict.Add("SS_WHITERECT", False)

	Return $oDict
EndFunc   ;==>_Styles_Label

Func _Styles_UpDown()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("UDS_ALIGNLEFT", False)
	$oDict.Add("UDS_ALIGNRIGHT", False)
	$oDict.Add("UDS_ARROWKEYS", False)
	$oDict.Add("UDS_HORZ", False)
	$oDict.Add("UDS_NOTHOUSANDS", False)
	$oDict.Add("UDS_WRAP", False)

	Return $oDict
EndFunc   ;==>_Styles_UpDown

Func _Styles_List()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_LIST", False)
	$oDict.Add("LBS_DISABLENOSCROLL", False)
	$oDict.Add("LBS_NOINTEGRALHEIGHT", False)
	$oDict.Add("LBS_NOSEL", False)
	$oDict.Add("LBS_NOTIFY", False)
	$oDict.Add("LBS_SORT", False)
	$oDict.Add("LBS_STANDARD", False)
	$oDict.Add("LBS_USETABSTOPS", False)

	Return $oDict
EndFunc   ;==>_Styles_List

Func _Styles_Combo()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_COMBO", False)
	$oDict.Add("CBS_AUTOHSCROLL", False)
	$oDict.Add("CBS_DISABLENOSCROLL", False)
	$oDict.Add("CBS_DROPDOWN", False)
	$oDict.Add("CBS_DROPDOWNLIST", False)
	$oDict.Add("CBS_LOWERCASE", False)
	$oDict.Add("CBS_NOINTEGRALHEIGHT", False)
	$oDict.Add("CBS_OEMCONVERT", False)
	$oDict.Add("CBS_SIMPLE", False)
	$oDict.Add("CBS_SORT", False)
	$oDict.Add("CBS_UPPERCASE", False)

	Return $oDict
EndFunc   ;==>_Styles_Combo

Func _Styles_Date()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_DATE", False)
	$oDict.Add("DTS_UPDOWN", False)
	$oDict.Add("DTS_SHOWNONE", False)
	$oDict.Add("DTS_LONGDATEFORMAT", False)
	$oDict.Add("DTS_TIMEFORMAT", False)
	$oDict.Add("DTS_RIGHTALIGN", False)
	$oDict.Add("DTS_SHORTDATEFORMAT", False)

	Return $oDict
EndFunc   ;==>_Styles_Date

Func _Styles_TreeView()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_TREEVIEW", False)
	$oDict.Add("TVS_HASBUTTONS", False)
	$oDict.Add("TVS_HASLINES", False)
	$oDict.Add("TVS_LINESATROOT", False)
	$oDict.Add("TVS_DISABLEDRAGDROP", False)
	$oDict.Add("TVS_SHOWSELALWAYS", False)
	$oDict.Add("TVS_RTLREADING", False)
	$oDict.Add("TVS_NOTOOLTIPS", False)
	$oDict.Add("TVS_CHECKBOXES", False)
	$oDict.Add("TVS_TRACKSELECT", False)
	$oDict.Add("TVS_SINGLEEXPAND", False)
	$oDict.Add("TVS_FULLROWSELECT", False)
	$oDict.Add("TVS_NOSCROLL", False)
	$oDict.Add("TVS_NONEVENHEIGHT", False)

	Return $oDict
EndFunc   ;==>_Styles_TreeView

Func _Styles_Progress()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_PROGRESS", False)
	$oDict.Add("PBS_MARQUEE", False)
	$oDict.Add("PBS_SMOOTH", False)
	$oDict.Add("PBS_SMOOTHREVERSE", False)
	$oDict.Add("PBS_VERTICAL", False)

	Return $oDict
EndFunc   ;==>_Styles_Progress

Func _Styles_Avi()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_AVI", False)
	$oDict.Add("ACS_AUTOPLAY", False)
	$oDict.Add("ACS_CENTER", False)
	$oDict.Add("ACS_TRANSPARENT", False)
	$oDict.Add("ACS_NONTRANSPARENT", False)

	Return $oDict
EndFunc   ;==>_Styles_Avi

Func _Styles_Icon()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_ICON", False)
	$oDict.Add("SS_BLACKFRAME", False)
	$oDict.Add("SS_BLACKRECT", False)
	$oDict.Add("SS_CENTER", False)
	$oDict.Add("SS_CENTERIMAGE", False)
	$oDict.Add("SS_ETCHEDFRAME", False)
	$oDict.Add("SS_ETCHEDHORZ", False)
	$oDict.Add("SS_ETCHEDVERT", False)
	$oDict.Add("SS_GRAYFRAME", False)
	$oDict.Add("SS_GRAYRECT", False)
	$oDict.Add("SS_LEFT", False)
	$oDict.Add("SS_LEFTNOWORDWRAP", False)
	$oDict.Add("SS_NOPREFIX", False)
	$oDict.Add("SS_NOTIFY", False)
	$oDict.Add("SS_RIGHT", False)
	$oDict.Add("SS_RIGHTJUST", False)
	$oDict.Add("SS_SIMPLE", False)
	$oDict.Add("SS_SUNKEN", False)
	$oDict.Add("SS_WHITEFRAME", False)
	$oDict.Add("SS_WHITERECT", False)

	Return $oDict
EndFunc   ;==>_Styles_Icon

Func _Styles_Pic()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_PIC", False)
	$oDict.Add("SS_BLACKFRAME", False)
	$oDict.Add("SS_BLACKRECT", False)
	$oDict.Add("SS_CENTER", False)
	$oDict.Add("SS_CENTERIMAGE", False)
	$oDict.Add("SS_ETCHEDFRAME", False)
	$oDict.Add("SS_ETCHEDHORZ", False)
	$oDict.Add("SS_ETCHEDVERT", False)
	$oDict.Add("SS_GRAYFRAME", False)
	$oDict.Add("SS_GRAYRECT", False)
	$oDict.Add("SS_LEFT", False)
	$oDict.Add("SS_LEFTNOWORDWRAP", False)
	$oDict.Add("SS_NOPREFIX", False)
	$oDict.Add("SS_NOTIFY", False)
	$oDict.Add("SS_RIGHT", False)
	$oDict.Add("SS_RIGHTJUST", False)
	$oDict.Add("SS_SIMPLE", False)
	$oDict.Add("SS_SUNKEN", False)
	$oDict.Add("SS_WHITEFRAME", False)
	$oDict.Add("SS_WHITERECT", False)

	Return $oDict
EndFunc   ;==>_Styles_Pic

Func _Styles_Slider()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_SLIDER", False)
	$oDict.Add("TBS_AUTOTICKS", False)
	$oDict.Add("TBS_BOTH", False)
	$oDict.Add("TBS_BOTTOM", False)
	$oDict.Add("TBS_HORZ", False)
	$oDict.Add("TBS_VERT", False)
	$oDict.Add("TBS_NOTHUMB", False)
	$oDict.Add("TBS_NOTICKS", False)
	$oDict.Add("TBS_LEFT", False)
	$oDict.Add("TBS_RIGHT", False)
	$oDict.Add("TBS_TOP", False)

	Return $oDict
EndFunc   ;==>_Styles_Slider

Func _Styles_IP()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	Return $oDict
EndFunc   ;==>_Styles_IP

Func _Styles_ListView()
	Local $oDict = ObjCreate("Scripting.Dictionary")

	$oDict.Add("GUI_SS_DEFAULT_LISTVIEW", False)
	$oDict.Add("LVS_ICON", False)
	$oDict.Add("LVS_REPORT", False)
	$oDict.Add("LVS_SMALLICON", False)
	$oDict.Add("LVS_LIST", False)
	$oDict.Add("LVS_EDITLABELS", False)
	$oDict.Add("LVS_NOCOLUMNHEADER", False)
	$oDict.Add("LVS_NOSORTHEADER", False)
	$oDict.Add("LVS_SINGLESEL", False)
	$oDict.Add("LVS_SHOWSELALWAYS", False)
	$oDict.Add("LVS_SORTASCENDING", False)
	$oDict.Add("LVS_SORTDESCENDING", False)
	$oDict.Add("LVS_NOLABELWRAP", False)

	Return $oDict
EndFunc   ;==>_Styles_ListView



;------------------------------------------------------------------------------
; Title...........: _objAction
; Description.....:	action object for undo/redo
;------------------------------------------------------------------------------
Func _objAction()
	Local $oObject = _AutoItObject_Create()

	Local $aTemp[0]
	_AutoItObject_AddProperty($oObject, "action", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "ctrls", $ELSCOPE_PUBLIC, $aTemp)
	_AutoItObject_AddProperty($oObject, "parameters", $ELSCOPE_PUBLIC, $aTemp)

	Return $oObject
EndFunc   ;==>_objAction

