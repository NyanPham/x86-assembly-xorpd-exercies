; 3.1   Write a program that takes a number n as input, and prints back to the
; console all the primes that are larger than 1 but not larger than n.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call 	read_hex
	mov		esi, eax 
	mov		edi, 2			; num_counter 
	
check_num_loop:
	sub		edi, esi
	jnc		end_check	
	add		edi, esi		; restore
		
	mov		ecx, edi
	sub		ecx, 0x2 			
	jz		print_prime		; is number a two?
	
	mov		ecx, edi		
	dec		ecx 			; inner_counter
	
check_prime:
	mov		eax, edi 
	mov		edx, 0
	div	 	ecx 
	
	inc		edx 
	dec		edx
	jz		next_num
	dec		ecx
	
	dec		ecx
	jz		print_prime
	inc		ecx 
	jmp		check_prime
	
print_prime:
	mov		eax, edi 
	call	print_eax 
	
next_num:
	inc		edi
	jmp		check_num_loop

is_two:
	mov		eax, 2
	call	print_eax
	jmp		end_check
is_zero:
is_one:

end_check:

    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

