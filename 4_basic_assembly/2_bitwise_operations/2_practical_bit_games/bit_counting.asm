; 1.  Bit counting:
    
; Write a program that takes a number (of size 4 bytes) x as input, and then
; counts the amount of "1" bits in even locations inside the number x. We
; assume that the rightmost bit has location 0, and the leftmost bit has a
; location of 31.

; Example:
; if x == {111011011}_2, then we only count the bits with stars under them.
		   ; * * * * *
		   ; 8 6 4 2 0 
; Hence we get the result of 4.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start: 
	call read_hex
	xor ecx,ecx 
	xor ebx,ebx 
	xor edx,edx 
	mov esi,31 
		
count:
	shr eax,1 
	jnc countup
	
	mov edx,ecx 
	and edx,1 
	jnz countup 
	inc ebx 
		
countup:
	inc ecx 
	cmp ecx,esi 
	jnz count 
	
	mov eax,ebx 
	call print_eax 

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
