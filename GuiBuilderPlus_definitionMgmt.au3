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


Func _json_open(ByRef $sJsonStr, $newItem, $tabs = 1, $type = "{")
	If $sJsonStr <> "" And StringRight($sJsonStr, 1) <> "{" And StringRight($sJsonStr, 1) <> "[" Then
		$sJsonStr &= ','
	EndIf
	If $sJsonStr <> "" Then
		$sJsonStr &= @CRLF
	EndIf
	For $i = 0 To $tabs - 1
		$sJsonStr &= @TAB
	Next
	If $newItem = "" Then
		$sJsonStr &= $type
	Else
		$sJsonStr &= '"' & $newItem & '": ' & $type
	EndIf
EndFunc   ;==>_json_open

Func _json_close(ByRef $sJsonStr, $tabs = 1, $type = "}")
	$sJsonStr &= @CRLF
	For $i = 0 To $tabs - 1
		$sJsonStr &= @TAB
	Next
	$sJsonStr &= $type
EndFunc   ;==>_json_close

Func _json_add(ByRef $sJsonStr, $newItem, $newValue, $tabs = 1)
	If StringRight($sJsonStr, 1) <> "{" Then
		$sJsonStr &= ','
	EndIf
	$sJsonStr &= @CRLF
	For $i = 0 To $tabs - 1
		$sJsonStr &= @TAB
	Next
	If IsString($newValue) Then
		;replace special chars
		$newValue = StringReplace($newValue, @CRLF, "\r\n")
		$newValue = StringReplace($newValue, '"', '\"')
		;add quotes to strings
		$newValue = '"' & $newValue & '"'
	ElseIf IsBool($newValue) Then
		$newValue = StringLower($newValue)
	EndIf
	$sJsonStr &= '"' & $newItem & '": ' & $newValue
