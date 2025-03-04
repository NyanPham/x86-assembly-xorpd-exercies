; 1. Write a program that takes the number n as input, and prints back all the
; pairs (x,y) such that x < y < n.
   
format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex
	mov		esi, eax 
	
; outerloop for y:
next_y:
	dec		esi
	cmp		esi, 0 
	jle		done

	mov		edi, esi
next_x:
	dec		edi
	
	cmp		edi, 0
	jl		next_y
	
	mov		eax, edi
	call	print_eax
	mov		eax, esi 
	call	print_eax
		
	jmp		next_x

done:
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

