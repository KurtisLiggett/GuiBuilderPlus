; #HEADER# ======================================================================================================================
; Title .........: GuiBuilderPlus_CtrlMgmt.au3
; Description ...: Control creation and management
; ===============================================================================================================================


;------------------------------------------------------------------------------
; Title...........: _create_ctrl
; Description.....: create new control and add it to the ctrls object
; Called by.......: Draw with mouse; Paste
;------------------------------------------------------------------------------
Func _create_ctrl($oCtrl = '', $bUseName = False)
	Local $oNewControl, $incTypeCount = True
	Local $isPaste = False

	Switch IsObj($oCtrl)
		Case True
			$isPaste = True
			$oNewControl = $oCtrl

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
			$oNewControl.Type = $oCtrls.CurrentType
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

		If $count >= 1 Then
			For $oCtrl In $oCtrls.ctrls

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
			If $oNewControl.TabCount = 1 Then
				$incTypeCount = False
			EndIf

			If $incTypeCount Then    ;create the main control
				;create main tab control
				$oNewControl.Hwnd = GUICtrlCreateTab($oNewControl.Left, $oNewControl.Top, $oNewControl.Width, $oNewControl.Height)
				GUICtrlSetOnEvent($oNewControl.Hwnd, "_onCtrlTabSwitch")

				$oCtrls.add($oNewControl)
			EndIf

			GUISwitch($hGUI)

			_hide_grid($background)
			If BitAND(GUICtrlRead($menu_show_grid), $GUI_CHECKED) = $GUI_CHECKED Then
				_show_grid($background, $oMain.Width, $oMain.Height)
			EndIf

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

		Case "Menu"
			$oNewControl.Hwnd = GUICtrlCreateMenu("Menu 1")
			$oNewControl.Left = -1
			$oNewControl.Top = -1
			$oNewControl.Width = 0
			$oNewControl.Height = 0

			$oCtrls.add($oNewControl)

			;resize the GUI for menu
;~ 			WinMove($hGUI, "", Default, Default, Default, $oMain.Height + $iGuiFrameH + _WinAPI_GetSystemMetrics($SM_CYMENU))
	EndSwitch

	If $incTypeCount Then
		$oCtrls.incTypeCount($oNewControl.Type)

		Switch IsObj($oCtrl)
			Case True    ;paste from existing object
				GUICtrlSetData($oNewControl.Hwnd, $oNewControl.Text)

			Case False    ;new object
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
	Local $oCtrl

	For $oCtrl In $oCtrls.ctrls
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
	$oCtrl.Tabs.add($tab)

	_GUICtrlTab_SetCurSel($oCtrl.Hwnd, $oCtrl.TabCount - 1)

	_refreshGenerateCode()
	_formObjectExplorer_updateList()
EndFunc   ;==>_new_tab


Func _onCtrlTabSwitch()

EndFunc   ;==>_onCtrlTabSwitch


Func _delete_tab()
	Local $oCtrl

	For $oCtrl In $oCtrls.ctrls
		If $oCtrl.Type = "Tab" Then
			ExitLoop
		EndIf
	Next

	Local $iTabFocus = _GUICtrlTab_GetCurSel($oCtrl.Hwnd)

	If $iTabFocus >= 0 Then
		_GUICtrlTab_DeleteItem($oCtrl.Hwnd, $iTabFocus)
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



Func _control_type()
	$oCtrls.CurrentType = GUICtrlRead(@GUI_CtrlId, 1)
	ConsoleWrite("tool selected: " & $oCtrls.CurrentType & @CRLF)

	$oCtrls.mode = $mode_draw
EndFunc   ;==>_control_type


;------------------------------------------------------------------------------
; Title...........: _delete_ctrl
; Description.....: delete control from GUI and remove the data object
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
	Local $sel_ctrl

	Local $smallest[]

	$smallest.Left = $oCtrls.getFirst().Left
	$smallest.Top = $oCtrls.getFirst().Top

	For $oCtrl In $oSelected.ctrls

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
			$oClipboard.removeAll()


			Local Const $smallest = _left_top_union_rect()

			Local Const $selected = _selected_to_array($sel_count, $smallest)

			_selected_to_clipboard($selected, $sel_count)

	EndSwitch