EndFunc   ;==>_json_add

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

			_addToRecentFiles($AgdOutFile)
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

	Local $sJsonString = ""
	_json_open($sJsonString, "", 0, "{")
	_json_open($sJsonString, "Main", 1)
	_json_add($sJsonString, "Left", $oMain.Left, 2)
	_json_add($sJsonString, "Top", $oMain.Top, 2)
	_json_add($sJsonString, "Width", $oMain.Width, 2)
	_json_add($sJsonString, "Height", $mainHeight, 2)
	_json_add($sJsonString, "Name", $oMain.Name, 2)
	_json_add($sJsonString, "Title", $oMain.Title, 2)
	_json_add($sJsonString, "Background", $oMain.Background, 2)
	_json_add($sJsonString, "numctrls", $ctrl_count, 2)
	_json_add($sJsonString, "styleString", $oMain.styleString, 2)
	_json_close($sJsonString, 1, "}")

	$i = 0
	Local $CtrlItems = $oCtrls.ctrls.Items()
	_json_open($sJsonString, "Controls", 1, "[")
	For $oCtrl In $CtrlItems
		If $oCtrl.Type = "TabItem" Then ContinueLoop
		If $oCtrl.CtrlParent <> 0 Then ContinueLoop

		_json_open($sJsonString, "", 2, "{")

		Local $handle = $oCtrl.Hwnd

		_json_add($sJsonString, "Type", $oCtrl.Type, 3)
		_json_add($sJsonString, "Name", $oCtrl.Name, 3)
		_json_add($sJsonString, "Text", $oCtrl.Text, 3)
		_json_add($sJsonString, "Visible", $oCtrl.Visible, 3)
		_json_add($sJsonString, "OnTop", $oCtrl.OnTop, 3)
		_json_add($sJsonString, "DropAccepted", $oCtrl.DropAccepted, 3)
		_json_add($sJsonString, "Left", $oCtrl.Left, 3)
		_json_add($sJsonString, "Top", $oCtrl.Top, 3)
		_json_add($sJsonString, "Width", $oCtrl.Width, 3)
		_json_add($sJsonString, "Height", $oCtrl.Height, 3)
		_json_add($sJsonString, "Autosize", $oCtrl.Autosize, 3)
		_json_add($sJsonString, "Global", $oCtrl.Global, 3)
		_json_add($sJsonString, "Locked", $oCtrl.Locked, 3)
		_json_add($sJsonString, "styleString", $oCtrl.styleString, 3)
		_json_add($sJsonString, "FontSize", $oCtrl.FontSize, 3)
		_json_add($sJsonString, "FontWeight", $oCtrl.FontWeight, 3)
		_json_add($sJsonString, "FontName", $oCtrl.FontName, 3)
		_json_add($sJsonString, "Color", $oCtrl.Color, 3)
		_json_add($sJsonString, "Background", $oCtrl.Background, 3)
		_json_add($sJsonString, "BorderColor", $oCtrl.BorderColor, 3)
		_json_add($sJsonString, "BorderSize", $oCtrl.BorderSize, 3)
		_json_add($sJsonString, "CodeString", $oCtrl.CodeString, 3)
		If $oCtrl.Type = "Line" Then
			_json_open($sJsonString, "Coords", 3, "{")
			_json_add($sJsonString, "Coord1_X", $oCtrl.Coord1[0], 4)
			_json_add($sJsonString, "Coord1_Y", $oCtrl.Coord1[1], 4)
			_json_add($sJsonString, "Coord2_X", $oCtrl.Coord2[0], 4)
			_json_add($sJsonString, "Coord2_Y", $oCtrl.Coord2[1], 4)
			_json_close($sJsonString, 3, "}")
		EndIf
		_json_add($sJsonString, "Items", $oCtrl.Items, 3)
		_json_add($sJsonString, "Img", $oCtrl.Img, 3)

		Switch $oCtrl.Type
			Case "Tab"
				_json_add($sJsonString, "TabCount", $oCtrl.TabCount, 3)
				_json_open($sJsonString, "Tabs", 3, "[")

				If $oCtrl.TabCount > 0 Then
					Local $oTab
					For $hTab In $oCtrl.Tabs
						_json_open($sJsonString, "", 4, "{")
						$oTab = $oCtrls.get($hTab)
						_json_add($sJsonString, "Type", $oTab.Type, 5)
						_json_add($sJsonString, "Name", $oTab.Name, 5)
						_json_add($sJsonString, "Text", $oTab.Text, 5)

						_json_open($sJsonString, "Controls", 5, "[")
						For $oTabCtrl In $oTab.ctrls.Items()
							_json_open($sJsonString, "", 6, "{")

							_json_add($sJsonString, "Type", $oTabCtrl.Type, 7)
							_json_add($sJsonString, "Name", $oTabCtrl.Name, 7)
							_json_add($sJsonString, "Text", $oTabCtrl.Text, 7)
							_json_add($sJsonString, "Visible", $oTabCtrl.Visible, 7)
							_json_add($sJsonString, "OnTop", $oTabCtrl.OnTop, 7)
							_json_add($sJsonString, "DropAccepted", $oTabCtrl.DropAccepted, 7)
							_json_add($sJsonString, "Left", $oTabCtrl.Left, 7)
							_json_add($sJsonString, "Top", $oTabCtrl.Top, 7)
							_json_add($sJsonString, "Width", $oTabCtrl.Width, 7)
							_json_add($sJsonString, "Height", $oTabCtrl.Height, 7)
							_json_add($sJsonString, "Autosize", $oTabCtrl.Autosize, 7)
							_json_add($sJsonString, "Global", $oTabCtrl.Global, 7)
							_json_add($sJsonString, "Locked", $oTabCtrl.Locked, 7)
							_json_add($sJsonString, "styleString", $oTabCtrl.styleString, 7)
							_json_add($sJsonString, "FontSize", $oTabCtrl.FontSize, 7)
							_json_add($sJsonString, "FontWeight", $oTabCtrl.FontWeight, 7)
							_json_add($sJsonString, "FontName", $oTabCtrl.FontName, 7)
							_json_add($sJsonString, "Color", $oTabCtrl.Color, 7)
							_json_add($sJsonString, "Background", $oTabCtrl.Background, 7)
							_json_add($sJsonString, "BorderColor", $oTabCtrl.BorderColor, 7)
							_json_add($sJsonString, "BorderSize", $oTabCtrl.BorderSize, 7)
							_json_add($sJsonString, "CodeString", $oTabCtrl.CodeString, 7)
							If $oTabCtrl.Type = "Line" Then
								_json_open($sJsonString, "Coords", 7, "{")
								_json_add($sJsonString, "Coord1_X", $oTabCtrl.Coord1[0], 8)
								_json_add($sJsonString, "Coord1_Y", $oTabCtrl.Coord1[1], 8)
								_json_add($sJsonString, "Coord2_X", $oTabCtrl.Coord2[0], 8)
								_json_add($sJsonString, "Coord2_Y", $oTabCtrl.Coord2[1], 8)
								_json_close($sJsonString, 7, "}")
							EndIf
							_json_add($sJsonString, "Items", $oTabCtrl.Items, 7)
							_json_add($sJsonString, "Img", $oTabCtrl.Img, 7)

							_json_close($sJsonString, 6, "}")
						Next
						_json_close($sJsonString, 5, "]")

						_json_close($sJsonString, 4, "}")
					Next

				EndIf
				_json_close($sJsonString, 3, "]")

			Case "Group"
				If $oCtrl.ctrls.Count > 0 Then
					_json_open($sJsonString, "Controls", 3, "[")
					For $oThisCtrl In $oCtrl.ctrls.Items()
						_json_open($sJsonString, "", 4, "{")

						_json_add($sJsonString, "Type", $oThisCtrl.Type, 5)
						_json_add($sJsonString, "Name", $oThisCtrl.Name, 5)
						_json_add($sJsonString, "Text", $oThisCtrl.Text, 5)
						_json_add($sJsonString, "Visible", $oThisCtrl.Visible, 5)
						_json_add($sJsonString, "OnTop", $oThisCtrl.OnTop, 5)
						_json_add($sJsonString, "DropAccepted", $oThisCtrl.DropAccepted, 5)
						_json_add($sJsonString, "Left", $oThisCtrl.Left, 5)
						_json_add($sJsonString, "Top", $oThisCtrl.Top, 5)
						_json_add($sJsonString, "Width", $oThisCtrl.Width, 5)
						_json_add($sJsonString, "Height", $oThisCtrl.Height, 5)
						_json_add($sJsonString, "Autosize", $oThisCtrl.Autosize, 5)
						_json_add($sJsonString, "Global", $oThisCtrl.Global, 5)
						_json_add($sJsonString, "Locked", $oThisCtrl.Locked, 5)
						_json_add($sJsonString, "styleString", $oThisCtrl.styleString, 5)
						_json_add($sJsonString, "FontSize", $oThisCtrl.FontSize, 5)
						_json_add($sJsonString, "FontWeight", $oThisCtrl.FontWeight, 5)
						_json_add($sJsonString, "FontName", $oThisCtrl.FontName, 5)
						_json_add($sJsonString, "Color", $oThisCtrl.Color, 5)
						_json_add($sJsonString, "Background", $oThisCtrl.Background, 5)
						_json_add($sJsonString, "BorderColor", $oThisCtrl.BorderColor, 5)
						_json_add($sJsonString, "BorderSize", $oThisCtrl.BorderSize, 5)
						_json_add($sJsonString, "CodeString", $oThisCtrl.CodeString, 5)
						If $oThisCtrl.Type = "Line" Then
							_json_open($sJsonString, "Coords", 5, "{")
							_json_add($sJsonString, "Coord1_X", $oThisCtrl.Coord1[0], 6)
							_json_add($sJsonString, "Coord1_Y", $oThisCtrl.Coord1[1], 6)
							_json_add($sJsonString, "Coord2_X", $oThisCtrl.Coord2[0], 6)
							_json_add($sJsonString, "Coord2_Y", $oThisCtrl.Coord2[1], 6)
							_json_close($sJsonString, 5, "}")
						EndIf
						_json_add($sJsonString, "Items", $oThisCtrl.Items, 5)
						_json_add($sJsonString, "Img", $oThisCtrl.Img, 5)

						_json_close($sJsonString, 4, "}")
					Next
					_json_close($sJsonString, 3, "]")
				EndIf
		EndSwitch

		If $oCtrl.Type = "Menu" Then
			_json_add($sJsonString, "MenuItemCount", $oCtrl.Menuitems.count, 3)
			Local $menuCount = $oCtrl.Menuitems.count
			If $menuCount > 0 Then
				_json_open($sJsonString, "MenuItems", 3, "[")
				For $oMenuItem In $oCtrl.MenuItems
					_json_open($sJsonString, "", 4, "{")
					_json_add($sJsonString, "Name", $oMenuItem.Name, 5)
					_json_add($sJsonString, "Text", $oMenuItem.Text, 5)
					_json_add($sJsonString, "Global", $oMenuItem.Global, 5)
					_json_close($sJsonString, 4, "}")
				Next
				_json_close($sJsonString, 3, "]")
			EndIf
		EndIf

		_json_close($sJsonString, 2, "}")
	Next
	_json_close($sJsonString, 1, "]")
	_json_close($sJsonString, 0, "}")

	Local $hFile = FileOpen($AgdOutFile, $FO_OVERWRITE)
	FileWrite($hFile, $sJsonString)
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
; Modified by.....: kurtykurtyboy
;------------------------------------------------------------------------------
Func _load_gui_definition($AgdInfile = '', $oImportData = -1)
	Static $firstLoad = True
	Local $objInput

	If Not IsMap($oImportData) Then
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
			Case Else
				If Not FileExists($AgdInfile) Then
					MsgBox($MB_ICONERROR, "File Error", "Error loading the GUI definition file." & @CRLF & "File not found." & @CRLF)
					Return
				EndIf
		EndSwitch

		$AgdOutFile = $AgdInfile
		_addToRecentFiles($AgdInfile)

