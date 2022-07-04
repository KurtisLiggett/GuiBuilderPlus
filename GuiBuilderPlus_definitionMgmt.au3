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
	Local $objOutput

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

		Local $gdtitle = _get_script_title()
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

			Local $tabCount = $oCtrl.TabCount
			Local $tabs = $oCtrl.Tabs
			Local $tab

			If $oCtrl.TabCount > 0 Then
				Local $j = 0
				For $oTab In $oCtrl.Tabs
					Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Name", $oTab.Name)
					Json_Put($objOutput, ".Controls[" & $i & "].Tabs[" & $j & "].Text", $oTab.Text)
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

	;only wipe if GUI exists already
	If Not $firstLoad Or Not $CmdLine[0] Then
		_wipe_current_gui()
	EndIf
	If $firstLoad Then $firstLoad = False

	Local $sData = FileRead($AgdInfile)
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


	Local $oCtrl, $Key
	Local $aControls = Json_Get($objInput, ".Controls")
	For $oThisCtrl In $aControls
;~ 		$Key = "Control_" & $i
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
		$oCtrl.Color = _Json_Get($oThisCtrl, ".Color", -1)
		If $oCtrl.Color <> -1 Then
			$oCtrl.Color = Dec(StringReplace($oCtrl.Color, "0x", ""))
		EndIf
		$oCtrl.Background = _Json_Get($oThisCtrl, ".Background", -1)
		If $oCtrl.Background <> -1 Then
			$oCtrl.Background = Dec(StringReplace($oCtrl.Background, "0x", ""))
		EndIf

		Local $oNewCtrl = _create_ctrl($oCtrl, True)


		$oCtrl = $oCtrls.get($oNewCtrl.Hwnd)
		Local $j
		If $oCtrl.Type = "Tab" Then
			Local $tabCount = _Json_Get($oThisCtrl, ".TabCount", 0)

			If $tabCount > 0 Then
				Local $aTabs = Json_Get($oThisCtrl, ".Tabs")

				$j = 1
				For $oThisTab In $aTabs
					_new_tab()

					$oCtrl.Tabs.at($j - 1).Name = _Json_Get($oThisTab, ".Name", "tempName")
					$oCtrl.Tabs.at($j - 1).Text = _Json_Get($oThisTab, ".Text", "tempText")
					_GUICtrlTab_SetItemText($oCtrl.Hwnd, $j - 1, $oCtrl.Tabs.at($j - 1).Text)
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
					_new_menuItemCreate($oCtrl)

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
