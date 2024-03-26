; 0.1 Write a program that does the same, except that it multiplies the four
; bytes. (All the bytes are considered to be unsigned).


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	bytes_prod_is	db	'The product of bytes in decimal %d is: %d',13,10,0
	
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
	call	multiply_bytes
	add		esp, 4 
		
	push	eax 
	push	dword [number]
	push	bytes_prod_is
	call	[printf]
	add		esp, 4*3
			
	push	0
	call	[ExitProcess]
	
; multiply_bytes(num)
multiply_bytes:
	.num = 8h
	
	push	ebp 
	mov		ebp, esp
	
	push	ebx
	push	ecx 
	push	edx 
	push	edi 
	
	mov		ebx, dword [ebp + .num]
	mov		ecx, 4h
	mov		eax, 1h
	
.shift_multiply_loop:  
	movzx	edx, bl 
	shr 	ebx, 8
	mul		edx 
	dec		ecx 
	jnz		.shift_multiply_loop 
	
.end_func:
	pop		edi
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