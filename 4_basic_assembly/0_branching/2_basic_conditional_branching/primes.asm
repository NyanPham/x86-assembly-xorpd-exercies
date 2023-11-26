; 3.1   Write a program that takes a number n as input, and prints back to the
; console all the primes that are larger than 1 but not larger than n.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable
	
start:
	call read_hex 
	mov ebx,eax 				; ebx = n
	mov ecx,1					; ecx = counter 1 -> ebx 
	
CheckNumber:
	mov esi,ecx
	dec esi 
	cmp esi,1 
	je IsPrime
	cmp esi,0
	je IsPrime
	
CheckPrime:
	xor edx,edx 
	mov eax,ecx 
	div esi
	cmp edx,0
	je Cont
	
	dec esi
	cmp esi,1 
	jne CheckPrime
	
IsPrime:
	mov eax,ecx
	call print_eax
	
Cont:
	inc ecx 
	cmp ecx,ebx 
	jl CheckNumber
		
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
