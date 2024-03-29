; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_formObjectExplorer.au3
; Description ...: Create and manage the object explorer GUI
; ===============================================================================================================================


#Region _formObjectExplorer
;------------------------------------------------------------------------------
; Title...........: _formObjectExplorer
; Description.....:	Create the GUI
;------------------------------------------------------------------------------
Func _formObjectExplorer()
	Local $w = 250
	Local $h = 500

	Local $currentWinPos = WinGetPos($hGUI)
	Local $x = $currentWinPos[0] + $currentWinPos[2]
	Local $y = $currentWinPos[1]

	Local $sPos = IniRead($sIniPath, "Settings", "posObjectExplorer", $x & "," & $y)
	Local $aPos = StringSplit($sPos, ",")
	If Not @error Then
		$x = $aPos[1]
		$y = $aPos[2]
	EndIf

	$sPos = IniRead($sIniPath, "Settings", "sizeObjectExplorer", $w & "," & $h)
	$aPos = StringSplit($sPos, ",")
	If Not @error Then
		$w = $aPos[1]
		$h = $aPos[2]
	EndIf

	;make sure not set off screen
	Local $ixCoordMin = _WinAPI_GetSystemMetrics(76)
	Local $iyCoordMin = _WinAPI_GetSystemMetrics(77)
	Local $iFullDesktopWidth = _WinAPI_GetSystemMetrics(78)
	Local $iFullDesktopHeight = _WinAPI_GetSystemMetrics(79)
	If ($x + $w) > ($ixCoordMin + $iFullDesktopWidth) Then
		$x = $iFullDesktopWidth - $w
	ElseIf $x < $ixCoordMin Then
		$x = 1
	EndIf
	If ($y + $h) > ($iyCoordMin + $iFullDesktopHeight) Then
		$y = $iFullDesktopHeight - $h
	ElseIf $y < $iyCoordMin Then
		$y = 1
	EndIf

	$hFormObjectExplorer = GUICreate("Object Explorer", $w, $h, $x, $y, $WS_SIZEBOX, -1, $hToolbar)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitObjectExplorer")

	If Not @Compiled Then
		GUISetIcon(@ScriptDir & '\resources\icons\icon.ico')
	EndIf

	Local $titleBarHeight = _WinAPI_GetSystemMetrics($SM_CYCAPTION) + 3

	;background label
	GUICtrlCreateLabel("", 0, 0, $w, $h - $titleBarHeight - 25)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

	;object list
	$lvObjects = GUICtrlCreateTreeView(1, 5, $w, $h - $titleBarHeight - 40, BitOR($TVS_LINESATROOT, $TVS_HASLINES, $TVS_HASBUTTONS, $TVS_FULLROWSELECT, $TVS_SHOWSELALWAYS), $WS_EX_TRANSPARENT)
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

	;bottom section
	$labelObjectCount = GUICtrlCreateLabel("Object Count: " & $oCtrls.count, 5, $h - 18 - $titleBarHeight)
	GUICtrlCreateButton("Move Up", $w - 20 - 58 * 2 - 5 * 1, $h - 22 - $titleBarHeight, 68, 20)
	GUICtrlSetOnEvent(-1, "_onLvMoveUp")
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlCreateButton("Move Down", $w - 20 - 48 - 5, $h - 22 - $titleBarHeight, 68, 20)
	GUICtrlSetOnEvent(-1, "_onLvMoveDown")
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)

	_formObjectExplorer_updateList()


	;accelerators
	Local Const $accel_delete = GUICtrlCreateDummy()
	Local Const $accelerators[1][2] = _
			[ _
			["{Delete}", $accel_delete] _
			]
	GUISetAccelerators($accelerators, $hFormObjectExplorer)
	GUICtrlSetOnEvent($accel_delete, "_onLvObjectsDelete")

	GUISwitch($hGUI)
EndFunc   ;==>_formObjectExplorer
#EndRegion _formObjectExplorer


