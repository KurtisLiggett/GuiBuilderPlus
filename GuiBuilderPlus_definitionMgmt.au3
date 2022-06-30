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

	IniWrite($AgdOutFile, "Main", "Left", $oMain.Left)
	IniWrite($AgdOutFile, "Main", "Top", $oMain.Top)
	IniWrite($AgdOutFile, "Main", "Width", $oMain.Width)
	IniWrite($AgdOutFile, "Main", "Height", $mainHeight)
	IniWrite($AgdOutFile, "Main", "Name", $oMain.Name)
	IniWrite($AgdOutFile, "Main", "Title", $oMain.Title)
	IniWrite($AgdOutFile, "Main", "Background", $oMain.Background)

	Local Const $ctrl_count = $oCtrls.count

	IniWrite($AgdOutFile, "Main", "numctrls", $ctrl_count)

	$i = 1
	For $oCtrl In $oCtrls.ctrls.Items()
		Local $Key = "Control_" & $i

		Local $handle = $oCtrl.Hwnd

		IniWrite($AgdOutFile, $Key, "Type", $oCtrl.Type)
		IniWrite($AgdOutFile, $Key, "Name", $oCtrl.Name)
		IniWrite($AgdOutFile, $Key, "Text", $oCtrl.Text)
		IniWrite($AgdOutFile, $Key, "Visible", $oCtrl.Visible)
		IniWrite($AgdOutFile, $Key, "OnTop", $oCtrl.OnTop)
		IniWrite($AgdOutFile, $Key, "DropAccepted", $oCtrl.DropAccepted)
		IniWrite($AgdOutFile, $Key, "Left", $oCtrl.Left)
		IniWrite($AgdOutFile, $Key, "Top", $oCtrl.Top)
		IniWrite($AgdOutFile, $Key, "Width", $oCtrl.Width)
		IniWrite($AgdOutFile, $Key, "Height", $oCtrl.Height)
		IniWrite($AgdOutFile, $Key, "Global", $oCtrl.Global)
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

		If $oCtrl.Type = "Menu" Then
			IniWrite($AgdOutFile, $Key, "MenuItemCount", $oCtrl.Menuitems.count)

			Local $menuCount = $oCtrl.Menuitems.count

			If $menuCount > 0 Then
				Local $j = 1
				For $oMenuItem In $oCtrl.MenuItems
					IniWrite($AgdOutFile, $Key, "MenuItem" & $j & "_Name", $oMenuItem.Name)
					IniWrite($AgdOutFile, $Key, "MenuItem" & $j & "_Text", $oMenuItem.Text)
					$j += 1
				Next
			EndIf
		EndIf
		$i += 1
	Next

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

					$oCtrl.Tabs.at($j - 1).Name = IniRead($AgdInfile, $Key, "TabItem" & $j & "_Name", "tempName")
					$oCtrl.Tabs.at($j - 1).Text = IniRead($AgdInfile, $Key, "TabItem" & $j & "_Text", "tempText")
					_GUICtrlTab_SetItemText($oCtrl.Hwnd, $j - 1, $oCtrl.Tabs.at($j - 1).Text)
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
