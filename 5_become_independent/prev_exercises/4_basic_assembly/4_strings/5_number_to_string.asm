; 5.  Number to String
	
    ; We are going to write a program that converts a number into its base 10
    ; representation, as a string.
	
    ; The program will read a number as input (Using the read_hex helper
    ; subroutine). It will then print back the number, in base 10.
		
    ; Example:
      
      ; Input:  1f23
      ; output: 7971 (Decimal representation).

    ; HINTS:
      ; - Recall that the input number could be imagined to be in the form:
        ; input = (10^0)*a_0 + (10^1)*a_1 + ... + (10^t)*a_t

      ; - Use repeated division method to calculate the decimal digits
        ; a_0,a_1,...,a_t.

      ; - Find out how to translate each decimal digit into the corresponding
        ; ASCII symbol. (Recall the codes for the digits '0'-'9').

      ; - Build a string and print it. Remember the null terminator!

	; Notes:
	;	Window API already supports convert number (hex, dec) to string
	; 	I will get the string from ReadFile, convert to hex by stroul
	; 	And then, manually, convert each number to char.
	
format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	input_value		db	'Test value: %d',13,10,0
	result_is		db	'The string from num is: %s',13,10,0
	num_too_big		db	'Number is too big to process',13,10,0
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	number 			dd	?	
	number_string	db	INPUT_BUFFER_MAX_LEN 	dup (?)
	
	
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
	push	INPUT_BUFFER_MAX_LEN
	push	number_string
	call	number_to_string
	add		esp, 4*3
	
	push	number_string
	push	result_is
	call	[printf]
	add		esp, 4*2
		
	push	0
	call	[ExitProcess]
	

; number_to_string(num_str_addr, max_str_len, number)
number_to_string:
	.num_str_addr = 8h
	.max_str_len = 0ch
	.number = 10h
	
	push	ebp
	mov		ebp, esp
	
	pusha 

	mov		edi, dword [ebp + .num_str_addr]
	mov		eax, dword [ebp + .number]
	mov		ecx, dword [ebp + .max_str_len]

	xor		ebx, ebx
	mov		esi, 10d 
.convert_loop:
	; Divide number by 10
	; Remainder is the digit
	xor		edx, edx
	div		esi
	
	; Translate the digit to ASCII
	; by adding 30h to number
	add		edx, 30h

		
	; Store it in the end of the string array
	mov		byte [edi + ebx], dl 
		
	inc		ebx 
	
	test	eax, eax 
	jnz		.convert_loop
	
.end_loop:
	; terminate the string
	mov		byte [edi + ebx], 0
	
	; move each end element to the beginning	
	xor		ecx, ecx
	dec		ebx
.reverse_loop:
	mov		al, byte [edi + ecx]
	mov		dl, byte [edi + ebx]
	mov		byte [edi + ebx], al
	mov		byte [edi + ecx], dl
	
	inc		ecx 
	dec		ebx 
	cmp		ebx, ecx 
	jle		.reverse_loop
	jmp		.end_func
	
.overflow_error:
	push	num_too_big
	call	[printf]
	add		esp, 4 
	
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
	call	str_to_hex
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

; str_to_hex(str_addr)
str_to_hex:
	.str_addr = 8h
	
	push	ebp
	mov		ebp, esp
		
	push	16d 
	push	0
	push	dword [ebp + .str_addr]
	call	[strtoul]
	add		esp, 4*3 
	
.end_func:
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