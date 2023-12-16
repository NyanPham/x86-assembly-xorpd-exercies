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

USER_MAX_STR = 40h
	
section '.data' data readable writeable
	enter_text			db		'Please enter a string: ',13,10,0 
	flipped_version		db 		'The flipped output is: ', 13,10,0
	
section '.bss' readable writeable
	user_str			db 		USER_MAX_STR 	dup 	(?) 
	user_str_len		dd		?
	user_str_case 		db		USER_MAX_STR	dup 	(?)
		
section '.text' code readable executable

start:
	mov		esi, enter_text 
	call	print_str 
	
	mov		edi, user_str 
	mov		ecx, USER_MAX_STR
	call	read_line 
	
	mov		esi, user_str
	mov		ecx, USER_MAX_STR
	xor		al, al 
	repnz	scasb 
	
	neg 	ecx 
	add		ecx, USER_MAX_STR 
	dec		ecx 
	mov		dword [user_str_len], ecx 
	
	mov		esi, user_str 
	mov		edi, user_str_case	
	mov		ecx, dword [user_str_len]

	xor 	eax, eax 
case_next:
	lodsb 	
	
	;============================================
	; Check the upper bound of chars
	; the char in hex must be in range between
	; 41 and 7a
	;============================================
	cmp		al, 41h 
	jb		cpy_char
	cmp		al, 7ah 
	ja		cpy_char
			
	;============================================
	; The middle part between the range also has
	; special chars. So we check:
	; char > 41 and char < 5a -> uppercase
	; char > 61 and char < 7a -> lowercase
	;============================================
	cmp		al, 5ah 
	jl		is_upper_case
	cmp		al, 61h 
	ja 		is_lower_case 
	jmp		cpy_char 
	
is_upper_case:
	add		al, 20h 				; uppercase char + 20h = lowercase
	jmp		cpy_char 
	
is_lower_case:
	sub		al, 20h 				; lowercase char - 20h = uppercase
			
cpy_char:
	stosb 
	dec		ecx 
	jnz		case_next
			
	mov		esi, user_str_case
	call	print_str 
	
	
	push	0
	call	[ExitProcess]

include 'training.inc'
	