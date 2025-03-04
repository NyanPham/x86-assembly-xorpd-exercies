 ; 3.0   Write a program that takes a number m as input, and prints back 1 to the
        ; console if m is a prime number. Otherwise, it prints 0.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex 
	mov		ebx, eax 
	mov		ecx, eax 

check_prime:
	inc		ecx
	dec		ecx 	
	jz		.not_prime		; n == 0 -> not prime 
	
	dec		ecx
	jz		.not_prime 		; n == 1 -> not prime
	
	dec		ecx
	jz		.is_prime		; n == 2 -> is prime
		
	mov		ecx, eax
	dec		ecx 			; n - 1
	
.check_prime_loop:
	mov		eax, ebx
	mov		edx, 0
	div		ecx 
	
	dec		edx 
	inc		edx
	jz		.not_prime 
	
	dec		ecx
	dec		ecx
	jz		.is_prime
	inc		ecx 
	jmp		.check_prime_loop 

.is_prime:
	mov		eax, 1
	jmp		print_result 

.not_prime:
	mov		eax, 0

print_result:
	call	print_eax
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

