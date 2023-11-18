format PE console
entry start

include 'win32a.inc'
		
; ===============================================
section '.text' code readable executable
	
start:
	call read_hex 
	mov ecx, 0
	sub ecx, eax
	mov eax,ecx 
	
	call print_eax 
		
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
