; 0.1   Write a program that takes three numbers x,y,z as input, and returns:
; - 0 if (x+y+z) is even.
; - 1 if (x+y+z) is odd.

; (Note that here + means arithmetic addition).
; Do it without actually adding the numbers.
; HINT: Use the XOR instruction.

format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

NUMS_LEN = 3h
section '.data' data readable writeable 
	enter_number	db		'Please enter a number: ',0
	sum_is_odd		db		'(%d + %d + %d) is odd: %d',13,10,0
	nums			dd 		NUMS_LEN 	dup (?)
		
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
	
	push	NUMS_LEN
	push	nums
	call	get_nums
	add		esp, 4*2
	
	push	NUMS_LEN
	push	nums 
	call	nums_odd_or_even
	add		esp, 4*2
		
	push	eax
	push	dword [nums + 4*2]
	push	dword [nums + 4]
	push	dword [nums ]
	push	sum_is_odd
	call	[printf]
	add		esp, 4*2
			
	push	0
	call	[ExitProcess]

; nums_odd_or_even(num_addr, nums_len)
nums_odd_or_even:
	.nums_addr = 8h
	.nums_len = 0ch 	
	
	push	ebp
	mov		ebp, esp 
	
	push	esi
	push	ebx
	push	ecx 

	mov		ecx, dword [ebp + .nums_len]
	cmp		ecx, 2h
	jb 		.end_func
		
	mov		esi, dword [ebp + .nums_addr]
	xor 	ebx, ebx
	
	mov		eax, dword [esi + ebx * 4]
		
.xor_loop:
	inc		ebx
	xor 	eax, dword [esi + ebx * 4]
	dec		ecx 
	jnz 	.xor_loop 
	
	shr 	eax, 1 
	jc 		.is_odd
	
.is_even:
	mov		eax, 0
	jmp		.end_func 

.is_odd:
	mov		eax, 1
	
.end_func:
	pop		ecx 
	pop		ebx
	pop		esi
	
	pop		ebp 
	ret 

; get_nums(nums_addr, nums_len)
get_nums:
	.nums_addr = 8h
	.nums_len = 0ch 	
	
	push	ebp
	mov		ebp, esp 
	
	pusha
	
	mov		ecx, dword [ebp + .nums_len]
	test	ecx, ecx 
	jz 		.end_func
	
	mov		edi, dword [ebp + .nums_addr]
	xor 	ebx, ebx
	
.get_num_loop:
	push	ecx 
	push	ebx 

	push	enter_number
	call	get_num
	add		esp, 4
		
	pop		ebx
	pop		ecx 
		
	mov		dword [edi + ebx * 4], eax 
	
	inc		ebx
	dec		ecx 
	jnz 	.get_num_loop

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