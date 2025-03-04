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

format PE console
entry start

include 'win32a.inc' 

struct FRAC
	numer		dd	?
	denom		dd	?
ends

section '.data' data readable writeable
	delimiter 	db		'----------',0xd,0xa,0
	hex_pre		db		'0x',0
	space		db		' ',0
	
section '.bss' readable writeable
	frac_1		FRAC		?
	frac_2		FRAC		?
	frac_res	FRAC		?
	
section '.text' code readable executable

start:
	push	frac_res
	push	9
	call	compute_finite_series
	add		esp, 4*2
	
	push	frac_res 
	call	print_frac
	add		esp, 4
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

;============================
; compute_finite_series(n, frac_res_addr)
;============================
compute_finite_series:
	.n 				= 0x8
	.frac_res_addr 	= 0xc 
	
	push	ebp
	mov		ebp, esp
	
	.tmp_frac_1 	= -1*sizeof.FRAC
	.tmp_frac_2 	= -2*sizeof.FRAC
	.tmp_frac_res 	= -3*sizeof.FRAC
	sub		esp, 3*sizeof.FRAC
	
	pusha 
	
	; Check if n >= 2
	mov		ecx, dword [ebp + .n]
	cmp		ecx, 2
	jb		.done_add
	
	; Construct the initial frac 1/1^2
	lea 	edi, dword [ebp + .tmp_frac_res]
	push	edi
	push	1
	push	1
	call	construct_frac
	add		esp, 4*3
	
	; Prepare to get to the add loop
	mov		ebx, 2
.next_add:
	; Copy the prev result into first operand
	lea		esi, dword [ebp + .tmp_frac_res]
	lea		edi, dword [ebp + .tmp_frac_1]
	
	mov		eax, dword [esi + FRAC.numer]
	mov		dword [edi + FRAC.numer], eax
	
	mov		eax, dword [esi + FRAC.denom]
	mov		dword [edi + FRAC.denom], eax
	
	; Compute the next frac denom
	mov		eax, ebx 
	xor		edx, edx
	mul		eax				; a^2
	
	; Construct the other operand frac
	lea		edi, dword [ebp + .tmp_frac_2]
	push	edi
	push	eax
	push	1
	call	construct_frac
	add		esp, 4*3
	
	; Add both fracs into temporary result
	lea		esi, dword [ebp + .tmp_frac_1]
	lea		edi, dword [ebp + .tmp_frac_2]
	lea		edx, dword [ebp + .tmp_frac_res]
	
	push	edx 
	push	edi
	push	esi
	call	add_fracs
	add		esp, 4*3
	
	inc		ebx
	cmp		ebx, ecx
	jbe		.next_add
	
.done_add:
	; Copy the result into the out variable
	lea		esi, dword [ebp + .tmp_frac_res]
	mov		edi, dword [ebp + .frac_res_addr]
	
	mov		eax, dword [esi + FRAC.numer]
	mov		dword [edi + FRAC.numer], eax
	mov		eax, dword [esi + FRAC.denom]
	mov		dword [edi + FRAC.denom], eax

.epilogue:
	popa 
	
	mov		esp, ebp
	pop		ebp
	ret 

;============================
; construct_frac(a, b, dst_addr)
;============================
construct_frac:
	.a = 0x8
	.b = 0xc 
	.dst_addr = 0x10
	
	push	ebp
	mov		ebp, esp
	
	push	edi
	push	eax 
	push	ebx
	
	mov		edi, dword [ebp + .dst_addr]
	mov		eax, dword [ebp + .a]
	mov		ebx, dword [ebp + .b]
	
	mov		dword [edi + FRAC.numer], eax
	mov		dword [edi + FRAC.denom], ebx
	
	push	edi
	call	reduce_frac
	add		esp, 4
	
.done:
	pop		ebx
	pop		eax
	pop		edi

	mov		esp, ebp
	pop		ebp
	ret

;=======================================
; reduce_frac(frac_addr)
;=======================================
reduce_frac:
	.frac_addr = 0x8
	
	push	ebp
	mov		ebp, esp
	
	push	esi
	push	eax
	push	ebx
	push	edx
	
	mov		esi, dword [ebp + .frac_addr]
	mov		eax, dword [esi + FRAC.numer]
	mov		ebx, dword [esi + FRAC.denom]
	
	push	ebx
	push	eax
	call	stein
	add		esp, 4*2
	
	mov		ebx, eax 
	
	mov		eax, dword [esi + FRAC.numer]
	xor		edx, edx 
	div		ebx
	mov		dword [esi + FRAC.numer], eax 
	
	mov		eax, dword [esi + FRAC.denom]
	xor		edx, edx 
	div		ebx
	mov		dword [esi + FRAC.denom], eax 
	
.done:
	pop		edx
	pop		ebx
	pop		eax 
	pop		esi
	
	mov		esp, ebp
	pop		ebp
	ret
	
