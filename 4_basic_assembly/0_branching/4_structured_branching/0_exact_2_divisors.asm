; 0. Write a program that takes the number n as input. Then it prints all the
; numbers x below n that have exactly 2 different integral divisors (Besides 1
; and x). 

; For example: 15 is such a number. It is divisible by 1,3,5,15. (Here 3 and 5
; are the two different divisiors, besides 1 and 15).

; However, 4 is not such a number. It is divisible by 1,2,4.

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call 	read_hex
	mov		esi, eax	; input

lower_print:			; outer loop, the lower number of input
	dec		esi
	cmp		esi, 1
	jbe		done
	
	mov		ecx, esi	 
	dec		ecx			
	mov		ebx, 0		
count_divisor:			; inner loop, check if its divisors count is 2
	mov		edx, 0
	mov		eax, esi
	div		ecx 
	cmp		edx, 0
	jnz		skip_count
	inc		ebx 
		
skip_count:
	dec		ecx
	cmp		ecx, 0x1
	ja		count_divisor
	
	cmp		ebx, 0x2
	jne		skip_print
	
	mov		eax, esi
	call	print_eax

skip_print:
	jmp		lower_print

done:
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

