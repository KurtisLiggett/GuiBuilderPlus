; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_definitionMgmt.au3
; Description ...: Save and load GUI definition files
; ===============================================================================================================================


Func _onSaveGui()
	_save_gui_definition()
EndFunc   ;==>_onSaveGui

Func _onSaveAsGui()
	_save_gui_definition(True)
EndFunc   ;==>_onSaveAsGui

;------------------------------------------------------------------------------
; Title...........: _save_gui_definition
; Description.....:	Save GUI to definition file
; Author..........: Roy
; Modified by.....: KurtyKurtyBoy
; Notes...........:	This can be optimized by creating the file in memory then writing at once
;------------------------------------------------------------------------------
Func _save_gui_definition($saveAs = False)
	Local $objOutput

	If $AgdOutFile = "" Or $saveAs Then
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

		Local $gdtitle = _get_script_title()
		Local $OutFile = FileSaveDialog("Save GUI Definition to file?", $lfld, "AutoIt Gui Definitions (*.agd)", BitOR($FD_PATHMUSTEXIST, $FD_PROMPTOVERWRITE), StringReplace($gdtitle, '"', ""))

		If @error = 1 Or $OutFile = "" Then
			$bStatusNewMessage = True
			_GUICtrlStatusBar_SetText($hStatusbar, "Error saving definition file!")
			Return -1
		Else
			$AgdOutFile = $OutFile

			; added by: TheSaint
			$lfld = StringInStr($AgdOutFile, "\", 0, -1)

			$lfld = StringLeft($AgdOutFile, $lfld - 1)

			IniWrite($sIniPath, "Save Folder", "Last", $lfld)

			If StringRight($AgdOutFile, 4) <> ".agd" Then
				$AgdOutFile = $AgdOutFile & ".agd"
			EndIf

			$mygui = StringReplace($AgdOutFile, $lfld & "\", "")

			$mygui = StringReplace($mygui, ".agd", "")

			$mygui = $mygui & ".au3"
		EndIf
	EndIf

	FileDelete($AgdOutFile)

	If @error Then
		$bStatusNewMessage = True
		_GUICtrlStatusBar_SetText($hStatusbar, "Error saving definition file!")
		Return -2
	EndIf

	Local $mainHeight = $oMain.Height
	If $oCtrls.hasMenu Then
		$mainHeight += _WinAPI_GetSystemMetrics($SM_CYMENU)
	EndIf

	Local Const $ctrl_count = $oCtrls.count

	Json_Put($objOutput, ".Main.Left", $oMain.Left)
	Json_Put($objOutput, ".Main.Top", $oMain.Top)
	Json_Put($objOutput, ".Main.Width", $oMain.Width)
	Json_Put($objOutput, ".Main.Height", $mainHeight)
	Json_Put($objOutput, ".Main.Name", $oMain.Name)
	Json_Put($objOutput, ".Main.Title", $oMain.Title)
	Json_Put($objOutput, ".Main.Background", $oMain.Background)
	Json_Put($objOutput, ".Main.numctrls", $ctrl_count)
	Json_Put($objOutput, ".Main.styleString", $oMain.styleString)

	$i = 0
	For $oCtrl In $oCtrls.ctrls.Items()
		If $oCtrl.Type = "TabItem" Then ContinueLoop
		If $oCtrl.CtrlParent <> 0 Then ContinueLoop

		Local $handle = $oCtrl.Hwnd

		Json_Put($objOutput, ".Controls[" & $i & "].Type", $oCtrl.Type)
		Json_Put($objOutput, ".Controls[" & $i & "].Name", $oCtrl.Name)
		Json_Put($objOutput, ".Controls[" & $i & "].Text", $oCtrl.Text)
		Json_Put($objOutput, ".Controls[" & $i & "].Visible", $oCtrl.Visible)
		Json_Put($objOutput, ".Controls[" & $i & "].OnTop", $oCtrl.OnTop)
		Json_Put($objOutput, ".Controls[" & $i & "].DropAccepted", $oCtrl.DropAccepted)
		Json_Put($objOutput, ".Controls[" & $i & "].Left", $oCtrl.Left)
		Json_Put($objOutput, ".Controls[" & $i & "].Top", $oCtrl.Top)
		Json_Put($objOutput, ".Controls[" & $i & "].Width", $oCtrl.Width)
		Json_Put($objOutput, ".Controls[" & $i & "].Height", $oCtrl.Height)
		Json_Put($objOutput, ".Controls[" & $i & "].Global", $oCtrl.Global)
		Json_Put($objOutput, ".Controls[" & $i & "].Locked", $oCtrl.Locked)
		Json_Put($objOutput, ".Controls[" & $i & "].styleString", $oCtrl.styleString)
		Json_Put($objOutput, ".Controls[" & $i & "].FontSize", $oCtrl.FontSize)
		Json_Put($objOutput, ".Controls[" & $i & "].FontWeight", $oCtrl.FontWeight)
		Json_Put($objOutput, ".Controls[" & $i & "].FontName", $oCtrl.FontName)
		If $oCtrl.Color = -1 Then
			Json_Put($objOutput, ".Controls[" & $i & "].Color", -1)
		Else
			Json_Put($objOutput, ".Controls[" & $i & "].Color", "0x" & Hex($oCtrl.Color, 6))
		EndIf
		If $oCtrl.Background = -1 Then
			Json_Put($objOutput, ".Controls[" & $i & "].Background", -1)
		Else
			Json_Put($objOutput, ".Controls[" & $i & "].Background", "0x" & Hex($oCtrl.Background, 6))
		EndIf
		Json_Put($objOutput, ".Controls[" & $i & "].CodeString", $oCtrl.CodeString)

		Switch $oCtrl.Type
			Case "Tab"
				Json_Put($objOutput, ".Controls[" & $i & "].TabCount", $oCtrl.TabCount)

				If $oCtrl.TabCount > 0 Then
					Local $j = 0, $oTab
					For $hTab In $oCtrl.Tabs
						$oTab = $oCtrls.get($hTab)
						Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Type", $oTab.Type)
						Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Name", $oTab.Name)
						Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Text", $oTab.Text)

						Local $k = 0
						For $oTabCtrl In $oTab.ctrls.Items()
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Type", $oTabCtrl.Type)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Name", $oTabCtrl.Name)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Text", $oTabCtrl.Text)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Visible", $oTabCtrl.Visible)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].OnTop", $oTabCtrl.OnTop)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].DropAccepted", $oTabCtrl.DropAccepted)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Left", $oTabCtrl.Left)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Top", $oTabCtrl.Top)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Width", $oTabCtrl.Width)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Height", $oTabCtrl.Height)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Global", $oTabCtrl.Global)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Locked", $oTabCtrl.Locked)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].styleString", $oTabCtrl.styleString)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].FontSize", $oTabCtrl.FontSize)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].FontWeight", $oTabCtrl.FontWeight)
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].FontName", $oTabCtrl.FontName)
							If $oTabCtrl.Color = -1 Then
								Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Color", -1)
							Else
								Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Color", "0x" & Hex($oTabCtrl.Color, 6))
							EndIf
							If $oTabCtrl.Background = -1 Then
								Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Background", -1)
							Else
								Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Background", "0x" & Hex($oTabCtrl.Background, 6))
							EndIf
							Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].CodeString", $oTabCtrl.CodeString)
							$k += 1
						Next

						$j += 1
					Next
				EndIf

			Case "Group"
				If $oCtrl.ctrls.Count > 0 Then
					Local $k = 0, $oThisCtrl
					For $oThisCtrl In $oCtrl.ctrls.Items()
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Type", $oThisCtrl.Type)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Name", $oThisCtrl.Name)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Text", $oThisCtrl.Text)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Visible", $oThisCtrl.Visible)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].OnTop", $oThisCtrl.OnTop)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].DropAccepted", $oThisCtrl.DropAccepted)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Left", $oThisCtrl.Left)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Top", $oThisCtrl.Top)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Width", $oThisCtrl.Width)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Height", $oThisCtrl.Height)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Global", $oThisCtrl.Global)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Locked", $oThisCtrl.Locked)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].styleString", $oThisCtrl.styleString)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].FontSize", $oThisCtrl.FontSize)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].FontWeight", $oThisCtrl.FontWeight)
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].FontName", $oThisCtrl.FontName)
						If $oThisCtrl.Color = -1 Then
							Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Color", -1)
						Else
							Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Color", "0x" & Hex($oThisCtrl.Color, 6))
						EndIf
						If $oThisCtrl.Background = -1 Then
							Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Background", -1)
						Else
							Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].Background", "0x" & Hex($oThisCtrl.Background, 6))
						EndIf
						Json_Put($objOutput, ".Controls[" & $i & "].Controls[" & $k & "].CodeString", $oThisCtrl.CodeString)
						$k += 1
					Next
				EndIf
		EndSwitch

		If $oCtrl.Type = "Menu" Then
			Json_Put($objOutput, ".Controls[" & $i & "].MenuItemCount", $oCtrl.Menuitems.count)

			Local $menuCount = $oCtrl.Menuitems.count

			If $menuCount > 0 Then
				Local $j = 0
				For $oMenuItem In $oCtrl.MenuItems
					Json_Put($objOutput, ".Controls[" & $i & "].MenuItems[" & $j & "].Name", $oMenuItem.Name)
					Json_Put($objOutput, ".Controls[" & $i & "].MenuItems[" & $j & "].Text", $oMenuItem.Text)
					$j += 1
				Next
			EndIf
		EndIf
		$i += 1
	Next

	Local $Json = Json_Encode($objOutput, $Json_PRETTY_PRINT)
	Local $hFile = FileOpen($AgdOutFile, $FO_OVERWRITE)
	FileWrite($hFile, $Json)
	FileClose($hFile)

	$bStatusNewMessage = True
	_GUICtrlStatusBar_SetText($hStatusbar, "Definition saved to file")

	$oMain.hasChanged = False
