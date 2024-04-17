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
;
;
;
; 		   Index	0	1	2	3	4
;			
;			0		1	1	1	1	1
;			1		1	2	3	4	5
;			2		1	3	6	10	15
;			3		1	4	10	20	35
;			4		1	5	15	35	70
;
;
;			A num_paths of size 5*5, should have the result of 70
; 

format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

MAP_SIZE = 5h
	
section '.data' data readable writeable 
	cell_value		db 	'(%d, %d): %d',13,10,0
	computing_cell	db	'Computing cell values...',13,10,0
	result_is 		db 	'The num paths from S to E is: %d',13,10,0
	line_brk		db	'',13,10,0
	
section '.bss' readable writeable
	num_paths 		dd	MAP_SIZE*MAP_SIZE 		dup (?) 
	
section '.text' code readable executable 

start:	
	push 	line_brk
	call	[printf]
	add		esp, 4

	push	MAP_SIZE 
	push	MAP_SIZE 
	push	num_paths
	call	initialize_num_paths
	add		esp, 4*3
	
	push	computing_cell
	call	[printf] 
	add 	esp, 4
	
	push	MAP_SIZE 
	push	MAP_SIZE 
	push	num_paths
	call	print_num_paths
	add		esp, 4*3
	
	push 	line_brk
	call	[printf]
	add		esp, 4
	
	push	MAP_SIZE
	push	MAP_SIZE
	push	MAP_SIZE-1
	push	MAP_SIZE-1 
	push	num_paths
	call	get_num_paths_cell_value
	add 	esp, 4*5
	
	push	eax 
	push 	result_is
	call	[printf]
	add		esp, 4*2
	
	push	0
	call	[ExitProcess]

; get_num_paths_cell_value(num_paths_addr, row_index, column_index, width, height)
get_num_paths_cell_value:
	.num_paths_addr = 8h
	.row_index = 0ch
	.column_index = 10h
	.width = 14h
	.height = 18h
	
	push	ebp
	mov		ebp, esp
	
	push	ebx
	push	ecx 
	push	edx 
	push	esi
	
	mov 	esi, dword [ebp + .num_paths_addr]
	mov		ebx, dword [ebp + .row_index]
	mov		ecx, dword [ebp + .column_index]
	
	cmp		ebx, dword [ebp + .height] 
	jge 	.invalid_index
	
	cmp		ecx, dword [ebp + .width]
	jge		.invalid_index 
	
	mov		eax, dword [ebp + .width]
	mul		ebx 
	add 	eax, ecx 
	mov		edx, eax 
	mov		eax, dword [esi + edx*4]
	jmp		.end_func
	
.invalid_index:
	mov		eax, -1 
	
.end_func:
	pop		esi
	pop		edx 
	pop		ecx 
	pop		ebx 

	pop		ebp
	ret 
		
	
; initialize_num_paths(num_paths_addr, width, height) 
initialize_num_paths:
	.num_paths_addr = 8h
	.width = 0ch
	.height = 10h
	
	push	ebp
	mov		ebp, esp
	
	pusha 
	
	mov		esi, dword [ebp + .num_paths_addr]
	
	xor		ebx, ebx
	xor		ecx, ecx 
	
.init_next_row:
	xor		ecx, ecx 
	
.init_next_cell:
	mov		eax, dword [ebp + .width]
	mul		ebx
	add		eax, ecx 
	mov		edi, eax 						; edi = index of current cell
	
	;===================================================
	; If the cell is in the top row the leftmost column
	;===================================================
	xor		eax, eax 
	
	test	ebx, ebx
	jnz 	.check_if_leftmost_col
	mov		eax, 1
	jmp 	.set_cell_value
	
.check_if_leftmost_col:
	test	ecx, ecx
	jnz		.compute_path
	mov		eax, 1 
	jmp 	.set_cell_value
		
.compute_path:
	;======================================================
	; The cell is neither in the top row or leftmost column
	; Compute the path with forumula:
	; num_paths(i,j) <-- num_paths(i-1,j) + num_paths(i,j-1)
	;======================================================
	
	sub		esp, 4						; local_sum
	
	dec 	ebx							; i - 1
	mov		eax, dword [ebp + .width]
	mul		ebx
	add		eax, ecx
	mov		edi, eax 					; edi = index of (i-1, j)
	mov		eax, dword [esi + edi*4]
	mov		dword [ebp - 4], eax 
	
	inc		ebx							; i restored
	dec		ecx							; j - 1
			
	mov		eax, dword [ebp + .width]
	mul		ebx
	add		eax, ecx
	mov		edi, eax 					; edi = index of (i, j - 1)
	mov		eax, dword [esi + edi*4]
	add 	eax, dword [ebp - 4]	
	mov		dword [ebp - 4], eax		; local_sum = num_paths(i-1,j) + num_paths(i,j-1)
	
	inc		ecx							; j restored
	mov		eax, dword [ebp + .width]
	mul		ebx 
	add 	eax, ecx 
	mov		edi, eax 
	mov		eax, dword [ebp - 4]
	
	add		esp, 4 
	
.set_cell_value:
	mov		dword [esi + edi*4], eax
	
	inc		ecx 
	cmp		ecx, dword [ebp + .width]
	jnz		.init_next_cell
	
	inc		ebx
	cmp		ebx, dword [ebp + .height]
	jnz		.init_next_row
		
.end_func:
	popa 
	pop		ebp
	ret 
	
; print_num_paths(num_paths_addr, width, height) 
print_num_paths:
	.num_paths_addr = 8h
	.width = 0ch
	.height = 10h
		
	push	ebp
	mov		ebp, esp
	pusha 
		
	mov		esi, dword [ebp + .num_paths_addr]
	xor		ebx, ebx
	xor		ecx, ecx 
	
.init_next_row:
	xor		ecx, ecx 

.init_next_cell:
	mov		eax, dword [ebp + .width]
	mul		ebx
	add		eax, ecx 
	mov		edi, eax 
	mov		eax, dword [esi + edi*4]
	
	pusha 
	
	push	eax
	push	ecx 
	push	ebx 
	push	cell_value 
	call	[printf]
	add		esp, 4*4
	popa 
	
	inc		ecx 
	cmp		ecx, dword [ebp + .width]
	jnz		.init_next_cell
	
	inc		ebx
	cmp		ebx, dword [ebp + .height]
	jnz		.init_next_row
	
		
.end_func:
	popa 
	pop		ebp
	ret 

section '.idata' data import readable 

library kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import	kernel32,\
		ExitProcess,'ExitProcess'
		
import	msvcrt,\
		printf,'printf'