EndFunc   ;==>_copy_selected


;------------------------------------------------------------------------------
; Title...........: _selected_to_array
; Description.....: put all selected controls into an array, (necessary?)
;------------------------------------------------------------------------------
Func _selected_to_array(Const $sel_count, Const $smallest)
	Local $selected[$sel_count][2] ; second dimension is magnitude of the control's rectangle

	Local $i = 0
	For $oCtrl In $oSelected.ctrls
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
	For $oCtrl In $oSelected.ctrls
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
			Local $oNewCtrl, $i = 0

			For $oCtrl In $oClipboard.ctrls
				;create a copy, so we don't overwrite the original!
				$oNewCtrl = $oClipboard.getCopy($oCtrl.Hwnd)

				If $bDuplicate Then
					$oNewCtrl.Left += 20
					$oNewCtrl.Top += 20
				Else
					$oNewCtrl.Left = $oMouse.X
					$oNewCtrl.Top = $oMouse.Y
				EndIf

				$aNewCtrls[$i] = _create_ctrl($oNewCtrl)
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

	For $oCtrl In $oSelected.ctrls
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
	For $oCtrl In $oCtrls.ctrls

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
			Switch $oSelected.exists($oCtrl.Hwnd)
				Case True
					Return SetError(1, 0, False)
			EndSwitch
	EndSwitch

	$oSelected.add($oCtrl)

;~ 	_enable_control_properties_gui()
	_showProperties($props_Ctrls)
	_populate_control_properties_gui($oCtrl)
	$oCtrl.grippies.show()

	Return True
EndFunc   ;==>_add_to_selected


;------------------------------------------------------------------------------
; Title...........: _selectAll
; Description.....: Select all controls
;------------------------------------------------------------------------------
Func _selectAll()
	Local $first = True

	_SendMessage($hGUI, $WM_SETREDRAW, False)
	For $oCtrl In $oCtrls.ctrls
		If $first Then
			_add_to_selected($oCtrl)
			$first = False
		Else
			_add_to_selected($oCtrl, False)
		EndIf
	Next
	_SendMessage($hGUI, $WM_SETREDRAW, True)
	_WinAPI_RedrawWindow($hGUI)
	$oCtrls.mode = $mode_selection
EndFunc   ;==>_selectAll
#EndRegion ; selection


;------------------------------------------------------------------------------
; Title...........: _add_remove_selected_control
; Description.....: while dragging selection rectangle, add controls as the
;					as the rectangle intersects with the controls
;------------------------------------------------------------------------------
Func _add_remove_selected_control(Const $oRect)
	For $oCtrl In $oCtrls.ctrls
		Switch _control_intersection($oCtrl, $oRect)
			Case True
				Switch _add_to_selected($oCtrl, False)
					Case True
						_populate_control_properties_gui($oCtrl)

						_display_selected_tooltip()
				EndSwitch

			Case False
				Switch _remove_from_selected($oCtrl)
					Case True
						Local $sel_count = $oSelected.count

						Switch $sel_count >= 1
							Case True
								_populate_control_properties_gui($oSelected.getLast())

;~ 								$oSelected.getLast().grippies.show()

							Case False
;~ 								_clear_control_properties_gui()

;~ 								_disable_control_properties_gui()
								_showProperties($props_Main)

;~ 								_hide_grippies()
;~ 								$oCtrl.grippies.hide()
						EndSwitch

						_display_selected_tooltip()
				EndSwitch
		EndSwitch
	Next
EndFunc   ;==>_add_remove_selected_control

Func _remove_all_from_selected()
	$oSelected.removeAll()

;~ 	_hide_grippies()

;~ 	_disable_control_properties_gui()
	_showProperties($props_Main)

	Return True
EndFunc   ;==>_remove_all_from_selected

Func _delete_selected_controls()
	Local Const $sel_count = $oSelected.count

	Switch $sel_count >= 1
		Case True
