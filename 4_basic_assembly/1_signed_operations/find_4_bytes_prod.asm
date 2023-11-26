; 0.2 Write a program that finds every double word (4 bytes) that satisfies the
; following condition: When decomposed into 4 bytes, if we multiply those
; four bytes, we get the original double word number.

format PE console
entry start

include 'win32a.inc'
		
; ===============================================
section '.text' code readable executable
	
start:
	mov ecx, 0x10101010				; intialize counter as 0, max 0xffffffff
			
MainLoop:			
	xor eax,eax 
	xor edx,edx 
	xor esi,esi
	xor ebx,ebx 	
			
	movzx eax, cl					; eax = byte 1
	mul ch 							; eax = byte 1 * byte 2
	mov ebx, eax 					; save eax in ebx 
	
	xor edx,edx 
	mov esi, 0ffffh 
	mov eax,ecx 
	div esi 
	
	mov eax, ebx 					; restore a from ebx 
	mov ebx, edx 					; save higher 2 bytes in dbx 
	xor edx, edx 					
	movzx esi, bl 					
	mul esi							; eax = byte 1 * byte 2 * byte 3
	xor edx,edx 
	movzx esi, bh 
	mul esi							; eax = byte 1 * byte 2 * byte 3 * byte 4
	
	cmp eax, eax 
	jne not_equal 
		
	call print_eax 	
							
not_equal:
	cmp ecx, 0xffffffff
	jz Done 
			
	inc ecx 
	jmp MainLoop 

Done: 
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
