; 4.  Rotation using shifts.

; Implement the ror instruction using the shift instructions. You may use any
; bitwise instruction for this task, except for the rotation instructions
; (ror,rol).


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	enter_count 	db	'Please enter rotate right count: ',0
	ror_is			db	'Right-rotated %d times of %d is: %d',13,10,0
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	number 			dd	?
	ror_times		dd	?
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_number 
	call	get_num 
	add		esp, 4 
	
	mov		dword [number], eax 
	
	push	enter_count
	call	get_num
	add		esp, 4
		
	mov		dword [ror_times], eax 	
		
	push	dword [ror_times] 
	push	dword [number]
	call	self_ror
	add		esp, 4*2
		
	push	eax 
	push	dword [number]
	push	dword [ror_times]
	push	ror_is
	call	[printf]
	add		esp, 4*4
			
	push	0
	call	[ExitProcess]

; self_ror(num, count)
self_ror:
	.num = 8h
	.count = 0ch
	
	push	ebp
	mov		ebp, esp
	
	push	ebx 
	push	ecx 
	
	mov		ecx, dword [ebp + .count]
	jecxz 	.end_func 
		
	mov		eax, dword [ebp + .num]
	mov		ebx, 80000000h
	
.shift_loop:
	shr		eax, 1
	jnc		.not_carry
		
	or		eax, ebx
	
.not_carry:
	dec		ecx 
	jnz		.shift_loop
	
.end_func:
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