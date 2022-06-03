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
	Local $x, $y

	Local $sPos = IniRead($sIniPath, "Settings", "posObjectExplorer", "")
	If $sPos <> "" Then
		Local $aPos = StringSplit($sPos, ",")
		$x = $aPos[1]
		$y = $aPos[2]
	Else
		Local $currentWinPos = WinGetPos($hGUI)
		$x = $currentWinPos[0] + $currentWinPos[2]
		$y = $currentWinPos[1]
	EndIf

	;make sure $x is not set off screen
	Local $ixCoordMin = _WinAPI_GetSystemMetrics(76)
	Local $iyCoordMin = _WinAPI_GetSystemMetrics(77)
	Local $iFullDesktopWidth = _WinAPI_GetSystemMetrics(78)
	Local $iFullDesktopHeight = _WinAPI_GetSystemMetrics(79)
	If ($x + $w) > ($ixCoordMin + $iFullDesktopWidth) Then
		$x = $iFullDesktopWidth - $w
	ElseIf $x < $ixCoordMin Then
		$x = 1
	EndIf

	$hFormObjectExplorer = GUICreate("Object Explorer", $w, $h, $x, $y, $WS_SIZEBOX, -1, $hGUI)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_onExitObjectExplorer")
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


	GUISetState(@SW_SHOW, $hFormObjectExplorer)

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
			If $hParent <> 0 Then    ;this is a child
				Local $aParentText = _GUICtrlTreeView_GetText($lvObjects, $hParent)
				Local $aParentStrings = StringSplit($aParentText, @TAB)
				Local $ParentTextHwnd = StringTrimRight(StringTrimLeft($aParentStrings[2], 7), 1)
				$oParentCtrl = $oCtrls.get(Dec($ParentTextHwnd))
				If $oParentCtrl.Type = "Tab" Then
					;get tab #
					Local $i = 0
					For $oTab In $oParentCtrl.Tabs
						If $oTab.Hwnd = Dec($textHwnd) Then
							$childSelected = True
							_GUICtrlTab_SetCurSel($oParentCtrl.Hwnd, $i)
						EndIf
						$i += 1
					Next
					_add_to_selected($oParentCtrl)
					_populate_control_properties_gui($oParentCtrl, Dec($textHwnd))
				ElseIf $oParentCtrl.Type = "Menu" Then
					$childSelected = True
;~ 					_add_to_selected($oParentCtrl)
					_populate_control_properties_gui($oCtrl, Dec($textHwnd))
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
		ConsoleWrite($oCtrlMove.Name & @CRLF)
		$oCtrls.moveUp($oCtrlMove)

		_refreshGenerateCode()
		_formObjectExplorer_updateList()

		_setLvSelected($oCtrlMove)
	Else
		ConsoleWrite($oCtrlMove & @CRLF)
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
		ConsoleWrite($oCtrlMove.Name & @CRLF)
		$oCtrls.moveDown($oCtrlMove)

		_refreshGenerateCode()
		_formObjectExplorer_updateList()

		_setLvSelected($oCtrlMove)
	Else
		ConsoleWrite($oCtrlMove & @CRLF)
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

			Local $hParent = _GUICtrlTreeView_GetParentHandle($lvObjects, $hItem)
			If $hParent <> 0 Then    ;this is a child
				Local $aParentText = _GUICtrlTreeView_GetText($lvObjects, $hParent)
				Local $aParentStrings = StringSplit($aParentText, @TAB)
				Local $ParentTextHwnd = StringTrimRight(StringTrimLeft($aParentStrings[2], 7), 1)
				$oCtrl = $oCtrls.get(Dec($ParentTextHwnd))
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

	Local $lvItem, $lvMenu, $lvMenuDelete, $childItem, $tabMenu, $tabMenuDelete, $lvMenuNewTab, $lvMenuDeleteTab, $sName
	Local $lvMenuNewMenuItem, $menuItemMenu
	_GUICtrlTreeView_DeleteAll($lvObjects)
	For $oCtrl In $oCtrls.ctrls
		$sName = $oCtrl.Name
		If $sName = "" Then
			$sName = $oCtrl.Type & "*"
		EndIf

		$lvItem = GUICtrlCreateTreeViewItem($sName & "       " & @TAB & "(HWND: " & Hex($oCtrl.Hwnd) & ")", $lvObjects)
		GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

		$lvMenu = GUICtrlCreateContextMenu($lvItem)
		$lvMenuDelete = GUICtrlCreateMenuItem("Delete", $lvMenu)
		GUICtrlSetOnEvent($lvMenuDelete, "_onLvObjectsDeleteMenu")

		If $oCtrl.Type = "Tab" Then
			$lvMenuNewTab = GUICtrlCreateMenuItem("New Tab", $lvMenu)
			$lvMenuDeleteTab = GUICtrlCreateMenuItem("Delete Tab", $lvMenu)
			GUICtrlSetOnEvent($lvMenuNewTab, "_new_tab")
			GUICtrlSetOnEvent($lvMenuDeleteTab, "_delete_tab")

			For $oTab In $oCtrl.Tabs
				$childItem = GUICtrlCreateTreeViewItem($oTab.Name & "       " & @TAB & "(HWND: " & Hex($oTab.Hwnd) & ")", $lvItem)
				GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

				$tabMenu = GUICtrlCreateContextMenu($childItem)
				$tabMenuDelete = GUICtrlCreateMenuItem("Delete Tab", $tabMenu)
				GUICtrlSetOnEvent($tabMenuDelete, "_delete_tab")

				_GUICtrlTreeView_Expand($lvObjects, $lvItem)
			Next
		ElseIf $oCtrl.Type = "Menu" Then
			$lvMenuNewMenuItem = GUICtrlCreateMenuItem("New menu item", $lvMenu)
			GUICtrlSetOnEvent($lvMenuNewMenuItem, "_new_menuItem")

			For $oMenuItem In $oCtrl.MenuItems
				$childItem = GUICtrlCreateTreeViewItem($oMenuItem.Name & "       " & @TAB & "(HWND: " & Hex($oMenuItem.Hwnd) & ")", $lvItem)
				GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

				$menuItemMenu = GUICtrlCreateContextMenu($childItem)
				$menuItemMenuDelete = GUICtrlCreateMenuItem("Delete menu item", $menuItemMenu)
				GUICtrlSetOnEvent($menuItemMenuDelete, "_delete_menuItem")

				_GUICtrlTreeView_Expand($lvObjects, $lvItem)
			Next
		EndIf
	Next

	If StringStripWS($count, $STR_STRIPALL) = "" Then $count = 0
	GUICtrlSetData($labelObjectCount, "Object Count: " & $count)

	If $prevSelected <> -1 Then
		_setLvSelectedHwnd($prevSelected)
	EndIf
EndFunc   ;==>_formObjectExplorer_updateList
