; 0.0 Write a program that takes the value n as input, and finds the sum of all the odd numbers between 1 and 2n+1, inclusive.

format PE console 
entry start 

include 'win32a.inc'

INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	odd_sum_is		db	'Input: %d',13,10
					db	'The sum of all odd numbers between 1 and 2x%d+1 is: %d',13,10,0
		
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
	
	call	get_num
	mov		dword [number], eax 
	
	push	number
	call	sum_odd
	add		esp, 4
		
	push	eax 
	push	dword [number]
	push	dword [number]
	push	odd_sum_is 
	call	[printf]
	add		esp, 4*4
	
	push	0
	call	[ExitProcess]
	
; sum_odd(num_addr) 
sum_odd:	
	.num_addr = 8h
	
	.local_boundary = 4h
	
	push	ebp
	mov		ebp, esp 
	
	sub		esp, .local_boundary
	
	push	ecx 
	push	esi
	push	ebx 
	push	edx 
	push	edi
			
	mov		esi, dword [ebp + .num_addr]
	
	mov		eax, dword [esi]
	shl 	eax,1
	inc		eax 
	mov		dword [ebp - .local_boundary], eax 
	
	mov 	ecx, 1
		
	mov		ebx, 2h
	xor		edi, edi 
		
.add_loop:
	xor		edx, edx 
	mov		eax, ecx 
	div		ebx 
	
	cmp		edx, 0
	je 		.not_odd
	
	add		edi, ecx 
		
.not_odd:	
	inc 	ecx 
	cmp		ecx, dword [ebp - .local_boundary]
	jbe		.add_loop 
	
	mov		eax, edi
.end_func:
	pop		edi
	pop		edx 
	pop		ebx 
	pop		esi 
	pop		ecx 
		
	add		esp, .local_boundary
	
	pop		ebp
	ret 
	
	
	
get_num:
	push	ebp 
	mov		ebp, esp 
	
	push	enter_number
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