#Region events
;------------------------------------------------------------------------------
; Title...........: _onExitGenerateCode
; Description.....: close the GUI
; Events..........: close button or menu item
;------------------------------------------------------------------------------
Func _onExitObjectExplorer()
	_saveWinPositions()

	GUIDelete($hFormObjectExplorer)
	GUICtrlSetState($menu_ObjectExplorer, $GUI_UNCHECKED)

	GUISwitch($hGUI)

	; save state to settings file
	IniWrite($sIniPath, "Settings", "ShowObjectExplorer", 0)
EndFunc   ;==>_onExitObjectExplorer


;------------------------------------------------------------------------------
; Title...........: _onLvObjectsItem
; Description.....: make selected item the selected control (or multiple)
; Events..........: select listview item
;------------------------------------------------------------------------------
Func _onLvObjectsItem()
	$childSelected = False

	Local $count = _GUICtrlTreeView_GetCount($lvObjects)
	Local $aItems[$count]
	Local $iIndex = 0, $first = True
	Local $hItem = _GUICtrlTreeView_GetFirstItem($lvObjects)
	If $hItem = 0 Then Return -1
	Do
		If _GUICtrlTreeView_GetSelected($lvObjects, $hItem) Then
			$aItems[$iIndex] = $hItem
			$iIndex += 1

			Local $aText = _GUICtrlTreeView_GetText($lvObjects, $hItem)
			Local $aStrings = StringSplit($aText, @TAB)
			Local $textHwnd = StringTrimRight(StringTrimLeft($aStrings[2], 7), 1)
			$oCtrl = $oCtrls.get(Dec($textHwnd))

			Local $hParent = _GUICtrlTreeView_GetParentHandle($lvObjects, $hItem)
			Local $aParentText1, $aParentStrings1, $ParentTextHwnd1, $oParentCtrl1
			If $hParent <> 0 Then    ;this is a child
				Local $hParent1 = _GUICtrlTreeView_GetParentHandle($lvObjects, _GUICtrlTreeView_GetItemHandle($lvObjects, $hParent))
				If $hParent1 <> 0 Then    ;this is a grand-child
					Local $aParentText = _GUICtrlTreeView_GetText($lvObjects, $hParent)
					Local $aParentStrings = StringSplit($aParentText, @TAB)
					Local $ParentTextHwnd = StringTrimRight(StringTrimLeft($aParentStrings[2], 7), 1)
					$oParentCtrl = $oCtrls.get(Dec($ParentTextHwnd))

					Local $aParentText1 = _GUICtrlTreeView_GetText($lvObjects, $hParent1)
					Local $aParentStrings1 = StringSplit($aParentText1, @TAB)
					Local $ParentTextHwnd1 = StringTrimRight(StringTrimLeft($aParentStrings1[2], 7), 1)
					$oParentCtrl1 = $oCtrls.get(Dec($ParentTextHwnd1))
					If $oParentCtrl1.Type = "Tab" Then
						;get tab #
						Local $i = 0, $oTab
						For $hTab In $oParentCtrl1.Tabs
							$oTab = $oCtrls.get($hTab)
							For $oTabCtrl In $oTab.ctrls.Items()
								If $oTabCtrl.Hwnd = Dec($textHwnd) Then
									_GUICtrlTab_ActivateTab($oParentCtrl1.Hwnd, $i)
									If $first Then    ;select first item
										$first = False
										_add_to_selected($oTabCtrl)
										_populate_control_properties_gui($oTabCtrl.Hwnd)
									Else    ;add to selection
										_add_to_selected($oTabCtrl, False)
									EndIf
								EndIf
							Next

							$i += 1
						Next
					EndIf
				Else    ;this is a child
					Local $aParentText = _GUICtrlTreeView_GetText($lvObjects, $hParent)
					Local $aParentStrings = StringSplit($aParentText, @TAB)
					Local $ParentTextHwnd = StringTrimRight(StringTrimLeft($aParentStrings[2], 7), 1)
					$oParentCtrl = $oCtrls.get(Dec($ParentTextHwnd))
					Switch $oParentCtrl.Type
						Case "Tab"
							;get tab #
							Local $i = 0, $oTab
							For $hTab In $oParentCtrl.Tabs
								$oTab = $oCtrls.get($hTab)
								If $oTab.Hwnd = Dec($textHwnd) Then
									$childSelected = True
									_GUICtrlTab_ActivateTab($oParentCtrl.Hwnd, $i)
									_add_to_selected($oParentCtrl)
									_populate_control_properties_gui($oParentCtrl, Dec($textHwnd))
								EndIf

								$i += 1
							Next

						Case "Group"
							$childSelected = True
							_add_to_selected($oCtrl)
							_populate_control_properties_gui($oCtrl, Dec($textHwnd))


						Case "Menu"
							$childSelected = True
