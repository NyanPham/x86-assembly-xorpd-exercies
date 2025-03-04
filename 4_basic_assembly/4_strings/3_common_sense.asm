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

MAX_USER_LEN = 0x40

section '.data' data readable writeable
    empty_str				db		'Oops! You entered an empty string!',0xd,0xa,0
	enter_text				db		'Enter text: ',0xd,0xa,0
	
	output1_txt				db		'The character ',0
	output2_txt				db		' is the most common character on the string.',0xd,0xa,0
	output3_txt				db		'Amount of occurrences: ',0
	
section '.bss' readable writeable
    user_text			db		MAX_USER_LEN 	dup 	(?)
	user_text_len		dd		?
	char_count_tbl		dd		0xff			dup		(0)
	common_char			db		0x2				dup		(0)
	
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

	; Count chars into table
	xor		eax, eax
	mov		esi, user_text
	mov		edi, char_count_tbl
count_char:
	lodsb	
	test	al, al
	jz		.terminated
	cmp		al, 0x20
	jz		.skip_count
	inc		dword [edi + 4*eax]
.skip_count:
	jmp		count_char

.terminated:
	; Find char with most count
	xor		ebx, ebx			; index			
	xor		edx, edx			; largest count
	mov		esi, char_count_tbl
	xor		ecx, ecx
check_next:	
	mov		eax, dword [esi + 4*ecx]
	cmp		eax, edx
	jle		.not_larger
	mov		ebx, ecx
	mov		edx, eax
	
.not_larger:
	inc		ecx 
	cmp		ecx, 0xff
	jnz		check_next
		
	mov		edi, common_char
	mov		byte [edi], bl
	mov		byte [edi + 1], 0x0
	
	mov		esi, output1_txt
	call	print_str
	mov		esi, common_char
	call	print_str
	mov		esi, output2_txt
	call	print_str
	mov		esi, output3_txt
	call	print_str
	mov		eax, edx
	call	print_eax
	
	jmp 	end_prog
invalid_input:
	mov		esi, empty_str
	call	print_str
	
end_prog:
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
