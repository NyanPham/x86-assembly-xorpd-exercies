; 0.0 Write a program that takes a double word (4 bytes) as an argument, and
; then adds all the 4 bytes. It returns the sum as output. Note that all the
; bytes are considered to be of unsigned value.

; Example: For the number 03ff0103 the program will calculate 0x03 + 0xff +
; 0x01 + 0x3 = 0x106, and the output will be 0x106

; HINT: Use division to get to the values of the highest two bytes.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex
	mov		ebx, eax			
	
	mov		ecx, 0xffff
	cdq 
	idiv	ecx
	mov		ecx,eax
	
	movzx	eax, cl
	movzx	esi, ch
	add		eax, esi
	movzx	esi, bl
	add		eax, esi
	movzx	esi, bh
	add		eax, esi
	
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

