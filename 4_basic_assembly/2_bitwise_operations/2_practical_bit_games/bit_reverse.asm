format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start: 
	call read_hex 
	xor ebx,ebx 
	mov ecx,32 
reverse_bit:
	shl ebx,1 
	shr eax,1 
	jnc countdown 
	inc ebx 
	
countdown:		
	dec ecx 
	jnz reverse_bit 

	mov eax, ebx 
	call print_eax 
	
    ; Exit the process:
	push	0
	call	[ExitProcess]
	

include 'training.inc'
