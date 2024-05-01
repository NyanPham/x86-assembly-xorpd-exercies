
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
   
   
format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

struct Fraction
	numerator 	dd	?
	denominator	dd	?
ends 

section '.data' data readable writeable
	frac_format		db	'%d/%d',13,10,0
	result_is		db	'1/(1^2) + 1/(2^2) + 1/(3^2) + ... + 1/(9^2) = ',0
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	fraction1		Fraction	?
	fraction2		Fraction	?
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	;  1     1     1           1
	; --- + --- + --- + ... + ---  =  ?
	; 1^2   2^2   3^2         9^2

	push	fraction1
	push	1
	push	0
	call 	create_fraction
	add		esp, 4*3
	
	mov		ecx, 9
	mov		ebx, 1
.add_frac_loop:
	mov		eax, ebx 
	mul		ebx
	
	push	fraction2
	push	eax
	push	1
	call 	create_fraction
	add		esp, 4*3
		
	pusha 
	push	fraction1 
	push	fraction2 
	push	fraction1 
	call 	add_fractions
	add		esp, 4*3 
	popa 
	
	inc		ebx 
	dec		ecx 
	jnz		.add_frac_loop
	
	push	result_is
	call	[printf]
	add		esp, 4
	
	push	fraction1
	call 	print_fraction
	add		esp, 4	
	
	push	0
	call	[ExitProcess]

	
add_fractions:
	.frac1_addr = 8h
	.frac2_addr = 0ch 
	.sum_addr = 10h
	
	push	ebp 
	mov		ebp, esp
	
	pusha 
	
	sub		esp, 4*2
	
	mov		esi, dword [ebp + .frac1_addr]
	mov		edi, dword [ebp + .frac2_addr]
	
	;==================================================
	; Find the LCM of both denominators 
	;==================================================
	push	dword [esi + Fraction.denominator]
	push	dword [edi + Fraction.denominator]
	call 	lcm 	
	add		esp, 4*2
	
	mov		ebx, eax 
	
	;==================================================
	; The LCM is the denominator of the 
	; destination fraction
	;==================================================
	mov		dword [ebp - 4h], ebx
	
	;==================================================
	; Find the numerator of the destination fraction
	; with the formula: a*(L/b) + c*(L/d)
	;==================================================
	mov		eax, ebx
	mov		ecx, dword [esi + Fraction.denominator]
	xor		edx, edx 
	div		ecx 
	mov		ecx, dword [esi + Fraction.numerator]
	mul		ecx 
	mov		dword [ebp - 8h], eax 
	
	mov		eax, ebx
	mov		ecx, dword [edi + Fraction.denominator]
	xor		edx, edx 
	div		ecx 
	mov		ecx, dword [edi + Fraction.numerator]
	mul		ecx 
	
	add		eax, dword [ebp - 8h]
	mov		dword [ebp - 8h], eax 
	
	;==================================================
	; Reduce the destination fraction
	;==================================================
	push	ecx 
	mov		ecx, dword [ebp + .sum_addr]
	mov		eax, dword [ebp - 4h]
	mov		dword [ecx + Fraction.denominator], eax 
	mov		eax, dword [ebp - 8h]
	mov		dword [ecx + Fraction.numerator], eax 
	
	push	ecx 
	call	reduce_fraction
	add		esp, 4
	pop		ecx 
	
.end_func:
	add		esp, 4*2
	
	popa 

	pop		ebp 
	ret 
	
; create_fraction(numerator, denominator, frac_addr)
create_fraction:
	.numerator = 8h
	.denominator = 0ch
	.frac_addr= 10h
	
	push	ebp 
	mov		ebp, esp 
	
	pusha 
	
	mov		edi, dword [ebp + .frac_addr]
	mov		eax, dword [ebp + .numerator]
	mov		ebx, dword [ebp + .denominator]
	test 	ebx, ebx 
	jz		.end_func
	
	mov		dword [edi + Fraction.numerator], eax 
	mov		dword [edi + Fraction.denominator], ebx 
	
	push	edi 
	call 	reduce_fraction
	add		esp, 4
	
.end_func:
	popa 
	
	pop		ebp 
	ret 

; reduce_fraction(frac_addr)
reduce_fraction:
	.frac_addr = 8h
		
	push	ebp 
	mov		ebp, esp 
	
	pusha 
	
	sub 	esp, 4
	
	mov		esi, dword [ebp + .frac_addr]
	push	dword [esi + Fraction.denominator]
	push	dword [esi + Fraction.numerator]
	call	gcd
	add		esp, 4*2
	
	test 	eax, eax 
	jz		.end_func
	
	mov		dword [ebp - 4], eax 
	mov		ebx, dword [ebp - 4]
	
	xor		edx, edx
	mov		eax, dword [esi + Fraction.numerator]
	div		ebx
	mov		dword [esi + Fraction.numerator], eax 
	
	xor		edx, edx
	mov		eax, dword [esi + Fraction.denominator]
	div		ebx
	mov		dword [esi + Fraction.denominator], eax
	
