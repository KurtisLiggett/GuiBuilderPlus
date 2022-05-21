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

	Local Const $ctrl_count = $oCtrls.count

	IniWrite($AgdOutFile, "Main", "numctrls", $ctrl_count)

	$i = 1
	For $oCtrl In $oCtrls.ctrls
		Local $Key = "Control_" & $i

		Local $handle = $oCtrl.Hwnd

		Local $pos = ControlGetPos($hGUI, "", $handle)

		Local $text = ControlGetText($hGUI, "", $handle)

		If @error Then
			$text = $oCtrl.Name
		EndIf

		IniWrite($AgdOutFile, $Key, "Type", $oCtrl.Type)
		IniWrite($AgdOutFile, $Key, "Name", $oCtrl.Name)
		IniWrite($AgdOutFile, $Key, "Text", $text)
		IniWrite($AgdOutFile, $Key, "Visible", $oCtrl.Visible)
		IniWrite($AgdOutFile, $Key, "OnTop", $oCtrl.OnTop)
		IniWrite($AgdOutFile, $Key, "DropAccepted", $oCtrl.DropAccepted)
		IniWrite($AgdOutFile, $Key, "Text", $text)
		IniWrite($AgdOutFile, $Key, "Left", $pos[0])
		IniWrite($AgdOutFile, $Key, "Top", $pos[1])
		IniWrite($AgdOutFile, $Key, "Width", $pos[2])
		IniWrite($AgdOutFile, $Key, "Height", $pos[3])
		If $oCtrl.Color = -1 Then
			IniWrite($AgdOutFile, $Key, "Color", -1)
		Else
			IniWrite($AgdOutFile, $Key, "Color", "0x" & Hex($oCtrl.Color, 6))
		EndIf
		If $oCtrl.Background = -1 Then
			IniWrite($AgdOutFile, $Key, "Background", -1)
		Else
			IniWrite($AgdOutFile, $Key, "Background", "0x" & Hex($oCtrl.Background, 6))
		EndIf

		If $oCtrl.Type = "Tab" Then
			IniWrite($AgdOutFile, $Key, "TabCount", $oCtrl.TabCount)

			Local $tabCount = $oCtrl.TabCount
			Local $tabs = $oCtrl.Tabs
			Local $tab

			If $oCtrl.TabCount > 0 Then
				Local $j = 1
				For $oTab In $oCtrl.Tabs
					IniWrite($AgdOutFile, $Key, "TabItem" & $j & "_Name", $oTab.Name)
					IniWrite($AgdOutFile, $Key, "TabItem" & $j & "_Text", $oTab.Text)
					$j += 1
				Next
			EndIf
		EndIf
		$i += 1
	Next

	$bStatusNewMessage = True
	_GUICtrlStatusBar_SetText($hStatusbar, "Definition saved to file")
EndFunc   ;==>_save_gui_definition


;------------------------------------------------------------------------------
; Title...........: _load_gui_definition
; Description.....:	Load GUI definition file
; Author..........: Roy
;------------------------------------------------------------------------------
Func _load_gui_definition($AgdInfile = '')
	If $oCtrls.count > 0 Then
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

	Local $oCtrl, $Key


	For $i = 1 To $numCtrls
		$Key = "Control_" & $i
		$oCtrl = $oCtrls.createNew()

		$oCtrl.HwndCount = 1
		$oCtrl.Type = IniRead($AgdInfile, $Key, "Type", -1)
		$oCtrl.Name = IniRead($AgdInfile, $Key, "Name", -1)
		$oCtrl.Text = IniRead($AgdInfile, $Key, "Text", -1)
		$oCtrl.Visible = IniRead($AgdInfile, $Key, "Visible", 1)
		$oCtrl.OnTop = IniRead($AgdInfile, $Key, "OnTop", 0)
		$oCtrl.Left = IniRead($AgdInfile, $Key, "Left", -1)
		$oCtrl.Top = IniRead($AgdInfile, $Key, "Top", -1)
		$oCtrl.Width = IniRead($AgdInfile, $Key, "Width", -1)
		$oCtrl.Height = IniRead($AgdInfile, $Key, "Height", -1)
		$oCtrl.Color = IniRead($AgdInfile, $Key, "Color", -1)
		If $oCtrl.Color <> -1 Then
			$oCtrl.Color = Dec(StringReplace($oCtrl.Color, "0x", ""))
		EndIf
		$oCtrl.Background = IniRead($AgdInfile, $Key, "Background", -1)
		If $oCtrl.Background <> -1 Then
			$oCtrl.Background = Dec(StringReplace($oCtrl.Background, "0x", ""))
		EndIf

		Local $oNewCtrl = _create_ctrl($oCtrl, True)


		$oCtrl = $oCtrls.get($oNewCtrl.Hwnd)
		If $oCtrl.Type = "Tab" Then
			Local $tabCount = IniRead($AgdInfile, $Key, "TabCount", 0)

			If $tabCount > 0 Then
				For $j = 1 To $tabCount
					_new_tab()

					$oCtrl.Tabs.at($j - 1).Name = IniRead($AgdInfile, $Key, "TabItem" & $j & "_Name", "tempName")
					$oCtrl.Tabs.at($j - 1).Text = IniRead($AgdInfile, $Key, "TabItem" & $j & "_Text", "tempText")
					_GUICtrlTab_SetItemText($oCtrl.Hwnd, $j - 1, $oCtrl.Tabs.at($j - 1).Text)
				Next
			EndIf
		EndIf
	Next

	_formObjectExplorer_updateList()
	_refreshGenerateCode()

	$bStatusNewMessage = True
	_GUICtrlStatusBar_SetText($hStatusbar, "Loaded successfully")
EndFunc   ;==>_load_gui_definition
