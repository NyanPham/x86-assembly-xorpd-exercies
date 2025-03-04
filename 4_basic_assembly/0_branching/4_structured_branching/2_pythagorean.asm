; 2. Write a program that takes the number n as input, and prints back all the
; triples (a,b,c), such that a^2 + b^2 = c^2. 

; These are all the pythagorean triples not larger than n.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call 	read_hex
	mov		cl, al
	
	mov		ch, cl
	mov		bl, cl
	mov		bh, cl
	
	mov		esi, 0

calculate:
	mov		eax, 0			; a^2
	mov		al, ch 
	mul		eax 
	mov		esi, eax
	
	mov		eax, 0
	mov		al, bl
	mul		eax
	add		esi, eax		; a^2 + b^2 
	
	mov		eax, 0
	mov		al, bh
	mul		eax 
	cmp		eax, esi
	
	; a^2 + b^2 != c^2 ?
	jne		skip_print 		
							
	; a^2 + b^2 == c^2:
	mov		eax, 0			
	mov		al, ch
	call	print_eax 
	mov		al, bl
	call	print_eax
	mov		al, bh
	call	print_eax
	
skip_print:
	dec		bh
	jns		calculate
	
	mov		bh, cl 
	dec 	bl
	jns 	calculate
	
	mov		bl, cl
	dec		ch	
	jns		calculate
	

done:
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

