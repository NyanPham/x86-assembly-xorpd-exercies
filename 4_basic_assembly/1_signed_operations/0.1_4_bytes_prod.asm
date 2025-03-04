; 0.1 Write a program that does the same, except that it multiplies the four
; bytes. (All the bytes are considered to be unsigned).

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex
	
	sub		edx, edx
	mov		ecx, 0x10000
	idiv	ecx
	
	mov		ecx, eax
	mov		ebx, edx 
	
	movzx	ax, cl
	movzx	si, ch
	mul		si
	movzx	si, bl
	mul		si
	movzx	si, bh
	mul 	si
	
	call	print_eax

	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

