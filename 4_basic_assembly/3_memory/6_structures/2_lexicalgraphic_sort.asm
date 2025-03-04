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

struct PNT 
	x	dd	?
	y	dd	?
ends

POINTS_LEN = 0x6

section '.bss' readable writable
	points 		PNT  	POINTS_LEN
	
section '.text' code readable executable

start:	
	;=========================================
	; Get points values
	;=========================================
	xor		ecx, ecx
	mov		esi, points
get_point:
	call	read_hex
	mov		dword [esi + sizeof.PNT*ecx + PNT.x], eax
	call	read_hex 
	mov		dword [esi + sizeof.PNT*ecx + PNT.y], eax
	
	inc		ecx
	cmp		ecx, POINTS_LEN
	jnz		get_point

	call	print_delimiter
	
	;=========================================
	; Sort the points array using bubble sort
	;=========================================
	mov		ecx, POINTS_LEN - 1
	mov		esi, points 
sort_points:
.sort_next:
	xor		ebx, ebx	
	xor		ebp, ebp		; flag if swap in inner loop
.inner_sort:
	mov		eax, dword [esi + sizeof.PNT*ebx + PNT.x]
	cmp		eax, dword [esi + sizeof.PNT*ebx + sizeof.PNT + PNT.x]
	jb		.skip_swap
	je		.compare_y
	jmp		.swap
	
.compare_y:
	mov		eax, dword [esi + sizeof.PNT*ebx + PNT.y]
	cmp		eax, dword [esi + sizeof.PNT*ebx + sizeof.PNT + PNT.y]
	jbe		.skip_swap

.swap:
	mov		edi, dword [esi + sizeof.PNT*ebx + sizeof.PNT + PNT.x]
	mov		edx, dword [esi + sizeof.PNT*ebx + sizeof.PNT + PNT.y]
	
	mov		eax, dword [esi + sizeof.PNT*ebx + PNT.x]
	mov		dword [esi + sizeof.PNT*ebx + sizeof.PNT + PNT.x], eax
	mov		eax, dword [esi + sizeof.PNT*ebx + PNT.y]
	mov		dword [esi + sizeof.PNT*ebx + sizeof.PNT + PNT.y], eax
	
	mov		dword [esi + sizeof.PNT*ebx + PNT.x], edi
	mov		dword [esi + sizeof.PNT*ebx + PNT.y], edx
	
	inc		ebp 
	
.skip_swap:	
	inc		ebx
	cmp		ebx, ecx 
	jb		.inner_sort
	
	test 	ebp, ebp
	jz		.sort_done
	
	dec		ecx
	jnz		.sort_next
	
.sort_done:
	
	;==========================
	; Print the points array
	;==========================
	xor		ecx, ecx
	mov		esi, points
print_points:
.print_point:
	mov		eax, dword [esi + sizeof.PNT*ecx  + PNT.x]
	call 	print_eax
	mov		eax, dword [esi + sizeof.PNT*ecx  + PNT.y]
	call 	print_eax
	inc		ecx
	cmp		ecx, POINTS_LEN
	jnz		.print_point
	
end_prog:
	push 	0
	call	[ExitProcess]
	
	
include 'training.inc'