
INCLUDE Irvine32.inc


.data

errorMsg1 byte "ERROR: file not found", 0
errorMsg2 byte "ERROR: cannot read file", 0
errorMsg3 byte "ERROR: writing to file failed", 0
errorMsg4 byte "ERROR: creating output file failed", 0

Msg1 byte "Please Enter your MSG: ", 0
Msg2 byte "Please Enter your Key: ", 0
Msg3 byte "Please Enter file name: ", 0
Msg4 byte "Hide or Unhide : (0/1) ", 0
Msg5 byte "Encrypt/Decrypt or none : (0/1) ", 0
Msg6 byte "Continue : (yes is 1, No is 0)", 0

programChoice byte 0

maxLength dword 100

fileDir dword 0
fileSize dword 0

fileFound Byte 0 ; boolean

outputDir byte "Output.txt", 0
outputHandle dword 0

lengthR dword 0 ; used for reading
lengthRead dword 0
toWrite dword 0
ptrForN dword 0 ; pointer for newline
tmpVar1 dword 0
tmpVar2 dword 0
msgLen dword 0
twoDigit byte 0; boolean for encrypting msgLen
; for proto i will use 8 bit key
key byte 0
KeyLen dword 0
currLetter byte 0



filePath byte 100 dup(?)
msg byte 1000 dup(?) 
decMsg byte 1000 dup(?)
bssBuf byte 40 dup(?)

.code

;----------------------------------------------------------------
;Asks the user for the file name to open
;----------------------------------------------------------------

GetName PROC USES ebx ecx edx
		mov edx, OFFSET Msg3
		call WriteString
		mov edx, OFFSET filePath
		mov ecx, 100
		call ReadString
	ret
GetName ENDP

;----------------------------------------------------------------
;Prints the recent file opened
;----------------------------------------------------------------

PrintName PROC USES edx
		mov edx, OFFSET filePath
		call WriteString
		call Crlf
	ret
PrintName ENDP

;----------------------------------------------------------------
;Opens the file recieved in proc getName
;if not found throws error
;----------------------------------------------------------------

OpenFile PROC USES ebx eax ecx edx ; fileName function mode
		mov edx, OFFSET filePath
		call OpenInputFile

		cmp eax, 0
		jg open_succeeded	;jnc open_successed

		errorOpen:
			mov edx, OFFSET errorMsg1
			call WriteString
			call Crlf
			mov fileFound, 0
			jmp doneOpen
		open_succeeded:
			mov fileDir, eax
			mov fileFound, 1
		doneOpen:
			
	ret
OpenFile ENDP

;----------------------------------------------------------------
;Creates a file for output called "Output.txt"
; returns file handler 
;----------------------------------------------------------------

outPutFileCreation PROC USES edx eax
		mov edx, offset outputDir
		call CreateOutputFile
		cmp eax, 0
		jg creation_succeeded
		errorCreation:
			mov edx, OFFSET errorMsg4
			call WriteString
			call Crlf
			jmp doneCreation
		creation_succeeded:
			mov outputHandle, eax
		doneCreation:
			
	ret
outPutFileCreation ENDP

;----------------------------------------------------------------
;Reads the file opened for certain length
; recieves: lengthR the number of bytes to be read
; return: bssBuff array of read bytes
;----------------------------------------------------------------

ReadFilex PROC USES ebx eax ecx edx

		; point to file
		mov eax, fileDir
		
		; pointer to data
		mov edx, offset bssBuf 

		; number of bytes to read
		mov ecx, lengthR
		call ReadFromFile

		js errorReading
		cmp eax, lengthR
		jge reading_succeeded
		errorReading:
			mov edx, OFFSET errorMsg2
			call WriteString
			call Crlf
		reading_succeeded:
			;mov lengthRead, eax
	ret
ReadFilex ENDP

;----------------------------------------------------------------
;writes the data in bssBuff to the output file
; recieves: toWrite contains the number of bytes to be written
;----------------------------------------------------------------

WriteFilex PROC USES eax edx ecx
		mov eax, outputHandle
		mov edx, offset bssBuf
		mov ecx, toWrite
		call WriteToFile
		cmp eax, 0
		jle errorWriting
		jmp written
		errorWriting:
			mov edx, OFFSET errorMsg3
			call WriteString

			call Crlf
			call WriteInt
			call Crlf
		written: 
			
		ret
WriteFilex ENDP

;----------------------------------------------------------------
;Closes the file recently opened
;----------------------------------------------------------------

