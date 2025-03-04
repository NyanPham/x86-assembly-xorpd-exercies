; 0.0 Write a program that takes the value n as input, and finds the sum of all the odd numbers between 1 and 2n+1, inclusive.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	; Main program
	call 	read_hex
	
	add		eax, eax 
	inc		eax 		; 2n + 1
	mov		ecx, eax 
	mov		esi, 0	
		
check_loop:
	mov		edx, 0 
	mov		eax, ecx 
	mov		ebx, 0x2 
	div		ebx
	
	sub		edx, 0x1
	jnz		.is_even	
.is_odd:
	add		esi, ecx
.is_even:
	dec 	ecx
	jnz		check_loop
	
	mov		eax, esi 
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

