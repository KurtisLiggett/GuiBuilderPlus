; ============================================================================================================================
; File		: MemoryDll.au3 (2015.01.23)
; Purpose	: Loading Binary DLL/EXE In AutoIt Script
; Author	: Ward
; Dependency: BinaryCall.au3
;
; Source	: MemoryModule.c
; Website	: http://www.joachim-bauch.de/tutorials/loading-a-dll-from-memory/
; CopyRight	: Copyright (c) 2004-2011 by Joachim Bauch.
; ============================================================================================================================

; ============================================================================================================================
; Public Functions:
;   MemoryDllOpen($Binary, $Name = "")
;   MemoryDllClose($Module)
;   MemoryDllRun($Module)
;   MemoryDllCall($Module, $RetType, $ProcName[, $Type1 = "", $Param1 = 0, ...])
;   MemoryDllLoadString($Module, $ID, $Language = 0x400)
;   MemoryDllLoadResource($Module, $Type, $Name, $Language = 0x400)
;
;   _WinAPI_MemoryFindResource($Module, $Type, $Name)
;   _WinAPI_MemoryFindResourceEx($Module, $Type, $Name, $Language = 0x400)
;   _WinAPI_MemorySizeOfResource($Module, $Resource)
;   _WinAPI_MemoryLoadResource($Module, $Resource)
;   _WinAPI_MemoryLoadString($Module, $ID, $MaxLength = 65535)
;   _WinAPI_MemoryLoadStringEx($Module, $ID, $Language = 0x400, $MaxLength = 65535)
; ============================================================================================================================

#Include-once
#Include "BinaryCall.au3"

