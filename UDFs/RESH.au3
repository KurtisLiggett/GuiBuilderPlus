#Region Header
; #INDEX# =======================================================================================================================
; Title .........: RESH
; AutoIt Version : v3.3.8.0
; Language ......: English
; Description ...: Functions to genterate AU3 Syntax Highlighted RTF (Rich Text Format) code for RichEdit Controls
; Author(s) .....: Brian J Christy (Beege)
; Modified by ...: Robjong
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _RESH_SyntaxHighlight
; _RESH_SetColorTable
; _RESH_GenerateRTFCode
; ===============================================================================================================================
#include-once
#include <GuiRichEdit.au3>
#include <array.au3>
#include <Color.au3>
#EndRegion Header

#Region Global Variables and Constants

Global $g_cbCheckString = DllCallbackRegister('_CheckSendKeys', 'uint', 'uint;uint')
Global $g_cbCheckUDFs = DllCallbackRegister('_CheckUDFs', 'uint', 'uint')
Global $g_pcbCheckString = DllCallbackGetPtr($g_cbCheckString)
Global $g_pcbCheckUDFs = DllCallbackGetPtr($g_cbCheckUDFs)

OnAutoItExitRegister('__RESH_Exit')

Global $g_aAutoitVersion = StringSplit(@AutoItVersion, '.', 2)
Global $g_AutoitIsBeta = $g_aAutoitVersion[2] > 8

Global $g_RESH_VIEW_TIMES = False

Global $g_iTagBegin, $g_iTagEnd, $g_iTagComment
Global $g_iTagDS, $g_iTagDE, $g_iTagSS, $g_iTagSE

Global $g_RESH_iFontSize = 18
Global $g_RESH_sFont = 'Courier New'
;~ Global $g_RESH_sFont = 'MS Shell Dlg'

Global Const $g_RESH_sDefaultColorTable = '' & _
		'\red240\green0\blue255;' & _ ;		Marcos - 0
		'\red153\green153\blue204;' & _ ; 	Strings - 1
		'\red160\green15\blue240;' & _ ; 	Special - 2
		'\red0\green153\blue51;' & _ ; 		Comments - 3
		'\red170\green0\blue0;' & _ ; 		Variables - 4
		'\red255\green0\blue0;' & _ ; 		Operators - 5
		'\red172\green0\blue169;' & _ ; 	Numbers - 6
		'\red0\green0\blue255;' & _ ; 		Keywords - 7
		'\red0\green128\blue255;' & _ ; 	UDF's - 8
		'\red255\green136\blue0;' & _ ; 	Send keys - 9
		'\red0\green0\blue144;' & _	;		Functions's - 10
		'\red240\green0\blue255;' & _ ;		Preprocessor - 11
		'\red0\green0\blue255;' ; 			comobjects - 12

Global $g_RESH_sColorTable = $g_RESH_sDefaultColorTable

Global Const $g_cMacro = 'cf1'
Global Const $g_cString = 'cf2'
Global Const $g_cSpecial = 'cf3'
Global Const $g_cComment = 'cf4'
Global Const $g_cVars = 'cf5'
Global Const $g_cOperators = 'cf6'
Global Const $g_cNum = 'cf7'
Global Const $g_cKeyword = 'cf8'
Global Const $g_cUDF = 'cf9'
Global Const $g_cSend = 'cf10'
Global Const $g_cFunctions = 'cf11'
Global Const $g_cPreProc = 'cf12'
Global Const $g_cComObjects = 'cf13'

#EndRegion Global Variables and Constants
$time = TimerInit()
_CheckUDFs(0)
;~ ConsoleWrite('startup = ' & TimerDiff($time) & @LF)
#Region Public Functions
; #FUNCTION# ====================================================================================================
; Name...........:	_RESH_SyntaxHighlight
; Description....:	Replaces AU3 code in a RichEdit with syntax highlighted AU3 code
; Syntax.........:	_RESH_SyntaxHighlight($hRichEdit)
; Parameters.....:	$hRichEdit - Handle to Richedit
;					$sUpdateFunction - A function to call to inform the user of the current status progress. The
;						function to call must be declared with 2 parameters:
;							$iPercent - Percentage of completion
;							$iMsg     - String that indicates what words are currently being highlighted
; Return values..:	Success - Returns Generated RTF Code
;					Failure - None
; Author.........:	Brian J Christy (Beege)
; Remarks........:	None
; ===============================================================================================================
Func _RESH_SyntaxHighlight($hRichEdit, $sUpdateFunction = 0)

	Local $iStart = _GUICtrlRichEdit_GetFirstCharPosOnLine($hRichEdit)
	Local $aScroll = _GUICtrlRichEdit_GetScrollPos($hRichEdit)
	_GUICtrlRichEdit_PauseRedraw($hRichEdit)
	_GUICtrlRichEdit_SetSel($hRichEdit, 0, -1, True)

	Local $sCode = _RESH_GenerateRTFCode(_GUICtrlRichEdit_GetSelText($hRichEdit), $sUpdateFunction)
	_GUICtrlRichEdit_ReplaceText($hRichEdit, '')
	_GUICtrlRichEdit_SetLimitOnText($hRichEdit, Round(StringLen($sCode) * 1.5))

;~ 	_GUICtrlRichEdit_StreamFromVar($hRichEdit, $sCode)
	_GUICtrlRichEdit_AppendText($hRichEdit, $sCode)

	_GUICtrlRichEdit_GotoCharPos($hRichEdit, $iStart)
	_GUICtrlRichEdit_SetScrollPos($hRichEdit, $aScroll[0], $aScroll[1])
	_GUICtrlRichEdit_ResumeRedraw($hRichEdit)

	Return $sCode

EndFunc   ;==>_RESH_SyntaxHighlight

