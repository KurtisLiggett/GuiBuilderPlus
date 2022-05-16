; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_CtrlMgmt.au3
; Description ...: Control creation and management
; ===============================================================================================================================


#Region ; control-creation
;------------------------------------------------------------------------------
; Title...........: _create_ctrl
; Description.....: create new control and add it to the map
; Called by.......: Draw with mouse; Paste
;------------------------------------------------------------------------------
Func _create_ctrl(Const $mCtrl = '')
	Local $mNewControl[], $incTypeCount = True
	Local $isPaste = False

	Switch IsMap($mCtrl)
		Case True
			$isPaste = True
			$mNewControl = $mCtrl

;~ 			$mControls.CurrentType = $mNewControl.Type

;~ 			ConsoleWrite("type " & $mControls.CurrentType & @CRLF)

		Case False
			Local $cursor_pos = _mouse_snap_pos()

			; control will be inserted at current mouse position UNLESS out-of-bounds mouse
			Switch $setting_paste_pos
				Case True
					If _cursor_out_of_bounds($cursor_pos) Then
						ContinueCase
					EndIf

				Case False
					$cursor_pos[0] = 0
					$cursor_pos[1] = 0
			EndSwitch

			$mNewControl.HwndCount = 1
			$mNewControl.Type = $mControls.CurrentType
			$mNewControl.Left = $cursor_pos[0]
			$mNewControl.Top = $cursor_pos[1]
			$mNewControl.Width = 1
			$mNewControl.Height = 1
			$mNewControl.Visible = True
			$mNewControl.Enabled = True
			$mNewControl.Focus = False
			$mNewControl.OnTop = False
			$mNewControl.DropAccepted = False
			$mNewControl.Focus = False
			$mNewControl.DefButton = False
			$mNewControl.Color = -1
			$mNewControl.Background = -1
	EndSwitch

	_control_count_inc()

	Local Const $count = $mControls.ControlCount
	Local $name

	;use next available name
	Local $found = True
	Local $j = 0
	While $found
		$found = False
		$j += 1
		$name = $mNewControl.Type & "_" & $j

		If $count > 1 Then
			For $i = 1 To $count - 1
				$mcl_ctrl = $mControls[$i]

				If $mcl_ctrl.Name = $name Then
					$found = True
					ExitLoop
				EndIf
			Next
		Else
			$found = False
		EndIf
	WEnd
;~ 	$mNewControl.Name = $mNewControl.Type & "_" & $mControls[$mNewControl.Type & "Count"]
	$mNewControl.Name = $name

	Switch $mNewControl.Type
		Case "Updown"
			$mNewControl.Text = "0"
		Case Else