;~ 		_SendMessage($hGUI, $WM_SETREDRAW, False)

		Local $sData = FileRead($AgdInfile)

		If StringLeft($sData, 1) = "[" Then
			_load_gui_definition_ini($AgdInfile)
;~ 			_SendMessage($hGUI, $WM_SETREDRAW, True)
;~ 			_WinAPI_RedrawWindow($hGUI)
			_addToRecentFiles($AgdInfile)
			Return
		EndIf

		$objInput = _JSON_Parse($sData)
	Else
		$objInput = $oImportData
	EndIf

	;only wipe if GUI exists already
	If Not $firstLoad Or Not $CmdLine[0] Then
		_wipe_current_gui()
		_SendMessage($hGUI, $WM_SETREDRAW, False)
	EndIf
	If $firstLoad Then $firstLoad = False


	ConsoleWrite("Start Load" & @CRLF)
	Local $ttimer = TimerInit()

	Local $oJsonMain = _Json_Get($objInput, ".Main")
	$oMain.Name = _json_getValue($oJsonMain, "Name", "hGUI")
	$oMain.Title = _json_getValue($oJsonMain, "Title", StringTrimRight(StringTrimLeft(_get_script_title(), 1), 1))
	$oMain.Left = _json_getValue($oJsonMain, "Left", -1)
	$oMain.Top = _json_getValue($oJsonMain, "Top", -1)
	$oMain.Width = _json_getValue($oJsonMain, "Width", 400)
	$oMain.Height = _json_getValue($oJsonMain, "Height", 350)
	$oMain.styleString = _json_getValue($oJsonMain, "styleString", "")
	$oMain.Background = _json_getValue($oJsonMain, "Background", "")
	Local $numCtrls = _json_getValue($oJsonMain, "numctrls", 0)

	If $oMain.Background <> "" Then
		GUISetBkColor($oMain.Background, $hGUI)
	Else
		GUISetBkColor($defaultGuiBkColor, $hGUI)
	EndIf



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

