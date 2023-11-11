format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call read_hex 
	mov ebx,eax 				; ebx = x 
	call read_hex 
	mov ecx,eax 				; ecx = y 
	call read_hex 				
	mov esi,eax 				; esi = z 
		
	mov eax,1 
	cmp ebx, ecx 
    jae Fail
			
    cmp ecx,esi
	jae Fail 
		
	jmp Print
Fail:
	mov eax,0
Print:
	call print_eax 
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'