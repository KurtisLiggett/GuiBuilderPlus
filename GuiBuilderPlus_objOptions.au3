; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_objOptions.au3
; Description ...: Create and manage objects for program settings
; ===============================================================================================================================


;------------------------------------------------------------------------------
; Title...........: _objOptions
; Description.....:	contains option menu handles, states, and values
;------------------------------------------------------------------------------
Func _objOptions()
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "count", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "CurrentType", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "menuCount", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "hasMenu", $ELSCOPE_PUBLIC, False)
	;actual list of controls
	_AutoItObject_AddProperty($oObject, "ctrls", $ELSCOPE_PUBLIC, LinkedList())

	Local $oTypeCountList = LinkedList()
	$oTypeCountList.add(_CreateListItem("Button", 0))
	$oTypeCountList.add(_CreateListItem("Group", 0))
	$oTypeCountList.add(_CreateListItem("Checkbox", 0))
	$oTypeCountList.add(_CreateListItem("Radio", 0))
	$oTypeCountList.add(_CreateListItem("Edit", 0))
	$oTypeCountList.add(_CreateListItem("Input", 0))
	$oTypeCountList.add(_CreateListItem("Label", 0))
	$oTypeCountList.add(_CreateListItem("List", 0))
	$oTypeCountList.add(_CreateListItem("Combo", 0))
	$oTypeCountList.add(_CreateListItem("Date", 0))
	$oTypeCountList.add(_CreateListItem("Slider", 0))
	$oTypeCountList.add(_CreateListItem("Tab", 0))
	$oTypeCountList.add(_CreateListItem("TreeView", 0))
	$oTypeCountList.add(_CreateListItem("Updown", 0))
	$oTypeCountList.add(_CreateListItem("Progress", 0))
	$oTypeCountList.add(_CreateListItem("Pic", 0))
	$oTypeCountList.add(_CreateListItem("Avi", 0))
	$oTypeCountList.add(_CreateListItem("Icon", 0))
	_AutoItObject_AddProperty($oObject, "typeCounts", $ELSCOPE_PUBLIC, $oTypeCountList)

	_AutoItObject_AddMethod($oObject, "createNew", "_objCtrls_createNew")
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

	Return $oObject
EndFunc   ;==>_objCtrls

Func _objCtrls_createNew($oSelf)
	#forceref $oSelf
	Local $oObject = _objCtrl()

	Return $oObject
EndFunc   ;==>_objCtrls_createNew

Func _objCtrls_add($oSelf, $objCtrl)
	#forceref $oSelf

	$oSelf.ctrls.add($objCtrl)
	$oSelf.count = $oSelf.count + 1

	If $objCtrl.Type = "Menu" Then
		$oSelf.menuCount = $oSelf.menuCount + 1
		$oSelf.hasMenu = True
	EndIf

	Return $oSelf.count
EndFunc   ;==>_objCtrls_add

Func _objCtrls_remove($oSelf, $Hwnd)
	#forceref $oSelf

	Local $i, $bFoundItem = False
	For $oItem In $oSelf.ctrls
		If $oItem.Hwnd = $Hwnd Then
			$bFoundItem = True
			ExitLoop
		EndIf
		$i += 1
	Next

	If $bFoundItem Then
		If $oSelf.ctrls.at($i).Type = "Menu" Then
			$oSelf.menuCount = $oSelf.menuCount - 1
			If $oSelf.menuCount >= 1 Then
				$oSelf.hasMenu = True
			Else
				$oSelf.hasMenu = False
			EndIf
		EndIf
		$oSelf.ctrls.remove($i)
	EndIf

	If Not @error Then
		$oSelf.count = $oSelf.count - 1
		Return $oSelf.count
	Else
		Return -1
	EndIf

EndFunc   ;==>_objCtrls_remove

Func _objCtrls_removeAll($oSelf)
	#forceref $oSelf

	$oSelf.ctrls = 0
	$oSelf.ctrls = LinkedList()
	$oSelf.count = 0
	$oSelf.menuCount = 0
	$oSelf.hasMenu = False
EndFunc   ;==>_objCtrls_removeAll

Func _objCtrls_get($oSelf, $Hwnd)
	#forceref $oSelf

	For $oItem In $oSelf.ctrls
		If $oItem.Hwnd = $Hwnd Then
			Return $oItem
		EndIf
	Next

	Return -1
EndFunc   ;==>_objCtrls_get

Func _objCtrls_getFist($oSelf)
	#forceref $oSelf

	If $oSelf.count > 0 Then
		Return $oSelf.ctrls.at(0)
	Else
		Return -1
	EndIf
EndFunc   ;==>_objCtrls_getFist

Func _objCtrls_getLast($oSelf)
	#forceref $oSelf

	If $oSelf.count > 0 Then
		Return $oSelf.ctrls.at($oSelf.count - 1)
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

	For $oItem In $oSelf.ctrls
		If $oItem.Hwnd = $Hwnd Then
			Return True
		EndIf
	Next

	Return False
EndFunc   ;==>_objCtrls_exists

Func _objCtrls_incTypeCount($oSelf, $sType)
	#forceref $oSelf

	For $oItem In $oSelf.typeCounts
		If $oItem.Name = $sType Then
			$oItem.Value = $oItem.Value + 1
			Return $oItem.Value
		EndIf
	Next

	Return -1
EndFunc   ;==>_objCtrls_incTypeCount