;~ 					_add_to_selected($oParentCtrl)
							_add_to_selected($oParentCtrl)
							_populate_control_properties_gui($oParentCtrl, Dec($textHwnd))

					EndSwitch
				EndIf
			Else
				If $first Then    ;select first item
					$first = False
					_add_to_selected($oCtrl)
					_populate_control_properties_gui($oCtrl)
				Else    ;add to selection
					_add_to_selected($oCtrl, False)
				EndIf
			EndIf
		EndIf
		$hItem = _GUICtrlTreeView_GetNext($lvObjects, $hItem)
	Until $hItem = 0
EndFunc   ;==>_onLvObjectsItem


;------------------------------------------------------------------------------
; Title...........: _onLvObjectsDelete
; Description.....: Delete selected
; Events..........: Del key
;------------------------------------------------------------------------------
Func _onLvObjectsDelete()
	_delete_selected_controls()
EndFunc   ;==>_onLvObjectsDelete


;------------------------------------------------------------------------------
; Title...........: _onLvObjectsDeleteMenu
; Description.....: Delete selected
; Events..........: right-click context menu
;------------------------------------------------------------------------------
Func _onLvObjectsDeleteMenu()
	;WM_NOTIFY is called right before this, which selects the right-clicked control
	_delete_selected_controls()
EndFunc   ;==>_onLvObjectsDeleteMenu


;------------------------------------------------------------------------------
; Title...........: _onLvObjectsTabItemDelete
; Description.....: Show Tab Item delete menu
; Events..........: right-click context menu
;------------------------------------------------------------------------------
Func _onLvObjectsTabItemDelete()
	ShowMenu($overlay_contextmenutab, $oMouse.X, $oMouse.Y)
EndFunc   ;==>_onLvObjectsTabItemDelete


;------------------------------------------------------------------------------
; Title...........: _onLvMoveUp
; Description.....: Move control up the list
; Events..........: button click
;------------------------------------------------------------------------------
Func _onLvMoveUp()
	Local $oCtrlMove = _getLvSelected()

	If IsObj($oCtrlMove) Then
		$oCtrls.moveUp($oCtrlMove)

		Local $foundIndex, $nextHwnd
		For $oThisCtrl In $oCtrls.ctrls.Items()
			If $foundIndex Then
				$nextHwnd = $oThisCtrl.Hwnd
				ExitLoop
			EndIf
			If $oThisCtrl.Hwnd = $oCtrlMove.Hwnd Then
				$foundIndex = True
			EndIf
		Next
		If $foundIndex Then
;~ 			ConsoleWrite("found index" & @CRLF)
			GuiCtrlSetOnTop($oCtrlMove.Hwnd, $nextHwnd)
		EndIf

		_refreshGenerateCode()
		_formObjectExplorer_updateList()

		_setLvSelected($oCtrlMove)
	EndIf

EndFunc   ;==>_onLvMoveUp


;------------------------------------------------------------------------------
; Title...........: _onLvMoveDown
; Description.....: Move control down the list
; Events..........: button click
;------------------------------------------------------------------------------
Func _onLvMoveDown()
	Local $oCtrlMove = _getLvSelected()

	If IsObj($oCtrlMove) Then
		$oCtrls.moveDown($oCtrlMove)

		Local $foundIndex, $nextHwnd
		For $oThisCtrl In $oCtrls.ctrls.Items()
			If $foundIndex Then
				$nextHwnd = $oThisCtrl.Hwnd
				ExitLoop
			EndIf
			If $oThisCtrl.Hwnd = $oCtrlMove.Hwnd Then
				$foundIndex = True
			EndIf
		Next
		If $foundIndex Then
			ConsoleWrite("found index" & @CRLF)
			GuiCtrlSetOnTop($oCtrlMove.Hwnd, $nextHwnd)
		EndIf

		_refreshGenerateCode()
		_formObjectExplorer_updateList()

		_setLvSelected($oCtrlMove)
	EndIf

