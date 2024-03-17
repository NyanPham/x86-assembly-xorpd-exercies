; 0.1 Write a program that takes the value m as input. It then receives m
  ; consecutive numbers from the user, sums all those numbers and prints back
  ; the total sum to the console.

format PE console 
entry start 

include 'win32a.inc'

INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable
	enter_number		db	'Please number count: ',0
	enter_number_nth 	db	'Please enter a number: ',0
	total_is			db 	'The total of %d number is: %d',13,10,0
	line_break			db	13,10,0
					
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	number_count 	dd	?
	num_sum			dd	?
		
section '.text' code readable executable 
		
start:
	push	STD_INPUT_HANDLE 
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_number
	call	get_num 
	add		esp, 4 
	mov		dword [number_count], eax 	
	
	push	line_break
	call	[printf]
	add		esp, 4 
				
	push	dword [number_count] 
	call	get_and_sum
	add		esp, 4
		
	mov		dword [num_sum], eax
		
	push	line_break
	call	[printf]
	add		esp, 4 
		
	push	dword [num_sum] 
	push	dword [number_count]
	push	total_is 
	call	[printf]
	add		esp, 4*2
	
	push	0
	call	[ExitProcess]

; get_and_sum(num_count)
get_and_sum:
	.num_count = 8h
	
	push	ebp
	mov		ebp, esp
	
	push	ecx 
	push	ebx 
		
	mov		ecx, dword [ebp + .num_count]
	xor		ebx, ebx
	
.get_add_loop:
	push	ecx 
	
	push	enter_number_nth
	call	get_num
	add		esp, 4 
	add		ebx, eax 
	
	pop		ecx 
	
	dec 	ecx 
	jne 	.get_add_loop
	
	mov		eax, ebx 
	
.end_func:	
	pop		ebx 
	pop		ecx 
	pop		ebp
	ret 

; get_num(promt_str_addr)
get_num:
	.promt_str_addr = 8h

	push	ebp 
	mov		ebp, esp 
			
	push	dword [ebp + .promt_str_addr]
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