;~ 		Local $aGuiPos = WinGetPos($hGUI)
;~ 		GUIDelete($hGUI)
;~ 		$hGUI = GUICreate($oMain.Title & " - Form (" & $oMain.Width & ", " & $oMain.Height & ")", $oMain.Width, $oMain.Height, $aGuiPos[0], $aGuiPos[1], BitOR($WS_SIZEBOX, $WS_CAPTION), BitOR($WS_EX_ACCEPTFILES, $WS_EX_COMPOSITED), $hFormHolder)
;~ 		If Not @Compiled Then
;~ 			GUISetIcon(@ScriptDir & '\resources\icons\icon.ico')
;~ 		EndIf

;~ 		;GUI events
;~ 		GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitForm", $hGUI)
;~ 		GUISetOnEvent($GUI_EVENT_RESIZED, "_onResize", $hGUI)
;~ 		GUISetOnEvent($GUI_EVENT_PRIMARYDOWN, "_onMousePrimaryDown", $hGUI)
;~ 		GUISetOnEvent($GUI_EVENT_PRIMARYUP, "_onMousePrimaryUp", $hGUI)
;~ 		GUISetOnEvent($GUI_EVENT_SECONDARYDOWN, "_onMouseSecondaryDown", $hGUI)
;~ 		GUISetOnEvent($GUI_EVENT_SECONDARYUP, "_onMouseSecondaryUp", $hGUI)
;~ 		GUISetOnEvent($GUI_EVENT_MOUSEMOVE, "_onMouseMove", $hGUI)

