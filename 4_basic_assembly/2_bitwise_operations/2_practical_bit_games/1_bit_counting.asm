; 1.  Bit counting:
    
; Write a program that takes a number (of size 4 bytes) x as input, and then
; counts the amount of "1" bits in even locations inside the number x. We
; assume that the rightmost bit has location 0, and the leftmost bit has a
; location of 31.

; Example:
; if x == {111011011}_2, then we only count the bits with stars under them.
		   ; * * * * *
		   ; 8 6 4 2 0 
; Hence we get the result of 4.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex
	mov		esi, eax
	
	xor		ebx, ebx
	mov		ecx, 0x10
	
shift_and_count:
	mov		edi, esi
	and		edi, 0x1
	add		ebx, edi
	
	ror 	esi, 0x2
	dec		ecx 
	jnz		shift_and_count
	
	mov		eax, ebx
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

