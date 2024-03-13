; 1.  Write a program that receives two numbers a,b and calculates their integral
    ; average.
	
	
format PE console
entry start

include 'win32a.inc'
	
BUFFER_MAX = 20h
NUMS_LEN = 2h
section '.data' data readable writeable 
	enter_num			db	'Please enter a number #%d: ', 0
	avg_value			db	'The integral value is: %d ',13,10,0
	
section '.bss' readable writeable
	input_buffer		db		BUFFER_MAX 	dup (?)
	input_handle		dd 		?
	bytes_read			dd		?
	
	numbers 			dd		NUMS_LEN 	dup (?)
	
section '.text' code readable executable 
start:
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	NUMS_LEN
	push	numbers
	call	get_numbers
	add		esp, 4*2
	
	push	NUMS_LEN
	push	numbers
	call	integral_avg
	add		esp, 4*2
		
	push	eax 
	push	avg_value
	call	[printf]
	add		esp, 4*2
	
	push 	0
	call	[ExitProcess]

; integral_avg(nums_addr, nums_len)
integral_avg:
	.nums_addr = 8h
	.nums_len = 0ch

	push	ebp 
	mov		ebp, esp
	
	push	ebx
	push	ecx 
	push	edx 
	push	esi
	
	mov		esi, dword [ebp + .nums_addr]
	xor		ecx, ecx 
	xor		ebx, ebx 
	
.add_num_loop:
	mov		eax, dword [esi + ecx * 4]
	add		ebx, eax 
	
	inc 	ecx 
	cmp		ecx, dword [ebp + .nums_len]
	jb 		.add_num_loop

.compute_avg:
	mov		eax, ebx 
	mov		ebx, dword [ebp + .nums_len]
	xor 	edx, edx 
	
	div 	ebx 
.end_func:
	pop		esi
	pop		edx 
	pop		ecx 
	pop		ebx 

	pop		ebp 
	ret 

; get_numbers(nums_addr, nums_len)
get_numbers:
	.nums_addr = 8h
	.nums_len = 0ch
		
	push	ebp 
	mov		ebp, esp
		
	push	edx 
	push	ecx 
	push	eax 
	push	edi
		
	mov		edi, dword [ebp + .nums_addr]
	
	xor 	ecx, ecx 
.get_num_loop:
	push	ecx 
	
	inc 	ecx 
	push	ecx 
	push	enter_num
	call	[printf]
	add		esp, 4*2
	
	; Get number from input
	call	read_input
	
	push	input_buffer
	call	str_to_dec
	add		esp, 4
		
	pop		ecx 		
	push	ecx 
		
	mov		dword [edi + ecx*4], eax 
		
	pop		ecx 
	inc		ecx 
	cmp		ecx, dword [ebp + .nums_len] 
	jb 		.get_num_loop
	
.end_func:
	pop		edi
	pop		eax
	pop		ecx
	pop		edx

	pop		ebp 
	ret 

; read_input (	
read_input:	
	push	ebp 
	mov		ebp, esp
	
	push	ecx 
	push	esi
	
	push	0
	push	bytes_read
	push	BUFFER_MAX
	push	input_buffer
	push	dword [input_handle]
	call	[ReadFile]
		
	mov		esi, input_buffer
	add		esi, dword [bytes_read]
	mov		byte [esi], 0
	
.end_func:
	pop		esi 
	pop		ecx 
	pop		ebp
	ret 
	
;str_to_dec(str_addr) 
str_to_dec:
	.str_addr = 8h
	
	push	ebp 
	mov		ebp, esp 
	
	push	esi 
	push	ecx 
	
	mov		esi, dword [ebp + .str_addr]
	
	push	10 
	push	0 
	push	esi
	call	[strtoul]
	add		esp, 4*3
		
.end_func:
	pop		ecx 
	pop		esi
	pop		ebp
	ret 
	

section '.idata' data import readable 

library	kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
			
import 	kernel32,\
		GetStdHandle,'GetStdHandle',\
		ReadFile,'ReadFile',\
		ExitProcess,'ExitProcess'
			
import 	msvcrt,\
		printf,'printf',\
		strtoul,'strtoul'