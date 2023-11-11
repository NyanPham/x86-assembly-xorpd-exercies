format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call read_hex 
	mov ebx,eax 			; eax = ebx = n 
	mov ecx,eax 			; ecx = eax / 2 => counter 
	dec ecx 
CheckInner:
	mov eax,ebx 
	xor edx,edx 
	div ecx 
	cmp edx,0
	je NotPrime
				
	dec ecx
	cmp ecx,1 
	jne CheckInner 
		
IsPrime:
	mov eax,1 
	call print_eax 
	jmp Done
NotPrime:
	mov eax,0
	call print_eax 

Done:
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
