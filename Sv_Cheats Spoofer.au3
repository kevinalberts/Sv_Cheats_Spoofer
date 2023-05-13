#RequireAdmin
#Include <NtProcess.au3>
#Include <Console.au3>

;~ If this source helped you or did you use is, please give credits.
;~ Github.com/KevinAlberts

Cout("")
Global $sAnswer, $rndmstr
Dim $aSpace[3]
For $i = 1 To 15
	$aSpace[0] = Chr(Random(65, 90, 1))     ;A-Z
	$aSpace[1] = Chr(Random(97, 122, 1))     ;a-z
	$aSpace[2] = Chr(Random(48, 57, 1))     ;0-9
	$rndmstr &= $aSpace[Random(0, 2, 1)]
Next
DllCall("Kernel32.dll", "BOOL", "SetConsoleTitle", "str", "  ")
$dwHandle = OpenProcess(0x1F0FFF, 0, ProcessExists("CSGO.exe"))
$dwEngineDLL = _MemoryModuleGetBaseAddress(ProcessExists("CSGO.exe"), "engine.dll")
$OffState = 0
$OnState = 0
Cout("CS:GO has been found" & @CRLF)
DllCall("Kernel32.dll", "BOOL", "SetConsoleTitle", "str", "Searching base address...")
$dwSvCheatsBaseSearch = FindPatternX32($dwHandle, "A1........B9........FF50..85C0747B8B0D", false, $dwEngineDLL)
$dwSvCheatsBaseAddress = NtReadVirtualMemory($dwHandle, $dwSvCheatsBaseSearch + 0x1, "dword")
If $dwSvCheatsBaseSearch <> 0 Then
	Cout("Base address has been found." & @CRLF, 0xA)
Else
	Cout("Base address search failed." & @CRLF, 0x4)
	Exit
EndIf
DllCall("Kernel32.dll", "BOOL", "SetConsoleTitle", "str", "Searching offset...")
$dwServerCommandsGeneralOffsetSearch = FindPatternX32($dwHandle, "3B46..750D8B46..3346..A9........74138B0D........85C974098B0156FF90........8B46..33C65EC3", false, $dwEngineDLL)
$dwServerCommandsGeneralOffset = NtReadVirtualMemory($dwHandle, $dwServerCommandsGeneralOffsetSearch + 0x2, "dword")
If $dwServerCommandsGeneralOffsetSearch <> 0 Then
	Cout("Offset has been found." & @CRLF, 0xA)
Else
	Cout("Offset search failed." & @CRLF, 0x4)
	Exit
EndIf
$dwSvCheatsAddress = "0x" & Hex($dwSvCheatsBaseAddress, 8)
$dwSvCheatsOffset = "0x" & Hex($dwServerCommandsGeneralOffset, 2)
$dwSvCheats = "0x" & Hex(Execute($dwSvCheatsAddress + $dwSvCheatsOffset), 8)
$OffState = $dwSvCheatsBaseAddress
$OnState = $dwSvCheatsBaseAddress + 0x1
Cout(@CRLF & @CRLF)
Sleep(1300)
DllCall("Kernel32.dll", "BOOL", "SetConsoleTitle", "str", $rndmstr)
_WinAPI_ClearConsole()
Cout("sv_cheats spoofer is ")
Cout("ready", 0xA)
Cout(" now." & @CRLF)
Sleep(1400)
GetAllCommands()

While 1
	Sleep(100)
	Cin($sAnswer)
	If $sAnswer = "sv_cheats 1" Then
		NtWriteVirtualMemory($dwHandle, $dwSvCheats, $OnState, "dword")
		GetAllCommands()
		Cout("sv_cheats ")
		Cout("True" & @CRLF, 0xA)
	ElseIf $sAnswer = "sv_cheats 0" Then
		NtWriteVirtualMemory($dwHandle, $dwSvCheats, $OffState, "dword")
		GetAllCommands()
		Cout("sv_cheats ")
		Cout("False" & @CRLF, 0x4)
	ElseIf $sAnswer = "sv_cheats" Then
		$dwReadSvCheats = Hex(NtReadVirtualMemory($dwHandle, $dwSvCheats, "dword"), 8)
		If $dwReadSvCheats = Hex($dwSvCheatsBaseAddress + 0x1, 8) Then
			GetAllCommands()
			Cout("sv_cheats ")
			Cout("True" & @CRLF, 0xA)
		ElseIf $dwReadSvCheats = Hex($dwSvCheatsBaseAddress, 8) Then
			GetAllCommands()
			Cout("sv_cheats ")
			Cout("False" & @CRLF, 0x4)
		EndIf
	EndIf
