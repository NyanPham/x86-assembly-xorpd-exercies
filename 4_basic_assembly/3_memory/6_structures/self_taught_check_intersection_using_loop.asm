format PE console
entry start

include 'win32a.inc'

section '.data' readable writeable

    struct PNT
        x   dd  ?
        y   dd  ?
    ends

    struct rectangle
        top_left        PNT     ?
        bottom_right    PNT     ?
    ends	
				
	rectangles:
		rectangle    <1, 5>, <4, 9>
		rectangle    <3, 4>, <6, 10>
		rectangle    <7, 3>, <9, 7>
		rectangle    <2, 8>, <5, 12>
		rectangle    <6, 2>, <8, 5>
			
	rectangles_end:
		
section '.text' code readable executable
	
start:	
	mov 	ecx, (rectangles_end - rectangles) / sizeof.rectangle
	xor 	ebx, ebx 					; counter of numbers of intersections
	xor 	esi, esi					; outer loop counter 
		
outer_loop:
	mov		edi, esi 					; check the rectangle at index esi to the next at index edi (edi = esi + 1)
	inc		edi 						
	
inner_loop:	
	mov 	edx, esi
	shl 	edx, 4 
	add		edx, rectangles
	add		edx, rectangle.top_left.x		; [rectangles + esi * sizeof.rectangle + rectangle.top_left.x]
	mov 	eax, dword [edx]
		
	mov 	edx, edi
	shl		edx, 4
	add		edx, rectangles
	add		edx, rectangle.bottom_right.x	; [rectangles + edi * sizeof.rectangle + rectangle.bottom_right.x]
	cmp		eax, dword [edx]
	
	jg 		no_intersecting
	
	mov 	edx, esi
	shl 	edx, 4 
	add		edx, rectangles
	add		edx, rectangle.bottom_right.x	; [rectangles + esi * sizeof.rectangle + rectangle.bottom_right.x]
	mov		eax, dword [edx]
	
	mov 	edx, edi
	shl		edx, 4
	add		edx, rectangles
	add		edx, rectangle.top_left.x		; [rectangles + edi * sizeof.rectangle + rectangle.top_left.x]
	cmp		eax, dword [edx]
	
	jl		no_intersecting
	
	mov 	edx, esi
	shl 	edx, 4 
	add		edx, rectangles
	add		edx, rectangle.top_left.y		; [rectangles + esi * sizeof.rectangle + rectangle.top_left.y]
	mov		eax, dword [edx]
	
	mov 	edx, edi
	shl		edx, 4
	add		edx, rectangles
	add		edx, rectangle.bottom_right.y	;[rectangles + edi * sizeof.rectangle + rectangle.bottom_right.y] 
	cmp		eax, dword [edx] 
	
	jg		no_intersecting
			
	mov 	edx, esi
	shl 	edx, 4 
	add		edx, rectangles
	add		edx, rectangle.bottom_right.y	; [rectangles + esi * sizeof.rectangle + rectangle.bottom_right.y]
	mov		eax, dword [edx]
		
	mov 	edx, edi
	shl		edx, 4
	add		edx, rectangles
	add		edx, rectangle.top_left.y		; [rectangles + edi * sizeof.rectangle + rectangle.top_left.y] 
	cmp		eax, dword [edx]
	
	jl		no_intersecting
	
	inc		ebx 
no_intersecting:		
	inc 	edi 
	cmp		edi, ecx 
	jl 		inner_loop 
		
	inc		esi
	cmp		esi, ecx 
	jl		outer_loop
		
	mov 	eax, ebx 
	call	print_eax 

done:
    ; Exit the process
    push    0
    call    [ExitProcess]

include 'training.inc'