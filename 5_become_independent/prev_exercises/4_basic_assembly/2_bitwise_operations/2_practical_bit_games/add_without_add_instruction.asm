; 8.  Bonus: Addition using bitwise operations.

    ; 8.0   You are given two bits a,b. Show that their arithmetic sum is of the
          ; form (a AND b, a XOR b).
		
          ; Example:
	
          ; 1 + 0 = 01
          ; And indeed: 0 = 1 AND 0, 1 = 1 XOR 0.

	
    ; 8.1   Write a program that gets as inputs two numbers x,y (Each of size 4
          ; bytes), and calculates their arithmetic sum x+y using only bitwise
          ; instructions. (ADD is not allowed!).

          ; HINT: Try to divide the addition into 32 iterations.
                ; In each iteration separate the immediate result and the carry
                ; bits that are produced from the addition.


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_num			db	'Please enter a number: ',0
	enter_other_num 	db	'Please enter another number: ',0
	sum_is				db	'%d + %d = %d',13,10,0
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	number_one 		dd	?
	number_two 		dd 	?
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_num
	call	get_num
	add		esp, 4
	
	mov		dword [number_one], eax 
	
	push	enter_other_num
	call	get_num
	add		esp, 4
	
	mov		dword [number_two], eax 
	
	push	dword [number_two]
	push	dword [number_one]
	call	add_without_add_instruction
	add		esp, 4*2
	
	push	eax 
	push	dword [number_two]
	push	dword [number_one]
	push	sum_is
	call	[printf]
	add		esp, 4*4
	
	push	0
	call	[ExitProcess]

; add_without_add_instruction(num_one, num_two)
add_without_add_instruction:
	.num_one = 8h
	.num_two = 0ch
		
	push	ebp
	mov		ebp, esp
	
	push	ebx
	push	ecx 
	push	edx 
	push	edi
	push	esi
	
	xor		eax, eax 
	mov		ecx, 32d 
	
	mov		esi, dword [ebp + .num_one]
	mov		edi, dword [ebp + .num_two]
	
.next_bit_loop:
	mov		edx, esi
	xor		esi, edi
	and		edi, edx 
	shl		edi, 1
	
	dec		ecx 
	jnz 	.next_bit_loop
	
	mov		eax, esi
	
.end_func:
	pop		esi 
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