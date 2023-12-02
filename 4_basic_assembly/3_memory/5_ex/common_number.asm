; 3.  Common number.

; Create a program that takes a number n as input, followed by a list of n
; numbers b_1, b_2, ... b_n. You may assume that 0x0 <= b_i <= 0xff for every
; 1 <= i <= n.

; The program will output the most common number.

; Example:

; Assume that the input was n=7, followed by the list: 1,5,1,3,5,5,2.
; The program will output 5, because this is the most common number.

; Note that if there is more than one most common number, the program will
; just print one of the most common numbers.

format PE console
entry start

include 'win32a.inc' 

; This is the bss section:
; ===============================================
section '.bss' readable writeable
	count 			dd ?
	common_number 	dd ?
    numbers 		dd ?
	

; This is the text section:
; ===============================================
section '.text' code readable executable

start:
    call 	read_hex 
	mov 	edi, eax 
	xor		ecx, ecx 

get_next_number:
	call	read_hex 
	mov		esi, ecx 
	shl 	esi, 2
	add		esi, numbers
	mov 	dword [esi], eax 
	inc 	ecx 
	cmp 	ecx, edi 
	jnz 	get_next_number
		
	;====================================
	; Bubble sort the list of numbers first
	;====================================
	
sort_num:	
	xor 	ecx, ecx 
	xor 	eax, eax 
	
next_el:
	mov 	esi, ecx 
	shl 	esi, 2
	add		esi, numbers 
	mov 	ebx, dword [esi]
	
	inc 	ecx 
	cmp 	ecx, edi
	je 		no_swap
	
	mov 	esi, ecx 
	shl 	esi, 2 
	add		esi, numbers 
	mov 	edx, dword [esi]
	
	cmp 	ebx, edx 
	jle		no_swap
	
swap:
	mov 	dword [esi], ebx
	dec 	ecx 
	mov 	esi, ecx 
	shl 	esi, 2 
	add		esi, numbers
	mov 	dword [esi], edx 	
	
	inc 	ecx 
	mov 	eax, 1
no_swap:
	cmp		ecx, edi 
	jnz  	next_el 
		
	cmp 	eax, 1
	jz 		sort_num 
			
sort_done:
	xor 	eax, eax 

	;===================================================================
	; Same numbers stand together in line 
	; Count the presence they are together and look for the common one 
	;=================================================================
	
	mov 	edx, dword [numbers]
	mov 	dword [count], 1
	mov		dword [common_number], edx 
	mov 	ecx, 1
	mov		ebx, 1
	
check_next_number:
	mov 	esi, ecx 
	shl 	esi, 2
	add 	esi, numbers 
	cmp		edx, dword [esi]

	
	jne 	not_same
	inc 	ebx 
	cmp 	ebx, dword [count]
	jl		done_num 
	
	mov 	dword [count], ebx 
	mov		dword [common_number], edx 
	jmp 	done_num 
not_same:
	mov 	edx, dword [esi]
	mov 	ebx, 1
		
done_num:
	inc 	ecx 
	cmp 	ecx, edi 
	jnz 	check_next_number
	
end_prog:
	mov 	eax, dword [common_number]
	call	print_eax 
	
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'

