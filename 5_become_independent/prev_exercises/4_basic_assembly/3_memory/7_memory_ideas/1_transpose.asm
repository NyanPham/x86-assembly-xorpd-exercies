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


; Results:
; 		TABLE A (3x5)
;		0	1	2	3	4
;		1	2	3	4	5
;		2	3	4	5	6

; 		TABLE B (5x3)
;		0	1	2
;		1	2	3
;		2	3	4
;		3	4	5
;		4	5	6

format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h
HEIGHT = 3h
WIDTH = 5h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	pair_value		db	'(%d, %d): %d',13,10,0
	line_break		db 	13,10,0
	
	table_a_is		db 	'Table A values are: ',13,10,0
	table_b_is		db 	'Table B values are: ',13,10,0
	
	table_a			dd 	HEIGHT*WIDTH 	dup 	(?)
	table_b			dd 	WIDTH*HEIGHT 	dup 	(?)				; WIDTH * HEIGHT = HEIGHT * WIDTH, 
																;	just to show they have different dimensions
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	; Initialize Table A
	push	HEIGHT
	push	WIDTH 
	push	table_a
	call	initialize_table
	add		esp, 4*3
	
	; Print Table A 
	push	table_a_is
	call	[printf]
	add		esp, 4
	
	push	HEIGHT
	push	WIDTH 
	push	table_a
	call	print_table
	add		esp, 4*3
	
	; Transpose Table A, out in Table B
	push	WIDTH
	push	HEIGHT
	push	table_b
	push	HEIGHT
	push	WIDTH 
	push	table_a
	call	transpose_table
	add 	esp, 4*6
	
	push	line_break
	push	[printf]
	add		esp, 4*2
	
	; Print Table B 
	push	table_b_is
	call	[printf]
	add		esp, 4
	
	push	WIDTH
	push	HEIGHT 
	push	table_b
	call	print_table
	add		esp, 4*3
	
	push	0
	call	[ExitProcess]


; initialize_table(table_addr, table_width, table_height)
initialize_table:
	.table_addr = 8h
	.table_width = 0ch
	.table_height = 10h

	push	ebp 
	mov		ebp, esp
	
	pusha
	
	mov		esi, dword [ebp + .table_addr]			; esi = address of the table 	
	xor		ebx, ebx								; ebx = row counter 
	xor		ecx, ecx								; ecx = column counter 
		
.next_row:
	mov		ecx, 0 
.next_cell:
	mov		edi, dword [ebp + .table_width]			; edi = row width
	mov		eax, ebx								; eax = current row number  
	mul		edi										; eax = row offset = row number*row width -> in contiguous memory 
	mov		edi, eax								; store the offset in edi 
	add 	edi, ecx 								; edi = row offset + cell offset -> index of current cell in contiguous memory
	
	mov		eax, ebx								; eax = i 
	add		eax, ecx 								; eax = i + j 
	mov		dword [esi + 4*edi], eax 				
		
	inc 	ecx 
	cmp		ecx, dword [ebp + .table_width]
	jnz		.next_cell
	
	inc		ebx
	cmp		ebx, dword [ebp + .table_height]
	jnz		.next_row
	
.end_func:
	popa 
	
	pop		ebp 
	ret 

; transpose_table(source_addr, source_width, source_height, target_addr, target_width, target_height)
transpose_table:
	.source_addr = 8h
	.source_width = 0ch
	.source_height = 10h
			
	.target_addr = 14h
	.target_width = 18h
	.target_height = 1ch
	
	push	ebp
	mov		ebp, esp 
	
	pusha
	
	;==============================================
	;	Check if the transpose dimensions matched
	;==============================================
	mov		eax, dword [ebp + .source_width]				
	cmp		eax, dword [ebp + .target_height]
	jne		.end_func
	
	mov		eax, dword [ebp + .source_height]
	cmp		eax, dword [ebp + .target_width]
	jne		.end_func
	
	mov		esi, dword [ebp + .source_addr]
	mov		edi, dword [ebp + .target_addr]
	xor		ebx, ebx 
	xor		ecx, ecx 
	
.transpose_next_row:
	xor		ecx, ecx 
	
