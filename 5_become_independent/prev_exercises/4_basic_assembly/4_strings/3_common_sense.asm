; 3.  Common sense
	
    ; Write a program that reads a string from the user, and then finds out the
    ; most common character in the string. (Don't count spaces).
    
    ; Finally the program prints that character back to the user, together with
    ; its number of occurrences in the string.
		
    ; Example:

      ; Input:  The summer is the place where all things find their winter

      ; Output: The character e is the most common character on the string.
              ; Amount of occurrences: 8
	


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h
CHARS_MAX_LEN = 34h

section '.data' data readable writeable 
	enter_str		db	'Input: ',0
	result_is		db	"The character %c is the most common character on the string",13,10
					db	"Amount of occurrences: %d",13,10,0

section '.bss' readable writeable
	input_buffer 	db	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
			
	chars_count 	db	CHARS_MAX_LEN	dup (0)
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_str
	call	[printf]
	add		esp, 4
	
	push	INPUT_BUFFER_MAX_LEN
	push	bytes_read 
	push	input_buffer
	call	get_line 
	add		esp, 4*3
	
	push	dword [bytes_read] 
	push	chars_count
	push	input_buffer
	call	count_chars
	add		esp, 4*3 
	
	push	CHARS_MAX_LEN
	push	chars_count
	call	find_most_common_char
	add		esp, 4*2
		
	push	ebx 
	push	eax
	push	result_is 
	call	[printf]
	add		esp, 4*3
		
	push	0
	call	[ExitProcess]
		
;find_most_common_char(chars_count_addr, len)
find_most_common_char:
	.chars_count_addr = 8h
	.len = 0ch
	
	push 	ebp
	mov		ebp, esp
	
	push	esi
	push	edi
	push	ecx 
		
	.max_index = 4h
	.max_value = 8h
	
	sub		esp, 8h
		
	mov		esi, dword [ebp + .chars_count_addr]
	mov		ecx, dword [ebp + .len]
	jecxz 	.end_func
	
	xor		ebx, ebx
	mov		dword [ebp - .max_value], -1
	mov		dword [ebp - .max_index], 0
	
.find_loop:
	lodsb	
	movzx	eax, al
	
	cmp		eax, dword [ebp - .max_value]
	jge		.update_max
	jmp		.next_iter 
	
.update_max:
	mov		dword [ebp - .max_value], eax 
	mov		dword [ebp - .max_index], ebx
	
.next_iter:
	inc		ebx
	dec		ecx 
	jnz		.find_loop
	
	mov		ebx, dword [ebp - .max_value]
	
	mov		eax, dword [ebp - .max_index]
	cmp		eax, 19h
	jg		.is_lower_char
.is_upper_char:
	mov		eax, dword [ebp - .max_index]
	add		eax, 41h
	
	
	jmp		.end_func

.is_lower_char:
	mov		eax, dword [ebp - .max_index]
	add		eax, 47h
.end_func:
	add		esp, 8h
	
	pop		ecx 
	pop		edi
	pop		esi 
	
	pop		ebp
	ret 

; is_lower_alphabetic(char)
is_lower_alphabetic:
	.char = 8h
	
	push	ebp
	mov		ebp, esp
		
	mov		al, byte [ebp + .char]
	cmp		al, 61h
	jl		.not_alpha
	cmp		al, 7ah 
	jg		.not_alpha
	
	mov		eax, 1
	jmp		.end_func
		
.not_alpha:
	mov		eax, 0
	
.end_func:
	pop 	ebp
	ret 
	
; is_upper_alphabetic(char)
is_upper_alphabetic:
	.char = 8h
	
	push	ebp
	mov		ebp, esp
	
	mov		al, byte [ebp + .char]
	cmp		al, 41h
	jl		.not_alpha
	cmp		al, 5ah
	jg		.not_alpha
	
	mov		eax, 1
	jmp 	.end_func	
	
.not_alpha:
	mov		eax, 0
	
.end_func:
	pop 	ebp
	ret 
	
; print_counts(chars_count_addr, len)
print_counts:
	.chars_count_addr = 8h
	.len = 0ch
	
	push 	ebp
	mov		ebp, esp
	
	pusha 
	
	mov		esi, dword [ebp + .chars_count_addr]
	mov		ecx, dword [ebp + .len]
	jecxz	.end_func
	
.print_loop:
	lodsb	
	movzx	eax, al 
	
	pusha 
	push	eax
	push	input_value
	call	[printf]
	add		esp, 4*2
	popa 
	
.next_iter:
	dec		ecx 
	jnz		.print_loop 
	
.end_func:
	popa 
	
	pop		ebp 
	ret 
	

; count_chars(input_buffer, chars_count_addr, buffer_length)
count_chars:
	.input_buffer = 8h
	.chars_count_addr = 0ch
	.buffer_length = 10h
	
	push	ebp
	mov		ebp, esp
		
	pusha 
	
	mov		esi, dword [ebp + .input_buffer]
	mov		ebx, dword [ebp + .chars_count_addr]
	mov		ecx, dword [ebp + .buffer_length]
	jecxz 	.end_func
	
.count_loop:
	lodsb	
	
	movzx	edx, al
	
	push	edx
	call	is_lower_alphabetic
	add		esp, 4 
	
	test	eax, eax 
	jz		.check_upper_alphabetic
	sub		edx, 47h
	jmp		.inc_count
	
.check_upper_alphabetic:
	push	edx 
	call	is_upper_alphabetic
	add		esp, 4
		
	test	eax, eax 
	jz		.continue_iter
	sub		edx, 41h
	
.inc_count:
	lea		eax, dword [ebx + edx]
	inc		byte [eax]
		
.continue_iter:
	dec		ecx 
	jnz		.count_loop

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