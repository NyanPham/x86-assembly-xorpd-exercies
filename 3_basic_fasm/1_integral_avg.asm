; 1. Write a program that receives two numbers a,b and calculates their integral average.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex
	mov		esi, eax 
	call	read_hex
	
	; Compute (x+y)/2
	add		eax, esi
	mov		edx, 0
	mov		esi, 0x2
	div		esi
	
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