EndFunc   ;==>_onLvMoveDown
#EndRegion events


Func _getLvSelected()
	$childSelected = False

	Local $count = _GUICtrlTreeView_GetCount($lvObjects)
	Local $aItems[$count]
	Local $iIndex = 0, $first = True
	Local $hItem = _GUICtrlTreeView_GetFirstItem($lvObjects)
	If $hItem = 0 Then Return -1
	Do
		If _GUICtrlTreeView_GetSelected($lvObjects, $hItem) Then
			Local $aText = _GUICtrlTreeView_GetText($lvObjects, $hItem)
			Local $aStrings = StringSplit($aText, @TAB)
			Local $textHwnd = StringTrimRight(StringTrimLeft($aStrings[2], 7), 1)
			$oCtrl = $oCtrls.get(Dec($textHwnd))

			If $oCtrl.Type = "TabItem" Then
				Local $hParent = _GUICtrlTreeView_GetParentHandle($lvObjects, $hItem)
				If $hParent <> 0 Then    ;this is a child
					Local $aParentText = _GUICtrlTreeView_GetText($lvObjects, $hParent)
					Local $aParentStrings = StringSplit($aParentText, @TAB)
					Local $ParentTextHwnd = StringTrimRight(StringTrimLeft($aParentStrings[2], 7), 1)
					$oCtrl = $oCtrls.get(Dec($ParentTextHwnd))
				EndIf
			Else
				$oCtrl = $oCtrl
			EndIf

			Return $oCtrl
		EndIf

		$hItem = _GUICtrlTreeView_GetNext($lvObjects, $hItem)
		$iIndex += 1
	Until $hItem = 0

	Return -1
EndFunc   ;==>_getLvSelected


Func _setLvSelected($oCtrlSelect, $bSelect = False)
	Local $i = 0
	Local $hItem = _GUICtrlTreeView_GetFirstItem($lvObjects)
	If $hItem = 0 Then Return -1

	;first, loop through and deselect all items
	Do
		_GUICtrlTreeView_SetSelected($lvObjects, $hItem, False)
		$hItem = _GUICtrlTreeView_GetNext($lvObjects, $hItem)
	Until $hItem = 0

	;if not an object, return now
	If Not IsObj($oCtrlSelect) Then Return 0

	$i = 0
	$hItem = _GUICtrlTreeView_GetFirstItem($lvObjects)
	If $hItem = 0 Then Return -1

	;otherwise, loop through and select only the passed in control(s)
	Do
		Local $aText = _GUICtrlTreeView_GetText($lvObjects, $hItem)
		Local $aStrings = StringSplit($aText, @TAB)
		Local $textHwnd = StringTrimRight(StringTrimLeft($aStrings[2], 7), 1)

		If Dec($textHwnd) = $oCtrlSelect.Hwnd Then
			_GUICtrlTreeView_SetSelected($lvObjects, $hItem, True)
			;if set, trigger the selection event
			If $bSelect Then
				_GUICtrlTreeView_SelectItem($lvObjects, $hItem, $TVGN_CARET)
			EndIf
			Return 0
		EndIf

		$hItem = _GUICtrlTreeView_GetNext($lvObjects, $hItem)
		$i += 1
	Until $hItem = 0

	Return -1
EndFunc   ;==>_setLvSelected


