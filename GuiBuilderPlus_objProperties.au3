; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_objProperties.au3
; Description ...: store property control IDs/hwnd
; ===============================================================================================================================



Func _objPropertiesMain()
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "properties", $ELSCOPE_PUBLIC, _objProperties())
	_AutoItObject_AddProperty($oObject, "styles", $ELSCOPE_PUBLIC, _objStylesMain())

	Return $oObject
EndFunc   ;==>_objCtrls



;------------------------------------------------------------------------------
; Title...........: _objProperties
; Description.....:	object containing gui or control property IDs
;------------------------------------------------------------------------------
Func _objProperties()
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "Hwnd", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "Title", $ELSCOPE_PUBLIC, _objProperty("Title"))
	_AutoItObject_AddProperty($oObject, "Text", $ELSCOPE_PUBLIC, _objProperty("Text"))
	_AutoItObject_AddProperty($oObject, "Name", $ELSCOPE_PUBLIC, _objProperty("Name"))
	_AutoItObject_AddProperty($oObject, "Left", $ELSCOPE_PUBLIC, _objProperty("Left"))
	_AutoItObject_AddProperty($oObject, "Top", $ELSCOPE_PUBLIC, _objProperty("Top"))
	_AutoItObject_AddProperty($oObject, "Width", $ELSCOPE_PUBLIC, _objProperty("Width"))
	_AutoItObject_AddProperty($oObject, "Height", $ELSCOPE_PUBLIC, _objProperty("Height"))
	_AutoItObject_AddProperty($oObject, "Color", $ELSCOPE_PUBLIC, _objProperty("Color"))
	_AutoItObject_AddProperty($oObject, "Background", $ELSCOPE_PUBLIC, _objProperty("Background"))
	_AutoItObject_AddProperty($oObject, "Global", $ELSCOPE_PUBLIC, _objProperty("Global", "Checkbox"))

	Return $oObject
EndFunc   ;==>_objCtrls

;------------------------------------------------------------------------------
; Title...........: _objStylesMain
; Description.....:	object containing gui or control property IDs
;------------------------------------------------------------------------------
Func _objStylesMain()
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "Hwnd", $ELSCOPE_PUBLIC, "")

	Local $oDict = ObjCreate("Scripting.Dictionary")
	$oDict.Add("WS_BORDER", _objProperty("WS_BORDER", "Checkbox"))
	$oDict.Add("WS_POPUP", _objProperty("WS_POPUP", "Checkbox"))
	$oDict.Add("WS_CAPTION", _objProperty("WS_CAPTION", "Checkbox"))
	$oDict.Add("WS_CLIPCHILDREN", _objProperty("WS_CLIPCHILDREN", "Checkbox"))
	$oDict.Add("WS_CLIPSIBLINGS", _objProperty("WS_CLIPSIBLINGS", "Checkbox"))
	$oDict.Add("WS_DISABLED", _objProperty("WS_DISABLED", "Checkbox"))
	$oDict.Add("WS_DLGFRAME", _objProperty("WS_DLGFRAME", "Checkbox"))
	$oDict.Add("WS_HSCROLL", _objProperty("WS_HSCROLL", "Checkbox"))
	$oDict.Add("WS_MAXIMIZE", _objProperty("WS_MAXIMIZE", "Checkbox"))
	$oDict.Add("WS_MAXIMIZEBOX", _objProperty("WS_MAXIMIZEBOX", "Checkbox"))
	$oDict.Add("WS_MINIMIZE", _objProperty("WS_MINIMIZE", "Checkbox"))
	$oDict.Add("WS_MINIMIZEBOX", _objProperty("WS_MINIMIZEBOX", "Checkbox"))
	$oDict.Add("WS_OVERLAPPED", _objProperty("WS_OVERLAPPED", "Checkbox"))
	$oDict.Add("WS_OVERLAPPEDWINDOW", _objProperty("WS_OVERLAPPEDWINDOW", "Checkbox"))
	$oDict.Add("WS_POPUPWINDOW", _objProperty("WS_POPUPWINDOW", "Checkbox"))
	$oDict.Add("WS_SIZEBOX", _objProperty("WS_SIZEBOX", "Checkbox"))
	$oDict.Add("WS_SYSMENU", _objProperty("WS_SYSMENU", "Checkbox"))
	$oDict.Add("WS_THICKFRAME", _objProperty("WS_THICKFRAME", "Checkbox"))
	$oDict.Add("WS_VSCROLL", _objProperty("WS_VSCROLL", "Checkbox"))
	$oDict.Add("WS_VISIBLE", _objProperty("WS_VISIBLE", "Checkbox"))
	$oDict.Add("WS_CHILD", _objProperty("WS_CHILD", "Checkbox"))
	$oDict.Add("WS_GROUP", _objProperty("WS_GROUP", "Checkbox"))
	$oDict.Add("WS_TABSTOP", _objProperty("WS_TABSTOP", "Checkbox"))
	$oDict.Add("DS_MODALFRAME", _objProperty("DS_MODALFRAME", "Checkbox"))
	$oDict.Add("DS_SETFOREGROUND", _objProperty("DS_SETFOREGROUND", "Checkbox"))
	$oDict.Add("DS_CONTEXTHELP", _objProperty("DS_CONTEXTHELP", "Checkbox"))

	_AutoItObject_AddProperty($oObject, "ctrls", $ELSCOPE_PUBLIC, $oDict)

	Return $oObject
EndFunc   ;==>_objCtrls

Func _objProperty($name, $type = "")
	Local $oSelf = _AutoItObject_Create()

	_AutoItObject_AddProperty($oSelf, "name", $ELSCOPE_PUBLIC, $name)
	_AutoItObject_AddProperty($oSelf, "type", $ELSCOPE_PUBLIC, $type)
	_AutoItObject_AddProperty($oSelf, "Hwnd", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddMethod($oSelf, "value", "_objProperty_value")

	Return $oSelf
EndFunc   ;==>_objCreateMouse

Func _objProperty_value($oSelf, $vNewValue = "")
   If @NumParams = 2 Then
		Switch $oSelf.type
			Case "Checkbox"
				_setCheckedState($oSelf.Hwnd, $vNewValue)
			Case Else
				GUICtrlSetData($oSelf.Hwnd, $vNewValue)
		EndSwitch
   Else
		Switch $oSelf.type
			Case "Checkbox"
				Return BitAND(GUICtrlRead($oSelf.Hwnd), $GUI_CHECKED) = $GUI_CHECKED
			Case Else
				Return GUICtrlRead($oSelf.Hwnd)
		EndSwitch
    EndIf
EndFunc
