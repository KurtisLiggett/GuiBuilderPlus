#include-once
#include <GuiScrollBars.au3>

Global $aColumnOrder = 0, $aColumnOrderReverse, $aColumnWidths
Global  $aColLeftEdgePosAcc ; Accumulated left edge positions of columns in left to right column order

Func MakeColumnVisible( $hListView, $iSubItem, ByRef $aRect, $iItem = -1 )
	Local Static $tSCROLLINFO = 0
	If Not IsDllStruct( $tSCROLLINFO ) Then
		$tSCROLLINFO = DllStructCreate( $tagSCROLLINFO )
		DllStructSetData( $tSCROLLINFO, "cbSize", DllStructGetSize( $tSCROLLINFO ) )
		DllStructSetData( $tSCROLLINFO, "fMask", $SIF_POS )
	EndIf

	; Set control width equal to width of subitem rectangle
	Local $iCtrlWidth = $aRect[2] - $aRect[0]
	Local $iLvWidth = WinGetClientSize( $hListView )[0]
	Local $iMaxWidth = $iLvWidth
	If $aRect[0] < 0 Then
		; Take into account that a column may be only partially visible along the left edge of the ListView
		; Scroll the ListView to the left to align the left edge of the column to the left edge of the ListView
		Local $iColLeftEdge = $aColLeftEdgePosAcc[$aColumnOrderReverse[$iSubItem]-1]
		_GUIScrollBars_GetScrollInfo( $hListView, $SB_HORZ, $tSCROLLINFO )
		Local $nPos = DllStructGetData( $tSCROLLINFO, "nPos" )
		_GUICtrlListView_Scroll( $hListView, $iColLeftEdge - $nPos, 0 )
		; Necessary to recalculate $aRect in examples without keyboard support
		; In examples with keyboard support this is done in the custom draw code
		If $iItem <> -1 Then 
			If $iSubItem Then
				$aRect = _GUICtrlListView_GetSubItemRect( $hListView, $iItem, $iSubItem )
				$aRect[2] = $aRect[0] + $aColumnWidths[$iSubItem]
			Else
				$aRect = _GUICtrlListView_GetItemRect( $hListView, $iItem, 2 ) ; 2 - The bounding rectangle of the item text
				$aRect[0] -= 4
			EndIf
		EndIf
	Else
		; Maximum room for control
		$iMaxWidth = $iLvWidth - $aRect[0]
		If $iCtrlWidth > $iMaxWidth And $iMaxWidth < 50 Then
			; Take into account that a column may be only partially visible along the right edge of the ListView
			; If less than 50 pixels of a column is visible, then scroll the ListView to the right to get room for the control
			$iMaxWidth = 50
			$iCtrlWidth = 50
			Local $iColRightEdge = $aColLeftEdgePosAcc[$aColumnOrderReverse[$iSubItem]-1] + $iCtrlWidth
			_GUIScrollBars_GetScrollInfo( $hListView, $SB_HORZ, $tSCROLLINFO )
			Local $nPos = DllStructGetData( $tSCROLLINFO, "nPos" )
			_GUICtrlListView_Scroll( $hListView, $iColRightEdge - $iLvWidth - $nPos, 0 )
			; Necessary to recalculate $aRect in examples without keyboard support
			; In examples with keyboard support this is done in the custom draw code
			If $iItem <> -1 Then 
				If $iSubItem Then
					$aRect = _GUICtrlListView_GetSubItemRect( $hListView, $iItem, $iSubItem )
					$aRect[2] = $aRect[0] + $aColumnWidths[$iSubItem]
				Else
					$aRect = _GUICtrlListView_GetItemRect( $hListView, $iItem, 2 ) ; 2 - The bounding rectangle of the item text
					$aRect[0] -= 4
				EndIf
			EndIf
		EndIf
	EndIf
	If $iCtrlWidth >= $iMaxWidth Then $iCtrlWidth = $iMaxWidth - 2
	Return $iCtrlWidth
EndFunc

Func CalcColumnOrderArrays( $hListView )
	If Not IsArray( $aColumnOrder ) Then
		; Calculate $aColumnOrderReverse array
		$aColumnOrder = _GUICtrlListView_GetColumnOrderArray( $hListView ) ; $aColumnOrder specifies $iSubItem with column number as index
		$aColumnOrderReverse = $aColumnOrder                               ; $aColumnOrderReverse specifies column number with $iSubItem as index
		For $i = 1 To $aColumnOrder[0]
			$aColumnOrderReverse[$aColumnOrder[$i]] = $i
		Next
		; Calculate accumulated left edge positions of columns in left to right column order
		$aColLeftEdgePosAcc = $aColumnOrder
		$aColLeftEdgePosAcc[0] = 0
		For $i = 1 To $aColumnOrder[0] - 1
			$aColLeftEdgePosAcc[$i] = $aColLeftEdgePosAcc[$i-1] + $aColumnWidths[$aColumnOrder[$i]]
		Next
	ElseIf Not IsArray( $aColLeftEdgePosAcc ) Then
		; Calculate accumulated left edge positions of columns in left to right column order
		$aColLeftEdgePosAcc = $aColumnOrder
		$aColLeftEdgePosAcc[0] = 0
		For $i = 1 To $aColumnOrder[0] - 1
			$aColLeftEdgePosAcc[$i] = $aColLeftEdgePosAcc[$i-1] + $aColumnWidths[$aColumnOrder[$i]]
		Next
	EndIf
