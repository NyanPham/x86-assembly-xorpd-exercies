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
	x 	dd 	?
	y	dd 	? 
ends 
		
struct rectangle 
	top_left 	PNT 	?
	bottom_right 	PNT 	? 
ends 
			
; ===============================================
section '.bss' readable writeable
    rectangle_1 	rectangle 	?
	rectangle_2 	rectangle 	?
		
; This is the text section:
; ===============================================
section '.text' code readable executable
	
start:
	;==================================
	; Get 2 points for rectangle 1
	;==================================
	call 	read_hex 
	mov		dword [rectangle_1.top_left.x], eax 
	call	read_hex 
	mov 	dword [rectangle_1.top_left.y], eax 
		
	call	read_hex 	
	mov		dword [rectangle_1.bottom_right.x], eax 
	call	read_hex 
	mov		dword [rectangle_1.bottom_right.y], eax 
			
	;==================================
	; Get 2 points for rectangle 2
	;==================================
	call	read_hex 
	mov		dword [rectangle_2.top_left.x], eax 
	call	read_hex 
	mov		dword [rectangle_2.top_left.y], eax 
	
	call	read_hex 
	mov		dword [rectangle_2.bottom_right.x], eax 
	call	read_hex 
	mov 	dword [rectangle_2.bottom_right.y], eax 
	
	;========================================================
	; Check if any point of rectangle 1 is inside rectangle 2
	;========================================================
	mov 	eax, dword [rectangle_1.bottom_right.x]
	cmp		eax, dword [rectangle_2.top_left.x]
	jl 		not_intersecting 
	
	mov		eax, dword [rectangle_1.top_left.x]
	cmp		eax, dword [rectangle_2.bottom_right.x]
	jg		not_intersecting
	
	mov		eax, dword [rectangle_1.bottom_right.y]
	cmp 	eax, dword [rectangle_2.top_left.y]
	jl		not_intersecting
	
	mov		eax, dword [rectangle_1.top_left.y]
	cmp		eax, dword [rectangle_2.bottom_right.y]
	jg 		not_intersecting
	
	mov		eax, 1
	jmp		print_result
		
not_intersecting:
	mov 	eax, 0

print_result:
	call	print_eax 

Done:
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'















