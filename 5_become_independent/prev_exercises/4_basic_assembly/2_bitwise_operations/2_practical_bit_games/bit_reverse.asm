; 2.  Bit reverse:

; Write a program that takes a number (of size 4 bytes) x as input, and then
; reverses all the bits of x, and outputs the result. By reversing all bits we
; mean that the bit with original location i will move to location 31-i.

; Small example (for the 8 bit case):

  ; if x == {01001111}_2, then the output is {11110010}_2.

  ; In this example we reversed only 8 bits. Your program will be able to
  ; reverse 32 bits.

format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	reverse_is		db	'The bit-reversed of number %d is: %d',13,10,0
		
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	number 				dd	?
	
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
	call	reverse_bits
	add		esp, 4
		
	push	eax
	push	dword [number]
	push	reverse_is
	call	[printf]
	add		esp, 4*3
				
	push	0
	call	[ExitProcess]

; reverse_bits(num)
reverse_bits:
	.num = 8h	
			
	push	ebp
	mov		ebp, esp
		
	push	ebx
	push	ecx 
	push	edx 
		
	mov		ebx, dword [ebp + .num]

	mov		ecx, 31d 
	xor		edx, edx 
	
.shift_and_inc_loop:
	shr 	ebx, 1
	jnc		.not_one 
		
	inc		edx 
.not_one:
	shl 	edx, 1	
	dec		ecx 
	jnz		.shift_and_inc_loop
	
	mov		eax, edx
	
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