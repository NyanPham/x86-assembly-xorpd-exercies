; 0. Write a program that takes the number n as input. Then it prints all the
; numbers x below n that have exactly 2 different integral divisors (Besides 1
; and x). 

; For example: 15 is such a number. It is divisible by 1,3,5,15. (Here 3 and 5
; are the two different divisiors, besides 1 and 15).

; However, 4 is not such a number. It is divisible by 1,2,4.

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
