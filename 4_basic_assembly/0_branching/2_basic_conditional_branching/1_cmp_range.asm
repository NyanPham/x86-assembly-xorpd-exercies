; 1.  Write a program that takes three numbers as input: x,y,z. Then it prints 1 to the console if x < y < z. It prints 0 otherwise.

; NOTE: The comparison should be in the unsigned sense. That means for
; example: 0x00000003 < 0x7f123456 < 0xffffffff

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex 
	mov		ecx, eax		; a
	call	read_hex
	mov		ebx, eax		; b
	call	read_hex 		; c
	
	; We compare using sub and carry flag for the unsigned sense
	sub		ecx, ebx		; a - b
	jnc		.wrong
	sub		ebx, eax  		; b - c 
	jnc		.wrong
	
	mov		eax, 1
	jmp		.correct 
		
.wrong:	
	mov		eax, 0
	jmp		.print
	
.correct:
	mov		eax, 1

.print:
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