;~ 			$mNewControl.Text = $mNewControl.Type & " " & $mControls[$mNewControl.Type & "Count"]
			;if copy+paste, use same text
			If Not $isPaste Then
				$mNewControl.Text = $mNewControl.Type & " " & $j
			EndIf
	EndSwitch

	Switch $mNewControl.Type
		Case "Button"
			$mNewControl.Hwnd = GUICtrlCreateButton($mNewControl.Text, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			_set_button_styles($mNewControl)

			$mControls[$mControls.ControlCount] = $mNewControl

			$bStatusNewMessage = True
			_GUICtrlStatusBar_SetText($hStatusbar, "new button")

		Case "Group"
			$mNewControl.Hwnd = GUICtrlCreateGroup($mNewControl.Text, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			$mControls[$mControls.ControlCount] = $mNewControl

		Case "Checkbox"
			$mNewControl.Height = 20

			$mNewControl.Hwnd = GUICtrlCreateCheckbox($mNewControl.Text, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			$mControls[$mControls.ControlCount] = $mNewControl

		Case "Radio"
			$mNewControl.Height = 20

			$mNewControl.Hwnd = GUICtrlCreateRadio($mNewControl.Text, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			$mControls[$mControls.ControlCount] = $mNewControl

		Case "Edit"
			$mNewControl.Hwnd = GUICtrlCreateEdit('', $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			GUICtrlSetState($mNewControl.Hwnd, $GUI_DISABLE)

			$mControls[$mControls.ControlCount] = $mNewControl

			GUICtrlSetResizing($mNewControl.Hwnd, $GUI_DOCKALL)

			Return $mNewControl

		Case "Input"
			$mNewControl.Hwnd = GUICtrlCreateInput($mNewControl.Text, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			GUICtrlSetState($mNewControl.Hwnd, $GUI_DISABLE)

			$mControls[$mControls.ControlCount] = $mNewControl

		Case "Label"
			$mNewControl.Hwnd = GUICtrlCreateLabel($mNewControl.Text, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
			If $isPaste Then
				If $mNewControl.Background <> -1 Then
					GUICtrlSetBkColor($mNewControl.Hwnd, $mNewControl.Background)
				EndIf
				If $mNewControl.Color <> -1 Then
					GUICtrlSetColor($mNewControl.Hwnd, $mNewControl.Color)
				EndIf
			EndIf

			$mControls[$mControls.ControlCount] = $mNewControl

		Case "List"
			$mNewControl.Hwnd = GUICtrlCreateList($mNewControl.Text, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			GUICtrlSetState($mNewControl.Hwnd, $GUI_DISABLE)

			$mControls[$mControls.ControlCount] = $mNewControl

		Case "Combo"
			$mNewControl.Height = 20

			$mNewControl.Hwnd = GUICtrlCreateCombo('', $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			$mControls[$mControls.ControlCount] = $mNewControl

		Case "Date"
			$mNewControl.Hwnd = GUICtrlCreateDate('', $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			$mControls[$mControls.ControlCount] = $mNewControl

			GUICtrlSetResizing($mNewControl.Hwnd, $GUI_DOCKALL)

			Return $mNewControl

		Case "Slider"
			$mNewControl.Hwnd = _GuiCtrlCreateSlider($mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height, $mNewControl.Height)

			$mControls[$mControls.ControlCount] = $mNewControl

			GUICtrlSetResizing($mNewControl.Hwnd, $GUI_DOCKALL)

			Return $mNewControl

		Case "Tab"
			If $mControls.TabCount = 1 Then
				$incTypeCount = False
				_control_count_dec()
			EndIf

			If $incTypeCount Then    ;create the main control
				;create main tab control
				$mNewControl.Hwnd = GUICtrlCreateTab($mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
				GUICtrlSetOnEvent($mNewControl.Hwnd, "_onCtrlTabSwitch")

				;create tab map
				Local $tabs[]
				$mNewControl.TabCount = 0
				$mNewControl.Tabs = $tabs

				;close the control
				$mControls[$mControls.ControlCount] = $mNewControl
			EndIf

			GUISwitch($hGUI)

			_hide_grid($background)
			If BitAND(GUICtrlRead($menu_show_grid), $GUI_CHECKED) = $GUI_CHECKED Then
				_show_grid($background, $win_client_size[0], $win_client_size[1])
			EndIf
;~ 			GUICtrlSetState($background, $GUI_DISABLE)

		Case "TreeView"
			$mNewControl.Hwnd = GUICtrlCreateTreeView($mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			GUICtrlCreateTreeViewItem($mNewControl.Text, $mNewControl.Hwnd)

			$mControls[$mControls.ControlCount] = $mNewControl

		Case "Updown"
			$mNewControl.HwndCount = 2

			$mNewControl.Height = 20

			$mNewControl.Hwnd1 = GUICtrlCreateInput($mNewControl.Text, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
			$mNewControl.Hwnd = $mNewControl.Hwnd1
			$mNewControl.Hwnd2 = GUICtrlCreateUpdown($mNewControl.Hwnd1)

			$mControls[$mControls.ControlCount] = $mNewControl

		Case "Progress"
			$mNewControl.Hwnd = GUICtrlCreateProgress($mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			GUICtrlSetData($mNewControl.Hwnd, 100)

			$mControls[$mControls.ControlCount] = $mNewControl

			GUICtrlSetResizing($mNewControl.Hwnd, $GUI_DOCKALL)

			Return $mNewControl

		Case "Pic"
			$mNewControl.Hwnd = GUICtrlCreatePic($samplebmp, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
			GUICtrlSetImage($mNewControl.Hwnd, $samplebmp)
			$mControls[$mControls.ControlCount] = $mNewControl

			GUICtrlSetResizing($mNewControl.Hwnd, $GUI_DOCKALL)

			Return $mNewControl

		Case "Avi"
			$mNewControl.Hwnd = GUICtrlCreateAvi($sampleavi, 0, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height, $ACS_AUTOPLAY)

			$mControls[$mControls.ControlCount] = $mNewControl

			GUICtrlSetResizing($mNewControl.Hwnd, $GUI_DOCKALL)

			Return $mNewControl

		Case "Icon"
			$mNewControl.Hwnd = GUICtrlCreateIcon($iconset, 0, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

			$mControls[$mControls.ControlCount] = $mNewControl

			Return $mNewControl
	EndSwitch

	If $incTypeCount Then
		$mControls[$mNewControl.Type & "Count"] += 1

		Switch IsMap($mCtrl)
			Case True
				GUICtrlSetData($mNewControl.Hwnd, $mNewControl.Text)

			Case False
				$mNewControl.Text = $mNewControl.Text
		EndSwitch

		GUICtrlSetResizing($mNewControl.Hwnd, $GUI_DOCKALL)

		Return $mNewControl
	Else
		Return 0
	EndIf
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


Func _new_tab()
	Local $mcl_ctrl

	Local Const $count = $mControls.ControlCount

	For $i = 1 To $count
		$mcl_ctrl = $mControls[$i]

		If $mcl_ctrl.Type = "Tab" Then
			ExitLoop
		EndIf
	Next

	$mcl_ctrl.TabCount += 1
	Local $tabCount = $mcl_ctrl.TabCount
	Local $tabs = $mcl_ctrl.Tabs
	Local $tab[]
	$tab.Hwnd = GUICtrlCreateTabItem("Tab" & $mcl_ctrl.TabCount)
	GUICtrlCreateTabItem("")
	$tab.Text = "Tab" & $mcl_ctrl.TabCount
	$tab.Name = "TabItem_" & $mcl_ctrl.TabCount
	$tabs[$mcl_ctrl.TabCount] = $tab
	$mcl_ctrl.Tabs = $tabs

	_GUICtrlTab_SetCurSel($mcl_ctrl.Hwnd, $mcl_ctrl.TabCount - 1)

;~ 	GUISwitch($hGUI)

	_update_control($mcl_ctrl)
	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_new_tab


Func _onCtrlTabSwitch()
;~ 	ConsoleWrite("tab switch" & @CRLF)
;~ 	ConsoleWrite("size " & $win_client_size[1] & @CRLF)
;~ 	_hide_grid($background)
;~ 	If BitAND(GUICtrlRead($menu_show_grid), $GUI_CHECKED) = $GUI_CHECKED Then
;~ 		_show_grid($background, $win_client_size[0], $win_client_size[1])
;~ 	EndIf
;~ 	GUICtrlSetState($background, $GUI_DISABLE)
EndFunc   ;==>_onCtrlTabSwitch


Func _delete_tab()
	Local $mcl_ctrl

	Local Const $count = $mControls.ControlCount

	For $i = 1 To $count
		$mcl_ctrl = $mControls[$i]

		If $mcl_ctrl.Type = "Tab" Then
			ExitLoop
		EndIf
	Next

	Local $iTabFocus = _GUICtrlTab_GetCurFocus($mcl_ctrl.Hwnd)

	If $iTabFocus >= 0 Then
		_GUICtrlTab_DeleteItem($mcl_ctrl.Hwnd, $iTabFocus)
		$mcl_ctrl.TabCount -= 1
		Local $tabs = $mcl_ctrl.Tabs
		MapRemove($tabs, $iTabFocus + 1)
		$mcl_ctrl.Tabs = $tabs

		_GUICtrlTab_SetCurSel($mcl_ctrl.Hwnd, 0)

		_update_control($mcl_ctrl)
	Else
;~ 		_delete_ctrl($mControls[$i])
		_delete_selected_controls()
	EndIf

	GUISwitch($hGUI)
	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_delete_tab


Func _createAnotherTabItem(Const $tabHandle, Const $text)
	; it would be better to explicitly use the handle of the parent GUI, but this the above function seems to work
	;GuiSwitch($tabHandle)

	;Local Const $item = GuiCtrlCreateTabItem($text)
	Local Const $item = _GUICtrlTab_InsertItem($tabHandle, 0, $text)

	If $text = "" Then
		GUISwitch($hGUI) ; remember null text denotes "closing" tabitem
	EndIf

	Return $item
EndFunc   ;==>_createAnotherTabItem
#EndRegion ; control-creation


#Region control-management
Func _control_type()
	$mControls.CurrentType = GUICtrlRead(@GUI_CtrlId, 1)
	ConsoleWrite("tool selected: " & $mControls.CurrentType & @CRLF)

	$mode = $draw

	;ConsoleWrite("$draw" & @CRLF)
EndFunc   ;==>_control_type


Func _set_button_styles(ByRef $mCtrl)
	$mCtrl.StyleTabStop = True

	Switch $mCtrl.StyleTop
		Case True
			GUICtrlSetState($mCtrl.Hwnd, $BS_TOP)

		Case False
			$mCtrl.StyleTop = False
	EndSwitch

	Switch $mCtrl.StyleAutoCheckbox
		Case False
			$mCtrl.StyleAutoCheckbox = False
	EndSwitch

	$mCtrl.ExStyleWindowEdge = True
EndFunc   ;==>_set_button_styles


;------------------------------------------------------------------------------
; Title...........: _control_map_from_hwnd
; Description.....: get control object from handle
;------------------------------------------------------------------------------
Func _control_map_from_hwnd(Const $ctrl_hwnd, $getIndex = False)
	Local $mcl_ctrl

	Local Const $count = $mControls.ControlCount

	For $i = 1 To $count
		$mcl_ctrl = $mControls[$i]

		If $ctrl_hwnd = $mcl_ctrl.Hwnd Then
			ExitLoop
		EndIf
	Next

	If $getIndex Then
		Return $i
	Else
		Return IsMap($mcl_ctrl) ? $mcl_ctrl : SetError(1, 0, False)
	EndIf
EndFunc   ;==>_control_map_from_hwnd


;------------------------------------------------------------------------------
;~ ; Title...........: _remove_all_control_maps
;~ ; Description.....: remove all maps from mControls object
;~ ;------------------------------------------------------------------------------
;~ Func _mControls_DeleteAll(ByRef $mCtrl)
;~ 	Local Const $count = $mControls.ControlCount
;~ 	Local $mcl_element

;~ 	For $i = 1 To $count
;~ 		$mcl_element = $mControls[$i]

;~ 		Switch $mcl_element.Type
;~ 			Case "Updown"
;~ 				GUICtrlDelete($mcl_element.Hwnd1)
;~ 				GUICtrlDelete($mcl_element.Hwnd2)

;~ 			Case Else
;~ 				GUICtrlDelete($mcl_element.Hwnd)
;~ 		EndSwitch
;~ 	Next

;~ 	_remove_all_control_maps()

;~ 	$mControls.ButtonCount = 0
;~ 	$mControls.GroupCount = 0
;~ 	$mControls.CheckboxCount = 0
;~ 	$mControls.RadioCount = 0
;~ 	$mControls.EditCount = 0
;~ 	$mControls.InputCount = 0
;~ 	$mControls.LabelCount = 0
;~ 	$mControls.ListCount = 0
;~ 	$mControls.ComboCount = 0
;~ 	$mControls.DateCount = 0
;~ 	$mControls.SliderCount = 0
;~ 	$mControls.TabCount = 0
;~ 	$mControls.TreeViewCount = 0
;~ 	$mControls.UpdownCount = 0
;~ 	$mControls.ProgressCount = 0
;~ 	$mControls.PicCount = 0
;~ 	$mControls.AviCount = 0
;~ 	$mControls.IconCount = 0
;~ EndFunc   ;==>_mControls_DeleteAll


;------------------------------------------------------------------------------
; Title...........: _remove_all_control_maps
; Description.....: remove all maps from mControls object
;------------------------------------------------------------------------------
Func _remove_all_control_maps()
	Local Const $count = $mControls.ControlCount

	For $i = 1 To $count
		MapRemove($mControls, $i)

		_control_count_dec()
	Next
EndFunc   ;==>_remove_all_control_maps


;------------------------------------------------------------------------------
; Title...........: _remove_from_control_map
; Description.....: remove a control object from mControls object
;------------------------------------------------------------------------------
Func _remove_from_control_map(Const $mCtrl)
	Local Const $count = $mControls.ControlCount

	For $i = 1 To $count
		If $mCtrl.Hwnd = $mControls[$i].Hwnd Then
			MapRemove($mControls, $i)
			ExitLoop
		EndIf
	Next

	_consolidate_controls($i)

	_control_count_dec()
EndFunc   ;==>_remove_from_control_map


;------------------------------------------------------------------------------
; Title...........: _update_control
; Description.....: replace selected control with another
;------------------------------------------------------------------------------
Func _update_control(Const $mCtrl)
	Local Const $count = $mControls.ControlCount

	For $i = 1 To $count
		If $mCtrl.Hwnd = $mControls[$i].Hwnd Then
			$mControls[$i] = $mCtrl

			ExitLoop
		EndIf
	Next

	Local Const $sel_count = $mSelected.SelectedCount

	If $sel_count Then
		For $i = 1 To $sel_count
			If $mCtrl.Hwnd = $mSelected[$i].Hwnd Then
				$mSelected[$i] = $mCtrl

				ExitLoop
			EndIf
		Next
	EndIf
EndFunc   ;==>_update_control


;------------------------------------------------------------------------------
; Title...........: _consolidate_controls
; Description.....: Shift (if necessary) and remove control object
;					**why is this needed and how does it even work successfully?
;------------------------------------------------------------------------------
Func _consolidate_controls(Const $startIndex)
	Local Const $count = $mControls.ControlCount

	Local $mCtrl
	For $j = 1 To $count - 1
		If Not IsMap($mControls[$j]) Then
			$mCtrl = $mControls[($j + 1)]

			$mControls[$j] = $mCtrl

			MapRemove($mControls, ($j + 1))
		EndIf
	Next

	Return $count
EndFunc   ;==>_consolidate_controls


;------------------------------------------------------------------------------
; Title...........: _delete_ctrl
; Description.....: delete control from GUI and remove the map object
;------------------------------------------------------------------------------
Func _delete_ctrl(Const $mCtrl)
	$mControls[$mCtrl.Type & "Count"] -= 1

	GUISwitch($hGUI)
	Switch $mCtrl.Type
		Case "Updown"
			GUICtrlDelete($mCtrl.Hwnd1)
			GUICtrlDelete($mCtrl.Hwnd2)

		Case Else
			GUICtrlDelete($mCtrl.Hwnd)
	EndSwitch
	GUISwitch($hGUI)

	_remove_from_selected($mCtrl)

	_remove_from_control_map($mCtrl)

	_formObjectExplorer_updateList()
EndFunc   ;==>_delete_ctrl


;------------------------------------------------------------------------------
; Title...........: _control_count_inc
; Description.....: increment control count
;------------------------------------------------------------------------------
Func _control_count_inc()
	$mControls.ControlCount += 1

	If $mControls.ControlCount = 1 Then
		GUICtrlSetState($menu_wipe, $GUI_ENABLE)

		_enable_control_properties_gui()
	EndIf
EndFunc   ;==>_control_count_inc


;------------------------------------------------------------------------------
; Title...........: _control_count_dec
; Description.....: decrement control count
;------------------------------------------------------------------------------
Func _control_count_dec()
	$mControls.ControlCount -= 1

	If $mControls.ControlCount = 0 Then
		GUICtrlSetState($menu_wipe, $GUI_DISABLE)

		_disable_control_properties_gui()
	EndIf
EndFunc   ;==>_control_count_dec


;------------------------------------------------------------------------------
; Title...........: _is_control
; Description.....: check if control is in the mControls list
;------------------------------------------------------------------------------
Func _is_control(Const $mCtrl)
	If Not IsMap($mCtrl) Then Return False

	Local Const $ctrl_count = $mControls.ControlCount

	For $i = 1 To $ctrl_count
		If $mCtrl.Hwnd = $mControls[$i].Hwnd Then
			Return True
		EndIf
	Next

	Return False
EndFunc   ;==>_is_control
#EndRegion control-management


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
Func _left_top_union_rect()
	Local Const $sel_count = $mSelected.SelectedCount

	Local $sel_ctrl

	Local $smallest[]

	$smallest.Left = $mControls.Selected1.Left

	$smallest.Top = $mControls.Selected1.Top

	For $i = 2 To $sel_count
		$sel_ctrl = $mSelected[$i]

		;ConsoleWrite('- ' & $sel_ctrl.Left & @TAB & $smallest.Left & @CRLF)

		If Int($sel_ctrl.Left) < Int($smallest.Left) Then
			$smallest.Left = $sel_ctrl.Left
		EndIf

		If Int($sel_ctrl.Top) < Int($smallest.Top) Then
			$smallest.Top = $sel_ctrl.Top
		EndIf
	Next

	Return $smallest
EndFunc   ;==>_left_top_union_rect


Func _copy_selected()
	Local Const $sel_count = $mSelected.SelectedCount

	Switch $sel_count >= 1
		Case True
			_remove_all_from_clipboard()

			Local Const $smallest = _left_top_union_rect()

			Local Const $selected = _selected_to_array($sel_count, $smallest)

			_selected_to_clipboard($selected, $sel_count)

			Local $clip_ctrl

			For $i = 1 To $sel_count
				$clip_ctrl = $mClipboard[$i]

;~ 				$clip_ctrl.Left = Abs($smallest.Left - $clip_ctrl.Left)

;~ 				$clip_ctrl.Top = Abs($smallest.Top - $clip_ctrl.Top)

				$mClipboard[$i] = $clip_ctrl
			Next
	EndSwitch
EndFunc   ;==>_copy_selected


Func _selected_to_array(Const $sel_count, Const $smallest)
	Local $selected[$sel_count][2] ; second dimension is magnitude of the control's rectangle

	Local $sel_ctrl

	For $i = 0 To $sel_count - 1
		$sel_ctrl = $mSelected[$i + 1]

		$selected[$i][0] = $sel_ctrl

		$selected[$i][1] = _vector_magnitude($smallest.Left, $smallest.Top, $sel_ctrl.Left, $sel_ctrl.Top)
	Next

	_ArraySort($selected, 0, 0, 0, 1)

	Return $selected
EndFunc   ;==>_selected_to_array


Func _selected_to_clipboard(Const $selected, Const $sel_count)
	For $i = 1 To $sel_count
		$mClipboard[$i] = $selected[$i - 1][0]
	Next

	$mClipboard.ClipboardCount = $sel_count
EndFunc   ;==>_selected_to_clipboard


Func _PasteSelected($bDuplicate = False)
	Local Const $clipboard_count = $mClipboard.ClipboardCount
	Local $aNewCtrls[$clipboard_count]
	Local $newCtrl

	Switch $clipboard_count >= 1
		Case True
			Local $clipboard

			For $i = 1 To $clipboard_count
				$clipboard = $mClipboard[$i]

				If $bDuplicate Then
					$clipboard.Left += 20
					$clipboard.Top += 20
				Else
					$clipboard.Left += $mMouse.X
					$clipboard.Top += $mMouse.Y
				EndIf

				$newCtrl = _create_ctrl($clipboard)
				$aNewCtrls[$i - 1] = $newCtrl
			Next
	EndSwitch

	If $bDuplicate Then
		For $i = 0 To UBound($aNewCtrls) - 1
			$mCtrl = $aNewCtrls[$i]

			If $i = 0 Then    ;select first item
				_add_to_selected($mCtrl)
				_populate_control_properties_gui($mCtrl)
			Else    ;add to selection
				_add_to_selected($mCtrl, False)
			EndIf
		Next
	EndIf

	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_PasteSelected


Func _DuplicateSelected()
	If $mSelected.SelectedCount < 1 Then Return
	;copy selected to clipboard
	_copy_selected()

	;paste clipboard with duplicate flag
	_PasteSelected(True)
EndFunc   ;==>_DuplicateSelected


Func _remove_all_from_clipboard()
	Local Const $count = $mClipboard.ClipboardCount

	For $i = 1 To $count
		MapRemove($mClipboard, $i)
	Next

	$mClipboard.ClipboardCount = 0

	Return True
EndFunc   ;==>_remove_all_from_clipboard
#EndRegion ; selection and clipboard management


#Region ; selection
Func _display_selected_tooltip()
	Local $tooltip, $selected_ctrl

	Local Const $count = $mSelected.SelectedCount

	For $i = 1 To $count
		$selected_ctrl = $mSelected[$i]

		$tooltip &= $selected_ctrl.Name & ": X:" & $selected_ctrl.Left & ", Y:" & $selected_ctrl.Top & ", W:" & $selected_ctrl.Width & ", H:" & $selected_ctrl.Height & @CRLF
	Next

	ToolTip(StringTrimRight($tooltip, 2))
EndFunc   ;==>_display_selected_tooltip

Func _control_intersection(Const $mCtrl, Const $mRect)
	If __WinAPI_PtInRectEx($mCtrl.Left, $mCtrl.Top, $mRect.Left, $mRect.Top, $mRect.Width, $mRect.Height) Then
		Return True
	EndIf

	Return False
EndFunc   ;==>_control_intersection

Func _group_select(Const $mCtrl)
	If $mCtrl.Type = "Group" Then
		_select_control_group($mCtrl)

		_set_current_mouse_pos()

		_hide_grippies()

		$mode = $init_move

		;ConsoleWrite("$init_move" & @CRLF)

		Return True
	EndIf

	Return False
EndFunc   ;==>_group_select

Func _select_control_group(Const $mGroup)
	Local $mGroupRect[]

	$mGroupRect.Left = $mGroup.Left
	$mGroupRect.Top = $mGroup.Top
	$mGroupRect.Width = $mGroup.Width
	$mGroupRect.Height = $mGroup.Height

	Local $mCtrl

	Local Const $count = $mControls.ControlCount

	For $i = 1 To $count
		$mCtrl = $mControls[$i]

		If _control_intersection($mCtrl, $mGroupRect) Then
			_add_to_selected($mCtrl, False)
		EndIf
	Next
EndFunc   ;==>_select_control_group

Func _add_to_selected(Const $mCtrl, Const $overwrite = True)
	If Not IsMap($mCtrl) Then
		Return
	EndIf

	Switch $overwrite
		Case True
			_remove_all_from_selected()

		Case False
			Switch _in_selected($mCtrl)
				Case True
					Return SetError(1, 0, False)
			EndSwitch
	EndSwitch

	$mSelected.SelectedCount += 1

	$mSelected[$mSelected.SelectedCount] = $mCtrl

	_enable_control_properties_gui()

	_populate_control_properties_gui($mCtrl)

	_show_grippies($mCtrl)

	Return True
EndFunc   ;==>_add_to_selected

Func _add_remove_selected_control(Const $i, Const $mRect)
	Local Const $mCtrl = $mControls[$i]

	Switch _control_intersection($mCtrl, $mRect)
		Case True
			Switch _add_to_selected($mCtrl, False)
				Case True
					_populate_control_properties_gui($mCtrl)

					_display_selected_tooltip()
			EndSwitch

		Case False
			Switch _remove_from_selected($mCtrl)
				Case True
					Local Const $sel_count = $mSelected.SelectedCount

					Switch $sel_count >= 1
						Case True
							_populate_control_properties_gui($mSelected[$sel_count])

							_show_grippies($mSelected[$sel_count])

						Case False
							_clear_control_properties_gui()

							_disable_control_properties_gui()

							_hide_grippies()
					EndSwitch

					_display_selected_tooltip()
			EndSwitch
	EndSwitch
EndFunc   ;==>_add_remove_selected_control

Func _remove_all_from_selected()
	Local Const $count = $mSelected.SelectedCount

	For $i = 1 To $count
		MapRemove($mSelected, $i)
	Next

	$mSelected.SelectedCount = 0

	_hide_grippies()

	_disable_control_properties_gui()

	Return True
EndFunc   ;==>_remove_all_from_selected

Func _delete_selected_controls()
	Local Const $sel_count = $mSelected.SelectedCount

	Switch $sel_count >= 1
		Case True
			_clear_control_properties_gui()

			Local $mCtrl

			For $i = $sel_count To 1 Step -1
				$mCtrl = $mSelected[$i]

				_delete_ctrl($mCtrl)
			Next

			_hide_grippies()

			_recall_overlay()

			_set_default_mode()

			_refreshGenerateCode()
			Return True
	EndSwitch

EndFunc   ;==>_delete_selected_controls

Func _remove_from_selected(Const $mCtrl)
	If Not IsMap($mCtrl) Then
		Return
	EndIf

	Switch _in_selected($mCtrl)
		Case False
			Return SetError(1, 0, False)
	EndSwitch

	Local Const $count = $mSelected.SelectedCount

	For $i = 1 To $count
		Switch $mCtrl.Hwnd
			Case $mSelected[$i].Hwnd
				MapRemove($mSelected, $i)

				_consolidate_selected($count)

				ExitLoop
		EndSwitch
	Next

	$mSelected.SelectedCount -= 1

	_show_grippies($mSelected[$mSelected.SelectedCount])

	_enable_control_properties_gui()

	Return True
EndFunc   ;==>_remove_from_selected

Func _consolidate_selected(Const $count)
	; inefficient; but works

	For $j = $count To 1 Step -1
		If Not IsMap($mSelected[($j - 1)]) Then
			$mSelected[($j - 1)] = $mSelected[$j]

			MapRemove($mSelected, $mSelected[$j])

			Return _consolidate_selected($count - 1)
		EndIf
	Next

	Return $count
EndFunc   ;==>_consolidate_selected

Func _in_selected(Const $mCtrl)
	Local Const $count = $mSelected.SelectedCount

	For $i = 1 To $count
		If $mSelected[$i].Hwnd = $mCtrl.Hwnd Then
			Return True
		EndIf
	Next

	Return False
EndFunc   ;==>_in_selected

Func _display_selection_rect(Const $mRect)
	GUICtrlSetPos($overlay, $mRect.Left, $mRect.Top, $mRect.Width, $mRect.Height)
EndFunc   ;==>_display_selection_rect

Func _hide_selected_controls()
	Local Const $count = $mSelected.SelectedCount

	For $i = 1 To $count
		If Not $setting_show_control Then
			GUICtrlSetState($mSelected[$i].Hwnd, $GUI_HIDE)
		EndIf
	Next
EndFunc   ;==>_hide_selected_controls

Func _show_selected_controls()
	Local Const $count = $mSelected.SelectedCount

	For $i = 1 To $count
		If Not $setting_show_control Then
			GUICtrlSetState($mSelected[$i].Hwnd, $GUI_SHOW)
		EndIf
	Next
EndFunc   ;==>_show_selected_controls
#EndRegion ; selection


#Region ; moving & resizing
Func _change_ctrl_size_pos(ByRef $mCtrl, Const $left, Const $top, Const $width, Const $height)
	If $width < 1 Or $height < 1 Then
		Return
	EndIf

	Switch $mCtrl.Type
		Case "Updown"
			GUICtrlSetPos($mCtrl.Hwnd1, $left, $top, $width, $height)

		Case Else
			GUICtrlSetPos($mCtrl.Hwnd, $left, $top, $width, $height)
	EndSwitch

	$mCtrl.Left = $left
	$mCtrl.Top = $top
	$mCtrl.Width = $width
	$mCtrl.Height = $height
EndFunc   ;==>_change_ctrl_size_pos


#Region ; grippies
Func _set_resize_mode()
	Switch @GUI_CtrlId
		Case $SouthEast_Grippy
			$mode = $resize_se

		Case $NorthWest_Grippy
			$mode = $resize_nw

		Case $North_Grippy
			$mode = $resize_n

		Case $NorthEast_Grippy
			$mode = $resize_ne

		Case $East_Grippy
			$mode = $resize_e

		Case $SouthEast_Grippy
			$mode = $resize_se

		Case $South_Grippy
			$mode = $resize_s

		Case $SouthWest_Grippy
			$mode = $resize_sw

		Case $West_Grippy
			$mode = $resize_w
	EndSwitch

	$initResize = True
	_hide_selected_controls()
EndFunc   ;==>_set_resize_mode

Func _handle_grippy(ByRef $mCtrl, Const $left, Const $top, Const $right, Const $bottom)
	_set_current_mouse_pos()

	Switch $mCtrl.Type
		Case "Slider"
			GUICtrlSendMsg($mCtrl.Hwnd, 27 + 0x0400, $mCtrl.Height - 20, 0) ; TBS_SETTHUMBLENGTH
	EndSwitch

	_change_ctrl_size_pos($mCtrl, $left, $top, $right, $bottom)

	$mControls.Selected1 = $mCtrl

	_update_control($mCtrl)

	_show_grippies($mCtrl)

	ToolTip($mControls.Selected1.Name & ": X:" & $mControls.Selected1.Left & ", Y:" & $mControls.Selected1.Top & ", W:" & $mControls.Selected1.Width & ", H:" & $mControls.Selected1.Height)
EndFunc   ;==>_handle_grippy

Func _handle_nw_grippy($mCtrl)
	Local Const $right = ($mCtrl.Width + $mCtrl.Left) - $mMouse.X

	Local Const $bottom = ($mCtrl.Height + $mCtrl.Top) - $mMouse.Y

	_handle_grippy($mCtrl, $mMouse.X, $mMouse.Y, $right, $bottom)
EndFunc   ;==>_handle_nw_grippy

Func _handle_n_grippy($mCtrl)
	Local Const $bottom = ($mCtrl.Top + $mCtrl.Height) - $mMouse.Y

	_handle_grippy($mCtrl, $mCtrl.Left, $mMouse.Y, $mCtrl.Width, $bottom)
EndFunc   ;==>_handle_n_grippy

Func _handle_ne_grippy($mCtrl)
	Local Const $bottom = ($mCtrl.Top + $mCtrl.Height) - $mMouse.Y

	_handle_grippy($mCtrl, $mCtrl.Left, $mMouse.Y, $mMouse.X - $mCtrl.Left, $bottom)
EndFunc   ;==>_handle_ne_grippy

Func _handle_w_grippy($mCtrl)
	Local Const $right = $mCtrl.Left + $mCtrl.Width

	_handle_grippy($mCtrl, $mMouse.X, $mCtrl.Top, $right - $mMouse.X, $mCtrl.Height)
EndFunc   ;==>_handle_w_grippy

Func _handle_e_grippy($mCtrl)
	_handle_grippy($mCtrl, $mCtrl.Left, $mCtrl.Top, $mMouse.X - $mCtrl.Left, $mCtrl.Height)
EndFunc   ;==>_handle_e_grippy

Func _handle_sw_grippy($mCtrl)
	Local Const $right = ($mCtrl.Left + $mCtrl.Width) - $mMouse.X

	_handle_grippy($mCtrl, $mMouse.X, $mCtrl.Top, $right, $mMouse.Y - $mCtrl.Top)
EndFunc   ;==>_handle_sw_grippy

Func _handle_s_grippy($mCtrl)
	_handle_grippy($mCtrl, $mCtrl.Left, $mCtrl.Top, $mCtrl.Width, $mMouse.Y - $mCtrl.Top)
EndFunc   ;==>_handle_s_grippy

Func _handle_se_grippy($mCtrl)
	_handle_grippy($mCtrl, $mCtrl.Left, $mCtrl.Top, $mMouse.X - $mCtrl.Left, $mMouse.Y - $mCtrl.Top)
EndFunc   ;==>_handle_se_grippy

Func _show_grippies(Const $mCtrl)
	If Not IsMap($mCtrl) Then
		Return
	EndIf

	Local Const $l = $mCtrl.Left
	Local Const $t = $mCtrl.Top
	Local Const $w = $mCtrl.Width
	Local Const $h = $mCtrl.Height

	Local Const $nw_left = $l - $grippy_size
	Local Const $nw_top = $t - $grippy_size
	Local Const $n_left = $l + ($w - $grippy_size) / 2
	Local Const $n_top = $nw_top
	Local Const $ne_left = $l + $w
	Local Const $ne_top = $nw_top
	Local Const $e_left = $ne_left
	Local Const $e_top = $t + ($h - $grippy_size) / 2
	Local Const $se_left = $ne_left
	Local Const $se_top = $t + $h
	Local Const $s_left = $n_left
	Local Const $s_top = $se_top
	Local Const $sw_left = $nw_left
	Local Const $sw_top = $se_top
	Local Const $w_left = $nw_left
	Local Const $w_top = $e_top

	Switch $mCtrl.Type
		Case "Combo", "Checkbox", "Radio"
			GUICtrlSetPos($East_Grippy, $e_left, $e_top, $grippy_size, $grippy_size)
			GUICtrlSetPos($West_Grippy, $w_left, $w_top, $grippy_size, $grippy_size)

		Case Else
			GUICtrlSetPos($NorthWest_Grippy, $nw_left, $nw_top, $grippy_size, $grippy_size)
			GUICtrlSetPos($North_Grippy, $n_left, $n_top, $grippy_size, $grippy_size)
			GUICtrlSetPos($NorthEast_Grippy, $ne_left, $ne_top, $grippy_size, $grippy_size)
			GUICtrlSetPos($East_Grippy, $e_left, $e_top, $grippy_size, $grippy_size)
			GUICtrlSetPos($SouthEast_Grippy, $se_left, $se_top, $grippy_size, $grippy_size)
			GUICtrlSetPos($South_Grippy, $s_left, $s_top, $grippy_size, $grippy_size)
			GUICtrlSetPos($SouthWest_Grippy, $sw_left, $sw_top, $grippy_size, $grippy_size)
			GUICtrlSetPos($West_Grippy, $w_left, $w_top, $grippy_size, $grippy_size)
	EndSwitch
EndFunc   ;==>_show_grippies

Func _hide_grippies()
	GUICtrlSetPos($NorthWest_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
	GUICtrlSetPos($North_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
	GUICtrlSetPos($NorthEast_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
	GUICtrlSetPos($East_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
	GUICtrlSetPos($SouthEast_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
	GUICtrlSetPos($South_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
	GUICtrlSetPos($SouthWest_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
	GUICtrlSetPos($West_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)

EndFunc   ;==>_hide_grippies

Func _move_mouse_to_grippy(Const $x, Const $y)
	Local Const $mouse_coord_mode = Opt("MouseCoordMode", 2)

	MouseMove(Int($x + ($grippy_size / 2)), Int($y + ($grippy_size / 2)), 0)

	Opt("MouseCoordMode", $mouse_coord_mode)
EndFunc   ;==>_move_mouse_to_grippy
#EndRegion ; grippies
#EndRegion ; moving & resizing


#Region ; overlay management
Func _dispatch_overlay(Const $mCtrl)
	; ConsoleWrite($mCtrl.Name & @CRLF)

	GUICtrlSetPos($overlay, $mCtrl.Left, $mCtrl.Top, $mCtrl.Width, $mCtrl.Height)

	GUICtrlSetState($overlay, $GUI_ONTOP)
EndFunc   ;==>_dispatch_overlay

Func _recall_overlay()
	GUICtrlSetPos($overlay, -1, -1, 1, 1)
EndFunc   ;==>_recall_overlay
#EndRegion ; overlay management

