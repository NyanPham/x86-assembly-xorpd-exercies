; 1.  Check intersection.
		
    ; Assume that we have two rectangles R,Q which are parallel to the X and Y
    ; axes. We say that R and Q intersect if there is a point which is inside both
    ; of them.
		
    ; Example:
      
      ; Intersecting rectangles:        Non intersecting rectangles:

      ; +---------+                     +-----+
      ; | R       |                     | R   |   +------+
      ; |     +---+----+                |     |   | Q    |
      ; |     |   |  Q |                +-----+   |      |
      ; +-----+---+    |                          |      |
            ; |        |                          +------+
            ; +--------+

    ; Write a program that takes the coordinates of two rectangles (Just like in
    ; the previous exercise), and finds out if the rectangles are intersecting.
    ; The program will print 1 if they are intersecting, and 0 otherwise.

    ; Example:
      ; First rectangle:  (1,5) (4,9)
      ; Second rectangle: (3,4) (6,10)

      ; Those two rectangles are intersecting.
	
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
	enter_number		db	'Please enter a number: ',0
	
	enter_x 			db 	'X coordinate: ',0
	enter_y 			db 	'Y coordinate: ',0
	
	rect_num			db	'---RECTANGLE %d---',13,10,0
	input_coord			db	'Point %d',13,10,0
	line_break			db	13,10,0
	
	rects_intersect		db	'Both rects are intersecting!',13,10,0
	rects_not_intersect	db	'Both rects are NOT intersecting!',13,10,0
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	rect1			Rect ?
	rect2			Rect ?
		
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
	
	push	rect2
	push	rect1
	call	rects_intersecting
	add		esp, 4*2
	
	test	eax, eax 
	jz		.not_intersecting
	
	push	rects_intersect
	call	[printf]
	add		esp, 4
	jmp		.end_prog

.not_intersecting:
	push	rects_not_intersect
	call	[printf]
	add		esp, 4 
		
.end_prog:	
	push	0
	call	[ExitProcess]
	
;rects_intersecting(rect1_addr, rect2_addr)
rects_intersecting:
	.rect1_addr = 8h
	.rect2_addr = 0ch
	
	push	ebp
	mov		ebp, esp
	
	push	esi
	push	edi
	
	mov		esi, dword [ebp + .rect1_addr]
	mov		edi, dword [ebp + .rect2_addr]

	; Check if Rect1 is way to the left of Rect2 
	mov		eax, dword [esi + Rect.p_2.x]
	cmp		eax, dword [edi + Rect.p_1.x]
	jl		.not_intersecting
	
	; Check if Rect1 is way to the right of Rect2 
	mov		eax, dword [esi + Rect.p_1.x]
	cmp		eax, dword [edi + Rect.p_2.x]
	jg		.not_intersecting
	
	; Check if Rect1 is above Rect2 
	mov		eax, dword [esi + Rect.p_2.y]
	cmp		eax, dword [edi + Rect.p_1.y]
	jl		.not_intersecting
	
	; Check if Rect1 is below Rect2 
	mov		eax, dword [esi + Rect.p_1.y]
	cmp		eax, dword [edi + Rect.p_2.y]
	jg		.not_intersecting
.are_intersecting:
	mov		eax, 1
	jmp		.end_func
	
.not_intersecting:
	mov		eax, 0
.end_func:	
	pop		edi 
	pop		esi
	
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