; #FUNCTION# ====================================================================================================
; Name...........:	_RESH_SetColorTable
; Description....:	Replaces AU3 code in a RichEdit with syntax highlighted AU3 code
; Syntax.........:	_RESH_SetColorTable($aColorTable)
; Parameters.....:	$aColorTable - Value can either be the keyword 'Default' or an array of rgb hex values. Values
;						can be in formats 0xRRGGBB or #RRGGBB. Array must be 13 elements and represents the
;						following meanings:
;								$aColorTable[0] =  Marcos
;								$aColorTable[1] =  Strings
;								$aColorTable[2] =  Special
;								$aColorTable[3] =  Comments
;								$aColorTable[4] =  Variables
;								$aColorTable[5] =  Operators
;								$aColorTable[6] =  Numbers
;								$aColorTable[7] =  Keywords
;								$aColorTable[8] =  UDF's
;								$aColorTable[9] =  Send Keys
;								$aColorTable[10] = Functions
;								$aColorTable[11] = PreProcessor
;								$aColorTable[12] = ComObjects
; Return values..:	Success - 1
;					Failure - Returns 0 and sets @error:
;								1 - bad rgb value. Index of bad value in @extended
;								2 - Color Table is not an array or has incorrect dimension size
; Author.........:	Brian J Christy (Beege)
; Remarks........:	None
; ===============================================================================================================
Func _RESH_SetColorTable($aColorTable)

	If $aColorTable = Default Then
		$g_RESH_sColorTable = $g_RESH_sDefaultColorTable
	Else
		If IsArray($aColorTable) And UBound($aColorTable) = 13 Then ;skdjfls
			Local $acolor, $sColorTable
			For $i = 0 To 12
				$acolor = __RESH_GetRGB($aColorTable[$i])
				If @error Then Return SetError(1, $i, 0)
				$sColorTable &= '\red' & $acolor[0] & '\green' & $acolor[1] & '\blue' & $acolor[2] & ';'
			Next
			$g_RESH_sColorTable = $sColorTable
		Else
			Return SetError(2, 0, 0)
		EndIf
	EndIf

	Return 1

EndFunc   ;==>_RESH_SetColorTable

; #FUNCTION# ====================================================================================================
; Name...........:	_RESH_GenerateRTFCode
; Description....:	Generates RTF code for syntax highlighted AU3 code
; Syntax.........:	_RESH_GenerateRTFCode($sAu3Code)
; Parameters.....:	$sAu3Code - AU3 code to convert
; Parameters.....:	$hRichEdit - Handle to Richedit
;					$sUpdateFunction - A function to call to inform the user of the current status progress. The
;							function to call must be declared with 2 parameters:
;								$iPercent - Percentage of completion
;								$iMsg     - String that indicates what words are currently being highlighted
; Return values..:	Success -	Generated RTF Code
;					Failure -	None
; Author.........:	Brian J Christy (Beege)
; Remarks........:	None
; ===============================================================================================================
Func _RESH_GenerateRTFCode($sAu3Code, $sUpdateFunction = 0)

	Local $sRTFCode = $sAu3Code & @CRLF

	__RESH_ReplaceRichEditTags($sRTFCode)
	__RESH_ASM_MC($sRTFCode)
	__RESH_HeaderFooter($sRTFCode)

	Return $sRTFCode

EndFunc   ;==>_RESH_GenerateRTFCode

#EndRegion Public Functions