CloseFilex PROC USES eax ebx 		
		mov eax, fileDir ; mov bx, fileDir
		call closeFile
	ret
CloseFilex ENDP

;----------------------------------------------------------------
;closes output file 
; necessary for unhiding in the same run session after hiding
;----------------------------------------------------------------

CloseOutPutFile PROC USES eax ebx	
		mov eax, OutputHandle 
		call closeFile
	ret
CloseOutPutFile ENDP

;----------------------------------------------------------------
;Extracts the number from array of bytes 
;guaranted that all the bytes are number chars
; recieves: bssBuff and ptrForN which contains the index of 
;the beginnig char in bssBuff
;returns: eax contains the number exteracted
;----------------------------------------------------------------

NumberExteractor PROC USES ebx edi edx
		mov edi, ptrForN
		;mov eax, ptrForN
		;call writeInt
		;call Crlf
		mov eax, 0

		Exter:
			mov edx, 10 
			cmp BYTE PTR [bssBuf + edi], 0Ah
			je done
			cmp BYTE PTR [bssBuf + edi], 0
			je done
			cmp BYTE PTR [bssBuf + edi], 13
			je carriageReturn
			mul edx
			mov ebx, 0
			mov bl, [bssBuf + edi]
			sub ebx, '0'
			add eax, ebx
			inc edi
			jmp Exter
		carriageReturn:
			inc edi
		done:
			inc edi
			;inc edi
			mov ptrForN, edi
	ret
NumberExteractor ENDP

;----------------------------------------------------------------
;Reads the first two lines from the file which indicated width and 
; recieves: ecx contains the offset of the msg (msg for hiding "msg" or from unhide "decmsg")
; returns: lengthRead which indicates the number of bytes to be read till the end of the file
;----------------------------------------------------------------

ReadHeader PROC USES  eax edx ecx
		mov lengthR, 12
		call ReadFilex
		;mov eax,0
		;inc ptrForN
		call NumberExteractor
		mov tmpVar1, eax
		
		;call WriteInt
		;call Crlf
		
		mov eax, 0
		call NumberExteractor
		mov tmpVar2, eax
		
		;call WriteInt
		;call Crlf
		
		mov ebx, [tmpVar1]
		mul ebx
		mov ecx, eax
		sub ecx, 2
		
		;call WriteInt
		;call Crlf

		mov ebx, 15
		mul ebx
		dec eax
		;add eax, ecx
		
		mov lengthRead, eax ; size of the whole file
		
	ret
ReadHeader ENDP 

;----------------------------------------------------------------
;writes the read header to the output file
; the header must be present in bssBuff in order for the proc
; to function properly
;----------------------------------------------------------------

WriteHeaderToOutput PROC USES eax edx ecx
		mov eax, outputHandle
		mov edx, offset bssBuf
		mov ecx, 12
		call WriteToFile
		ret
WriteHeaderToOutput ENDP

;----------------------------------------------------------------
;For debugging purpose moves the file pointer after the header
;----------------------------------------------------------------

EscapeHeader PROC USES  eax edx ecx
		mov lengthR, 12
		call ReadFilex
		ret
EscapeHeader ENDP

;----------------------------------------------------------------
;Reads the whole file and store it in bssBuff
;----------------------------------------------------------------

ReadWhole PROC USES eax
		mov eax, lengthRead
		mov lengthR, eax
		call ReadFilex
	ret
ReadWhole ENDP

;----------------------------------------------------------------
;Gets the msg from the user to be hidden
;----------------------------------------------------------------

GetMsg PROC USES edx eax ecx
		mov edx, OFFSET Msg1
		call WriteString
		mov edx, OFFSET msg
		mov ecx, 1000
		call ReadString
		mov msgLen, eax

	ret
GetMsg ENDP

;----------------------------------------------------------------
;if an encryption is to be preformed this function gets the 8 bits key
;----------------------------------------------------------------

getKey PROC USES edx eax ecx
		mov edx, OFFSET Msg2
		call WriteString
		mov eax, 0
		call ReadChar
		mov key, al
		call writeChar
		call Crlf
	ret
getKey ENDP

;----------------------------------------------------------------
;hides only one letter in 8 lines from the file
; recieves: currLetter
;----------------------------------------------------------------

