; 1. Write a program that takes the number n as input, and prints back all the
; pairs (x,y) such that x < y < n.
   
   
format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	pair			db	'(%d, %d)',13,10,0
		
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
	mov		dword [number], eax 
	
	push	eax 
	call	print_pairs
	add		esp, 4
	
	push	0
	call	[ExitProcess]
	

; print_pairs(num)
print_pairs:
	.num = 8h
	
	push	ebp 
	mov		ebp, esp
	
	push	edi 
	push	ecx 
	push	ebx 
	
	mov		edi, dword [ebp + .num]
	mov		ebx, 0
	
.print_loop_outer:
	lea 	ecx, dword [ebx + 1]
	cmp		ecx, edi 
	jae		.end_func
.print_loop:
	push	ecx 
	
	push	ecx 
	push	ebx
	push	pair
	call	[printf]
	add		esp, 4*3 
			
	pop		ecx 
		
	inc 	ecx 
	cmp		ecx, edi
	jb		.print_loop
	
	inc		ebx 
	cmp		ebx, edi
	jb		.print_loop_outer 
	
.end_func:
	pop		ebx 
	pop		ecx 
	pop		edi
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