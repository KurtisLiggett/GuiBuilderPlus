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

	Local $hWin = $hGUI
;~ 	If IsHWnd($hFormGenerateCode) Then
;~ 		$hWin = $hFormGenerateCode
;~ 	EndIf

	Local $currentWinPos = WinGetPos($hWin)
	Local $x = $currentWinPos[0] + $currentWinPos[2]
	Local $y = $currentWinPos[1]

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
;~ 	_GUICtrlListView_SetColumnWidth($lvObjects, 0, $w / 2 - 20 - 5) ; sets column width

	;bottom section
	$labelObjectCount = GUICtrlCreateLabel("Object Count: " & $oCtrls.count, 5, $h - 18 - $titleBarHeight, $w - 20)

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
;~ 	Local $aIndices = _GUICtrlListView_GetSelectedIndices($lvObjects, True)
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
					For $oTab in $oParentCtrl.Tabs
						If $oTab.Hwnd = Dec($textHwnd) Then
							$childSelected = True
							_GUICtrlTab_SetCurSel($oParentCtrl.Hwnd, $i)
						EndIf
						$i += 1
					Next
					_add_to_selected($oParentCtrl)
					_populate_control_properties_gui($oParentCtrl, Dec($textHwnd))
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
#EndRegion events


;------------------------------------------------------------------------------
; Title...........: _formObjectExplorer_updateList
; Description.....: update list of objects
;------------------------------------------------------------------------------
Func _formObjectExplorer_updateList()
	If Not IsHWnd($hFormObjectExplorer) Then Return

	Local $count = $oCtrls.count
	Local $aList[$count]


	Local $lvItem, $lvMenu, $lvMenuDelete, $childItem
	_GUICtrlTreeView_DeleteAll($lvObjects)
	For $oCtrl in $oCtrls.ctrls
		$lvItem = GUICtrlCreateTreeViewItem($oCtrl.Name & "       " & @TAB & "(HWND: " & Hex($oCtrl.Hwnd) & ")", $lvObjects)
		GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

		$lvMenu = GUICtrlCreateContextMenu($lvItem)
		$lvMenuDelete = GUICtrlCreateMenuItem("Delete", $lvMenu)
		;menu events
		GUICtrlSetOnEvent($lvMenuDelete, "_onLvObjectsDeleteMenu")

		If $oCtrl.Type = "Tab" Then
			Local $tabCount = $oCtrl.TabCount
			Local $tabs = $oCtrl.Tabs
			Local $tab

			For $j = 1 To $tabCount
				ConsoleWrite($j & @CRLF)
				$tab = $tabs[$j]
				$childItem = GUICtrlCreateTreeViewItem($tab.Name & "       " & @TAB & "(HWND: " & Hex($tab.Hwnd) & ")", $lvItem)
				GUICtrlSetOnEvent(-1, "_onLvObjectsItem")

;~ 				$lvMenu = GUICtrlCreateContextMenu($childItem)
;~ 				$lvMenuDelete = GUICtrlCreateMenuItem("Delete", $lvMenu)
;~ 				;menu events
;~ 				GUICtrlSetOnEvent($lvMenuDelete, "_onLvObjectsDeleteMenu")
				_GUICtrlTreeView_Expand($lvObjects, $lvItem)
			Next
		EndIf
	Next

	If StringStripWS($count, $STR_STRIPALL) = "" Then $count = 0
	GUICtrlSetData($labelObjectCount, "Object Count: " & $count)
EndFunc   ;==>_formObjectExplorer_updateList
