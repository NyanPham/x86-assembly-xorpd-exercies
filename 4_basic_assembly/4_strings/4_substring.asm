; 4.  Substring

    ; Write a program that asks the user for two strings: s1,s2. 
    
    ; The program then searches for all the occurrences of s2 inside s1, and prints
    ; back to the user the locations of all the found occurrences.
	
    ; Example:
      
      ; Input:  s1 = 'the colors of my seas are always with me.'
              ; s2 = 'th'

      ; Search: s1 = 'the colors of my seas are always with me.'
                    ; th                                 th
                    ; 00000000000000001111111111111111222222222
                    ; 0123456789abcdef0123456789abcdef012345678

      ; Output: Substring was found at locations:
              ; 0
              ; 23
  
format PE console
entry start

include 'win32a.inc' 

MAX_USER_LEN = 0x40

section '.data' data readable writeable
    empty_str				db		'Oops! You entered an empty string!',0xd,0xa,0
	enter_text				db		'Enter text: ',0xd,0xa,0
	enter_substr			db		'Enter text to search: ',0xd,0xa,0
	found_locations			db		'Substring was found at locations: ',0xd,0xa,0
	no_locations			db		'Substring was not found',0xd,0xa,0
	newline					db		0xd,0xa,0
	
section '.bss' readable writeable
    user_text			db		MAX_USER_LEN 	dup 	(?)
	user_text_len		dd		?
	substr_text			db		MAX_USER_LEN	dup		(?)
	substr_text_len		dd		?
	
	locations			dd		MAX_USER_LEN	dup		(?)
	
	is_tracking			db		0
	lock_idx			dd		0
	locations_count		dd		0
	
section '.text' code readable executable

start:
	;=============================
	; Enter input text
	;=============================
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
	
	;=============================
	; Enter substring
	;=============================
	mov		esi, enter_substr
	call	print_str
	
	mov		ecx, MAX_USER_LEN
	mov		edi, substr_text
	call	read_line
		
	; Find user text length
	mov		ecx, MAX_USER_LEN
	mov		esi, substr_text
	xor		al, al
	repnz	scasb
		
	neg		ecx
	add		ecx, MAX_USER_LEN
	dec		ecx 
	mov		dword [substr_text_len], ecx
	
	test	ecx, ecx
	jz		invalid_input
	
	;=========================================
	; Search for indices of substring in text
	;=========================================
search_substr_in_text:
	xor		eax, eax				; just for clearing
	mov		esi, user_text
	mov		edi, substr_text
	xor		ecx, ecx				; text idx
	xor		ebx, ebx				; substr idx
.next_char:
	mov		al, byte [esi + ecx]
	test	al, al
	jz		.terminated
	cmp		al, byte [edi + ebx]
	jnz		.reset_tracking
	cmp		byte [is_tracking], 0
	jnz		.continue_tracking
	
	mov		byte [is_tracking], 1
	mov		dword [lock_idx], ecx
	
.continue_tracking:
	inc		ebx				
	cmp		byte [edi + ebx], 0			; Are we the end of the substring
	jnz		.skip_append_location		
	mov		eax, dword [lock_idx]		; Yes, then add lock_idx into location
	mov		edx, dword [locations_count]
	mov		dword [locations + 4*edx], eax
	inc		edx
	mov		dword [locations_count], edx
	xor		ebx, ebx
	mov		byte [is_tracking], 0
.skip_append_location:	
	inc		ecx
	jmp		.next_char
	
.reset_tracking:
	cmp		byte [is_tracking], 0
	jz		.skip_reset_txt_index
	mov		byte [is_tracking], 0	; Turn off the flag
	mov		ecx, dword [lock_idx]	; Restore the index in text
	dec		ecx
.skip_reset_txt_index:
	inc		ecx 
	xor		ebx, ebx				; Restore the index in substr
	jmp		.next_char
	
.terminated:	
	mov		ecx, dword [locations_count]
	test	ecx, ecx
	jz		.print_no_results
	
	mov		esi, found_locations
	call	print_str
	
	mov		esi, locations
.print_next_location:
	mov		eax, dword [esi]
	call	print_eax
	add		esi, 4
	dec		ecx
	jnz		.print_next_location
	jmp		end_prog

.print_no_results:
	mov		esi, no_locations
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
