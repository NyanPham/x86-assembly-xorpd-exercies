; 2.  The Fibonacci series is the series of numbers where every number is the sum
    ; of the two previous numbers. It begins with the numbers: 1,1,2,3,5,8,...
    ; Write a program that takes as input the number n, and prints back the n-th
    ; element of the fibonacci series.

    ; Bonus question: What is the largest n that can be given to your program such
    ; that it still returns a correct answer? What happens when it is given larger
    ; inputs?

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex
	mov		ecx, eax 		; n

fibo:
	inc		ecx 
	dec		ecx 
	jz		.is_zero 
		
	dec		ecx 
	jz		.is_one
		
	; We haven't learned calling conventions, so we'll do
	; fibonacci caluclation in the iterative approach
	mov		esi, 0			; total
	mov		eax, 1			; curr_num
	mov		ebx, 1			; prev_num
.fibo_iter_loop:
	add		eax, ebx
	
	; Swap 	curr_num and prev_num 
	mov		edx, eax 
	mov		eax, ebx
	mov		ebx, edx 
	
	; Next iter
	dec		ecx 
	jnz 	.fibo_iter_loop
	
	jmp		.print_result
	
.is_zero:
	mov		eax, 0
	jmp		.print_result
	
.is_one:
	mov		eax, 1
	
.print_result:
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

