format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call read_hex 
	mov ebx, eax 
	call read_hex 
	xor ebx,eax 
	call read_hex 
	xor ebx,eax 
	and ebx,1 
	mov eax,ebx 
	call print_eax 
	
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
