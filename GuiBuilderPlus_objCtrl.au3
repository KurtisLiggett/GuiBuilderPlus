; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_objCtrl.au3
; Description ...: Create and manage objects for control components
; ===============================================================================================================================

;~ #Region object test scripts
;~ #include "UDFs\AutoItObject.au3"
;~ #include "UDFs\oLinkedList.au3"
;~ #include <Array.au3>
;~ _AutoItObject_StartUp()

;~ ;create GUI for generating HWNDs
;~ Global $hGUI = GUICreate("", 100, 100)
;~ Local $ctrl1 = GUICtrlCreateLabel("test1", 0, 0)
;~ ConsoleWrite("$ctrl1: " & $ctrl1 & @CRLF)
;~ Local $ctrl2 = GUICtrlCreateLabel("test2", 0, 50)
;~ ConsoleWrite("$ctrl2: " & $ctrl2 & @CRLF)

;~ ;create container
;~ Global $myControls = _objCtrls()
;~ ConsoleWrite("Count: " & $myControls.count & @CRLF)

;~ ;create 1st control
;~ Global $thisCtrl1 = $myControls.createNew()
;~ $thisCtrl1.Hwnd = $ctrl1
;~ $thisCtrl1.Name = "Ctrl1"
;~ $myControls.add($thisCtrl1)

;~ ;create 2nd control
;~ Global $thisCtrl2 = $myControls.createNew()
;~ $thisCtrl2.Hwnd = $ctrl2
;~ $thisCtrl2.Name = "Ctrl2"
;~ $myControls.add($thisCtrl2)

;~ ;get name of ctrl
;~ ConsoleWrite(@CRLF)
;~ ConsoleWrite("name 1: " & $myControls.get($ctrl1).Name & @CRLF)
;~ ConsoleWrite("name 2: " & $myControls.get($ctrl2).Name & @CRLF)

;~ ;remove 1st
;~ ConsoleWrite(@CRLF)
;~ ConsoleWrite("count: " & $myControls.count & ", list size: " & $myControls.ctrls.size & @CRLF)
;~ $myControls.remove($ctrl1)
;~ ConsoleWrite("count: " & $myControls.count & ", list size: " & $myControls.ctrls.size & @CRLF)

;~ ;get 2nd ctrl Name again,  to make sure it's still there
;~ ConsoleWrite(@CRLF)
;~ ConsoleWrite("name 1: " & $myControls.get($ctrl1).Name & @CRLF)    ;1st control no longer exists, returns nothing
;~ $myControls.get($ctrl1)    ;does not exist, returns -1
;~ ConsoleWrite("name 2: " & $myControls.get($ctrl2).Name & @CRLF)

;~ ;get ctrl and set new name
;~ ConsoleWrite(@CRLF)
;~ $myControls.add($thisCtrl1)
;~ ConsoleWrite("Name 1: " & $myControls.get($ctrl1).Name & @CRLF)
;~ $myControls.get($ctrl1).Name = "Test Name 1"
;~ ConsoleWrite("New Name 1: " & $myControls.get($ctrl1).Name & @CRLF)

;~ ConsoleWrite(@CRLF)
;~ ConsoleWrite("Ctrl 1 exists: " & $myControls.exists($ctrl1) & @CRLF)
;~ ConsoleWrite("Ctrl 3 exists: " & $myControls.exists(5) & @CRLF)

;~ Global $test = $myControls.get($ctrl1)
;~ Global $keys = $myControls.get($ctrl1).getKeys()
;~ ;_ArrayDisplay($keys)


;~ ;delete all
;~ ConsoleWrite(@CRLF)
;~ ConsoleWrite("before delete all -- count: " & $myControls.count & ", list size: " & $myControls.ctrls.size & @CRLF)
;~ $myControls.removeAll()
;~ ConsoleWrite("count: " & $myControls.count & ", list size: " & $myControls.ctrls.size & @CRLF)


;~ ;increment type count
;~ ConsoleWrite(@CRLF)
;~ ConsoleWrite("count: " & $myControls.getTypeCount("Button") & @CRLF)
;~ $myControls.incTypeCount("Button")
;~ $myControls.incTypeCount("Tab")
;~ $myControls.incTypeCount("Button")
;~ $myControls.incTypeCount("Label")
;~ $myControls.decTypeCount("Button")
;~ ConsoleWrite("count: " & $myControls.getTypeCount("Button") & @CRLF)

;~ ConsoleWrite(@CRLF)
;~ #EndRegion


;------------------------------------------------------------------------------
; Title...........: _objCtrls
; Description.....:	Main container for all controls, a wrapper for linked list
;					with additional properties and methods
;------------------------------------------------------------------------------
Func _objCtrls()
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "count", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "CurrentType", $ELSCOPE_PUBLIC, "")
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
	_AutoItObject_AddProperty($oObject, "TabCount", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Tabs", $ELSCOPE_PUBLIC, LinkedList())

	_AutoItObject_AddMethod($oObject, "createNew", "_objCtrls_createNew")
	_AutoItObject_AddMethod($oObject, "add", "_objCtrls_add")
	_AutoItObject_AddMethod($oObject, "remove", "_objCtrls_remove")
	_AutoItObject_AddMethod($oObject, "removeAll", "_objCtrls_removeAll")
	_AutoItObject_AddMethod($oObject, "get", "_objCtrls_get")
	_AutoItObject_AddMethod($oObject, "getFirst", "_objCtrls_getFist")
	_AutoItObject_AddMethod($oObject, "getLast", "_objCtrls_getLast")
	_AutoItObject_AddMethod($oObject, "getCopy", "_objCtrls_getCopy")
;~ 	_AutoItObject_AddMethod($oObject, "set", "_objCtrls_set")
	_AutoItObject_AddMethod($oObject, "exists", "_objCtrls_exists")
	_AutoItObject_AddMethod($oObject, "incTypeCount", "_objCtrls_incTypeCount")
	_AutoItObject_AddMethod($oObject, "decTypeCount", "_objCtrls_decTypeCount")
	_AutoItObject_AddMethod($oObject, "getTypeCount", "_objCtrls_getTypeCount")

	Return $oObject
EndFunc   ;==>_objCtrls

Func _objCtrls_getKeys($oSelf)
	#forceref $oSelf
	Return $oSelf.keys
EndFunc   ;==>_objCtrls_getKeys

Func _objCtrls_createNew($oSelf)
	#forceref $oSelf
	Local $oObject = _objCtrl()

	Return $oObject
EndFunc   ;==>_objCtrls_createNew

Func _objCtrls_add($oSelf, $objCtrl)
	#forceref $oSelf

	$oSelf.ctrls.add($objCtrl)
	$oSelf.count = $oSelf.count + 1

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
		Return $oSelf.ctrls.at($oSelf.count)
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

	Local $aKeys[19] = _
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
			"Background" _
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
EndFunc   ;==>_CreateListItem


;example by ProgAndy
Func _CreateListItem($name, $value)
	Local $oSelf = _AutoItObject_Create()

	_AutoItObject_AddProperty($oSelf, "Name", $ELSCOPE_PUBLIC, $name)
	_AutoItObject_AddProperty($oSelf, "Value", $ELSCOPE_PUBLIC, $value)

	Return $oSelf
EndFunc   ;==>_CreateListItem
