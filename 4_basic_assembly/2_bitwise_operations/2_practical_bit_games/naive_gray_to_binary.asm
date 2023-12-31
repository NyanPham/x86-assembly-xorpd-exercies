; 7.  Bonus: Convert Gray into binary.
    
    ; In the "Gray" Exercise at the code reading section, we have learned that in
    ; order to find the Gray code of a number x, we should shift the number x by
    ; 1, and xor the result with the original x value.

    ; In high level pseudo code: 
      ; (x >> 1) XOR x.

    ; In assembly code:
      ; mov   ecx,eax
      ; shr   ecx,1
      ; xor   eax,ecx


    ; Find a way to reconstruct x from the expression (x >> 1) XOR x.
    ; Write a program that takes a gray code g as input, and returns the
    ; corresponding x such that g = (x >> 1) XOR x.

    ; NOTE that You may need to use a loop in your program.

format PE console
entry start

include 'win32a.inc' 
	
; ===============================================

; ===============================================
; The code below is my naive implemetation of 
; converting Gray code to Binary.
; ===============================================
; Better way:
; xor temp with shr number until shr num is zero.
; code:
; start:
;
;    call    read_hex
;    mov     ecx,eax
;  
;calculate:
;    cmp     ecx,0
;    je      done
;    shr     ecx,1
;    xor     eax,ecx
;    jmp     calculate
;
;done:
;    call    print_eax
; ===============================================

section '.text' code readable executable
	
start: 
	call read_hex 
	xor edx,edx 
	cmp eax,0
	jz Done

	mov ebx,eax 
	mov esi,eax 
			
	; First get the position of the first 1 from left
	; ecx  stores the bit displace from left to right 
	mov ecx,0
shift_bit:
	shl ebx,1
	jc one_found 
	
	inc ecx 
	cmp ecx, 32d
	jnz shift_bit
	jmp Done
	
	; insert 1 to the Most significant bit of edx
	; and right shift ecx times 
one_found:
	mov edx,0
	or edx,0x80000000
	shr edx,cl  
	
	; Loops from this and calculate until reach the gray code 

calculate:
	inc edx

	mov ecx,edx 
	shr ecx,1
	xor ecx,edx 
			
	cmp esi, ecx 
	jnz calculate
			
Done:
	mov eax,edx 
	call print_eax 
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