;=======================================
; add_fracs(frac_1_addr, frac_2_addr, frac_res_addr)
;=======================================
add_fracs:
	.frac_1_addr = 0x8
	.frac_2_addr = 0xc
	.frac_res_addr = 0x10
	.temp = -0x4
	
	push 	ebp
	mov		ebp, esp
	
	pusha
	
	mov		esi, dword [ebp + .frac_1_addr]
	mov		edi, dword [ebp + .frac_2_addr]
	mov		ecx, dword [ebp + .frac_res_addr]
	
	mov		eax, dword [esi + FRAC.denom]
	mov		ebx, dword [edi + FRAC.denom]
	
	push	ebx
	push	eax
	call	lcm
	add		esp, 4*2

	mov		dword [ecx + FRAC.denom], eax
	
	; Find a*(L/b)
	mov	 	eax, dword [ecx + FRAC.denom]
	mov		ebx, dword [esi + FRAC.denom]
	xor		edx, edx
	div		ebx			 					; (L/b)
	
	mov		ebx, dword [esi + FRAC.numer]	
	xor		edx, edx
	mul		ebx
	mov		dword [ebp + .temp], eax		; a * (L/b)
	
	; Find c*(L/d)
	mov	 	eax, dword [ecx + FRAC.denom]
	mov		ebx, dword [edi + FRAC.denom]
	xor		edx, edx
	div		ebx			 					; (L/d)
		
	mov		ebx, dword [edi + FRAC.numer]	;
	xor		edx, edx
	mul		ebx								; c * (L/d)
	
	add		eax, dword [ebp + .temp]		; a * (L/b) + c * (L/d) 		
	
	mov		dword [ecx + FRAC.numer], eax
	
.done:
	popa 
	
	mov		esp, ebp
	pop		ebp
	ret
	
;=======================================
; print_frac(frac_addr)
;=======================================
print_frac:
	.frac_addr = 0x8
	
	push	ebp
	mov		ebp, esp
	
	push	eax
	push	ebx
	push	esi
	
	mov		esi, space
	call	print_str
	
	mov		esi, hex_pre
	call	print_str
	
	mov		ebx, dword [ebp + .frac_addr]
	mov		eax, dword [ebx + FRAC.numer]
	call	print_eax
	
	mov		esi, delimiter
	call	print_str
		
	mov		esi, space
	call	print_str
	
	mov		esi, hex_pre
	call	print_str
	
	mov		eax, dword [ebx + FRAC.denom]
	call	print_eax
.done:
	pop		esi
	pop		ebx
	pop		eax

	mov		esp, ebp
	pop		ebp
	ret 
	
;=======================================
; lcm(a, b)
;=======================================	
lcm:
	.a = 0x8
	.b = 0xc 
	
	push	ebp
	mov		ebp, esp
	
	push	ebx
	push	ecx
	push	edx 
	
	mov		eax, dword [ebp + .a]	; a
	mov		ebx, dword [ebp + .b]	; b
	
	push	eax
	push	ebx
	call	stein
	add		esp, 4*2
	
	mov		ecx, eax				; GCD (a, b)
	mov		eax, dword [ebp + .a]	; a 
	mov		ebx, dword [ebp + .b]	; b
	
	xor		edx, edx 
	mul		ebx						; a * b
	xor		edx, edx
	div		ecx						; (a*b) / GCD(a, b)
	
.done:
	pop		edx 
	pop		ecx
	pop		ebx

	mov		esp, ebp
	pop		ebp
	ret 


; ===========================================================
; stein(a,b)
;
; Input:
;   2 dwords a, b
; Output:
;   gcd(a, b)
; Operations:
;   
;
stein:
    .a = 0x8
    .b = 0xc 
	
    push	ebp
	mov		ebp, esp
	
    push    esi
    push    edi
    push    ecx
    push    ebx

    mov     esi,[ebp + .a]		; a 
    mov     edi,[ebp + .b]		; b
	
    mov     eax,esi				; a
    test    edi,edi				; if (b == 0), return a 
    jz      .end_func

    mov     eax,edi				; b
    test    esi,esi				; if (a == 0) return b
    jz      .end_func
	
    xor     ebx,ebx				; val

    mov     ecx,esi				
    not     ecx					
    and     ecx,1				
    shr     esi,cl				; if a is even, a /= 2
    add     ebx,ecx				; and val += 1
	
    mov     ecx,edi				
    not     ecx
    and     ecx,1
    shr     edi,cl				; if b is even, b /= 2
    add     ebx,ecx				; and val += 1
	
    test    ebx,ebx				; val == 0 -> both a and b are odd
    jnz     .not_both_odd

    cmp     esi,edi				; If both are odd, swap a and b such that a >= b
    jae     .a_bigger_equal
    xchg    esi,edi         ; Exchanges the contents of esi,edi
.a_bigger_equal:

    sub     esi,edi				; (a - b) / 2
    shr     esi,1
.not_both_odd:
    
    push    edi
    push    esi
    call    stein
    add     esp,4*2

    mov     ecx,ebx
    shr     ecx,1
    shl     eax,cl
	
.end_func:
    pop     ebx
    pop     ecx
    pop     edi
    pop     esi
	
	mov		esp, ebp
	pop		ebp
    ret

include 'training.inc'
