; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_definitionMgmt.au3
; Description ...: Save and load GUI definition files
; ===============================================================================================================================


;------------------------------------------------------------------------------
; Title...........: _save_gui_definition
; Description.....:	Save GUI to definition file
; Author..........: Roy
; Modified by.....: KurtyKurtyBoy
; Notes...........:	This can be optimized by creating the file in memory then writing at once
;------------------------------------------------------------------------------
Func _save_gui_definition()
	If $AgdOutFile = "" Then
		; added by: TheSaint
		If $lfld = "" Then
			$lfld = IniRead($sIniPath, "Save Folder", "Last", "")
		EndIf

		If Not FileExists($lfld) Then
			$lfld = ""
		EndIf

		If $lfld = "" Then
			$lfld = @MyDocumentsDir
		EndIf

		$AgdOutFile = FileSaveDialog("Save GUI Definition to file?", $lfld, "AutoIt Gui Definitions (*.agd)", BitOR($FD_PATHMUSTEXIST, $FD_PROMPTOVERWRITE), StringReplace($gdtitle, '"', ""))

		If @error = 1 Or $AgdOutFile = "" Then
			$bStatusNewMessage = True
			_GUICtrlStatusBar_SetText($hStatusbar, "Error saving definition file!")
;~ 			SplashTextOn("Save GUI Definition to file", "Definition not saved!", 200, 80)

;~ 			Sleep(1000)

