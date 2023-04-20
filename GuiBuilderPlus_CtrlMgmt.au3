; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_CtrlMgmt.au3
; Description ...: Control creation and management
; ===============================================================================================================================


;------------------------------------------------------------------------------
; Title...........: _create_ctrl
; Description.....: create new control and add it to the ctrls object
; Called by.......: Draw with mouse; Paste
;------------------------------------------------------------------------------
Func _create_ctrl($oCtrl = 0, $bUseName = False, $startX = -1, $startY = -1, $hParent = -1, $bDuplicate = False)
	;only allow 1 tab control
	If $oCtrls.CurrentType = "Tab" Then
		If $oCtrls.getTypeCount("Tab") > 0 Then
			Return 0
		EndIf
	EndIf

	Local $oNewControl
	Local $isPaste = False

	Local $cursor_pos = _mouse_snap_pos()

	Switch IsObj($oCtrl)
		Case True
			$isPaste = True
			$oNewControl = $oCtrl

		Case False

			If $startX <> -1 Then $cursor_pos[0] = $startX
			If $startY <> -1 Then $cursor_pos[1] = $startY

			; control will be inserted at current mouse position UNLESS out-of-bounds mouse
			If $oOptions.pasteAtMouse Or $oCtrls.mode = $mode_drawing Then
				If _cursor_out_of_bounds($cursor_pos) Then
					ContinueCase
				EndIf
			Else
				$cursor_pos[0] = 0
				$cursor_pos[1] = 0
			EndIf

			$oNewControl = $oCtrls.createNew()

			$oNewControl.HwndCount = 1
			$oNewControl.Type = $oCtrls.CurrentType
			$oNewControl.Left = $cursor_pos[0]
			$oNewControl.Top = $cursor_pos[1]
			$oNewControl.Global = $GUI_CHECKED
			$oNewControl.FontSize = 8.5

	EndSwitch

	;at least 1 control, enable menu item wipe
	GUICtrlSetState($menu_wipe, $GUI_ENABLE)

	Local Const $count = $oCtrls.count
	Local $name

	;use next available name
	Local $found = True
	Local $j = 0
	While $found
		$found = False
		$j += 1
		$name = $oNewControl.Type & "_" & $j

		If $count >= 1 Then
			For $oCtrl In $oCtrls.ctrls.Items()

				If $oCtrl.Name = $name Then
					$found = True
					ExitLoop
				EndIf
			Next
		Else
			$found = False
		EndIf
	WEnd
	If Not $bUseName Then
		$oNewControl.Name = $name
	EndIf

	Switch $oNewControl.Type
		Case "Updown"
			$oNewControl.Text = "0"
		Case Else
			;if copy+paste, use same text
			If Not $isPaste Then
				$oNewControl.Text = $oNewControl.Type & " " & $j
			EndIf
	EndSwitch

	;check if pasting into Tab or Group
	$oNewControl.CtrlParent = 0
	If $isPaste Then
		For $oThisCtrl In $oSelected.ctrls.Items()
			Switch $oThisCtrl.Type
				Case "Tab"
					$hParent = $oThisCtrl.Hwnd
					ExitLoop

				Case "Group"
					$hParent = $oThisCtrl.Hwnd
					ExitLoop

			EndSwitch
		Next
	EndIf

	;if tab parent, then switch to that tab
	Local $tabChild = False
	If $hParent <> -1 Then
		For $oThisCtrl In $oCtrls.ctrls.Items()
			If $oThisCtrl.Hwnd = $hParent Then
				Switch $oThisCtrl.Type
					Case "Tab"
						Local $iTabFocus = _GUICtrlTab_GetCurSel($oThisCtrl.Hwnd)
						If $iTabFocus >= 0 Then
							Local $tabID = $oThisCtrl.Tabs.at($iTabFocus)
							GUISwitch($hGUI, $tabID)
							$tabChild = True
						EndIf
						ExitLoop

