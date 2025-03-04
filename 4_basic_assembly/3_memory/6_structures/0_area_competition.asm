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

formatformat PE console
entry start

include 'win32a.inc'

struct PNT 
	x	dd	?
	y	dd	?
ends

struct RECT
	a	PNT		?
	b	PNT		?
ends

section '.bss' readable writable
	rect1		RECT 	?
	rect2		RECT 	?
	area1		dd		?
	area2		dd		?

section '.text' code readable executable

start:	
	call	read_hex
	mov		dword [rect1.a.x], eax
	call	read_hex
	mov		dword [rect1.a.y], eax
	call	read_hex
	mov		dword [rect1.b.x], eax
	call	read_hex
	mov		dword [rect1.b.y], eax
	call	print_delimiter
	
	call	read_hex
	mov		dword [rect2.a.x], eax
	call	read_hex
	mov		dword [rect2.a.y], eax
	call	read_hex
	mov		dword [rect2.b.x], eax
	call	read_hex
	mov		dword [rect2.b.y], eax
	call	print_delimiter
	
compute_area_1:
	xor		edi, edi 
	
	; Get height of rect1
	mov		eax, dword [rect1.a.y]
	sub		eax, dword [rect1.b.y]
	
	; abs(height)
	cdq								
	xor		eax, edx
	sub		eax, edx
	mov		edi, eax	

	; Get width of rect1
	mov		eax, dword [rect1.a.x]
	sub		eax, dword [rect1.b.x]
	
	; abs(width)
	cdq
	xor		eax, edx
	sub		eax, edx
	
	; Get area 
	mul		edi
	mov		dword [area1], eax 
	
compute_area_2:
	xor		edi, edi 
	
	; Get height of rect1
	mov		eax, dword [rect2.a.y]
	sub		eax, dword [rect2.b.y]
	
	; abs(height)
	cdq
	xor		eax, edx
	sub		eax, edx
	mov		edi, eax	

	; Get width of rect1
	mov		eax, dword [rect2.a.x]
	sub		eax, dword [rect2.b.x]
	
	; abs(width)
	cdq
	xor		eax, edx
	sub		eax, edx
	
	; Get area 
	mul		edi
	mov		dword [area2], eax 

	
	; Compare 2 areas
	call	print_delimiter
	
	mov		eax, dword [area1]
	mov		ebx, dword [area2]
	
	cmp		eax, ebx
	jb		area2_larger
area1_larger:
	mov		eax, 0
	call	print_eax
	mov		eax, dword [area1]
	call	print_eax
	jmp		end_prog
	
area2_larger:
	mov		eax, 1
	call	print_eax
	mov		eax, dword [area2]
	call	print_eax
	
end_prog:
	push 	0
	call	[ExitProcess]
	
	
include 'training.inc'