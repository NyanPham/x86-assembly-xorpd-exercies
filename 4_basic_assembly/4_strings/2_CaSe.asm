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

MAX_USER_LEN = 0x40

section '.data' data readable writeable
    empty_str				db		'Oops! You entered an empty string!',0xd,0xa,0
	enter_text				db		'Enter text: ',0xd,0xa,0
	
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

	; Flip case of characters
	mov		esi, user_text
flip_case:
	lodsb
	test	al, al
	jz		terminated
	
	lea		edi, [esi - 1]
	
	cmp		al, 0x41
	jb		.skip
	cmp		al, 0x7a
	ja		.skip
	
	cmp		al, 0x5a
	jbe		.is_upper
	cmp		al, 0x61
	jae		.is_lower
	jmp		.skip
	
.is_upper:
	add		al, 0x20
	mov		byte [edi], al
	
	jmp		.skip
.is_lower:
	sub		al, 0x20
	mov		byte [edi], al
	
.skip:
	jmp		flip_case
	
terminated:
	mov		esi, user_text
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
