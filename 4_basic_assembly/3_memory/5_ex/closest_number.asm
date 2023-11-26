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


; This is the data section:
; ===============================================
section '.data' data readable writeable
    nums dd 23h,75h,111h,0abch,443h,1000h,5h,2213h,433a34h,0deadbeafh
	nums_end:
	closest dd 0h	

; This is the text section:
; ===============================================
section '.text' code readable executable
	
start:
	call read_hex 
	mov ebx,eax 					; ebx - number to check 
	mov ecx,(nums_end - nums) / 4 	; get the length of the list
	mov eax,[nums]
	mov [closest],eax  
	xor esi,esi 					; initalize address index 
	
check_next:
	mov eax,[nums + 4*esi]
	mov edx, [closest]
	cmp eax,ebx 
	jne check_offsets
	mov [closest], eax  
	jmp Done
		
check_offsets:	
	stc 
	sub eax,ebx 
	jc  check_prev_offset
	neg eax 
		
check_prev_offset:
	stc 
	sub edx,ebx 
	jc compare_offsets 
	neg edx 
	
compare_offsets:
	stc 
	cmp eax, edx 
	jc countdown
	mov eax, [nums + 4*esi]
	mov [closest], eax  
	
countdown:
	inc esi
	dec ecx 
	jnz check_next 
	
Done:
	mov eax,[closest]
	call print_eax 
	
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
