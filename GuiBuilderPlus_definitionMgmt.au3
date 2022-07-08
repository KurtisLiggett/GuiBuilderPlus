; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_definitionMgmt.au3
; Description ...: Save and load GUI definition files
; ===============================================================================================================================


Func _onSaveGui()
	_save_gui_definition()
EndFunc

Func _onSaveAsGui()
	_save_gui_definition(True)
EndFunc

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
			Return
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
		Return
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

	$i = 0
	For $oCtrl In $oCtrls.ctrls.Items()
		If $oCtrl.Type = "TabItem" Then ContinueLoop
		If $oCtrl.TabParent <> 0 Then ContinueLoop

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
		Json_Put($objOutput, ".Controls[" & $i & "].Locked", $oCtrl.Global)
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

		If $oCtrl.Type = "Tab" Then
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
						Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Controls[" & $k & "].Locked", $oTabCtrl.Global)
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
						$k += 1
					Next

					$j += 1
				Next
			EndIf
		EndIf

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
Func _load_gui_definition($AgdInfile = '')
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

	_SendMessage($hGUI, $WM_SETREDRAW, False)

	;only wipe if GUI exists already
	If Not $firstLoad Or Not $CmdLine[0] Then
		_wipe_current_gui()
	EndIf
	If $firstLoad Then $firstLoad = False

	Local $sData = FileRead($AgdInfile)

	If StringLeft($sData, 1) = "[" Then
		_load_gui_definition_ini($AgdInfile)
		_SendMessage($hGUI, $WM_SETREDRAW, True)
		_WinAPI_RedrawWindow($hGUI)
		Return
	EndIf

	Local $objInput = Json_Decode($sData)

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

		If _setting_show_grid() Then
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

	$oProperties_Main.Title.value = $oMain.Title
	$oProperties_Main.Name.value = $oMain.Name
	$oProperties_Main.Left.value = $oMain.Left
	$oProperties_Main.Top.value = $oMain.Top
	$oProperties_Main.Width.value = $oMain.Width
	$oProperties_Main.Height.value = $oMain.Height

	Local Const $numCtrls = _Json_Get($objInput, ".Main.numctrls", -1)


	Local $oCtrl, $Key, $oNewCtrl
	Local $aControls = Json_Get($objInput, ".Controls")
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
		$oCtrl.Global = (_Json_Get($oThisCtrl, ".Global", False) = "True") ? True : False
		$oCtrl.Global = (_Json_Get($oThisCtrl, ".Locked", False) = "True") ? True : False
		$oCtrl.Color = _Json_Get($oThisCtrl, ".Color", -1)
		If $oCtrl.Color <> -1 Then
			$oCtrl.Color = Dec(StringReplace($oCtrl.Color, "0x", ""))
		EndIf
		$oCtrl.Background = _Json_Get($oThisCtrl, ".Background", -1)
		If $oCtrl.Background <> -1 Then
			$oCtrl.Background = Dec(StringReplace($oCtrl.Background, "0x", ""))
		EndIf

		$oNewCtrl = _create_ctrl($oCtrl, True)


		$oCtrl = $oCtrls.get($oNewCtrl.Hwnd)
		Local $j
		If $oCtrl.Type = "Tab" Then
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
					For $oTabCtrl in $aTabCtrls
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
						$oCtrl2.Global = (_Json_Get($oTabCtrl, ".Global", False) = "True") ? True : False
						$oCtrl2.Global = (_Json_Get($oTabCtrl, ".Locked", False) = "True") ? True : False
						$oCtrl2.Color = _Json_Get($oTabCtrl, ".Color", -1)
						If $oCtrl2.Color <> -1 Then
							$oCtrl2.Color = Dec(StringReplace($oCtrl2.Color, "0x", ""))
						EndIf
						$oCtrl2.Background = _Json_Get($oTabCtrl, ".Background", -1)
						If $oCtrl2.Background <> -1 Then
							$oCtrl2.Background = Dec(StringReplace($oCtrl2.Background, "0x", ""))
						EndIf

						$oNewCtrl = _create_ctrl($oCtrl2, True, -1, -1, $oCtrl.Hwnd)
					Next
					GUICtrlCreateTabItem('')
					GUISwitch($hGUI)

					$j += 1
				Next
			EndIf
		EndIf

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
EndFunc




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

		If _setting_show_grid() Then
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
		$oCtrl.Global = (IniRead($AgdInfile, $Key, "Global", False) = "True") ? True : False
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
EndFunc   ;==>_load_gui_definition