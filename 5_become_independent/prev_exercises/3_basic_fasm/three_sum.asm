; 0.  Write a program the receives three numbers and sums those three numbers.
; Then output the result.
		
format PE console
entry start
	
include 'win32a.inc'

BUFFER_MAX = 20h
NUMS_LEN = 3h
	
section '.data' data readable writeable
	enter_number			db	'Please enter number %d: ',0
	sum_value				db 	'The sum is: %d',13,10,0
		
section '.bss' readable writeable	
	numbers					dd	NUMS_LEN 	dup (?) 
	input_handle 			dd 	?
	bytes_read 				dd 	?
	input_buffer 			dd	BUFFER_MAX 	dup (?) 

section '.text' code readable executable
	
start:
	push	STD_INPUT_HANDLE 
	call	[GetStdHandle]
	mov		[input_handle], eax 
	
	push	NUMS_LEN
	push	numbers
	call	get_number_inputs
	add		esp, 4*2
		
	push	NUMS_LEN
	push	numbers 
	call	sum_numbers 
	add		esp, 4 

	push	eax 
	push	sum_value
	call	[printf] 
	add		esp, 4*2
	
	push	0
	call	[ExitProcess] 

	
; sum_numbers(nums_addr, nums_len)
sum_numbers:
	.nums_addr = 8h
	.nums_len = 0ch
	
	push	ebp 
	mov		ebp, esp
	
	push	esi
	push	ecx 
	push	ebx 
	push	edx
		
	mov 	esi, dword [ebp + .nums_addr]
	mov		ebx, dword [ebp + .nums_len] 
	test	ebx, ebx 
	jz 		.end_func
			
	xor 	ecx, ecx 
	xor 	eax, eax  
.print_num_loop:
	mov		edx, dword [esi + ecx*4]
	add		eax, edx 
			
	inc		ecx 
	cmp		ecx, ebx 
	jb 		.print_num_loop
	
.end_func:
	pop		edx
	pop		ebx 
	pop		ecx 
	pop		esi
		
	pop		ebp 
	ret 
	
; get_number_inputs(nums_addr, nums_len)
get_number_inputs: 	
	.nums_addr = 8h
	.nums_len = 0ch
			
	push	ebp
	mov		ebp, esp
	
	push	edi 
	push	eax 
	push	ecx 
	push	edx 
	push	ebx 
		
	mov 	edi, dword [ebp + .nums_addr]
	mov		ebx, dword [ebp + .nums_len]
	test 	ebx, ebx 
	jz 		.end_func
		
	xor 	ecx, ecx 
.get_num_loop:
	push	ecx 
	
	inc 	ecx 
	push	ecx 
	push	enter_number
	call	[printf]
	add		esp, 4*2
	
	; Get number from console 
	push	0
	push 	bytes_read 
	push	BUFFER_MAX
	push	input_buffer
	push	dword [input_handle]
	call	[ReadFile] 		
		
	mov		edx, input_buffer 
	add		edx,  dword [bytes_read]
	mov		byte [edx], 0
			
	push	input_buffer
	call	str_to_num
	add 	esp, 4 	
			
	pop		ecx 		
	mov		dword [edi + ecx*4], eax
		
	inc 	ecx 	
	cmp		ecx, ebx
	jb		.get_num_loop
		
.end_func:	
	pop		ebx 
	pop		edx 
	pop		ecx 
	pop 	eax 
	pop		edi
	
	pop		ebp
	ret 
	
	

; str_to_num(str_addr)
str_to_num:
	.str_addr = 8h
	
	push	ebp
	mov		ebp, esp 
	
	push	esi
	mov		esi, dword [ebp + .str_addr]
	
	push 	10
	push	0
	push	esi 
	call	[strtoul]
	add		esp,4*3
			
.end_func:
	pop		esi
	pop		ebp 
	ret 
	
section '.idata' data import readable 

library	kernel32, 'kernel32.dll',\
		msvcrt,'msvcrt.dll' 
	
import 	kernel32,\
		GetStdHandle,'GetStdHandle',\
		ReadFile,'ReadFile',\
		WriteFile,'WriteFile',\
		ExitProcess,'ExitProcess'
	
import 	msvcrt,\
		strtoul,'strtoul',\
		printf,'printf'