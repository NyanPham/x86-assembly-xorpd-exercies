; 0.  Area competition.

    ; For every rectangle R which is parallel to the X and Y axes, we can
    ; represent R using two points.
	
    ; Example:
  
      ; A------------B
      ; |     R      |
      ; |            |
      ; D------------C

      ; We could represent the rectangle in the drawing using the points A(x,y)
      ; and C(x,y) for example. Basically, we need 4 numbers to represent this
      ; kind of rectangle: 2 coordinates for A, and 2 coordinates for C.

      ; I remind you that the area of a rectangle is computed as the
      ; multiplication of its height by its width.


    ; Write a program that takes the coordinates of two rectangles (2 points or 4
    ; dwords for each rectangle), and then finds out which rectangle has the
    ; larger area.

    ; The program then outputs 0 if the first rectangle had the largest area, or 1
    ; if the second rectangle had the largest area. 

    ; In addition, the program prints the area of the rectangle that won the area
    ; competition.
	
; Note: Instead of print 0 or 1, the program would print 'Rect 1 is larger' or 'Rect 2 is larger'

format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

struct Point
	x 	dd	?
	y	dd 	?
ends 

struct Rect
	p_1	Point ?
	p_2 Point ?
ends 

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	
	enter_x 		db 	'X coordinate: ',0
	enter_y 		db 	'Y coordinate: ',0
	
	rect_num		db	'---RECTANGLE %d---',13,10,0
	input_coord		db	'Point %d',13,10,0
	line_break		db	13,10,0
	
	rect_larger		db	'Rectangle %d is larger.',13,10,0
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	rect1			Rect ?
	rect2			Rect ?
	
	area_1 			dd	?
	area_2 			dd	? 
		
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	; Constructing Rect 1 
	
	push	1 
	push	rect_num
	call	[printf]
	add		esp, 4*2
	
	push	rect1 
	call	construct_rect
	add		esp, 4
	
	push	line_break
	call	[printf]
	add		esp, 4
	; Constructing Rect 2 	
	
	push	2
	push	rect_num
	call	[printf]
	add		esp, 4*2
	
	push	rect2 
	call	construct_rect
	add		esp, 4
	
	; Computing area of Rect 1 
	push	rect1 
	call	compute_rect_area
	add		esp, 4
		
	mov		dword [area_1], eax
	
	; Computing area of Rect 2
	push	rect2
	call	compute_rect_area
	add		esp, 4
		
	mov		dword [area_2], eax
	
	; Compare 2 areas
	mov		eax, dword [area_1]
	cmp		eax, dword [area_2]
	
	jg		.rect_1_larger
	push	2 
	jmp		.print_larger_rect 
.rect_1_larger:
	push	1 
.print_larger_rect:
	push	rect_larger
	call	[printf]
	add		esp, 4*2 
	
	push	0
	call	[ExitProcess]

; compute_rect_area(struct_rect_addr)
compute_rect_area:
	.struct_rect_addr = 8h
	
	push	ebp
	mov		ebp, esp
	
	.width = 4h
	.height = 8h
	sub		esp, 4*2		; 2 local vars for width and height
	
	push	ebx
	push	ecx 
	push	edx
	push	esi
	
	mov		esi, dword [ebp + .struct_rect_addr]
	
	; Computing the width
	mov		eax, dword [esi + Rect.p_2.x]
	
	sub		eax, dword [esi + Rect.p_1.x]
	mov		dword [ebp - .width], eax 
	
	; Computing the height
	mov		eax, dword [esi + Rect.p_2.y]
	sub		eax, dword [esi + Rect.p_1.y]
	mov		dword [ebp - .height], eax 
	
	; Multiply width and height for area
	xor		edx, edx 
	mul		dword [ebp - .width]
	
.end_func:	
	pop		esi
	pop		edx 
	pop		ecx 
	pop		ebx
	
	add		esp, 4*2
	
	pop		ebp
	ret 

; construct_rect(struct_rect_addr)
construct_rect:
	.struct_rect_addr = 8h
	
	push	ebp
	mov		ebp, esp
	
	pusha 
	
	mov		edi, dword [ebp + .struct_rect_addr]
		
	push	1
	push	input_coord
	call	[printf]
	add		esp, 4*2
		
	lea 	ebx, dword [edi + Rect.p_1]
	
	push	ebx 
	call	construct_point
	add		esp, 4
		
	push	2
	push	input_coord
	call	[printf]
	add		esp, 4*2
		
	lea 	ebx, dword [edi + Rect.p_2]
	
	push	ebx 
	call	construct_point
	add		esp, 4

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

