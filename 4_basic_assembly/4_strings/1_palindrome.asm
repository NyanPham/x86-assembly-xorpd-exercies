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

MAX_USER_LEN = 0x40

section '.data' data readable writeable
    empty_str				db		'Oops! You entered an empty string!',0xd,0xa,0
	
	enter_text				db		'Enter text: ',0xd,0xa,0
	is_palindrome_text		db		' is a palindrome.',0xd,0xa,0
	not_palindrome_text		db		' is not a palindrome.',0xd,0xa,0
	
section '.bss' readable writeable
    user_text		db		MAX_USER_LEN 	dup 	(?)
	user_text_len	dd		?
	
section '.text' code readable executable

start:
    mov		esi, enter_text
	call	print_str
	
	mov		ecx, MAX_USER_LEN
	mov		edi, user_text
	call	read_line
		
	; Find user text length
	mov		ecx, MAX_USER_LEN
	mov		esi, user_text
	xor		al, al
	repnz	scasb
		
	neg		ecx
	add		ecx, MAX_USER_LEN
	dec		ecx 
	mov		dword [user_text_len], ecx
	
	test	ecx, ecx
	jz		invalid_input
	
	; Compare using 2 pointers
	mov		esi, user_text		; user_text[0]
	mov		edi, esi
	add		edi, dword [user_text_len]
	dec		edi					; user_text[len-1]
compare_char:
	cmp		esi, edi
	jae		.is_palindrome
	
	mov		al, byte [esi]
	cmp		al, byte [edi]
	jnz		.is_not_palindrome
	
	inc		esi 
	dec		edi
	jmp		compare_char
	
.is_palindrome:
	mov		esi, user_text
	call	print_str
	
	mov		esi, is_palindrome_text
	call	print_str
	jmp		end_prog
	
.is_not_palindrome:
	mov		esi, user_text
	call	print_str

	mov		esi, not_palindrome_text
	call	print_str
	jmp		end_prog

invalid_input:
	mov		esi, empty_str
	call	print_str
	
end_prog:
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