#Region Machine Code Function
; #FUNCTION# ====================================================================================================
;	Function Flow:
;		The previous version for this library worked by checking for each catagory (variable, keyword, string, etc)
;		one catagory at a time using reg expressions. The libaray works by walking the data ONE TIME and adds the coloring
;		each time it hits a catagory. Each time we hit a catogory, we jump to that catagoys procedure and continue
;		processing until that catagory is over, then return to the main loop, or another catagorey. This makes processing
;		parts like comments and strings very fast.
;		For strings Im passing the data to an autoit function for the send keys. For the UDFs im also passing the data
;		to an auto it function, but only to check if its a function, not modify any data. Using a dictionary, I setup a
;		a structure where the key is the function name and the item for that key is the length. Checking to see if a key
;		exists in a dictionary is very fast, so is the lookup so if it is a key, I pass back the length of the funtion, along
;		with the function type (Native, UDF, Keyword). Code for Native functions and Keywords are built into the assembly
;		code, the reason they are also in the udfs is for case insensitve checks. The assembly code then adds the coloring
;		and copys the bytes specifed by the length.
; ===============================================================================================================
Func __RESH_ASM_MC(ByRef $sSource);$sArray, ByRef $tSource, ByRef $tPtrTable)
	$timer = TimerInit()

	Local Static $bOpCode, $tMem, $fStartup = True

	If $fStartup Then
		;####### (BinaryStrLen = 37368) #### (CompStrLen = 17434) #### (Base64StrLen = 11624 )####################################################################################################
		$bOpCode = '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' & _
				'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' & _
				'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' & _
				'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' & _
				'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' & _
				'BwAAAOlTAChAgT5VRFBTA/hlKm4CfGQFfDMCfFdppG5NA3xvdgI+ZQU+QhMCPklzQWQDPm2SaQu+8wYBPlRDFb5C0wIfSW5ldAMfRxUDn3QFH7MCH09iajhHdRICPwEZABMA6UKZAhlSYW5kAxlvim0FGX8CGUVudg4zQmWCDE51bWKEDHJFhQxLg0NzQm+EJmyFhQwxggxDRFRygwwUYXmFDBeCDE1zZ0pChBl4hQz9BYEMU0h0cmmDDG5nhQzjoYIMSXNGdYQMY4UMesmCDFUAQIQMgZGCDK8hggxCaXROgwxPVFWFDJWFDFiEDFKFDHulhQxBgwxORIUMYUIGlUBHU01HR8QmSFdNIKItQgZBc3PEM2fBd6VCBhPEGW5hQwZyRkfU+QREIE9BdARBJsAKCADp4cIFSXNPYlXCBWrFBcnEBUlCiASLQSXCBbHCBVNsZUKGFARwxQWZwgVGbG8ub8IFQXLCBYHCBVJ1VG5BwgVzxQVpxBdQinTLC1HDKXJlYcIFymvFBTnDEW91wyPBQmXCBSHDI3FyQSjAAgA06Q9DBGXCS0IE/QNZwlh2YUGRQgTrQgRQFmlCgkIE2UIEQ2hySldFBMdDBGFsRg21UUIEQXNjxgijQwRDFm/BNUIEkUIEQmVly0FGQgR/wwhTaUFpQgRSbUIESFcnFFtjBFRqYWYESSACZsBZwikCowEFAAIA6TLDAkzDAquhF8ICG8MCU8J9AoEI1cICBMMCRGI1AmFbwgJs7QLCAkMvAkEvwgLWqcMCUnWLCL/DAkNDDssBHcICqMMCRXjCAqEdbcICkcMCw0YCgTLCAnqtwwJUojpnC2NkC2grEVJMwwJPcIsINcMCQepzyxkewwJIoxyhfsICDgekBQJb5xbwAQAAAIA+X3UygH4BAF90LIpeAYDrADCA+wl3AusfoYIBYYD7GYABEoIBIkGDAQXpjsAGgT5QXHRhYiU0ImI2XKxwYcEWIgIQwy1wgxwFphn5ABFW/1UUgwD4AHQlicHB6QAQZoP4AQ+EfENACiABAg+EhiMBAwgPhFIgAesApOkA57n//4A+AA8EhMOAB8cHXGNmADDGRwQgg8cFrOnMQAMiAjQkAqQCBUKaAAWBPiNjAK8fASG/ZW50dRaBfggIcy2AvA2AfgwgZHUHuQ3gEesCwOvN86TroWsI4BbkI2PhBAJl4AThFuAEQOnzpOl2/8QNMklEBYn6AA4idaIAdAD0iftTUv9VEFCJx+lNEgUnAgUnBQkFJAUFMWbHRwRSMkAFBvNjGNZiMzukdDegAXTt4QuFYQcAqYA+Cg+E7f4hQSI8D4RZoASk68rOQgg25RfpzsADzSJgCnX66bblAqINMWmjDemgpQI5pAVgAoxVZQI4ZwJ4ZQI3pQqKWh7mRfNhASBEBWAB5wdhAUBHYQHbgD54dJjW6TwmD2QH6w/CAYo1xQEAIApfdPqUAy1xJu4UBbEA4pgG1ulc7/3EBBYPaAMRaAMF7OnEpQISDzMRD8kCVQvHsQBSCzQG2+mLhQMVHIlRGXREEBkPhKHSF6VgGGZAAuvmYgIzdhJVcQIccgJ5dQI+cAKkBOvmMBQbt///xggHALhgGwDJwhAAAC=='

		$bOpCode = _B64Decode($bOpCode)

		Local $tBuffers = DllStructCreate('byte[18683];byte[18683]')
		DllStructSetData($tBuffers, 2, $bOpCode)
		Local $aDecompress = DllCall('ntdll.dll', 'uint', 'RtlDecompressBuffer', 'ushort', 0x0002, 'ptr', DllStructGetPtr($tBuffers, 1), 'ulong', 18683, 'ptr', DllStructGetPtr($tBuffers, 2), 'ulong', 8716, 'ulong*', 0)
		If @error Or $aDecompress[0] Then Return SetError(2, 0, 0)
		$bOpCode = BinaryMid(DllStructGetData($tBuffers, 1), 1, $aDecompress[6])

		Local $aMemBuff = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($bOpCode), "dword", 4096, "dword", 64)
		$tMem = DllStructCreate('byte[' & BinaryLen($bOpCode) & ']', $aMemBuff[0])
		DllStructSetData($tMem, 1, $bOpCode)
		;####################################################################################################################################################################################

		$fStartup = False
	EndIf

	Local $iLen = StringLen($sSource) * 5
	Local $tOutput = DllStructCreate('char[' & $iLen & ']')
	DllCall("kernel32.dll", "bool", "VirtualProtect", "struct*", $tOutput, "dword_ptr", DllStructGetSize($tOutput), "dword", 0x00000004, "dword*", 0)

	DllCallAddress('dword', DllStructGetPtr($tMem), 'str', $sSource, 'struct*', $tOutput, 'ptr', $g_pcbCheckString, 'ptr', $g_pcbCheckUDFs)

	$sSource = DllStructGetData($tOutput, 1)

;~ 	ConsoleWrite('RESH ASM = ' & TimerDiff($timer) & @LF)
EndFunc   ;==>__RESH_ASM_MC

#EndRegion Machine Code Function

#Region CallBack Functions
Func _CheckSendKeys($iStartAddress, $iEndAddress)

	Local $sSendKeys = 'alt|altdown|altup|appskey|asc|backspace|break|browser_back|browser_favorites|browser_forward|browser_home|' & _
			'browser_refresh|browser_search|browser_stop|bs|capslock|ctrldown|ctrlup|del|delete|down|end|enter|esc|escape|f\d|f1[12]|' & _
			'home|ins|insert|lalt|launch_app1|launch_app2|launch_mail|launch_media|lctrl|left|lshift|lwin|lwindown|lwinup|media_next|' & _
			'media_play_pause|media_prev|media_stop|numlock|numpad0|numpad1|numpad2|numpad3|numpad4|numpad5|numpad6|numpad7|numpad8|numpad9|numpadadd|' & _
			'numpaddiv|numpaddot|numpadenter|numpadmult|numpadsub|pause|pgdn|pgup|printscreen|ralt|rctrl|right|rshift|rwin|rwindown|rwinup|scrolllock|' & _
			'shiftdown|shiftup|sleep|space|tab|up|volume_down|volume_mute|volume_up'

	Local $iLen = $iEndAddress - $iStartAddress
	Local $tString = DllStructCreate('char[' & $iLen & ']', $iStartAddress)
	Local $sString = DllStructGetData($tString, 1)

	;add send keys color tags
	$sString = StringRegExpReplace($sString, '(?i)([+^!#]*?\\{)(' & $sSendKeys & ')(\\})', '\\' & $g_cSend & ' \1\2\3' & '\\' & $g_cString & ' ')
	If $iLen = StringLen($sString) Then Return $iEndAddress

	$iEndAddress += (StringLen($sString) - $iLen)
	$tString = DllStructCreate('char[' & $iEndAddress - $iStartAddress & ']', $iStartAddress)
	DllStructSetData($tString, 1, $sString)

	Return $iEndAddress