;~ 		_set_accelerators()

		If $oOptions.showGrid Then
			_display_grid($background, $oMain.Width, $oMain.Height)
		EndIf
	EndIf


	;update properties inspector
	$oProperties_Main.properties.Background.value = $oMain.Background
	$oProperties_Main.properties.Title.value = $oMain.Title
	$oProperties_Main.properties.Name.value = $oMain.Name
	$oProperties_Main.properties.Left.value = $oMain.Left
	$oProperties_Main.properties.Top.value = $oMain.Top
	$oProperties_Main.properties.Width.value = $oMain.Width
	$oProperties_Main.properties.Height.value = $oMain.Height


	Local $oCtrl, $Key, $oNewCtrl
	Local $aControls = _Json_Get($objInput, ".Controls")
	If @error Then
		ConsoleWrite("No controls found" & @CRLF)
	EndIf

	;get the controls
	If IsArray($aControls) Then
		For $oThisCtrl In $aControls
			;create new temporary control
			$oCtrl = $oCtrls.createNew()

			;get properties
			$oCtrl.HwndCount = 1
			$oCtrl.Type = _json_getValue($oThisCtrl, "Type", "")
			$oCtrl.Name = _json_getValue($oThisCtrl, "Name", "")
			$oCtrl.Text = _json_getValue($oThisCtrl, "Text", "")
			$oCtrl.Visible = _json_getValue($oThisCtrl, "Visible", True)
			$oCtrl.OnTop = _json_getValue($oThisCtrl, "OnTop", False)
			$oCtrl.Left = _json_getValue($oThisCtrl, "Left", -1)
			$oCtrl.Top = _json_getValue($oThisCtrl, "Top", -1)
			$oCtrl.Width = _json_getValue($oThisCtrl, "Width", 1)
			$oCtrl.Height = _json_getValue($oThisCtrl, "Height", 1)
			$oCtrl.Autosize = _json_getValue($oThisCtrl, "Autosize", $GUI_UNCHECKED)
			$oCtrl.Global = _json_getValue($oThisCtrl, "Global", 1)
			$oCtrl.Locked = _json_getValue($oThisCtrl, "Locked", False)
			$oCtrl.styleString = _json_getValue($oThisCtrl, "styleString", "")
			$oCtrl.Color = _json_getValue($oThisCtrl, "Color", "")
			$oCtrl.Background = _json_getValue($oThisCtrl, "Background", "")
			$oCtrl.FontSize = _json_getValue($oThisCtrl, "FontSize", 8.5)
			$oCtrl.FontWeight = _json_getValue($oThisCtrl, "FontWeight", 400)
			$oCtrl.FontName = _json_getValue($oThisCtrl, "FontName", "")
			$oCtrl.BorderColor = _json_getValue($oThisCtrl, "BorderColor", "0x000000")
			$oCtrl.BorderSize = _json_getValue($oThisCtrl, "BorderSize", 1)
			$oCtrl.CodeString = _json_getValue($oThisCtrl, "CodeString", "")
			$oCtrl.Items = _json_getValue($oThisCtrl, "Items", "")
			$oCtrl.Img = _json_getValue($oThisCtrl, "Img", "")

			Local $aCoords[2]
			$aCoords[0] = _json_getValue($oThisCtrl.Coords, "Coord1_X", "")
			$aCoords[1] = _json_getValue($oThisCtrl.Coords, "Coord1_Y", "")
			If $aCoords[0] = "" Then $aCoords[0] = 0
			If $aCoords[1] = "" Then $aCoords[1] = 0
			$oCtrl.Coord1 = $aCoords
			$aCoords[0] = _json_getValue($oThisCtrl.Coords, "Coord2_X", "")
			$aCoords[1] = _json_getValue($oThisCtrl.Coords, "Coord2_Y", "")
			If $aCoords[0] = "" Then $aCoords[0] = 0
			If $aCoords[1] = "" Then $aCoords[1] = 0
			$oCtrl.Coord2 = $aCoords

			;create the permanent control based on properties
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

			;get tab items
			Local $j, $oCtrl2
			Switch $oCtrl.Type
				Case "Tab"
					Local $tabCount = $oThisCtrl.TabCount

					If $tabCount > 0 Then
						Local $aTabs = $oThisCtrl.Tabs
						If Not IsArray($aTabs) Then ContinueLoop

						$j = 1
						Local $oTab
						For $oThisTab In $aTabs
							_new_tab(True)

							$oTab = $oCtrls.getLast()
							$oTab.Name = $oThisTab.Name
							$oTab.Text = $oThisTab.Text
							_GUICtrlTab_SetItemText($oCtrl.Hwnd, $j - 1, $oTab.Text)

							;get controls inside tab item
							Local $aTabCtrls = $oThisTab.Controls
							If Not IsArray($aTabCtrls) Then ContinueLoop
							GUISwitch($hGUI, $oTab.Hwnd)
							For $oTabCtrl In $aTabCtrls
								$oCtrl2 = $oCtrls.createNew()

								;get properties
								$oCtrl2.HwndCount = 1
								$oCtrl2.Type = _json_getValue($oTabCtrl, "Type", "")
								$oCtrl2.Name = _json_getValue($oTabCtrl, "Name", "")
								$oCtrl2.Text = _json_getValue($oTabCtrl, "Text", "")
								$oCtrl2.Visible = _json_getValue($oTabCtrl, "Visible", True)
								$oCtrl2.OnTop = _json_getValue($oTabCtrl, "OnTop", False)
								$oCtrl2.Left = _json_getValue($oTabCtrl, "Left", -1)
								$oCtrl2.Top = _json_getValue($oTabCtrl, "Top", -1)
								$oCtrl2.Width = _json_getValue($oTabCtrl, "Width", 1)
								$oCtrl2.Height = _json_getValue($oTabCtrl, "Height", 1)
								$oCtrl2.Autosize = _json_getValue($oTabCtrl, "Autosize", $GUI_UNCHECKED)
								$oCtrl2.Global = _json_getValue($oTabCtrl, "Global", 1)
								$oCtrl2.Locked = _json_getValue($oTabCtrl, "Locked", False)
								$oCtrl2.styleString = _json_getValue($oTabCtrl, "styleString", "")
								$oCtrl2.Color = _json_getValue($oTabCtrl, "Color", "")
								$oCtrl2.Background = _json_getValue($oTabCtrl, "Background", "")
								$oCtrl2.FontSize = _json_getValue($oTabCtrl, "FontSize", 8.5)
								$oCtrl2.FontWeight = _json_getValue($oTabCtrl, "FontWeight", 400)
								$oCtrl2.FontName = _json_getValue($oTabCtrl, "FontName", "")
								$oCtrl2.BorderColor = _json_getValue($oTabCtrl, "BorderColor", "0x000000")
								$oCtrl2.BorderSize = _json_getValue($oTabCtrl, "BorderSize", 1)
								$oCtrl2.CodeString = _json_getValue($oTabCtrl, "CodeString", "")
								$oCtrl2.Items = _json_getValue($oTabCtrl, "Items", "")
								$oCtrl2.Img = _json_getValue($oTabCtrl, "Img", "")

								Local $aCoords[2]
								$aCoords[0] = _json_getValue($oTabCtrl.Coords, "Coord1_X", "")
								$aCoords[1] = _json_getValue($oTabCtrl.Coords, "Coord1_Y", "")
								If $aCoords[0] = "" Then $aCoords[0] = 0
								If $aCoords[1] = "" Then $aCoords[1] = 0
								$oCtrl2.Coord1 = $aCoords
								$aCoords[0] = _json_getValue($oTabCtrl.Coords, "Coord2_X", "")
								$aCoords[1] = _json_getValue($oTabCtrl.Coords, "Coord2_Y", "")
								If $aCoords[0] = "" Then $aCoords[0] = 0
								If $aCoords[1] = "" Then $aCoords[1] = 0
								$oCtrl2.Coord2 = $aCoords

								;create the control
								$oNewCtrl = _create_ctrl($oCtrl2, True, -1, -1, $oCtrl.Hwnd)
								Local $aStyles = StringSplit($oNewCtrl.styleString, ", ", $STR_ENTIRESPLIT + $STR_NOCOUNT)
								For $sStyle In $aStyles
									$iOldStyle = _WinAPI_GetWindowLong(GUICtrlGetHandle($oNewCtrl.Hwnd), $GWL_STYLE)
									GUICtrlSetStyle($oNewCtrl.Hwnd, BitOR($iOldStyle, Execute($sStyle)))
								Next

								Switch $oCtrl2.Type
									Case "Rect", "Ellipse", "Line"
										_updateGraphic($oCtrl2)
								EndSwitch
							Next
							GUICtrlCreateTabItem('')
							GUISwitch($hGUI)

							$j += 1
						Next
					EndIf

				Case "Group"
					Local $aCtrls = $oThisCtrl.Controls
					If Not IsArray($aCtrls) Then ContinueLoop

					For $oGroupCtrl In $aCtrls
						$oCtrl2 = $oCtrls.createNew()

						;get properties
						$oCtrl2.HwndCount = 1
						$oCtrl2.Type = _json_getValue($oGroupCtrl, "Type", "")
						$oCtrl2.Name = _json_getValue($oGroupCtrl, "Name", "")
						$oCtrl2.Text = _json_getValue($oGroupCtrl, "Text", "")
						$oCtrl2.Visible = _json_getValue($oGroupCtrl, "Visible", True)
						$oCtrl2.OnTop = _json_getValue($oGroupCtrl, "OnTop", False)
						$oCtrl2.Left = _json_getValue($oGroupCtrl, "Left", -1)
						$oCtrl2.Top = _json_getValue($oGroupCtrl, "Top", -1)
						$oCtrl2.Width = _json_getValue($oGroupCtrl, "Width", 1)
						$oCtrl2.Height = _json_getValue($oGroupCtrl, "Height", 1)
						$oCtrl2.Autosize = _json_getValue($oGroupCtrl, "Autosize", $GUI_UNCHECKED)
						$oCtrl2.Global = _json_getValue($oGroupCtrl, "Global", 1)
						$oCtrl2.Locked = _json_getValue($oGroupCtrl, "Locked", False)
						$oCtrl2.styleString = _json_getValue($oGroupCtrl, "styleString", "")
						$oCtrl2.Color = _json_getValue($oGroupCtrl, "Color", "")
						$oCtrl2.Background = _json_getValue($oGroupCtrl, "Background", "")
						$oCtrl2.FontSize = _json_getValue($oGroupCtrl, "FontSize", 8.5)
						$oCtrl2.FontWeight = _json_getValue($oGroupCtrl, "FontWeight", 400)
						$oCtrl2.FontName = _json_getValue($oGroupCtrl, "FontName", "")
						$oCtrl2.BorderColor = _json_getValue($oGroupCtrl, "BorderColor", "0x000000")
						$oCtrl2.BorderSize = _json_getValue($oGroupCtrl, "BorderSize", 1)
						$oCtrl2.CodeString = _json_getValue($oGroupCtrl, "CodeString", "")
						$oCtrl2.Items = _json_getValue($oGroupCtrl, "Items", "")
						$oCtrl2.Img = _json_getValue($oGroupCtrl, "Img", "")

						Local $aCoords[2]
						$aCoords[0] = _json_getValue($oGroupCtrl.Coords, "Coord1_X", "")
						$aCoords[1] = _json_getValue($oGroupCtrl.Coords, "Coord1_Y", "")
						If $aCoords[0] = "" Then $aCoords[0] = 0
						If $aCoords[1] = "" Then $aCoords[1] = 0
						$oCtrl2.Coord1 = $aCoords
						$aCoords[0] = _json_getValue($oGroupCtrl.Coords, "Coord2_X", "")
						$aCoords[1] = _json_getValue($oGroupCtrl.Coords, "Coord2_Y", "")
						If $aCoords[0] = "" Then $aCoords[0] = 0
						If $aCoords[1] = "" Then $aCoords[1] = 0
						$oCtrl2.Coord2 = $aCoords

						;create the control
						$oNewCtrl = _create_ctrl($oCtrl2, True, -1, -1, $oCtrl.Hwnd)
						Local $aStyles = StringSplit($oNewCtrl.styleString, ", ", $STR_ENTIRESPLIT + $STR_NOCOUNT)
						For $sStyle In $aStyles
							$iOldStyle = _WinAPI_GetWindowLong(GUICtrlGetHandle($oNewCtrl.Hwnd), $GWL_STYLE)
							GUICtrlSetStyle($oNewCtrl.Hwnd, BitOR($iOldStyle, Execute($sStyle)))
						Next

						Switch $oCtrl2.Type
							Case "Rect", "Ellipse", "Line"
								_updateGraphic($oCtrl2)
						EndSwitch
					Next

			EndSwitch

			Switch $oCtrl.Type
				Case "Menu"
					Local $MenuItemCount = $oThisCtrl.MenuItemCount
					If $MenuItemCount > 0 Then
						Local $aMenuItems = $oThisCtrl.MenuItems
						If Not IsArray($aMenuItems) Then ContinueLoop

						$j = 1
						For $oMenuItem In $aMenuItems
							_new_menuItemCreate($oCtrl, True, _json_getValue($oMenuItem, "Text", ""))
							$oCtrl.MenuItems.at($j - 1).Name = _json_getValue($oMenuItem, "Name", "")
							$oCtrl.MenuItems.at($j - 1).Text = _json_getValue($oMenuItem, "Text", "")
							$oCtrl.MenuItems.at($j - 1).Global = _json_getValue($oMenuItem, "Global", "")
