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
