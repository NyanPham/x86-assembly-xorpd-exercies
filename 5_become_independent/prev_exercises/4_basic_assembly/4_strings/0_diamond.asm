; 0.  Diamond

    ; Write a program that asks the user for a number n, and then prints a
    ; "diamond" of size n, made of ASCII stars.

    ; Example:
      ; For n = 1 the expected result is:
	
       ; *
      ; ***
       ; *

      ; For n = 2 the expected result is:

        ; *
       ; ***
      ; *****
       ; ***
        ; *

    ; HINT: You could use tri.asm exercise from the code reading section as a
    ; basis for your program.
	
	; Can refactor later after learning subroutines and stack
; Plan:
; 	Compute the width and height of the diamond: (n * 2) + 1
;   Loop from top to bottom to print star
;	If index == n, print full stars row
; 	else if index < n, increment stars and print row
; 	else, decrement stars and print row.

format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	star_str		db 	'*',0
	blank_str 		db	' ',0
	line_brk		db	'',13,10,0
	
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
	
	push	enter_number
	call	get_num
	add		esp, 4
	
	mov		dword [number], eax 
	
	push	line_brk
	call	[printf]
	add		esp, 4
	
	push	dword [number]
	call	print_diamond
	add		esp, 4
	
	
	
	push	0
	call	[ExitProcess]

; print_diamond(size)
print_diamond: 
	.size = 8h
	
	push	ebp 
	mov		ebp, esp 
	
	pusha 
	
	;==========================================================
	; Check size if it's valid
	;==========================================================
	mov		eax, dword [ebp + .size]
	cmp		eax, 0
	jle		.end_func
	
	;==========================================================
	; Compute the width the height of diamonds in stars 
	;==========================================================
	.height = 4h
	.row_stars_count = 8h
		
	sub		esp, 8h					; local variable to store the height/width
	shl		eax, 1h
	inc		eax 
	mov		dword [ebp - .height], eax

	;==========================================================
	; Loop through each row and print stars based on index 
	;==========================================================
	mov		ecx, dword [ebp - .height]
	mov		dword [ebp - .row_stars_count], 0
.next_row:
	mov		ebx, dword [ebp - .row_stars_count] 	; ebx = number of stars for row
	cmp		ecx, dword [ebp + .size]
	jg		.more_stars
	
	sub		ebx, 2
	jmp		.set_up_row
	
.more_stars:
	test 	ebx, ebx
	jz		.is_first_or_last_row
	add		ebx, 2
	jmp		.set_up_row
	
.is_first_or_last_row:
	mov		ebx, 1 
	
.set_up_row:
	mov		dword [ebp - .row_stars_count], ebx
	; compute index to start stars
	mov		edi, dword [ebp - .height]
	sub		edi, ebx 
	shr		edi, 1					; edi = index to start stars in row
	xor		edx, edx 				; edx = interate index in row
	
.print_row:
	cmp		edx, edi
	jge		.check_stars_left_in_row
	jmp		.print_blank
	
.check_stars_left_in_row:
	test	ebx, ebx
	jz		.print_blank
.print_star:
	pusha 
	push	star_str
	call	[printf]
	add		esp, 4 
	popa 

	dec		ebx
	jmp 	.next_star
.print_blank:
	pusha 
	push	blank_str 
	call	[printf]
	add		esp, 4 
	popa 
	
.next_star:	
	inc		edx 
	cmp		edx, dword [ebp - .height]
	jnz		.print_row
	
	pusha 
	push	line_brk
	call	[printf]
	add		esp, 4
	popa 
	
	dec		ecx 
	jnz		.next_row

	add 	esp, 4h
	
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