; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_objProperties.au3
; Description ...: store property control IDs/hwnd
; ===============================================================================================================================


;------------------------------------------------------------------------------
; Title...........: _objProperties
; Description.....:	object containing gui or control property IDs
;------------------------------------------------------------------------------
Func _objProperties()
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddMethod($oObject, "Hwnd", "_objProperties_Hwnd")
	_AutoItObject_AddProperty($oObject, "HwndNum", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "Title", $ELSCOPE_PUBLIC, _objProperty("Title"))
	_AutoItObject_AddProperty($oObject, "Text", $ELSCOPE_PUBLIC, _objProperty("Text"))
	_AutoItObject_AddProperty($oObject, "Name", $ELSCOPE_PUBLIC, _objProperty("Name"))
	_AutoItObject_AddProperty($oObject, "Left", $ELSCOPE_PUBLIC, _objProperty("Left"))
	_AutoItObject_AddProperty($oObject, "Top", $ELSCOPE_PUBLIC, _objProperty("Top"))
	_AutoItObject_AddProperty($oObject, "Width", $ELSCOPE_PUBLIC, _objProperty("Width"))
	_AutoItObject_AddProperty($oObject, "Height", $ELSCOPE_PUBLIC, _objProperty("Height"))
	_AutoItObject_AddProperty($oObject, "Color", $ELSCOPE_PUBLIC, _objProperty("Color"))
	_AutoItObject_AddProperty($oObject, "Background", $ELSCOPE_PUBLIC, _objProperty("Background"))


	Return $oObject
EndFunc   ;==>_objCtrls

Func _objProperties_Hwnd($oSelf, $vNewValue = "")
   If @NumParams = 2 Then
        $oSelf.HwndNum = Number($vNewValue)
    Else
        Return HWnd($oSelf.HwndNum)
    EndIf
EndFunc

Func _objProperty($name)
	Local $oSelf = _AutoItObject_Create()

	_AutoItObject_AddProperty($oSelf, "name", $ELSCOPE_PUBLIC, $name)
	_AutoItObject_AddProperty($oSelf, "Hwnd", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddMethod($oSelf, "value", "_objProperty_value")

	Return $oSelf
EndFunc   ;==>_objCreateMouse

Func _objProperty_value($oSelf, $vNewValue = "")
   If @NumParams = 2 Then
        GUICtrlSetData($oSelf.Hwnd, $vNewValue)
    Else
        Return GUICtrlRead($oSelf.Hwnd)
    EndIf
EndFunc
