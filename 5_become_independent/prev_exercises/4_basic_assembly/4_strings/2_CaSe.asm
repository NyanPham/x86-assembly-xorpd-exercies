; 2.  CaSe
    
    ; Write a program that asks the user for a string. It then flips every letter
    ; from lower case to UPPER case and vice versa, and prints back the result to the
    ; user.

    ; Example:
      ; Input:  Hello
      ; Output: hELLO

    ; You may assume that the input is only made of letters. (No spaces or
    ; other punctuation marks).
	


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

struct STRING
	string 	db	INPUT_BUFFER_MAX_LEN dup (?)
	length	dd	? 
ends 
	
section '.data' data readable writeable 
	enter_string			db	'Please enter a string: ',0
	line_brk				db	'',13,10,0
	flipped_string_is		db	'Flipped case string: %s',13,10,0
	
section '.bss' readable writeable
	input_handle	dd	? 
	input_str		STRING 	?
	
	flipped_case_str	db	INPUT_BUFFER_MAX_LEN 	dup 	(?)
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	line_brk
	call	[printf]
	add		esp, 4
	
	push	enter_string
	call	[printf]
	add		esp, 4
	
	push	INPUT_BUFFER_MAX_LEN
	push	input_str.length
	push	input_str.string
	call	get_line 
	add		esp, 4*3
	
	mov		eax, dword [input_str.length]
	mov		esi, input_str.string
	mov		byte [esi + eax - 2], 0
	
	push	dword [input_str.length]
	push	flipped_case_str
	push	input_str.string
	call	flip_cases
	add		esp, 4*3 
	
	push	line_brk
	call	[printf]
	add		esp, 4
	
	push	flipped_case_str
	push	flipped_string_is
	call	[printf]
	add		esp, 4*2
	
	push	0
	call	[ExitProcess]

; flip_cases(string_in_addr, string_out_addr, string_len)
flip_cases:
	.string_in_addr = 8h
	.string_out_addr = 0ch
	.string_len = 10h 
	
	push	ebp 
	mov		ebp, esp 
	
	pusha 
	
	mov		esi, dword [ebp + .string_in_addr]
	mov		edi, dword [ebp + .string_out_addr]
	mov		ecx, dword [ebp + .string_len]

.flip_loop:
	lodsb 	
	
	; Check if the loaded byte is a character a-z or A-Z
	cmp		al, 41h
	jl		.copy_char 
	cmp		al, 5ah 
	jg		.check_lowercase 
		
	add		al, 20h
	jmp 	.copy_char
	
.check_lowercase:
	cmp		al, 61h 
	jl		.copy_char 
	cmp		al, 7ah 
	jg		.copy_char
	
	sub		al, 20h

.copy_char: 	
	stosb 	
	dec		ecx 
	jnz		.flip_loop
	
.end_func:
	popa 
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
	
section '.idata' data import readable 

library kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import	kernel32,\
		ReadFile,'ReadFile',\
		GetStdHandle,'GetStdHandle',\
		ExitProcess,'ExitProcess'
		
import	msvcrt,\
		printf,'printf'