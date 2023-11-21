format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start: 
	call read_hex
	xor ecx,ecx 
	xor ebx,ebx 
	xor edx,edx 
	mov esi,31 
		
count:
	shr eax,1 
	jnc countup
	
	mov edx,ecx 
	and edx,1 
	jnz countup 
	inc ebx 
		
countup:
	inc ecx 
	cmp ecx,esi 
	jnz count 
	
	mov eax,ebx 
	call print_eax 

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