Func __MemoryModule_RuntimeLoader($ProcName = "")
	Static $SymbolList
	If Not IsDllStruct($SymbolList) Then
		Local $Code, $Reloc
		If @AutoItX64 Then
			$Code = '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' & _
				'TJorxgdQ9oJ37IW2tl1h3x1qCmG9k24j0FA0VcONA0WGN2wJ9nicPRNHsLE4Ou7W9qNYjkVHQUe7ZXOJ87KV231iI1gJpKNc8Ms4QRVjkjcVVpH8vDl15KqWgXvbSoxD6C74+yu5Mv2OCa+PhDLTgSbnT6hrbPHZ/AX9dfRgxXprZlxOKvaoQVh7TDdMbfEIdjy4CpZWzdkNgyGc1Bc2yEwbx/UP3/kvjBe+YD7ID5qU0UAPqq6yAmQHu8g9353oAjM6ZUH+OD6NwmTb1ClPphWzLSeW6FkC4nX6npBFl40i+A5LSBg4ZQRbgz/SBpqmrLDiQXJwyKLXtugr8X5Mb6J7wDv0n8i0+60iMnXLw4hoyYF8jq+NPIZkCykCIuOqZD2APJ4vVbSOiqAOOBGIovScUQ3nHTBk4HJkAlMpdMIp8kyroqcdSGZ/yrmDXHVPQPFkQ0s+EpyDOKMiJcdISh7e1IC5NeaCzD+xaEa5pxHwU1k5jolDTsSlOMOscAFjhFQZLK0cayxI9prAauIn7jp7yKykEgePNh+wPLN7l23/Q3acfs1y2IuE0AOZvPtO0UPgR09m9DfXgblXD5L0kbeEx2KilSNWgqwxoVmlpYN7uONZuTJYmNAlkvx86/YcNK85L+CiVU9eV5iz43Vjmp/gTaND0ZW+F2UV6LPjc53FWVRWcOYh0c5vY6Al8gT4hUMUtz0uOaudv4BdetzHcVpMgY+2o4x0OaLxZL0ZRp13++ls7jc2TbieBWL3NueTU+bGs/wmZsotzPPEnXdzwnhyXcApVKuLE8eit7AVmOupAlAqIOkG6/1I+OhO4PIKKge2lHX0tdFVqhGxYHJVH9fc4HN3qGhjS1uvmzQmugA='
			$Reloc = 'AwAAAAQSAAAAAAAAAAABAB3uXDOHqMigEbdoTME+4GD5N65gAA=='
		Else
			$Code = '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' & _
				'7PzpWPFpgv9GF7eVeAEhZpe4drSDu8nFl+KiPejCrqaSSla7LJpWe26+vQaGbpx+3H9xdf0bqVxC9xuhrnAINvXL68CwXHEvOpd8R7SXHOh/uGfUIjToMbICZkSU/202sVcpAI3aDRZm/Ktl6O70QFOGdWYvxFOze28jwM738KCLhOnm2im4l4mR3D7Sk9wXl53+3yEtuC1+fwpmW6aDCV7XTTvE5g8aJXnCNDjh9DYjFlp7omUvAzjANuh5DQMFVW6q14OKHEFyqCMiH9TFnoVdsrGtHrvpU8bHGxjpnyo1VpjxDKhIb0VRBpYnGGgxNhf+9oRjxH3E8DbBeZN1Y+io2sMWpPSox0EO59GSr/iRXn8b2mqBYJMKW7FGM0HZOFOXXWYhoZVuke0/fbKYnmXx8nURBkSu/G6TmcsXyq4tKVqItcmgoQ2psIT3GCDPES+so2J5bxEb0d5GfrgjGEFBTmD6mdJ4mnGdOnu8qa1ZsoDGF5FPmBvqc+cUGMGFOiOaYuDQ2yAXH7PQ5WUNao/x8BQQVca2suRg19LJLsKMswZ2S6Voc/YGllyoOFCo3k6GZ9BX8gJJIauTHRzyWiae0jmV442Q87zMSSMrUMyJoKLVDps2bWE6CGdqTOvrQZuVkQThL/u5usAOZltlFvPSeLKKtOkoRxEcvVmTZ9OfE5x8IG4aKUyRHK5swgfq9st60x7UfShuf+6wn/IFddxY+VMDZbI6u2vFnQOqSKJsT3aNiMDLycyLnHjtmgbVFBRCEEl/wW1hJR95A82N4eA5MqzbtwFMU4ujT+eAARzd8N//T3RvqK6rZRtn+oA='
			$Reloc = 'AwAAAAQQAAAAAAAAAAABABRbSMoa0b+9mTDwkZMYPU9LaCA='
		EndIf

		Local $Symbol[] = ["MemoryGetProcAddress","MemoryFreeLibrary","MemoryLoadLibraryEx","MemoryLoadLibrary","MemoryCallEntryPoint","MemoryFindResourceEx","MemoryFindResource","MemorySizeofResource","MemoryLoadResource","MemoryLoadStringEx","MemoryLoadString"]
		Local $CodeBase = _BinaryCall_Create($Code, $Reloc)
		If @Error Then Exit MsgBox(16, "MemoryDll", "Startup Failure!")

		$SymbolList = _BinaryCall_SymbolList($CodeBase, $Symbol)
		If @Error Then Exit MsgBox(16, "MemoryDll", "Startup Failure!")
	EndIf
	If $ProcName Then Return DllStructGetData($SymbolList, $ProcName)
EndFunc

