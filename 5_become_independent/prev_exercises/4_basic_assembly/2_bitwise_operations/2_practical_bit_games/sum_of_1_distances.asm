; 3.  Sum of distances:
    
; For a binary number x, we define the "sum of 1 distances" to be the sum of
; distances between every two "1" bits in x's binary representation.

; Small example (8 bits):

  ; x = {10010100}_2
	   ; 7  4 2
  
  ; The total sum of distances: (7-4) + (7-2) + (4-2) = 3 + 5 + 2 = 10


; Create a program that takes a number x (of size 4 bytes) as input, and
; outputs x's "sum of 1 distances".


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

DWORD_LENGTH = 31d

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	index_value		db	'Value at index %d: %d',13,10,0
	distances_is	db	"Sum of bit 1s' distances is: %d",13,10,0
		
	bit_positions	dw 	DWORD_LENGTH dup (?)
	
section '.bss' readable writeable
	input_buffer 		dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read			dd 	?
	input_handle		dd	? 
		
	number 				dd	?
		
	bit_positions_len 	dw ? 
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_number
	call	get_num
	add		esp, 4
	
	mov		dword [number], eax 
	
	push	bit_positions_len
	push	bit_positions
	push	dword [number]
	call	get_bit_positions
	add		esp, 4*3
	
	push	dword [bit_positions_len]
	push	bit_positions
	call	compute_distances
	add		esp, 4*2
		
	push	eax 
	push	distances_is 
	call	[printf]
	add		esp, 4*2

	push	0
	call	[ExitProcess]


; compute_distances(array_addr, array_len)
compute_distances:
	.array_addr = 8h
	.array_len = 0ch 
	
	push	ebp 
	mov		ebp, esp 
	
	push	ebx
	push	ecx 
	push	edx 
	push	esi
	push	edi

	mov		edi, dword [ebp + .array_len]
	mov		esi, dword [ebp + .array_addr]
	xor		ecx, ecx			; outer loop iterator
	xor		edx, edx			; inner loop iterator
	
	xor		ebx, ebx 			; sum 
	
.outer_loop:
	mov		edx, ecx 
	inc		edx 
	cmp		edx, edi
	jae 	.done
	
.inner_loop:
	mov		eax, dword [esi + ecx * 4]
	sub		eax, dword [esi + edx * 4]
	add		ebx, eax 
	
	inc		edx 
	cmp		edx, edi
	jb		.inner_loop
			
	inc		ecx 
	cmp		ecx, edi
	jb		.outer_loop
		
.done:	
	mov		eax, ebx
	
.end_func:
	pop		edi
	pop		esi
	pop		edx 
	pop		ecx 
	pop		ebx
	
	pop		ebp
	ret 


; print_array(array_addr, array_len)
print_array:
	.array_addr = 8h
	.array_len = 0ch 
	
	push	ebp 
	mov		ebp, esp 
	
	pusha
	
	mov		ecx, dword [ebp + .array_len]
	mov		esi, dword [ebp + .array_addr]
	xor		ebx, ebx 
	
.print_loop:
	test 	ecx, ecx 
	jz		.end_func
	
	push	ecx 
	
	push	dword [esi + ebx * 4]
	push	ebx
	push	index_value
	call	[printf]
	add		esp, 4*3
	
	pop		ecx 
	inc		ebx 
	dec 	ecx 
	jmp		.print_loop
	
.end_func:
	popa 
	pop		ebp
	ret 
	

; get_bit_positions(num, bit_pos_addr, bit_pos_len_addr)
get_bit_positions:
	.num = 8h
	.bit_pos_addr = 0ch 
	.bit_pos_len_addr = 10h
		
	push	ebp 
	mov		ebp, esp 
	
	pusha
	
	mov		eax, dword [ebp + .num]
	mov		ecx, DWORD_LENGTH
	mov		edi, dword [ebp + .bit_pos_addr]
	mov		edx, dword [ebp + .bit_pos_len_addr]
			
	xor		ebx, ebx			; bit_pos_addr index
	
.get_bit_pos_loop:
	shl 	eax, 1
	jnc		.not_one
	
	mov		dword [edi + ebx * 4], ecx
	inc		ebx
	inc		dword [edx]
		
.not_one:
	dec		ecx 
	jne		.get_bit_pos_loop

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