EndFunc   ;==>_save_gui_definition


Func _onload_gui_definition()
	_load_gui_definition()
EndFunc   ;==>_onload_gui_definition


;------------------------------------------------------------------------------
; Title...........: _load_gui_definition
; Description.....:	Load GUI definition file
; Author..........: Roy
;------------------------------------------------------------------------------
Func _load_gui_definition($AgdInfile = '', $oImportData = -1)
	Static $firstLoad = True
	Local $objInput

	If Not IsObj($oImportData) Then
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

		_SendMessage($hGUI, $WM_SETREDRAW, False)

		Local $sData = FileRead($AgdInfile)

		If StringLeft($sData, 1) = "[" Then
			_load_gui_definition_ini($AgdInfile)
			_SendMessage($hGUI, $WM_SETREDRAW, True)
			_WinAPI_RedrawWindow($hGUI)
			Return
		EndIf

		$objInput = Json_Decode($sData)
	Else
		$objInput = $oImportData
	EndIf

	;only wipe if GUI exists already
	If Not $firstLoad Or Not $CmdLine[0] Then
		_wipe_current_gui()
	EndIf
	If $firstLoad Then $firstLoad = False

	$oMain.Name = _Json_Get($objInput, ".Main.Name", "hGUI")
	$oMain.Title = _Json_Get($objInput, ".Main.Title", StringTrimRight(StringTrimLeft(_get_script_title(), 1), 1))
	$oMain.Left = _Json_Get($objInput, ".Main.Left", -1)
	$oMain.Top = _Json_Get($objInput, ".Main.Top", -1)
	$oMain.Width = _Json_Get($objInput, ".Main.Width", 400)
	$oMain.Height = _Json_Get($objInput, ".Main.Height", 350)
	If IsHWnd($hGUI) Then
		Local $newLeft = $oMain.Left, $newTop = $oMain.Top
		If $oMain.Left = -1 Then
			$newLeft = Default
		EndIf
		If $oMain.Top = -1 Then
			$newTop = Default
		EndIf
		WinMove($hGUI, "", $newLeft, $newTop, $oMain.Width + $iGuiFrameW, $oMain.Height + $iGuiFrameH)
		WinSetTitle($hGUI, "", $oMain.AppName & " - Form (" & $oMain.Width & ", " & $oMain.Height & ")")

		If $oOptions.showGrid Then
			_display_grid($background, $oMain.Width, $oMain.Height)
		EndIf
	EndIf
	$oMain.Background = _Json_Get($objInput, ".Main.Background", -1)
	$oProperties_Main.Background.value = $oMain.Background
	If $oMain.Background <> -1 And $oMain.Background <> "" Then
		$oMain.Background = Dec(StringReplace($oMain.Background, "0x", ""))
		GUISetBkColor($oMain.Background, $hGUI)
	Else
		GUISetBkColor($defaultGuiBkColor, $hGUI)
	EndIf
	$oMain.styleString = _Json_Get($objInput, ".Main.styleString", "")

	$oProperties_Main.Title.value = $oMain.Title
	$oProperties_Main.Name.value = $oMain.Name
	$oProperties_Main.Left.value = $oMain.Left
	$oProperties_Main.Top.value = $oMain.Top
	$oProperties_Main.Width.value = $oMain.Width
	$oProperties_Main.Height.value = $oMain.Height

	Local Const $numCtrls = _Json_Get($objInput, ".Main.numctrls", -1)

	Local $oCtrl, $Key, $oNewCtrl
	Local $aControls = Json_Get($objInput, ".Controls")
	If @error Then
		ConsoleWrite("Error: " & @error & @CRLF)
	EndIf

	For $oThisCtrl In $aControls
		$oCtrl = $oCtrls.createNew()

		$oCtrl.HwndCount = 1
		$oCtrl.Type = _Json_Get($oThisCtrl, ".Type", -1)
		$oCtrl.Name = _Json_Get($oThisCtrl, ".Name", -1)
		$oCtrl.Text = _Json_Get($oThisCtrl, ".Text", -1)
		$oCtrl.Visible = _Json_Get($oThisCtrl, ".Visible", 1)
		$oCtrl.OnTop = _Json_Get($oThisCtrl, ".OnTop", 0)
		$oCtrl.Left = _Json_Get($oThisCtrl, ".Left", -1)
		$oCtrl.Top = _Json_Get($oThisCtrl, ".Top", -1)
		$oCtrl.Width = _Json_Get($oThisCtrl, ".Width", -1)
		$oCtrl.Height = _Json_Get($oThisCtrl, ".Height", -1)
		$oCtrl.Global = _Json_Get($oThisCtrl, ".Global", $GUI_CHECKED)
		$oCtrl.Locked = _Json_Get($oThisCtrl, ".Locked", $GUI_UNCHECKED)
		$oCtrl.styleString = _Json_Get($oThisCtrl, ".styleString", "")
		$oCtrl.Color = _Json_Get($oThisCtrl, ".Color", -1)
		If $oCtrl.Color <> -1 Then
			$oCtrl.Color = Dec(StringReplace($oCtrl.Color, "0x", ""))
		EndIf
		$oCtrl.Background = _Json_Get($oThisCtrl, ".Background", -1)
		If $oCtrl.Background <> -1 Then
			$oCtrl.Background = Dec(StringReplace($oCtrl.Background, "0x", ""))
		EndIf
		$oCtrl.FontSize = _Json_Get($oThisCtrl, ".FontSize", 8.5)
		$oCtrl.FontWeight = _Json_Get($oThisCtrl, ".FontWeight", 400)
		$oCtrl.FontName = _Json_Get($oThisCtrl, ".FontName", "")
		$oCtrl.CodeString = _Json_Get($oThisCtrl, ".CodeString", "")

		$oNewCtrl = _create_ctrl($oCtrl, True)
		Local $aStyles = StringSplit($oNewCtrl.styleString, ", ", $STR_ENTIRESPLIT + $STR_NOCOUNT)
		Local $iOldStyle
		For $sStyle In $aStyles
			$iOldStyle = _WinAPI_GetWindowLong(GUICtrlGetHandle($oNewCtrl.Hwnd), $GWL_STYLE)
			GUICtrlSetStyle($oNewCtrl.Hwnd, BitOR($iOldStyle, Execute($sStyle)))
		Next

		If $oCtrl.FontSize <> 8.5 Then
			If $oCtrl.Type = "IP" Then
				_GUICtrlIpAddress_SetFont($oCtrl.Hwnd, "Arial", $oCtrl.FontSize)
			Else
				GUICtrlSetFont($oCtrl.Hwnd, $oCtrl.FontSize)
			EndIf
		EndIf

		If $oCtrl.FontWeight <> 400 Then
			If $oCtrl.Type = "IP" Then
				_GUICtrlIpAddress_SetFont($oCtrl.Hwnd, "Arial", $oCtrl.FontSize, $oCtrl.FontWeight)
			Else
				GUICtrlSetFont($oCtrl.Hwnd, $oCtrl.FontSize, $oCtrl.FontWeight)
			EndIf
		EndIf

		If $oCtrl.FontName <> "" Then
			If $oCtrl.Type = "IP" Then
				_GUICtrlIpAddress_SetFont($oCtrl.Hwnd, $oCtrl.FontName, $oCtrl.FontSize, $oCtrl.FontWeight)
			Else
				GUICtrlSetFont($oCtrl.Hwnd, $oCtrl.FontSize, $oCtrl.FontWeight, 0, $oCtrl.FontName)
			EndIf
		EndIf

		$oCtrl = $oCtrls.get($oNewCtrl.Hwnd)
		Local $j, $oCtrl2
		Switch $oCtrl.Type
			Case "Tab"
				Local $tabCount = _Json_Get($oThisCtrl, ".TabCount", 0)

				If $tabCount > 0 Then
					Local $aTabs = Json_Get($oThisCtrl, ".Tabs")

					$j = 1
					Local $oTab
					For $oThisTab In $aTabs
						_new_tab(True)

						$oTab = $oCtrls.getLast()
						$oTab.Name = _Json_Get($oThisTab, ".Name", "tempName")
						$oTab.Text = _Json_Get($oThisTab, ".Text", "tempText")
						_GUICtrlTab_SetItemText($oCtrl.Hwnd, $j - 1, $oTab.Text)

						Local $aTabCtrls = Json_Get($oThisTab, ".Controls")
						If Not IsArray($aTabCtrls) Then ContinueLoop
						GUISwitch($hGUI, $oTab.Hwnd)
						For $oTabCtrl In $aTabCtrls
							$oCtrl2 = $oCtrls.createNew()

							$oCtrl2.HwndCount = 1
							$oCtrl2.Type = _Json_Get($oTabCtrl, ".Type", -1)
							$oCtrl2.Name = _Json_Get($oTabCtrl, ".Name", -1)
							$oCtrl2.Text = _Json_Get($oTabCtrl, ".Text", -1)
							$oCtrl2.Visible = _Json_Get($oTabCtrl, ".Visible", 1)
							$oCtrl2.OnTop = _Json_Get($oTabCtrl, ".OnTop", 0)
							$oCtrl2.Left = _Json_Get($oTabCtrl, ".Left", -1)
							$oCtrl2.Top = _Json_Get($oTabCtrl, ".Top", -1)
							$oCtrl2.Width = _Json_Get($oTabCtrl, ".Width", -1)
							$oCtrl2.Height = _Json_Get($oTabCtrl, ".Height", -1)
							$oCtrl2.Global = _Json_Get($oTabCtrl, ".Global", $GUI_CHECKED)
							$oCtrl2.Locked = _Json_Get($oTabCtrl, ".Locked", $GUI_UNCHECKED)
							$oCtrl2.styleString = _Json_Get($oTabCtrl, ".styleString", "")
							$oCtrl2.CodeString = _Json_Get($oTabCtrl, ".CodeString", "")
							$oCtrl2.Color = _Json_Get($oTabCtrl, ".Color", -1)
							If $oCtrl2.Color <> -1 Then
								$oCtrl2.Color = Dec(StringReplace($oCtrl2.Color, "0x", ""))
							EndIf
							$oCtrl2.Background = _Json_Get($oTabCtrl, ".Background", -1)
							If $oCtrl2.Background <> -1 Then
								$oCtrl2.Background = Dec(StringReplace($oCtrl2.Background, "0x", ""))
							EndIf

							$oNewCtrl = _create_ctrl($oCtrl2, True, -1, -1, $oCtrl.Hwnd)
							Local $aStyles = StringSplit($oNewCtrl.styleString, ", ", $STR_ENTIRESPLIT + $STR_NOCOUNT)
							For $sStyle In $aStyles
								$iOldStyle = _WinAPI_GetWindowLong(GUICtrlGetHandle($oNewCtrl.Hwnd), $GWL_STYLE)
								GUICtrlSetStyle($oNewCtrl.Hwnd, BitOR($iOldStyle, Execute($sStyle)))
							Next
						Next
						GUICtrlCreateTabItem('')
						GUISwitch($hGUI)

						$j += 1
					Next
				EndIf

			Case "Group"
				Local $aCtrls = Json_Get($oThisCtrl, ".Controls")
				If Not IsArray($aCtrls) Then ContinueLoop
				For $oGroupCtrl In $aCtrls
					$oCtrl2 = $oCtrls.createNew()

					$oCtrl2.HwndCount = 1
					$oCtrl2.Type = _Json_Get($oGroupCtrl, ".Type", -1)
					$oCtrl2.Name = _Json_Get($oGroupCtrl, ".Name", -1)
					$oCtrl2.Text = _Json_Get($oGroupCtrl, ".Text", -1)
					$oCtrl2.Visible = _Json_Get($oGroupCtrl, ".Visible", 1)
					$oCtrl2.OnTop = _Json_Get($oGroupCtrl, ".OnTop", 0)
					$oCtrl2.Left = _Json_Get($oGroupCtrl, ".Left", -1)
					$oCtrl2.Top = _Json_Get($oGroupCtrl, ".Top", -1)
					$oCtrl2.Width = _Json_Get($oGroupCtrl, ".Width", -1)
					$oCtrl2.Height = _Json_Get($oGroupCtrl, ".Height", -1)
					$oCtrl2.Global = _Json_Get($oGroupCtrl, ".Global", $GUI_CHECKED)
					$oCtrl2.Locked = _Json_Get($oGroupCtrl, ".Locked", $GUI_UNCHECKED)
					$oCtrl2.styleString = _Json_Get($oGroupCtrl, ".styleString", "")
					$oCtrl2.CodeString = _Json_Get($oGroupCtrl, ".CodeString", "")
					$oCtrl2.Color = _Json_Get($oGroupCtrl, ".Color", -1)
					If $oCtrl2.Color <> -1 Then
						$oCtrl2.Color = Dec(StringReplace($oCtrl2.Color, "0x", ""))
					EndIf
					$oCtrl2.Background = _Json_Get($oGroupCtrl, ".Background", -1)
					If $oCtrl2.Background <> -1 Then
						$oCtrl2.Background = Dec(StringReplace($oCtrl2.Background, "0x", ""))
					EndIf

					$oNewCtrl = _create_ctrl($oCtrl2, True, -1, -1, $oCtrl.Hwnd)
					Local $aStyles = StringSplit($oNewCtrl.styleString, ", ", $STR_ENTIRESPLIT + $STR_NOCOUNT)
					For $sStyle In $aStyles
						$iOldStyle = _WinAPI_GetWindowLong(GUICtrlGetHandle($oNewCtrl.Hwnd), $GWL_STYLE)
						GUICtrlSetStyle($oNewCtrl.Hwnd, BitOR($iOldStyle, Execute($sStyle)))
					Next
				Next

		EndSwitch

		If $oCtrl.Type = "Menu" Then
			Local $MenuItemCount = _Json_Get($oThisCtrl, ".MenuItemCount", 0)

			If $MenuItemCount > 0 Then
				Local $aMenuItems = Json_Get($oThisCtrl, ".MenuItems")

				$j = 1
				For $oMenuItem In $aMenuItems
					_new_menuItemCreate($oCtrl, True)

					$oCtrl.MenuItems.at($j - 1).Name = _Json_Get($oMenuItem, ".Name", "tempName")
					$oCtrl.MenuItems.at($j - 1).Text = _Json_Get($oMenuItem, ".Text", "tempText")
					GUICtrlSetData($oCtrl.MenuItems.at($j - 1).Hwnd, $oCtrl.MenuItems.at($j - 1).Text)
					$j += 1
				Next
			EndIf
		EndIf
	Next

	_formObjectExplorer_updateList()
	_refreshGenerateCode()

	_SendMessage($hGUI, $WM_SETREDRAW, True)
	_WinAPI_RedrawWindow($hGUI)

	$bStatusNewMessage = True
	_GUICtrlStatusBar_SetText($hStatusbar, "Loaded successfully")

	$oMain.hasChanged = False
