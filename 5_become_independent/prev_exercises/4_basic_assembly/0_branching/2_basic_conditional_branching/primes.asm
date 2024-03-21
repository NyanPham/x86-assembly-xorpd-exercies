; 3.1   Write a program that takes a number n as input, and prints back to the
; console all the primes that are larger than 1 but not larger than n.

format PE console 
entry start 

include 'win32a.inc'

INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number		db	'Please enter a number: ',0
	primes_are			db 	'The prime numbers from 1 to %d are listed below:',13,10,0
	prime				db 	'%d',13,10,0
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	number 			dd	?
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_number
	call	get_num
	add		esp, 4 
	
	mov		dword [number], eax 
		
	push	dword [number]
	push	primes_are
	call	[printf]
	add		esp, 4*2
	
	push	dword [number] 
	call	print_primes 
	add		esp, 4 
	
	push	0
	call	[ExitProcess]

; print_primes(upper_bound_num)
print_primes:
	.upper_bound_num = 8h
	
	push	ebp 
	mov		ebp, esp 
	pusha 
	
	mov		esi, dword [ebp + .upper_bound_num]
	cmp		esi, 1 
	jbe 	.end_func
	mov		ecx, 1
	
.is_prime_loop:
	push	ecx 
	call	is_prime
	add		esp, 4
	
	test 	eax, eax 
	jz		.not_prime
	
	push	ecx 
	
	push	ecx 
	push	prime
	call	[printf]
	add		esp, 4*2 
				
	pop 	ecx 
.not_prime:
	inc 	ecx 
	cmp		ecx, esi
	jbe		.is_prime_loop
		
.end_func:	
	popa 
	pop		ebp
	ret 
	
	
; is_prime(number)
is_prime:
	.number = 8h
	
	push	ebp 
	mov		ebp, esp
		
	push	ecx 
	push	ebx 
	push	edx 
		
	mov		eax, dword [ebp + .number]
	cmp		eax, 1
	jbe		.not_prime 
			
	mov		ebx, eax 			; ebx, the orginal value of number		
	mov		ecx, eax 
	dec 	ecx 
.check_prime_loop:
	cmp		ecx, 1
	je		.is_prime 
		
	xor 	edx, edx 
	mov		eax, ebx 
	div		ecx 
	
	test 	edx, edx 
	je		.not_prime 
	dec 	ecx 
	jmp .check_prime_loop
	
.is_prime:
	mov 	eax, 1
	jmp 	.end_func
	
.not_prime:
	mov		eax, 0
	
.end_func:
	pop		edx 
	pop		ebx 
	pop		ecx 
	
	pop		ebp 
	ret 

; get_num(prompt_addr)
get_num:
	.prompt_addr = 8h
	
	push	ebp 
	mov		ebp, esp 
		
	push	dword [ebp + .prompt_addr]
	call	[printf]
	add		esp, 4 
	
	push	INPUT_BUFFER_MAX_LEN
	push	bytes_read
	push	input_buffer 
	call	get_line
	add		esp, 4*3
	
	push	input_buffer 
	call	str_to_dec
	add		esp, 4
	
	pop		ebp
	ret 

; get_line(input_buffer, bytes_read, bytes_to_read)
get_line:
	.input_buffer = 8h
	.bytes_read = 0ch
	.bytes_to_read = 10h
	
	push	ebp 
	mov		ebp, esp
	
	push	ecx 
	push	esi
	
	mov		ecx, dword [ebp + .bytes_read]
	mov		esi, dword [ebp + .input_buffer]
	
	push	0
	push	ecx 
	push	dword [ebp + .bytes_to_read]
	push	esi 
	push	dword [input_handle]
	call	[ReadFile]
	
	pop		esi 
	pop		ecx 
	
	pop		ebp 
	ret 
	
; str_to_dec(str_addr)
str_to_dec:
	.str_addr = 8h 
	
	push	ebp
	mov		ebp, esp 
	
	push	10
	push	0
	push	dword [ebp + .str_addr]
	call 	[strtoul]
	add		esp, 4*3 
	
	pop		ebp
	ret 

section '.idata' data import readable 

library kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import	kernel32,\
		ReadFile,'ReadFile',\
		GetStdHandle,'GetStdHandle',\
		ExitProcess,'ExitProcess'
		
import	msvcrt,\
		printf,'printf',\
		strtoul,'strtoul'