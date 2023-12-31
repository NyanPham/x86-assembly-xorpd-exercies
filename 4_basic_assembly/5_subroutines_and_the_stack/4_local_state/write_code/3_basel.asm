; 3.  Basel
    
    ; Consider fractions. A fraction is denoted as a/b, where a and b are
    ; integers. a is called the numerator, and b is called the denominator. For
    ; this exercise we assume a >= 0, b > 0.

    ; The sum of two fractions is also a fraction. 

    ; In order to calculate the sum of a/b and c/d, we first find the least common
    ; multiple (LCM) of b and d (Call it L), and then we get:
    
        ; a     c     a*(L/b) + c*(L/d)
        ; -  +  -  =  -----------------
        ; b     d             L

    ; Example:
        ; 1/2 + 1/3 = 5/6

    
    ; Every fraction has a unique representation as a Reduced fraction. A reduced
    ; fraction is a fraction where the numerator and the denominator have no
    ; common divisors.

    ; Examples for reduced fractions:
      ; 1/3, 7/4, 18/61.

    ; Examples for fractions which are not in the reduced form:
      ; 2/4, 21/6, 42/164

	
    ; 0.  Define a struct to represent a fraction.

    ; 1.  Write a function that transforms a fraction into the reduced form.

    ; 2.  Write a function that takes the following arguments: a, b, dest_addr.
        ; The function then creates a fraction a/b at address dest_addr. The
        ; fraction will be stored in its reduced form.

    ; 2.  Write a function that calculates the sum of two fractions. 
        ; The result will be in the reduced form.
        ; HINT: LCM(a,b) = (a*b) / GCD(a,b).

    ; 3.  Write a function that prints a fraction nicely to the screen.

    ; 4.  Calculate the following sum:
        
          ; 1     1     1           1
         ; --- + --- + --- + ... + ---  =  ?
         ; 1^2   2^2   3^2         9^2
		
    ; 5.  Bonus: What value does this sum approximate?
	; => The value of the sum approximate π^2/6 ≈ 1.64493407
;	

format PE console
entry start 

include 'win32a.inc'

struct FRACTION 
	numer	dd	? 
	denom	dd	? 
ends 
	
BASEL_MAX = 9h 
BASEL_MIN = 1h
	
section '.data' data readable writeable 
	frac_delim		db	'---',13,10,0
	result_is		db  'The result of the sum',13,10
					db  ' 1/(1^2) + 1/(2^2) + 1/(3^2) + ... + 1/(9^2) = ',0
		
section '.bss' readable writeable
	frac_1 		FRACTION	?
	frac_2 		FRACTION	? 
	
section '.text' code readable executable 
start:

	; initalize the frac_2 to be the 0/1,  
	; storing the sum of each iteration
	
	mov		eax, 0h				
	mov		ebx, 1h
	mov		esi, frac_2 
	push	esi
	push	ebx 
	push	eax 
	call	create_fraction
	add		esp, 4*3 
	
	mov		ecx, BASEL_MIN
sum_next:
	; Initialize frac_1 to be the next element to add
	mov		ebx, 1h				; numerator is always 1 
	mov		eax, ecx 			
	mul		eax 				; denominator is from (1 -> 9)^2 
	mov		esi, frac_1 
	push	esi
	push	eax 
	push	ebx 
	call	create_fraction
	add		esp, 4 * 3
	
	; add both fractions together
	; eax returned with address of the stack memory
	; of the local variable for the numerator and denominator 
	mov		esi, frac_1 
	mov		edi, frac_2 
	push	edi 
	push	esi
	call	add_fractions
	add		esp, 4 * 2
	
	
	; Store the sum (resulted numerator and denominator) back to frac_2
	mov		esi, frac_2			
	push	esi
	mov		edx, dword [eax + 4]
	push	edx 
	mov		edx, dword [eax]
	push	edx 
	call	create_fraction
	add		esp, 4 * 3
	
	inc		ecx 
	cmp		ecx, BASEL_MAX 
	jbe  	sum_next
	
	mov		esi, result_is
	call 	print_str 
			
	mov		esi, frac_2
	push	esi
	call	print_fraction
	add		esp, 4
	
	push	0
	call	[ExitProcess]
	
;===================================
; add_fractions(frac_addr_1, frac_addr_2)
;
; Input: addresses of both fractions
; Ouput: eax - address of the local variable (space for numerator and denominator of the sum)
; Operation: 
; 	Get the LCM of both denominators and compute the sum of both numerators based on LCM 
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
	mov		eax, dword [ebp + .sum_denom_offset]
    mov 	ebx, dword [esi + FRACTION.denom]
    div 	ebx 
    mov 	ebx, dword [esi + FRACTION.numer]
    mul 	ebx
    mov 	dword [ebp + .sum_numer_offset], eax 
    
    mov 	eax, dword [ebp + .sum_denom_offset]
    mov 	ebx, dword [edi + FRACTION.denom]
    div 	ebx 
    mov 	ebx, dword [edi + FRACTION.numer]
    mul 	ebx 
    
    add 	eax, dword [ebp + .sum_numer_offset]
    mov 	dword [ebp + .sum_numer_offset], eax 
    
    lea 	eax, dword [ebp - sizeof.FRACTION]
		
.end_func:
	pop		ebx 
	pop		ecx 
	pop		edx 
	pop		edi 
	pop		esi 
	
	add 	esp, sizeof.FRACTION
	
	pop		ebp
	ret 
	
;===================================
; create_fraction(numer, denom, frac_addr) 
; 
; Input: numerator, denominator, address of the destination fraction
; Output: void 
; Operation: copy enumerator and denominator to relevant offset in destination fraction
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
	
	mov		eax, dword [esi + FRACTION.numer]
	test	eax, eax 
	jz 		.end_func
		
	mov		eax, dword [esi + FRACTION.denom]
	test	eax, eax 
	jz 		.end_func
		
	push	esi
	call	reduce_fraction
	add		esp, 4

.end_func:

	pop		eax 
	pop		esi 
	
	pop		ebp 
	ret 
	
;===================================
; reduce_fraction(frac_addr)
; 
; Input: address of the fraction
; Ouput: void, altering the original value stored at the address 
; Operation: transform the fraction into reduced from 
; 	e.g: 2/4 -> 1/2 
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
	
	jmp     .print_eax_after_data
	.print_eax_fmt   db          "%x/%x",10,13,0
.print_eax_after_data:
			
	mov		esi, dword [ebp + .frac_addr]
	mov		eax, dword [esi + FRACTION.denom]
	push	eax 
	mov		eax, dword [esi + FRACTION.numer]
	push    eax 
	push    .print_eax_fmt
	call    [printf]
	add     esp,4*3 
	
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