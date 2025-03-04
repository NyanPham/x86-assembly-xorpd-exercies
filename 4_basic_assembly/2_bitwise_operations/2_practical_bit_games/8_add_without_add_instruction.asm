; 8.  Bonus: Addition using bitwise operations.

    ; 8.0   You are given two bits a,b. Show that their arithmetic sum is of the
          ; form (a AND b, a XOR b).
		
          ; Example:
	
          ; 1 + 0 = 01
          ; And indeed: 0 = 1 AND 0, 1 = 1 XOR 0.

	
    ; 8.1   Write a program that gets as inputs two numbers x,y (Each of size 4
          ; bytes), and calculates their arithmetic sum x+y using only bitwise
          ; instructions. (ADD is not allowed!).

          ; HINT: Try to divide the addition into 32 iterations.
                ; In each iteration separate the immediate result and the carry
                ; bits that are produced from the addition.


format PE console
entry start

include 'win32a.inc' 
	
; ===============================================

section '.text' code readable executable
	
start: 
	call read_hex 
	mov ebx,eax 			; ebx = a 
	call read_hex 
	mov esi,eax 			; esi = b 
		
	mov ecx, 32d			; 32 bit iterations
next_bit:
	mov edx,ebx				;
	xor ebx,esi 			; ebx stores the XOR result 
	and esi,edx 			; esi stores the and 
	shl esi,1
		
	dec ecx
	jnz next_bit 
		
done:
	mov eax,ebx 
	call print_eax

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
