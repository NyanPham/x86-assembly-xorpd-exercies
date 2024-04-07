; 7.  Bonus: Convert Gray into binary.
    
    ; In the "Gray" Exercise at the code reading section, we have learned that in
    ; order to find the Gray code of a number x, we should shift the number x by
    ; 1, and xor the result with the original x value.

    ; In high level pseudo code: 
      ; (x >> 1) XOR x.

    ; In assembly code:
      ; mov   ecx,eax
      ; shr   ecx,1
      ; xor   eax,ecx


    ; Find a way to reconstruct x from the expression (x >> 1) XOR x.
    ; Write a program that takes a gray code g as input, and returns the
    ; corresponding x such that g = (x >> 1) XOR x.

    ; NOTE that You may need to use a loop in your program.


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	hex_rep_is		db	'Hex representation of %d is: %x',13,10,0
	gray_rep_is		db	'Graycode representation in hex of %d is: %x',13,10,0
	
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
	
	push 	enter_number
	call	get_num
	add		esp, 4
	
	mov		dword [number], eax 
	
	push	dword [number]
	push	dword [number]
	push	hex_rep_is
	call	[printf]
	add		esp, 4*3
		
	push	dword [number]
	call	graycode_to_bin
	add		esp, 4
	
	push	eax 
	push	dword [number]
	push	gray_rep_is
	call	[printf]
	add		esp, 4*3
	
	push	0
	call	[ExitProcess]

;graycode_to_bin(num)
graycode_to_bin:
	.num = 8h
	
	push	ebp
	mov		ebp, esp
			
	push	ebx
	push	ecx 
	push	esi
	
	mov		eax, dword [ebp + .num]			; graycode to convert
	
	xor		ebx, ebx						; current binary 
	xor		esi, esi 						; previous binary
	mov		ecx, 32d 	
	
.convert_loop:
	mov		esi, ebx 
	and		esi, 1h
	shl		ebx, 1 
	clc
		
	shl 	eax, 1 
	jnc		.not_carry
	inc		ebx
.not_carry:
	xor		ebx, esi
	
	dec		ecx 
	jne		.convert_loop
	
	mov		eax, ebx
		
.end_func:
	pop		esi
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