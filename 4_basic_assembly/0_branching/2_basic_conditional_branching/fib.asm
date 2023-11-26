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
	call read_hex 
	cmp eax,2
	jl Print1 
	
	mov ecx,eax 				; ecx = n 
	dec ecx 
	mov ebx,0
	mov esi,1 
NextEl:
	mov eax,ebx 
	add eax,esi 
	mov ebx,esi 
	mov esi,eax 

	dec ecx 
	jnz NextEl 	
			
	call print_eax 
	jmp Done 
	
Print1:
	mov eax,1
	call print_eax 

Done:
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
