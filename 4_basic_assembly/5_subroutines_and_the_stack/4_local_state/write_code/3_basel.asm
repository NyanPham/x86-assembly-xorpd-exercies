format PE console
entry start 

include 'win32a.inc'

struct FRACTION 
	numer	dd	? 
	denom	dd	? 
ends 
	
section '.data' data readable writeable 
	frac_delim		db	'---',13,10,0
		
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
	

	mov		esi, frac_1 
	mov		edi, frac_2
	push	edi 
	push	esi
	call	add_fractions
	add		esp, 4*2
		
	mov ebx, dword [eax]
	mov ecx, dword [eax + 4]
		
	mov eax, ebx
	call    print_eax 
			
	mov eax, ecx
	call    print_eax 

	
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
	push 	ebp 
	mov		ebp, esp
	sub     esp, sizeof.FRACTION
	
	.sum_numer_offset = -8h
    .sum_denom_offset = -4h
	
	push	esi
	push	edi
	push	edx 
	push	ecx 
	push	ebx 
	
	mov		esi, dword [ebp + .frac_addr_1]
	mov		edi, dword [ebp + .frac_addr_2]
			
	;=================================
	; Get product of both denominator
	;================================= 
	mov		eax, dword [esi + FRACTION.denom]
	mov		ebx, dword [edi + FRACTION.denom]
	mul		ebx 
	mov		ecx, eax 			; ecx = product 
	
	;===============================
	; Get GCD of both denominator
	;===============================
	mov		eax, dword [esi + FRACTION.denom]
	mov		ebx, dword [edi + FRACTION.denom]
	push	ebx 
	push	eax
	call	stein 
	add		esp, 4*2 			; eax has GCD 
	
	;===============================
	; Get the LCM = product / GCD 
	;===============================
	mov		ebx, eax 			; swap eax and ecx
	mov		eax, ecx 			; eax is not product 		
	mov		ecx, ebx 			; ecx is GCD to divide 
	div		ecx 				; eax is now LCM after division
	
	;=========================================
	; store LCM as the denominator of the sum
	;=========================================
	mov dword [ebp + .sum_denom_offset], eax
		
	;=========================================
	; compute for the numerator of the sum 
	;=========================================
	mov	eax, dword [ebp + .sum_denom_offset]
    mov ebx, dword [esi + FRACTION.denom]
    div ebx 
    mov ebx, dword [esi + FRACTION.numer]
    mul ebx
    mov dword [ebp + .sum_numer_offset], eax 
    
    mov eax, dword [ebp + .sum_denom_offset]
    mov ebx, dword [edi + FRACTION.denom]
    div ebx 
    mov ebx, dword [edi + FRACTION.numer]
    mul ebx 
    
    add eax, dword [ebp + .sum_numer_offset]
    mov dword [ebp + .sum_numer_offset], eax 
    
    lea eax, dword [ebp - sizeof.FRACTION]
		
.end_func:
	pop		ebx 
	pop		ecx 
	pop		edx 
	pop		edi 
	pop		esi 
	
	add esp, sizeof.FRACTION
	
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
	
	push	esi
	mov		esi, frac_delim
	call	print_str 
	pop		esi 
		
	mov		eax, dword [esi + FRACTION.denom]
	call	print_eax 
	
.end:	
	pop		eax 
	pop		esi
	
	pop		ebp 
	ret 
	
; ===========================================================
; stein(a,b)
;
; Input:
;   number a and number b 
; Output:
;   eax = Greatest Common Divisor between a & b 
; Operations:
;   continuously check a and b if they are odd/even 
;	if a is even => a = a / 2
;   if b is even => b = b / 2
;	if both are odd, a = |a - b| / 2
;	continue until any a or b is 0, the remainder is the GCD 
;
stein:
	.a = 8h
	.b = 0ch
	
	push	ebp 
	mov		ebp, esp 
	
	push	esi
	push	edi 
	push	ecx 
	push	ebx 
	
	mov		esi, dword [ebp + .a]
	mov		edi, dword [ebp + .b]
	
	mov		eax, esi 
	test 	edi, edi
	jz 		.end_func
	
	mov		eax, edi
	test	esi, esi
	jz		.end_func
	
	xor 	ebx, ebx
	
	mov		ecx, esi
	not		ecx 
	and		ecx, 1
	shr		esi, cl 
	add		ebx, ecx 
	
	mov		ecx, edi
	not		ecx 
	and		ecx, 1
	shr		edi, cl 
	add		ebx, ecx 
	
	test	ebx, ebx
	jnz		.not_both_odd 
	
	cmp		esi, edi 
	jae		.a_bigger_equal 
	xchg 	esi, edi 
	
.a_bigger_equal:
	sub		esi, edi 
	shr		esi, 1 
	
.not_both_odd:
	push	edi
	push	esi 
	call	stein 
	add		esp, 4*2  
	
	mov		ecx, ebx 
	shr 	ecx, 1
	shl		eax, cl 
	
.end_func:
	pop		ebx 
	pop		ecx 
	pop		edi
	pop		esi 
	
	pop		ebp
	ret 
	
	
include 'training.inc'