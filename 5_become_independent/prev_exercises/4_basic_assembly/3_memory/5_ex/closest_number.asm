; 0.  Find closest number.
    
    ; Add the following into the data section:

    ; nums  dd  23h,75h,111h,0abch,443h,1000h,5h,2213h,433a34h,0deadbeafh

    ; This is an array of numbers. 
    
    ; Write a program that receives a number x as input, and finds the dword
    ; inside the array nums, which is the closest to x. (We define the distance
    ; between two numbers to be the absolute value of the difference: |a-b|).

    ; Example:

    ; For the input of 100h, the result will be 111h, because 111h is closer to
    ; 100h than any other number in the nums array. (|100h - 111h| = 11h).


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number		db	'Please enter a number: ',0
	closest_num_is		db	'Closest number is: %d',13,10,0
	
    nums            	dd  23h,75h,111h,0abch,443h,1000h,5h,2213h,433a34h,0deadbeafh
	NUMS_LEN 	=   ($ - nums) / 4 
	
section '.bss' readable writeable
	input_buffer 		dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read			dd 	?
	input_handle		dd	? 
       
	number 		    	dd	?
    closest_index       dd  ? 

section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
    
	push    enter_number
    call    get_num
    add     esp, 4
	
	mov		dword [number], eax
			
	push	dword [number]
	push	NUMS_LEN
	push	nums
	call	find_closest_num 
	add		esp, 4*2
	
	mov		ebx, dword [nums + 4*eax]
	push	ebx 
	push	closest_num_is 
	call	[printf]
	add		esp, 4*2
	
	push	0
	call	[ExitProcess]
	
;find_closest_num(nums_addr, nums_len, num)
; Input: 	address of nums array
; 			length of the array
;			number to check closest
; Ouput:	Index of the closest number
; 
find_closest_num:
	.nums_addr = 8h
	.nums_len = 0ch
	.num = 10h
		
	.local_smallest_distance = 4h
	.local_smallest_index = 8h
	
	push	ebp
	mov		ebp, esp
	
	sub		esp, 4*2
	
	push	ebx
	push	ecx 
	push	edx 
	push	edi
	push	esi
	
	mov		ecx, dword [ebp + .nums_len]
	jecxz 	.end_func
	
	xor		ebx, ebx
	mov		esi, dword [ebp + .nums_addr]
	mov		edx, dword [ebp + .num]
	
	mov		dword [ebp - .local_smallest_distance], 0
	mov		dword [ebp - .local_smallest_index], -1
	
.compare_loop:
	mov		eax, dword [esi + 4*ebx]
	sub		eax, edx
	
	push	eax 
	call	abs_num
	add		esp, 4 
	
	cmp		dword [ebp - .local_smallest_index], 0
	jl		.update_distance
	
	cmp		eax, dword [ebp - .local_smallest_distance]
	ja		.not_closest

.update_distance:
	mov		dword [ebp - .local_smallest_distance], eax 
	mov		dword [ebp - .local_smallest_index], ebx 
	
.not_closest:
	inc		ebx 
	dec		ecx 
	jnz		.compare_loop
	
	mov		eax, dword [ebp - .local_smallest_index] 

.end_func:	
		
	add		esp, 4*2

	pop		esi
	pop		edi
	pop		edx 
	pop		ecx 
	pop		ebx 
	
	pop		ebp
	ret 
	
; abs_num(num)
; Input: number 
; Ouput: unsigned number
abs_num:
	.num = 8h 
	
	push	ebp
	mov		ebp, esp 
		
	mov		eax, dword [ebp + .num]
	cmp		eax, 0
	jge		.not_neg 
	
	neg		eax 
.not_neg:
	
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