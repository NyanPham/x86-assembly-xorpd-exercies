; 1.  Bit counting:
    
; Write a program that takes a number (of size 4 bytes) x as input, and then
; counts the amount of "1" bits in even locations inside the number x. We
; assume that the rightmost bit has location 0, and the leftmost bit has a
; location of 31.

; Example:
; if x == {111011011}_2, then we only count the bits with stars under them.
		   ; * * * * *
		   ; 8 6 4 2 0 
; Hence we get the result of 4.


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	bits_total		db	'Bits count in even locations is: %d',13,10,0
	
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
		
	push 	enter_number 
	call	get_num
	add		esp, 4 
		
	mov		dword [number], eax
	
	push	dword [number]
	call	count_bit_even_pos
	add		esp, 4
		
	push	eax 
	push	bits_total
	call	[printf]
	add		esp, 4*2
	
	push	0
	call	[ExitProcess]
	
; count_bit_even_pos(num)	
count_bit_even_pos:
	.num = 8h
	
	push	ebp 
	mov		ebp, esp
		
	push	ebx 
	push	ecx 
	push	edx
	
	mov		eax, dword [ebp + .num]
	mov		ecx, 10h
	xor 	ebx, ebx 
	xor 	edx, edx 

.count_bit_loop:
	mov		edx, eax 
	and 	edx, 1h
	test 	edx, edx 
	jz		.not_one 
		
	inc 	ebx 
	
.not_one:
	shr		eax, 2
	
	dec		ecx
	cmp		ecx, 0
	jge 	.count_bit_loop
	
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