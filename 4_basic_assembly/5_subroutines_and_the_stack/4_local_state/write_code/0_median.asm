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
		
ARR_MAX_LEN = 40h
		
section '.data' data readable writeable
	enter_length 		db	'Please enter the length of the array:',13,10,0
	enter_arr			db	'Please enter each number:',13,10,0
	median_are			db	'The median of nums are:',13,10,0
			
section '.bss' readable writeable
	nums				dd	ARR_MAX_LEN	 dup (?)
	medians 			dd	2 			 dup (?)
	nums_len			dd	? 
	
section '.text' code readable executable
start:
	mov		esi, enter_length
	call	print_str 
	call	read_hex 
		
	test	eax, eax 
	jz		.end_program
	
	mov		dword [nums_len], eax 
	
	mov		esi, enter_arr
	call	print_str 
	
	mov		esi, nums
	mov		ecx, dword [nums_len] 
	push	ecx 
	push	esi
	call	fill_nums
	add		esp, 4*2 
	
	mov		esi, nums
	mov		ecx, dword [nums_len] 
	push	ecx 
	push	esi
	call	sort_nums 
	add		esp, 4*2 
	
	mov		esi, median_are
	call	print_str 
	
	mov		ecx, dword [nums_len]
	cmp		ecx, 3h 
	jge		.need_find_medians
	mov		esi, nums 
	mov		eax, ecx 
	jmp		.print_results
	
.need_find_medians:	
	mov		esi, nums
	mov		edi, medians
	mov		ecx, dword [nums_len] 
	push	ecx 
	push	esi
	push	edi 
	call	get_median 
	add		esp, 4*2 
	mov		esi, medians
	
.print_results:
	push	eax 
	push	esi
	call	print_medians
	add		esp, 4*2 

.end_program:
	push	0
	call	[ExitProcess]
	
;=======================================
; fill_nums(nums_addr, nums_len)
;
; Input: address of nums and nums length 
; Output: void 
; Operation: nums get filled by user input 
;

fill_nums:
	.nums_addr = 8h
	.nums_len = 0ch
	push	ebp 
	mov		ebp, esp
	
	push	ecx
	push	ebx
	push	esi
	push	eax 
	
	mov		ecx, dword [ebp + .nums_len]
	jecxz   .fill_done
	mov		esi, dword [ebp + .nums_addr]
	xor		ebx, ebx 
.fill_next:
	call	read_hex 
	mov		dword [esi + ebx * 4], eax 
	inc		ebx 
	dec		ecx 
	jnz		.fill_next
	
.fill_done: 
	pop		eax 
	pop		ebx 
	pop		esi
	pop		ecx 
	
	pop		ebp 
	ret
	
;=======================================
; print_nums(nums_addr, nums_len)
;	
; Input: address of nums and nums length 
; Output: void 
; Operation: print each number in nums 
;

print_nums:
	.nums_addr = 8h
	.nums_len = 0ch
	push	ebp 
	mov		ebp, esp
		
	push	esi
	push	ecx 
	push	ebx 
	push	eax 
	
	mov		ecx, dword [ebp + .nums_len]
	jecxz	.print_done
	
	mov		esi, dword [ebp + .nums_addr]
	xor		ebx, ebx 
.print_next:
	mov		eax, dword [esi + ebx * 4]
	call	print_eax 
	inc		ebx 
	dec		ecx 
	jnz		.print_next
.print_done:
	pop		eax 
	pop		ebx 
	pop		ecx 
	pop		esi
	
	pop		ebp
	ret 
	
;=======================================
; sort_nums(nums_addr, nums_len)
;	
; Input: address of nums and nums length 
; Output: void 
; Operation: bubble sort the nums from smallest to largest
;

sort_nums:
	.nums_addr = 8h
	.nums_len = 0ch 
	push	ebp 
	mov		ebp, esp
	
	push	esi
	push	edi 
	push	ecx 
	push	ebx 
	push	eax 
		
	mov		ecx, dword [ebp + .nums_len]
	jecxz	.no_nums
	mov		esi, dword [ebp + .nums_addr]
	mov		edi, dword [ebp + .nums_addr]
	lea		ebx, dword [edi + 4*ecx ] 
