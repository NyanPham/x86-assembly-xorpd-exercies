format PE console
entry start

include 'win32a.inc'
	
; ===============================================
section '.text' code readable executable
	
start:
	call read_hex 
	mov ebx,0
	
	mov bl, al					; bl = byte 1
	mov bh, ah 					; bh = byte 2 
	
	mov edx,0
	sub eax, ebx 
	mov esi, 0ffffh
	div esi						; dl = byte 3
								; dh = byte 4
	
	movzx eax, bl 				; now use eax to add them all
	movzx ecx, bh 
	add eax, ecx 
	movzx ecx, dl
	add eax, ecx 
	movzx ecx, dh
	add eax, ecx 
				
	call print_eax 
	
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
