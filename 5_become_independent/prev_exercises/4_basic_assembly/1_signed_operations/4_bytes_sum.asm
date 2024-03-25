; 0.0 Write a program that takes a double word (4 bytes) as an argument, and
; then adds all the 4 bytes. It returns the sum as output. Note that all the
; bytes are considered to be of unsigned value.

; Example: For the number 03ff0103 the program will calculate 0x03 + 0xff +
; 0x01 + 0x3 = 0x106, and the output will be 0x106

; HINT: Use division to get to the values of the highest two bytes.

format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	
	sum_bytes_is	db	'Sum bytes of number %d is: %d',13,10,0
	
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
	call	sum_bytes
	add		esp, 4
	
	push	eax 
	push	dword [number]
	push	sum_bytes_is
	call	[printf]
	add		esp, 4*3
	
	push	0
	call	[ExitProcess]
	
; sum_bytes(num)
sum_bytes:
	.num = 8h
	
	push	ebp 
	mov		ebp, esp
	
	push	ebx
	push	ecx 
	push	edx 
	
	mov		eax, dword [ebp + .num]
	mov		ecx, 4h 
	xor		ebx, ebx 
	
.shift_add_loop:
	xor 	edx, edx 
	movzx	edx, al 
	shr		eax, 8 
	
	add		ebx, edx 
	
	dec		ecx 
	jnz		.shift_add_loop
	
	mov		eax, ebx 
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