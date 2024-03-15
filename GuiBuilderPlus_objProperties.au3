; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_objProperties.au3
; Description ...: store property control IDs/hwnd
; ===============================================================================================================================



Func _objProperties()
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "properties", $ELSCOPE_PUBLIC, _objPropertiesProps())
	_AutoItObject_AddProperty($oObject, "styles", $ELSCOPE_PUBLIC, ObjCreate("Scripting.Dictionary"))

	Return $oObject
EndFunc   ;==>_objProperties


;------------------------------------------------------------------------------
; Title...........: _objProperties
; Description.....:	object containing gui or control property IDs
;------------------------------------------------------------------------------
Func _objPropertiesProps()
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
	_AutoItObject_AddProperty($oObject, "FontName", $ELSCOPE_PUBLIC, _objProperty("FontName"))
	_AutoItObject_AddProperty($oObject, "FontSize", $ELSCOPE_PUBLIC, _objProperty("FontSize"))
	_AutoItObject_AddProperty($oObject, "FontWeight", $ELSCOPE_PUBLIC, _objProperty("FontWeight"))
	_AutoItObject_AddProperty($oObject, "Background", $ELSCOPE_PUBLIC, _objProperty("Background"))
	_AutoItObject_AddProperty($oObject, "Autosize", $ELSCOPE_PUBLIC, _objProperty("Autosize", "Checkbox"))
	_AutoItObject_AddProperty($oObject, "Global", $ELSCOPE_PUBLIC, _objProperty("Global", "Checkbox"))
	_AutoItObject_AddProperty($oObject, "BorderColor", $ELSCOPE_PUBLIC, _objProperty("BorderColor"))
	_AutoItObject_AddProperty($oObject, "BorderSize", $ELSCOPE_PUBLIC, _objProperty("BorderSize"))
	_AutoItObject_AddProperty($oObject, "Items", $ELSCOPE_PUBLIC, _objProperty("Items"))
	_AutoItObject_AddProperty($oObject, "Img", $ELSCOPE_PUBLIC, _objProperty("Img"))

	Return $oObject
EndFunc   ;==>_objPropertiesProps

;_objProperty("GUI_SS_DEFAULT_GUI", "Checkbox")

Func _objProperty($name, $type = "")
	Local $oSelf = _AutoItObject_Create()

	_AutoItObject_AddProperty($oSelf, "name", $ELSCOPE_PUBLIC, $name)
	_AutoItObject_AddProperty($oSelf, "type", $ELSCOPE_PUBLIC, $type)
	_AutoItObject_AddProperty($oSelf, "Hwnd", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddMethod($oSelf, "value", "_objProperty_value")

	Return $oSelf
EndFunc   ;==>_objProperty

Func _objProperty_value($oSelf, $vNewValue = "")
	If @NumParams = 2 Then
		Switch $oSelf.type
			Case "Checkbox"
;~ 				_setCheckedState($oSelf.Hwnd, $vNewValue)
				Switch $vNewValue
					Case $GUI_CHECKED
						GUICtrlSetState($oSelf.Hwnd, $GUI_CHECKED)
					Case $GUI_UNCHECKED
						GUICtrlSetState($oSelf.Hwnd, $GUI_UNCHECKED)
					Case Else
						GUICtrlSetState($oSelf.Hwnd, $GUI_INDETERMINATE)
				EndSwitch
			Case Else
				GUICtrlSetData($oSelf.Hwnd, $vNewValue)
		EndSwitch
	Else
		Switch $oSelf.type
			Case "Checkbox"
				Return GUICtrlRead($oSelf.Hwnd)
			Case Else
				Return GUICtrlRead($oSelf.Hwnd)
		EndSwitch
	EndIf
EndFunc   ;==>_objProperty_value
