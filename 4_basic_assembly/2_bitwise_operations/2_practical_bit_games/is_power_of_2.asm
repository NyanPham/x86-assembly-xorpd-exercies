format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start: 
	call read_hex 
	mov ecx, 32d 
	xor ebx,ebx 			; counter for 1's in binary string 
	clc 
next_bit:
	shr eax,1 
	jnc no_carry
		
	inc ebx 
no_carry:
	dec ecx 
	jnz next_bit
	
	cmp ebx,1
	jnz not_power_of_2
	mov eax,1
	call print_eax 
	jmp Done
	
not_power_of_2:
	mov eax, 0
	call print_eax 
	
Done:
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
