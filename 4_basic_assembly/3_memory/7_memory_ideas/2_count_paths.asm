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

TBL_SIZE = 0x5

section '.bss' readable writeable
	num_paths 	dd		TBL_SIZE*TBL_SIZE  dup  (?)
	temp1		dd		?
	temp2		dd		?
    
section '.text' code readable executable

start:
    
	;======================================
	; Initialize num paths table
	;======================================
init_tbl:
	mov		edi, num_paths
	xor		ecx, ecx
.next_cell:
	; Cell on top
	lea		edx, [edi + 4*ecx]
	mov		dword [edx], 0x1
	
	mov		eax, ecx
	mov		edx, TBL_SIZE
	mul		edx
	shl		eax, 2
	lea		edx, [edi + eax]
	
	mov		dword [edx], 0x1
	
	inc		ecx
	cmp		ecx, TBL_SIZE
	jb		.next_cell
	
	;======================================
	; Populate num paths table
	;======================================
populate_tbl:
	mov		edi, num_paths
	mov		ebx, 0x1
.next_row:
	mov		ecx, 0x1
.next_col:
	; Get num_paths(i-1,j)
	mov		eax, TBL_SIZE
	mov		edx, ebx 
	dec		edx
	mul		edx
	add		eax, ecx
	shl		eax, 0x2
	mov		eax, dword [edi + eax]
	mov		dword [temp1], eax
	
	; Get num_paths(i,j-1)
	mov		eax, TBL_SIZE
	mul		ebx
	mov		edx, ecx
	dec		edx
	add		eax, edx
	shl		eax, 0x2
	mov		eax, dword [edi + eax]
	mov		dword [temp2], eax
	
	; Compute num_paths(i,j)
	mov		eax,  TBL_SIZE
	mul		ebx
	add		eax, ecx
	shl		eax, 0x2
	mov		edx, eax
	mov		eax, dword [temp1]
	add		eax, dword [temp2]
	mov		dword [edi + edx], eax
	
	inc		ecx
	cmp		ecx, TBL_SIZE
	jb		.next_col
	
	inc		ebx
	cmp		ebx, TBL_SIZE
	jb		.next_row
	
	;======================================
	; Print last cell
	;======================================
	mov		esi, num_paths
	mov		ebx, TBL_SIZE-1
	mov		ecx, TBL_SIZE-1
	
	mov		eax, TBL_SIZE
	mul		ebx
	add		eax, ecx
	shl		eax, 0x2
	mov		eax, dword [esi + eax]
	call	print_eax

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
