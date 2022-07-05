; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_codeGeneration.au3
; Description ...: Code generation and management
; ===============================================================================================================================


;------------------------------------------------------------------------------
; Title...........: _code_generation
; Description.....: generate the au3 code
; Return..........: code as string
;------------------------------------------------------------------------------
Func _code_generation()
	Local $controls, $globals[2]

	;get options
;~ 	Local $bAddDpiScale = $setting_dpi_scaling
	Local $bAddDpiScale = False
	Local $bOnEventMode = $setting_onEvent_mode
	Local $bGuiFunction = $setting_gui_function

	Local $sDpiScale = ""
	If $bAddDpiScale Then
		$sDpiScale = " * $fDpiFactor"
	EndIf

	;set up the region tags
	Local $regionStart = "#Region (=== GUI generated by " & $oMain.AppName & " " & $oMain.AppVersion & " ===)"
	Local $regionEnd = "#EndRegion (=== GUI generated by " & $oMain.AppName & " " & $oMain.AppVersion & " ===)"

	; Mod by: TheSaint - default includes
	Local $includes = "#include <Constants.au3>" & @CRLF & _
			"#include <GUIConstantsEx.au3>" & @CRLF & _
			"#include <Misc.au3>" & @CRLF & _
			"#include <WindowsConstants.au3>"
	If $bAddDpiScale Then
		$includes &= @CRLF & "#include <GDIPlus.au3>"
	EndIf

	If $oMain.Name <> "" Then
		$globals[0] = "Global $" & $oMain.Name & @CRLF
	Else
		$globals[0] = ""
	EndIf
	$globals[1] = "Global "
	Local $globalsIndex = 1
	For $oCtrl In $oCtrls.ctrls.Items()
		;generate globals for controls
		If $oCtrl.Name <> "" And $oCtrl.Global Then
			If StringLen($globals[$globalsIndex]) > 100 Then
				$globals[$globalsIndex] = StringTrimRight($globals[$globalsIndex], 2) & @CRLF
				$globalsIndex += 1
				ReDim $globals[$globalsIndex+1]
				$globals[$globalsIndex] = "Global "
			EndIf
			$globals[$globalsIndex] &= "$" & $oCtrl.Name & ", "
		EndIf

		;generate includes
		$includes &= _generate_includes($oCtrl, $includes)

		;generate controls
		$controls &= _generate_controls($oCtrl, $sDpiScale)
	Next
	If $globals[$globalsIndex] = "Global " Then
		$globals[$globalsIndex] = ""
	Else
		$globals[$globalsIndex] = StringTrimRight($globals[$globalsIndex], 2) & @CRLF
	EndIf

	Local $FuncMain = _getFuncMain($bOnEventMode, $bGuiFunction)
	Local $FuncOnEventMode = _getFuncOnExit()
	Local $FuncDpiScaling = _getFuncDpiScaling()

	Local $gdtitle = _get_script_title()
	If $oMain.Title <> "" Then
		$gdtitle = $oMain.Title
	EndIf

	;apply the DPI scaling factor
	Local $w = $oMain.Width
	If $w <> -1 Then
		$w &= $sDpiScale
	EndIf

	Local $h = $oMain.Height
	If $oCtrls.hasMenu Then
		$h = $h + _WinAPI_GetSystemMetrics($SM_CYMENU)
	EndIf
	If $h <> -1 Then
		$h &= $sDpiScale
	EndIf

	Local $x = $oMain.Left
	If $x <> -1 Then
		$x &= $sDpiScale
	EndIf

	Local $y = $oMain.Top
	If $y <> -1 Then
		$y &= $sDpiScale
	EndIf

	Local $setOnEvent = ""
	If $bOnEventMode Then
		$setOnEvent = 'GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitMain")' & @CRLF
	EndIf

	Local $background = ""
	If $oMain.Background <> -1 And $oMain.Background <> "" Then
		$background = "GUISetBkColor(0x" & Hex($oMain.Background, 6) & ")" & @CRLF
	Else
		$background = ""
	EndIf


	Local $code = ""
	If $bAddDpiScale Then
		$code &= "#AutoIt3Wrapper_Res_HiDpi=y" & @CRLF & @CRLF
	EndIf

	If $bOnEventMode Then
		$code &= 'Opt("GUIOnEventMode", 1)' & @CRLF & @CRLF
	EndIf

	$code &= $includes & @CRLF & @CRLF
	If $bAddDpiScale Then
		$code &= "Global $fDpiFactor = _GDIPlus_GraphicsGetDPIRatio()" & @CRLF & @CRLF
	EndIf
	$code &= $regionStart & @CRLF

	If $bGuiFunction Then
		For $line in $globals
			$code &= $line
		Next
		$code &= @CRLF

		Local $mDocData = _objDocData()
		$mDocData.name = "_guiCreate"
		$mDocData.description = "Create the main GUI"
		$code &= _functionDoc($mDocData) & @CRLF

		$code &= "Func _guiCreate()" & @CRLF
	EndIf

	Local $guiBodyCode = ""

