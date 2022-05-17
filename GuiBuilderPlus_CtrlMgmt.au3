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
Func _create_ctrl(Const $oCtrl = '')
	Local $oNewControl, $incTypeCount = True
	Local $isPaste = False

	Switch IsObj($oCtrl)
		Case True
			$isPaste = True
			$oNewControl = $oCtrl

;~ 			$mControls.CurrentType = $oNewControl.Type

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

			$oNewControl = $oCtrls.createNew()

			$oNewControl.HwndCount = 1
			$oNewControl.Type = $mControls.CurrentType
			$oNewControl.Left = $cursor_pos[0]
			$oNewControl.Top = $cursor_pos[1]
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
;~ 	$oNewControl.Name = $oNewControl.Type & "_" & $mControls[$oNewControl.Type & "Count"]
	$oNewControl.Name = $name

	Switch $oNewControl.Type
		Case "Updown"
			$oNewControl.Text = "0"
		Case Else
;~ 			$oNewControl.Text = $oNewControl.Type & " " & $mControls[$oNewControl.Type & "Count"]
			;if copy+paste, use same text
			If Not $isPaste Then
				$oNewControl.Text = $oNewControl.Type & " " & $j
			EndIf
	EndSwitch

	Switch $oNewControl.Type
		Case "Button"
			$oNewControl.Hwnd = GUICtrlCreateButton($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl)

			$bStatusNewMessage = True
			_GUICtrlStatusBar_SetText($hStatusbar, "new button")

		Case "Group"
			$oNewControl.Hwnd = GUICtrlCreateGroup($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl)

		Case "Checkbox"
			$oNewControl.Height = 20

			$oNewControl.Hwnd = GUICtrlCreateCheckbox($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl)

		Case "Radio"
			$oNewControl.Height = 20

			$oNewControl.Hwnd = GUICtrlCreateRadio($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl)

		Case "Edit"
			$oNewControl.Hwnd = GUICtrlCreateEdit('', $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			GUICtrlSetState($oNewControl.Hwnd, $GUI_DISABLE)

			$oCtrls.add($oNewControl)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

			Return $oNewControl

		Case "Input"
			$oNewControl.Hwnd = GUICtrlCreateInput($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			GUICtrlSetState($oNewControl.Hwnd, $GUI_DISABLE)

			$oCtrls.add($oNewControl)

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

			$oCtrls.add($oNewControl)

		Case "List"
			$oNewControl.Hwnd = GUICtrlCreateList($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			GUICtrlSetState($oNewControl.Hwnd, $GUI_DISABLE)

			$oCtrls.add($oNewControl)

		Case "Combo"
			$oNewControl.Height = 20

			$oNewControl.Hwnd = GUICtrlCreateCombo('', $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl)

		Case "Date"
			$oNewControl.Hwnd = GUICtrlCreateDate('', $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

			Return $oNewControl

		Case "Slider"
			$oNewControl.Hwnd = _GuiCtrlCreateSlider($oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height, $oNewControl.Height)

			$oCtrls.add($oNewControl)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

			Return $oNewControl

		Case "Tab"
			If $mControls.TabCount = 1 Then
				$incTypeCount = False
				_control_count_dec()
			EndIf

			If $incTypeCount Then    ;create the main control
				;create main tab control
				$oNewControl.Hwnd = GUICtrlCreateTab($oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
				GUICtrlSetOnEvent($oNewControl.Hwnd, "_onCtrlTabSwitch")

				;create tab map
				Local $tabs[]
				$oNewControl.TabCount = 0
				$oNewControl.Tabs = $tabs

				$oCtrls.add($oNewControl)
			EndIf

			GUISwitch($hGUI)

			_hide_grid($background)
			If BitAND(GUICtrlRead($menu_show_grid), $GUI_CHECKED) = $GUI_CHECKED Then
				_show_grid($background, $win_client_size[0], $win_client_size[1])
			EndIf
;~ 			GUICtrlSetState($background, $GUI_DISABLE)

		Case "TreeView"
			$oNewControl.Hwnd = GUICtrlCreateTreeView($oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			GUICtrlCreateTreeViewItem($oNewControl.Text, $oNewControl.Hwnd)

			$oCtrls.add($oNewControl)

		Case "Updown"
			$oNewControl.HwndCount = 2

			$oNewControl.Height = 20

			$oNewControl.Hwnd1 = GUICtrlCreateInput($oNewControl.Text, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
			$oNewControl.Hwnd = $oNewControl.Hwnd1
			$oNewControl.Hwnd2 = GUICtrlCreateUpdown($oNewControl.Hwnd1)

			$oCtrls.add($oNewControl)

		Case "Progress"
			$oNewControl.Hwnd = GUICtrlCreateProgress($oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			GUICtrlSetData($oNewControl.Hwnd, 100)

			$oCtrls.add($oNewControl)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

			Return $oNewControl

		Case "Pic"
			$oNewControl.Hwnd = GUICtrlCreatePic($samplebmp, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
			GUICtrlSetImage($oNewControl.Hwnd, $samplebmp)

			$oCtrls.add($oNewControl)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

			Return $oNewControl

		Case "Avi"
			$oNewControl.Hwnd = GUICtrlCreateAvi($sampleavi, 0, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height, $ACS_AUTOPLAY)

			$oCtrls.add($oNewControl)

			GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

			Return $oNewControl

		Case "Icon"
			$oNewControl.Hwnd = GUICtrlCreateIcon($iconset, 0, $oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)

			$oCtrls.add($oNewControl)

			Return $oNewControl
	EndSwitch

	If $incTypeCount Then
		$oCtrls.incTypeCount($oNewControl.Type)

		Switch IsObj($oCtrl)
			Case True	;paste from existing object
				GUICtrlSetData($oNewControl.Hwnd, $oNewControl.Text)

			Case False	;new object
				$oNewControl.Text = $oNewControl.Text
		EndSwitch

		GUICtrlSetResizing($oNewControl.Hwnd, $GUI_DOCKALL)

		Return $oNewControl
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

	Local $iTabFocus = _GUICtrlTab_GetCurSel($mcl_ctrl.Hwnd)

	If $iTabFocus >= 0 Then
		_GUICtrlTab_DeleteItem($mcl_ctrl.Hwnd, $iTabFocus)
		$mcl_ctrl.TabCount -= 1
		Local $tabs = $mcl_ctrl.Tabs
		MapRemove($tabs, $iTabFocus + 1)
;~ 		$mcl_ctrl.Tabs = $tabs

		_GUICtrlTab_SetCurSel($mcl_ctrl.Hwnd, 0)

		$mcl_ctrl.Tabs = _consolidate_tabs($tabs)

		_update_control($mcl_ctrl)
	Else
;~ 		_delete_ctrl($mControls[$i])
		_delete_selected_controls()
	EndIf

	GUISwitch($hGUI)
	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_delete_tab



#Region control-management
Func _control_type()
	$oCtrls.CurrentType = GUICtrlRead(@GUI_CtrlId, 1)
	ConsoleWrite("tool selected: " & $oCtrls.CurrentType & @CRLF)

	$mode = $draw

	;ConsoleWrite("$draw" & @CRLF)
EndFunc   ;==>_control_type


;------------------------------------------------------------------------------
; Title...........: _delete_ctrl
; Description.....: delete control from GUI and remove the map object
;------------------------------------------------------------------------------
Func _delete_ctrl(Const $oCtrl)
	$oCtrls.decTypeCount($oCtrl.Type)

	GUISwitch($hGUI)
	Switch $oCtrl.Type
		Case "Updown"
			GUICtrlDelete($oCtrl.Hwnd1)
			GUICtrlDelete($oCtrl.Hwnd2)

		Case Else
			GUICtrlDelete($oCtrl.Hwnd)
	EndSwitch
	GUISwitch($hGUI)

	$oCtrls.remove($oCtrl.Hwnd)
	$oSelected.remove($oCtrl.Hwnd)

	_formObjectExplorer_updateList()
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
Func _left_top_union_rect()
	Local Const $sel_count = $mSelected.SelectedCount

	Local $sel_ctrl

	Local $smallest[]

	$smallest.Left = $oCtrls.getFirst().Left
	$smallest.Top = $oCtrls.getFirst().Top

	For $oCtrl in $oSelected.ctrls

		;ConsoleWrite('- ' & $sel_ctrl.Left & @TAB & $smallest.Left & @CRLF)

		If Int($oCtrl.Left) < Int($smallest.Left) Then
			$smallest.Left = $oCtrl.Left
		EndIf

		If Int($oCtrl.Top) < Int($smallest.Top) Then
			$smallest.Top = $oCtrl.Top
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

	Switch $sel_count >= 1
		Case True
			_remove_all_from_clipboard()

			Local Const $smallest = _left_top_union_rect()

			Local Const $selected = _selected_to_array($sel_count, $smallest)

			_selected_to_clipboard($selected, $sel_count)

;~ 			For $i = 1 To $sel_count
;~ 				$clip_ctrl = $mClipboard[$i]

;~ 				;$clip_ctrl.Left = Abs($smallest.Left - $clip_ctrl.Left)
;~ 				;$clip_ctrl.Top = Abs($smallest.Top - $clip_ctrl.Top)

;~ 				$mClipboard[$i] = $clip_ctrl
;~ 			Next
	EndSwitch
EndFunc   ;==>_copy_selected


;------------------------------------------------------------------------------
; Title...........: _selected_to_array
; Description.....: put all selected controls into an array, (necessary?)
;------------------------------------------------------------------------------
Func _selected_to_array(Const $sel_count, Const $smallest)
	Local $selected[$sel_count][2] ; second dimension is magnitude of the control's rectangle

	Local $i = 0
	For $oCtrl in $oSelected.ctrls
		$selected[$i][0] = $oCtrl
		$selected[$i][1] = _vector_magnitude($smallest.Left, $smallest.Top, $oCtrl.Left, $oCtrl.Top)
		$i += 1
	Next

;~ 	_ArraySort($selected, 0, 0, 0, 1)

	Return $selected
EndFunc   ;==>_selected_to_array


;------------------------------------------------------------------------------
; Title...........: _selected_to_clipboard
; Description.....: add selected controls to clipboard object
;------------------------------------------------------------------------------
Func _selected_to_clipboard(Const $selected, Const $sel_count)
	$oClipboard.removeAll()
	Local $i = 0
	For $oCtrl in $oSelected.ctrls
		$oClipboard.add($selected[$i][0])
		$i += 1
	Next
EndFunc   ;==>_selected_to_clipboard


;------------------------------------------------------------------------------
; Title...........: _PasteSelected
; Description.....: paste selected controls
;------------------------------------------------------------------------------
Func _PasteSelected($bDuplicate = False)
	Local Const $clipboard_count = $oClipboard.count
	Local $aNewCtrls[$clipboard_count]

	Switch $clipboard_count >= 1
		Case True
			Local $oNewCtrl,  $i=0

			For $oCtrl in $oClipboard.ctrls
				;create a copy, so we don't overwrite the original!
				$oNewCtrl = $oClipboard.getCopy($oCtrl)

				If $bDuplicate Then
					$oNewCtrl.Left += 20
					$oNewCtrl.Top += 20
				Else
					$oNewCtrl.Left += $mMouse.X
					$oNewCtrl.Top += $mMouse.Y
				EndIf

				Local $oNewCtrl = _create_ctrl($clipboard)
				$aNewCtrls[$i] = $oNewCtrl
				$i += 1
			Next
	EndSwitch

	If $bDuplicate Then
		For $i = 0 To UBound($aNewCtrls) - 1
			$oNewCtrl = $aNewCtrls[$i]

			If $i = 0 Then    ;select first item
				_add_to_selected($oNewCtrl)
				_populate_control_properties_gui($oNewCtrl)
			Else    ;add to selection
				_add_to_selected($oNewCtrl, False)
			EndIf
		Next
	EndIf

	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_PasteSelected


;------------------------------------------------------------------------------
; Title...........: _DuplicateSelected
; Description.....: copy then paste selected controls at an offset
;------------------------------------------------------------------------------
Func _DuplicateSelected()
	If $mSelected.SelectedCount < 1 Then Return
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

	For $oCtrl in $oSelected.ctrls
		$tooltip &= $oCtrl.Name & ": X:" & $oCtrl.Left & ", Y:" & $oCtrl.Top & ", W:" & $oCtrl.Width & ", H:" & $oCtrl.Height & @CRLF
	Next

	ToolTip(StringTrimRight($tooltip, 2))
EndFunc   ;==>_display_selected_tooltip

Func _control_intersection(Const $oCtrl, Const $oRect)
	If __WinAPI_PtInRectEx($oCtrl.Left, $oCtrl.Top, $oRect.Left, $oRect.Top, $oRect.Width, $oRect.Height) Then
		Return True
	EndIf

	Return False
EndFunc   ;==>_control_intersection

Func _group_select(Const $oCtrl)
	If $oCtrl.Type = "Group" Then
		_select_control_group($oCtrl)

		_set_current_mouse_pos()

		_hide_grippies()

		$mode = $init_move

		;ConsoleWrite("$init_move" & @CRLF)

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
	For $oCtrl in $oCtrls.ctrls

		If _control_intersection($oCtrl, $oGroupRect) Then
			_add_to_selected($oCtrl, False)
		EndIf
	Next
EndFunc   ;==>_select_control_group

Func _add_to_selected(Const $oCtrl, Const $overwrite = True)
	If Not IsObj($oCtrl) Then
		Return
	EndIf

	Switch $overwrite
		Case True
			_remove_all_from_selected()

		Case False
			Switch $oSelected.exists($oCtrl)
				Case True
					Return SetError(1, 0, False)
			EndSwitch
	EndSwitch

	$oSelected.add($oCtrl)

	_enable_control_properties_gui()
	_populate_control_properties_gui($oCtrl)
	_show_grippies($oCtrl)

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

