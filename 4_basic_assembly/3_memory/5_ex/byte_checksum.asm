; 2.  Byte checksum.

    ; Create a program that calculates the sum of all its bytes modulo 0x100.
    ; (The program will actually sum itself).

    ; HINT: You can use the ars_poetic exercise (See Read Code section) as a basis
    ; for your program.

format PE console
entry start

include 'win32a.inc' 

start:
	mov 	esi, start 						
	xor 	ebx, ebx 					; ebx, sums of bytes of the whole program
	
next_byte:
	movzx	eax, byte [esi]
	add		ebx, eax 
		
	inc 	esi
	cmp 	esi, end_prog
	jnz 	next_byte
	
	mov 	eax, ebx 
	xor 	edx, edx 
	mov 	ebx, 0x100
	div 	ebx 
		
	mov 	eax, edx 
	call 	print_eax 
		
    ; Exit the process:
	push	0
	call	[ExitProcess]

end_prog:

include 'training.inc'
