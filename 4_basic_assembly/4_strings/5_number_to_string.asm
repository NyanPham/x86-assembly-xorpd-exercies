; 5.  Number to String

    ; We are going to write a program that converts a number into its base 10
    ; representation, as a string.

    ; The program will read a number as input (Using the read_hex helper
    ; subroutine). It will then print back the number, in base 10.
	
    ; Example:
      
      ; Input:  1f23
      ; output: 7971 (Decimal representation).

    ; HINTS:
      ; - Recall that the input number could be imagined to be in the form:
        ; input = (10^0)*a_0 + (10^1)*a_1 + ... + (10^t)*a_t

      ; - Use repeated division method to calculate the decimal digits
        ; a_0,a_1,...,a_t.

      ; - Find out how to translate each decimal digit into the corresponding
        ; ASCII symbol. (Recall the codes for the digits '0'-'9').

      ; - Build a string and print it. Remember the null terminator!

format PE console
entry start

include 'win32a.inc' 

MAX_STR_LEN = 0x40

section '.data' data readable writeable
	enter_num				db		'Enter hex: ',0xd,0xa,0
	
section '.bss' readable writeable
	hex_num					dd		?
	dec_str					db		MAX_STR_LEN		dup  (0)
	dec_str_len				dd		0
	outbound				db		0
	
section '.text' code readable executable

start:
	mov		esi, enter_num
	call	print_str
	
	call	read_hex
	mov		dword [hex_num], eax
	
	;====================================
	; Repeat division to find next digit
	;====================================
	mov		ebx, 10			; divisor
	mov		esi, 1			; prev_divisor
	xor		ecx, ecx
	mov		edi, dec_str
next_digit:
	xor		edx, edx
	mov		eax, dword [hex_num]
	idiv	ebx
	mov		eax, edx
	cmp		eax, dword [hex_num]
	jnz		.still_in_bound
	
	cmp		byte [outbound], 0
	jnz		.done
	inc		byte [outbound]

.still_in_bound:
	xor		edx, edx
	div		esi
	mov		esi, ebx
	
	add		eax, 0x30
	mov		byte [edi + ecx], al
	inc		dword [dec_str_len]
	
	mov		edx, ebx
	shl		ebx, 0x2
	add		ebx, edx
	shl		ebx, 0x1			; divisor *= 10
	
	inc		ecx 
	cmp		ecx, MAX_STR_LEN-1
	jnz		next_digit

.done:
	;=======================
	; Revert the order
	;=======================
	xor		ebx, ebx
	mov		ecx, dword [dec_str_len]
	dec		ecx 
	mov		esi, dec_str
swap_next:
	cmp		ebx, ecx
	jae		.done_swap
	
	mov		al, byte [esi + ebx]
	mov		dl, byte [esi + ecx]
	mov		byte [esi + ebx], dl
	mov		byte [esi + ecx], al
	
	inc		ebx
	dec		ecx
	jmp		swap_next

.done_swap:
	mov		esi, dec_str
	call 	print_str

end_prog:
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