;~ 			"Global $MainStyle = BitOR($WS_OVERLAPPED, $WS_CAPTION, $WS_SYSMENU, $WS_VISIBLE, $WS_CLIPSIBLINGS, $WS_MINIMIZEBOX)" & @CRLF
	If $oMain.Name = "" Then
		$guiBodyCode &= 'GUICreate("' & $gdtitle & '", ' & $w & ", " & $h & ", " & $x & ", " & $y & ")" & @CRLF
	Else
		$guiBodyCode &= "Global $" & $oMain.Name & ' = GUICreate("' & $gdtitle & '", ' & $w & ", " & $h & ", " & $x & ", " & $y & ")" & @CRLF
	EndIf

	$guiBodyCode &= $setOnEvent & _
		$background & _
		@CRLF & $controls

	If $bGuiFunction Then
		$guiBodyCode = StringReplace($guiBodyCode, "Global ", "")
		$guiBodyCode = @TAB & StringReplace($guiBodyCode, @CRLF, @CRLF & @TAB)
		$guiBodyCode = StringTrimRight($guiBodyCode, 1)
		$guiBodyCode &= "EndFunc   ;==>_guiCreate" & @CRLF
	EndIf

	$code &= $guiBodyCode & _
		$regionEnd & @CRLF & @CRLF & _
		$FuncMain & @CRLF & @CRLF

	If $bOnEventMode Then
		$code &= @CRLF & $FuncOnEventMode
	EndIf

	If $bAddDpiScale Then
		$code &= @CRLF & $FuncDpiScaling
	EndIf
	Return $code
EndFunc   ;==>_code_generation


;------------------------------------------------------------------------------
; Title...........: _functionDoc
; Description.....: generate the function doc based on template
;------------------------------------------------------------------------------
Func _functionDoc($mDocData)
	If Not IsObj($mDocData) Then Return ""

	Local $sFileData = FileRead(@ScriptDir & "\storage\templateFunctionDoc.au3")
	If @error Then Return ""

	$sFileData = StringRegExpReplace($sFileData, "\%\%name\%\%", $mDocData.name)
	$sFileData = StringRegExpReplace($sFileData, "\%\%description\%\%", $mDocData.description)

	Return $sFileData
EndFunc   ;==>_functionDoc


