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
section '.text' code readable executable

start:
	call	read_hex
	mov		ecx, eax

calc:
	cmp		ecx, 0
	jz		end_calc
	shr		ecx, 1
	xor		eax, ecx
	jmp		calc
	
end_calc:
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