EncryptLetter PROC USES eax ebx edi ecx
		mov ptrForN, 0
		mov al, currLetter
		;call WriteChar
		;call Crlf
		;xor al, key
		mov bl, 80h
		mov edi, ptrForN
		cmp twoDigit, 1
		je only2
		mov cl, 00h
		jmp enc
		only2:
			mov cl, 20h
		enc:
			cmp bl, cl
			je doneEnc
			EndofNum:
				;cmp BYTE PTR [bssBuf + edi], 0Ah
				;je EncCurrLetter
				cmp BYTE PTR [bssBuf + edi], 0Dh
				je EncCurrLetter
				cmp BYTE PTR [bssBuf + edi], 0
				je EXITENC
				inc edi
				jmp EndofNum
				EncCurrLetter:
					test al, bl
					jz zero
					
					or BYTE PTR [bssBuf + edi - 1], 01h
					jmp avoid
					zero:
						and BYTE PTR [bssBuf + edi - 1], 0FEh
					avoid:
						clc
						shr bl, 1
						inc edi
						jmp enc
						
		doneEnc:
			
		EXITENC:
			;mov ptrForN, edi
	ret
EncryptLetter ENDP

;----------------------------------------------------------------
;sets the two lowest bits to the 2 highest bits
; for hiding the length
; receives : al the number
; returns : al 
;----------------------------------------------------------------

setHighest2bits PROC 
		test al, 01h
		jz zero1
		or al, 40h
		jmp secondBit
		zero1:
			and al, 0AFh
		secondBit:
			test al, 02h
			jz zero2
			or al, 80h
			jmp done
			zero2:
				and al, 7Fh
		done:

	ret
setHighest2bits ENDP

;----------------------------------------------------------------
;hides the length in fist 10 lines then hides the rest of the msg
;writes the hiddin msg to outputfile using proc writeFilex
;writes the rest of the file with no hidden msg to outputfile
;----------------------------------------------------------------

EncBuffer PROC USES edi ecx ebx edx
		;mov ptrForN, 0
		
		; we need only 10 digits to encrypt msgLen
		
			mov eax, msgLen
			
			mov edx, 40
			mov lengthR, edx
			call ReadFilex
			sub lengthRead, edx

			mov currLetter, al
			call EncryptLetter
			mov toWrite, edx
			call writeFilex
			mov twoDigit, 1
			mov bl, ah
			mov al, bl
			call setHighest2Bits

			mov edx, 10
			mov lengthR, edx
			call ReadFilex
			sub lengthRead, edx

			mov currLetter, al
			call EncryptLetter
			mov toWrite, edx
			call writeFilex
			mov twoDigit, 0

		mov edi, 0
		LoopLetters:
			cmp edi, msgLen
			je endLoop
			mov bl, BYTE PTR [msg + edi]
			mov currLetter, bl

			mov edx, 40
			mov lengthR, edx
			call ReadFilex
			sub lengthRead, edx

			call EncryptLetter
			mov toWrite, edx
			call writeFilex
			inc edi
			jmp LoopLetters
		endLoop:
			
			cmp lengthRead, 0
			je done
			cmp lengthRead, 40
			jl lessWrite
				mov edx, 40
				mov lengthR, edx
				call ReadFilex
				sub lengthRead, edx
				mov toWrite, edx
				call writeFilex
				jmp endLoop
			lessWrite:
				mov edx, lengthRead
				mov lengthR, edx
				call ReadFilex
				sub lengthRead, edx
				mov toWrite, edx
				call writeFilex
			done:

	ret 
EncBuffer ENDP

;----------------------------------------------------------------
;retrieves a char from 8 lines or 2 lines in the case of second half of length
; returns: al contains the hidden char or length
;----------------------------------------------------------------

DecryptLetter PROC USES ebx edi ecx
		mov ptrForN, 0
		mov al, 0
		;call WriteChar
		;call Crlf
		;xor al, key
		mov edi, ptrForN
		mov bl, 80h
		cmp twoDigit, 1
		je only2
		mov cl, 00h
		jmp denc
		only2:
			mov cl, 20h
		
		
		denc:
			cmp bl, cl
			je doneEnc
			EndofNum:
				;cmp BYTE PTR [bssBuf + edi], 0Ah
				;je EncCurrLetter
				cmp BYTE PTR [bssBuf + edi], 0Dh
				je EncCurrLetter
				cmp BYTE PTR [bssBuf + edi], 0
				je EXITENC
				inc edi
				jmp EndofNum
				EncCurrLetter:
					test BYTE PTR [bssBuf + edi - 1], 01h
					jz avoid
					or al, bl
					avoid:
						clc
						shr bl, 1
						inc edi
						jmp denc
						
		doneEnc:
			
		EXITENC:
			mov ptrForN, edi
	ret