Func __MemoryModule_ModuleRecord($Func, $Module = Null, $Filename = Null)
	Static $Dict

	If Not IsObj($Dict) Then
		$Dict = ObjCreate('Scripting.Dictionary')
		$Dict.CompareMode = 1
	EndIf

	Local $Key
	Switch $Func
		Case "get"
			If $Module Then
				$Key = "Module:" & Ptr($Module)
				If $Dict.Exists($Key) Then Return $Dict.Item($Key)
			ElseIf $Filename Then
				$Key = "Name:" & $Filename
				If $Dict.Exists($Key) Then Return Ptr($Dict.Item($Key))
			EndIf
			Return SetError(1, 0, Null)

		Case "set"
			$Key = "Module:" & Ptr($Module)
			If $Dict.Exists($Key) Then $Dict.Remove($Key)
			$Dict.Add($Key, $Filename)

			$Key = "Name:" & $Filename
			If $Dict.Exists($Key) Then $Dict.Remove($Key)
			$Dict.Add($Key, $Module)

		Case "delete"
			If $Module Then
				$Key = "Module:" & Ptr($Module)
				If $Dict.Exists($Key) Then
					Local $Key2 = "Name:" & $Dict.Item($Key)
					If $Dict.Exists($Key2) Then $Dict.Remove($Key2)
					$Dict.Remove($Key)
				EndIf
			ElseIf $Filename Then
				$Key = "Name:" & $Filename
				If $Dict.Exists($Key) Then
					Local $Key2 = "Module:" & Ptr($Dict.Item($Key))
					If $Dict.Exists($Key2) Then $Dict.Remove($Key2)
					$Dict.Remove($Key)
				EndIf
			EndIf
	EndSwitch
	Return SetError(1, 0, Null)
EndFunc

Func __MemoryModule_LoadLibrary($Filename, $Userdata)
	Local $Module = __MemoryModule_ModuleRecord("get", Null, $Filename)
	Return $Module ? $Module : DllCall($__BinaryCall_Kernel32dll, "ptr", "LoadLibraryA", "str", $Filename)[0]
EndFunc

Func __MemoryModule_GetProcAddress($Module, $Proc, $Userdata)
	Static $MemoryGetProcAddress = __MemoryModule_RuntimeLoader("MemoryGetProcAddress")

	If __MemoryModule_ModuleRecord("get", $Module) Then
		Return DllCallAddress("ptr:cdecl", $MemoryGetProcAddress, "ptr", $Module, "ptr", $Proc)[0]
	Else
		Return DllCall($__BinaryCall_Kernel32dll, 'ptr', 'GetProcAddress', 'ptr', $Module, 'ptr', $Proc)[0]
	EndIf
EndFunc

Func __MemoryModule_FreeLibrary($Module, $Userdata)
	Static $MemoryFreeLibrary = __MemoryModule_RuntimeLoader("MemoryFreeLibrary")

	If Not __MemoryModule_ModuleRecord("get", $Module) Then
		DllCall($__BinaryCall_Kernel32dll, "int", "FreeLibrary", "ptr", $Module)
	EndIf
EndFunc

Func MemoryDllOpen($Binary, $Name = "")
	Static $LoadLibrary = DllCallbackGetPtr(DllCallbackRegister(__MemoryModule_LoadLibrary, "ptr:cdecl", "str;ptr"))
	Static $GetProcAddress = DllCallbackGetPtr(DllCallbackRegister(__MemoryModule_GetProcAddress, "ptr:cdecl", "ptr;ptr;ptr"))
	Static $FreeLibrary = DllCallbackGetPtr(DllCallbackRegister(__MemoryModule_FreeLibrary, "none:cdecl", "ptr;ptr"))
	Static $MemoryLoadLibraryEx = __MemoryModule_RuntimeLoader("MemoryLoadLibraryEx")
	If Not IsBinary($Binary) Then Return SetError(1, 0, -1)

	Local $Buffer = DllStructCreate("byte[" & BinaryLen($Binary) & "]")
	DllStructSetData($Buffer, 1, $Binary)

	Local $Module = DllCallAddress("ptr:cdecl", $MemoryLoadLibraryEx, "ptr", DllStructGetPtr($Buffer), "ptr", $LoadLibrary, "ptr", $GetProcAddress, "ptr", $FreeLibrary, "ptr", 0)[0]
	If $Module And $Name Then __MemoryModule_ModuleRecord("set", $Module, $Name)
	Return $Module ? $Module : SetError(1, 0, -1)
EndFunc

