; 2.  Write a program that receives a number x as input, and outputs to the
    ; console the following values: x+1, x^2 , x^3, one after another.
	
format PE console 
entry start
	
include 'win32a.inc'
	
BUFFER_MAX_LEN = 20h
		
section '.data' data readable writeable
	enter_num		db	'Please enter number x: ',0
	add_one 		db	'x+1 = %d',13,10,0
	expo_two 		db	'x^2 = %d',13,10,0
	expo_three 		db	'x^3 = %d',13,10,0
			
section '.bss' 	readable writeable 
	input_buffer		dd		BUFFER_MAX_LEN	dup (?)
	input_handle 		dd		?
	bytes_read 			dd		?
	number 				dd		? 
				
section '.text' code readable executable 

start:
	push	STD_INPUT_HANDLE	
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_num
	call	[printf]
	add		esp, 4
	
	; Get string input from console 
	push	BUFFER_MAX_LEN
	push	bytes_read 
	push	input_buffer 
	call	read_input
	add		esp, 4*2
					
	; Convert the string to number 	
	push	input_buffer
	call	str_to_dec
	add		esp, 4
	
	mov		dword [number], eax 
	inc		eax 
	
	push	eax 
	push	add_one
	call	[printf]
	add		esp, 4*2
		
	push	2 
	push	dword [number]
	call	expo
	add		esp, 4*2
	
	push	eax 
	push	expo_two
	call	[printf]
	add		esp, 4*2
	
	push	3
	push	dword [number]
	call	expo
	add		esp, 4*2
		
	push	eax 
	push	expo_three
	call	[printf]
	add		esp, 4*2
	
	push	0
	call	[ExitProcess]

; expo(number, exponention) 
expo:
	.number = 8h
	.exponention = 0ch
	
	push	ebp 
	mov		ebp, esp 
	
	push	ebx 
	push	ecx 
		
	mov		eax, 1
	mov		ebx, dword [ebp + .number]
	mov		ecx, dword [ebp + .exponention]
	
	test	ecx, ecx 
	jz		.zero_expo
	
	cmp		ecx, 1 
	jz		.one_expo
	
.mul_loop:
	mul		ebx 
	dec 	ecx
	jnz		.mul_loop
		
	jmp		.end_func

.one_expo:
	mov		eax, ebx 
	jmp		.end_func

.zero_expo:
	mov		eax, 1 
	
.end_func:
	pop		ecx 
	pop		ebx 
	pop		ebp 
	ret 

; read_input(input_buffer, bytes_read, max_bytes_read)
read_input:
	.input_buffer = 8h
	.bytes_read = 0ch 
	.max_bytes_read = 10h 
	
	push	ebp 
	mov		ebp, esp 
	
	push	ecx 
	push	esi
	push	edi
		
	mov		ecx, dword [ebp + .max_bytes_read]
			
	push	0
	push	dword [ebp + .bytes_read]	
	push	ecx
	push	dword [ebp + .input_buffer]
	push	dword [input_handle]
	call	[ReadFile]	
		
	mov		ecx, dword [ebp + .bytes_read]	
	mov		esi, dword [ebp + .input_buffer]
	add		esi, dword [ecx]	
	mov		byte [esi], 0
	
	pop		edi
	pop		esi
	pop		ecx 
	pop		ebp 
	ret 

; str_to_dec(input_addr) 
str_to_dec:
	.input_addr = 8h
	
	push	ebp
	mov		ebp, esp
	
	push	10
	push	0
	push	dword [ebp + .input_addr]
	call	[strtoul]
	add		esp, 4*3
		
	pop		ebp
	ret

section '.idata' data import readable 	

library	kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import 	kernel32,\
		GetStdHandle,'GetStdHandle',\
		ReadFile,'ReadFile',\
		ExitProcess,'ExitProcess'
		
import	msvcrt,\
		printf,'printf',\
		strtoul,'strtoul'