EndFunc   ;==>_load_gui_definition


Func _Json_Get(ByRef $obj, $data, $defaultValue = 0)
	Local $val = Json_Get($obj, $data)
	If @error Then
		Return $defaultValue
	Else
		Return $val
	EndIf
EndFunc   ;==>_Json_Get




;------------------------------------------------------------------------------
; Title...........: _load_gui_definition_ini
; Description.....:	Fallback to load GUI definition from old ini file
; Author..........: Roy
;------------------------------------------------------------------------------
Func _load_gui_definition_ini($AgdInfile = '')
	Static $firstLoad = True

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

	;only wipe if GUI exists already
	If Not $firstLoad Or Not $CmdLine[0] Then
		_wipe_current_gui()
	EndIf
	If $firstLoad Then $firstLoad = False

	$oMain.Name = IniRead($AgdInfile, "Main", "Name", "hGUI")
	$oMain.Title = IniRead($AgdInfile, "Main", "Title", StringTrimRight(StringTrimLeft(_get_script_title(), 1), 1))
	$oMain.Left = IniRead($AgdInfile, "Main", "Left", -1)
	$oMain.Top = IniRead($AgdInfile, "Main", "Top", -1)
	$oMain.Width = IniRead($AgdInfile, "Main", "Width", 400)
	$oMain.Height = IniRead($AgdInfile, "Main", "Height", 350)
	If IsHWnd($hGUI) Then
		Local $newLeft = $oMain.Left, $newTop = $oMain.Top
		If $oMain.Left = -1 Then
			$newLeft = Default
		EndIf
		If $oMain.Top = -1 Then
			$newTop = Default
		EndIf
		WinMove($hGUI, "", $newLeft, $newTop, $oMain.Width + $iGuiFrameW, $oMain.Height + $iGuiFrameH)
		WinSetTitle($hGUI, "", $oMain.AppName & " - Form (" & $oMain.Width & ", " & $oMain.Height & ")")

		If $oOptions.showGrid Then
			_display_grid($background, $oMain.Width, $oMain.Height)
		EndIf
	EndIf
	$oMain.Background = IniRead($AgdInfile, "Main", "Background", -1)
	$oProperties_Main.Background.value = $oMain.Background
	If $oMain.Background <> -1 And $oMain.Background <> "" Then
		$oMain.Background = Dec(StringReplace($oMain.Background, "0x", ""))
		GUISetBkColor($oMain.Background, $hGUI)
	Else
		GUISetBkColor($defaultGuiBkColor, $hGUI)
	EndIf

	$oProperties_Main.Title.value = $oMain.Title
	$oProperties_Main.Name.value = $oMain.Name
	$oProperties_Main.Left.value = $oMain.Left
	$oProperties_Main.Top.value = $oMain.Top
	$oProperties_Main.Width.value = $oMain.Width
	$oProperties_Main.Height.value = $oMain.Height


	Local Const $numCtrls = IniRead($AgdInfile, "Main", "numctrls", -1)


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
		$oCtrl.Global = IniRead($AgdInfile, $Key, "Global", $GUI_CHECKED)
		$oCtrl.Locked = IniRead($AgdInfile, $Key, "Locked", $GUI_UNCHECKED)
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

					$oTab = $oCtrls.getLast()
					$oTab.Name = IniRead($AgdInfile, $Key, "TabItem" & $j & "_Name", "tempName")
					$oTab.Text = IniRead($AgdInfile, $Key, "TabItem" & $j & "_Text", "tempText")
					_GUICtrlTab_SetItemText($oCtrl.Hwnd, $j - 1, $oTab.Text)
				Next
			EndIf
		EndIf

		If $oCtrl.Type = "Menu" Then
			Local $MenuItemCount = IniRead($AgdInfile, $Key, "MenuItemCount", 0)

			If $MenuItemCount > 0 Then
				For $j = 1 To $MenuItemCount
					_new_menuItemCreate($oCtrl)

					$oCtrl.MenuItems.at($j - 1).Name = IniRead($AgdInfile, $Key, "MenuItem" & $j & "_Name", "tempName")
					$oCtrl.MenuItems.at($j - 1).Text = IniRead($AgdInfile, $Key, "MenuItem" & $j & "_Text", "tempText")
					GUICtrlSetData($oCtrl.MenuItems.at($j - 1).Hwnd, $oCtrl.MenuItems.at($j - 1).Text)
				Next
			EndIf
		EndIf

	Next

	_formObjectExplorer_updateList()
	_refreshGenerateCode()

	$bStatusNewMessage = True
	_GUICtrlStatusBar_SetText($hStatusbar, "Loaded successfully")

	$oMain.hasChanged = False