Func MemoryDllClose($Module)
	Static $MemoryFreeLibrary = __MemoryModule_RuntimeLoader("MemoryFreeLibrary")

	__MemoryModule_ModuleRecord("delete", $Module)
	If $Module And $Module <> -1 Then DllCallAddress("none:cdecl", $MemoryFreeLibrary, "ptr", $Module)
EndFunc

;* Execute entry point (EXE only). The entry point can only be executed
;* if the EXE has been loaded to the correct base address or it could
;* be relocated (i.e. relocation information have not been stripped by
;* the linker).
;*
;* Important: calling this function will not return, i.e. once the loaded
;* EXE finished running, the process will terminate.
;*
;* Returns a negative value if the entry point could not be executed.
Func MemoryDllRun($Module)
	Static $MemoryCallEntryPoint = __MemoryModule_RuntimeLoader("MemoryCallEntryPoint")
	Local $OpenFlag = False

	If IsBinary($Module) Then
		$OpenFlag = True
		$Module = MemoryDllOpen($Module)
	EndIf
	If Not $Module Or $Module = -1 Then Return SetError(1, 0, Null) ; 1 = unable to use the DLL file

	Local $Ret = DllCallAddress("int:cdecl", $MemoryCallEntryPoint, "ptr", $Module)[0]
	If $OpenFlag Then MemoryDllClose($Module)
	Return SetError($Ret < 0, 0, $Ret)
EndFunc

Func MemoryDllCall($Module, $RetType, $ProcName, $Type1 = "", $Param1 = 0, $Type2 = "", $Param2 = 0, $Type3 = "", $Param3 = 0, $Type4 = "", $Param4 = 0, $Type5 = "", $Param5 = 0, $Type6 = "", $Param6 = 0, $Type7 = "", $Param7 = 0, $Type8 = "", $Param8 = 0, $Type9 = "", $Param9 = 0, $Type10 = "", $Param10 = 0, $Type11 = "", $Param11 = 0, $Type12 = "", $Param12 = 0, $Type13 = "", $Param13 = 0, $Type14 = "", $Param14 = 0, $Type15 = "", $Param15 = 0, $Type16 = "", $Param16 = 0, $Type17 = "", $Param17 = 0, $Type18 = "", $Param18 = 0, $Type19 = "", $Param19 = 0, $Type20 = "", $Param20 = 0)
	Static $MemoryGetProcAddress = __MemoryModule_RuntimeLoader("MemoryGetProcAddress")
	Local $Ret, $OpenFlag = False
	Local Const $MaxParams = 20

	If IsBinary($Module) Then
		$OpenFlag = True
		$Module = MemoryDllOpen($Module)
	EndIf
	If Not $Module Or $Module = -1 Then Return SetError(1, 0, Null) ; 1 = unable to use the DLL file

	Local $Ptr = DllCallAddress("ptr:cdecl", $MemoryGetProcAddress, "ptr", $Module, IsInt($ProcName) ? "int" : "str", $ProcName)[0]
	If Not $Ptr Then Return SetError(3, 0, Null) ; 3 = "function" not found in the DLL file,

	Switch @NumParams
	Case 3
		$Ret = DllCallAddress($RetType, $Ptr)
	Case 5
		$Ret = DllCallAddress($RetType, $Ptr, $Type1, $Param1)
	Case 7
		$Ret = DllCallAddress($RetType, $Ptr, $Type1, $Param1, $Type2, $Param2)
	Case 9
		$Ret = DllCallAddress($RetType, $Ptr, $Type1, $Param1, $Type2, $Param2, $Type3, $Param3)
	Case 11
		$Ret = DllCallAddress($RetType, $Ptr, $Type1, $Param1, $Type2, $Param2, $Type3, $Param3, $Type4, $Param4)
	Case 13
		$Ret = DllCallAddress($RetType, $Ptr, $Type1, $Param1, $Type2, $Param2, $Type3, $Param3, $Type4, $Param4, $Type5, $Param5)
	Case 15
		$Ret = DllCallAddress($RetType, $Ptr, $Type1, $Param1, $Type2, $Param2, $Type3, $Param3, $Type4, $Param4, $Type5, $Param5, $Type6, $Param6)
	Case 17
		$Ret = DllCallAddress($RetType, $Ptr, $Type1, $Param1, $Type2, $Param2, $Type3, $Param3, $Type4, $Param4, $Type5, $Param5, $Type6, $Param6, $Type7, $Param7)
	Case 19
		$Ret = DllCallAddress($RetType, $Ptr, $Type1, $Param1, $Type2, $Param2, $Type3, $Param3, $Type4, $Param4, $Type5, $Param5, $Type6, $Param6, $Type7, $Param7, $Type8, $Param8)
	Case 21
		$Ret = DllCallAddress($RetType, $Ptr, $Type1, $Param1, $Type2, $Param2, $Type3, $Param3, $Type4, $Param4, $Type5, $Param5, $Type6, $Param6, $Type7, $Param7, $Type8, $Param8, $Type9, $Param9)
	Case 23
		$Ret = DllCallAddress($RetType, $Ptr, $Type1, $Param1, $Type2, $Param2, $Type3, $Param3, $Type4, $Param4, $Type5, $Param5, $Type6, $Param6, $Type7, $Param7, $Type8, $Param8, $Type9, $Param9, $Type10, $Param10)
	Case Else
		If (@NumParams < 3) Or (@NumParams > $MaxParams * 2 + 3) Or (Mod(@NumParams, 2) = 0) Then Return SetError(4, 0, 0) ; 4 = bad number of parameters,

		Local $Script = 'DllCallAddress($RetType, $Ptr', $n = 1
		For $i = 5 To @NumParams Step 2
			$Script &= ', $Type' & $n & ', $Param' & $n
			$n += 1
		Next
		$Script &= ')'
		$Ret = Execute($Script)
	EndSwitch

	Local $Err = @Error
	; 2 = unknown "return type",
	; 4 = bad number of parameters,
	; 5 = bad parameter

	If $OpenFlag Then MemoryDllClose($Module)
	Return SetError($Err, 0, $Ret)
