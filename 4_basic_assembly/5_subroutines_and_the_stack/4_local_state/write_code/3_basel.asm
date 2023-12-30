format PE console
entry start 

include 'win32a.inc'

struct FRACTION 
	numer	dd	? 
	denom	dd	? 
ends 
	
; section '.data' data readable writeable 

section '.bss' readable writeable
	frac_1 		FRACTION	?
	frac_2 		FRACTION	?
	
section '.text' code readable executable 
start:
	mov		eax, [esp]
	call	print_eax 
		
	mov		esi, frac_1 
	call	read_hex 
	mov		ebx, eax 
	call	read_hex 
	push	esi
	push	eax 
	push	ebx 
	call	create_fraction
	add		esp, 4*3
	
	call	print_delimiter
	
	mov		esi, frac_2
	call	read_hex 
	mov		ebx, eax 
	call	read_hex 
	push	esi
	push	eax 
	push	ebx 
	call	create_fraction
	add		esp, 4*3
	
	call	print_delimiter
	call	print_delimiter

	
	
	mov		eax, [esp]
	call	print_eax 
	
	push	0
	call	[ExitProcess]
	
;===================================
; add_fractions(frac_addr_1, frac_addr_2)
;
add_fractions:
	.frac_addr_1 = 8h
	.frac_addr_2 = 0ch
	push	ebp 
	mov		ebp, esp 
	
	push	esi
	push	edi 
	push	ebx 
	push	ecx 
	push	edx 
	
	
	
	
	pop		edx 
	pop		ecx 
	pop		ebx 
	pop		edi 
	pop		esi
	
	pop		ebp 
	ret 
	
;===================================
; create_fraction(numer, denom, frac_addr) 
; 
create_fraction:
	.numer = 8h 
	.denom = 0ch 
	.frac_addr = 10h 
	push	ebp
	mov		ebp, esp
	
	push	esi 
	push	eax 
	
	mov		esi, dword [ebp + .frac_addr] 
	mov		eax, dword [ebp + .numer]
	mov		dword [esi + FRACTION.numer], eax 
	mov		eax, dword [ebp + .denom]
	mov		dword [esi + FRACTION.denom], eax 
		
	push	esi
	call	reduce_fraction
	add		esp, 4
	
	pop		eax 
	pop		esi 
	
	pop		ebp 
	ret 
	
;===================================
; reduce_fraction(frac_addr)
; 
reduce_fraction:
	.frac_addr = 8h
	push	ebp 
	mov		ebp, esp
	
	.num_1 = -4h
	.num_2 = -8h
	.numer_smaller = -0ch
	sub		esp, 4*3
	
	push	esi
	push	edi
	push	eax 
	push	edx 
	push	ebx 
	push	ecx 
	
	xor 	ecx,ecx 
	xor 	ebx, ebx 
	xor		edx, edx 
	xor		eax, eax 
	
	mov		esi, dword [ebp + .frac_addr]	
	mov		dword [ebp + .numer_smaller], 1 
	mov		edi, dword [esi + FRACTION.numer]
	mov		ebx, dword [esi + FRACTION.denom] 
	cmp		edi, ebx
	je		.is_one
	jb		.reduce
	mov		dword [ebp + .numer_smaller], 0
	push	edi 
	push	ebx 
	pop		edi 
	pop		ebx
	jmp		.reduce 
	
.is_one:
	mov		eax, 1
	mov		ebx, 1 
	jmp		.set_reduce
	
.reduce:
	mov		ecx, edi 
	
.divisor_loop:
	mov		eax, edi 
	xor 	edx, edx 
	div		ecx 
	mov		dword [ebp + .num_1], eax
	test	edx, edx 	
	jnz		.not_divisor
			
	mov		eax, ebx 
	xor		edx, edx 
	div		ecx 
	mov		dword [ebp + .num_2], eax 
	test	edx, edx 
	jz		.divisor_found
	
.not_divisor:
	dec		ecx 
	jnz		.divisor_loop 
	jmp		.divisor_not_found 
	
.divisor_found:
	mov		eax, dword [ebp + .numer_smaller]
	test	eax, eax 
	jnz 	.denom_num_2 
.denom_num_1:
	mov		eax, dword [ebp + .num_2]
	mov		ebx, dword [ebp + .num_1]
	jmp		.set_reduce
.denom_num_2:
	mov		eax, dword [ebp + .num_1]
	mov		ebx, dword [ebp + .num_2]
	
.set_reduce:
	mov		dword [esi + FRACTION.numer], eax 
	mov		dword [esi + FRACTION.denom], ebx 
		
	jmp 	.end
		
.divisor_not_found:
	jmp 	.end
	
.end:	
	pop		ecx 
	pop		ebx 
	pop		edx 
	pop		eax 
	pop		edi
	pop		esi
	
	add		esp, 4*3
	
	pop		ebp 
	ret 
	
;===================================
; print_fraction(frac_addr)
;
print_fraction: 
	.frac_addr = 8h 
	push	ebp 
	mov		ebp, esp
	
	push	esi
	push	eax 
	
	mov		esi, dword [ebp + .frac_addr]
	mov		eax, dword [esi + FRACTION.numer]
	call	print_eax 
	
	mov		eax, dword [esi + FRACTION.denom]
	call	print_eax 
	
.end:	
	pop		eax 
	pop		esi
	
	pop		ebp 
	ret 
	
	
include 'training.inc'