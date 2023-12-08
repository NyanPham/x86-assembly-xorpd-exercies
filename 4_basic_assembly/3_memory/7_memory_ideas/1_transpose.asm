; 1.  Transpose.
		
    ; 1.0   Create a new program. Add a two dimensional table A (of dwords) in the
          ; bss section of your program, of sizes: HEIGHT X WIDTH. Initialize cell
          ; number A(i,j) (Row number i, column number j) with the number i+j.
			
          ; Print some cells of the table A to make sure that your code works
          ; correctly.

    ; 1.1   Add another table B to your bss section, with dimensions WIDTH X
          ; HEIGHT. (Note that this table has different dimensions!)

          ; Then add a piece of code that for every pair i,j: Stores A(i,j) into
          ; B(j,i). 

          ; In another formulation:
          ; B(j,i) <-- A(i,j) for every i,j.

          ; Example:

            ; Original A table:
            
              ; 0 1 2 3
              ; 1 2 3 4

            ; Resulting B table:

              ; 0 1
              ; 1 2
              ; 2 3
              ; 3 4
	
    ; 1.2   Print some cells of table A and table B to make sure that your code
          ; works correctly.



format PE console 
entry start 

include 'win32a.inc'

WIDTH = 4
HEIGHT = 2
	
section '.bss' readable writeable
	table_a 	dd 		WIDTH * HEIGHT 		dup 	(?)
	table_b		dd 		HEIGHT * WIDTH 		dup 	(?)
	
section '.text' code readable executable 

start:
	mov		esi, table_a 
	xor		ebx, ebx 			; ebx = row counter 

row_loop_a:
	xor		ecx, ecx 			; ecx = column counter 
column_loop_a:
	mov 	eax, ebx 
	add		eax, ecx 
	mov 	dword [esi], eax 
	
	add		esi, 4
	inc		ecx 
	cmp		ecx, WIDTH
	jnz 	column_loop_a
		
	inc		ebx 
	cmp		ebx, HEIGHT
	jnz 	row_loop_a 
	
	;=========================
	; Transpose matrix
	;=========================
	mov		esi, table_a
	mov		edi, table_b 
	xor 	ebx, ebx 
row_loop_b:
	xor		ecx, ecx 
column_loop_b:
	mov		eax, ecx
	mov		edx, WIDTH * 4
	mul		edx 
	mov		edx, ebx 
	shl		edx, 2
	add		eax, edx 	
	
	mov		eax, dword [esi + eax]
	mov		dword [edi], eax
		
	add		edi, 4
	inc		ecx
	cmp		ecx, HEIGHT
	jnz 	column_loop_b
		
	inc		ebx 
	cmp		ebx, WIDTH 
	jnz 	row_loop_b
	
	;=========================
	; Print Test A
	;=========================
	xor		ecx, ecx 
	mov		ebx, HEIGHT * WIDTH
	mov		esi, table_a
print_next_a:	
	mov		eax, [esi + ecx * 4]
	call	print_eax 
	inc		ecx 
	cmp		ecx, ebx 
	jnz 	print_next_a
	
	;=========================
	; Print Test B
	;=========================
	xor		ecx, ecx 
	mov		ebx, HEIGHT * WIDTH
	mov		esi, table_b
print_next_b:
	mov		eax, [esi + ecx * 4]
	call	print_eax 
	inc		ecx 
	cmp		ecx, ebx 
	jnz 	print_next_b 
		
	push 	0
	call	[ExitProcess]

include 'training.inc'