Func _getLvSelectedHwnd()
	Local $count = _GUICtrlTreeView_GetCount($lvObjects)
	Local $aItems[$count]
	Local $iIndex = 0, $first = True
	Local $hItem = _GUICtrlTreeView_GetFirstItem($lvObjects)
	If $hItem = 0 Then Return -1
	Do
		If _GUICtrlTreeView_GetSelected($lvObjects, $hItem) Then
			Local $aText = _GUICtrlTreeView_GetText($lvObjects, $hItem)
			Local $aStrings = StringSplit($aText, @TAB)
			Local $textHwnd = StringTrimRight(StringTrimLeft($aStrings[2], 7), 1)
			$oCtrl = $oCtrls.get(Dec($textHwnd))

			Return Dec($textHwnd)
		EndIf

		$hItem = _GUICtrlTreeView_GetNext($lvObjects, $hItem)
		$iIndex += 1
	Until $hItem = 0

	Return -1
EndFunc   ;==>_getLvSelectedHwnd


Func _setLvSelectedHwnd($hwnd, $bSelect = False)
	Local $i = 0
	Local $hItem = _GUICtrlTreeView_GetFirstItem($lvObjects)
	If $hItem = 0 Then Return -1

	;first, loop through and deselect all items
	Do
		_GUICtrlTreeView_SetSelected($lvObjects, $hItem, False)
		$hItem = _GUICtrlTreeView_GetNext($lvObjects, $hItem)
	Until $hItem = 0

	$i = 0
	$hItem = _GUICtrlTreeView_GetFirstItem($lvObjects)
	If $hItem = 0 Then Return -1

	;loop through and select only the passed in control(s)
	Do
		Local $aText = _GUICtrlTreeView_GetText($lvObjects, $hItem)
		Local $aStrings = StringSplit($aText, @TAB)
		Local $textHwnd = StringTrimRight(StringTrimLeft($aStrings[2], 7), 1)

		If Dec($textHwnd) = $hwnd Then
			_GUICtrlTreeView_SetSelected($lvObjects, $hItem, True)
			;if set, trigger the selection event
			If $bSelect Then
				_GUICtrlTreeView_SelectItem($lvObjects, $hItem, $TVGN_CARET)
			EndIf
			Return 0
		EndIf

		$hItem = _GUICtrlTreeView_GetNext($lvObjects, $hItem)
		$i += 1
	Until $hItem = 0

	Return -1
EndFunc   ;==>_setLvSelectedHwnd