.end_func:
	add 	esp, 4

	popa 
	
	pop 	ebp 
	ret 

print_fraction:
	.frac_addr = 8h
	
	push	ebp 
	mov		ebp, esp 
	
	pusha 
	
	mov		esi, dword [ebp + .frac_addr]
	
	push	dword [esi + Fraction.denominator]
	push	dword [esi + Fraction.numerator]
	push	frac_format
	call	[printf]
	add		esp, 4*3
	
.end_func:
	popa 
	
	pop 	ebp 
	ret 

; lcm(num1, num2)
lcm:
	.num1 = 8h
	.num2 = 0ch
	
	push	ebp
	mov		ebp, esp 
	
	push	esi
	push	edi 
	push	ecx 
	push	ebx 
	push	edx 
	
	mov		eax, dword [ebp + .num1]
	mov		ebx, dword [ebp + .num2]
	
	push	ebx 
	push	eax 
	call	gcd 
	add		esp, 4*2
	
	mov		edi, eax 
	
	mov		eax, dword [ebp + .num1]
	mov		ebx, dword [ebp + .num2]
	mul 	ebx 
	
	xor		edx, edx 
	div		edi

.end_func:
	pop		edx 
	pop		ebx 
	pop		ecx 
	pop		edi
	pop		esi

	pop		ebp
	ret 
	

; gcd(num1, num2)
gcd:
	.num1 = 8h
	.num2 = 0ch
	
	push	ebp
	mov		ebp, esp 
	
	push	esi
	push	edi 
	push	ecx 
	push	ebx 
	
	
	mov		esi, dword [ebp + .num1]
	mov		edi, dword [ebp + .num2]
	
	mov		eax, esi
	test	edi, edi
	jz		.end_func
	
	mov		eax, edi 
	test	esi, esi 
	jz		.end_func
	
	xor		ebx, ebx
	
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
	xchg	esi, edi
.a_bigger_equal:
	sub		esi, edi
	shr		esi, 1
	
.not_both_odd:
	push	esi 
	push	edi
	call	gcd
	add		esp, 4*2 
	
	mov		ecx, ebx 
	shr		ecx, 1 
	shl		eax, cl
	
.end_func:
	pop		ebx 
	pop		ecx 
	pop		edi
	pop		esi

	pop		ebp
	ret 

; get_num(prompt_addr)
get_num:
	.prompt_addr = 8h
	
	push	ebp 
	mov		ebp, esp 
		
	push	dword [ebp + .prompt_addr]
	call	[printf]
	add		esp, 4 
	
	push	INPUT_BUFFER_MAX_LEN
	push	bytes_read
	push	input_buffer 
	call	get_line
	add		esp, 4*3
	
	push	input_buffer 
	call	str_to_dec
	add		esp, 4
	
	pop		ebp
	ret 
	
; get_line(input_buffer, bytes_read, bytes_to_read)
get_line:
	.input_buffer = 8h
	.bytes_read = 0ch
	.bytes_to_read = 10h
	
	push	ebp 
	mov		ebp, esp
	
	pusha
	
	mov		ecx, dword [ebp + .bytes_read]
	mov		esi, dword [ebp + .input_buffer]
	
	push	0
	push	ecx 
	push	dword [ebp + .bytes_to_read]
	push	esi 
	push	dword [input_handle]
	call	[ReadFile]
	
	mov		ebx, dword [ebp + .bytes_read]
	
	mov		eax, dword [ebx]
	mov		byte [esi + eax], 0
	dec		eax 
	mov		byte [esi + eax], 0
	dec		eax
	mov		byte [esi + eax], 0
	inc 	eax 

	mov		dword [ebx], eax 

.end_func:
	popa 
	
	pop		ebp 
	ret 
	
; str_to_dec(str_addr)
str_to_dec:
	.str_addr = 8h 
	
	push	ebp
	mov		ebp, esp 
	
	push	10
	push	0
	push	dword [ebp + .str_addr]
	call 	[strtoul]
	add		esp, 4*3 
	
	pop		ebp
	ret 

section '.idata' data import readable 

library kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import	kernel32,\
		ReadFile,'ReadFile',\
		GetStdHandle,'GetStdHandle',\
		ExitProcess,'ExitProcess'
		
import	msvcrt,\
		printf,'printf',\
		strtoul,'strtoul'