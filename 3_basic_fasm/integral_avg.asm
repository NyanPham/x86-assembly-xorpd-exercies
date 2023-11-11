
format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
    ; The program begins here:
	
	call read_hex
	mov ebx,eax 
	call read_hex 
	add eax,ebx 
	mov edx,0
	mov ebx,2
    div ebx 
	call print_eax
	

    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'