Func _objCtrls_decTypeCount($oSelf, $sType)
	#forceref $oSelf

	For $oItem In $oSelf.typeCounts
		If $oItem.Name = $sType Then
			$oItem.Value = $oItem.Value - 1
			If $oItem.Value < 0 Then
				$oItem.Value = 0
			EndIf
			Return $oItem.Value
		EndIf
	Next

	Return -1
EndFunc   ;==>_objCtrls_decTypeCount

Func _objCtrls_getTypeCount($oSelf, $sType)
	#forceref $oSelf

	For $oItem In $oSelf.typeCounts
		If $oItem.Name = $sType Then
			Return $oItem.Value
		EndIf
	Next

	Return -1
EndFunc   ;==>_objCtrls_getTypeCount

Func _objCtrls_moveUp($oSelf, $oCtrlStart)
	#forceref $oSelf

	;find start and end index
	Local $iStart = -1
	Local $i = 0
	For $oCtrl In $oSelf.ctrls
		If $oCtrl.Hwnd = $oCtrlStart.Hwnd Then
			$iStart = $i
			$iEnd = $iStart - 1
			ExitLoop
		EndIf

		$i += 1
	Next

	ConsoleWrite("Start " & $iStart & " end " & $iEnd & @CRLF)
;~ 	Return

	If $iStart = -1 Or $iEnd > $oSelf.count - 1 Or $iEnd < 0 Then Return 1

	Local $oCtrlsTemp = LinkedList()

	;loop through items, creating new order in temp list
	$i = 0
	For $oCtrl In $oSelf.ctrls
		If $i <> $iStart Then
			If $i = $iEnd Then
				$oCtrlsTemp.add($oCtrlStart)
			EndIf
			$oCtrlsTemp.add($oCtrl)
		EndIf
		$i += 1
	Next

	;clear ctrls list
	$oSelf.ctrls = 0

	;move temp list to our list
	$oSelf.ctrls = $oCtrlsTemp

	Return $oCtrlStart
EndFunc   ;==>_objCtrls_moveUp


Func _objCtrls_moveDown($oSelf, $oCtrlStart)
	#forceref $oSelf

	;find start and end index
	Local $iStart = -1
	Local $i = 0
	For $oCtrl In $oSelf.ctrls
		If $oCtrl.Hwnd = $oCtrlStart.Hwnd Then
			$iStart = $i
			$iEnd = $iStart + 1
			ExitLoop
		EndIf

		$i += 1
	Next

	ConsoleWrite("Start " & $iStart & " end " & $iEnd & @CRLF)
;~ 	Return

	If $iStart = -1 Or $iEnd > $oSelf.count - 1 Or $iEnd < 0 Then Return 1

	Local $oCtrlsTemp = LinkedList()

	;loop through items, creating new order in temp list
	$i = 0
	For $oCtrl In $oSelf.ctrls
		If $i <> $iStart Then
			$oCtrlsTemp.add($oCtrl)
			If $i = $iEnd Then
				$oCtrlsTemp.add($oCtrlStart)
			EndIf
		EndIf
		$i += 1
	Next

	;clear ctrls list
	$oSelf.ctrls = 0

	;move temp list to our list
	$oSelf.ctrls = $oCtrlsTemp

	Return $oCtrlStart
EndFunc   ;==>_objCtrls_moveDown


;------------------------------------------------------------------------------
; Title...........: _objCtrl
; Description.....:	Ctrl object
;------------------------------------------------------------------------------
Func _objCtrl()
	Local $oObject = _AutoItObject_Create()

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
	_AutoItObject_AddProperty($oObject, "Visible", $ELSCOPE_PUBLIC, True)
	_AutoItObject_AddProperty($oObject, "Enabled", $ELSCOPE_PUBLIC, True)
	_AutoItObject_AddProperty($oObject, "Focus", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "OnTop", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "DropAccepted", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "DefButton", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "Color", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Background", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "TabCount", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Tabs", $ELSCOPE_PUBLIC, LinkedList())

	Local $aKeys[21] = _
			[ _
			"Hwnd", _
			"Hwnd1", _
			"Hwnd2", _
			"Name", _
			"Text", _
			"HwndCount", _
			"Type", _
			"Left", _
			"Top", _
			"Widt", _
			"Height", _
			"Visible", _
			"Enabled", _
			"Focus", _
			"OnTop", _
			"DropAccepted", _
			"DefButton", _
			"Color", _
			"Background", _
			"TabCount", _
			"Tabs" _
			]
	_AutoItObject_AddProperty($oObject, "keys", $ELSCOPE_PUBLIC, $aKeys)

	_AutoItObject_AddMethod($oObject, "getKeys", "_objCtrl_getKeys")

	Return $oObject
EndFunc   ;==>_objCtrl

Func _objCtrl_getKeys($oSelf)
	#forceref $oSelf
	Return $oSelf.keys
EndFunc   ;==>_objCtrl_getKeys


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
	_AutoItObject_AddProperty($oObject, "Title", $ELSCOPE_PUBLIC)
	_AutoItObject_AddProperty($oObject, "Name", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Text", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Left", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Top", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Width", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Height", $ELSCOPE_PUBLIC, -1)
	_AutoItObject_AddProperty($oObject, "Background", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "AppName", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "AppVersion", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "DefaultCursor", $ELSCOPE_PUBLIC, 0)

	Return $oObject
EndFunc   ;==>_objMain
