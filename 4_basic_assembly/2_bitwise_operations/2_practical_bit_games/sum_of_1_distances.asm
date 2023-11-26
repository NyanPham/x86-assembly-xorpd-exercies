; 3.  Sum of distances:
    
; For a binary number x, we define the "sum of 1 distances" to be the sum of
; distances between every two "1" bits in x's binary representation.

; Small example (8 bits):

  ; x = {10010100}_2
	   ; 7  4 2
  
  ; The total sum of distances: (7-4) + (7-2) + (4-2) = 3 + 5 + 2 = 10


; Create a program that takes a number x (of size 4 bytes) as input, and
; outputs x's "sum of 1 distances".

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start: 
	call read_hex 
	mov ecx,0 
	xor ebx,ebx 
		
next_bit:
	shr eax,1 
	jnc countdown
	
	mov edx,eax 
	mov esi,ecx 
	inc esi 
	
sum_distances:
	shr edx,1 
	jnc next_sum
	
	mov edi,esi 
	sub edi,ecx 
	add ebx,edi 
			
next_sum:
	inc esi
	cmp esi, 32d
	jnz sum_distances

countdown:
	inc ecx
	cmp ecx, 32d
	jnz next_bit

	mov eax,ebx 
	call print_eax

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
