; 0.2 Write a program that finds every double word (4 bytes) that satisfies the
; following condition: When decomposed into 4 bytes, if we multiply those
; four bytes, we get the original double word number.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	mov		esi, 0xffffffff

check_loop:
	mov		eax, esi
	sub		edx, edx
	mov		ebx, 0x10000
	div		ebx
	
	; edx: lower, eax: higher
	
	mov		ebx, edx
	mov		ecx, eax 
	
	movzx	eax, bl
	movzx	edx, bh
	mul		edx
	movzx	edx, cl
	mul		edx
	movzx	edx, ch
	mul		edx
	
	cmp		eax, esi 
	jnz		skip_print
	
	call	print_eax

skip_print:
	dec		esi
	cmp		esi, 0xffffffff
	jnz 	check_loop

end_prog:
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

