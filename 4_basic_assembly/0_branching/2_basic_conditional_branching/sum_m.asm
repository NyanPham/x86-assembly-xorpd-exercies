format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call read_hex 
	mov ecx,eax 
	xor ebx,ebx 
Input:
	call read_hex 
	add ebx,eax 
	
	dec ecx 
	jnz Input 
	
	mov eax,ebx 
	call print_eax 
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'