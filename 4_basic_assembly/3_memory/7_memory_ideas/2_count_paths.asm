; 2.  Count paths.
    
    ; We consider a two dimensional table of size N X N:

      ; +---+---+---+---+
      ; |   |   |   |   |
      ; | S |   |   |   |
      ; |   |   |   |   |
      ; +---+---+---+---+
      ; |   |   |   |   |
      ; |   |   |   |   |
      ; |   |   |   |   |
      ; +---+---+---+---+
      ; |   |   |   |   |
      ; |   |   |   |   |
      ; |   |   |   |   |
      ; +---+---+---+---+
      ; |   |   |   |   |
      ; |   |   |   | E |
      ; |   |   |   |   |
      ; +---+---+---+---+

    ; With two special cells: Start (S) and End (E). Start is the top left cell,
    ; and End is the bottom right cell. 
    
    ; A valid path from S to E is a path that begins with S, ends with E, and
    ; every step in the path could either be in the down direction, or in the
    ; right direction. (Up or left are not allowed).

      ; Example for a valid path: right, right, down, down, right, down:

      ; +---+---+---+---+
      ; |   |   |   |   |
      ; | S-|---|-+ |   |
      ; |   |   | | |   |
      ; +---+---+---+---+
      ; |   |   | | |   |
      ; |   |   | | |   |
      ; |   |   | | |   |
      ; +---+---+---+---+
      ; |   |   | | |   |
      ; |   |   | +-|-+ |
      ; |   |   |   | | |
      ; +---+---+---+---+
      ; |   |   |   | | |
      ; |   |   |   | E |
      ; |   |   |   |   |
      ; +---+---+---+---+

    ; We would like to count the amount of possible valid paths from S
    ; to E.


    ; 2.0   Let T be some cell in the table:

             ; |   |   |
             ; |   |   |
           ; --+---+---+--
             ; |   |   |
             ; |   | R |
             ; |   |   |
           ; --+---+---+--
             ; |   |   |
             ; | Q | T |
             ; |   |   |
           ; --+---+---+--
             ; |   |   |
             ; |   |   |

          ; Prove that the amount of valid paths from S to T equals to the amount
          ; of paths from S to Q plus the amount of paths from S to R.

    ; 2.1   Define a constant N in your program, and create a two dimensional
          ; table of size N X N (of dwords). Call it num_paths. We will use this
          ; table to keep the amount of possible valid paths from S to any cell in
          ; the table.

    ; 2.2   The amount of paths from S to each of the cells in the top row, or the
          ; leftmost column, is 1. 
			
          ; Write a piece of code that initializes all the top row and the
          ; leftmost column to be 1.

    ; 2.3   Write a piece of code that iterates over the table num_paths. For
          ; every cell num_paths(i,j) it will assign:

          ; num_paths(i,j) <-- num_paths(i-1,j) + num_paths(i,j-1)

          ; Note that you should not iterate over the top row and the leftmost
          ; column, because you have already assigned them to be 1.

    ; 2.4   The last cell in num_paths, num_paths(N-1,N-1) contains the amount of
          ; valid paths possible from S to E. 

          ; Add a piece of code to print this number.

format PE console 
entry start

include 'win32a.inc'

N = 5
	
section '.bss' readable writeable 
	temp 			dd 	?
	num_paths		dd  N*N 	dup 	(?)
	
	
section '.text' code readable executable
	
start:
	;=================================================
	; Initialize top row and leftmost column to be 1
	;=================================================
	mov		esi, num_paths
	mov		ecx, 0 
		
init_top_row_cell:
	mov		dword [esi + ecx * 4], 1
	inc 	ecx 
	cmp 	ecx, N 
	jnz 	init_top_row_cell
			
	mov		ecx, 1
init_left_col_cell:
	mov 	eax, ecx 
	shl		eax, 2
	mov		ebx, N
	mul 	ebx
	
	mov 	dword [esi + eax], 1
	
	inc 	ecx
	cmp 	ecx, N
	jnz 	init_left_col_cell 
		
	;=================================================
	; Compute the path num for each cell
	;=================================================
	mov		esi, num_paths
	mov		ebx, 1					; row counter
next_row:
	mov		ecx, 1	 				; column counter
next_cell:	
	; get num paths at coords (i - 1, j)
	dec 	ebx 
	mov		eax, ecx 
	shl		eax, 2
	mov		edi, N
	mul 	edi 
	mov		edi, ebx 
	shl		edi, 2
	add		eax, edi 
	mov		eax, dword [esi + eax]	; temp = num_paths(i - 1, j)
	mov		dword [temp], eax
	inc 	ebx
	
	; get num paths at coords (i, j - 1)
	dec 	ecx
	mov		eax, ecx 
	shl		eax, 2
	mov		edi, N
	mul 	edi 
	mov		edi, ebx 
	shl		edi, 2
	add		eax, edi 	
	mov		eax, dword [esi + eax]		
	inc 	ecx 	
	
	add		eax, dword [temp]		; eax = num_paths(i, j - 1) + num_paths(i - 1, j)
	mov		dword [temp], eax 
	
	mov		eax, ecx 
	shl		eax, 2
	mov		edi, N 
	mul		edi
	mov		edi, ebx 
	shl		edi, 2
	add		eax, edi 
	mov		edi, dword [temp]
	mov 	dword [esi + eax], edi
	
	inc 	ecx 
	cmp 	ecx, N
	jnz		next_cell
		
	inc 	ebx 
	cmp		ebx, N
	jnz 	next_row 
	
	;=====================================
	; Print last cell
	;=====================================
	mov		ebx, N - 1
	mov		ecx, N - 1
	
	mov 	eax, ecx 
	mov		edi, N 
	mul		edi
	shl		eax, 2
	mov		edi, ebx 
	shl		edi, 2
	add		eax, edi
	mov		eax, dword [esi + eax]
	call	print_eax 
		
	;====================
	; Print all cells
	;====================  
	; mov 	ecx, 0 
	; mov 	ebx, N
; print_next:	
	; xor 	edx, edx 
	; mov		eax, ecx 
	; div		ebx 
	; cmp		edx, 0
	; jnz 	not_next_row 
	; call	print_delimiter 
	
; not_next_row:	
	; mov		eax, dword [esi + ecx * 4]
	; call	print_eax 
	; inc 	ecx 
	; cmp 	ecx, N * N 
	; jnz 	print_next
	
	push	0
	call	[ExitProcess]
	
include 'training.inc'
	
	
	
	
	
	
	
	
	
	
	