EndFunc   ;==>_load_gui_definition_ini


;------------------------------------------------------------------------------
; Title...........: _onImportMenuItem
; Description.....: Import au3 file
; Events..........: file menu item
;------------------------------------------------------------------------------
Func _onImportMenuItem()
	If $oCtrls.count > 0 Then
		Switch MsgBox($MB_ICONWARNING + $MB_YESNO, "Load Gui Definition from file", "Loading a Gui Definition will clear existing controls." & @CRLF & "Are you sure?" & @CRLF)
			Case $IDNO
				Return
		EndSwitch
	EndIf

	Local $oFileData = _importAu3File()

	If Not @error Then
		If IsObj($oFileData) Then
			_load_gui_definition('', $oFileData)
		EndIf
	Else
		Local $errCode = @error, $lineNo = @extended
		Switch $errCode
			Case 2
				MsgBox(1, "Error", "Error code: " & $errCode & @CRLF & "Error parsing parameters." & @CRLF & "Line number: " & $lineNo)

			Case 3
				MsgBox(1, "Error", "Error code: " & $errCode & @CRLF & "Cannot parse variables as parameters." & @CRLF & "Line number: " & $lineNo)

			Case Else
				MsgBox(1, "Error", "Error code: " & $errCode & @CRLF & "Error parsing AU3 file.")

		EndSwitch
	EndIf
