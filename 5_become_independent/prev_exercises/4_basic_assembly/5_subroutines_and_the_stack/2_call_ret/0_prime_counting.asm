; 0.  Prime counting

    ; We want to calculate the amount of prime numbers between 1 and n.

    ; Recall that a prime number is a positive integer which is only divisible by
    ; 1 and by itself. The first prime numbers are 2,3,5,7,11,13. (1 is not
    ; considered to be prime).

    ; We break down this task into a few subtasks:

    ; 0.  Write a function that takes a number x as input. It then returns 
        ; eax = 1 if the number x is prime, and eax = 0 otherwise.

    ; 1.  Write a function that takes a number n as input, and then calculates the
        ; amount of prime numbers between 1 and n. Use the previous function that
        ; you have written for this task.

    ; Finally ask for an input number from the user, and use the last function you
    ; have written to calculate the amount of prime numbers between 1 and n.

    ; Bonus Question: After running your program for some different inputs, Can
    ; you formulate a general rough estimation of how many primes are there
    ; between 1 and n for some positive integer n?
	

format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number		db	'Please enter a number: ',0
	primes_total_is		db	'There are %d prime numbers between 1 and %d.',13,10,0
	
	
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
	call	count_primes
	add		esp, 4 
	
	push	dword [number]
	push	eax 
	push	primes_total_is
	call	[printf]
	add		esp, 4*3
	
	push	0
	call	[ExitProcess]

; count_primes(num)
; Count the primes present from 1 to num
count_primes:
	.num = 8h
	
	push	ebp
	mov		ebp, esp
	
	push	ebx
	push	ecx 
	push	edi
	
	mov		edi, dword [ebp + .num]
	mov		ecx, 1
	xor		ebx, ebx

.count_loop:
	push	ecx 
	call	is_prime
	add		esp, 4 
	
	test 	eax, eax 
	jz		.skip_increment
	inc		ebx		
	
.skip_increment:
	inc		ecx 
	cmp		ecx, edi 
	jng		.count_loop
	
	mov		eax, ebx
	
.end_func:
	pop		edi
	pop		ecx 
	pop		ebx

	pop		ebp
	ret 

; is_prime(num)
is_prime:
	.num = 8h
	
	push	ebp 
	mov		ebp, esp
	
	push	ecx 
	push	edi 
	
	mov		eax, dword [ebp + .num]
	cmp		eax, 1 
	jle		.not_prime
	
	mov		edi, eax
	mov		ecx, 2
	cmp		ecx, dword [ebp + .num]
	je		.is_prime
	
.divisor_loop:	
	mov		eax, dword [ebp + .num]
	xor		edx, edx 
	div		ecx
	test	edx, edx
	jz		.not_prime
		
	inc		ecx 
	cmp		ecx, dword [ebp + .num]
	jnz		.divisor_loop
	
.is_prime:
	mov		eax, 1
	jmp		.end_func

.not_prime:
	mov		eax, 0
.end_func:
	pop		edi 
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
	
	pusha
	
	mov		ecx, dword [ebp + .bytes_read]
	mov		esi, dword [ebp + .input_buffer]
	
	push	0
	push	ecx 
	push	dword [ebp + .bytes_to_read]
	push	esi 
	push	dword [input_handle]
	call	[ReadFile]
	
	mov		ebx, dword [ebp + .bytes_read]
	
	mov		eax, dword [ebx]
	mov		byte [esi + eax], 0
	dec		eax 
	mov		byte [esi + eax], 0
	dec		eax
	mov		byte [esi + eax], 0
	inc 	eax 

	mov		dword [ebx], eax 

.end_func:
	popa 
	
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