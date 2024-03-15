; 3.  Write a program that receives two numbers a,b as input, and outputs the
    ; remainder of dividing a by b.

format PE console
entry start 


include 'win32a.inc'

INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable
	enter_number		db	'Please enter number %d: ',0
	remainder_is 		db	'The remainder is: %d',13,10,0
	
section '.bss' readable writeable
	input_handle 		dd	?
	input_buffer		dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read			dd	?
	
	num_a				dd	?
	num_b				dd	?
	
section '.text' code readable writeable
	
start:
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	1
	call	get_number
	add		esp, 4
	mov		dword [num_a], eax 
	
	push	2
	call	get_number
	add		esp, 4 
	mov		dword [num_b], eax 
	
	push	dword [num_b]
	push	dword [num_a]
	call	get_remainder
	add		esp, 4*2 
			
	push	eax 
	push	remainder_is
	call	[printf]
	add		esp, 4*2
		
	push	0
	call	[ExitProcess]
	
; get_remainder(a, b)
; Input:
;	number a 
; 	number b
; Output:
;	eax -> remainder a % b 
get_remainder:	
	.a = 8h
	.b = 0ch
	
	push	ebp 
	mov		ebp, esp 
	
	push	ebx 
	push	edx 
	
	xor		edx, edx 
	mov		eax, dword [ebp + .a]
	mov		ebx, dword [ebp + .b]
	
	div		ebx 
	mov		eax, edx 
	
	pop		edx 
	pop		ebx 
	pop		ebp 
	ret 
	

; get_number(num_name) 
get_number:
	.num_name = 8h
	
	push	ebp 
	mov		ebp, esp 
		
	push	dword [ebp + .num_name]
	push	enter_number
	call	[printf]
	add		esp, 4 * 2
		
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


; str_to_dec(input_buffer)
str_to_dec:
	.input_buffer = 8h 
	
	push	ebp 
	mov		ebp, esp
		
	push	10
	push	0
	push	dword [ebp + .input_buffer]
	call	[strtoul]
	add		esp, 4*3
	
	pop		ebp 
	ret 

; get_Line(input_buffer, bytes_read, max_to_read)
get_line:
	.input_buffer = 8h
	.bytes_read = 0ch 
	.max_to_read = 10h 
	
	push	ebp 
	mov		ebp, esp 
	
	push	ecx 
	push	esi
	
	push	0 
	push	dword [ebp + .bytes_read] 
	push	dword [ebp + .max_to_read]
	push	dword [ebp + .input_buffer]
	push	dword [input_handle]
	call	[ReadFile]
	
	mov		ecx, dword [ebp + .bytes_read]
	mov		esi, dword [ebp + .input_buffer]
	add		esi, dword [ecx]
	mov		byte [esi], 0
		
.end_func:
	pop		esi
	pop		ecx 

	pop		ebp 
	ret 
	
section '.idata' data import readable

library	kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import 	kernel32,\
		GetStdHandle,'GetStdHandle',\
		ReadFile,'ReadFile',\
		ExitProcess,'ExitProcess'
			
import	msvcrt,\
		printf,'printf',\
		strtoul,'strtoul'