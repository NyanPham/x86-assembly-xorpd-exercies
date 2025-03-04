format PE console
entry start

include 'win32a.inc'

MAX_STR_LEN = 0ffh
		
section '.data' data readable writeable 
	enter_str 		db	'Please enter a string: ',13,10,0
	result_str 	db 	'The transformed string is: ', 13,10,0
	
section '.bss' readable writeable 
	in_str 			db	  MAX_STR_LEN	dup		(?)
	out_str 		db	  MAX_STR_LEN 	dup 	(?)
	str_size		dd	  ?
		
section '.text' code readable executable
	
start:
	mov		esi, enter_str
	call	print_str 
	
	mov		edi, in_str
	mov		ecx, MAX_STR_LEN
	call	read_line
	
	mov		esi, in_str 
	mov		ecx, MAX_STR_LEN
	xor		al, al
	repnz	scasb 
	
	neg		ecx
	add		ecx, MAX_STR_LEN 
	dec		ecx 
	mov		dword [str_size], ecx
		
	mov		esi, in_str 
	mov		edi, out_str
	mov		ecx, dword [str_size]
	push	ecx 
	push	esi 
	push	edi
	call	transform_str 
	add		esp, 4 * 3
		
	call	print_delimiter	
		
	mov		esi, result_str
	call	print_str 
		
	mov		esi, out_str 
	call	print_str 
	
	push	0
	call	[ExitProcess]
	
;===========================================
; transform_str(dst_str_addr, src_str_addr, str_size)
; 
; Input: 
;	- Address of destination string
;   - Address of source string 
;   - Size of string to transform
;
; Output: void 
;	
; Operation: Iterate through each char and rotate them using 13, 
; 	storing the result in the destination string.
; 

transform_str:
	.dst_str_addr = 8h
	.src_str_addr = 0ch
	.str_size = 10h 
	push	ebp 
	mov		ebp, esp 
	
	push	esi
	push	edi
	push	ecx 
	push	eax 
	
	mov		esi, dword [ebp + .src_str_addr]
	mov		edi, dword [ebp + .dst_str_addr]
	mov		ecx, dword [ebp + .str_size]
	
	cmp		ecx, 1
	jbe		.transform_done
	
.transform_next:
	lodsb 	
	test 	al, al
	jz		.transform_done 
	movzx	eax, al
	push	eax
	call	rot13
	add		esp, 4 
	stosb 	
	loop	.transform_next
		
.transform_done:
	add		edi, 1 
	mov		byte [edi], 0
	
	pop		eax 
	pop		ecx 
	pop		edi 
	pop		esi
	
	pop		ebp 
	ret 
	
	
;===========================================
; rot13(char_addr)
; 	
; Input: address of the char to rotate 
; Ouput: eax - rotated char value 
; Operation: add 13 decimal to the char code 
; 	if out of bound of the last char (Z || z), 
;	add the difference to the beggining as a circle

rot13:
	.char_addr = 8h
	push	ebp 
	mov		ebp, esp
	
	push	esi 
	push	edi
		
	.out_char_off = 4 
			
	sub		esp, .out_char_off
		
	mov		esi, dword [ebp + .char_addr]
	mov		edi, dword [ebp - .out_char_off] 
	
	mov		eax, esi
	
	cmp		esi, 41h 
	jb		.rot_done 
	cmp		esi, 7ah 
	ja		.rot_done 
	
	cmp		esi, 5ah
	jbe		.upper_case 
	cmp		esi, 61h
	jae		.lower_case 2.  Caesar
    
    The ROT13 transformation changes a latin letter into another latin letter in
    the following method:

    We order all the latin letters 'a'-'z' on a circle. A letter is transformed
    into the letter which could be found 13 locations clockwise.

    Example:
      ROT13(a) = n
      ROT13(b) = o
      ROT13(p) = c
      ROT13(c) = p

    Note that the ROT13 transform is its own inverse. That means:
    ROT13(ROT13(x)) = x for every letter x.
    We will use this transform to encode and decode text made of latin letters.

    Example:
      'Somebody set up us the bomb.' -> 'Fbzrobql frg hc hf gur obzo.'
      'Fbzrobql frg hc hf gur obzo.' -> 'Somebody set up us the bomb.'

    0.  Write a function that implements the ROT13 transform, and extends it a
        bit: The function takes a character as input. If the character is a
        latin letter, it is transformed. (13 places clockwise). If the character
        is not a latin letter, it is left unchanged.

        Capital latin letters will result in capital letters after the
        transform. Minuscule letters will result in minuscule letters.

        The function finally returns the transformed character.

    1.  Write a function that transforms a string. The function takes a null
        terminated string as an argument, and transforms every letter in the
        string, using the previously written function.

    2.  Write a program that takes a string from the user, and prints back to
        the user the transformed string.

    3.  Tbbq wbo! Jryy qbar!

format PE console
entry start

include 'win32a.inc' 

MAX_STR_LEN = 0x40

section '.data' data readable writeable
	enter_str	db	'Please enter a string: ',0
	
section '.bss' readable writeable
	user_str		db		MAX_STR_LEN 	dup 	(?)
	user_str_len	dd		?

section '.text' code readable executable

start: 
	mov		esi, enter_str
	call	print_str
	
	mov		edi, user_str
	mov		ecx, MAX_STR_LEN
	call	read_line
		
	mov     edi, user_str
    mov     ecx, MAX_STR_LEN
    xor     al,al
    repnz 	scasb
	
    neg     ecx
    add     ecx, MAX_STR_LEN
    dec     ecx
	
    mov     dword [user_str_len], ecx

	push	dword [user_str_len]
	push	user_str
	call	encode_decode_str
	add		esp, 4*2
	
	mov		esi, user_str
	call	print_str
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

;=====================================
; encode_decode_str(str_addr, str_len)
;=====================================
encode_decode_str:
	.str_addr = 0x8
	.str_len = 0xc 
	
	push 	ebp
	mov		ebp, esp
	
	push	esi
	push	eax
	push	ebx
	push	ecx
	
	mov		esi, dword [ebp + .str_addr]
	mov		ecx, dword [ebp + .str_len]
	jecxz 	.done
	xor		eax, eax
	xor		ebx, ebx
.next_char:
	mov		al, byte [esi + ebx]
	
	push	eax
	call	encode_decode_char
	add		esp, 4
	
	mov		byte [esi + ebx], al
	
	inc		ebx
	dec		ecx 
	jnz		.next_char
	
.done:
	pop		ecx
	pop		ebx
	pop		eax
	pop		esi

	mov		esp, ebp
	pop		ebp 
	ret

;==================================
; encode_decode_char(char)
;==================================
encode_decode_char:
	.char = 0x8
	
	push	ebp
	mov		ebp, esp
	
	push	ecx
	
	mov		eax, dword [ebp + .char]
	cmp		al, 0x41
	jb		.epilogue
	cmp		al, 0x7a
	ja		.epilogue
	cmp		al, 0x5a
	jbe		.is_upper 
	cmp		al, 0x61
	jae		.is_lower
	jmp		.epilogue
.is_upper:
	add		eax, 0xd
	cmp		al, 0x5a
	jbe		.epilogue
	sub		al, 0x5a
	add		al, 0x40
	
	jmp		.epilogue
.is_lower:
	add		eax, 0xd
	cmp		al, 0x7a
	jbe		.epilogue
	sub		al, 0x7a
	add		al, 0x60
	
.epilogue:
	pop		ecx

	mov		esp, ebp
	pop		ebp
	ret 


include 'training.inc'
