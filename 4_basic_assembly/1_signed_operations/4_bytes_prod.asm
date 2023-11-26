; 0.1 Write a program that does the same, except that it multiplies the four
; bytes. (All the bytes are considered to be unsigned).

format PE console
entry start

include 'win32a.inc'
	
; ===============================================
section '.text' code readable executable
	
start:
	call read_hex 
		
	mov ebx,0
	mov bl, al 					; bl = byte 1
	mov bh, ah 					; bh = byte 2 
		
		
	mov edx,0
	sub eax,ebx 
	mov esi, 0ffffh
	div esi						; dl = byte 3
								; dh = byte 4 
								
	mov esi, edx 				
	
	movzx eax, bl 				; initialize product with byte 1 
	movzx ecx, bh 
	mul ecx 					; byte 1 * byte 2
	
	mov edx,esi 
	movzx ecx, dl 				
	mul ecx 					; byte 1 * byte 2 * byte 3
						
	mov edx,esi
	movzx ecx, dh 				
	mul ecx 					; byte 1 * byte 2 * byte 3 * byte 4

	call print_eax 
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