EndFunc

Func SetLeftCellFocused( $hListView, $iItem, ByRef $iSubItem )
	Local Static $tSCROLLINFO = 0
	If Not IsDllStruct( $tSCROLLINFO ) Then
		$tSCROLLINFO = DllStructCreate( $tagSCROLLINFO )
		DllStructSetData( $tSCROLLINFO, "cbSize", DllStructGetSize( $tSCROLLINFO ) )
		DllStructSetData( $tSCROLLINFO, "fMask", $SIF_POS )
	EndIf

	If $aColumnOrderReverse[$iSubItem] > 1 Then
		Local $i = $aColumnOrder[$aColumnOrderReverse[$iSubItem]-1]
		While $aColumnOrderReverse[$i] > 1 And Not $aColumnWidths[$i]
			$i = $aColumnOrder[$aColumnOrderReverse[$i]-1]
		WEnd
		If $aColumnWidths[$i] Then $iSubItem = $i
	EndIf
	; Make entire column visible in left part of ListView
	Local $iColLeftEdge = $aColLeftEdgePosAcc[$aColumnOrderReverse[$iSubItem]-1]
	_GUIScrollBars_GetScrollInfo( $hListView, $SB_HORZ, $tSCROLLINFO )
	Local $nPos = DllStructGetData( $tSCROLLINFO, "nPos" )
	If $iColLeftEdge < $nPos Then
		_GUICtrlListView_Scroll( $hListView, $iColLeftEdge - $nPos + 5, 0 )
	Else
		; Make entire column visible in right part of ListView
		Local $iSizeX = WinGetClientSize( $hListView )[0]
		Local $iColRightEdge = $iColLeftEdge + $aColumnWidths[$iSubItem]
		If $iColRightEdge > $iSizeX + $nPos Then _
			_GUICtrlListView_Scroll( $hListView, $iColRightEdge - $iSizeX - $nPos + 5, 0 )
	EndIf
	; Redraw ListView item
	_GUICtrlListView_RedrawItems( $hListView, $iItem, $iItem )
EndFunc

Func SetRightCellFocused( $hListView, $iItem, ByRef $iSubItem )
	Local Static $tSCROLLINFO = 0
	If Not IsDllStruct( $tSCROLLINFO ) Then
		$tSCROLLINFO = DllStructCreate( $tagSCROLLINFO )
		DllStructSetData( $tSCROLLINFO, "cbSize", DllStructGetSize( $tSCROLLINFO ) )
		DllStructSetData( $tSCROLLINFO, "fMask", $SIF_POS )
	EndIf

	If $aColumnOrderReverse[$iSubItem] < $aColumnOrder[0] Then
		Local $i = $aColumnOrder[$aColumnOrderReverse[$iSubItem]+1]
		While $aColumnOrderReverse[$i] < $aColumnOrder[0] And Not $aColumnWidths[$i]
			$i = $aColumnOrder[$aColumnOrderReverse[$i]+1]
		WEnd
		If $aColumnWidths[$i] Then $iSubItem = $i
	EndIf
	; Make entire column visible in right part of ListView
	Local $iWidth = $aColumnWidths[$iSubItem], $iSizeX = WinGetClientSize( $hListView )[0]
	Local $iColRightEdge = $aColLeftEdgePosAcc[$aColumnOrderReverse[$iSubItem]-1] + ( $iWidth > $iSizeX ? $iSizeX : $iWidth )
	_GUIScrollBars_GetScrollInfo( $hListView, $SB_HORZ, $tSCROLLINFO )
	Local $nPos = DllStructGetData( $tSCROLLINFO, "nPos" )
	If $iColRightEdge > $iSizeX + $nPos Then
		_GUICtrlListView_Scroll( $hListView, $iColRightEdge - $iSizeX - $nPos - 5, 0 )
	Else
		; Make entire column visible in left part of ListView
		Local $iColLeftEdge = $aColLeftEdgePosAcc[$aColumnOrderReverse[$iSubItem]-1]
		If $iColLeftEdge < $nPos Then _
			_GUICtrlListView_Scroll( $hListView, $iColLeftEdge - $nPos - 5, 0 )
	EndIf
	; Redraw ListView item
	_GUICtrlListView_RedrawItems( $hListView, $iItem, $iItem )
EndFunc

; Get mouse pos relative to window
Func MouseGetWindowPos( $hWindow )
	Local $aPos = MouseGetPos()
	Local $tPoint = DllStructCreate( "int X;int Y" )
	DllStructSetData( $tPoint, "X", $aPos[0] )
	DllStructSetData( $tPoint, "Y", $aPos[1] )
	_WinAPI_ScreenToClient( $hWindow, $tPoint )
	$aPos[0] = DllStructGetData( $tPoint, "X" )
	$aPos[1] = DllStructGetData( $tPoint, "Y" )
	Return $aPos
EndFunc