;~ 			_clear_control_properties_gui()
			For $oCtrl In $oSelected.ctrls
				_delete_ctrl($oCtrl)
			Next

;~ 			_hide_grippies()

			_recall_overlay()

			_set_default_mode()

			_refreshGenerateCode()

			If $oSelected.count > 0 Then
				_populate_control_properties_gui($oSelected.getFirst())
				_showProperties($props_Ctrls)
			Else
				_showProperties($props_Main)
			EndIf

			Return True

		Case False
			_showProperties($props_Main)
	EndSwitch

EndFunc   ;==>_delete_selected_controls

Func _remove_from_selected(Const $oCtrl)
	If Not IsObj($oCtrl) Then
		Return
	EndIf

	Switch $oSelected.exists($oCtrl.Hwnd)
		Case False
			Return SetError(1, 0, False)
	EndSwitch

	For $oThisCtrl In $oSelected.ctrls
		Switch $oCtrl.Hwnd
			Case $oThisCtrl.Hwnd
				$oSelected.remove($oThisCtrl.Hwnd)
				ExitLoop
		EndSwitch
	Next

	$oCtrl.grippies.hide()

;~ 	_enable_control_properties_gui()
	If $oSelected.count > 0 Then
		_showProperties($props_Ctrls)
	Else
		_showProperties($props_Main)
	EndIf

	Return True
EndFunc   ;==>_remove_from_selected


Func _display_selection_rect(Const $oRect)
	GUICtrlSetPos($overlay, $oRect.Left, $oRect.Top, $oRect.Width, $oRect.Height)
EndFunc   ;==>_display_selection_rect

Func _hide_selected_controls()
	For $oCtrl In $oSelected.ctrls
		If Not $setting_show_control Then
			GUICtrlSetState($oCtrl.Hwnd, $GUI_HIDE)
		EndIf
	Next
EndFunc   ;==>_hide_selected_controls

Func _show_selected_controls()
	For $oCtrl In $oSelected.ctrls
		If Not $setting_show_control Then
			GUICtrlSetState($oCtrl.Hwnd, $GUI_SHOW)
		EndIf
	Next
EndFunc   ;==>_show_selected_controls


#Region ; moving & resizing
Func _change_ctrl_size_pos(ByRef $oCtrl, Const $left, Const $top, Const $width, Const $height)
	If $width < 1 Or $height < 1 Then
		Return
	EndIf

	Switch $oCtrl.Type
		Case "Updown"
			GUICtrlSetPos($oCtrl.Hwnd1, $left, $top, $width, $height)

		Case Else
			GUICtrlSetPos($oCtrl.Hwnd, $left, $top, $width, $height)
	EndSwitch

	$oCtrl.Left = $left
	$oCtrl.Top = $top
	$oCtrl.Width = $width
	$oCtrl.Height = $height
EndFunc   ;==>_change_ctrl_size_pos


#Region ; grippies
;~ Func _set_resize_mode()
;~ 	Switch @GUI_CtrlId
;~ 		Case $SouthEast_Grippy
;~ 			$oCtrls.mode = $resize_se

;~ 		Case $NorthWest_Grippy
;~ 			$oCtrls.mode = $resize_nw

;~ 		Case $North_Grippy
;~ 			$oCtrls.mode = $resize_n

;~ 		Case $NorthEast_Grippy
;~ 			$oCtrls.mode = $resize_ne

;~ 		Case $East_Grippy
;~ 			$oCtrls.mode = $resize_e

;~ 		Case $SouthEast_Grippy
;~ 			$oCtrls.mode = $resize_se

;~ 		Case $South_Grippy
;~ 			$oCtrls.mode = $resize_s

;~ 		Case $SouthWest_Grippy
;~ 			$oCtrls.mode = $resize_sw

;~ 		Case $West_Grippy
;~ 			$oCtrls.mode = $resize_w
;~ 	EndSwitch

;~ 	$initResize = True
;~ 	_hide_selected_controls()
;~ EndFunc   ;==>_set_resize_mode