WEnd

Func GetAllCommands()
	_WinAPI_ClearConsole()
	Cout("Commands:" & @CRLF & @CRLF, 0x1)
	Cout("sv_cheats: ", 0xA)
	Cout("This will show your current sv_cheats state." & @CRLF)
	Cout("sv_cheats 1: ", 0xA)
	Cout("This will set your sv_cheats state to 1." & @CRLF)
	Cout("sv_cheats 0: ", 0xA)
	Cout("This will set your sv_cheats state to 0." & @CRLF & @CRLF)
EndFunc   ;==>GetAllCommands

Func _WinAPI_ClearConsole($hConsole = -1, $iX = Default, $iY = Default)
	Local $dwCoord, $fFlag = False
	Local $bChar = 0x20, $iErr ; fill character: 0x20 (Space)
	Local Const $STD_OUTPUT_HANDLE = -11
	Local Const $INVALID_HANDLE_VALUE = -1
	Local Const $tagCONSOLE_SCREEN_BUFFER_INFO = "short dwSizeX; short dwSizeY;short dwCursorPositionX;" & _
			"short dwCursorPositionY; short wAttributes;short Left; short Top; short Right; short Bottom;" & _
			"short dwMaximumWindowSizeX; short dwMaximumWindowSizeY"
	;// get handle to standard output device (handle does not have to be closed on return)
	Local $hDLLK32 = DllOpen("Kernel32.dll"), $aRet
	If $hConsole = -1 Then
		$aRet = DllCall($hDLLK32, "hwnd", "GetStdHandle", "dword", $STD_OUTPUT_HANDLE)
		$iErr = @error
		If @error Or UBound($aRet) <> 2 Or $aRet[0] = $INVALID_HANDLE_VALUE Then
			Return SetError($iErr, 1, $INVALID_HANDLE_VALUE)
		EndIf
		$hConsole = $aRet[0]
	EndIf
	;// create console screen buffer struct, get buffer
	Local $tCONSOLE_SCREEN_BUFFER_INFO = DllStructCreate($tagCONSOLE_SCREEN_BUFFER_INFO)
	If @error Then Return SetError(@error, 2, 0)
	Local $pConsoleScreenBufferInfo = DllStructGetPtr($tCONSOLE_SCREEN_BUFFER_INFO)
	If @error Then Return SetError(@error, 3, 0)
	$aRet = DllCall($hDLLK32, "int", "GetConsoleScreenBufferInfo", "hwnd", _
			$hConsole, "ptr", $pConsoleScreenBufferInfo)
	$iErr = @error
	If @error Or UBound($aRet) <> 3 Or Not $aRet[0] Then Return SetError($iErr, 4, 0)
	;// Get the screen buffer max width (character columns) and height (rows)
	Local $dwSizeX = DllStructGetData($tCONSOLE_SCREEN_BUFFER_INFO, "dwSizeX")
	Local $dwSizeY = DllStructGetData($tCONSOLE_SCREEN_BUFFER_INFO, "dwSizeY")
	Local $dwConSize
	;// input coordinates range check
	If IsNumber($iX) And(Abs($iX) > ($dwSizeX - 1)) Then $iX = $dwSizeX - 1
	If IsNumber($iY) And(Abs($iY) > ($dwSizeY - 1)) Then $iY = $dwSizeY - 1
	Select
		;// clear screen (Default) - max screen buffer width multiplied by height
		Case IsNumber($iX) = 0 And IsNumber($iY) = 0
			; handles Default keyword and strings in params
			$dwConSize = ($dwSizeX * $dwSizeY)
			$iX = 0
			$iY = 0
			;// overwrite or clear any single row - cursor now set to start of that row
		Case IsKeyword($iX) = 1 And IsKeyword($iY) = 0 And $iY >= 0
			$dwConSize = $dwSizeX
			$iX = 0
			;// overwrite or clear a number of rows from starting row
			;(-$iX parameter is number of rows to overwrite, second row minimum)
		Case $iX < 0 And $iY < 0
			$iY = Abs($iY)
			$dwConSize = ($dwSizeX * Abs($iX))
			$iX = 0
			;// overwrite or clear all rows from starting row to last row, second row minimum)
		Case IsKeyword($iX) = 1 And $iY < 0
			$iY = Abs($iY)
			$dwConSize = ($dwSizeX * $dwSizeY) - ($dwSizeX * $iY)
			$iX = 0
			;// overwrite or clear text from character position on row to end of row
		Case $iX >= 0 And IsKeyword($iY) = 0 And $iY >= 0
			$dwConSize = ($dwSizeX - $iX)
			If $iX = 0 And $iY = 0 Then
				$fFlag = True
				ContinueCase
			EndIf
			;// place cursor at last row of console window
		Case $iX >= 0 And IsKeyword($iY) = 1
			If Not $fFlag Then $iY = DllStructGetData($tCONSOLE_SCREEN_BUFFER_INFO, "Bottom")
			ContinueCase
			;// places cursor at coordinates for overwriting
		Case $iX < 0 And $iY >= 0
			$dwCoord = BitOR($iY * 0x10000, BitAND(Abs($iX), 0xFFFF))
			$aRet = DllCall($hDLLK32, "int", "SetConsoleCursorPosition", "hwnd", _
					$hConsole, "dword", $dwCoord)
			$iErr = @error
			If @error Or UBound($aRet) <> 3 Or Not $aRet[0] Then Return SetError($iErr, 5, 0)
			DllClose($hDLLK32)
			Return SetError(0, 0, $hConsole)
		Case Else
			Return SetError(@error, 6, 0)
	EndSelect
	;// Cursor position: make DWord of X,Y coordinates)
	$dwCoord = BitOR($iY * 0x10000, BitAND($iX, 0xFFFF))
	;// Fill selected rows with blanks
	$aRet = DllCall($hDLLK32, "int", "FillConsoleOutputCharacterW", "hwnd", $hConsole, _
			"byte", $bChar, "dword", $dwConSize, "dword", $dwCoord, "int*", 0)
	$iErr = @error
	If @error Or UBound($aRet) <> 6 Or $aRet[5] <> $dwConSize Then Return SetError($iErr, 7, 0)
	;// Get the current text attributes
	$aRet = DllCall($hDLLK32, "int", "GetConsoleScreenBufferInfo", "hwnd", _
			$hConsole, "dword", $pConsoleScreenBufferInfo)
	$iErr = @error
	If @error Or UBound($aRet) <> 3 Or Not $aRet[0] Then Return SetError($iErr, 8, 0)
	Local $wAttribute = DllStructGetData($tCONSOLE_SCREEN_BUFFER_INFO, "wAttributes")
	;// Set the buffer's attributes
	$aRet = DllCall($hDLLK32, "int", "FillConsoleOutputAttribute", "hwnd", $hConsole, _
			"short", $wAttribute, "dword", $dwConSize, "dword", $dwCoord, "int*", 0)
	$iErr = @error
	If @error Or UBound($aRet) <> 6 Or $aRet[5] <> $dwConSize Then Return SetError($iErr, 9, 0)
	;// Put the cursor at 0,0 or supplied coordinates
	$aRet = DllCall($hDLLK32, "int", "SetConsoleCursorPosition", "hwnd", _
			$hConsole, "dword", $dwCoord)
	$iErr = @error
	If @error Or UBound($aRet) <> 3 Or Not $aRet[0] Then Return SetError($iErr, 10, 0)
	DllClose($hDLLK32)
	Return SetError(@error, 0, $hConsole)
EndFunc   ;==>_WinAPI_ClearConsole
