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

STR_MAX_LEN		=	40h
MAX_LOCATIONS 	=	10h
	
section '.data' data readable writeable 
	enter_s1				db		'Please enter the string:',13,10,0
	enter_s2				db  	'Please enter the substring:',13,10,0
	result_str 				db		'Substring was found at locations:',13,10,0
	no_result_str			db		'No substring found in',0
	invalid_input			db		'Either S1 or S2 is empty!',0
		
section '.bss' readable writeable 
	s1 						db 		STR_MAX_LEN 	dup 	(?)
	s1_len					dd 		? 
	s2 						db 		STR_MAX_LEN 	dup 	(?)
	s2_len					dd		? 
	rs_locations			dd		MAX_LOCATIONS	dup		(?)
	rs_idx					dd		? 
	has_substring 			db		0 
		
section '.text' code readable executable	
	
start:

	;==============================================
	; Get the input for both string and substring
	;==============================================
get_string_1:
	mov		esi, enter_s1
	call	print_str 
	
	mov		edi, s1 
	mov		ecx, STR_MAX_LEN
	call	read_line 
	
.find_str_len_1:
	mov		esi, s1
	mov		ecx, STR_MAX_LEN
	xor 	al, al 
	repnz	scasb 
	
	neg 	ecx 
	add		ecx, STR_MAX_LEN
	dec		ecx 
	mov		dword [s1_len], ecx 
		
get_string_2:
	mov		esi, enter_s2 
	call	print_str 
	
	mov		edi, s2 
	mov		ecx, STR_MAX_LEN
	call	read_line 
	
.find_str_len_2:
	mov		esi, s2 
	mov		ecx, STR_MAX_LEN
	xor 	al, al 
	repnz 	scasb 
		
	neg 	ecx
	add		ecx, STR_MAX_LEN
	dec		ecx 
	mov		dword [s2_len], ecx 	
		
	;==============================================
	; Check any length if 0. If 0, don't process
	; searching for substring
	;==============================================
	cmp		dword [s1_len], 0 
	jz 		print_invalid 
	cmp		dword [s2_len], 0
	jz		print_invalid 
			
	mov		dword [rs_idx], 0d 

	;==============================================
	; ebx = current string1 index 
	; ecx = current string2 index
	; edx = string1 index for inner iteration
	;==============================================
search_substring:
	xor		ebx, ebx 
	xor		ecx, ecx 
	xor		edx, edx 
	
	mov		esi, s1 
	mov		edi, s2 
	
check_next_char:
	mov		al, byte [esi + ebx] 
	cmp		al, byte [edi + ecx] 
	jnz 	not_match 
	
	mov		edx, ebx 
inner_loop:
	inc 	edx
	cmp 	edx, dword [s1_len]
	jz		done 
	inc 	ecx
	cmp		ecx, dword [s2_len]
	jz		found_one 
	
	mov		al, byte [esi + edx]
	cmp		al, byte [edi + ecx]
	jnz		not_match
	jmp		inner_loop
	
found_one:
	mov		eax, dword [rs_idx] 
	mov		dword [rs_locations + eax * 4], ebx  
	inc		dword [rs_idx]
	mov		byte [has_substring], 1h
		
not_match:
	xor		ecx, ecx 
	inc		ebx 
	cmp		ebx, dword [s1_len]
	jnz 	check_next_char 
	
done:
	cmp		byte [has_substring], 0  
	jnz 	print_substring_locations
	
	mov		esi, no_result_str
	call	print_str 
	jmp 	search_substring_end
	
print_substring_locations:
	mov		esi, result_str
	call	print_str 
	
	xor 	ecx, ecx 
	mov		esi, rs_locations
print_rs:
	mov		eax, dword [rs_locations + ecx * 4] 
	call	print_eax 
	inc		ecx 
	cmp		ecx, dword [rs_idx] 
	jnz 	print_rs
	
	jmp 	search_substring_end
	
print_invalid:
	mov		esi, invalid_input
	call	print_str 
	
search_substring_end:
	
	push	0
	call	[ExitProcess]
	
include 'training.inc'
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	