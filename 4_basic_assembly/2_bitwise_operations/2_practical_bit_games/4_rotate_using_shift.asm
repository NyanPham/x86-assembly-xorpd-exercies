; 4.  Rotation using shifts.

; Implement the ror instruction using the shift instructions. You may use any
; bitwise instruction for this task, except for the rotation instructions
; (ror,rol).

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex	
	mov		esi, eax		; x	
	call	read_hex		
	mov		ecx, eax		; k bits to rotate
	mov		ebx, 0x20
	sub		ebx, ecx
	
	mov		edi, esi
	shr		edi, cl
	mov		cl, bl
	shl		esi, bl
	or		esi, edi
	
	mov		eax, esi
	call	print_eax

    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