;~ Func _handle_grippy(ByRef $oCtrl, Const $left, Const $top, Const $right, Const $bottom)
;~ 	_set_current_mouse_pos()

;~ 	Switch $oCtrl.Type
;~ 		Case "Slider"
;~ 			GUICtrlSendMsg($oCtrl.Hwnd, 27 + 0x0400, $oCtrl.Height - 20, 0) ; TBS_SETTHUMBLENGTH
;~ 	EndSwitch

;~ 	_change_ctrl_size_pos($oCtrl, $left, $top, $right, $bottom)

;~ 	_show_grippies($oCtrl)

;~ 	Local $oSelectedCtrl = $oSelected.getLast()
;~ 	ToolTip($oSelectedCtrl.Name & ": X:" & $oSelectedCtrl.Left & ", Y:" & $oSelectedCtrl.Top & ", W:" & $oSelectedCtrl.Width & ", H:" & $oSelectedCtrl.Height)
;~ EndFunc   ;==>_handle_grippy

;~ Func _handle_nw_grippy($oCtrl)
;~ 	Local Const $right = ($oCtrl.Width + $oCtrl.Left) - $oMouse.X

;~ 	Local Const $bottom = ($oCtrl.Height + $oCtrl.Top) - $oMouse.Y

;~ 	_handle_grippy($oCtrl, $oMouse.X, $oMouse.Y, $right, $bottom)
;~ EndFunc   ;==>_handle_nw_grippy

;~ Func _handle_n_grippy($oCtrl)
;~ 	Local Const $bottom = ($oCtrl.Top + $oCtrl.Height) - $oMouse.Y

;~ 	_handle_grippy($oCtrl, $oCtrl.Left, $oMouse.Y, $oCtrl.Width, $bottom)
;~ EndFunc   ;==>_handle_n_grippy

;~ Func _handle_ne_grippy($oCtrl)
;~ 	Local Const $bottom = ($oCtrl.Top + $oCtrl.Height) - $oMouse.Y

;~ 	_handle_grippy($oCtrl, $oCtrl.Left, $oMouse.Y, $oMouse.X - $oCtrl.Left, $bottom)
;~ EndFunc   ;==>_handle_ne_grippy

;~ Func _handle_w_grippy($oCtrl)
;~ 	Local Const $right = $oCtrl.Left + $oCtrl.Width

;~ 	_handle_grippy($oCtrl, $oMouse.X, $oCtrl.Top, $right - $oMouse.X, $oCtrl.Height)
;~ EndFunc   ;==>_handle_w_grippy

;~ Func _handle_e_grippy($oCtrl)
;~ 	_handle_grippy($oCtrl, $oCtrl.Left, $oCtrl.Top, $oMouse.X - $oCtrl.Left, $oCtrl.Height)
;~ EndFunc   ;==>_handle_e_grippy

;~ Func _handle_sw_grippy($oCtrl)
;~ 	Local Const $right = ($oCtrl.Left + $oCtrl.Width) - $oMouse.X

;~ 	_handle_grippy($oCtrl, $oMouse.X, $oCtrl.Top, $right, $oMouse.Y - $oCtrl.Top)
;~ EndFunc   ;==>_handle_sw_grippy

;~ Func _handle_s_grippy($oCtrl)
;~ 	_handle_grippy($oCtrl, $oCtrl.Left, $oCtrl.Top, $oCtrl.Width, $oMouse.Y - $oCtrl.Top)
;~ EndFunc   ;==>_handle_s_grippy

;~ Func _handle_se_grippy($oCtrl)
;~ 	_handle_grippy($oCtrl, $oCtrl.Left, $oCtrl.Top, $oMouse.X - $oCtrl.Left, $oMouse.Y - $oCtrl.Top)
;~ EndFunc   ;==>_handle_se_grippy

;~ Func _show_grippies(Const $oCtrl)
;~ 	If Not IsObj($oCtrl) Then
;~ 		Return
;~ 	EndIf

;~ 	Local Const $l = $oCtrl.Left
;~ 	Local Const $t = $oCtrl.Top
;~ 	Local Const $w = $oCtrl.Width
;~ 	Local Const $h = $oCtrl.Height

