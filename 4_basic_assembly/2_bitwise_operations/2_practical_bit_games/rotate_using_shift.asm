format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start: 
	call read_hex 
	mov ebx,eax 				; input to rotate 
	
	call read_hex 
	mov ecx, eax 				; bits count to rotate
	clc 
rotate_r:
	shr ebx,1
	jnc no_carry
			
	or ebx, 0x80000000
		
no_carry:
	clc	
	dec ecx 
	jnz rotate_r
		
	mov eax,ebx 
	call print_eax 

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
