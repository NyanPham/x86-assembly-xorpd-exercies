; 0.  Median

    ; Given an array of numbers, The median is defined to be the middle number in
    ; the sorted array. (If there are two middle numbers, we pick one of them).

    ; Examples:

      ; For the array: {4,8,1,9,23h,41h,15h,13h,44h} the median is 13h. (Sort the
      ; array and find the middle number, for example).

      ; For the array: {4,9,1,5}, then median could be chosen to be both 4 or 5.

    ; NOTE that the median is not the same as the mean of the array.


    ; 0.  Write a function that gets an address of an array of dwords, and the
        ; length of the array. The function will then return the median of the 
        ; array.

    ; 1.  Test your function with a few different arrays, and verify the results.

    ; 2.  Bonus: What is the running time complexity of the function you wrote?
        ; Could you find a faster way to find the median of an array?

format PE console
entry start

include 'win32a.inc' 

MAX_ARR_LEN = 0x40

section '.data' data readable writeable
	enter_size		db		'Please enter the size of the array: ',0
	enter_nums		db		'Please enter numbers: ',0xd,0xa,0
	new_line 		db		0xd,0xa,0
	
	sorted_nums		db		'Sorted nums array is: ',0xd,0xa,0
	median_is		db		'The median is: ',0

section '.bss' readable writeable
	nums 		dd		MAX_ARR_LEN  	dup 	(?)
	nums_len	dd		? 
	
section '.text' code readable executable

start:
	push	nums_len
	push	nums
	call	get_nums
	add		esp, 4*2
	
	push	dword [nums_len]
	push	nums
	call	sort_nums
	add		esp, 4*2
	
	call	print_delimiter

	mov	esi, sorted_nums
	call	print_str
	
	push	dword [nums_len]
	push	nums
	call	print_nums
	add		esp, 4*2 

	call	print_delimiter
	
	mov	esi, median_is
	call	print_str

	push		dword [nums_len]
	push		nums
	call		find_median
	add		esp, 4*2
	
	call	print_eax

	mov	esi, new_line
	call	print_str

	
    	; Exit the process:
	push	0
	call	[ExitProcess]
	

;========================================
; void get_nums(int* nums_addr, int* nums_len_addr)
;========================================
get_nums:
	.nums_addr = 8
	.nums_len_addr = 0ch
	
	push	ebp
	mov		ebp, esp
	
	push	esi
	push	edi
	push	eax
	push	ebx
	push	ecx 
	
	mov		esi, enter_size
	call	print_str
	call	read_hex
	
	mov		edi, dword [ebp + .nums_len_addr] 
	mov		dword [edi], eax
	
	mov		esi, enter_nums
	call	print_str
	
	mov		edi, dword [ebp + .nums_addr]
	mov		eax, dword [ebp + .nums_len_addr]
	mov		ecx, dword [eax]
	
	jecxz	.done
	xor		ebx, ebx
.next_num:
	push	edi
	call	read_hex
	pop		edi
	
	mov		dword [edi + 4*ebx], eax
	
	inc		ebx
	dec		ecx
	jnz		.next_num

.done:
	pop		ecx 
	pop		ebx
	pop		eax
	pop		edi
	pop		esi
	
	mov		esp, ebp
	pop		ebp
	ret 
	
;=========================================
; sort_nums(int* nums_addr, int nums_len)
;=========================================
sort_nums:
	.nums_addr = 0x8
	.nums_len = 0xc
	
	push	ebp
	mov		ebp, esp
	
	push	esi
	push	ebx
	push	ecx
	push	eax
	push	edx
	
	mov		esi, dword [ebp + .nums_addr]
	mov		ecx, dword [ebp + .nums_len]
	jecxz	.done
	dec		ecx
	jecxz	.done
.outer_loop:
	xor		ebx, ebx
.inner_loop:
	mov		eax, dword [esi + 4*ebx]
	mov		edx, dword [esi + 4*ebx + 4]
	cmp		eax, edx
	jb		.skip_swap

	lea		eax, dword [esi + 4*ebx]
	lea		edx, dword [esi + 4*ebx + 4]
	push	edx
	push	eax
	call	swap_nums
	add		esp, 4*2

.skip_swap:
	inc		ebx
	cmp		ebx, ecx
	jb		.inner_loop

	dec		ecx
	cmp		ecx, 1
	jae		.outer_loop
	
.done:
	pop		edx
	pop		eax
	pop		ecx
	pop		ebx
	pop		esi

	mov		esp, ebp 
	pop		ebp
	ret 
;=========================================
; swap_nums(a_addr, b_addr)
;=========================================
swap_nums:
	.a_addr = 0x8
	.b_addr = 0xc
	
	push	ebp
	mov		ebp, esp
	
	push	eax
	push	edx

	mov		eax, dword [ebp + .a_addr]
	mov		edx, dword [ebp + .b_addr]

	push	dword [eax]
	push	dword [edx]
	pop		dword [eax]
	pop		dword [edx]
	
	pop		edx
	pop		eax
	
	mov		esp, ebp
	pop		ebp
	
	ret


;=========================================
; find_median(int* nums_addr, int nums_len)
;=========================================
find_median:
	.nums_addr = 0x8
	.nums_len = 0xc

	push	ebp
	mov	ebp, esp

	push	ebx
	push	esi

	; Find median index	
	mov	ebx, dword [ebp + .nums_len]
	shr	ebx, 0x1
	
	mov	esi, dword [ebp + .nums_addr]
	mov  	eax, dword [esi + 4*ebx]

	pop	esi
	pop	ebx

	mov	esp, ebp
	pop	ebp
	ret 


;=========================================
; print_nums(int* nums_addr, int nums_len)
;=========================================
print_nums:
	.nums_addr = 0x8
	.nums_len = 0xc
	
	push	ebp
	mov		ebp, esp
	
	push	esi
	push	ebx
	push	ecx
	push	eax
	
	mov		esi, dword [ebp + .nums_addr]
	mov		ecx, dword [ebp + .nums_len]
	jecxz	.done
	xor		ebx, ebx
.print_num:	
	mov		eax, dword [esi + 4*ebx]
	call	print_eax

	inc		ebx
	dec		ecx 
	jnz		.print_num
	
.done:
	pop		eax
	pop		ecx
	pop		ebx
	pop		esi

	mov		esp, ebp 
	pop		ebp
	ret 
	
include 'training.inc'
