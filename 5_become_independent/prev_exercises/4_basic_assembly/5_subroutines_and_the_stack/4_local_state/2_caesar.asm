; 2.  Caesar
    
    ; The ROT13 transformation changes a latin letter into another latin letter in
    ; the following method:

    ; We order all the latin letters 'a'-'z' on a circle. A letter is transformed
    ; into the letter which could be found 13 locations clockwise.

    ; Example:
      ; ROT13(a) = n
      ; ROT13(b) = o
      ; ROT13(p) = c
      ; ROT13(c) = p

    ; Note that the ROT13 transform is its own inverse. That means:
    ; ROT13(ROT13(x)) = x for every letter x.
    ; We will use this transform to encode and decode text made of latin letters.
	
    ; Example:
      ; 'Somebody set up us the bomb.' -> 'Fbzrobql frg hc hf gur obzo.'
      ; 'Fbzrobql frg hc hf gur obzo.' -> 'Somebody set up us the bomb.'
		
    ; 0.  Write a function that implements the ROT13 transform, and extends it a
        ; bit: The function takes a character as input. If the character is a
        ; latin letter, it is transformed. (13 places clockwise). If the character
        ; is not a latin letter, it is left unchanged.

        ; Capital latin letters will result in capital letters after the
        ; transform. Minuscule letters will result in minuscule letters.

        ; The function finally returns the transformed character.

    ; 1.  Write a function that transforms a string. The function takes a null
        ; terminated string as an argument, and transforms every letter in the
        ; string, using the previously written function.

    ; 2.  Write a program that takes a string from the user, and prints back to
        ; the user the transformed string.

    ; 3.  Tbbq wbo! Jryy qbar!


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 40h

section '.data' data readable writeable
	enter_string	db	'Please enter a string to encode: ',0
	encoded_string	db	'Encoded string: %s',13,10,0

section '.bss' readable writeable
	bytes_read		dd 	?
	input_handle	dd	? 
	
	string			dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_string
	call	[printf]
	add		esp, 4
	
	push	INPUT_BUFFER_MAX_LEN
	push	bytes_read
	push	string
	call	get_line
	add		esp, 4*3 
	
	push	string 
	call	rot13_string
	add		esp, 4 
	
	push	string
	push	encoded_string
	call	[printf]
	add		esp, 4*2
	
	push	0
	call	[ExitProcess]
	
rot13_string:
	.str_addr = 8h
	
	push	ebp 
	mov		ebp, esp
	
	pusha 
	
	mov		esi, dword [ebp + .str_addr]
	xor		ebx, ebx

.rot_loop:
	movzx	eax, byte [esi + ebx]
	cmp		eax, 0
	jz		.end_func
		
	push	eax 
	call	rot13_char
	add		esp, 4 
	
	mov		byte [esi + ebx], al
	inc		ebx 
	jmp		.rot_loop
		
.end_func:
	popa
	pop		ebp 
	ret 

; rot13_char(char)
rot13_char:
	.char = 8h
	
	push	ebp 
	mov		ebp, esp 
	
	xor		eax, eax 
	mov		al, byte [esp + .char]

	cmp		eax, 41h
	jl		.end_func
	cmp		eax, 5ah
	jg		.check_lower_case
	;		Is Uppercase
	add		eax, 0dh
	cmp		eax, 5ah
	jle		.end_func
	sub		eax, 5ah
	add		eax, 40h
	jmp		.end_func
	
.check_lower_case:
	cmp		eax, 61h
	jl		.end_func
	cmp		eax, 7ah
	jg		.end_func
	;		Is Lowercase
	add		eax, 0dh
	cmp		eax, 7ah
	jle		.end_func
	sub		eax, 7ah
	add		eax, 60h
	jmp		.end_func
	
.end_func:

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