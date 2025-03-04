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

      ; Those two rectangle are intersecting.
	
format PE console
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

section '.text' code readable executable

start:	
	;==================================
	; Get 2 points for rectangle 1
	;==================================
	call	read_hex
	mov		dword [rect1.a.x], eax
	call	read_hex
	mov		dword [rect1.a.y], eax
	call	read_hex
	mov		dword [rect1.b.x], eax
	call	read_hex
	mov		dword [rect1.b.y], eax
	call	print_delimiter
	
	;==================================
	; Get 2 points for rectangle 2
	;==================================
	call	read_hex
	mov		dword [rect2.a.x], eax
	call	read_hex
	mov		dword [rect2.a.y], eax
	call	read_hex
	mov		dword [rect2.b.x], eax
	call	read_hex
	mov		dword [rect2.b.y], eax
	call	print_delimiter
	
	;========================================================
	; Check if any point of rectangle 1 is inside rectangle 2
	;========================================================
	
	; rect1 right is less than rect2 left
	mov		eax, dword [rect1.b.x]
	cmp		eax, dword [rect2.a.x]
	jb		no_intersecting
	
	; rect1 left is greater than rect2 right
	mov		eax, dword [rect1.a.x]
	cmp		eax, dword [rect2.b.x]
	ja		no_intersecting
	
	; rect1 top is greater than rect2 bottom
	mov		eax, dword [rect1.a.y]
	cmp		eax, dword [rect2.b.y]
	ja		no_intersecting
	
	; rect1 bottom is less than rect2 top
	mov		eax, dword [rect1.b.y]
	cmp		eax, dword [rect2.a.y]
	jb		no_intersecting
	
intersecting:
	mov		eax, 1
	call	print_eax
	jmp		end_prog
		
no_intersecting:
	mov		eax, 0
	call	print_eax

end_prog:
	push 	0
	call	[ExitProcess]
	
	
include 'training.inc'