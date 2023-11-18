format PE console
entry start

include 'win32a.inc'
		
; ===============================================
section '.text' code readable executable
	
start:
	call read_hex 
	neg eax 
	dec eax 
	
	call print_eax 
		
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