;~ 							GUICtrlSetData($oCtrl.MenuItems.at($j - 1).Hwnd, $oCtrl.MenuItems.at($j - 1).Text)
							$j += 1
						Next
					EndIf
				Case "Rect", "Ellipse", "Line"
					_updateGraphic($oCtrl)
			EndSwitch
		Next
	EndIf

	_SendMessage($hGUI, $WM_SETREDRAW, True)
;~ 	GUISetState(@SW_SHOWNORMAL, $hGUI)

;~ 	_SendMessage($hGUI, $WM_SETREDRAW, True)
	_WinAPI_RedrawWindow($hGUI)

	_formObjectExplorer_updateList()
	_refreshGenerateCode()

	$bStatusNewMessage = True
	_GUICtrlStatusBar_SetText($hStatusbar, "Loaded successfully")

	$oMain.hasChanged = False

	ConsoleWrite("End Load: " & TimerDiff($ttimer) & @CRLF & @CRLF)
EndFunc   ;==>_load_gui_definition

Func _json_getValue($oJson, $sKey, $defaultValue = "")
	If MapExists($oJson, $sKey) Then
		Return $oJson[$sKey]
	Else
		Return $defaultValue
	EndIf
EndFunc


Func _json_getLine(ByRef $sJsonStr)
	Local $aReturnVals[2]

	;remove leading and trailing whitespace
	$sJsonStr = StringRegExpReplace($sJsonStr, '(?im)^\s*', "")
	$sJsonStr = StringRegExpReplace($sJsonStr, '(?im)\s*$', "")

	;check what type of line it is
	If $sJsonStr = "{" Then
		$aReturnVals[0] = "{"
	ElseIf $sJsonStr = "}" Or $sJsonStr = "}," Then
		$aReturnVals[0] = "}"
	ElseIf $sJsonStr = "]" Or $sJsonStr = "]," Then
		$aReturnVals[0] = "]"
	Else
		Local $aMatches = StringRegExp($sJsonStr, '(?im)^\s*"(.*?)"\s*:\s*\"*(.*?)(?:(?:")|(?:,)|(?:$))', $STR_REGEXPARRAYGLOBALMATCH)
		If IsArray($aMatches) Then
			$aReturnVals[0] = $aMatches[0]
			If UBound($aMatches) > 1 Then
				$aReturnVals[1] = $aMatches[1]
			Else
				$aReturnVals[1] = ""
			EndIf
		Else
			$aReturnVals[0] = ""
			$aReturnVals[1] = ""
		EndIf
	EndIf

	Return $aReturnVals
