; 2.  Bit reverse:

; Write a program that takes a number (of size 4 bytes) x as input, and then
; reverses all the bits of x, and outputs the result. By reversing all bits we
; mean that the bit with original location i will move to location 31-i.

; Small example (for the 8 bit case):

  ; if x == {01001111}_2, then the output is {11110010}_2.

  ; In this example we reversed only 8 bits. Your program will be able to
  ; reverse 32 bits.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex
	mov		esi, eax
	
	call	print_eax_binary
	
	xor		edi, edi
	mov		ecx, 0x20
reverse_bit:
	shr		esi, 0x1
	rcl		edi, 0x1
	dec		ecx
	jnz		reverse_bit
	
	mov		eax, edi
	call	print_eax_binary
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

