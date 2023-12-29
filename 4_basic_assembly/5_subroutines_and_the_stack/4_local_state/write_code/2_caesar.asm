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
	jae		.lower_case 
	jmp		.rot_done
		
.upper_case:
	add		eax, 0dh 			; char code + 13 decimal
	cmp		eax, 5ah			; are the circle out of Z?
	jbe		.rot_done 			; no, return 
	sub		eax, 5ah 			; yes, subtract for offset 
	add		eax, 40h 			; add to the begging of circle: A char 
	jmp		.rot_done	
			
.lower_case:
	add		eax, 0dh
	cmp		eax, 7ah 
	jbe		.rot_done 
	sub		eax, 7ah 
	add		eax, 60h 
	jmp		.rot_done 	
	
.rot_done:
	add		esp, .out_char_off
	
	pop		edi 
	pop		esi
	
	pop		ebp 
	ret 


include 'training.inc'





