EndFunc   ;==>_CheckSendKeys
Func _CheckUDFs($iStartAddress)

	Local Static $fStartup = True, $oUdfs, $oFunctions, $oKeyWords

	If $fStartup Then

		$oUDFs = ObjCreate("Scripting.Dictionary")
		$oFunctions = ObjCreate("Scripting.Dictionary")
		$oKeywords = ObjCreate("Scripting.Dictionary")

		$oUDFs.CompareMode = 1; case insensitive
		$oFunctions.CompareMode = 1;
		$oKeywords.CompareMode = 1;

		Local $aUdfs = __GetUDFs()
		$aUdfs = StringSplit($aUdfs, '|', 2)
		For $i = 0 To UBound($aUdfs) - 1
			If Not $oUDFs.Exists($aUdfs[$i]) Then
				$oUDFs.Add($aUdfs[$i], StringLen($aUdfs[$i]))
			EndIf
		Next

		Local $aFunctions = __Functions()
		$aFunctions = StringSplit($aFunctions, '|', 2)
		For $i = 0 To UBound($aFunctions) - 1
			If Not $oFunctions.Exists($aFunctions[$i]) Then
				$oFunctions.Add($aFunctions[$i], StringLen($aFunctions[$i]))
			EndIf
		Next

		Local $sKeywords = 'ReDim|And|ByRef|Case|Const|ContinueCase|ContinueLoop|Default|Dim|Do|ElseIf|Else|EndFunc|EndIf|EndSelect|EndSwitch|EndWith|Enum|Exit|ExitLoop|False|For|Func|Global|If|In|Local|Next|Not|Null|Return|Select|Static|Step|Switch|Then|To|True|Until|Volatile|WEnd|While|With|Or'
		$aKeywords = StringSplit($sKeywords, '|', 2)
		For $i = 0 To UBound($aKeywords) - 1
			If Not $oKeywords.Exists($aKeywords[$i]) Then
				$oKeywords.Add($aKeywords[$i], StringLen($aKeywords[$i]))
			EndIf
		Next

		$fStartup = False
		Return
	EndIf

	Local $tString = DllStructCreate('char[50]', $iStartAddress)
	Local $sWord = StringRegExp(DllStructGetData($tString, 1), '(\w+)\b', 3)
	If @error Then Return 0

	Local $oDict, $iRet = 0
	If $oUDFs.Exists($sWord[0]) Then
		$iRet = 1
		$oDict = $oUDFs
	ElseIf $oKeywords.Exists($sWord[0]) Then
		$iRet = 2
		$oDict = $oKeywords
	ElseIf $oFunctions.Exists($sWord[0]) Then
		$iRet = 3
		$oDict = $oFunctions
	EndIf

	If $iRet Then
		Local $tRet = DllStructCreate('word[2]')
		DllStructSetData($tRet, 1, $iRet);type
		DllStructSetData($tRet, 1, $oDict.Item($sWord[0]), 2);len
		Local $tDwordRet = DllStructCreate('dword', DllStructGetPtr($tRet))
		Return DllStructGetData($tDwordRet, 1)
	EndIf

	Return 0

EndFunc   ;==>_CheckUDFs
#EndRegion CallBack Functions

