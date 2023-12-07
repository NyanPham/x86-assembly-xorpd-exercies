format PE console
entry start

include 'win32a.inc' 

struct point 
	x	dd ?
	y	dd ? 
ends 

; This is the bss section:
; ===============================================
section '.bss' readable writeable
    points:
		point	?
		point	?
		point	?
		point	?
		point	?
		point	?
	
	num_points = ($ - points) / sizeof.point
	
; This is the text section:
; ===============================================
section '.text' code readable executable

start:
	;======================================
	; Get inputs for 6 points
	;======================================
	mov		ecx, num_points 
	xor 	esi, esi 
	
input_next_point:
	call	read_hex 
	mov		dword [points + esi * sizeof.point + point.x], eax 
	call	read_hex 
	mov		dword [points + esi * sizeof.point + point.y], eax 
	
	call	print_delimiter
		
	inc 	esi	
	dec		ecx 
	jnz 	input_next_point	
	
	;======================================
	; Lexicalgraphic sort
	;======================================
sort:	
	mov 	ecx, num_points
	dec 	ecx 
	
	xor 	esi, esi				; prev el index 
	xor		edi, edi 				; next el index to compare 
	xor 	edx, edx 				; temp storage for swap
	xor 	ebx, ebx 				; swap flag 
next_el:
	mov		edi, esi 
	inc 	edi
	mov		eax, dword [points + esi * sizeof.point + point.x]
	cmp		eax, dword [points + edi * sizeof.point + point.x]
		
	jl		check_done
	jg 		swap	
compare_y:
	mov		eax, dword [points + esi * sizeof.point + point.y]
	cmp		eax, dword [points + edi * sizeof.point + point.y]
		
	jle 	check_done
swap:
	mov		edx, dword [points + esi * sizeof.point + point.x]
	mov 	eax, dword [points + edi * sizeof.point + point.x]
	
	mov		dword [points + esi * sizeof.point + point.x], eax
	mov		dword [points + edi * sizeof.point + point.x], edx 
	
	mov		edx, dword [points + esi * sizeof.point + point.y]
	mov		eax, dword [points + edi * sizeof.point + point.y]
		
	mov		dword [points + esi * sizeof.point + point.y], eax 
	mov		dword [points + edi * sizeof.point + point.y], edx 
	
	mov 	ebx, 1
	
check_done:
	inc 	esi
	dec 	ecx 
	jnz 	next_el
	
	cmp		ebx, 1d 
	je		sort 
	
	;======================================
	; Sort done. Print the sorted points
	;======================================
	call	print_delimiter
	call	print_delimiter
	
	mov		ecx, num_points
	xor		esi, esi
print_next_point:	
	mov		eax, [points + esi * sizeof.point + point.x]
	call	print_eax 
	mov		eax, [points + esi * sizeof.point + point.y]
	call	print_eax 
	
	call	print_delimiter
	
	inc 	esi
	dec 	ecx 
	jnz 	print_next_point
		
end_prog:
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
