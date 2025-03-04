; 0. Write a program the receives three numbers and sums those three numbers. Then output the result.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex 
	mov		esi,eax
	call	read_hex
	add		esi,eax 
	call	read_hex
	add		eax,esi
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

