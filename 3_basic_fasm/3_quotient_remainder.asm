; 3.  Write a program that receives two numbers a,b as input, and outputs the remainder of dividing a by b.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex
	mov		esi, eax
	call	read_hex
	
	mov		edx, esi
	mov		esi, eax
	mov		eax, edx 
	
	mov		edx, 0x0 
	div		esi
	
	mov		eax, edx 
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