.outer_loop:	
	mov		edi, esi
.inner_loop:
	push	edi 
	push	esi 
	call	compare_and_swap
	add		esp, 4*2 
	add		edi, 4 
	cmp		edi, ebx 
	jb		.inner_loop
	add		esi, 4 
	cmp		esi, ebx 
	jb		.outer_loop 
		
.no_nums:
	pop		eax 
	pop		ebx 
	pop		ecx 
	pop		edi
	pop		esi
	
	pop		ebp 
	ret 
	
;=======================================
; compare_and_swap(x_addr, y_addr)
;	
; Input: addresses of 2 numbers: x, y
; Output: void 
; Operation: compare the value of 2 address and decide to swap if x > y 
;

compare_and_swap:
	.x_addr = 8h
	.y_addr = 0ch
	push	ebp 
	mov		ebp, esp
		
	push	esi 
	push	edi 
	
	mov		esi, dword [ebp + .x_addr]
	mov		edi, dword [ebp + .y_addr]

	
	mov		eax, dword [esi]
	cmp		eax, dword [edi]
	jle		.x_below_equal
	
	push	edi
	push	esi
	call	swap 
	add		esp, 4*2 
	
.x_below_equal:
	pop		edi 
	pop		esi 
	
	pop		ebp 
	ret 
	
;=======================================
; swap(x_addr, y_addr)
;	
; Input: addresses of 2 numbers: x, y
; Output: void 
; Operation: swap the value in the addresses of x and y 
;

swap:
	.x_addr = 8h
	.y_addr = 0ch
	push	ebp
	mov		ebp, esp
	
	push	esi 
	push	edi
	
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

;=======================================
; get_median(medians_addr, nums_addr, nums_len)
; 
; Input: Address of medians as target, address of nums as source, nums length
; Output: change medians, eax = numbers of median 
; Operation: divide length by 2, 
;				decide to get 1 median if length is odd, 2 medians if even and fill the medians array 
; 
get_median:
	.medians_addr = 8h
	.nums_addr = 0ch 
	.nums_len = 010h
	push	ebp 
	mov		ebp, esp
	
	push	esi
	push	edi 
	push	ecx 
		
	mov		ecx, dword [ebp + .nums_len]
	jecxz	.nums_empty
	mov		edi, dword [ebp + .medians_addr]
	mov		esi, dword [ebp + .nums_addr]
	shr		ecx, 1 
	jc		.odd 
.even:
	mov		eax, dword [esi + ecx * 4 - 4]
	mov		dword [edi], eax 
	mov		eax, dword [esi + ecx * 4]
	mov		dword [edi + 4], eax 
	mov		eax, 2h
	jmp 	.nums_empty
	
.odd:
	mov		eax, dword [esi + ecx * 4]
	mov		dword [edi], eax 
	mov		dword [edi + 4],eax 
	mov		eax, 1h
.nums_empty:
	pop		ecx 
	pop		edi 
	pop		esi
	
	pop		ebp 
	ret 
		
;=======================================
; print_medians(medians_addr, num_medians)
;
; Input: Address of medians array, numbers of medians (either 1 or 2)
; Output: void 
; Operation: Print each number in the medians array
; 
print_medians:
	.medians_addr = 8h 
	.num_medians = 0ch
	push	ebp 
	mov		ebp, esp
	
	push	esi
	push	ecx
	push	eax 
	
	mov		ecx, dword [ebp + .num_medians]
	jecxz	.no_medians
	mov		esi, dword [ebp + .medians_addr]
	xor		ebx, ebx 
.print_median:
	mov		eax, dword [esi + ebx * 4]
	call	print_eax 
	inc		ebx 
	dec		ecx 
	jnz 	.print_median

.no_medians:
	pop		eax 
	pop		ecx 
	pop		esi
	
	pop		ebp 
	ret 
	
	
	


include 'training.inc'