; 1.  Strange sum.

    ; Write a program that gets a number n as input, and then receives a list of n
    ; numbers: a_1, a_2, ..., a_n.

    ; The program then outputs the value n*a_1 + (n-1)*a_2 + ... + 1*a_n.
    ; Here * means multiplication.

    ; Example:

    ; Assume that the input received was n=3, together with the following list of
    ; numbers:  3,5,2.
    ; Hence the result will be 3*3 + 2*5 + 1*2 = 9 + 10 + 2 = 21 = 0x15

    
    ; Question for thought: Could you write this program without using memory -> Yes. Here is another solution.

format PE console
entry start

include 'win32a.inc' 

section '.text' code readable executable

start:
	call	read_hex
	mov		esi, eax
	
	xor		ebx, ebx 
	xor		ecx, ecx 
compute:
	call	read_hex
	mov		edi, esi
	sub		edi, ecx
	mul		edi
	add		ebx, eax
	
	inc		ecx
	cmp		ecx, esi
	jnz		compute
	
	mov		eax, ebx
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
