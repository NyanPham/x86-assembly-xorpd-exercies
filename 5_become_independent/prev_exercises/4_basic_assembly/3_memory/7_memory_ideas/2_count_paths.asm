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
	
INPUT_BUFFER_MAX_LEN = 20h

MAP_SIZE = 5h
	
section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	cell_value		db 	'(%d, %d): %d',13,10,0
	input_value		db	'Test value: %d',13,10,0
		
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	num_paths 		dd	MAP_SIZE*MAP_SIZE 		dup (?) 
	
	PATH_LENTH = ($ - num_paths) / 4
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
		
	push	MAP_SIZE 
	push	MAP_SIZE 
	push	num_paths
	call	initialize_num_paths
	add		esp, 4*3
		
	push	MAP_SIZE 
	push	MAP_SIZE 
	push	num_paths
	call	print_map
	add		esp, 4*3
		
	push	0
	call	[ExitProcess]
	
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
	mov		edi, eax 
	mov		dword [esi + edi*4], 0 
	
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
	
; print_map(num_paths_addr, width, height) 
print_map:
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

