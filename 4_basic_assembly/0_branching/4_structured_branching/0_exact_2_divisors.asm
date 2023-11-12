format PE console
entry start

include 'win32a.inc'

; ===============================================
section '.text' code readable executable
	
start:
	call read_hex 			; input N 
	mov esi,eax 			; esi holds original N
	mov ecx,2 				; loop counter until N 
Iters:
	mov ebx,0 				; count of divisibles 
	mov edi,ecx 
	dec edi 				; edi innerloop for as divisors 
CheckDivisible:
	mov edx,0
	mov eax,ecx 
	div edi 
	cmp edx,0
	jne NoRemainder 
	inc ebx
	
NoRemainder:
	dec edi 
	cmp edi,1 
	ja CheckDivisible
	
	cmp ebx, 2
	jne No2Divisors 
			
Has2Divisors:
	mov eax,ecx
	call print_eax 
	
No2Divisors:	
	inc ecx 
	cmp ecx,esi 
	jbe Iters 
		
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
