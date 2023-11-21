
format PE console
entry start

include 'win32a.inc' 
	
; ===============================================

section '.text' code readable executable
	
start: 
	call read_hex 
	mov ebx,eax 			; ebx = a 
	call read_hex 
	mov esi,eax 			; esi = b 
		
	mov ecx, 32d			; 32 bit iterations
next_bit:
	mov edx,ebx				;
	xor ebx,esi 			; ebx stores the XOR result 
	and esi,edx 			; esi stores the and 
	shl esi,1
		
	dec ecx
	jnz next_bit 
		
done:
	mov eax,ebx 
	call print_eax

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