;------------------------------------------------------------------------------
; Title...........: _generate_controls
; Description.....: generate the code for the controls
;------------------------------------------------------------------------------
Func _generate_controls(Const $oCtrl, $sDpiScale)
	If $oCtrl.Type = "TabItem" Then Return 0

	;apply the DPI scaling factor
	Local $left = $oCtrl.Left
	If $left <> -1 Then
		$left &= $sDpiScale
	EndIf

	Local $top = $oCtrl.Top
	If $top <> -1 Then
		$top &= $sDpiScale
	EndIf

	Local $width = $oCtrl.Width
	If $width <> -1 Then
		$width &= $sDpiScale
	EndIf

	Local $height = $oCtrl.Height
	If $height <> -1 Then
		$height &= $sDpiScale
	EndIf

	Local Const $ltwh = $left & ", " & $top & ", " & $width & ", " & $height

	; The general template is GUICtrlCreateXXX( "text", left, top [, width [, height [, style [, exStyle]]] )
	; but some controls do not use this.... Avi, Icon, Menu, Menuitem, Progress, Tabitem, TreeViewitem, updown
	Local $mControls

	Local $scopeString = "Global"
	If Not $oCtrl.Global Then $scopeString = "Local"

	Switch StringStripWS($oCtrl.Name, $STR_STRIPALL) <> ''
		Case True
			$mControls = $scopeString & " $" & $oCtrl.Name & " = "
	EndSwitch

	Switch $oCtrl.Type
		Case "Progress", "Slider", "TreeView" ; no text field
			$mControls &= "GUICtrlCreate" & $oCtrl.Type & '(' & $ltwh & ")" & @CRLF

		Case "Icon" ; extra iconid [set to zero]
			$mControls &= "GUICtrlCreate" & $oCtrl.Type & '("' & $oCtrl.Text & '", 0, ' & $ltwh & ")" & @CRLF

		Case "Tab"
			$mControls &= "GUICtrlCreate" & $oCtrl.Type & '(' & $ltwh & ')' & @CRLF

			Local $oTab
			For $hTab In $oCtrl.Tabs
				$oTab = $oCtrls.get($hTab)
				$mControls &= $scopeString & " $" & $oTab.Name & " = "
				$mControls &= 'GUICtrlCreateTabItem("' & $oTab.Text & '")' & @CRLF
				$mControls &= 'GUICtrlCreateTabItem("")' & @CRLF
			Next

		Case "Updown"
			$mControls &= "GUICtrlCreateInput" & '("' & $oCtrl.Text & '", ' & $ltwh & ")" & @CRLF
			$mControls &= "GUICtrlCreateUpdown(-1)" & @CRLF

		Case "Pic"
			$mControls &= "GUICtrlCreate" & $oCtrl.Type & '("", ' & $ltwh & ")" & @CRLF
			$mControls &= "GUICtrlSetImage(-1, " & '"' & $samplebmp & '")' & @CRLF

		Case "Menu"
			$mControls &= "GUICtrlCreate" & $oCtrl.Type & '("' & $oCtrl.Text & '")' & @CRLF

			For $oMenuItem In $oCtrl.MenuItems
				$mControls &= $scopeString & " $" & $oMenuItem.Name & " = "
				$mControls &= 'GUICtrlCreateMenuItem("' & $oMenuItem.Text & '", $' & $oCtrl.Name & ')' & @CRLF
			Next

		Case "IP"
;~ 			_GUICtrlIpAddress_Create($hGUI, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
			$mControls &= "_GUICtrlIpAddress_Create" & '($' & $oMain.Name & ', ' & $ltwh & ")" & @CRLF
			$mControls &= "_GUICtrlIpAddress_Set($" & $oCtrl.Name & ', "' & $oCtrl.Text & '")' & @CRLF

		Case Else
			$mControls &= "GUICtrlCreate" & $oCtrl.Type & '("' & $oCtrl.Text & '", ' & $ltwh & ")" & @CRLF
	EndSwitch

	If $oCtrl.Color <> -1 Then
		$mControls &= "GUICtrlSetColor(-1, 0x" & Hex($oCtrl.Color, 6) & ")" & @CRLF
	EndIf
	If $oCtrl.Background <> -1 Then
		$mControls &= "GUICtrlSetBkColor(-1, 0x" & Hex($oCtrl.Background, 6) & ")" & @CRLF
	EndIf

	Return $mControls
EndFunc   ;==>_generate_controls


;------------------------------------------------------------------------------
; Title...........: _generate_includes
; Description.....: generate the code for the includes
;------------------------------------------------------------------------------
Func _generate_includes(Const $oCtrl, Const $includes)
	Switch $oCtrl.Type
		Case "Button", "Checkbox", "Group", "Radio"
			If Not StringInStr($includes, "<ButtonConstants.au3>") Then
				Return @CRLF & "#include <ButtonConstants.au3>"
			EndIf

		Case "Tab"
			If Not StringInStr($includes, "<GUITab.au3>") Then
				Return @CRLF & "#include <GUITab.au3>"
			EndIf

		Case "Date"
			If Not StringInStr($includes, "<DateTimeConstants.au3>") Then
				Return @CRLF & "#include <DateTimeConstants.au3>"
			EndIf

		Case "Edit", "Input"
			If Not StringInStr($includes, "<EditConstants.au3>") Then
				Return @CRLF & "#include <EditConstants.au3>"
			EndIf

		Case "Icon", "Label", "Pic"
			If Not StringInStr($includes, "<StaticConstants.au3>") Then
				Return @CRLF & "#include <StaticConstants.au3>"
			EndIf

		Case "List"
			If Not StringInStr($includes, "<ListBoxConstants.au3>") Then
				Return @CRLF & "#include <ListBoxConstants.au3>"
			EndIf

		Case "Progress", "Slider", "TreeView", "Combo"
			If Not StringInStr($includes, '<' & $oCtrl.Type & "Constants.au3>") Then
				Return @CRLF & "#include <" & $oCtrl.Type & "Constants.au3>"
			EndIf

		Case "IP"
			If Not StringInStr($includes, "<GuiIPAddress.au3>") Then
				Return @CRLF & "#include <GuiIPAddress.au3>"
			EndIf
	EndSwitch

	Return ""
EndFunc   ;==>_generate_includes

;------------------------------------------------------------------------------
; Title...........: _save_code
; Description.....: generate the au3 code and save to file
;------------------------------------------------------------------------------
Func _save_code()
	Local $code = _code_generation()
	_copy_code_to_output($code)
EndFunc   ;==>_save_code


;------------------------------------------------------------------------------
; Title...........: _copy_code_to_output
; Description.....: Save generated code to file
; Author..........: TheSaint
; Modified By.....: KurtyKurtyBoy
;------------------------------------------------------------------------------
Func _copy_code_to_output(Const $code)
	Switch StringInStr($CmdLineRaw, "/StdOut")
		Case True
			_log("#region ; --- " & $oMain.AppName & " generated code Start ---" & @CRLF & _
					StringReplace($code, @CRLF, @LF) & @CRLF & _
					"#endregion ; --- " & $oMain.AppName & " generated code End ---")

		Case False
			If $mygui = "" Then
				$mygui = "MyGUI.au3"
			EndIf

			Local Const $destination = FileSaveDialog("Save GUI to file?", "", "AutoIt (*.au3)", BitOR($FD_FILEMUSTEXIST, $FD_PATHMUSTEXIST, $FD_PROMPTOVERWRITE), $mygui)

			If @error = 1 Or Not $destination Then
				ClipPut($code)
				$bStatusNewMessage = True
				_GUICtrlStatusBar_SetText($hStatusbar, "Script copied to clipboard")
			Else
				FileDelete($destination)

				FileWrite($destination, $code)

				$bStatusNewMessage = True
				_GUICtrlStatusBar_SetText($hStatusbar, "Saved to file")
			EndIf
	EndSwitch
EndFunc   ;==>_copy_code_to_output

Func _getFuncMain($bOnEventMode, $bGuiFunction)
	;function documentation template
	Local $mDocData = _objDocData()
	$mDocData.name = "_main"
	$mDocData.description = "run the main program loop"
	Local $FuncDoc = _functionDoc($mDocData) & @CRLF

	Local $code = '' & _
			"_main()" & @CRLF & @CRLF & _
			$FuncDoc & _
			"Func _main()" & @CRLF
			If $bGuiFunction Then
				$code &= @TAB & "_guiCreate()" & @CRLF
			EndIf
			$code &= @TAB & "GUISetState(@SW_SHOWNORMAL)" & @CRLF & @CRLF & _
			@TAB & "While 1" & @CRLF
	If Not $bOnEventMode Then
		$code &= '' & _
				@TAB & @TAB & "Switch GUIGetMsg()" & @CRLF & _
				@TAB & @TAB & @TAB & "Case $GUI_EVENT_CLOSE" & @CRLF & _
				@TAB & @TAB & @TAB & @TAB & "ExitLoop" & @CRLF & @CRLF & _
				@TAB & @TAB & @TAB & "Case Else" & @CRLF & _
				@TAB & @TAB & @TAB & @TAB & ";" & @CRLF & _
				@TAB & @TAB & "EndSwitch" & @CRLF
	Else
		$code &= '' & _
				@TAB & @TAB & "Sleep(100)" & @CRLF
	EndIf
	$code &= '' & _
			@TAB & "WEnd" & @CRLF & _
			"EndFunc   ;==>_main"

	Return $code
EndFunc   ;==>_getFuncMain

Func _getFuncOnExit()
	;function documentation template
	Local $mDocData = _objDocData()
	$mDocData.name = "_onExitMain"
	$mDocData.description = "Clean up and exit the program"
	Local $FuncDoc = _functionDoc($mDocData) & @CRLF

	Local $code = '' & _
			$FuncDoc & _
			'Func _onExitMain()' & @CRLF & _
			@TAB & 'GUIDelete()' & @CRLF & _
			@TAB & 'Exit' & @CRLF & _
			'EndFunc   ;==>_onExitMain' & @CRLF

	Return $code
EndFunc   ;==>_getFuncOnExit

Func _getFuncDpiScaling()
	Local $code = '' & _
			';------------------------------------------------------------------------------' & @CRLF & _
			'; Name ..........: _GDIPlus_GraphicsGetDPIRatio' & @CRLF & _
			'; Description ...:' & @CRLF & _
			'; Syntax ........: _GDIPlus_GraphicsGetDPIRatio([$iDPIDef = 96])' & @CRLF & _
			'; Parameters ....: $iDPIDef             - [optional] An integer value. Default is 96.' & @CRLF & _
			'; Return values .: Scaling value for control sizes and positions' & @CRLF & _
			'; Author ........: UEZ' & @CRLF & _
			'; Modified by....: KurtyKurtyBoy' & @CRLF & _
			'; Link ..........: http://www.autoitscript.com/forum/topic/159612-dpi-resolution-problem/?hl=%2Bdpi#entry1158317' & @CRLF & _
			';------------------------------------------------------------------------------' & @CRLF & _
			'Func _GDIPlus_GraphicsGetDPIRatio($iDPIDef = 96)' & @CRLF & _
			@TAB & '_GDIPlus_Startup()' & @CRLF & _
			@TAB & 'Local $hGfx = _GDIPlus_GraphicsCreateFromHWND(0)' & @CRLF & _
			@TAB & 'If @error Then Return SetError(1, @extended, 0)' & @CRLF & _
			@TAB & 'Local $aResult' & @CRLF & _
			@TAB & '#forcedef $__g_hGDIPDll, $ghGDIPDll' & @CRLF & _
			@CRLF & _
			@TAB & '$aResult = DllCall($__g_hGDIPDll, "int", "GdipGetDpiX", "handle", $hGfx, "float*", 0)' & @CRLF & _
			@CRLF & _
			@TAB & 'If @error Then Return SetError(2, @extended, 0)' & @CRLF & _
			@TAB & 'Local $iDPI = $aResult[2]' & @CRLF & _
			@TAB & 'Local $aresults[2] = [$iDPIDef / $iDPI, $iDPI / $iDPIDef]' & @CRLF & _
			@TAB & '_GDIPlus_GraphicsDispose($hGfx)' & @CRLF & _
			@TAB & '_GDIPlus_Shutdown()' & @CRLF & _
			@CRLF & _
			@TAB & 'Return $aresults[1]' & @CRLF & _
			'EndFunc   ;==>_GDIPlus_GraphicsGetDPIRatio' & @CRLF

	Return $code
EndFunc   ;==>_getFuncDpiScaling


Func _objDocData()
	Local $oObject = _AutoItObject_Create()

	_AutoItObject_AddProperty($oObject, "name", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oObject, "description", $ELSCOPE_PUBLIC, "")

	Return $oObject
EndFunc