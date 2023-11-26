; 0.0   Write a program that takes a number x as input, and returns:
; - 0 if x is even.
; - 1 if x is odd. 

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start: 
	call read_hex 
	shr	eax,1 
	jc	is_odd
is_even:
	mov eax, 0
	call print_eax
	jmp Done
	
is_odd:
	mov eax,1 
	call print_eax 
	
Done:

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
