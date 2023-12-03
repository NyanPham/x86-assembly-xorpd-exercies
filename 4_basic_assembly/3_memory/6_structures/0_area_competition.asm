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

format PE console
entry start

include 'win32a.inc' 

struct PNT 
	x 	dd	?
	y 	dd  ?
ends 
	
struct rectangle 
	point_1 	PNT 	?
	point_2 	PNT 	?
ends 
	
; This is the bss section:
; ===============================================
section '.bss' readable writeable
    rectangle_1			rectangle   ? 
	rectangle_2 		rectangle   ?
	area_1				dd 			?
	area_2 				dd 			?
	
; This is the text section:
; ===============================================
section '.text' code readable executable

start:
	call 	read_hex 
	mov 	dword [rectangle_1.point_1.x], eax 
	call	read_hex 
	mov		dword [rectangle_1.point_1.y], eax 
	
	call	read_hex 
	mov 	dword [rectangle_1.point_2.x], eax 
	call	read_hex 
	mov 	dword [rectangle_1.point_2.y], eax 

	call	read_hex 
	mov 	dword [rectangle_2.point_1.x], eax 
	call	read_hex 
	mov		dword [rectangle_2.point_1.y], eax 
	
	call	read_hex 
	mov		dword [rectangle_2.point_2.x], eax 
	call	read_hex 
	mov		dword [rectangle_2.point_2.y], eax 
	
calc_area_1:
	mov 	eax, dword [rectangle_1.point_2.x] 
	mov		ebx, dword [rectangle_1.point_1.x]
	sub 	eax, ebx 
	mov 	esi, eax 
	
	mov 	eax, dword [rectangle_1.point_2.y] 
	mov		ebx, dword [rectangle_1.point_1.y]
	sub 	eax, ebx
	mul 	esi
	mov		dword [area_1], eax 
	
calc_area_2:
	mov 	eax, dword [rectangle_2.point_2.x] 
	mov		ebx, dword [rectangle_2.point_1.x]
	sub 	eax, ebx 
	mov 	esi, eax 
		
	mov 	eax, dword [rectangle_2.point_2.y] 
	mov		ebx, dword [rectangle_2.point_1.y]
	sub 	eax, ebx
	mul 	esi
compare:
	cmp 	eax, dword [area_1] 
	jg 		second_bigger 
first_bigger:
	mov		eax, 0
	jmp 	print_result
second_bigger:
	mov 	eax, 1
		
print_result:
	call	print_eax 
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
