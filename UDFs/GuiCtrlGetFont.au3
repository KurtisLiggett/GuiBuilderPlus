#include <WinAPI.au3>
#include <WindowsConstants.au3>

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlGetFont
; Description ...: Gets the font of a GUI Control
; Syntax.........: _GUICtrlGetFont( [$hWnd] )
; Parameters ....: $hWnd        - [optional] ControlID or Handle of the control. Default is last created GUICtrl... (-1)
;
; Return values .: Success      - Array[5] with options of font:
;                                 [0] - FontSize (~ approximation)
;                                 [1] - Font weight (400 = normal).
;                                 [2] - italic:2 underlined:4 strike:8 char format (styles added together, 2+4 = italic and underlined).
;                                 [3] - The name of the font to use.
;                                 [4] - Font quality to select (PROOF_QUALITY=2 is default in AutoIt).
;
;                  Failure      - Array[5] with empty fields, @error set to nonzero
;
; Author ........: KaFu, Prog@ndy
;
; Comments.......: The FontSize returned is an approximation of the actual fontsize used for the control.
;                  The height of the font returned by GetObject is the height of the font's character cell or character in logical units.
;                  The character height value (also known as the em height) is the character cell height value minus the internal-leading value.
;                  The font mapper interprets the value specified in lfHeight. The result returned by the font mapper is not easily reversible
;                  The FontSize calculated below is an approximation of the actual size used for the analyzed control, qualified enough to use
;                  in another call to the font mapper resulting in the same font size as the the original font.
; MSDN.. ........: Windows Font Mapping: http://msdn.microsoft.com/en-us/library/ms969909(loband).aspx
; ===============================================================================================================================
Func _GUICtrlGetFont($hWnd = -1)
    Local $aReturn[5], $hObjOrg

    If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
    If Not IsHWnd($hWnd) Then Return SetError(1, 0, $aReturn)

    Local $hFONT = _SendMessage($hWnd, $WM_GETFONT)
    If Not $hFONT Then Return SetError(2, 0, $aReturn)

    Local $hDC = _WinAPI_GetDC($hWnd)
    $hObjOrg = _WinAPI_SelectObject($hDC, $hFONT)
    Local $tFONT = DllStructCreate($tagLOGFONT)
    Local $aRet = DllCall('gdi32.dll', 'int', 'GetObjectW', 'ptr', $hFONT, 'int', DllStructGetSize($tFONT), 'ptr', DllStructGetPtr($tFONT))
    If @error Or $aRet[0] = 0 Then
        _WinAPI_SelectObject($hDC, $hObjOrg)
        _WinAPI_ReleaseDC($hWnd, $hDC)
        Return SetError(3, 0, $aReturn)
    EndIf

    ; Need to extract FontFacename separately  => DllStructGetData($tFONT, 'FaceName') is only valid if FontFacename has been set explicitly!
    $aRet = DllCall("gdi32.dll", "int", "GetTextFaceW", "handle", $hDC, "int", 0, "ptr", 0)
    Local $nCount = $aRet[0]
    Local $tBuffer = DllStructCreate("wchar[" & $aRet[0] & "]")
    Local $pBuffer = DllStructGetPtr($tBuffer)
    $aRet = DllCall("Gdi32.dll", "int", "GetTextFaceW", "handle", $hDC, "int", $nCount, "ptr", $pBuffer)
    If @error Then
        _WinAPI_SelectObject($hDC, $hObjOrg)
        _WinAPI_ReleaseDC($hWnd, $hDC)
        Return SetError(4, 0, $aReturn)
    EndIf
    $aReturn[3] = DllStructGetData($tBuffer, 1) ; FontFacename

    $aReturn[0] = Round((-1 * DllStructGetData($tFONT, 'Height')) * 72 / _WinAPI_GetDeviceCaps($hDC, 90), 1) ; $LOGPIXELSY = 90 => DPI aware

    _WinAPI_SelectObject($hDC, $hObjOrg)
    _WinAPI_ReleaseDC($hWnd, $hDC)

    $aReturn[1] = DllStructGetData($tFONT, 'Weight')
    $aReturn[2] = 2 * (True = DllStructGetData($tFONT, 'Italic')) + 4 * (True = DllStructGetData($tFONT, 'Underline')) + 8 * (True = DllStructGetData($tFONT, 'StrikeOut'))
    $aReturn[4] = DllStructGetData($tFONT, 'Quality')

    Return $aReturn

EndFunc   ;==>_GUICtrlGetFont