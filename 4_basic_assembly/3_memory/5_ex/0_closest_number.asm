; 0.  Find closest number.
    
    ; Add the following into the data section:

    ; nums  dd  23h,75h,111h,0abch,443h,1000h,5h,2213h,433a34h,0deadbeafh

    ; This is an array of numbers. 
    
    ; Write a program that receives a number x as input, and finds the dword
    ; inside the array nums, which is the closest to x. (We define the distance
    ; between two numbers to be the absolute value of the difference: |a-b|).

    ; Example:

    ; For the input of 100h, the result will be 111h, because 111h is closer to
    ; 100h than any other number in the nums array. (|100h - 111h| = 11h).


format PE console
entry start

include 'win32a.inc' 


section '.data' data readable writeable
	nums  			dd  23h,75h,111h,0abch,443h,1000h,5h,2213h,433a34h,0deadbeafh
	nums_end:
	
	closest_idx		dd	0x0
	min_dist		dd 	0xffffffff
	
section '.text' code readable executable
	
start:
	call	read_hex
	mov		ebx, eax					; x

	mov		esi, (nums_end - nums) / 4
	mov		edi, nums					; nums 
	xor		ecx, ecx					; i = 0
find_next:
	mov		eax, dword [edi + 4*ecx]	; nums[i]
	
	sub		eax, ebx 
	cdq 	
	xor		eax, edx
	sub		eax, edx 					; |nums[i] - x|
	
	mov		edx, dword [min_dist]
	cmp		eax, edx					; |nums[i] - x| < *min_dist ?
	jae		.not_closer
	
	mov		dword [closest_idx], ecx	; yes, closest_idx = i
	mov		dword [min_dist], eax
	
.not_closer:
	inc		ecx 
	cmp		ecx, esi
	jnz		find_next
	
	mov		ecx, dword [closest_idx]
	mov		edi, nums
	mov		eax, dword [edi + 4*ecx]
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