EndFunc   ;==>_onImportMenuItem

;------------------------------------------------------------------------------
; Title...........: _importAu3File
; Description.....: Load au3 file, parse data, return object representing GUI
;------------------------------------------------------------------------------
Func _importAu3File()
	;error codes:
	;	1:	file read error
	;	2:	formatting error
	;	3:	variable used for parameter

	Local $sFileName = FileOpenDialog("Import GUI from AU3 file?", $lfld, "AutoIt Gui Definitions (*.au3)", $FD_FILEMUSTEXIST)
	If @error Then Return 1

	Local $aFileData = FileReadToArray($sFileName)
	If @error Then Return SetError(1)

	Local $sFileData = FileRead($sFileName)
	If @error Then Return SetError(1)

	Local $objOutput, $oVariables = ObjCreate("Scripting.Dictionary")
	Local $iLineCounter, $iCtrlCounter = -1, $aMatches, $aParams, $sCtrlType, $aParamMatches, $sStyles, $sScope
	Local $sParam, $iTabParentIndex, $bIsChild, $iChildCounter = -1, $sJsonString, $iTabCounter = -1, $inTab, $inGroup, $iGroupParentIndex
	Local $iBoxCommentLvl

	For $sLine In $aFileData
		$iLineCounter += 1
		$sScope = ""

		;check for box comment
		If StringRegExp($sLine, '(?im)^\s*(?:#comments-start|#cs)') Then
			$iBoxCommentLvl += 1
		ElseIf StringRegExp($sLine, '(?im)^\s*(?:#comments-end|#ce)') Then
			$iBoxCommentLvl -= 1
		EndIf

		If $iBoxCommentLvl > 0 Then
			ContinueLoop
		EndIf

		;check for line comment
		If StringRegExp($sLine, '(?im)^\s*;') Then
			ContinueLoop
		EndIf

		;check line for GUICtrlSetFont
		Local $ctrlIndex, $fontWeight, $fontName
		$aMatches = StringRegExp($sLine, '(?im)\s*(?:GUICtrlSetFont)\s*\((.+?),\s*(.+?)(?:,\s*(.+?))?(?:,\s*(?:.+?))?(?:,\s*"(.+?))?"\s*(?:,|\))', $STR_REGEXPARRAYGLOBALMATCH)
		If Not @error Then
			If $aMatches[0] = "-1" Then
				$ctrlIndex = $iCtrlCounter
			Else
				Local $sName = StringReplace($aMatches[0], "$", "")
				If $oVariables.Exists($sName) Then
					For $i = 0 To $iCtrlCounter
						If Json_Get($objOutput, ".Controls[" & $i & "].Name") = $sName Then
							$ctrlIndex = $i
							ExitLoop
						EndIf
					Next
				EndIf
			EndIf
			If UBound($aMatches) > 2 Then
				$fontWeight = $aMatches[2]
			Else
				$fontWeight = 400
			EndIf
			If UBound($aMatches) > 3 Then
				$fontName = $aMatches[3]
				ConsoleWrite($aMatches[3] & @CRLF)
			Else
				$fontName = ""
			EndIf
			Json_Put($objOutput, ".Controls[" & $ctrlIndex & "].FontSize", $aMatches[1])
			Json_Put($objOutput, ".Controls[" & $ctrlIndex & "].FontWeight", $fontWeight)
			Json_Put($objOutput, ".Controls[" & $ctrlIndex & "].FontName", $fontName)

			ContinueLoop
		EndIf


		;check line for GUICtrlSetBkColor
		$aMatches = StringRegExp($sLine, '(?im)\s*(?:GUICtrlSetBkColor)\s*\((.+?),\s*(.+?)\s*(?:,|\))', $STR_REGEXPARRAYGLOBALMATCH)
		If Not @error Then
			If $aMatches[0] = "-1" Then
				Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Background", $aMatches[1])
			Else
				Local $sName = StringReplace($aMatches[0], "$", "")
				If $oVariables.Exists($sName) Then
					For $i = 0 To $iCtrlCounter
						If Json_Get($objOutput, ".Controls[" & $i & "].Name") = $sName Then
							Json_Put($objOutput, ".Controls[" & $i & "].Background", $aMatches[1])
							ExitLoop
						EndIf
					Next
				EndIf
			EndIf
			ContinueLoop
		EndIf

		;check line for GUICtrlSetColor
		$aMatches = StringRegExp($sLine, '(?im)\s*(?:GUICtrlSetColor)\s*\((.+?),\s*(.+?)\s*(?:,|\))', $STR_REGEXPARRAYGLOBALMATCH)
		If Not @error Then
			If $aMatches[0] = "-1" Then
				Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Color", $aMatches[1])
			Else
				Local $sName = StringReplace($aMatches[0], "$", "")
				If $oVariables.Exists($sName) Then
					For $i = 0 To $iCtrlCounter
						If Json_Get($objOutput, ".Controls[" & $i & "].Name") = $sName Then
							Json_Put($objOutput, ".Controls[" & $i & "].Color", $aMatches[1])
							ExitLoop
						EndIf
					Next
				EndIf
			EndIf
			ContinueLoop
		EndIf

		;check for variable declaration
		$aMatches = StringRegExp($sLine, '(?im)^\s*(Global|Local)\s*(.+?)\s*(?:$|=)', $STR_REGEXPARRAYGLOBALMATCH)
		If Not @error Then
			Local $aVars = StringSplit(StringReplace($aMatches[1], "$", ""), ",")
			If @error Then
				$oVariables.Item(StringReplace($aMatches[1], "$", "")) = $aMatches[0]
			Else
				For $i = 1 To $aVars[0]
					$oVariables.Item(StringStripWS($aVars[$i], $STR_STRIPLEADING + $STR_STRIPTRAILING)) = $aMatches[0]
				Next
			EndIf
		EndIf

		;check line for standard gui/ctrl create format
		$aMatches = StringRegExp($sLine, '(?i)(?:\s*?(Global|Local)?\s*?(?:\$(\S*?))?\s*?=)?\s*?(\S*?)\s*?\((.*)\)', $STR_REGEXPARRAYGLOBALMATCH)
		If @error Then ContinueLoop

		;check what this line is
		If $aMatches[2] = "GUICreate" Then
			If $oVariables.Exists($aMatches[1]) Then
				$sScope = $oVariables.Item($aMatches[1])
			EndIf
			If $aMatches[0] = "Global" Or $sScope = "Global" Then
				Json_Put($objOutput, ".Main.Global", 1)
			Else
				Json_Put($objOutput, ".Main.Global", 0)
			EndIf

			Json_Put($objOutput, ".Main.Name", $aMatches[1])

			$aParamMatches = StringRegExp($aMatches[3], '(?im)(.+?)(?:$|(?:,\s*(?:BitOR\()(.*?)\)(?:,\s*(?:BitOR)\((.*?)\))?))', $STR_REGEXPARRAYGLOBALMATCH)
			If Not @error Then
				$aParams = StringSplit($aParamMatches[0], ",")
				If @error Then Return SetError(2, $iLineCounter)
				If $aParams[0] > 5 Then
					;do nothing
				Else
					If UBound($aParamMatches) > 1 Then
						$aParams[0] = $aParams[0] + 1
						ReDim $aParams[$aParams[0] + 1]
						$aParams[$aParams[0]] = $aParamMatches[1]
					EndIf
				EndIf
			Else
				$aParams = StringSplit($aMatches[3], ",")
				If @error Then Return SetError(2, $iLineCounter)
			EndIf

			Json_Put($objOutput, ".Main.Title", _removeQuotes(StringStripWS($aParams[1], $STR_STRIPLEADING + $STR_STRIPTRAILING)))

			If $aParams[0] > 1 Then
				$sParam = _FormatParameter($aParams[2])
				If @error Then Return SetError(3, $iLineCounter)
				Json_Put($objOutput, ".Main.Width", $sParam)
			EndIf
			If $aParams[0] > 2 Then
				$sParam = _FormatParameter($aParams[3])
				If @error Then Return SetError(3, $iLineCounter)
				Json_Put($objOutput, ".Main.Height", $sParam)
			EndIf
			If $aParams[0] > 3 Then
				$sParam = _FormatParameter($aParams[4])
				If @error Then Return SetError(3, $iLineCounter)
				Json_Put($objOutput, ".Main.Left", $sParam)
			EndIf
			If $aParams[0] > 4 Then
				$sParam = _FormatParameter($aParams[5])
				If @error Then Return SetError(3, $iLineCounter)
				Json_Put($objOutput, ".Main.Top", $sParam)
			EndIf
			If $aParams[0] > 5 Then
				$sParam = _FormatParameter($aParams[6])
				Json_Put($objOutput, ".Main.styleString", $sParam)
			EndIf

		ElseIf $aMatches[2] = "GUICtrlCreateTab" Then
			$iCtrlCounter += 1
			$sCtrlType = "Tab"
			$iTabParentIndex = $iCtrlCounter
			$iTabCounter = -1

			Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Type", $sCtrlType)

			If $oVariables.Exists($aMatches[1]) Then
				$sScope = $oVariables.Item($aMatches[1])
			EndIf
			If $aMatches[0] = "Global" Or $sScope = "Global" Then
				Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Global", 1)
			Else
				Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Global", 0)
			EndIf

			Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Name", $aMatches[1])

			$aParamMatches = StringRegExp($aMatches[3], '(?im)(.+?)(?:$|(?:,\s*(?:BitOR\()(.*?)\)(?:,\s*(?:BitOR)\((.*?)\))?))', $STR_REGEXPARRAYGLOBALMATCH)
			If Not @error Then
				$aParams = StringSplit($aParamMatches[0], ",")
				If @error Then Return SetError(2, $iLineCounter)
				If $aParams[0] > 4 Then
					;do nothing
				Else
					If UBound($aParamMatches) > 1 Then
						$aParams[0] = $aParams[0] + 1
						ReDim $aParams[$aParams[0] + 1]
						$aParams[$aParams[0]] = $aParamMatches[1]
					EndIf
				EndIf
			Else
				$aParams = StringSplit($aMatches[3], ",")
				If @error Then Return SetError(2, $iLineCounter)
			EndIf

			If $aParams[0] < 2 Then
				Return SetError(2, $iLineCounter)
			EndIf

			$sParam = _FormatParameter($aParams[1])
			If @error Then Return SetError(3, $iLineCounter)
			Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Left", $sParam)

			$sParam = _FormatParameter($aParams[2])
			If @error Then Return SetError(3, $iLineCounter)
			Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Top", $sParam)

			If $aParams[0] > 2 Then
				$sParam = _FormatParameter($aParams[3])
				If @error Then Return SetError(3, $iLineCounter)
				Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Width", $sParam)
			EndIf
			If $aParams[0] > 3 Then
				$sParam = _FormatParameter($aParams[4])
				If @error Then Return SetError(3, $iLineCounter)
				Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Height", $sParam)
			EndIf
			If $aParams[0] > 4 Then
				$sParam = _FormatParameter($aParams[6])
				Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].styleString", $sParam)
			EndIf
			Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Locked", False)
			Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].TabCount", 0)

		ElseIf $aMatches[2] = "GUICtrlCreateTabItem" Then
			If $iTabParentIndex > -1 Then
				If _removeQuotes($aMatches[3]) = "" Then
					$inTab = False
					ContinueLoop
				Else
