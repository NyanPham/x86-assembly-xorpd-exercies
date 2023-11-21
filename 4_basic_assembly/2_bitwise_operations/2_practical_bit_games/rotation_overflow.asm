format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable
	
start: 
	mov eax,20d
	call print_eax_binary
				
	ror eax, 35d
					
	call print_eax_binary 

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
