
format PE console
entry start

include 'win32a.inc' 
	
; ===============================================

section '.text' code readable executable
	
start: 
	call read_hex 
	mov ecx,eax 

calculate:
	cmp ecx,0
	jz Done 
	
	shr ecx,1
	xor eax,ecx 
	jmp calculate
	
Done:
	call print_eax 
	
	
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
