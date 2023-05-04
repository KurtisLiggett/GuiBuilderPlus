; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_objOptions.au3
; Description ...: Create and manage objects for program settings
; ===============================================================================================================================


;------------------------------------------------------------------------------
; Title...........: _objOptions
; Description.....:	contains settings
;------------------------------------------------------------------------------
Func _objOptions()
	Local $oObject = _AutoItObject_Create()

	Local $oDict = ObjCreate("Scripting.Dictionary")

	_AutoItObject_AddProperty($oObject, "snapGrid", $ELSCOPE_PUBLIC, True)
	_AutoItObject_AddProperty($oObject, "pasteAtMouse", $ELSCOPE_PUBLIC, True)
	_AutoItObject_AddProperty($oObject, "guiInFunction", $ELSCOPE_PUBLIC, True)
	_AutoItObject_AddProperty($oObject, "eventMode", $ELSCOPE_PUBLIC, False)
	_AutoItObject_AddProperty($oObject, "gridSize", $ELSCOPE_PUBLIC, 10)
	_AutoItObject_AddProperty($oObject, "showGrid", $ELSCOPE_PUBLIC, True)
	_AutoItObject_AddProperty($oObject, "showCodeViewer", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oObject, "showObjectExplorer", $ELSCOPE_PUBLIC, False)

	Return $oObject
EndFunc   ;==>_objCtrls
