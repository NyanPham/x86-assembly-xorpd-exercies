; 2. Find out a way to implement NEG using the SUB instruction (And some other
; instructions that we have learned). Write a small piece of code which
; demonstrates your conclusion.

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
