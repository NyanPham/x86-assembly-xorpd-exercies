; 1. Write a program that takes the number n as input, and prints back all the
; pairs (x,y) such that x < y < n.
   
format PE console
entry start

include 'win32a.inc'

; ===============================================
section '.text' code readable executable
	
start:
	call read_hex 
	mov ecx,eax 
	mov edx,1			; ebx = x + 1 = 1
y_loop: 				; for ebx, ebx < edx < ecx 
	mov ebx,0
x_loop: 				; for ebx, ebx < edx, starts at 0	
print_x_y:
	mov eax,ebx 
	call print_eax 
	mov eax,edx 
	call print_eax 
	
next_x:
	inc ebx 
	cmp ebx,edx 
	jb 	x_loop 
	
next_y:
	inc edx
	cmp edx,ecx 
	jb y_loop
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