;~ 	Local Const $nw_left = $l - $grippy_size
;~ 	Local Const $nw_top = $t - $grippy_size
;~ 	Local Const $n_left = $l + ($w - $grippy_size) / 2
;~ 	Local Const $n_top = $nw_top
;~ 	Local Const $ne_left = $l + $w
;~ 	Local Const $ne_top = $nw_top
;~ 	Local Const $e_left = $ne_left
;~ 	Local Const $e_top = $t + ($h - $grippy_size) / 2
;~ 	Local Const $se_left = $ne_left
;~ 	Local Const $se_top = $t + $h
;~ 	Local Const $s_left = $n_left
;~ 	Local Const $s_top = $se_top
;~ 	Local Const $sw_left = $nw_left
;~ 	Local Const $sw_top = $se_top
;~ 	Local Const $w_left = $nw_left
;~ 	Local Const $w_top = $e_top

;~ 	Switch $oCtrl.Type
;~ 		Case "Combo", "Checkbox", "Radio"
;~ 			GUICtrlSetPos($East_Grippy, $e_left, $e_top, $grippy_size, $grippy_size)
;~ 			GUICtrlSetPos($West_Grippy, $w_left, $w_top, $grippy_size, $grippy_size)

;~ 		Case Else
;~ 			GUICtrlSetPos($NorthWest_Grippy, $nw_left, $nw_top, $grippy_size, $grippy_size)
;~ 			GUICtrlSetPos($North_Grippy, $n_left, $n_top, $grippy_size, $grippy_size)
;~ 			GUICtrlSetPos($NorthEast_Grippy, $ne_left, $ne_top, $grippy_size, $grippy_size)
;~ 			GUICtrlSetPos($East_Grippy, $e_left, $e_top, $grippy_size, $grippy_size)
;~ 			GUICtrlSetPos($SouthEast_Grippy, $se_left, $se_top, $grippy_size, $grippy_size)
;~ 			GUICtrlSetPos($South_Grippy, $s_left, $s_top, $grippy_size, $grippy_size)
;~ 			GUICtrlSetPos($SouthWest_Grippy, $sw_left, $sw_top, $grippy_size, $grippy_size)
;~ 			GUICtrlSetPos($West_Grippy, $w_left, $w_top, $grippy_size, $grippy_size)
;~ 	EndSwitch
;~ EndFunc   ;==>_show_grippies

;~ Func _hide_grippies()
;~ 	GUICtrlSetPos($NorthWest_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
;~ 	GUICtrlSetPos($North_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
;~ 	GUICtrlSetPos($NorthEast_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
;~ 	GUICtrlSetPos($East_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
;~ 	GUICtrlSetPos($SouthEast_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
;~ 	GUICtrlSetPos($South_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
;~ 	GUICtrlSetPos($SouthWest_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)
;~ 	GUICtrlSetPos($West_Grippy, -$grippy_size, -$grippy_size, $grippy_size, $grippy_size)

;~ EndFunc   ;==>_hide_grippies

Func _move_mouse_to_grippy(Const $x, Const $y)
	Local Const $mouse_coord_mode = Opt("MouseCoordMode", 2)

	MouseMove(Int($x + ($grippy_size / 2)), Int($y + ($grippy_size / 2)), 0)

	Opt("MouseCoordMode", $mouse_coord_mode)
EndFunc   ;==>_move_mouse_to_grippy
#EndRegion ; grippies
#EndRegion ; moving & resizing


#Region ; overlay management
Func _dispatch_overlay(Const $oCtrl)
	; ConsoleWrite($oCtrl.Name & @CRLF)

	GUICtrlSetPos($overlay, $oCtrl.Left, $oCtrl.Top, $oCtrl.Width, $oCtrl.Height)

	GUICtrlSetState($overlay, $GUI_ONTOP)
EndFunc   ;==>_dispatch_overlay

Func _recall_overlay()
	GUICtrlSetPos($overlay, -1, -1, 1, 1)
EndFunc   ;==>_recall_overlay
#EndRegion ; overlay management

