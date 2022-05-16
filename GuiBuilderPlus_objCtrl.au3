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
;~ Global $hGUI = GUICreate("",100,100)
;~ Local $ctrl1 = GUICtrlCreateLabel("test1", 0,0)
;~ ConsoleWrite("$ctrl1: " & $ctrl1 & @CRLF)
;~ Local $ctrl2 = GUICtrlCreateLabel("test2", 0,50)
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
;~ ConsoleWrite("name 1: " & $myControls.get($ctrl1).Name & @CRLF)	;1st control no longer exists, returns nothing
;~ $myControls.get($ctrl1)	;does not exist, returns -1
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
	;actual list of controls
	_AutoItObject_AddProperty($oObject, "ctrls", $ELSCOPE_PUBLIC, LinkedList())

	_AutoItObject_AddMethod($oObject, "createNew", "_objCtrls_createNew")
	_AutoItObject_AddMethod($oObject, "add", "_objCtrls_add")
	_AutoItObject_AddMethod($oObject, "remove", "_objCtrls_remove")
	_AutoItObject_AddMethod($oObject, "removeAll", "_objCtrls_removeAll")
	_AutoItObject_AddMethod($oObject, "get", "_objCtrls_get")
	_AutoItObject_AddMethod($oObject, "getFirst", "_objCtrls_getFist")
	_AutoItObject_AddMethod($oObject, "getLast", "_objCtrls_getLast")
	_AutoItObject_AddMethod($oObject, "getCopy", "_objCtrls_getCopy")
;~ 	_AutoItObject_AddMethod($oObject, "set", "_objCtrls_set")
	_AutoItObject_AddMethod($oObject, "getKeys", "_objCtrls_getKeys")
	_AutoItObject_AddMethod($oObject, "exists", "_objCtrls_exists")

	Local $aKeys[2] = _
	[ _
		"count", _
		"ctrls" _
	]
	_AutoItObject_AddProperty($oObject, "keys", $ELSCOPE_PUBLIC, $aKeys)

	Return $oObject
EndFunc   ;==>_objCtrls

Func _objCtrls_getKeys($oSelf)
	#forceref $oSelf
	Return $oSelf.keys
EndFunc

Func _objCtrls_createNew($oSelf)
	#forceref $oSelf
	Local $oObject = _objCtrl()

	Return $oObject
EndFunc

Func _objCtrls_add($oSelf, $objCtrl)
	#forceref $oSelf

	$oSelf.ctrls.add($objCtrl)
	$oSelf.count = $oSelf.count + 1

	Return $oSelf.count
EndFunc

Func _objCtrls_remove($oSelf, $Hwnd)
	#forceref $oSelf

	Local $i, $bFoundItem = False
	For $oItem in $oSelf.ctrls
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
EndFunc

Func _objCtrls_removeAll($oSelf)
	#forceref $oSelf

	$oSelf.ctrls = 0
	$oSelf.ctrls = LinkedList()
	$oSelf.count = 0
EndFunc

Func _objCtrls_get($oSelf, $Hwnd)
	#forceref $oSelf

	For $oItem in $oSelf.ctrls
		If $oItem.Hwnd = $Hwnd Then
			Return $oItem
		EndIf
	Next

	Return -1
EndFunc

Func _objCtrls_getFist($oSelf)
	#forceref $oSelf

	If $oSelf.count > 0 Then
		Return $oSelf.ctrls.at(0)
	Else
		Return -1
	EndIf
EndFunc

Func _objCtrls_getLast($oSelf)
	#forceref $oSelf

	If $oSelf.count > 0 Then
		Return $oSelf.ctrls.at($oSelf.count)
	Else
		Return -1
	EndIf
EndFunc

Func _objCtrls_getCopy($oSelf, $Hwnd)
	#forceref $oSelf

	Local $oCtrl = $oSelf.get($Hwnd)
	if IsObj($oCtrl) Then
		Return _AutoItObject_Create($oCtrl)
	Else
		Return -1
	EndIf
EndFunc

Func _objCtrls_exists($oSelf, $Hwnd)
	#forceref $oSelf

	For $oItem in $oSelf.ctrls
		If $oItem.Hwnd = $Hwnd Then
			Return True
		EndIf
	Next

	Return False
EndFunc


;------------------------------------------------------------------------------
; Title...........: _objCtrl
; Description.....:	Ctrl object
;------------------------------------------------------------------------------
Func _objCtrl()
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "Hwnd", $ELSCOPE_PUBLIC)
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

	Local $aKeys[17] = _
	[ _
		"Hwnd", _
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
EndFunc