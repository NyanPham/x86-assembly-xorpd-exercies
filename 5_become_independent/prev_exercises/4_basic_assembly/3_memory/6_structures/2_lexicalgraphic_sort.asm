; 2.  Lexicographic sort.

    ; We define the lexicographic order as follows:
    ; For every two points (a,b), (c,d), we say that (a,b) < (c,d) if:

    ; (a < c) or (a = c and b < d)

    ; This order is similar to the one you use when you look up words in the
    ; dictionary. The first letter has bigger significance than the second one,
    ; and so on.
    
    ; Examples:

      ; (1,3) < (2,5)
      ; (3,7) < (3,9)
      ; (5,6) = (5,6)

    ; Write a program that takes 6 points as input (Two coordinates for each
    ; point), and prints a sorted list of the points, with respect to the
    ; lexicographic order.


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

struct Point
	x 	dd	?
	y	dd 	?
ends 

section '.data' data readable writeable 
	enter_x 				db 	'X coordinate: ',0
	enter_y 				db 	'Y coordinate: ',0
	coord					db	'(%d, %d)',13,10,0

	input_coord				db	'Point %d',13,10,0
	line_break				db	13,10,0
	
	sorted_points_result	db	'Sorted points array is: ',13,10,0
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	points			Point 	?
					Point 	?
					Point 	?
					Point 	?
					Point 	?
					Point 	?
	points_len = ($ - points) / sizeof.Point
		
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
		
	push	points_len
	push	points 
	call	populate_points 
	add		esp, 4*2
	
	push	points_len
	push	points 
	call	lexical_sort_points 
	add		esp, 4*2
	
	push	sorted_points_result
	call	[printf]
	add		esp, 4
		
	push	points_len
	push	points 
	call	print_points 
	add		esp, 4*2
			
.end_prog:	
	push	0
	call	[ExitProcess]
	


;lexical_sort_points(points_addr, points_len)
lexical_sort_points:
	.points_addr = 8h
	.points_len = 0ch
	
	push	ebp 
	mov		ebp, esp
	
	pusha 
	
	mov		esi, dword [ebp + .points_addr]
	mov		ecx, dword [ebp + .points_len]
	
.sort_loop_setup:
	dec 	ecx 
	jz		.end_func
	xor		ebx, ebx
	push	ecx 
	
.sort_loop:	
	lea		edi, dword [esi + sizeof.Point*ebx]
	lea		edx, dword [esi + sizeof.Point*ebx + sizeof.Point]
	
	mov		eax, dword [edi + Point.x]
	cmp		eax, dword [edx + Point.x]
	jl		.next_iter
	jg		.swap_points 

.compare_y: 			; if point1.x == point2.x , compare their Y values
	mov		eax, dword [edi + Point.y]
	cmp		eax, dword [edx + Point.y]
	jg		.swap_points
	jmp		.next_iter
	
.swap_points:
	push	dword [edi + Point.y]
	push	dword [edi + Point.x]
		
	mov		eax, dword [edx + Point.x]
	mov		dword [edi + Point.x], eax
	mov		eax, dword [edx + Point.y]
	mov		dword [edi + Point.y], eax 
		
	pop		eax
	mov		dword [edx + Point.x], eax 
	pop		eax 
	mov		dword [edx + Point.y], eax 
	
.next_iter:
	inc		ebx 
	dec		ecx 
	jnz		.sort_loop
	
	pop		ecx
	cmp		ecx, 0
	jnz		.sort_loop_setup
	
.end_func:
	popa 
	pop		ebp 
	ret 
	
;print_points(points_addr, points_len)
print_points:
	.points_addr = 8h
	.points_len = 0ch
		
	push	ebp 
	mov		ebp, esp
	
	pusha 
	
	mov		esi, dword [ebp + .points_addr]
	mov		ecx, dword [ebp + .points_len]
	xor		ebx, ebx 

.construct_loop:
	lea		edi, dword [esi + sizeof.Point*ebx]
			
	push	edi
	call	print_point
	add		esp, 4
	
	inc		ebx 
	dec		ecx 
	jnz		.construct_loop
	
.end_func:
	popa 
	pop		ebp 
	ret 
	
;populate_points(points_addr, points_len)
populate_points:
	.points_addr = 8h
	.points_len = 0ch
	
	push	ebp 
	mov		ebp, esp
	
	pusha 
	
	mov		esi, dword [ebp + .points_addr]
	mov		ecx, dword [ebp + .points_len]
	xor		ebx, ebx 

.construct_loop:
	lea		edi, dword [esi + sizeof.Point*ebx]

	inc		ebx 
	pusha 
	push	ebx 
	push	input_coord
	call	[printf]
	add		esp, 4*2 
	popa 
	
	push	edi
	call	construct_point
	add		esp, 4
	
	dec		ecx 
	jnz		.construct_loop
	
.end_func:
	popa 
	pop		ebp 
	ret 

;print_point(struct_point_addr)
print_point:
	.struct_point_addr = 8h
	
	push	ebp
	mov		ebp, esp
	
	pusha 
		
	mov		esi, dword [ebp + .struct_point_addr]
	mov		eax, dword [esi + Point.x]
	mov		ebx, dword [esi + Point.y]
		
	push	ebx 
	push	eax
	push 	coord
	call	[printf]
	add		esp, 4*3 
	
.end_func:
	popa 

	pop		ebp 
	ret 
	

; construct_point(struct_point_addr)
construct_point:
	.struct_point_addr = 8h
	
	push	ebp 
	mov		ebp, esp
	
	pusha 
	
	mov		edi, dword [ebp + .struct_point_addr]
		
	push	enter_x
	call	get_num
	add		esp, 4
	
	mov		dword [edi + Point.x], eax
		
	push	enter_y
	call	get_num
	add		esp, 4
	
	mov		dword [edi + Point.y], eax

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