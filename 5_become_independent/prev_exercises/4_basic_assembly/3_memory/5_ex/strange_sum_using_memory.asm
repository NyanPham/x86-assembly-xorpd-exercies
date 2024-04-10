; 1.  Strange sum.

    ; Write a program that gets a number n as input, and then receives a list of n
    ; numbers: a_1, a_2, ..., a_n.

    ; The program then outputs the value n*a_1 + (n-1)*a_2 + ... + 1*a_n.
    ; Here * means multiplication.

    ; Example:

    ; Assume that the input received was n=3, together with the following list of
    ; numbers:  3,5,2.
    ; Hence the result will be 3*3 + 2*5 + 1*2 = 9 + 10 + 2 = 21 = 0x15

    
    ; Question for thought: Could you write this program without using memory?
	
format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

NUMS_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	enter_item_num	db	'Enter a number in array: ',0
	sum_is			db	'Result: %d',13,10,0
		
	nums 			dd	NUMS_MAX_LEN dup (?)
				
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	nums_len		dd	? 
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_number
	call	get_num 
	add		esp, 4
	
	mov		dword [nums_len], eax
	
	push	dword [nums_len]
	push	nums 
	call	populate_nums
	add		esp, 4*2
	
	push	dword [nums_len]
	push	nums 
	call	strange_sum
	add		esp, 4*2
	
	push	eax 
	push	sum_is
	call	[printf]
	add		esp, 4*2 
	
	push	0
	call	[ExitProcess]


; strange_sum(nums_addr, nums_len)
strange_sum:
	.nums_addr = 8h
	.nums_len = 0ch
	
	push	ebp
	mov		ebp, esp
	
	push	ebx 
	push	ecx 
	push	edx 
	push	esi
	push	edi
	
	mov		ecx, dword [ebp + .nums_len]
	jecxz	.end_func
		
	mov		esi, dword [ebp + .nums_addr]
	xor		ebx, ebx
	xor		edx, edx 
	xor		edi, edi
	
.get_loop:
	mov		eax, dword [esi + 4*ebx] 
	xor		edx, edx 
	mul		ecx 
	add		edi, eax
	
	inc		ebx 
	dec		ecx 	
	jnz		.get_loop
	
	mov		eax, edi 
	
.end_func:
	pop		edi
	pop		esi 
	pop		edx 
	pop		ecx 
	pop		ebx
	
	pop		ebp 
	ret 

; populate_nums(nums_addr, nums_len)
populate_nums:
	.nums_addr = 8h
	.nums_len = 0ch
	
	push	ebp
	mov		ebp, esp
	
	pusha
	
	mov		ecx, dword [ebp + .nums_len]
	jecxz	.end_func
		
	mov		esi, dword [ebp + .nums_addr]
	xor		ebx, ebx
.get_loop:
	push	ecx 
	
	push	enter_item_num
	call	get_num
	add		esp, 4
	mov		dword [esi + 4*ebx], eax
	
	pop		ecx  
	
	inc		ebx 
	dec		ecx 	
	jnz		.get_loop
	
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