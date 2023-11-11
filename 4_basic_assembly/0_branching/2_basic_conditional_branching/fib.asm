format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call read_hex 
	cmp eax,2
	jl Print1 
	
	mov ecx,eax 				; ecx = n 
	dec ecx 
	mov ebx,0
	mov esi,1 
NextEl:
	mov eax,ebx 
	add eax,esi 
	mov ebx,esi 
	mov esi,eax 

	dec ecx 
	jnz NextEl 	
			
	call print_eax 
	jmp Done 
	
Print1:
	mov eax,1
	call print_eax 

Done:
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
