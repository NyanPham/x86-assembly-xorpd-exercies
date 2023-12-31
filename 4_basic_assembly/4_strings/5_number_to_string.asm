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

DEC_NUM_MAX_LEN		=	10d  

section '.data' data readable writeable 
	enter_hex_num			db		'Please enter a hex number:',13,10,0
	
section '.bss' readable writeable 
	hex_num					dd 		? 
	dec_num_str 			db		DEC_NUM_MAX_LEN + 1  dup	(?)
	dec_num_str_len			dd		?
	
section '.text' code readable executable
	
start:	
	mov		esi, enter_hex_num
	call	print_str 
		
	call 	read_hex 
	mov		dword [hex_num], eax 
	
	mov		ebx, 10d
	mov		ecx, 0 			; index in dec_num_str 
		
compute_dec_digit:
	xor		edx, edx 
	div		ebx
	add		edx, 30h 
	mov		byte [dec_num_str + ecx], dl  
	inc		ecx
	test	eax, eax 
	jnz		compute_dec_digit
		
	mov		dword [dec_num_str_len], ecx 
	
reverse_dec_num_str:
	mov		edx, ecx
	dec		edx 
	shr		ecx, 1	
	xor		ebx, ebx 
	mov		esi, dec_num_str
	
.reverse_next_char:
	mov		al, byte [esi + ebx]
	mov		ah, byte [esi + edx]
	mov		byte [esi + ebx], ah
	mov		byte [esi + edx], al 
	inc		ebx 
	dec		edx 
	clc 
	dec		ecx 
	jnz		.reverse_next_char
.reverse_done:
	mov		eax, dword [dec_num_str_len]
	mov		byte [esi + eax], 0 
	
print_result:
	mov		esi, dec_num_str
	call	print_str 
	
	push	0
	call	[ExitProcess]
	
include 'training.inc'