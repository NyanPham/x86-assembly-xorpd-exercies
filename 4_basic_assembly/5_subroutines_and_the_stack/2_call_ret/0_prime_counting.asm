format PE console
entry start 

include 'win32a.inc'

section '.data' data readable writeable
	enter_number 		db	'Please enter a number: ',0
	total_primes		db  'The total of primes is: ',0 
	newline 			db  13,10,0

section '.text' code readable executable

start:
	mov		esi, enter_number
	call	print_str 
		
	call	read_hex 	
	call	count_primes 
	
	mov		esi, newline 
	call	print_str 
	mov		esi, total_primes
	call	print_str  
	call	print_eax 
	
	push	0
	call	[ExitProcess]
	
	
;===============================================================
; Input: eax -> number to check if it's a prime
; Operation: Iterate from 1 to eax and divide by it to check 
; 				if it's a divisor	
; Output: eax <- 1 if prime, else eax <- 0 
;=============================================================== 
is_prime:
	push	edi
	push	edx
	push	ecx	
	
	cmp		eax, 1 
	
	jbe 	.not_prime 	
		
	mov		edi, eax 
	mov		ecx, eax
.check_divisor:
	dec		ecx 
	cmp		ecx, 1 
	jbe 	.prime 
	
	xor 	edx, edx 
	mov		eax, edi 
	div		ecx 
	test	edx, edx 
	jz		.not_prime 
	jmp		.check_divisor
	
.not_prime:	
	mov		eax, 0
	jmp		.is_prime_done
.prime:	
	mov		eax, 1
.is_prime_done:
	pop 	ecx 
	pop 	edx 
	pop 	edi 
	
	ret 
	
;===============================================================
; Input: eax -> number as an upperbound to check for total of primes
; Operation: Iterate from 1 to eax and increment total if it's a prime	
; Output: eax <- total of primes
;=============================================================== 
count_primes:
	push	ebx
	push	ecx 
	
	xor		ebx, ebx 
	xor		ecx, ecx 
	
	cmp		eax, 1
	jbe 	.count_primes_done
	
.check_next:
	push	eax 
	mov		eax, ecx 
	call	is_prime 
	test	eax, eax 
	jz		.not_prime 
	inc		ebx 
.not_prime:
	pop		eax 
	inc		ecx 
	cmp		ecx, eax 
	jbe 	.check_next 

.count_primes_done:
	mov		eax, ebx 

	pop		ecx 
	pop		ebx 

	ret 

include 'training.inc'
