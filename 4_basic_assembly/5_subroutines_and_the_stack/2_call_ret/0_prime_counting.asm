; 0.  Prime counting

    ; We want to calculate the amount of prime numbers between 1 and n.

    ; Recall that a prime number is a positive integer which is only divisible by
    ; 1 and by itself. The first prime numbers are 2,3,5,7,11,13. (1 is not
    ; considered to be prime).

    ; We break down this task into a few subtasks:

    ; 0.  Write a function that takes a number x as input. It then returns 
        ; eax = 1 if the number x is prime, and eax = 0 otherwise.

    ; 1.  Write a function that takes a number n as input, and then calculates the
        ; amount of prime numbers between 1 and n. Use the previous function that
        ; you have written for this task.

    ; Finally ask for an input number from the user, and use the last function you
    ; have written to calculate the amount of prime numbers between 1 and n.

    ; Bonus Question: After running your program for some different inputs, Can
    ; you formulate a general rough estimation of how many primes are there
    ; between 1 and n for some positive integer n?

format PE console
entry start

include 'win32a.inc' 

section '.data' data readable writeable
    enter_num		db		'Enter a number: ',0xd,0xa,0
	
section '.bss' readable writeable
    num				dd		?
	
section '.text' code readable executable

start:
	mov		esi, enter_num
	call	print_str
	
	call	read_hex
	mov		dword [num], eax
	
	mov		edi, dword [num]
	call	count_primes
	call	print_eax
	
	 ; Exit the process:
	push	0
	call	[ExitProcess]

;================================
; int count_primes(range);
; 
; edi -> range
; eax -> returnValue
;================================
count_primes:
	push	ecx
	push	ebx	
	
	xor		ecx, ecx
	xor		ebx, ebx
.count_next:
	push	edi
	mov		edi, ecx
	call	is_prime
	test	eax, eax
	jz		.skip_count
	inc		ebx
.skip_count:	
	pop		edi
	inc		ecx
	cmp		ecx, edi
	jb		.count_next
	
	mov		eax, ebx
.end:
	pop		ebx
	pop		ecx
	ret

;================================
; bool is_prime(num);
; 
; edi -> num
; eax -> returnValue
;================================
is_prime:
	push	ecx 
	push	edx
	push	edi
	
	cmp		edi, 0x2
	jl		.not_prime
	jz		.is_prime
	
	mov		ecx, 0x2
.check_loop:
	xor		edx, edx
	mov		eax, edi
	div		ecx
	cmp		edx, 0
	jz		.not_prime
	inc		ecx
	cmp		ecx, edi
	jnz		.check_loop
.is_prime:
	mov		eax, 0x1
	jmp		.end
.not_prime:
	xor		eax, eax
.end:
	pop		edi
	pop		edx
	pop		ecx
	ret


include 'training.inc'
