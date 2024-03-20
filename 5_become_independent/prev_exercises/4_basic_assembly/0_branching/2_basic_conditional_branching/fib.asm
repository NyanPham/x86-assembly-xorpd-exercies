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

INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	fibonacci_is	db 	'The Fibonacci value at %d element is: %d',13,10,0
		
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_number
	call	get_num
	add		esp, 4
			
	mov 	esi, eax
			
	push	eax
	call	fibonacci
	add		esp, 4 
		
	push	eax 
	push	esi
	push	fibonacci_is
	call	[printf]
	add		esp, 4*3
			
	push	0
	call	[ExitProcess]


; fibonacci(nth_num)
fibonacci:
	.nth_num = 8h
	
	push	ebp
	mov		ebp, esp
	
	push	ebx 
	push	ecx 
	
	mov		ecx, dword [ebp + .nth_num] 
		
	cmp		ecx, 1
	jbe		.nth_zero
			
	dec 	ecx 
	mov		eax, 0
	mov		ebx, 1 
.fib_loop:
	add		eax, ebx 
	xchg 	eax, ebx 
	
	dec 	ecx 
	jnz		.fib_loop
		
	jmp		.end_func
				
.nth_zero:
	mov		eax, 0
	jmp 	.end_func

.end_func:
	pop		ecx 
	pop		ebx 

	pop		ebp
	ret 

; get_num(prompt_addr)
get_num:
	.prompt_addr = 8h
	
	push	ebp 
	mov		ebp, esp 
		
	push	dword [ebp + .prompt_addr]
	call	[printf]
	add		esp, 4 
	
	push	INPUT_BUFFER_MAX_LEN
	push	bytes_read
	push	input_buffer 
	call	get_line
	add		esp, 4*3
	
	push	input_buffer 
	call	str_to_dec
	add		esp, 4
	
	pop		ebp
	ret 

; get_line(input_buffer, bytes_read, bytes_to_read)
get_line:
	.input_buffer = 8h
	.bytes_read = 0ch
	.bytes_to_read = 10h
	
	push	ebp 
	mov		ebp, esp
	
	push	ecx 
	push	esi
	
	mov		ecx, dword [ebp + .bytes_read]
	mov		esi, dword [ebp + .input_buffer]
	
	push	0
	push	ecx 
	push	dword [ebp + .bytes_to_read]
	push	esi 
	push	dword [input_handle]
	call	[ReadFile]
	
	pop		esi 
	pop		ecx 
	
	pop		ebp 
	ret 
	
; str_to_dec(str_addr)
str_to_dec:
	.str_addr = 8h 
	
	push	ebp
	mov		ebp, esp 
	
	push	10
	push	0
	push	dword [ebp + .str_addr]
	call 	[strtoul]
	add		esp, 4*3 
	
	pop		ebp
	ret 

section '.idata' data import readable 

library kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import	kernel32,\
		ReadFile,'ReadFile',\
		GetStdHandle,'GetStdHandle',\
		ExitProcess,'ExitProcess'
		
import	msvcrt,\
		printf,'printf',\
		strtoul,'strtoul'