EndFunc   ;==>_json_getLine


;~ Func _Json_Get(ByRef $obj, $data, $defaultValue = 0)
;~ 	Local $val = Json_Get($obj, $data)
;~ 	If @error Then
;~ 		Return $defaultValue
;~ 	Else
;~ 		Return $val
;~ 	EndIf
;~ EndFunc   ;==>_Json_Get

;~ Func _Json_Get3(ByRef $obj, $data, $defaultValue = 0)
;~ 	Local $val = _JSON_Get2($obj, $data)
;~ 	If @error Then
;~ 		Return $defaultValue
;~ 	Else
;~ 		Return $val
;~ 	EndIf
;~ EndFunc   ;==>_Json_Get3




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
	$oMain.Background = IniRead($AgdInfile, "Main", "Background", "")
	If $oMain.Background <> "" Then
		GUISetBkColor($oMain.Background, $hGUI)
	Else
		GUISetBkColor($defaultGuiBkColor, $hGUI)
	EndIf

	$oProperties_Main.properties.Background.value = $oMain.Background
	$oProperties_Main.properties.Title.value = $oMain.Title
	$oProperties_Main.properties.Name.value = $oMain.Name
	$oProperties_Main.properties.Left.value = $oMain.Left
	$oProperties_Main.properties.Top.value = $oMain.Top
	$oProperties_Main.properties.Width.value = $oMain.Width
	$oProperties_Main.properties.Height.value = $oMain.Height


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
		$oCtrl.Autosize = IniRead($AgdInfile, $Key, "Autosize", $GUI_UNCHECKED)
		$oCtrl.Global = IniRead($AgdInfile, $Key, "Global", $GUI_CHECKED)
		$oCtrl.Locked = IniRead($AgdInfile, $Key, "Locked", $GUI_UNCHECKED)
		$oCtrl.Color = IniRead($AgdInfile, $Key, "Color", "")
		$oCtrl.Background = IniRead($AgdInfile, $Key, "Background", "")

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
		If IsMap($oFileData) Then
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
;~ 		$aMatches = StringRegExp($sLine, '(?im)\s*(?:GUICtrlSetFont)\s*\((.+?),\s*(.+?)(?:,\s*(.+?))?(?:,\s*(?:.+?))?(?:,\s*"(.+?))?"\s*(?:,|\))', $STR_REGEXPARRAYGLOBALMATCH)
		$aMatches = StringRegExp($sLine, '(?im)\s*(?:GUICtrlSetFont)\s*\((.+?),\s*(.+?)(?:,|\))(?:\s*(.+?)(?:,|\)))?(?:\s*(.+?)(?:,|\)))?(?:\s*(.+?)(?:,|\)))?(?:\s*(.+?)(?:,|\)))?', $STR_REGEXPARRAYGLOBALMATCH)
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
			Else
				$fontName = ""
			EndIf

			$sJsonString = ""
			If $iTabParentIndex > -1 And $inTab Then
				$sJsonString = ".Controls[" & $iTabParentIndex & "].Tabs[" & $iTabCounter & "].Controls[" & $iChildCounter & "]"
			Else
				$sJsonString = ".Controls[" & $ctrlIndex & "]"
			EndIf

			If $inGroup Then
				$sJsonString = ".Controls[" & $iGroupParentIndex & "].Controls[" & $iChildCounter & "]"
			EndIf
			Json_Put($objOutput, $sJsonString & ".FontSize", $aMatches[1])
			Json_Put($objOutput, $sJsonString & ".FontWeight", $fontWeight)
			Json_Put($objOutput, $sJsonString & ".FontName", $fontName)

			ContinueLoop
		EndIf


		;check line for GUICtrlSetBkColor
		$ctrlIndex = -1
		$aMatches = StringRegExp($sLine, '(?im)\s*(?:GUICtrlSetBkColor)\s*\((.+?),\s*(.+?)\s*(?:,|\))', $STR_REGEXPARRAYGLOBALMATCH)
		If Not @error Then
			If $aMatches[0] = "-1" Then
				$ctrlIndex = $iCtrlCounter
