; 1.  Write a program that takes three numbers as input: x,y,z. Then it prints 1 to the console if x < y < z. It prints 0 otherwise.

; NOTE: The comparison should be in the unsigned sense. That means for
; example: 0x00000003 < 0x7f123456 < 0xffffffff


format PE console 
entry start 

include 'win32a.inc'

INPUT_BUFFER_MAX_LEN = 20h

NUMBERS_LEN	= 3h

section '.data' data readable writeable 
	enter_number_1	db	'Please enter number x: ',0
	enter_number_2	db	'Please enter number y: ',0
	enter_number_3	db	'Please enter number z: ',0
	
	result_is		db	'x < y < z: %d',0
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
		
	numbers 		dd	NUMBERS_LEN dup	(?)
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE 
	call	[GetStdHandle]
	mov		dword [input_handle], eax 

	push	enter_number_1
	call	get_num 
	add		esp, 4 
	
	mov		dword [numbers], eax 
	
	push	enter_number_2
	call	get_num 
	add		esp, 4 
		
	mov		dword [numbers + 4], eax 
	
	push	enter_number_3
	call	get_num 
	add		esp, 4 
		
	mov		dword [numbers + 8], eax 
	
	push	NUMBERS_LEN
	push	numbers
	call	compare_three_nums
	add		esp, 4*2 
	
	push	eax 
	push	result_is 
	call	[printf]
	add		esp, 4*2	
		
	push	0
	call	[ExitProcess]
	
compare_three_nums:
	.nums_addr = 8h
	.nums_length = 0ch
		
	push	ebp 
	mov		ebp, esp 
		
	push	ebx
	push	ecx 
	push	esi
	
	mov		ebx, dword [ebp + .nums_length]
	dec 	ebx 
	
	mov		esi, dword [ebp + .nums_addr]
	xor 	ecx, ecx 
	
.cmp_loop:
	mov		eax, dword [esi + ecx*4]
	cmp		eax, dword [esi + ecx*4 + 4]

	ja		.not_true
	
	inc 	ecx 
	cmp 	ecx, ebx 
	jb 		.cmp_loop 
	
	mov		eax, 1
	jmp		.end_func 
.not_true:
	mov		eax, 0
.end_func:
	pop		esi
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