.transpose_next_cell:
	sub		esp, 4 								; x = local var to store the value at index in source

	;===============================================================
	;	Compute the index in source based on row and column counters
	;===============================================================
	mov		edx, dword [ebp + .source_width]
	mov		eax, ebx
	mul		edx 
	add		eax, ecx 
	mov		edx, eax 							; edx = index of element in source table
	
	;===============================================================
	;	Store the value in x (local var)
	;===============================================================
	mov		eax, dword [esi + 4*edx]	
	mov		dword [ebp - 4], eax 				; x = i + j
	
	;===============================================================
	;	Compute the index in target based on row and column counters
	;===============================================================
	mov		edx, dword [ebp + .target_width]
	mov		eax, ecx 
	mul 	edx 
	add 	eax, ebx 
	mov		edx, eax 
	
	;=====================================================================
	;	Retrieve the value from x and store it to target at computed index
	;=====================================================================
	mov		eax, [dword ebp - 4]
	mov		dword [edi + 4*edx], eax 
		
	add 	esp, 4 
			
	inc		ecx
	cmp		ecx, dword [ebp + .source_width]
	jnz		.transpose_next_cell
	
	inc		ebx
	cmp		ebx, dword [ebp + .source_height]
	jnz		.transpose_next_row
	
.end_func:
	popa 
	
	pop 	ebp 
	ret 


; print_table(table_addr, table_width, table_height)
print_table:
	.table_addr = 8h
	.table_width = 0ch
	.table_height = 10h
	
	push	ebp 
	mov		ebp, esp
	
	pusha
	
	mov		esi, dword [ebp + .table_addr]			; esi = address of the table 	
	xor		ebx, ebx								; ebx = row counter 
	xor		ecx, ecx								; ecx = column counter 
	
.next_row:
	mov		ecx, 0 
.next_cell:
	pusha 
	mov		edi, dword [ebp + .table_width]
	mov		eax, ebx
	mul 	edi 
	mov		edi, eax
	add 	edi, ecx 	
		
	push	dword [esi + 4*edi] 
	push	ecx 
	push	ebx
	push	pair_value
	call 	[printf]
	add 	esp, 4*4
	popa 
	
	inc 	ecx 
	cmp		ecx, dword [ebp + .table_width]
	jnz		.next_cell
	
	inc		ebx
	cmp		ebx, dword [ebp + .table_height]
	jnz		.next_row
	
.end_func:
	popa 
	
	pop		ebp 
	ret

; get_num(prompt_addr)
get_num:
	.prompt_addr = 8h
	
	push	ebp 
	mov		ebp, esp 
		
	push	dword [ebp + .prompt_addr]
	call	[printf]
	add		esp, 4 
	
	push	INPUT_BUFFER_MAX_LEN
	push	bytes_read
	push	input_buffer 
	call	get_line
	add		esp, 4*3
	
	push	input_buffer 
	call	str_to_dec
	add		esp, 4
	
	pop		ebp
	ret 

; get_line(input_buffer, bytes_read, bytes_to_read)
get_line:
	.input_buffer = 8h
	.bytes_read = 0ch
	.bytes_to_read = 10h
	
	push	ebp 
	mov		ebp, esp
	
	push	ecx 
	push	esi
	
	mov		ecx, dword [ebp + .bytes_read]
	mov		esi, dword [ebp + .input_buffer]
	
	push	0
	push	ecx 
	push	dword [ebp + .bytes_to_read]
	push	esi 
	push	dword [input_handle]
	call	[ReadFile]
	
	pop		esi 
	pop		ecx 
	
	pop		ebp 
	ret 
	
; str_to_dec(str_addr)
str_to_dec:
	.str_addr = 8h 
	
	push	ebp
	mov		ebp, esp 
	
	push	10
	push	0
	push	dword [ebp + .str_addr]
	call 	[strtoul]
	add		esp, 4*3 
	
	pop		ebp
	ret 

section '.idata' data import readable 

library kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import	kernel32,\
		ReadFile,'ReadFile',\
		GetStdHandle,'GetStdHandle',\
		ExitProcess,'ExitProcess'
		
import	msvcrt,\
		printf,'printf',\
		strtoul,'strtoul'
		