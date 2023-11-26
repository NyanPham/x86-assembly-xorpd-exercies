; 1.  Strange sum.

    ; Write a program that gets a number n as input, and then receives a list of n
    ; numbers: a_1, a_2, ..., a_n.

    ; The program then outputs the value n*a_1 + (n-1)*a_2 + ... + 1*a_n.
    ; Here * means multiplication.

    ; Example:

    ; Assume that the input received was n=3, together with the following list of
    ; numbers:  3,5,2.
    ; Hence the result will be 3*3 + 2*5 + 1*2 = 9 + 10 + 2 = 21 = 0x15

    
    ; Question for thought: Could you write this program without using memory?


format PE console
entry start

include 'win32a.inc' 

; This is the bss section:
; ===============================================
section '.bss' readable writeable
	numbers_length	dd 	?
	numbers 		dd 	?
	
; This is the text section:
; ===============================================
section '.text' code readable executable
	
start:
	call 	read_hex 			; get n the length of numbers
	mov		edi, eax 
	mov 	dword [numbers_length], edi 
	mov		ecx, 0
	xor		ebx, ebx
		
get_one_number:
	call 	read_hex 
	mov 	esi, ecx 
	shl		esi,2
	add		esi, numbers
	mov  	dword [esi], eax 
	inc 	ecx 
	cmp 	ecx, edi 
	jnz get_one_number 
	
	mov 	ecx, 0
strange_sum:
	mov 	esi, ecx 
	shl 	esi,2 
	add		esi, numbers
	mov 	eax, dword [esi]
	mul 	edi
	add		ebx, eax 
	inc 	ecx 
	dec 	edi
	test 	edi, edi
	jnz 	strange_sum
	
	mov 	eax, ebx
	call 	print_eax 
	
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