;~ 				Json_Put($objOutput, ".Controls[" & $iCtrlCounter & "].Background", $aMatches[1])
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

			$sJsonString = ""
			If $iTabParentIndex > -1 And $inTab Then
				$sJsonString = ".Controls[" & $iTabParentIndex & "].Tabs[" & $iTabCounter & "].Controls[" & $iChildCounter & "]"
			Else
				$sJsonString = ".Controls[" & $ctrlIndex & "]"
			EndIf

			If $inGroup Then
				$sJsonString = ".Controls[" & $iGroupParentIndex & "].Controls[" & $iChildCounter & "]"
			EndIf
			Json_Put($objOutput, $sJsonString & ".Background", $aMatches[1])
			ContinueLoop
		EndIf

		;check line for GUICtrlSetColor
		$aMatches = StringRegExp($sLine, '(?im)\s*(?:GUICtrlSetColor)\s*\((.+?),\s*(.+?)\s*(?:,|\))', $STR_REGEXPARRAYGLOBALMATCH)
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

			$sJsonString = ""
			If $iTabParentIndex > -1 And $inTab Then
				$sJsonString = ".Controls[" & $iTabParentIndex & "].Tabs[" & $iTabCounter & "].Controls[" & $iChildCounter & "]"
			Else
				$sJsonString = ".Controls[" & $ctrlIndex & "]"
			EndIf

			If $inGroup Then
				$sJsonString = ".Controls[" & $iGroupParentIndex & "].Controls[" & $iChildCounter & "]"
			EndIf
			Json_Put($objOutput, $sJsonString & ".Color", $aMatches[1])
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

;~ 			Json_Put($objOutput, ".Main.Background", "")

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
;~ 			Json_Put($objOutput, $sJsonString & ".Background", "")
;~ 			Json_Put($objOutput, $sJsonString & ".Color", "")
;~ 			Json_Put($objOutput, $sJsonString & ".FontName", "")
;~ 			Json_Put($objOutput, $sJsonString & ".StyleString", "")
;~ 			Json_Put($objOutput, $sJsonString & ".CodeString", "")

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
	ClipPut(_JSON_Generate($objOutput))

	Return $objOutput
EndFunc   ;==>_importAu3File

Func Json_Put(ByRef $mMap, $sItem, $value)
	_JSON_addChangeDelete($mMap, $sItem, $value)
EndFunc

Func Json_Get(ByRef $mMap, $sItem)
	Return _Json_Get($mMap, $sItem)
EndFunc

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