;~ 					Case "Group"
;~ 						Local $iTabFocus = _GUICtrlTab_GetCurSel($oThisCtrl.Hwnd)
;~ 						ExitLoop

				EndSwitch
			EndIf
		Next
	EndIf

	Switch $oNewControl.Type
		Case "Button"
			$oNewControl.Hwnd = GUICtrlCreateButton($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl, $hParent)

			$bStatusNewMessage = True
			_GUICtrlStatusBar_SetText($hStatusbar, "new button")

		Case "Group"
			$oNewControl.Hwnd = GUICtrlCreateGroup($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl, $hParent)

		Case "Checkbox"
			$oNewControl.Height = 20

			$oNewControl.Hwnd = GUICtrlCreateCheckbox($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
			If $isPaste Then
				If $oNewControl.Background <> -1 Then
					GUICtrlSetBkColor($oNewControl.Hwnd, $oNewControl.Background)
				EndIf
			EndIf

			$oCtrls.add($oNewControl, $hParent)

		Case "Radio"
			$oNewControl.Height = 20

			$oNewControl.Hwnd = GUICtrlCreateRadio($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
			If $isPaste Then
				If $oNewControl.Background <> -1 Then
					GUICtrlSetBkColor($oNewControl.Hwnd, $oNewControl.Background)
				EndIf
			EndIf

			$oCtrls.add($oNewControl, $hParent)

		Case "Edit"
			$oNewControl.Hwnd = GUICtrlCreateEdit('', $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

;~ 			GUICtrlSetState($oNewControl.Hwnd, $GUI_DISABLE)

			$oCtrls.add($oNewControl, $hParent)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

;~ 			Return $oNewControl

		Case "Input"
			$oNewControl.Hwnd = GUICtrlCreateInput($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

;~ 			GUICtrlSetState($oNewControl.Hwnd, $GUI_DISABLE)

			$oCtrls.add($oNewControl, $hParent)

		Case "Label"
			$oNewControl.Hwnd = GUICtrlCreateLabel($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
			If $isPaste Then
				If $oNewControl.Background <> -1 Then
					GUICtrlSetBkColor($oNewControl.Hwnd, $oNewControl.Background)
				EndIf
				If $oNewControl.Color <> -1 Then
					GUICtrlSetColor($oNewControl.Hwnd, $oNewControl.Color)
				EndIf
			EndIf

			$oCtrls.add($oNewControl, $hParent)

		Case "List"
			$oNewControl.Hwnd = GUICtrlCreateList($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

;~ 			GUICtrlSetState($oNewControl.Hwnd, $GUI_DISABLE)

			$oCtrls.add($oNewControl, $hParent)

		Case "Combo"
			$oNewControl.Height = 20

			$oNewControl.Hwnd = GUICtrlCreateCombo('', $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl, $hParent)

		Case "Date"
			$oNewControl.Hwnd = GUICtrlCreateDate('', $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl, $hParent)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

;~ 			Return $oNewControl

		Case "Slider"
			$oNewControl.Hwnd = _GuiCtrlCreateSlider($oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height, $oNewControl.Height)

			$oCtrls.add($oNewControl, $hParent)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

;~ 			Return $oNewControl

		Case "Tab"
			;create main tab control
			$oNewControl.Hwnd = GUICtrlCreateTab($oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
			GUICtrlSetOnEvent(-1, "_onCtrlTabSwitch")

			$oCtrls.add($oNewControl, $hParent)

			GUISwitch($hGUI)

			_hide_grid($background)
			If BitAND(GUICtrlRead($menu_show_grid), $GUI_CHECKED) = $GUI_CHECKED Then
				_show_grid($background, $oMain.Width, $oMain.Height)
			EndIf

		Case "TreeView"
			$oNewControl.Hwnd = GUICtrlCreateTreeView($oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			GUICtrlCreateTreeViewItem($oNewControl.Text, $oNewControl.Hwnd)

			$oCtrls.add($oNewControl, $hParent)

		Case "Updown"
			$oNewControl.HwndCount = 2

			$oNewControl.Height = 20

			$oNewControl.Hwnd1 = GUICtrlCreateInput($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
			$oNewControl.Hwnd = $oNewControl.Hwnd1
			$oNewControl.Hwnd2 = GUICtrlCreateUpdown($oNewControl.Hwnd1)

			$oCtrls.add($oNewControl, $hParent)

		Case "Progress"
			$oNewControl.Hwnd = GUICtrlCreateProgress($oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			GUICtrlSetData($oNewControl.Hwnd, 100)

			$oCtrls.add($oNewControl, $hParent)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

;~ 			Return $oNewControl

		Case "Pic"
			$oNewControl.Hwnd = GUICtrlCreatePic($samplebmp, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
			GUICtrlSetImage($oNewControl.Hwnd, $samplebmp)

			$oCtrls.add($oNewControl, $hParent)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

;~ 			Return $oNewControl

		Case "Avi"
			$oNewControl.Hwnd = GUICtrlCreateAvi($sampleavi, 0, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height, $ACS_AUTOPLAY)

			$oCtrls.add($oNewControl, $hParent)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

;~ 			Return $oNewControl

		Case "Icon"
			$oNewControl.Hwnd = GUICtrlCreateIcon($iconset, 0, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl, $hParent)

;~ 			Return $oNewControl

		Case "Menu"
			$oNewControl.Hwnd = GUICtrlCreateMenu("Menu 1")
			$oNewControl.Left = -1
			$oNewControl.Top = -1
			$oNewControl.Width = 0
			$oNewControl.Height = 0

			$oCtrls.add($oNewControl, $hParent)

			Local $cmenu = GUICtrlCreateContextMenu($oNewControl.Hwnd)
			GUICtrlCreateMenuItem("test Item", $cmenu)

			Local $aWinPos = WinGetClientSize($hGUI)
;~ 			WinSetTitle($hGUI, "", $oMain.AppName & " - Form (" & $aWinPos[0] & ", " & $aWinPos[1] & ")")
			$oMain.Height = $aWinPos[1]

		Case "IP"
			$oNewControl.Text = ""
			$oNewControl.Hwnd = _GUICtrlIpAddress_Create($hGUI, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
			$oCtrls.add($oNewControl)
			_GUICtrlIpAddress_Set($oNewControl.Hwnd, $oNewControl.Text)

		Case "ListView"
			$oNewControl.Hwnd = GUICtrlCreateListView($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

;~ 			GUICtrlSetState($oNewControl.Hwnd, $GUI_DISABLE)

			$oCtrls.add($oNewControl, $hParent)

		Case "Graphic"
			$oNewControl.Hwnd = GUICtrlCreateGraphic($oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
			GUICtrlSetGraphic($oNewControl.Hwnd, $GUI_GR_RECT, 0, 0, $oNewControl.Width, $oNewControl.Height)
			GUICtrlSetGraphic($oNewControl.Hwnd, $GUI_GR_REFRESH)
			GUICtrlSetGraphic($background, $GUI_GR_REFRESH)
;~ 			GUISwitch($hGUI)

			$oCtrls.add($oNewControl, $hParent)

	EndSwitch

	$oMain.hasChanged = True

	If $tabChild Then
		GUICtrlCreateTabItem('')
		GUISwitch($hGUI)
	EndIf

	Switch IsObj($oCtrl)
		Case True    ;paste from existing object
			GUICtrlSetData($oNewControl.Hwnd, $oNewControl.Text)

		Case False    ;new object
			$oNewControl.Text = $oNewControl.Text
	EndSwitch

	GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

	GuiCtrlSetOnTop($oNewControl.Hwnd)

	Return $oNewControl
EndFunc   ;==>_create_ctrl


Func _GuiCtrlCreateSlider(Const $left, Const $top, Const $width, Const $height, $style)
	Local Const $ref = GUICtrlCreateSlider($left, $top, $width, $height)

	If $style <= 0 Then
		$style = 0x50020001 ; the default style
	EndIf

	GUICtrlSetStyle($ref, BitOR($style, 0x040)) ; TBS_FIXEDLENGTH

	Local $size = $height - 20

	If $width - 20 < $size Then
		$size = $width - 20
	EndIf

	GUICtrlSendMsg($ref, 27 + 0x0400, $size, 0) ; TBS_SETTHUMBLENGTH

	Return $ref
EndFunc   ;==>_GuiCtrlCreateSlider

Func _onNewTab()
	_new_tab()
EndFunc   ;==>_onNewTab

Func _new_tab($loadGUI = False)
	Local $oCtrl

	For $oCtrl In $oCtrls.ctrls.Items()
		If $oCtrl.Type = "Tab" Then
			ExitLoop
		EndIf
	Next

	$oCtrl.TabCount = $oCtrl.TabCount + 1
	Local $tab = _objCtrl($oCtrls)
	$tab.Hwnd = GUICtrlCreateTabItem("Tab" & $oCtrl.TabCount)
	GUICtrlCreateTabItem("")
	$tab.Text = "Tab" & $oCtrl.TabCount
	$tab.Name = "TabItem_" & $oCtrl.TabCount
	$tab.Type = "TabItem"

	;add control to the ctrls object
	$oCtrls.add($tab)

	;add tab sheet control ID to tab list for tracking
	$oCtrl.Tabs.add($tab.Hwnd)

	_GUICtrlTab_SetCurSel($oCtrl.Hwnd, $oCtrl.TabCount - 1)

	If Not $loadGUI Then
		_refreshGenerateCode()
		_formObjectExplorer_updateList()
	EndIf

	Return $oCtrl.TabCount
EndFunc   ;==>_new_tab


Func _onCtrlTabSwitch()
;~ 	_remove_all_from_selected()
	_tabClearInactiveSelection(@GUI_CtrlId)
EndFunc   ;==>_onCtrlTabSwitch

Func _tabClearInactiveSelection($Hwnd)
	Local $oCtrl = $oCtrls.get($Hwnd)
	Local $oTab

	Local $iTabFocus = _GUICtrlTab_GetCurSel($Hwnd)
	Local $tabFocusID = $oCtrl.Tabs.at($iTabFocus)

	For $hTab In $oCtrl.Tabs
		If $hTab = $tabFocusID Then ContinueLoop

		$oTab = $oCtrls.get($hTab)
		For $oTabCtrl In $oTab.ctrls.Items()
			_remove_from_selected($oTabCtrl)
		Next
	Next
	GUISwitch($hGUI)
EndFunc   ;==>_tabClearInactiveSelection

Func _onDeleteTab()
	_delete_tab()
EndFunc   ;==>_onDeleteTab

Func _delete_tab()
	Local $oCtrl

	For $oCtrl In $oCtrls.ctrls.Items()
		If $oCtrl.Type = "Tab" Then
			ExitLoop
		EndIf
	Next

	Local $iTabFocus = _GUICtrlTab_GetCurSel($oCtrl.Hwnd)

	If $iTabFocus >= 0 Then
		$tabID = $oCtrl.Tabs.at($iTabFocus)
		$oTabItem = $oCtrls.get($tabID)
		For $oTabCtrl In $oTabItem.ctrls.Items()
			_delete_ctrl($oTabCtrl)
		Next

		_GUICtrlTab_DeleteItem($oCtrl.Hwnd, $iTabFocus)

		;remove from controls object
		$oCtrls.ctrls.remove($oTabItem.Hwnd)

		;remove from tab tracker
		$oCtrl.Tabs.remove($iTabFocus)

		$oCtrl.TabCount = $oCtrl.TabCount - 1
		_GUICtrlTab_SetCurSel($oCtrl.Hwnd, 0)
	Else
		_delete_selected_controls()
	EndIf

	GUISwitch($hGUI)
	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_delete_tab

Func _updateIP($oCtrl)
	Local $prevKey = $oCtrl.Hwnd
	_GUICtrlIpAddress_Destroy(HWnd($oCtrl.Hwnd))
	$oCtrl.Hwnd = _GUICtrlIpAddress_Create($hGUI, $oCtrl.Left, $oCtrl.Top, $oCtrl.Width, $oCtrl.Height)
	_GUICtrlIpAddress_Set($oCtrl.Hwnd, $oCtrl.Text)
	$oCtrl.parent.ctrls.Key($prevKey) = $oCtrl.Hwnd
;~ 	_WinAPI_SetWindowPos($oCtrl.Hwnd, $HWND_TOP, $oCtrl.Left, $oCtrl.Top, $oCtrl.Width, $oCtrl.Height, $SWP_SHOWWINDOW)
EndFunc   ;==>_updateIP


Func _new_menuItem()
	_new_menuItemCreate()
EndFunc   ;==>_new_menuItem

Func _new_menuItemCreate($oParent = 0, $loadGUI = False)
	Local $oCtrl, $hSelected
	If Not IsObj($oParent) Then
		$hSelected = _getLvSelectedHwnd()
		$oCtrl = $oCtrls.get($hSelected)
		If Not IsObj($oCtrl) Then Return -1
	Else
		$oCtrl = $oParent
		$hSelected = $oParent.Hwnd
	EndIf

	Local $newCount = $oCtrl.MenuItems.count + 1
	Local $MenuItem = _objCtrl($oCtrl)
	$MenuItem.Hwnd = GUICtrlCreateMenuItem("MenuItem" & $newCount, $hSelected)
	$MenuItem.Text = "MenuItem" & $newCount
	$MenuItem.Name = "MenuItem_" & $newCount
	$oCtrl.MenuItems.add($MenuItem)

	_GUICtrlTab_SetCurSel($oCtrl.Hwnd, $newCount - 1)

	If Not $loadGUI Then
		_refreshGenerateCode()
		_formObjectExplorer_updateList()
	EndIf
EndFunc   ;==>_new_menuItemCreate


Func _delete_menuItem()
	Local $hSelected = _getLvSelectedHwnd()
	Local $oCtrl = $oCtrls.get($hSelected)
	If Not IsObj($oCtrl) Then Return -1

	Local $oParent
	For $oCtrl In $oCtrls.ctrls.Items()
		If $oCtrl.Type = "Menu" Then
			For $oMenuItem In $oCtrl.MenuItems
				If $oMenuItem.Hwnd = $hSelected Then
					$oParent = $oCtrl
					ExitLoop 2
				EndIf
			Next
		EndIf
	Next

	If Not IsObj($oParent) Then Return -1

	Local $i = 0
	For $oMenuItem In $oParent.MenuItems
		If $oMenuItem.Hwnd = $hSelected Then
			$oParent.MenuItems.remove($i)
			_GUICtrlTab_SetCurSel($oParent.Hwnd, 0)
			ExitLoop
		EndIf
		$i += 1
	Next
	GUICtrlDelete($hSelected)

	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_delete_menuItem


Func _control_type()
	$oCtrls.CurrentType = GUICtrlRead(@GUI_CtrlId, 1)

	$oCtrls.mode = $mode_draw
EndFunc   ;==>_control_type


;------------------------------------------------------------------------------
; Title...........: _delete_ctrl
; Description.....: delete control from GUI and remove the data object
;------------------------------------------------------------------------------
Func _delete_ctrl(Const $oCtrl, $clear = False)
	If $oCtrl.Locked And Not $clear Then Return

	GUISwitch($hGUI)
	Switch $oCtrl.Type
		Case "Updown"
			GUICtrlDelete($oCtrl.Hwnd1)
			GUICtrlDelete($oCtrl.Hwnd2)

		Case "IP"
			_GUICtrlIpAddress_Destroy(HWnd($oCtrl.Hwnd))

		Case "Tab"
			For $hTabItem In $oCtrl.Tabs
;~ 				_delete_ctrl($oCtrls.get($hTabItem))
				_delete_tab()
			Next
			GUICtrlDelete($oCtrl.Hwnd)

		Case "Group"
			For $oThisCtrl In $oCtrl.ctrls.Items()
				_delete_ctrl($oThisCtrl)
			Next
			GUICtrlDelete($oCtrl.Hwnd)

		Case Else
			GUICtrlDelete($oCtrl.Hwnd)
	EndSwitch
	GUISwitch($hGUI)

	$oCtrls.remove($oCtrl.Hwnd)
	$oSelected.remove($oCtrl.Hwnd)

	$oMain.hasChanged = True
EndFunc   ;==>_delete_ctrl


#Region ; selection and clipboard management
;------------------------------------------------------------------------------
; Title...........: _vector_magnitude
; Description.....: calculate the distance between 2 points
;------------------------------------------------------------------------------
Func _vector_magnitude(Const $x1, Const $x2, Const $y1, Const $y2)
	Return Sqrt((($x1 - $y1) ^ 2) + (($x2 - $y2) ^ 2))
EndFunc   ;==>_vector_magnitude


;------------------------------------------------------------------------------
; Title...........: _left_top_union_rect
; Description.....: gets the xy coords of the union of the selected controls rectangles
;------------------------------------------------------------------------------
Func _left_top_union_rect($oObjCtrls = 0)
	If Not IsObj($oObjCtrls) Then
		$oObjCtrls = $oSelected
	EndIf

	Local $sel_ctrl

	Local $smallest = _objCreateRect()

	$smallest.Left = $oObjCtrls.getFirst().Left
	$smallest.Top = $oObjCtrls.getFirst().Top

	For $oCtrl In $oObjCtrls.ctrls.Items()

		If Int($oCtrl.Left) < Int($smallest.Left) Then
			$smallest.Left = $oCtrl.Left
		EndIf

		If Int($oCtrl.Top) < Int($smallest.Top) Then
			$smallest.Top = $oCtrl.Top
		EndIf
	Next

	For $oCtrl In $oObjCtrls.ctrls.Items()

		If Int(($oCtrl.Left - $smallest.Left) + $oCtrl.Width) > Int($smallest.Width) Then
			$smallest.Width = Int(($oCtrl.Left - $smallest.Left) + $oCtrl.Width)
		EndIf

		If Int(($oCtrl.Top - $smallest.Top) + $oCtrl.Height) > Int($smallest.Height) Then
			$smallest.Height = Int(($oCtrl.Top - $smallest.Top) + $oCtrl.Height)
		EndIf
	Next

	Return $smallest
EndFunc   ;==>_left_top_union_rect


;------------------------------------------------------------------------------
; Title...........: _copy_selected
; Description.....: find top left corner,
;					put all selected controls into an array, (necessary?)
;					add the array to the clipboard object
;------------------------------------------------------------------------------
Func _copy_selected()
	Local Const $sel_count = $oSelected.count

	GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
	$oCtrls.mode = $mode_default

	Switch $sel_count >= 1
		Case True
			$oClipboard.removeAll()


			Local Const $smallest = _left_top_union_rect()

			Local Const $selected = _selected_to_array($sel_count, $smallest)

			_selected_to_clipboard($selected, $sel_count)

	EndSwitch
EndFunc   ;==>_copy_selected


;------------------------------------------------------------------------------
; Title...........: _cut_selected
; Description.....: copy selected, then delete
;------------------------------------------------------------------------------
Func _cut_selected()
	_copy_selected()
	_delete_selected_controls()
EndFunc   ;==>_cut_selected


;------------------------------------------------------------------------------
; Title...........: _selected_to_array
; Description.....: put all selected controls into an array, (necessary?)
;------------------------------------------------------------------------------
Func _selected_to_array(Const $sel_count, Const $smallest)
	Local $selected[$sel_count][2] ; second dimension is magnitude of the control's rectangle

	Local $i = 0
	For $oCtrl In $oSelected.ctrls.Items()
		;create a copy, so we don't later accidentally overwrite the original!
		$selected[$i][0] = $oCtrl
		$selected[$i][1] = _vector_magnitude($smallest.Left, $smallest.Top, $oCtrl.Left, $oCtrl.Top)
		$i += 1
	Next

	Return $selected
EndFunc   ;==>_selected_to_array


;------------------------------------------------------------------------------
; Title...........: _selected_to_clipboard
; Description.....: add selected controls to clipboard object
;------------------------------------------------------------------------------
Func _selected_to_clipboard(Const $selected, Const $sel_count)
	$oClipboard.removeAll()
	Local $i = 0
	For $oCtrl In $oSelected.ctrls.Items()
		$oClipboard.add($oSelected.getCopy($oCtrl.Hwnd))
		$i += 1
	Next
EndFunc   ;==>_selected_to_clipboard


;------------------------------------------------------------------------------
; Title...........: _PasteSelected
; Description.....: paste selected controls
;------------------------------------------------------------------------------
Func _PasteSelected($bDuplicate = False, $bAtMouse = False)
	GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)

	Local Const $clipboard_count = $oClipboard.count
	Local $aNewCtrls[$clipboard_count]

	;get the top left point
	Local $topLeftRect = _left_top_union_rect($oClipboard)

	_SendMessage($hGUI, $WM_SETREDRAW, False)
	Switch $clipboard_count >= 1
		Case True
			Local $oNewCtrl, $i = 0
			Local $iPosX = -1, $iPosY = -1

			For $oCtrl In $oClipboard.ctrls.Items()
				;create a copy, so we don't overwrite the original!
				$oNewCtrl = $oClipboard.getCopy($oCtrl.Hwnd)

				If Not $oOptions.pasteAtMouse And Not $bDuplicate Then
					$oNewCtrl.Left = 0
					$oNewCtrl.Top = 0
				ElseIf $bDuplicate Then
					$oNewCtrl.Left += 20
					$oNewCtrl.Top += 20
				ElseIf $bAtMouse Then
					$oNewCtrl.Left = $oMouse.StartX
					$oNewCtrl.Top = $oMouse.StartY
				Else
					Local $mouse_pos = _mouse_snap_pos()
					$oNewCtrl.Left = ($mouse_pos[0] - $topLeftRect.Left) + $oNewCtrl.Left
					$oNewCtrl.Top = ($mouse_pos[1] - $topLeftRect.Height) + ($oNewCtrl.Top - $topLeftRect.Top)
;~ 					$iPosX = $oMouse.X
;~ 					$iPosY = $oMouse.Y
				EndIf

				$aNewCtrls[$i] = _create_ctrl($oNewCtrl, 0, $iPosX, $iPosY, -1, $bDuplicate)

				$i += 1
			Next

			;now select the controls
			$i = 0
			For $oCtrl In $aNewCtrls
				If $i = 0 Then    ;select first item
					_add_to_selected($aNewCtrls[$i], True, True)
;~ 					_populate_control_properties_gui($oNewCtrl)
				Else    ;add to selection
					_add_to_selected($aNewCtrls[$i], False, False)
				EndIf

				$i += 1
			Next
	EndSwitch

	;update the undo action stack
	Local $oAction = _objAction()
	$oAction.action = $action_pasteCtrl
	$oAction.ctrls = $aNewCtrls
	_updateActionStacks($oAction)

;~ 	If Not $bDuplicate And Not $bAtMouse And $setting_paste_pos And $oSelected.count > 0 Then
;~ 		$oCtrls.mode = $mode_paste
;~ 	EndIf

;~ 	If $bDuplicate Then
;~ 		For $i = 0 To UBound($aNewCtrls) - 1
;~ 			$oNewCtrl = $aNewCtrls[$i]

;~ 			If $i = 0 Then    ;select first item
;~ 				_add_to_selected($oNewCtrl)
;~ 				_populate_control_properties_gui($oNewCtrl)
;~ 			Else    ;add to selection
;~ 				_add_to_selected($oNewCtrl, False)
;~ 			EndIf
;~ 		Next
;~ 	EndIf

	_SendMessage($hGUI, $WM_SETREDRAW, True)
	_WinAPI_RedrawWindow($hGUI)

	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_PasteSelected


;------------------------------------------------------------------------------
; Title...........: _DuplicateSelected
; Description.....: copy then paste selected controls at an offset
;------------------------------------------------------------------------------
Func _DuplicateSelected()
	If $oSelected.count < 1 Then Return
	;copy selected to clipboard
	_copy_selected()

	;paste clipboard with duplicate flag
	_PasteSelected(True)
EndFunc   ;==>_DuplicateSelected
#EndRegion ; selection and clipboard management


#Region ; selection
Func _display_selected_tooltip()
	Local $tooltip

	Local Const $count = $oSelected.count

	If $oSelected.count < 5 Then
		For $oCtrl In $oSelected.ctrls.Items()
			$tooltip &= $oCtrl.Name & ": X:" & $oCtrl.Left & ", Y:" & $oCtrl.Top & ", W:" & $oCtrl.Width & ", H:" & $oCtrl.Height & @CRLF
		Next

		ToolTip(StringTrimRight($tooltip, 2))
	Else
		ToolTip("")
	EndIf

EndFunc   ;==>_display_selected_tooltip

Func _control_intersection(Const $oCtrl, Const $oRect)
	If $oCtrl.Type = "TabItem" Then Return False
	Local $aMousePos = MouseGetPos()
	Local $returnVal

	If $aMousePos[0] < $oMouse.StartX Then    ;right-to-left
		$returnVal = _CtrlCrossRect($oCtrl.Left, $oCtrl.Top, $oCtrl.Width, $oCtrl.Height, $oRect.Left, $oRect.Top, $oRect.Width, $oRect.Height)
	Else    ;left-to-right
		$returnVal = _CtrlInRect($oCtrl.Left, $oCtrl.Top, $oCtrl.Width, $oCtrl.Height, $oRect.Left, $oRect.Top, $oRect.Width, $oRect.Height)
	EndIf

	If $oCtrl.CtrlParent <> 0 Then
		If $oCtrls.get($oCtrl.CtrlParent).Type = "TabItem" Then
			Local $TabHwnd = $oCtrls.get($oCtrl.CtrlParent).CtrlParent
			Local $iTabFocus = _GUICtrlTab_GetCurSel($TabHwnd)

			If $iTabFocus >= 0 Then
				Local $oTabCtrl = $oCtrls.get($TabHwnd)
				Local $iTabFocusID = $oTabCtrl.Tabs.at($iTabFocus)
				If $iTabFocusID <> $oCtrl.CtrlParent Then
					Return False
				EndIf
			EndIf
		EndIf
	EndIf

	Return $returnVal
EndFunc   ;==>_control_intersection

Func _group_select(Const $oCtrl)
	If $oCtrl.Type = "Group" Then
		_select_control_group($oCtrl)
		_set_current_mouse_pos()
;~ 		_hide_grippies()

		$oCtrls.mode = $mode_init_move

		Return True
	EndIf

	Return False
EndFunc   ;==>_group_select

Func _select_control_group(Const $oGroup)
	Local $oGroupRect = _objCreateRect()

	$oGroupRect.Left = $oGroup.Left
	$oGroupRect.Top = $oGroup.Top
	$oGroupRect.Width = $oGroup.Width
	$oGroupRect.Height = $oGroup.Height

	Local Const $count = $oCtrls.count
	For $oCtrl In $oCtrls.ctrls.Items()

		If _control_intersection($oCtrl, $oGroupRect) Then
			_add_to_selected($oCtrl, False)
		EndIf
	Next
EndFunc   ;==>_select_control_group

Func _add_to_selected(Const $oCtrl, Const $overwrite = True, Const $updateProps = True)
	If Not IsObj($oCtrl) Then
		Return
	EndIf

	Switch $overwrite
		Case True
			_remove_all_from_selected()

		Case False
			Switch $oSelected.exists($oCtrl.Hwnd)
				Case True
					Return SetError(1, 0, False)
			EndSwitch
	EndSwitch

	$oSelected.add($oCtrl)

;~ 	_enable_control_properties_gui()

	If $updateProps Then
		_showProperties($props_Ctrls)
		_populate_control_properties_gui($oCtrl)
	EndIf
	$oCtrl.grippies.show()

	Return True
EndFunc   ;==>_add_to_selected


;------------------------------------------------------------------------------
; Title...........: _selectAll
; Description.....: Select all controls
;------------------------------------------------------------------------------
Func _selectAll()
	Local $first = True

	_remove_all_from_selected()
	_SendMessage($hGUI, $WM_SETREDRAW, False)

	For $oCtrl In $oCtrls.ctrls.Items()
		$oSelected.add($oCtrl)
		$oCtrl.grippies.show()
	Next

	_showProperties($props_Ctrls)
	_populate_control_properties_gui($oCtrl)
	_SendMessage($hGUI, $WM_SETREDRAW, True)
	_WinAPI_RedrawWindow($hGUI)
	$oCtrls.mode = $mode_default
EndFunc   ;==>_selectAll
#EndRegion ; selection


;------------------------------------------------------------------------------
; Title...........: _add_remove_selected_control
; Description.....: while dragging selection rectangle, add controls as the
;					as the rectangle intersects with the controls
;------------------------------------------------------------------------------
Func _add_remove_selected_control(Const $oRect)
	For $oCtrl In $oCtrls.ctrls.Items()
		Switch _control_intersection($oCtrl, $oRect)
			Case True
				Switch _add_to_selected($oCtrl, False, False)
					Case True
;~ 						_populate_control_properties_gui($oCtrl)

						_display_selected_tooltip()
				EndSwitch

			Case False
				Switch _remove_from_selected($oCtrl, False)
					Case True
						Local $sel_count = $oSelected.count

						Switch $sel_count >= 1
							Case True
;~ 								_populate_control_properties_gui($oSelected.getLast())

;~ 							Case False
;~ 								_showProperties($props_Main)

						EndSwitch

						_display_selected_tooltip()
				EndSwitch
		EndSwitch
	Next
EndFunc   ;==>_add_remove_selected_control

Func _remove_all_from_selected()
	_SendMessage($hGUI, $WM_SETREDRAW, False)
	$oSelected.removeAll()
;~ 	_showProperties($props_Main)
	_SendMessage($hGUI, $WM_SETREDRAW, True)
	_WinAPI_RedrawWindow($hGUI)

	Return True
EndFunc   ;==>_remove_all_from_selected

Func _delete_selected_controls()
	_deleteCtrls()
EndFunc   ;==>_delete_selected_controls

Func _deleteCtrls($aCtrlsIn = 0)
	GUICtrlSetState($oMain.DefaultCursor, $GUI_CHECKED)
	$oCtrls.mode = $mode_default

	Local $undo
	If IsArray($aCtrlsIn) Then
		$undo = True
	Else
		$aCtrlsIn = $oSelected.ctrls.Items()
	EndIf
	Local $count = UBound($aCtrlsIn)

	Switch $count >= 1
		Case True
			_SendMessage($hGUI, $WM_SETREDRAW, False)

			Local $oAction = _objAction()
			$oAction.action = $action_deleteCtrl
			Local $aCtrls[UBound($aCtrlsIn)]

			Local $i
			For $oCtrl In $aCtrlsIn
				If Not $undo Then
					$aCtrls[$i] = $oSelected.getCopy($oCtrl.Hwnd)
				EndIf
				_delete_ctrl($oCtrl)
				$i += 1
			Next

			_formObjectExplorer_updateList()

			_recall_overlay()

			_set_default_mode()

			_refreshGenerateCode()

			If $count > 0 Then
				_populate_control_properties_gui($oSelected.getFirst())
				_showProperties($props_Ctrls)
			Else
				_showProperties($props_Main)
			EndIf

			_SendMessage($hGUI, $WM_SETREDRAW, True)
			_WinAPI_RedrawWindow($hGUI)

			If Not $undo Then
				;update the undo action stack
				$oAction.ctrls = $aCtrls
				_updateActionStacks($oAction)
			EndIf

			Return True

		Case False
			_showProperties($props_Main)
	EndSwitch

EndFunc   ;==>_deleteCtrls

Func _remove_from_selected(Const $oCtrl, $updateProps = True)
	If Not IsObj($oCtrl) Then
		Return
	EndIf

	Switch $oSelected.exists($oCtrl.Hwnd)
		Case False
			Return SetError(1, 0, False)
	EndSwitch

	For $oThisCtrl In $oSelected.ctrls.Items()
		Switch $oCtrl.Hwnd
			Case $oThisCtrl.Hwnd
				$oSelected.remove($oThisCtrl.Hwnd)
				ExitLoop
		EndSwitch
	Next

	$oCtrl.grippies.hide()

	If $updateProps Then
		If $oSelected.count > 0 Then
			_showProperties($props_Ctrls)
		Else
			_showProperties($props_Main)
		EndIf
	EndIf

	Return True
EndFunc   ;==>_remove_from_selected


;~ Func _hide_selected_controls()
;~ 	For $oCtrl In $oSelected.ctrls.Items()
;~ 		If Not $setting_show_control Then
;~ 			GUICtrlSetState($oCtrl.Hwnd, $GUI_HIDE)
;~ 		EndIf
;~ 	Next
;~ EndFunc   ;==>_hide_selected_controls

;~ Func _show_selected_controls()
;~ 	For $oCtrl In $oSelected.ctrls.Items()
;~ 		If Not $setting_show_control Then
;~ 			GUICtrlSetState($oCtrl.Hwnd, $GUI_SHOW)
;~ 		EndIf
;~ 	Next
;~ EndFunc   ;==>_show_selected_controls


#Region ; moving & resizing
Func _change_ctrl_size_pos(ByRef $oCtrl, $left, $top, $width, $height, $tabChild = False)
	If $oCtrl.Locked Then Return

	If $width < 1 Or $height < 1 Then
		Return
	EndIf

	If $left <> Default Then $oCtrl.Left = $left
	If $top <> Default Then $oCtrl.Top = $top
	If $width <> Default Then $oCtrl.Width = $width
	If $height <> Default Then $oCtrl.Height = $height

	Switch $oCtrl.Type
		Case "Updown"
			GUICtrlSetPos($oCtrl.Hwnd, $left, $top, $oCtrl.Width, $oCtrl.Height)

		Case "IP"
;~ 			WinMove($oCtrl.Hwnd, "", $left, $top, $width, $height)
			_updateIP($oCtrl)

		Case "Graphic"
			Local $prevKey = $oCtrl.Hwnd
			If $oCtrl.Hwnd <> 0 Then
				GUICtrlDelete($oCtrl.Hwnd)
			EndIf
			If $left = Default Then $left = $oCtrl.left
			If $top = Default Then $top = $oCtrl.top
			If $width = Default Then $width = $oCtrl.Width
			If $height = Default Then $height = $oCtrl.Height
			$oCtrl.Hwnd = GUICtrlCreateGraphic($left, $top, $width, $height)
			GUICtrlSetGraphic($oCtrl.Hwnd, $GUI_GR_RECT, 0, 0, $width, $height)
			GUICtrlSetGraphic($oCtrl.Hwnd, $GUI_GR_REFRESH)
			$oCtrl.parent.ctrls.Key($prevKey) = $oCtrl.Hwnd
			GUICtrlSetGraphic($background, $GUI_GR_REFRESH)

		Case Else
			GUICtrlSetPos($oCtrl.Hwnd, $left, $top, $width, $height)
	EndSwitch

	If Not $tabChild Then
		$oCtrl.grippies.show()

	EndIf
	$oMain.hasChanged = True
EndFunc   ;==>_change_ctrl_size_pos

Func _moveTabCtrls($oCtrl, $delta_x, $delta_y, $width, $height)
	If $oCtrl.Locked Then Return

	Local $oTab, $left, $top

	For $hTab In $oCtrl.Tabs
		$oTab = $oCtrls.get($hTab)
		For $oTabCtrl In $oTab.ctrls.Items()
			If $oSelected.exists($oTabCtrl.Hwnd) Then ContinueLoop

			If $delta_x = Default Then
				$left = Default
			Else
				$left = $oTabCtrl.Left - $delta_x
			EndIf

			If $delta_y = Default Then
				$top = Default
			Else
				$top = $oTabCtrl.Top - $delta_y
			EndIf

			_change_ctrl_size_pos($oTabCtrl, $left, $top, $width, $height, True)
		Next
	Next
	GUISwitch($hGUI)
EndFunc   ;==>_moveTabCtrls


Func _moveGroupCtrls($oCtrl, $delta_x, $delta_y, $width, $height)
	If $oCtrl.Locked Then Return

	Local $left, $top

	For $oThisCtrl In $oCtrl.ctrls.Items()
		If $oSelected.exists($oThisCtrl.Hwnd) Then ContinueLoop

		If $delta_x = Default Then
			$left = Default
		Else
			$left = $oThisCtrl.Left - $delta_x
		EndIf

		If $delta_y = Default Then
			$top = Default
		Else
			$top = $oThisCtrl.Top - $delta_y
		EndIf

		_change_ctrl_size_pos($oThisCtrl, $left, $top, $width, $height, True)
	Next

	GUISwitch($hGUI)
EndFunc   ;==>_moveGroupCtrls


Func _move_mouse_to_grippy(Const $x, Const $y)
	Local Const $mouse_coord_mode = Opt("MouseCoordMode", 2)

	MouseMove(Int($x + ($grippy_size / 2)), Int($y + ($grippy_size / 2)), 0)

	Opt("MouseCoordMode", $mouse_coord_mode)
EndFunc   ;==>_move_mouse_to_grippy
#EndRegion ; moving & resizing


;_objAction()_updateActionStacks
Func _updateActionStacks($oActionObject = 0)
	Local $aTemp[0]

	;if not an object, clear the stacks
	If Not IsObj($oActionObject) Then
		$aStackUndo = $aTemp
		$aStackRedo = $aTemp
		Return
	EndIf

	;add this action to the undo stack
	_ArrayAdd($aStackUndo, $oActionObject)

	;clear the redo stack
	$aStackRedo = $aTemp
EndFunc   ;==>_updateActionStacks


;credit to jmon
;modified by kurtykurtboy
Func GuiCtrlSetOnTop($iCtrlID, $hAfter = $HWND_TOP)
    Local $hWnd = $iCtrlID
	Local $hAfterNew = $hAfter
    If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($iCtrlID)

	If $hAfter <> $HWND_TOP Then
		If Not IsHWnd($hAfter) Then $hAfterNew = GUICtrlGetHandle($hAfter)
	EndIf

    Return _WinAPI_SetWindowPos($hWnd, $hAfterNew, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
EndFunc


Func _undo()
	ConsoleWrite("Undo" & @CRLF)
	Local $size = UBound($aStackUndo)

	If $size > 0 Then
		;perform the inverse of the saved action
		Local $oAction = $aStackUndo[$size - 1]
		Switch $oAction.action
			Case $action_changeText
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				_SendMessage($hGUI, $WM_SETREDRAW, False)
				Local $aParams
				For $i = 0 To UBound($aActionCtrls) - 1
					$aParams = $aActionParams[$i]
					GUICtrlSetData($aActionCtrls[$i].Hwnd, $aParams[0])
					$aActionCtrls[$i].Text = $aParams[0]
				Next
				_SendMessage($hGUI, $WM_SETREDRAW, True)
				_WinAPI_RedrawWindow($hGUI)
				_populate_control_properties_gui($oSelected.getFirst())
				_refreshGenerateCode()

			Case $action_renameCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters
				$aActionCtrls[0].Name = $aActionParams[0]
				_populate_control_properties_gui($oSelected.getFirst())
				_formObjectExplorer_updateList()
				_refreshGenerateCode()

			Case $action_nudgeCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters
				_nudgeSelected(-1 * $aActionParams[0], -1 * $aActionParams[1], $aActionCtrls)

			Case $action_moveCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters
				_nudgeSelected(-1 * $aActionParams[0], -1 * $aActionParams[1], $aActionCtrls)

			Case $action_resizeCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				_SendMessage($hGUI, $WM_SETREDRAW, False)
				Local $aParams
				For $i = 0 To UBound($aActionCtrls) - 1
					$aParams = $aActionParams[$i]
					_change_ctrl_size_pos($aActionCtrls[$i], $aParams[4], $aParams[5], $aParams[0], $aParams[1])
				Next
				_SendMessage($hGUI, $WM_SETREDRAW, True)
				_WinAPI_RedrawWindow($hGUI)
				_populate_control_properties_gui($oSelected.getFirst())
				_refreshGenerateCode()

			Case $action_drawCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters
				_deleteCtrls($aActionCtrls)

			Case $action_deleteCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				_SendMessage($hGUI, $WM_SETREDRAW, False)
				Local $prevHwnd, $oNewCtrl
				For $i = 0 To UBound($aActionCtrls) - 1
					ConsoleWrite("$i: " & $i & @CRLF)
					$prevHwnd = $aActionCtrls[$i].Hwnd
					$oNewCtrl = _create_ctrl($aActionCtrls[$i])
					ConsoleWrite(Hex($oNewCtrl.Hwnd, 8) & @CRLF)
					_remove_all_from_selected()
;~ 					For $oActionObject In $aStackUndo
;~ 						For $oActionCtrl In $oActionObject.ctrls
;~ 							ConsoleWrite("  name: " & $oActionCtrl.Name & @CRLF)
;~ 							ConsoleWrite("  hwnd: " & $oActionCtrl.Hwnd & @CRLF)
;~ 							If $oActionCtrl.Hwnd = $prevHwnd Then
;~ 								ConsoleWrite("  new hwnd: " & $oNewCtrl.Hwnd & @CRLF)
;~ 								$oActionCtrl.Hwnd = $oNewCtrl.Hwnd
;~ 								$oActionCtrl.grippies.parent = $oNewCtrl.Hwnd
;~ 							Else
;~ 								ConsoleWrite("  no match: " & $oActionCtrl.Hwnd & @CRLF)
;~ 							EndIf
;~ 						Next
;~ 					Next
				Next
				_SendMessage($hGUI, $WM_SETREDRAW, True)
				_WinAPI_RedrawWindow($hGUI)
				_formObjectExplorer_updateList()
				_refreshGenerateCode()

			Case $action_pasteCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters
				_deleteCtrls($aActionCtrls)

			Case $action_changeBkColor
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				_SendMessage($hGUI, $WM_SETREDRAW, False)
				Local $aParams
				For $i = 0 To UBound($aActionCtrls) - 1
					$aParams = $aActionParams[$i]
					Local $newColor = $aParams[0]
					Switch $aActionCtrls[$i].Type
						Case "Label", "Checkbox", "Radio"
							If $newColor <> -1 Then
								GUICtrlSetBkColor($aActionCtrls[$i].Hwnd, $newColor)
								$aActionCtrls[$i].Background = $newColor
							Else
								GUICtrlSetBkColor($aActionCtrls[$i].Hwnd, $defaultGuiBkColor)
								$aActionCtrls[$i].Background = -1
							EndIf

					EndSwitch
				Next
				_SendMessage($hGUI, $WM_SETREDRAW, True)
				_WinAPI_RedrawWindow($hGUI)
				_populate_control_properties_gui($oSelected.getFirst())
				_refreshGenerateCode()

			Case $action_changeColor
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				_SendMessage($hGUI, $WM_SETREDRAW, False)
				Local $aParams
				For $i = 0 To UBound($aActionCtrls) - 1
					$aParams = $aActionParams[$i]
					Local $newColor = $aParams[0]

					If $aActionCtrls[$i].Type = "Label" Then
						If $newColor <> -1 Then
							GUICtrlSetColor($aActionCtrls[$i].Hwnd, $newColor)
						Else
							GUICtrlDelete($aActionCtrls[$i].Hwnd)
							$aActionCtrls[$i].Hwnd = GUICtrlCreateLabel($aActionCtrls[$i].Text, $aActionCtrls[$i].Left, $aActionCtrls[$i].Top, $aActionCtrls[$i].Width, $aActionCtrls[$i].Height)
							$aActionCtrls[$i].Color = -1
							If $aActionCtrls[$i].Background <> -1 Then
								GUICtrlSetBkColor($aActionCtrls[$i].Hwnd, $aActionCtrls[$i].Background)
							EndIf
						EndIf

						$aActionCtrls[$i].Color = $newColor
					EndIf
				Next
				_SendMessage($hGUI, $WM_SETREDRAW, True)
				_WinAPI_RedrawWindow($hGUI)
				_populate_control_properties_gui($oSelected.getFirst())
				_refreshGenerateCode()

			Case $action_changeCode
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				Local $aParams
				For $i = 0 To UBound($aActionCtrls) - 1
					$aParams = $aActionParams[$i]
					$aActionCtrls[$i].CodeString = $aParams[0]
				Next
				_refreshGenerateCode()

		EndSwitch

		;move from undo stack to redo stack
		_ArrayAdd($aStackRedo, $aStackUndo[$size - 1])
		_ArrayDelete($aStackUndo, $size - 1)
	EndIf
EndFunc   ;==>_undo


Func _redo()
	ConsoleWrite("Redo" & @CRLF)
	Local $size = UBound($aStackRedo)

	If $size > 0 Then
		;perform the action
		Local $oAction = $aStackRedo[$size - 1]
		Switch $oAction.action
			Case $action_changeText
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				_SendMessage($hGUI, $WM_SETREDRAW, False)
				Local $aParams
				For $i = 0 To UBound($aActionCtrls) - 1
					$aParams = $aActionParams[$i]
					GUICtrlSetData($aActionCtrls[$i].Hwnd, $aParams[1])
					$aActionCtrls[$i].Text = $aParams[1]
				Next
				_SendMessage($hGUI, $WM_SETREDRAW, True)
				_WinAPI_RedrawWindow($hGUI)
				_populate_control_properties_gui($oSelected.getFirst())
				_refreshGenerateCode()

			Case $action_renameCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters
				$aActionCtrls[0].Name = $aActionParams[1]
				_populate_control_properties_gui($oSelected.getFirst())
				_formObjectExplorer_updateList()
				_refreshGenerateCode()

			Case $action_nudgeCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters
				_nudgeSelected($aActionParams[0], $aActionParams[1], $aActionCtrls)

			Case $action_moveCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters
				_nudgeSelected($aActionParams[0], $aActionParams[1], $aActionCtrls)

			Case $action_resizeCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				_SendMessage($hGUI, $WM_SETREDRAW, False)
				Local $aParams
				For $i = 0 To UBound($aActionCtrls) - 1
					$aParams = $aActionParams[$i]
					_change_ctrl_size_pos($aActionCtrls[$i], $aParams[6], $aParams[7], $aParams[2], $aParams[3])
				Next
				_SendMessage($hGUI, $WM_SETREDRAW, True)
				_WinAPI_RedrawWindow($hGUI)
				_populate_control_properties_gui($oSelected.getFirst())
				_refreshGenerateCode()

			Case $action_drawCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				_SendMessage($hGUI, $WM_SETREDRAW, False)
				Local $prevHwnd, $oNewCtrl
				For $i = 0 To UBound($aActionCtrls) - 1
					ConsoleWrite("$i: " & $i & @CRLF)
					$prevHwnd = $aActionCtrls[$i].Hwnd
					$oNewCtrl = _create_ctrl($aActionCtrls[$i])
					ConsoleWrite(Hex($oNewCtrl.Hwnd, 8) & @CRLF)
					_remove_all_from_selected()
;~ 					For $oActionObject In $aStackUndo
;~ 						For $oActionCtrl In $oActionObject.ctrls
;~ 							ConsoleWrite("  name: " & $oActionCtrl.Name & @CRLF)
;~ 							ConsoleWrite("  hwnd: " & $oActionCtrl.Hwnd & @CRLF)
;~ 							If $oActionCtrl.Hwnd = $prevHwnd Then
;~ 								ConsoleWrite("  new hwnd: " & $oNewCtrl.Hwnd & @CRLF)
;~ 								$oActionCtrl.Hwnd = $oNewCtrl.Hwnd
;~ 								$oActionCtrl.grippies.parent = $oNewCtrl.Hwnd
;~ 							Else
;~ 								ConsoleWrite("  no match: " & $oActionCtrl.Hwnd & @CRLF)
;~ 							EndIf
;~ 						Next
;~ 					Next
				Next
				_SendMessage($hGUI, $WM_SETREDRAW, True)
				_WinAPI_RedrawWindow($hGUI)
				_formObjectExplorer_updateList()
				_refreshGenerateCode()

			Case $action_deleteCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters
				_deleteCtrls($aActionCtrls)

			Case $action_pasteCtrl
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				_SendMessage($hGUI, $WM_SETREDRAW, False)
				Local $prevHwnd, $oNewCtrl
				For $i = 0 To UBound($aActionCtrls) - 1
					ConsoleWrite("$i: " & $i & @CRLF)
					$prevHwnd = $aActionCtrls[$i].Hwnd
					$oNewCtrl = _create_ctrl($aActionCtrls[$i])
					ConsoleWrite(Hex($oNewCtrl.Hwnd, 8) & @CRLF)
					_remove_all_from_selected()
				Next
				_SendMessage($hGUI, $WM_SETREDRAW, True)
				_WinAPI_RedrawWindow($hGUI)
				_formObjectExplorer_updateList()
				_refreshGenerateCode()

			Case $action_changeBkColor
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				_SendMessage($hGUI, $WM_SETREDRAW, False)
				Local $aParams
				For $i = 0 To UBound($aActionCtrls) - 1
					$aParams = $aActionParams[$i]
					Local $newColor = $aParams[1]
					Switch $aActionCtrls[$i].Type
						Case "Label", "Checkbox", "Radio"
							If $newColor <> -1 Then
								GUICtrlSetBkColor($aActionCtrls[$i].Hwnd, $newColor)
								$aActionCtrls[$i].Background = $newColor
							Else
								GUICtrlSetBkColor($aActionCtrls[$i].Hwnd, $defaultGuiBkColor)
								$aActionCtrls[$i].Background = -1
							EndIf

					EndSwitch
				Next
				_SendMessage($hGUI, $WM_SETREDRAW, True)
				_WinAPI_RedrawWindow($hGUI)
				_populate_control_properties_gui($oSelected.getFirst())
				_refreshGenerateCode()

			Case $action_changeColor
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				_SendMessage($hGUI, $WM_SETREDRAW, False)
				Local $aParams
				For $i = 0 To UBound($aActionCtrls) - 1
					$aParams = $aActionParams[$i]
					Local $newColor = $aParams[1]

					If $aActionCtrls[$i].Type = "Label" Then
						If $newColor <> -1 Then
							GUICtrlSetColor($aActionCtrls[$i].Hwnd, $newColor)
						Else
							GUICtrlDelete($aActionCtrls[$i].Hwnd)
							$aActionCtrls[$i].Hwnd = GUICtrlCreateLabel($aActionCtrls[$i].Text, $aActionCtrls[$i].Left, $aActionCtrls[$i].Top, $aActionCtrls[$i].Width, $aActionCtrls[$i].Height)
							$aActionCtrls[$i].Color = -1
							If $aActionCtrls[$i].Background <> -1 Then
								GUICtrlSetBkColor($aActionCtrls[$i].Hwnd, $aActionCtrls[$i].Background)
							EndIf
						EndIf

						$aActionCtrls[$i].Color = $newColor
					EndIf
				Next
				_SendMessage($hGUI, $WM_SETREDRAW, True)
				_WinAPI_RedrawWindow($hGUI)
				_populate_control_properties_gui($oSelected.getFirst())
				_refreshGenerateCode()

			Case $action_changeCode
				Local $aActionCtrls = $oAction.ctrls
				Local $aActionParams = $oAction.parameters

				Local $aParams
				For $i = 0 To UBound($aActionCtrls) - 1
					$aParams = $aActionParams[$i]
					$aActionCtrls[$i].CodeString = $aParams[1]
				Next
				_refreshGenerateCode()

		EndSwitch

		;move from redo stack to undo stack
		_ArrayAdd($aStackUndo, $aStackRedo[$size - 1])
		_ArrayDelete($aStackRedo, $size - 1)
	EndIf
EndFunc   ;==>_redo


