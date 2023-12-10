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
		
N = 5	
		
section '.bss' readable writeable 
	prev_row 		dd	N dup (?)
	curr_row 		dd 	N dup (?)
	
section '.text' code readable executable
	
start:
	;=================================================
	; Initialize the first row to be one 
	;=================================================
	mov 	esi, prev_row
	mov		ecx, 0
init_first_row:	
	mov 	dword [esi + ecx * 4], 1
	inc 	ecx 
	cmp		ecx, N
	jne		init_first_row
			
	;=================================================;
	; Compute number path to each row
	;=================================================
	mov		ebx, 1
compute_next_row:
	mov		esi, prev_row
	mov		edi, curr_row 
	
	mov		dword [esi], 1d
	mov		dword [edi], 1d
	mov		ecx, 1
compute_next_cell:
	mov		eax, dword [esi + ecx * 4]
	add		eax, dword [edi + ecx * 4 - 4]
	mov		dword [edi + ecx * 4], eax 
	
	inc 	ecx 
	cmp		ecx, N 
	jnz		compute_next_cell 
	
	; Done computing, move the curr_row to prev_row 
	mov		ecx, 1
move_next_cell:
	mov		eax, dword [edi + ecx * 4]
	mov		dword [esi + ecx * 4], eax 
	
	inc		ecx 
	cmp 	ecx, N 
	jnz 	move_next_cell 
		
	inc		ebx 
	cmp		ebx, N 
	jnz 	compute_next_row 
		
	;=================================================
	; Print result test 
	;=================================================
	mov		esi, prev_row
	mov		ecx, N - 1
	mov		eax, dword [esi + ecx * 4]
	call	print_eax 
	
	push	0
	call	[ExitProcess]
	
include 'training.inc'
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
