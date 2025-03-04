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

WIDTH = 0x4
HEIGHT = 0x2

section '.bss' readable writeable
	table_a 	dd		WIDTH*HEIGHT dup (?)
	table_b 	dd		HEIGHT*WIDTH dup (?)

	temp		dd		?
section '.text' code readable executable

start:   

	;========================
	; Init table A
	;========================
init_tbl_a:
	mov		esi, table_a
	xor		ebx, ebx		; row
.next_row:
	xor		ecx, ecx		; col 
.next_col:
	mov		eax, ebx
	mov		edx, WIDTH
	mul		edx
	add		eax, ecx
	shl		eax, 2
	lea 	edx, [esi + eax]
	
	lea		eax, [ebx + ecx]
	mov		dword [edx], eax
	
	inc		ecx
	cmp		ecx, WIDTH	
	jb		.next_col
	
	inc		ebx
	cmp		ebx, HEIGHT
	jb		.next_row
	
	;========================
	; Transpose A into B
	;========================
transpose_a_2_b:
	mov		esi, table_a
	mov		edi, table_b
	
	xor		ebx, ebx		; row in a, col in b
.next_row:
	xor		ecx, ecx		; col in a, row in b
.next_col:
	; Get value in table_a 
	mov		eax, ebx
	mov		edx, WIDTH
	mul		edx
	add		eax, ecx
	shl		eax, 2
	lea		edx, [esi + eax]
	mov		eax, dword [edx]
	mov		dword [temp], eax
	
	; Copy the value to table_b
	mov		eax, ecx
	mov		edx, HEIGHT		; Width for table_b
	mul		edx
	add		eax, ebx
	shl		eax, 2
	lea		edx, [edi + eax]
	mov		eax, dword [temp]
	mov		dword [edx], eax
	
	inc		ecx
	cmp		ecx, WIDTH
	jb		.next_col
	
	inc		ebx
	cmp		ebx, HEIGHT
	jb		.next_row
	
	;========================
	; Print table a
	;========================
print_tbl_a:
	mov		esi, table_a
	xor		ebx, ebx		; row
.next_row:
	xor		ecx, ecx		; col 
.next_col:
	mov		eax, ebx
	mov		edx, WIDTH
	mul		edx
	add		eax, ecx
	shl		eax, 2
	lea 	edx, [esi + eax]
	
	mov		eax, dword [edx]
	call	print_eax
	
	inc		ecx
	cmp		ecx, WIDTH	
	jb		.next_col
	
	call	print_delimiter
	
	inc		ebx
	cmp		ebx, HEIGHT
	jb		.next_row
	
	call	print_delimiter
	
	;========================
	; Print table b
	;========================
print_tbl_b:
	mov		esi, table_b
	xor		ebx, ebx		; row
.next_row:
	xor		ecx, ecx		; col 
.next_col:
	mov		eax, ebx
	mov		edx, HEIGHT
	mul		edx
	add		eax, ecx
	shl		eax, 2
	lea 	edx, [esi + eax]
	
	mov		eax, dword [edx]
	call	print_eax
	
	inc		ecx
	cmp		ecx, HEIGHT
	jb		.next_col
	
	call	print_delimiter
	
	inc		ebx
	cmp		ebx, WIDTH
	jb		.next_row

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