DecryptLetter ENDP

;----------------------------------------------------------------
;reverses proc setHighest2bits for getting the length correctly
; recieves : al
; returns : al
;----------------------------------------------------------------

setLowest2bits PROC 
		test al, 40h
		jz zero1
		or al, 01h
		jmp secondBit
		zero1:
			and al, 0FEh
		secondBit:
			test al, 80h
			jz zero2
			or al, 02h
			jmp done
			zero2:
				and al, 0FDh
		done:

	ret
setLowest2bits ENDP

;----------------------------------------------------------------
;retrieves the length of the msg
; then the hidden msg based on length
; returns: al
;----------------------------------------------------------------

DecBuffer PROC USES edi ecx ebx edx
		mov ptrForN, 0
		;mov ecx, msgLen

		EncMsgLen:
			;mov eax, msgLen
			mov edx, 40
			mov lengthR, edx
			call ReadFilex

			mov twoDigit, 0
			mov eax, 0
			call decryptLetter

			mov edx, 10
			mov lengthR, edx
			call ReadFilex

			mov msgLen, eax
		
			mov twoDigit, 1
			call decryptLetter
			call setLowest2bits

			mov bl, al
			mov al, BYTE PTR [msgLen]
			mov ah, bl
			mov msgLen, eax
			mov twoDigit, 0

		mov edi, 0
		LoopLetters:
			cmp edi, msgLen
			je endLoop
			
			mov edx, 40
			mov lengthR, edx
			call ReadFilex

			call decryptLetter
			;add al, '0'
			mov BYTE PTR [decMsg + edi], al
			
			inc edi
			jmp LoopLetters
		endLoop:

	ret 
DecBuffer ENDP

;----------------------------------------------------------------
;Performs encryption or decryption on the msg by xoring with a key (8 bits)
; recieves: ecx contains the offset of the msg (msg for hiding or from unhide)
;----------------------------------------------------------------
EncryptMsg PROC USES edi ebx eax
		mov bl, key
		mov edi, 0
		LoopLetters:
			cmp edi, msgLen
			je endLoop
			xor BYTE PTR [ecx + edi], bl
			inc edi
			jmp LoopLetters
		endLoop:
	ret 
EncryptMsg ENDP

;----------------------------------------------------------------
;Asks the user wether to perform encryption or not
; recieves: ecx contains the offset of the msg (msg for hiding "msg" or from unhide "decmsg")
;----------------------------------------------------------------

EncryptOrNot PROC 
			mov edx, offset msg5
			call WriteString
			call Crlf

			call ReadInt
			mov programChoice, al
			cmp programChoice, 0
			je encryptMsgx
			jmp avoid
				encryptMsgx:
					call getKey
					call EncryptMsg
				avoid:
	ret
EncryptOrNot ENDP

;----------------------------------------------------------------
;prints the contents of bssBuff array
; for debugging purpose
;----------------------------------------------------------------

PrintPointer PROC USES edx ecx
		mov edx, OFFSET bssBuf
		mov ecx, lengthRead
		call WriteString
		call Crlf
	ret
PrintPointer ENDP

;----------------------------------------------------------------
;prints the retrieved hidden msg 
;----------------------------------------------------------------

PrintDecMsg PROC USES edx ecx 
		mov edx, offset decMsg
		mov ecx, msgLen
		call WriteString
		call Crlf
	ret
PrintDecMsg ENDP

main proc
	beginCode:
		mov edx, OFFSET msg4
		call writeString
		call Crlf
		call ReadInt
		mov programChoice, al
		cmp eax, 1
		je unhide
		cmp eax, 0
		jne beginCode
		hide:
			call outPutFileCreation
			call GetName
			;call PrintName
	
			call OpenFile
			cmp fileFound, 0
			je doneEnc

			call ReadHeader
			call WriteHeaderToOutput
	
			call GetMsg

			mov ecx, offset msg
			call EncryptOrNot

			call EncBuffer
			;call PrintPointer
			call WriteFilex
			call CloseFilex
			jmp doneEnc
		
		unhide:
			call GetName
			
			call OpenFile
			cmp fileFound, 0
			je doneEnc

			call ReadHeader
			call DecBuffer

			mov ecx, offset decMsg
			call EncryptOrNot

			call printDecMsg
			call CloseFilex
	doneEnc:
		call CloseOutputFile
		mov edx, OFFSET msg6
		call writeString
		call Crlf
		call ReadInt
		cmp eax, 1
		je beginCode
	invoke ExitProcess,0
main endp

end main