EndFunc

Func MemoryDllLoadString($Module, $ID, $Language = 0x400)
	Local $OpenFlag = False
	If IsBinary($Module) Then
		$OpenFlag = True
		$Module = MemoryDllOpen($Module)
	EndIf
	If Not $Module Or $Module = -1 Then Return SetError(1, 0, Null) ; 1 = unable to use the DLL file

	Local $Ret = _WinAPI_MemoryLoadStringEx($Module, $ID, $Language)
	If @Error Then Return SetError(@Error, 0, Null)

	If $OpenFlag Then MemoryDllClose($Module)
	Return $Ret
EndFunc

Func MemoryDllLoadResource($Module, $Type, $Name, $Language = 0x400)
	Local $OpenFlag = False
	If IsBinary($Module) Then
		$OpenFlag = True
		$Module = MemoryDllOpen($Module)
	EndIf
	If Not $Module Or $Module = -1 Then Return SetError(1, 0, Null) ; 1 = unable to use the DLL file

	Local $Resource = _WinAPI_MemoryFindResourceEx($Module, $Type, $Name, $Language)
	If @Error Or Not $Resource Then Return SetError(6, 0, Null)

	Local $Size = _WinAPI_MemorySizeOfResource($Module, $Resource)

	Local $Ret = Binary("")
	If $Size Then
		Local $Ptr = _WinAPI_MemoryLoadResource($Module, $Resource)
		If $Ptr Then
			Local $Buffer = DllStructCreate("byte[" & $Size & "]", $Ptr)
			$Ret = DllStructGetData($Buffer, 1)
		EndIf
	EndIf

	If $OpenFlag Then MemoryDllClose($Module)
	Return $Ret