#Region Internel Functions
Func __RESH_ReplaceRichEditTags(ByRef $sCode)
	Local $time = TimerInit()

	;modify any actual richedit tags that are in the code.
	Local $aRicheditTags = StringRegExp($sCode, '\\+par|\\+tab|\\+cf\d+', 3)
	If Not @error Then
		$aRicheditTags = __ArrayRemoveDups($aRicheditTags)
		For $i = 0 To UBound($aRicheditTags) - 1
			$sCode = StringReplace($sCode, $aRicheditTags[$i], StringReplace($aRicheditTags[$i], '\', '#', 0, 1), 0, 1)
		Next
	EndIf

	;escape characters for rtf code
	$sCode = StringRegExpReplace($sCode, '([\\{}])', '\\\1') ; (\\|{|})
	$sCode = StringReplace($sCode, @CR, '\par' & @CRLF, 0, 1)
	$sCode = StringReplace($sCode, @TAB, '\tab ', 0, 1)

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('ReplaceRichEditTags = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_ReplaceRichEditTags
Func __RESH_HeaderFooter(ByRef $sCode)
#Tidy_Off
	$sCode = 	"{" 													& _
					"\rtf1\ansi\ansicpg1252\deff0\deflang1033" 			& _
					"{" 												& _
						"\fonttbl" 										& _
						"{" 											& _
							"\f0\fnil\fcharset0 " & $g_RESH_sFont & ";" & _
						"}" 											& _
					"}" 												& _
					"{" 												& _
						"\colortbl;" 									& _
						$g_RESH_sColorTable 							& _
					"}" 												& _
					"{" 												& _
						"\*\generator Msftedit 5.41.21.2510;" 			& _
					"}" 												& _
					"\viewkind4\uc1\pard\f0\fs" & $g_RESH_iFontSize  	& _
					StringStripWS($sCode, 2) 							& _
				'}'
	 #Tidy_On
EndFunc   ;==>__RESH_HeaderFooter
Func __RESH_GetRGB($vColorValue)

	If IsNumber($vColorValue) Then Return _ColorGetRGB($vColorValue)

	If IsString($vColorValue) And StringLeft($vColorValue, 1) = '#' Then
		Return _ColorGetRGB(Dec(StringTrimLeft($vColorValue, 1)))
	EndIf

	Return SetError(1, 0, 0)

EndFunc   ;==>__RESH_GetRGB
Func __RESH_Exit()
	DllCallbackFree($g_pcbCheckUDFs)
	DllCallbackFree($g_pcbCheckString)
EndFunc   ;==>__RESH_Exit
Func __ArrayRemoveDups(Const ByRef $aArray)
	If Not IsArray($aArray) Then Return SetError(1, 0, 0)

	Local $oSD = ObjCreate("Scripting.Dictionary")

	For $i In $aArray
		$oSD.Item($i); shown by wraithdu
	Next

	Return $oSD.Keys()
EndFunc   ;==>__ArrayRemoveDups
Func __ArraySortbyLen(ByRef $aArray, $iDecending = 1)

	Local $aArray2D[UBound($aArray)][2]
	For $i = 0 To UBound($aArray) - 1
		$aArray2D[$i][0] = $aArray[$i]
		$aArray2D[$i][1] = StringLen($aArray[$i])
	Next

	_ArraySort($aArray2D, $iDecending, 0, UBound($aArray) - 1, 1)

	For $i = 0 To UBound($aArray) - 1
		$aArray[$i] = $aArray2d[$i][0]
	Next

EndFunc   ;==>__ArraySortbyLen
Func _Decompress($bData, $iOrigLen)
	Local $tBuffers = DllStructCreate('byte[' & $iOrigLen & '];byte[' & $iOrigLen & ']')
	DllStructSetData($tBuffers, 2, $bData)
	Local $aDecompress = DllCall('ntdll.dll', 'uint', 'RtlDecompressBuffer', 'ushort', 0x0002, 'ptr', DllStructGetPtr($tBuffers, 1), _
			'ulong', $iOrigLen, 'ptr', DllStructGetPtr($tBuffers, 2), 'ulong', BinaryLen($bData), 'ulong*', 0)
	If @error Or $aDecompress[0] Then Return SetError(2, 0, 0)
	Return BinaryMid(DllStructGetData($tBuffers, 1), 1, $aDecompress[6])
EndFunc   ;==>_Decompress
Func _B64Decode($sSource)

	Local Static $Opcode, $tMem, $tRevIndex, $fStartup = True

	If $fStartup Then
		If @AutoItX64 Then
			$Opcode = '0xC800000053574D89C74C89C74889D64889CB4C89C89948C7C10400000048F7F148C7C10300000048F7E14989C242807C0EFF3D750E49FFCA42807C0EFE3D750349FFCA4C89C89948C7C10800000048F7F14889C148FFC1488B064989CD48C7C108000000D7C0C0024188C349C1E30648C1E808E2EF49C1E308490FCB4C891F4883C7064883C6084C89E9E2CB4C89D05F5BC9C3'
		Else
			$Opcode = '0xC8080000FF75108B7D108B5D088B750C8B4D148B06D7C0C00288C2C1E808C1E206D7C0C00288C2C1E808C1E206D7C0C00288C2C1E808C1E206D7C0C00288C2C1E808C1E2060FCA891783C70383C604E2C2807EFF3D75084F807EFE3D75014FC6070089F85B29D8C9C21000'
		EndIf

		Local $aMemBuff = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($Opcode), "dword", 4096, "dword", 64)
		$tMem = DllStructCreate('byte[' & BinaryLen($Opcode) & ']', $aMemBuff[0])
		DllStructSetData($tMem, 1, $Opcode)

		Local $aRevIndex[128]
		Local $aTable = StringToASCIIArray('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/')
		For $i = 0 To UBound($aTable) - 1
			$aRevIndex[$aTable[$i]] = $i
		Next
		$tRevIndex = DllStructCreate('byte[' & 128 & ']')
		DllStructSetData($tRevIndex, 1, StringToBinary(StringFromASCIIArray($aRevIndex)))

		$fStartup = False
	EndIf

	Local $iLen = StringLen($sSource)
	Local $tOutput = DllStructCreate('byte[' & $iLen + 8 & ']')
	DllCall("kernel32.dll", "bool", "VirtualProtect", "struct*", $tOutput, "dword_ptr", DllStructGetSize($tOutput), "dword", 0x00000004, "dword*", 0)

	Local $tSource = DllStructCreate('char[' & $iLen + 8 & ']')
	DllStructSetData($tSource, 1, $sSource)
	Local $aRet = DllCallAddress('uint', DllStructGetPtr($tMem), 'struct*', $tRevIndex, 'struct*', $tSource, 'struct*', $tOutput, 'uint', (@AutoItX64 ? $iLen : $iLen / 4))

	Return BinaryMid(DllStructGetData($tOutput, 1), 1, $aRet[0])

EndFunc   ;==>_B64Decode
#EndRegion Internel Functions

#Region Function lists
Func __Functions()

	Local $sFunctions = 'GUICtrlRegisterListViewSort|GUICtrlCreateListViewItem|GUICtrlCreateTreeViewItem|GUICtrlCreateContextMenu|OnAutoItExitUnRegister|GUICtrlCreateMonthCal|GUICtrlCreateProgress|GUICtrlCreateCheckbox|GUICtrlCreateListView|GUICtrlCreateMenuItem|GUICtrlCreateTreeView|OnAutoItExitRegister|GUICtrlCreateGraphic|GUICtrlSetDefBkColor|StringFromASCIIArray|GUICtrlCreateTabItem|GUICtrlCreateSlider|StringRegExpReplace|DllCallbackRegister|IniReadSectionNames|GUICtrlCreateUpdown|GUICtrlCreateButton|StringToASCIIArray|SoundSetWaveVolume|DriveGetFileSystem|FileCreateNTFSLink|ProcessSetPriority|FileCreateShortcut|GUICtrlSendToDummy|GUICtrlCreateRadio|GUICtrlSetDefColor|GUISetAccelerators|GUICtrlSetResizing|GUICtrlCreateLabel|GUICtrlCreateCombo|ObjCreateInterface|GUICtrlCreateDummy|GUICtrlCreateInput|GUICtrlCreateGroup|WinMinimizeAllUndo|TrayItemSetOnEvent|GUICtrlCreateDate|FileFindFirstFile|GUICtrlSetGraphic|GUICtrlCreateEdit|GUICtrlCreateList|DllCallbackGetPtr|GUICtrlSetBkColor|GUICtrlCreateMenu|GUICtrlCreateIcon|ConsoleWriteError|TrayItemGetHandle|AutoItWinSetTitle|WinMenuSelectItem|AutoItWinGetTitle|GUICtrlSetOnEvent|GUICtrlCreateObj|GUICtrlCreateTab|WinGetClientSize|GUICtrlCreatePic|StatusbarGetText|ShellExecuteWait|HttpSetUserAgent|TrayItemGetState|FileRecycleEmpty|FileSelectFolder|IniRenameSection|GUICtrlCreateAvi|TraySetPauseIcon|ProcessWaitClose|FileFindNextFile|TrayItemSetState|FileGetShortName|GUICtrlGetHandle|DllStructSetData|ControlGetHandle|GUIGetCursorInfo|DllStructGetData|GUICtrlSetCursor|DllStructGetSize|WinWaitNotActive|FileGetEncoding|ProcessGetStats|AdlibUnRegister|GUICtrlSetStyle|GUICtrlSetLimit|TrayItemSetText|ControlListView|GUICtrlSetState|ControlTreeView|FileGetLongName|GUICtrlSetImage|FileGetShortcut|WinGetClassList|GUICtrlGetState|ControlGetFocus|DriveSpaceTotal|AutoItSetOption|DllStructGetPtr|DllStructCreate|FileReadToArray|TrayItemGetText|GUICtrlSetColor|StringTrimRight|IniWriteSection|DllCallbackFree|GUIRegisterMsg|IniReadSection|BinaryToString|UDPCloseSocket' & _
			'|GUICtrlRecvMsg|WinMinimizeAll|WinGetCaretPos|GUICtrlSetFont|TraySetOnEvent|GUICtrlSetData|GUICtrlSendMsg|TraySetToolTip|ControlSetText|TrayCreateMenu|DllCallAddress|DriveGetSerial|ControlCommand|TrayCreateItem|StringIsXDigit|DriveSpaceFree|ControlDisable|TCPCloseSocket|SendKeepActive|MouseClickDrag|ControlGetText|MouseGetCursor|FileOpenDialog|StringTrimLeft|FileGetVersion|StringToBinary|TrayItemDelete|FileSaveDialog|StringIsLower|StringIsASCII|StringIsDigit|StringIsFloat|GUICtrlDelete|WinWaitActive|StringIsSpace|ControlEnable|StringStripWS|GUICtrlSetTip|ControlGetPos|GUISetBkColor|GUICtrlSetPos|AdlibRegister|StringIsUpper|StringReplace|StringStripCR|StringReverse|SplashImageOn|GUISetOnEvent|StringCompare|GUIStartGroup|PixelChecksum|ProcessExists|FileGetAttrib|FileChangeDir|PixelGetColor|DriveGetLabel|FileSetAttrib|DriveGetDrive|WinGetProcess|StringIsAlpha|DriveSetLabel|FileWriteLine|StringIsAlNum|WinWaitClose|HttpSetProxy|TraySetClick|StringFormat|SplashTextOn|GUISetCursor|WinGetHandle|TraySetState|ProcessClose|StringRegExp|ShellExecute|ControlFocus|DriveGetType|ConsoleWrite|ControlClick|FileReadLine|StringUpper|StringLower|WinGetTitle|WinActivate|WinSetOnTop|WinSetState|TCPNameToIP|ProgressSet|ProgressOff|IsDllStruct|ConsoleRead|MemGetStats|FileGetSize|StringSplit|ControlSend|StringRight|FileGetTime|FileInstall|ControlShow|MouseGetPos|ProcessWait|WinGetState|ProcessList|PixelSearch|ControlMove|ControlHide|StringInStr|TraySetIcon|DriveMapDel|FtpSetProxy|DriveMapAdd|WinSetTitle|WinSetTrans|DriveMapGet|GUICtrlRead|GUISetCoord|GUIGetStyle|StringAddCR|GUISetStyle|GUISetState|DriveStatus|SetExtended|TCPShutdown|FileSetTime|FileRecycle|InetGetSize|InetGetInfo|UDPShutdown|StringIsInt|StdinWrite|StringLeft|StderrRead|StdoutRead|StdioClose|VarGetType|RegEnumKey|UDPStartup|ProgressOn|FileDelete|FileGetPos|DirGetSize|RegEnumVal|FileExists|TCPStartup|FileSetPos|TCPConnect|WinGetText|IsDeclared|GUISetHelp|GUISetFont|GUISetIcon|TrayGetMsg|BlockInput|MouseWheel|MouseClick|SoundPl' & _
			'ay|EnvUpdate|HotKeySet|InetClose|IniDelete|TimerDiff|WinGetPos|TimerInit|StringMid|BinaryMid|GUIGetMsg|GUIDelete|BinaryLen|GUISwitch|SplashOff|GUICreate|ObjCreate|TCPAccept|RegDelete|MouseMove|MouseDown|BitRotate|IsKeyword|StringLen|WinExists|DirCreate|DirRemove|FileWrite|FileClose|FileFlush|WinActive|TCPListen|RunAsWait|DllClose|BitShift|FileCopy|WinFlash|WinClose|RegWrite|IsBinary|FileMove|FileRead|IsString|IsNumber|ObjEvent|FileOpen|SetError|InputBox|Shutdown|InetRead|IniWrite|FuncName|ToolTip|WinList|ClipPut|WinKill|ClipGet|IniRead|TCPRecv|IsArray|IsAdmin|TCPSend|InetGet|WinMove|IsFloat|DllOpen|UDPSend|Execute|DllCall|UDPRecv|UDPBind|SRandom|UDPOpen|Ceiling|ObjName|TrayTip|MouseUp|WinWait|RunWait|DirMove|RegRead|DirCopy|BitXOR|BitAND|UBound|BitNOT|Assign|Binary|EnvSet|IsHWnd|IsFunc|EnvGet|Number|ObjGet|Random|MsgBox|String|IsBool|CDTray|IsPtr|RunAs|Round|Break|Floor|IsObj|BitOR|Sleep|IsInt|Beep|ACos|AscW|ATan|HWnd|ASin|Eval|Send|Sqrt|Call|ChrW|Ping|Chr|Tan|Int|Opt|Abs|Hex|Asc|Exp|Sin|Log|Mod|Dec|Cos|Run|Ptr'

	Return $sFunctions

EndFunc   ;==>__Functions
Func __GetUDFs()

	Local $sUdfs = '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' & _
			'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' & _
			'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' & _
			'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' & _
			'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' & _
			'gUuHpE9nDiAGUHJpb4F1H60yxURqK8UnIlpQYXIdIHp0YFahKMwKU2VxAHVlbmNlTnVtjmIpe2NIQhlkZWQCPv9uK+AtoT3rcwdMSRnNYcAD/k5AJWGKTxkoV0xwIX6BNTBTY2hliJQFElJl+nMBBG7hL3YOgKdoDuAc/+Gw8hxrZQxpiCAAAwxMiz2foQcoB6pPBky0bEZsiD1lZQ5EYA50ZWwOZ0hIMm+Af3ZpoAHtOVVu4Gljb2RlNHvgpqOi/FNlboLEGC0HwyfMCqRPUFdhaXQgAVNACmwwZU9iauIctAFVbgZoIGfAAGRvd3NIk6AA8RFOZXBSaGGRcyMgErAOaWNzcAdXcgZrdwMCLkxheWVyDGVk4wNfd3RCTVADjAryg0NoZWNrUjBhZGlvqnxnWGltwHBsZVNvcu81j0IxiCVBcHDQI2ocRFT+UCIcJmX4H6uDIAlIc8kq/5AlOgWbGCKUPwXjKP8NaGb8Q3U/BZMBEjsPfAR86VX/8Q0hCv8ND44KevZw/xR2Aw5GcB3MLTkTRm9jdf5zj4Z1YCGMHjPaUX8mciYMU3a3CPtsQWxpZ/93Z7mok24nfXgD9a5/AzEY/3gfl7FlAzcMtJGoaDcTtQHHV0T7FNx8bGFnKJaxCM+zcaEA+iKyAU1h4aDAJPxyYaC4/yIyBZJlvwGyAeBXaWR0aLIBo4/wTuZzIiPSAFBvswi4AaMAIzU9uw9CdWKAdkhlCGlnaPwUVHJhY8BrUG9wdXDhAC5NZ/NMOyF5GEVuq8R6xmUwZmF1bL4yQjJUb6NbxnkDU3ViswhXkKIgRXJyb3IzjHJE/GVSYCgQM/cUcgMUE/kG8dvSY29uvw92Az0MtQ/gUHJlc3Nlrj8hNxoBAb9kUGlwZXNf8kNA23RlBgH7BoMG9yKLdV6QZkPgNFRvTeAL+GlCedid+Uz9PjkMfVD/aHDvwXQDcQCQI0ONPxNgbCRpenJJSUXRYEVsaSCDbnQiQmxBUrKkRUJ2MAFMb2dfQHVywdQZU291cmMzDF/rn7sk+xQ7WbsBuzJTbOF5/WI9aJCXqo57AztZORN2Jp2/AW2BTTNZBMNQZVB90UCyc3RvACNkwHL/YRlxV0luM2dn0URPUz/BAHPRYFn/PrlONCFN9rUAdWx0aUJ5dGUAVG9XaWRlQ2gAYXJ8X0dVSUMAdHJsUmViYXIAX1NldEJhbmRATGVuZ3RoBmxUCG9vbAF0RmluZAMEFgY2RWRpdF9TAGhvd0JhbGxvIG9uVGlwBjZMaSBzdEJveAGqSXRAZW1EYXRhB1NyAGVlVmlld19HAGV0Q2hlY2tlYmQHi2ljaAJXABtWwGVyc2lvbgpTBTeAT3JpZ2luWRgbGlgLp0iAepBTQnV0CHRvbgJTbWFnZQMBI4ANRElQbHVzAF9HcmFwaGljAHNEcmF3QmV6jGllgX2EDVBlbgFfAHVzdG9tRW5kBENhkSlTcGxpdBBJbmZvkA1Eb25AdENsaWNrkmFCYGtDb2xvh7WJDUgCb4KpfF9XaW5BBFBJAQlMYXN0RQBycm9yTWVzcwOAY4kNRm9yZWdyEG91bmTABGRvdw/NIoAI1inABklkZWEwbFNpesAU0otQYTxyYcAizw3IU8wwQWQwZFN1YsMwz4tUb8BwSW5kZXjSPgENBEN11GhTdHJpbgJn0hRhYlN0b3ACc8lFT3ZlcmxhgHBwZWRSZXOAxwHPoEluc2VydFQEZXjHBlN0YXR1DHNCwD8BYmVpZ2j/0DfCb8I/ztFCfANJzimEN8HKykhlYWRlAhuBBvBGbGFnwDDNG4FizBsHywbLkmoYUmVjdEUPZy1pc+YGIBJlX1RpAG1lX0VuY29kcGVTeXOAEQEC8gZW4GlzaWJsaxHoGyEOAnzgEmN1cml0eQBfX0xvb2t1cIhBY2NAVHRTaWeBA2kYcF5DdXJyZW4gdFByb2OAXklEP24tYARBAcB9ZyZnO3NNYG9kaWZpaI/mDUTg' & _
			'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' & _
			'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' & _
			'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' & _
			'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' & _
			'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' & _
			'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' & _
			'uWE70S0bq01zcBb3BXODOhczQ2VhwgRaIHtw97BUVISjYFbxD3YrJEnXan8BH3QcoAhFjvcBYbqFQUj8YXN0WfcA1HiaZIszsUifJHBgMoGh8Qyjc0J58wD38wS3KflsYfBbkCg6aJY69yQj9BtQRUPSLxVW+HqhPn1AB1UAGT1+8SCgCsBXcphpYnWioPYHRnXxFf31BFIQePEKdi9SJ7p18iEfIj2pNXO3JZflFlNwbOdBv9QBzIVMbzOLthujCrk1OHNnAOvHAnAjVMd5f1Eb4QB1C2QSpgRjZ8UCdfhsRGlwptYBQIOhTTMwz7VQ0AFRBWAAb3IQL4IvgE1heEluZGVnCMxIaTML0gFUb1W6cwAYUmV2MBzRFlm0AGlFeGVjQ29tAG1hbmR8X1N0AHJpbmdFbmNyCHlwdAZweHBsbwBkZXxfV2VlawBOdW1iZXJJUwBPfF9FeGNlbABCb29rT3BlbgB8X0RhdGVEYYh5T2YBTHxfQwGEQQCCYXJ0dXAAdmkAbkFQSV9CaXQEQmwAskRlYnVnAFJlcG9ydEV4AHxfSUVFcnJvgHJOb3RpZnkADgBOZXRHZXRTbwh1cmMAd0FycmEAeU1pbkluZGUBAixEb2NSZWFkEEhUTUwApFFMaQB0ZV9Fc2NhcIMALAOzQmV0d2UBlRkFHW5jAsIFDnJyTcRzZwjCU2F2gA4CByGBLENlbGwAYW9sJG9ygENHcgIlSUUAUHJvcGVydHkbgAkJB1MBBwJSUmV2CGVycwVZRmluZAJBASRTZW5kTWVAc3NhZ2VBhA1EIGlzcGxhgHVXb/RyZIBnUIBagCIEkwAwzERDhWUAk2VhgQ2DFBhDbG+BMIRkUXVlHnKAIoQGhA2BFE1hY/Byb1J1AYGCIgNWhQYYSW5zgFwHcUJsdQHADUZUUF9GaWwGZYFAxClQZXJtdSZ0wQbABVdyABlMbzEJTk5ld4FCgBBPYhBqQnlJwA1JRUYAb3JtU3VibWkDgUnAclNtdHBNYQJpQEJNYXRoQ2hAZWNrRGl2QQpJQHNGcmFtZUJQdgJpgAFUaW1lb3XHQAPFIgOXQ2hvQDZCKwB8X05vd0NhbIZjAZzAM291bmSAmQh0dXMEA1Jlc3XCbcVgVW5pcYU2hrlhAwNubmVji6LAGWxgaXBQdXQBHkO0VMBvTW9udGjKcIQW4FNlYXJjQAYCAwVUYUIgTGVuZ8EMQgZUPm8BFYVFACfBOoEWSXMQVmFsaQVaRGVsxmXBM0VkUkdChnzDQIBUaWNrc1RvQUidAQNtwCaCBAfXZWXAGeBIZXhUb0N5R1FCrP9EE8O6RQagHYQOoC+CDmRJz4MOgm2jO2VHVG9ADCAQgENQSXBUb07ANz2oFmWhiIRsIIsBCE5h2HZpZ2I1ozhGACrhAjEABGFtcAEtBBNBZMOAB2EBQXR0YSErYQEMQ3KAXwQecl9EaeRmZmUBSW7hSwIu5F5H4RnlBeICUGF14QJJgEVMb2FkV2HhBSfCPUAdgZJ2aUF0R3CkaWJiUW1nIDVjYJeJI191c0U4U3dhoAUHQwHCRAM7cmltfF+iUCBaU3BsRhFQonrbo1ICoVNAJkA7byFxoQK/4ypCL2N+olGEeoNZb8FFmHNQcsBN4SlNb6AYPFRyYRBhBQUzpSRUZZxtcANWYW3jbElF5SBx4ARjdGmhD4IWZixR3nWiIYG2YiriIk+BQaMf22EQA69hgD1DG29gTeEdjEZ1oZohAU1hawi0f0Jz41MAAeRzY3oCASMCdp5ppB3BAeIRBHp8X+CV2ERPU4EWwxNBACDhLSBSYWRpYWHMZWeHYLFBCIMgdmlHVEDA6QBPSVCgBmngGMUQYY0AeE=='

	$sUdfs = BinaryToString(_Decompress(_B64Decode($sUdfs), 50865))

	$sUdfs &= '|_WinAPI_GetProcAddress|_WinAPI_ShellAboutDlg'

	Return $sUdfs

EndFunc   ;==>__GetUDFs
#EndRegion Function lists
