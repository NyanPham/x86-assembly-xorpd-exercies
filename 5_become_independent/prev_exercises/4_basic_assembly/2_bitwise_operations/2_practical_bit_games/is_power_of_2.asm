; 6.  Bonus: Identifying powers of two.

; 6.1   Write a program that takes a number x and finds out if this number is
; a power of 2. It outputs 1 if the number is a power of 2, and 0
; otherwise.


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	result_p2		db	'%d is power of two: %d', 0
		
	input_value		db	'Test value: %d',13,10,0
	
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
	call	is_exp_of_two
	add		esp, 4
	
	push	eax
	push	dword [number]
	push	result_p2
	call	[printf]
	add		esp, 4*3
	
	push	0
	call	[ExitProcess]
	

; is_exp_of_two(num)
is_exp_of_two:
	.num = 8h
	
	push	ebp 
	mov		ebp, esp
	
	push	ebx			; number to check 
	push	ecx 		; loop iterator
	push	edx 		; 1 bit locations count

	mov		ebx, dword [ebp + .num]
	test 	ebx, ebx 
	jz		.not_exp_two
		
	mov		ecx, 01fh
	xor		edx, edx 
	
.shift_check_loop:
	shr		ebx, 1h
	jnc		.not_carry
	inc		edx 
	cmp		edx, 2
	jae		.not_exp_two
		
.not_carry:
	dec		ecx 
	jnz 	.shift_check_loop 
		
	cmp		edx, 1
	jne		.not_exp_two
	
.is_exp_two:
	mov		eax, 1
	jmp		.end_func

.not_exp_two:
	mov		eax, 0
	
.end_func:
	pop		edx 
	pop		ecx 
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