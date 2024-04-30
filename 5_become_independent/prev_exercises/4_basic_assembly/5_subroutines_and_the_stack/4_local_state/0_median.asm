; 0.  Median

    ; Given an array of numbers, The median is defined to be the middle number in
    ; the sorted array. (If there are two middle numbers, we pick one of them).
	
    ; Examples:

      ; For the array: {4,8,1,9,23h,41h,15h,13h,44h} the median is 13h. (Sort the
      ; array and find the middle number, for example).

      ; For the array: {4,9,1,5}, then median could be chosen to be both 4 or 5.

    ; NOTE that the median is not the same as the mean of the array.


    ; 0.  Write a function that gets an address of an array of dwords, and the
        ; length of the array. The function will then return the median of the 
        ; array.
	
    ; 1.  Test your function with a few different arrays, and verify the results.

    ; 2.  Bonus: What is the running time complexity of the function you wrote?
        ; Could you find a faster way to find the median of an array?


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h
MAX_NUMS_LEN = 40h

section '.data' data readable writeable 
	enter_num_total		db	'List number total is: ',13,10,0
	enter_number		db	'Please enter a number: ',0
	medians_are			db	'The list has 2 medians: %d and %d',13,10,0
	median_is			db	'The list has 1 median: %d',13,10,0
	linebreak			db	13,10,0	
	
section '.bss' readable writeable
	input_buffer 		dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read			dd 	?
	input_handle		dd	? 
		
	nums				dd	MAX_NUMS_LEN 	dup	(?)
	nums_len			dd	?
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_num_total
	call	get_num
	add		esp, 4
	
	mov		dword [nums_len], eax 
	
	push	dword [nums_len] 
	push	nums 
	call	populate_nums
	add		esp, 4*2
	
	push	linebreak
	call	[printf]
	add		esp, 4
	
	push	dword [nums_len]
	push	nums
	call	find_medium_in_nums
	add		esp, 4*2
	
	cmp		eax, edx 
	jnz		.print_both_medium
		
	push	eax 
	push	median_is
	call	[printf]
	add		esp, 4*2
	
	jmp		.end_print

.print_both_medium:
	push	edx 
	push	eax 
	push	medians_are
	call	[printf]
	add		esp, 4*3

.end_print:

	push	0
	call	[ExitProcess]

; populate_nums(nums_addr, nums_len)
populate_nums:
	.nums_addr = 8h
	.nums_len = 0ch 
	
	push	ebp 
	mov		ebp, esp
	pusha 	
		
	mov		esi, dword [ebp + .nums_addr]
	mov		ecx, dword [ebp + .nums_len]
	jecxz	.end_func 
	
	xor		ebx, ebx 
.populate_loop:
	push	ecx 
	push	ebx 
	push	enter_number
	call	get_num 
	add		esp, 4
	pop		ebx 
	pop		ecx 
	
	mov		dword [esi + ebx*4], eax 
	 
	inc		ebx 
	dec		ecx 
	jnz		.populate_loop
		
.end_func:
	popa 

	pop		ebp 
	ret 

; find_medium_in_nums(nums_addr, nums_len)
find_medium_in_nums:
	.nums_addr = 8h
	.nums_len = 0ch 
	
	push	ebp
	mov		ebp, esp
	
	push	esi
	push	ebx
	push	ecx 
	
	mov		esi, dword [ebp + .nums_addr]
	mov		eax, dword [ebp + .nums_len]
	
	push	eax
	push	esi
	call	sort_nums
	add		esp, 4*2

	mov		eax, dword [ebp + .nums_len]	
	
	xor		edx, edx 
	mov		ebx, 2 
	div		ebx 
	test	edx, edx 
	jz		.is_even_len 
	
.is_odd_len:
	mov		eax, dword [esi + eax*4]
	mov		edx, eax

	jmp		.end_func
	
.is_even_len:
	mov		ecx, eax 
	mov		edx, dword [esi + ecx*4]
	dec		ecx 
	mov		eax, dword [esi + ecx*4]

.end_func:
	pop		ecx 
	pop		ebx 
	pop		esi 
	
	pop		ebp 
	ret 

	
; sort_nums(nums_addr, nums_len)
sort_nums:
	.nums_addr = 8h
	.nums_len = 0ch 
	
	push	ebp
	mov		ebp, esp
		
	pusha 
	
	mov		esi, dword [ebp + .nums_addr]
	mov		edi, dword [ebp + .nums_len]
	xor		ebx, ebx
	
.sort_loop_outer:
	.has_swap = -4h;
	sub		esp, 4		; local variable to hold the boolean if swap occurs in one sort iteration.
	
	xor		ebx, ebx
	mov		ecx, edi 
	dec		ecx
	mov		dword [ebp + .has_swap], 0
	
.sort_loop:
	mov		edx, ebx
	inc		edx
	
	mov		eax, dword [esi + ebx*4]
	cmp		eax, dword [esi + edx*4] 
	jle		.skip_swap
	
.swap:
	mov		dword [ebp + .has_swap], 1
	
	push	dword [esi + edx*4] 
	mov		dword [esi + edx*4], eax 
	pop		eax 
	mov		dword [esi + ebx*4], eax 
		
.skip_swap:	
	inc		ebx 
	dec		ecx 
	jnz		.sort_loop
	
	mov		eax, dword [ebp + .has_swap]
	add		esp, 4 
	
	cmp		eax, 0
	jz		.end_func
	
	dec		edi
	cmp		edi, 1
	jg		.sort_loop_outer
		
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
	
	pusha
	
	mov		ecx, dword [ebp + .bytes_read]
	mov		esi, dword [ebp + .input_buffer]
	
	push	0
	push	ecx 
	push	dword [ebp + .bytes_to_read]
	push	esi 
	push	dword [input_handle]
	call	[ReadFile]
	
	mov		ebx, dword [ebp + .bytes_read]
	
	mov		eax, dword [ebx]
	mov		byte [esi + eax], 0
	dec		eax 
	mov		byte [esi + eax], 0
	dec		eax
	mov		byte [esi + eax], 0
	inc 	eax 

	mov		dword [ebx], eax 

.end_func:
	popa 
	
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