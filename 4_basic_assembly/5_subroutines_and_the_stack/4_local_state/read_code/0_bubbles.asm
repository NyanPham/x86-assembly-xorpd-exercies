format PE console 
entry start 

include 'win32a.inc'

section '.data' data readable writeable 
	nums		dd	8,15h,141h,0a2h,31h,14h,31h,82h,34h,55h 
	NUMS_LEN = ($ - nums) / 4
	
	initial_arr		db	'Initial array:',13,10,0
	array_sorted	db	'Array sorted:',13,10,0
	
section '.text' code readable executable
start:
	mov		esi, initial_arr
	call	print_str 
		
	push	NUMS_LEN
	push	nums 
	call	print_arr
	add		esp, 4*2
	
	push	NUMS_LEN
	push	nums 
	call	sort_arr
	add		esp, 4*2 
	
	mov		esi, array_sorted
	call	print_str 
	
	push	NUMS_LEN
	push	nums 
	call	print_arr
	add		esp, 4*2

	
	push	0
	call	[ExitProcess]




;=========================================
; print_arr(arr_addr, arr_len) 
;
print_arr:
	.arr_addr =	8h 
	.arr_len = 0ch
	
	push 	ebp 
	mov		ebp, esp 
	
	push	esi
	push	ecx 
	
	mov		ecx, dword [ebp + .arr_len]
	jecxz	.no_elements
	mov		esi, dword [ebp + .arr_addr]

.print_element:
	mov		eax, dword [esi] 
	call	print_eax 
	add		esi, 4
	loop	.print_element 
		
.no_elements:
	pop		ecx 
	pop		esi
	
	pop		ebp 
	ret 
	
;=========================================
; sort_arr(arr_addr, arr_len) 
;
sort_arr:
	.arr_addr = 8h 
	.arr_len = 0ch 
	push	ebp 
	mov		ebp, esp 
	
	push	esi 
	push	edi
	push	ecx 
	push	ebx 
	
	mov		esi, dword [ebp + .arr_addr]
	mov		ecx, dword [ebp + .arr_len]
	jecxz 	.no_elements
	lea		ebx, dword [esi + ecx*4]			; ebx = address of the last element in array 
.outer_iter:									; 	
	mov		edi, esi 
.inner_iter:
	push	edi 
	push	esi
	call	compare_and_swap 
	add		esp, 4*2 
	add		edi, 4 
	cmp		edi, ebx 
	jb 		.inner_iter
	add		esi, 4 
	cmp		esi, ebx 
	jb		.outer_iter 
	
.no_elements:
	pop		ebx
	pop		ecx 
	pop		edi 
	pop		esi 
	
	pop		ebp 
	ret 

;=========================================
; compare_and_swap(x_addr, y_addr) 
;
compare_and_swap:
	.x_addr	= 8h
	.y_addr = 0ch
	push	ebp 
	mov		ebp, esp 
	
	push	esi
	push	edi
	push	eax 

	mov		esi, dword [ebp + .x_addr]
	mov		edi, dword [ebp + .y_addr] 
	
	mov		eax, dword [esi]
	cmp		eax, dword [edi]
	jae		.x_above_equal
	push	esi
	push	edi
	call	swap 
	add		esp, 4*2 
.x_above_equal:
	pop		eax 
	pop		edi 
	pop		esi 
		
	pop		ebp 
	ret 


;=========================================
; swap(x_addr, y_addr) 
;
swap:
	.x_addr = 8h 
	.y_addr	= 0ch 
	push	ebp 
	mov		ebp, esp 
	
	push	esi
	push 	edi

	mov		esi, dword [ebp + .x_addr]
	mov		edi, dword [ebp + .y_addr] 
	
	push	dword [esi] 
	push	dword [edi]
	pop		dword [esi]
	pop		dword [edi]
	
	pop		edi
	pop		esi 
	
	pop		ebp 
	
	ret 







	
include 'training.inc'





