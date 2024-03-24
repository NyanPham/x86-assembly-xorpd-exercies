; 2. Write a program that takes the number n as input, and prints back all the
; triples (a,b,c), such that a^2 + b^2 = c^2. 

; These are all the pythagorean triples not larger than n.

format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	results_are		db 	'Pythagorean triples are: ',13,10,0
	triples			db	'(%d, %d, %d)',13,10,0
	linebreak		db	13,10,0
	
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
	add 	esp, 4
	
	mov		dword [number], eax 
	
	push	linebreak
	call	[printf]
	add		esp, 4
	
	push	dword [number]
	call	search_pythagorean_triples
	
	push	0
	call	[ExitProcess]
	

; search_pythagorean_triples(num)
search_pythagorean_triples:
	.num = 8h
	.a = 4h
	.b = 8h 
	.c = 0ch
	
	push	ebp 
	mov		ebp, esp 

	pusha 
	
	push	results_are
	call	[printf]
	add		esp, 4
		
	mov		edi, dword [ebp + .num]
		
	mov		dword [ebp - .c], 0
	mov		dword [ebp - .b], 0
	mov		dword [ebp - .a], 0 
	
.loop_c:
	mov		dword [ebp - .b], 0
.loop_b:
	
	mov		dword [ebp - .a], 0 
.loop_a:
	mov		eax, dword [ebp - .c]
	mul 	eax
	mov		ecx, eax 
	
	mov		eax, dword [ebp - .b]
	mul		eax 
	mov		ebx, eax 
	
	mov		eax, dword [ebp - .a]
	mul		eax 
	
	add		eax, ebx
	cmp		eax, ecx 
	jne 	.next_iter
	
	push	dword [ebp - .c]
	push	dword [ebp - .b]
	push	dword [ebp - .a]
	push	triples
	call	[printf]
	add		esp, 4*4 
	
.next_iter:	
	inc 	dword [ebp - .a]
	mov		eax, dword [ebp - .a]
	cmp		eax, edi
	jbe		.loop_a
		
	inc 	dword [ebp - .b]
	mov		eax, dword [ebp - .b]
	cmp		eax, edi
	jbe		.loop_b 
			
	inc 	dword [ebp - .c]
	mov		eax, dword [ebp - .c]
	cmp		eax, edi
	jbe 	.loop_c

.end_func:	
	popa
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