EndFunc

Func _WinAPI_MemoryFindResource($Module, $Type, $Name)
	Static $MemoryFindResource = __MemoryModule_RuntimeLoader("MemoryFindResource")

	Local $TypeOfType = 'int', $TypeOfName = 'int'
	If IsString($Type) Then $TypeOfType = 'wstr'
	If IsString($Name) Then $TypeOfName = 'wstr'

	Local $Ptr = DllCallAddress('ptr:cdecl', $MemoryFindResource, 'ptr', $Module, $TypeOfName, $Name, $TypeOfType, $Type)[0]
	Return SetError($Ptr = 0, 0, $Ptr)
EndFunc

Func _WinAPI_MemoryFindResourceEx($Module, $Type, $Name, $Language = 0x400)
	Static $MemoryFindResourceEx = __MemoryModule_RuntimeLoader("MemoryFindResourceEx")

	Local $TypeOfType = 'int', $TypeOfName = 'int'
	If IsString($Type) Then $TypeOfType = 'wstr'
	If IsString($Name) Then $TypeOfName = 'wstr'

	Local $Ptr = DllCallAddress('ptr:cdecl', $MemoryFindResourceEx, 'ptr', $Module, $TypeOfName, $Name, $TypeOfType, $Type, "word", $Language)[0]
	Return SetError($Ptr = 0, 0, $Ptr)
EndFunc

Func _WinAPI_MemorySizeOfResource($Module, $Resource)
	Static $MemorySizeofResource = __MemoryModule_RuntimeLoader("MemorySizeofResource")
	Return DllCallAddress('uint:cdecl', $MemorySizeofResource, 'ptr', $Module, 'ptr', $Resource)[0]
EndFunc

Func _WinAPI_MemoryLoadResource($Module, $Resource)
	Static $MemoryLoadResource = __MemoryModule_RuntimeLoader("MemoryLoadResource")
	Return DllCallAddress('ptr:cdecl', $MemoryLoadResource, 'ptr', $Module, 'ptr', $Resource)[0]
EndFunc

Func _WinAPI_MemoryLoadString($Module, $ID, $MaxLength = 65535)
	Static $MemoryLoadString = __MemoryModule_RuntimeLoader("MemoryLoadString")

	Local $Str
	If $MaxLength <= 65535 Then ; faster than create DllStruct
		$Str = DllCallAddress("uint:cdecl", $MemoryLoadString, "ptr", $Module, "uint", $ID, "wstr", "", "uint", 65535)[3]
	Else
		$MaxLength += 1
		Local $Buffer = DllStructCreate("wchar[" & $MaxLength & "]")
		DllCallAddress("uint:cdecl", $MemoryLoadString, "ptr", $Module, "uint", $ID, "ptr", DllStructGetPtr($Buffer), "uint", $MaxLength)
		$Str = DllStructGetData($Buffer, 1)
	EndIf
	Return SetError($Str = "", 0, $Str)
EndFunc

Func _WinAPI_MemoryLoadStringEx($Module, $ID, $Language = 0x400, $MaxLength = 65535)
	Static $MemoryLoadStringEx = __MemoryModule_RuntimeLoader("MemoryLoadStringEx")

	Local $Str
	If $MaxLength <= 65535 Then
		$Str = DllCallAddress("uint:cdecl", $MemoryLoadStringEx, "ptr", $Module, "uint", $ID, "wstr", "", "uint", 65535, "word", $Language)[3]
	Else
		$MaxLength += 1
		Local $Buffer = DllStructCreate("wchar[" & $MaxLength & "]")
		DllCallAddress("uint:cdecl", $MemoryLoadStringEx, "ptr", $Module, "uint", $ID, "ptr", DllStructGetPtr($Buffer), "uint", $MaxLength, "word", $Language)
		$Str = DllStructGetData($Buffer, 1)
	EndIf
	Return SetError($Str = "", 0, $Str)
EndFunc