;~ 					$iCtrlCounter += 1
					$inTab = True
					$iTabCounter += 1
					$iChildCounter = -1
					Json_Put($objOutput, ".Controls[" & $iTabParentIndex & "].TabCount", $iTabCounter + 1)
					Json_Put($objOutput, ".Controls[" & $iTabParentIndex & "].Tabs[" & $iTabCounter & "].Type", "TabItem")
					Json_Put($objOutput, ".Controls[" & $iTabParentIndex & "].Tabs[" & $iTabCounter & "].Name", $aMatches[1])
					Json_Put($objOutput, ".Controls[" & $iTabParentIndex & "].Tabs[" & $iTabCounter & "].Text", _removeQuotes($aMatches[3]))
				EndIf
			Else
				ContinueLoop
			EndIf

		Else
			If $aMatches[2] = "GUICtrlCreateButton" Then
				$sCtrlType = "Button"
			ElseIf $aMatches[2] = "GUICtrlCreateLabel" Then
				$sCtrlType = "Label"
			ElseIf $aMatches[2] = "GUICtrlCreateCheckbox" Then
				$sCtrlType = "Checkbox"
			ElseIf $aMatches[2] = "GUICtrlCreateRadio" Then
				$sCtrlType = "Radio"
			ElseIf $aMatches[2] = "GUICtrlCreateList" Then
				$sCtrlType = "List"
			ElseIf $aMatches[2] = "GUICtrlCreateInput" Then
				$sCtrlType = "Input"
			ElseIf $aMatches[2] = "GUICtrlCreateEdit" Then
				$sCtrlType = "Edit"
			ElseIf $aMatches[2] = "GUICtrlCreateListView" Then
				$sCtrlType = "ListView"
			ElseIf $aMatches[2] = "GUICtrlCreateDate" Then
				$sCtrlType = "Date"
			ElseIf $aMatches[2] = "GUICtrlCreateCombo" Then
				$sCtrlType = "Combo"
			ElseIf $aMatches[2] = "GUICtrlCreateGroup" Then
				$sCtrlType = "Group"
				$inGroup = True
			Else
				ContinueLoop
			EndIf

			If $iTabParentIndex > -1 And $inTab Then
				$iChildCounter += 1
				$sJsonString = ".Controls[" & $iTabParentIndex & "].Tabs[" & $iTabCounter & "].Controls[" & $iChildCounter & "]"
			Else
				If Not $inGroup Then
					$iCtrlCounter += 1
				EndIf
				$sJsonString = ".Controls[" & $iCtrlCounter & "]"
			EndIf

			If $inGroup Then
				If $sCtrlType = "Group" Then
					Local $aGroupParams = StringSplit($aMatches[3], ",")
					If @error Then Return SetError(2, $iLineCounter)
					If $aGroupParams[0] < 3 Then Return SetError(2, $iLineCounter)
					If _FormatParameter($aGroupParams[2]) = -99 And _FormatParameter($aGroupParams[3]) = -99 Then
						$inGroup = False
						ContinueLoop
					Else
						$iCtrlCounter += 1
						$iGroupParentIndex = $iCtrlCounter
						$iChildCounter = -1
						$sJsonString = ".Controls[" & $iGroupParentIndex & "]"
					EndIf
				Else
					$iChildCounter += 1
					$sJsonString = ".Controls[" & $iGroupParentIndex & "].Controls[" & $iChildCounter & "]"
				EndIf
			EndIf

			Json_Put($objOutput, $sJsonString & ".Type", $sCtrlType)

			If $oVariables.Exists($aMatches[1]) Then
				$sScope = $oVariables.Item($aMatches[1])
			EndIf
			If $aMatches[0] = "Global" Or $sScope = "Global" Then
				Json_Put($objOutput, $sJsonString & ".Global", 1)
			Else
				Json_Put($objOutput, $sJsonString & ".Global", 0)
			EndIf

			Json_Put($objOutput, $sJsonString & ".Name", $aMatches[1])

			$aParamMatches = StringRegExp($aMatches[3], '(?im)(.+?)(?:$|(?:,\s*(?:BitOR\()(.*?)\)(?:,\s*(?:BitOR)\((.*?)\))?))', $STR_REGEXPARRAYGLOBALMATCH)
			If Not @error Then
				$aParams = StringSplit($aParamMatches[0], ",")
				If @error Then Return SetError(2, $iLineCounter)
				If $aParams[0] > 5 Then
					;do nothing
				Else
					If UBound($aParamMatches) > 1 Then
						$aParams[0] = $aParams[0] + 1
						ReDim $aParams[$aParams[0] + 1]
						$aParams[$aParams[0]] = $aParamMatches[1]
					EndIf
				EndIf
			Else
				$aParams = StringSplit($aMatches[3], ",")
				If @error Then Return SetError(2, $iLineCounter)
			EndIf

			Json_Put($objOutput, $sJsonString & ".Text", _removeQuotes(StringStripWS($aParams[1], $STR_STRIPLEADING + $STR_STRIPTRAILING)))

			If $aParams[0] < 3 Then
				Return SetError(2, $iLineCounter)
			EndIf

			If $aParams[0] > 1 Then
				$sParam = _FormatParameter($aParams[2])
				If @error Then Return SetError(3, $iLineCounter)
				Json_Put($objOutput, $sJsonString & ".Left", $sParam)
			EndIf
			If $aParams[0] > 2 Then
				$sParam = _FormatParameter($aParams[3])
				If @error Then Return SetError(3, $iLineCounter)
				Json_Put($objOutput, $sJsonString & ".Top", $sParam)
			EndIf
			If $aParams[0] > 3 Then
				$sParam = _FormatParameter($aParams[4])
				If @error Then Return SetError(3, $iLineCounter)
				Json_Put($objOutput, $sJsonString & ".Width", $sParam)
			EndIf
			If $aParams[0] > 4 Then
				$sParam = _FormatParameter($aParams[5])
				If @error Then Return SetError(3, $iLineCounter)
				Json_Put($objOutput, $sJsonString & ".Height", $sParam)
			EndIf
			If $aParams[0] > 5 Then
				$sParam = _FormatParameter($aParams[6])
				Json_Put($objOutput, $sJsonString & ".styleString", $sParam)
			EndIf
			Json_Put($objOutput, $sJsonString & ".Locked", False)

		EndIf

	Next
	Json_Put($objOutput, ".Main.numctrls", $iCtrlCounter + 1)

;~ 	ConsoleWrite(Json_Encode($objOutput, $Json_PRETTY_PRINT) & @CRLF)

	Return $objOutput
EndFunc   ;==>_importAu3File

Func _FormatParameter($sParam)
	$sParam = StringStripWS($sParam, $STR_STRIPLEADING + $STR_STRIPTRAILING)
	If ($sParam = "0") Or (Number($sParam) <> 0) Then
		Return $sParam
	Else
		Return SetError(1, 0, $sParam)
	EndIf
EndFunc   ;==>_FormatParameter

Func _removeQuotes($sParam)
	Local $sRet = StringRegExpReplace($sParam, '["' & "'" & ']', "")
	If @error Then Return $sParam
	Return $sRet
EndFunc   ;==>_removeQuotes
