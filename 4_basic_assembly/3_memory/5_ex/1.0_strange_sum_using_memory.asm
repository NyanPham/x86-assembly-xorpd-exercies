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

section '.bss' readable writeable
	nums_len		dd	?
	nums			dd	0x40  dup (?)
	
section '.text' code readable executable

start:
    call	read_hex
	mov		dword [nums_len], eax
	
	xor		ecx, ecx 
get_num:
	call	read_hex
	mov		edi, nums
	mov		dword [edi + 4*ecx], eax
	
	inc		ecx 
	cmp		ecx, dword [nums_len]
	jnz		get_num

	
	xor		ebx, ebx
	xor		ecx, ecx
compute:
	mov		edi, nums
	mov		eax, dword [edi + 4*ecx]
	mov		edx, dword [nums_len]
	sub		edx, ecx
	mul		edx 
	add		ebx, eax
	
	inc		ecx 
	cmp		ecx, dword [nums_len]
	jnz		compute
		
	mov		eax, ebx
	call	print_eax

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
