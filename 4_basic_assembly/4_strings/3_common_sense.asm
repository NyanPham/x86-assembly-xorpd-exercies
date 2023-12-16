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

MAX_USER_STR	=	80h

section '.data' data readable writeable
	enter_str		db		'Please enter string: ',13,10,0
	found_char 		db		'The character x is the most common character on the string.',13,10,0
	amount_occur	db 		'Amount of occurrences: ',0
	space			db 		' ',0	
		
section '.bss' readable	writeable
	user_str		db 		MAX_USER_STR 	dup 	(?)
	user_str_len	dd		? 
	has_swap		db 		? 
	
	common_char 	db		?
	common_count	dd		0
			
section '.text' code readable executable
	
start:
	mov		esi, enter_str
	call	print_str 
		
	mov		edi, user_str 
	mov		ecx, MAX_USER_STR
	call	read_line
		
	mov		esi , user_str
	mov		ecx, MAX_USER_STR
	xor		al, al
	repnz	scasb 
			
	neg		ecx 
	add		ecx, MAX_USER_STR
	dec		ecx 	
	mov		dword [user_str_len], ecx 
	
	
	;=========================================
	; We will sort the string to have the 
	; chars in order
	;=========================================	
sort_chars:
	mov		esi, user_str
	mov		ecx, dword [user_str_len]
	dec 	ecx 
	mov		byte [has_swap], 0 
	xor		ebx, ebx 
		
next_char:
	xor		eax, eax 
	xor		edx, edx 
	
	mov		al, byte [esi + ebx]
	mov		dl, byte [esi + ebx + 1]
	cmp		al, dl 
		
	jbe		no_swap
	
swap:	
	mov		byte [esi + ebx], dl
	mov		byte [esi + ebx + 1], al
	mov		byte [has_swap], 1h	
	
no_swap:		
	inc		ebx
	dec		ecx 
	jnz		next_char 
	
	cmp		byte [has_swap], 0d
	jnz 	sort_chars
	
sort_chars_done:
	
	;=========================================
	; Iterate through each char 
	; compare it with the previous char
	; if the same char code, increment its count 
	; else, check if its count is the max 
	; and update common_char, common_count 
	; before iterate next char 
	;=========================================	

	mov		esi, user_str
	xor		ebx, ebx 
	mov		ecx, dword [user_str_len]
	dec		ecx 
	xor		edx, edx
	xor		eax, eax 
	mov		ah, byte [esi] 
	
count_next:	 
	mov		al, byte [esi + ebx]
	cmp		al, byte [space]
	je 		countdown 		
	
	inc		edx
	cmp		al, ah
	jne 	iterate_next_char
	jmp		countdown
	
iterate_next_char:
	cmp		edx, dword [common_count] 
	jle		update_prev_char 
	
	mov		byte [common_char], ah 
	mov		dword [common_count], edx 
	
update_prev_char:
	mov		ah, al 
	xor		edx, edx
	
countdown:
	inc		ebx
	dec		ecx 
	jnz		count_next 
			
check_done:
	mov		al, byte [common_char]
	mov 	esi, found_char
	mov		byte [esi + 14], al 	
	call	print_str 
	
	;==========================================
	; Convert count in hex to ASCII 
	;==========================================
	mov		esi, amount_occur
	call	print_str 
	
	mov		eax, dword [common_count]
	call	print_eax 
		
	push	0
	call	[ExitProcess]
	
include 'training.inc'
	
	
	
	
	
	
	
	
	
	
	
	