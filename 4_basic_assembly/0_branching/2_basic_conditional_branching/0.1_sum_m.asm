; 0.1 Write a program that takes the value m as input. It then receives m consecutive numbers from the user, sums all those numbers and prints back the total sum to the console.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex
	mov		ecx, eax 
	inc		ecx			; we haven't learned cmp yet
	dec		ecx			; so use inc the dec to affect the zero flag and sign flag
	jz		invalid_input
	js		invalid_input
	
	mov		ebx, 0
	
get_num_loop:
	call	read_hex
	add		ebx, eax 
	dec		ecx 
	jnz		get_num_loop 
			
	mov		eax, ebx
	jmp		print_result
	
	
invalid_input:
	mov		eax, 0	
		
print_result:
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