;~ 			SplashOff()

			Return
		Else
			; added by: TheSaint
			$lfld = StringInStr($AgdOutFile, "\", 0, -1)

			$lfld = StringLeft($AgdOutFile, $lfld - 1)

			IniWrite($sIniPath, "Save Folder", "Last", $lfld)

			If StringRight($AgdOutFile, 4) <> ".agd" Then
				$AgdOutFile = $AgdOutFile & ".agd"
			EndIf

			$mygui = StringReplace($AgdOutFile, $lfld & "\", "")

			$mygui = StringReplace($mygui, ".agd", "")

			$gdtitle = '"' & $mygui & '"'

			$mygui = $mygui & ".au3"
		EndIf
	EndIf

	FileDelete($AgdOutFile)

	If @error Then
		$bStatusNewMessage = True
		_GUICtrlStatusBar_SetText($hStatusbar, "Error saving definition file!")
;~ 		SplashTextOn("Save GUI Definition to file", "Definition not saved!", 200, 80)

;~ 		Sleep(1000)

;~ 		SplashOff()

		Return
	EndIf

	Local Const $p = WinGetPos($hGUI)

	IniWrite($AgdOutFile, "Main", "guiwidth", $win_client_size[0])
	IniWrite($AgdOutFile, "Main", "guiheight", $win_client_size[1])
	IniWrite($AgdOutFile, "Main", "Left", $p[0])
	IniWrite($AgdOutFile, "Main", "Top", $p[1])
	IniWrite($AgdOutFile, "Main", "Width", $p[2])
	IniWrite($AgdOutFile, "Main", "Height", $p[3])
	IniWrite($AgdOutFile, "Main", "Name", $mainName)

	Local Const $ctrl_count = $mControls.ControlCount

	IniWrite($AgdOutFile, "Main", "numctrls", $ctrl_count)

	For $i = 1 To $ctrl_count
		Local $Key = "Control_" & $i

		Local $mCtrl = $mControls[$i]

		Local $handle = $mCtrl.Hwnd

		Local $pos = ControlGetPos($hGUI, "", $handle)

		Local $text = ControlGetText($hGUI, "", $handle)

		If @error Then
			$text = $mControls[$i].Name
		EndIf

		IniWrite($AgdOutFile, $Key, "Type", $mCtrl.Type)
		IniWrite($AgdOutFile, $Key, "Name", $mCtrl.Name)
		IniWrite($AgdOutFile, $Key, "Text", $text)
		IniWrite($AgdOutFile, $Key, "Visible", $mCtrl.Visible)
		IniWrite($AgdOutFile, $Key, "OnTop", $mCtrl.OnTop)
		IniWrite($AgdOutFile, $Key, "DropAccepted", $mCtrl.DropAccepted)
		IniWrite($AgdOutFile, $Key, "Text", $text)
		IniWrite($AgdOutFile, $Key, "Left", $pos[0])
		IniWrite($AgdOutFile, $Key, "Top", $pos[1])
		IniWrite($AgdOutFile, $Key, "Width", $pos[2])
		IniWrite($AgdOutFile, $Key, "Height", $pos[3])
		If $mCtrl.Color = -1 Then
			IniWrite($AgdOutFile, $Key, "Color", -1)
		Else
			IniWrite($AgdOutFile, $Key, "Color", "0x" & Hex($mCtrl.Color, 6))
		EndIf
		If $mCtrl.Background = -1 Then
			IniWrite($AgdOutFile, $Key, "Background", -1)
		Else
			IniWrite($AgdOutFile, $Key, "Background", "0x" & Hex($mCtrl.Background, 6))
		EndIf

		If $mCtrl.Type = "Tab" Then
			IniWrite($AgdOutFile, $Key, "TabCount", $mCtrl.TabCount)

			Local $tabCount = $mCtrl.TabCount
			Local $tabs = $mCtrl.Tabs
			Local $tab

			If $mCtrl.TabCount > 0 Then
				For $j = 1 To $tabCount
					$tab = $tabs[$j]
					$mControls &= "Global $" & $tab.Name & " = "
					$mControls &= 'GUICtrlCreateTabItem("' & $tab.Text & '")' & @CRLF
					IniWrite($AgdOutFile, $Key, "TabItem" & $j & "_Name", $tab.Name)
					IniWrite($AgdOutFile, $Key, "TabItem" & $j & "_Text", $tab.Text)
				Next
			EndIf
		EndIf
	Next

	$bStatusNewMessage = True
	_GUICtrlStatusBar_SetText($hStatusbar, "Definition saved to file")

;~ 	SplashTextOn("Save GUI Definition to file", "Saved to " & @CRLF & $AgdOutFile, 500, 100)

;~ 	Sleep(1000)

;~ 	SplashOff()
EndFunc   ;==>_save_gui_definition


;------------------------------------------------------------------------------
; Title...........: _load_gui_definition
; Description.....:	Load GUI definition file
; Author..........: Roy
;------------------------------------------------------------------------------
Func _load_gui_definition($AgdInfile = '')
	If $mControls.ControlCount > 0 Then
		Switch MsgBox($MB_ICONWARNING + $MB_YESNO, "Load Gui Definition from file", "Loading a Gui Definition will clear existing controls." & @CRLF & "Are you sure?" & @CRLF)
			Case $IDNO
				Return
		EndSwitch
	EndIf

	Switch $AgdInfile
		Case ''
			; added by: TheSaint
			$lfld = IniRead($sIniPath, "Save Folder", "Last", "")

			If $lfld = "" Then
				$lfld = @MyDocumentsDir
			EndIf

			If Not $CmdLine[0] Then ; mod by: TheSaint
				$AgdInfile = FileOpenDialog("Load GUI Definition from file?", $lfld, "AutoIt Gui Definitions (*.agd)", $FD_FILEMUSTEXIST)

				If @error Then
					Return
				EndIf
			EndIf
	EndSwitch

	$AgdOutFile = $AgdInfile

	Local Const $w = IniRead($AgdInfile, "Main", "guiwidth", -1)

	If $w = -1 Then
		$bStatusNewMessage = True
		_GUICtrlStatusBar_SetText($hStatusbar, "Error loading gui definition file!")
;~ 		MsgBox($MB_ICONERROR, "Load Gui Error", "Error loading gui definition.")

		Return
	EndIf

	;only wipe if GUI exists already
	If Not $CmdLine[0] Then
		_wipe_current_gui()
	EndIf

	WinMove($hGUI, "", IniRead($AgdInfile, "Main", "Left", -1), _
			IniRead($AgdInfile, "Main", "Top", -1), _
			IniRead($AgdInfile, "Main", "Width", -1), _
			IniRead($AgdInfile, "Main", "Height", -1))
	Local Const $numCtrls = IniRead($AgdInfile, "Main", "numctrls", -1)
	$mainName = IniRead($AgdInfile, "Main", "Name", "hGUI")

	Local $control[], $Key

	For $i = 1 To $numCtrls
		$Key = "Control_" & $i

		$control.HwndCount = 1
		$control.Type = IniRead($AgdInfile, $Key, "Type", -1)
		$control.Name = IniRead($AgdInfile, $Key, "Name", -1)
		$control.Text = IniRead($AgdInfile, $Key, "Text", -1)
		$control.Visible = IniRead($AgdInfile, $Key, "Visible", 1)
		$control.OnTop = IniRead($AgdInfile, $Key, "OnTop", 0)
		$control.Left = IniRead($AgdInfile, $Key, "Left", -1)
		$control.Top = IniRead($AgdInfile, $Key, "Top", -1)
		$control.Width = IniRead($AgdInfile, $Key, "Width", -1)
		$control.Height = IniRead($AgdInfile, $Key, "Height", -1)
		$control.Color = IniRead($AgdInfile, $Key, "Color", -1)
		If $control.Color <> -1 Then
			$control.Color = Dec(StringReplace($control.Color, "0x", ""))
		EndIf
		$control.Background = IniRead($AgdInfile, $Key, "Background", -1)
		If $control.Background <> -1 Then
			$control.Background = Dec(StringReplace($control.Background, "0x", ""))
		EndIf

		$mCtrl = _create_ctrl($control)

		If $control.Type = "Tab" Then
			Local $tabCount = IniRead($AgdInfile, $Key, "TabCount", 0)
			Local $tabs[]
			Local $tab[]

			If $tabCount > 0 Then
				For $j = 1 To $tabCount
					_new_tab()
					$mCtrl = _control_map_from_hwnd($mCtrl.Hwnd)
					$tabs = $mCtrl.Tabs
					$tabs[$j].Name = IniRead($AgdInfile, $Key, "TabItem" & $j & "_Name", "tempName")
					$tabs[$j].Text = IniRead($AgdInfile, $Key, "TabItem" & $j & "_Text", "tempText")
					_GUICtrlTab_SetItemText($mCtrl.Hwnd, $j - 1, $tabs[$j].Text)
					$mCtrl.Tabs = $tabs
					_update_control($mCtrl)
				Next
			EndIf
		EndIf
	Next

	$mControls.Selected1 = Null

	_formObjectExplorer_updateList()
	_refreshGenerateCode()

	$bStatusNewMessage = True
	_GUICtrlStatusBar_SetText($hStatusbar, "Loaded successfully")

;~ 	SplashTextOn("Load GUI Definition from file", "Loaded from " & @CRLF & $AgdInfile, 500, 100)

;~ 	Sleep(1000)

;~ 	SplashOff()
EndFunc   ;==>_load_gui_definition
