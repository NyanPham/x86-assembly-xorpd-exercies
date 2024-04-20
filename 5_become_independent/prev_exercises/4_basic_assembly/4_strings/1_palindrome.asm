; 1.  Palindrome

    ; A palindrome is a sequence of symbols which is interpreted the same if read in
    ; the usual order, or in reverse order.
    
    ; Examples:

      ; 1234k4321   is a palindrome.
      ; 5665        is a palindrome.
	
      ; za1221at    is not a palindrome.


    ; Write a program that takes a string as input, and decides whether it is a
    ; palindrome or not. It then prints an appropriate message to the user.


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
	result_is_palindrome	db	'%s is a palindrome.',13,10,0
	result_not_palindrome	db	'"%s" is not a palindrome.',13,10,0
	
section '.bss' readable writeable
	input_handle	dd	? 
	input_str		STRING 	?
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_string
	call	[printf]
	add		esp, 4
	
	push	INPUT_BUFFER_MAX_LEN
	push	input_str.length
	push	input_str.string
	call	get_line 
	add		esp, 4*3
	
	push	input_str
	call	check_str_palindrome
	add		esp, 4
		
	test	eax, eax 
	jz		.print_not 
	
	push	input_str.string
	push	result_is_palindrome
	call	[printf]
	add		esp, 4*2 
	jmp		.end_check
.print_not:
	push	input_str.string
	push	result_not_palindrome
	call	[printf]
	add		esp, 4*2 
.end_check:
		
	push	0
	call	[ExitProcess]

; check_str_palindrome(struct_string_addr)
check_str_palindrome:
	.struct_string_addr = 8h 
	
	push	ebp
	mov		ebp, esp
	
	push	esi
	push	ecx 
	push	ebx
	
	mov		eax, dword [ebp + .struct_string_addr]
	
	lea		esi, dword [eax + STRING.string]
	mov		ecx, dword [eax + STRING.length]
	
	mov		byte [esi + ecx - 2], 0
	
	;========================================================
	; ebx = start pointer in string
	; ecx = end pointer in string
	;========================================================
	sub		ecx, 3			; subtract 2 chars: 0 and \n, 
							; subtract another 1 for last index in string
	
	xor		ebx, ebx 
	
.check_loop:
	mov		al, byte [esi + ebx]
	cmp		al, byte [esi + ecx]
	jnz		.not_palindrome
	
	inc		ebx 
	dec		ecx
	
	cmp		ebx, ecx
	jge		.is_palindrome
	jmp 	.check_loop
	
.is_palindrome:
	mov		eax, 1
	jmp		.end_func

.not_palindrome:
	mov		eax, 0
	
.end_func:
	pop		ebx
	pop		ecx 
	pop		esi

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