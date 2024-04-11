; 3.  Common number.

; Create a program that takes a number n as input, followed by a list of n
; numbers b_1, b_2, ... b_n. You may assume that 0x0 <= b_i <= 0xff for every
; 1 <= i <= n.

; The program will output the most common number.

; Example:

; Assume that the input was n=7, followed by the list: 1,5,1,3,5,5,2.
; The program will output 5, because this is the most common number.

; Note that if there is more than one most common number, the program will
; just print one of the most common numbers.

format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

NUMS_MAX_LEN = 0ffh

section '.data' data readable writeable 
	enter_number	db	'Please numbers total: ',0
	enter_byte		db	'Enter a number (0 < x < 255): ',0
	most_common_is	db	'Most common number is: %d',13,10,0
	
	nums			db	NUMS_MAX_LEN dup (?)
	num_freqs		db	NUMS_MAX_LEN dup (?)
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	nums_len		dd 	?
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_number
	call	get_num
	mov		dword [nums_len], eax 

	push	dword [nums_len]
	push	nums 
	call	populate_nums
	add		esp, 4*2
	
	push	dword [nums_len]
	push	num_freqs
	push	nums 
	call	count_freqs
	add		esp, 4*3
	
	push	dword [nums_len]
	push	num_freqs
	call	get_common_num
	add		esp, 4*2
	
	push	eax 
	push	most_common_is
	call	[printf]
	add		esp, 4*2
		
	push	0
	call	[ExitProcess]
	
;get_common_num(nums_freqs_addr, nums_len)
get_common_num:
	.num_freqs = 8h
	.nums_len = 0ch
	
	push	ebp 
	mov		ebp, esp
	
	.most_freq = 4h
	.most_common = 8h
	sub		esp, 4*2
	
	push	ebx 
	push 	ecx 
		
	mov		dword [ebp - .most_freq], 0
	mov		dword [ebp - .most_common], -1
		
	mov		edi, dword [ebp + .num_freqs]
	mov		ecx, dword [ebp + .nums_len]
	xor		ebx, ebx
	
.find_loop:
	movzx	eax, byte [edi + ebx]
	cmp		dword [ebp - .most_common], 0
	jl		.update_common
	
	cmp		eax, dword [ebp - .most_freq]
	jbe		.check_next
	
.update_common:
	mov		dword [ebp - .most_freq], eax
	mov		dword [ebp - .most_common], ebx
	
.check_next:
	inc		ebx 
	dec		ecx 
	jnz		.find_loop
	
	mov		eax, dword [ebp - .most_common]
	
.end_func:	
	pop		ecx 
	pop		ebx 
	
	add		esp, 4*2
	
	pop		ebp 
	ret 

; count_freqs(nums_addr, nums_freq_addr, nums_len)
count_freqs:
	.nums_addr = 8h
	.num_freqs = 0ch
	.nums_len = 10h
	
	push	ebp 
	mov		ebp, esp
	pusha 
	
	mov		esi, dword [ebp + .nums_addr]
	mov		edi, dword [ebp + .num_freqs]
	mov		ecx, dword [ebp + .nums_len]
	
	xor 	ebx, ebx 
	jecxz 	.end_func
	
.count_loop:
	movzx	eax, byte [esi + ebx]
	inc 	byte [edi + eax]
	
	inc 	ebx 
	dec		ecx 
	jnz		.count_loop

.end_func:
	popa 
	pop		ebp 
	ret 	

; populate_nums(nums_addr, nums_len)
populate_nums:
	.nums_addr = 8h
	.nums_len = 0ch
	
	push	ebp 
	mov		ebp, esp
	
	pusha 
	
	mov		esi, dword [ebp + .nums_addr]
	mov		ecx, dword [ebp + .nums_len]
	
	xor 	ebx, ebx 
	jecxz 	.end_func
	
.get_num_loop:
	pusha 
	push	enter_byte
	call	get_num
	add		esp, 4
	
	mov		byte [esi + ebx], al 
	popa 	
	
	inc		ebx 
	dec		ecx
	jnz		.get_num_loop

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