; 0. Write a program that takes the number n as input. Then it prints all the
; numbers x below n that have exactly 2 different integral divisors (Besides 1
; and x). 

; For example: 15 is such a number. It is divisible by 1,3,5,15. (Here 3 and 5
; are the two different divisiors, besides 1 and 15).

; However, 4 is not such a number. It is divisible by 1,2,4.

format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
		
	result_is		db	'The numbers <= %d with 2 integral divisors are: ',13,10,0
	result_value	db	'%d',13,10,0
	
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
	push	result_is
	call	[printf]
	add		esp, 4*2 
			
	push	dword [number]
	call	print_lower_integrals
	add		esp, 4 
			
	push	0
	call	[ExitProcess]

; print_lower_integrals(num)
print_lower_integrals:
	.num = 8h
	
	push	ebp 
	mov		ebp, esp
	
	push	eax 
	push	ebx 
	push	ecx 
	push	edx 
	
	mov		edx, dword [ebp + .num]
	mov		ecx, 1
	
.check_print_loop:
	push	ecx 
	push	edx 

	push	ecx 
	call	count_divisors
	add		esp, 4
	
	cmp		eax, 2 
	jne		.next_iter
	
	push	ecx 
	push	result_value
	call	[printf]
	add		esp, 4*2
	

.next_iter:
	pop		edx 
	pop		ecx 

	inc		ecx 
	cmp		ecx, edx 
	jbe		.check_print_loop

.end_func:	
	pop		edx 
	pop		ecx 
	pop		ebx 
	pop		eax 

	pop		ebp
	ret 
	
; count_divisors(num)
count_divisors:
	.num = 8h
	
	push	ebp 
	mov		ebp, esp
	
	push	esi
	push	ecx 
	push	ebx
	
	mov		esi, dword [ebp + .num]
	xor		eax, eax 
	cmp		esi, 2 
	jbe		.end_func
	
	mov		ecx, 2 
	xor 	ebx, ebx 

.count_loop:
	push	ecx 
	push	esi
	call	is_divisor
	add		esp, 4*2 
	
	test 	eax, eax 
	je		.next_iter
	
	inc		ebx
		
.next_iter:
	inc		ecx 
	cmp		ecx, esi
	jb		.count_loop
		
	mov		eax, ebx
	
.end_func:
	pop		ebx
	pop		ecx
	pop		esi
	
	pop		ebp 
	ret 
	
	

; is_divisor(dividend, divisor)
is_divisor:
	.dividend = 8h
	.divisor = 0ch
	
	push	ebp 
	mov		ebp, esp
	
	push	ebx
	push	edx
		
	mov		eax, dword [ebp + .dividend]
	mov		ebx, dword [ebp + .divisor]
	xor 	edx, edx 
	
	div 	ebx 
	test 	edx, edx 
	jz		.is_divisor
	mov		eax, 0
	jmp 	.end_func
	
.is_divisor:
	mov		eax, 1
	
.end_func:
	
	pop		edx 
	pop		ebx 

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