;------------------------------------------------------------------------------
; Title...........: _formObjectExplorer_updateList
; Description.....: update list of objects
;------------------------------------------------------------------------------
Func _formObjectExplorer_updateList()
	If Not IsHWnd($hFormObjectExplorer) Then Return

	Local $prevSelected = _getLvSelectedHwnd()

	Local $count = $oCtrls.count
	Local $aList[$count]

	Local $lvItem, $lvMenu, $lvMenuDelete, $childItem, $tabMenu, $tabMenuDelete, $lvMenuNewTab, $lvMenuDeleteTab, $sName, $childTabCtrl
	Local $lvMenuNewMenuItem, $menuItemMenu

	Local $isVisible = BitAND(WinGetState($hFormObjectExplorer), $WIN_STATE_VISIBLE)
	If $isVisible Then
		_SendMessage($hFormObjectExplorer, $WM_SETREDRAW, False)
	EndIf
	_GUICtrlTreeView_DeleteAll($lvObjects)
	For $oCtrl In $oCtrls.ctrls.Items()
		If $oCtrl.Type = "TabItem" Then ContinueLoop
		If $oCtrl.CtrlParent <> 0 Then ContinueLoop

		$sName = $oCtrl.Name
		If $sName = "" Then
			$sName = $oCtrl.Type & "*"
		EndIf

		$lvItem = GUICtrlCreateTreeViewItem($sName & "       " & @TAB & "(HWND: " & Hex($oCtrl.Hwnd) & ")", $lvObjects)
		GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

		$lvMenu = GUICtrlCreateContextMenu($lvItem)
		$lvMenuDelete = GUICtrlCreateMenuItem("Delete", $lvMenu)
		GUICtrlSetOnEvent($lvMenuDelete, "_onLvObjectsDeleteMenu")

		Switch $oCtrl.Type
			Case "Tab"
				$lvMenuNewTab = GUICtrlCreateMenuItem("New Tab", $lvMenu)
				$lvMenuDeleteTab = GUICtrlCreateMenuItem("Delete Tab", $lvMenu)
				GUICtrlSetOnEvent($lvMenuNewTab, "_onNewTab")
				GUICtrlSetOnEvent($lvMenuDeleteTab, "_onDeleteTab")

				Local $oTab
				For $hTab In $oCtrl.Tabs
					$oTab = $oCtrls.get($hTab)
					$childItem = GUICtrlCreateTreeViewItem($oTab.Name & "       " & @TAB & "(HWND: " & Hex($oTab.Hwnd) & ")", $lvItem)
					GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

					$tabMenu = GUICtrlCreateContextMenu($childItem)
					$tabMenuDelete = GUICtrlCreateMenuItem("Delete Tab", $tabMenu)
					GUICtrlSetOnEvent($tabMenuDelete, "_delete_tab")

					_GUICtrlTreeView_Expand($lvObjects, $lvItem)

					For $oTabCtrl In $oTab.ctrls.Items()
						$sName = $oTabCtrl.Name
						If $sName = "" Then
							$sName = $oTabCtrl.Type & "*"
						EndIf

						$childTabCtrl = GUICtrlCreateTreeViewItem($sName & "       " & @TAB & "(HWND: " & Hex($oTabCtrl.Hwnd) & ")", $childItem)
						GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

						$lvMenu = GUICtrlCreateContextMenu($childTabCtrl)
						$lvMenuDelete = GUICtrlCreateMenuItem("Delete", $lvMenu)
						GUICtrlSetOnEvent($lvMenuDelete, "_onLvObjectsDeleteMenu")
					Next
				Next
				_GUICtrlTreeView_Expand($lvObjects, $lvItem)

			Case "Group"
				For $oThisCtrl In $oCtrl.ctrls.Items()
					$sName = $oThisCtrl.Name
					If $sName = "" Then
						$sName = $oThisCtrl.Type & "*"
					EndIf

					$childCtrl = GUICtrlCreateTreeViewItem($sName & "       " & @TAB & "(HWND: " & Hex($oThisCtrl.Hwnd) & ")", $lvItem)
					GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

					$lvMenu = GUICtrlCreateContextMenu($childCtrl)
					$lvMenuDelete = GUICtrlCreateMenuItem("Delete", $lvMenu)
					GUICtrlSetOnEvent($lvMenuDelete, "_onLvObjectsDeleteMenu")
				Next
				_GUICtrlTreeView_Expand($lvObjects, $lvItem)

			Case "Menu"
				$lvMenuNewMenuItem = GUICtrlCreateMenuItem("New menu item", $lvMenu)
				GUICtrlSetOnEvent($lvMenuNewMenuItem, "_new_menuItem")

				For $oMenuItem In $oCtrl.MenuItems
					Local $childName = $oMenuItem.Name
					If $childName = "" Then
						$childName = $oMenuItem.Type & "*"
					EndIf
					$childItem = GUICtrlCreateTreeViewItem($childName & "       " & @TAB & "(HWND: " & Hex($oMenuItem.Hwnd) & ")", $lvItem)
					GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

					$menuItemMenu = GUICtrlCreateContextMenu($childItem)
					$menuItemMenuDelete = GUICtrlCreateMenuItem("Delete menu item", $menuItemMenu)
					GUICtrlSetOnEvent($menuItemMenuDelete, "_delete_menuItem")

					_GUICtrlTreeView_Expand($lvObjects, $lvItem)
				Next

		EndSwitch
	Next

	If $isVisible Then
		_SendMessage($hFormObjectExplorer, $WM_SETREDRAW, True)
		_WinAPI_RedrawWindow($hFormObjectExplorer)
	EndIf

	If StringStripWS($count, $STR_STRIPALL) = "" Then $count = 0
	GUICtrlSetData($labelObjectCount, "Object Count: " & $count)

	If $prevSelected <> -1 Then
		_setLvSelectedHwnd($prevSelected)
	EndIf
EndFunc   ;==>_formObjectExplorer_updateList
