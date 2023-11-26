; 3.  Write a program that receives two numbers a,b as input, and outputs the remainder of dividing a by b.


format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
    ; The program begins here:
	call read_hex 
	mov ecx,eax 
	call read_hex 
	mov ebx,eax 
	mov eax,ecx 
	mov edx,0 
	div ebx 
	call print_eax 
	mov eax,edx 
	call print_eax 

    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'