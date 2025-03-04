; 2.  Write a program that receives a number x as input, and outputs to the
; console the following values: x+1, x^2 , x^3, one after another.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex
	mov		esi, eax
	
	inc		eax
	call	print_eax 
	
	mov		eax, esi
	mul		eax
	call	print_eax 
	
	mul		esi
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

