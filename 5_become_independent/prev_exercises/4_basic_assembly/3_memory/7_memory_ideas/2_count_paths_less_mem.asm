; 2.  Count paths.

    ; 2.5   Bonus: Could you find out num_paths(N-1,N-1) with less memory?
          ; Currently we use about O(N^2) dwords of memory. Could you do it with
          ; about O(N) dwords of memory?
	
    ; 2.6*  Bonus: Could you calculate the number num_paths(N-1,N-1) without using
          ; the computer at all?
		
	; Plan:	
		; Instead of creating the whole matrix, create only 2 rows and work all the 
		; way down to the Nth row.
		

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
	path_row_1		dd 	MAP_SIZE	dup (?)
	path_row_2		dd 	MAP_SIZE	dup (?)
	
	path_row_1_ptr 	dd 	path_row_1
	path_row_2_ptr 	dd 	path_row_2
	
section '.text' code readable executable 

start:	
	push 	line_brk
	call	[printf]
	add		esp, 4
	
	push	computing_cell
	call	[printf]
	add		esp, 4 	
	
	push	MAP_SIZE 
	push	MAP_SIZE 
	push	path_row_2_ptr
	push	path_row_1_ptr
	call	compute_num_paths
	add		esp, 4*4
	
	push	MAP_SIZE
	push	MAP_SIZE-1
	push	path_row_1_ptr
	call	get_row_cell_value
	add		esp, 4*3 
		
	push	eax 
	push	result_is
	call	[printf]
	add		esp, 4*2
		
	push	0
	call	[ExitProcess]

; get_row_cell_value(path_row_addr, index, width)
get_row_cell_value:
	.path_row_addr = 8h
	.index = 0ch
	.width = 10h
	
	push 	ebp 
	mov		ebp, esp 
	
	push	esi
	push	ebx 
	
	mov		esi, dword [ebp + .path_row_addr]
	mov		esi, dword [esi]
	mov		ebx, dword [ebp + .index]
	cmp		ebx, dword [ebp + .width] 
	jge		.invalid_index	
		
	mov		eax, dword [esi + ebx*4]
	jmp		.end_func
	
.invalid_index:
	mov		eax, -1 
	
.end_func:
	pop		ebx
	pop		esi

	pop		ebp
	ret 

; print_num_path_row(path_row_addr, width)
print_num_path_row:
	.path_row_addr = 8h
	.width = 0ch
		
	push	ebp
	mov		ebp, esp
	
	pusha
	
	mov		esi, dword [ebp + .path_row_addr]
	mov		esi, dword [esi]		
	mov		ecx, dword [ebp + .width]
	xor		ebx, ebx

.print_cell_loop:
	mov		eax, dword [esi + ebx*4]
	pusha 
	push	eax 
	push	ebx 
	push	0
	push 	cell_value
	call	[printf]
	add		esp, 4*4
	popa 	
	
	inc		ebx 
	dec		ecx 
	jnz		.print_cell_loop
	
.end_func:
	popa 
	pop		ebp
	ret 

; compute_num_paths(path_row_1_ptr, path_row_2_ptr, width, height)
compute_num_paths:
	.path_row_1_ptr = 8h
	.path_row_2_ptr = 0ch
	.width = 10h
	.height = 14h
	
	push	ebp 
	mov		ebp, esp 
	
	pusha 
		
	mov		esi, dword [ebp + .path_row_1_ptr]
	mov		edi, dword [ebp + .path_row_2_ptr]
	xor 	ebx, ebx 
	xor		ecx, ecx 
	
	;====================================
	; Initialize the first row to be 1
	;====================================
.first_row_loop:
	mov		eax, dword [esi]
	
	mov		dword [eax + ecx*4], 1
	inc		ecx 
	cmp		ecx, dword [ebp + .width]
	jnz 	.first_row_loop 
	
	inc		ebx
	xor		ecx, ecx 
.compute_loop:
	push	esi
	push	edi 
	call	swap_num_path_rows
	add		esp, 4*2
	
	;=============================================
	; If the cell is the leftmost one, set it to 1
	;=============================================
	test	ecx, ecx 
	jnz 	.compute_cell
	
	mov		eax, dword [esi]
	mov		dword [eax + ecx*4], 1
	jmp		.next_iter 
	
.compute_cell:
	sub		esp, 4						; local x  
		
	mov		eax, dword [edi]
	mov		eax, dword [eax + ecx*4]	; eax = (i-1, j)
	mov		dword [ebp - 4], eax 		; local x = previous row value at the current index
	
	dec 	ecx 
	mov		eax, dword [esi]
	mov		eax, dword [eax + ecx*4]	; eax = (i, j - 1)
	add 	eax, dword [ebp - 4]
	mov		dword [ebp - 4], eax 		; local x = (i-1, j) + (i, j - 1)
	
	inc		ecx 
	mov		eax, dword [esi]
	mov		edx, dword [ebp - 4]
	mov		dword [eax + ecx*4], edx 
	
	add		esp, 4 
	
.next_iter:
	inc		ecx 
	cmp		ecx, dword [ebp + .width]
	jnz		.compute_cell
	
	xor		ecx, ecx
	
	inc		ebx 
	cmp		ebx, dword [ebp + .height]
	jnz		.compute_loop
	
	popa 
.end_func:
	pop		ebp
	ret 
	
	
; swap_num_path_rows(num_path_row_1_ptr, num_path_row_2_ptr)
swap_num_path_rows:
	.num_path_row_1_ptr = 8h 
	.num_path_row_2_ptr = 0ch
	
	push	ebp
	mov		ebp, esp
	
	pusha
	
	mov		esi, dword [ebp + .num_path_row_1_ptr]
	mov		edi, dword [ebp + .num_path_row_2_ptr]
	
	push	dword [esi]
	push	dword [edi] 
	
	pop		dword [esi] 
	pop 	dword [edi]
	
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

