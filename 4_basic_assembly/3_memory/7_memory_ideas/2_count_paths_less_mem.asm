; 2.  Count paths.

    ; 2.5   Bonus: Could you find out num_paths(N-1,N-1) with less memory?
          ; Currently we use about O(N^2) dwords of memory. Could you do it with
          ; about O(N) dwords of memory?
	
    ; 2.6*  Bonus: Could you calculate the number num_paths(N-1,N-1) without using
          ; the computer at all?
		
	; Plan:	
		; Instead of creating the whole matrix, create only 2 rows and work all the 
		; down to the Nth row.

format PE console
entry start

include 'win32a.inc' 

TBL_SIZE = 0x5

section '.bss' readable writeable
	curr_row	dd		TBL_SIZE	dup 	(?)
	prev_row	dd		TBL_SIZE	dup		(?)
	temp1		dd		?
	temp2		dd		?
    
section '.text' code readable executable

start:

	;======================================
	; Initialize num paths table
	;======================================
init_tbl:
	; First row to be all 1
	xor		ecx, ecx
	mov		esi, prev_row
.next_prev_cell:
	mov		dword [esi + 4*ecx], 1
	inc		ecx
	cmp		ecx, TBL_SIZE
	jb		.next_prev_cell
	
	; Second row, first cell is 1
	mov		esi, curr_row
	mov		dword [esi], 1

	;======================================
	; Populate num paths table
	;======================================
populate_tbl:
	mov		esi, prev_row
	mov		edi, curr_row
	
	mov		ecx, 1
	; Compute the curr_row based on prev_row
.compute_row:
	mov		ebx, 1	
.next_cell:
	mov		eax, dword [esi + 4*ebx]
	mov		edx, ebx
	dec		edx
	add		eax, dword [edi + 4*edx]
	mov		dword [edi + 4*ebx], eax
	inc		ebx 
	cmp		ebx, TBL_SIZE
	jb		.next_cell

	; Done compute row, swap rows
	mov		ebx, 1
.swap_cell:
	mov		eax, dword [edi + 4*ebx]
	mov		dword [esi + 4*ebx], eax
	
	inc		ebx 
	cmp		ebx, TBL_SIZE
	jb		.swap_cell

	inc		ecx
	cmp		ecx, TBL_SIZE
	jb		.compute_row	

print_result:
	mov		ecx, TBL_SIZE-1
	mov		eax, dword [edi + 4*ecx]
	call	print_eax


    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
