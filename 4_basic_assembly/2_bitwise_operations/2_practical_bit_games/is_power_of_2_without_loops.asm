
format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start: 
	call read_hex 
	;==============================================
	; Need this part to check if input is 0 or not
	;==============================================
	cmp eax,0
	jnz Done 
	
	mov ebx, eax 
	sub ebx,1
	and eax,ebx 
		
	cmp eax,0
	jnz print_0
	mov eax,1 
	jmp Done
		
print_0:
	mov eax,0
	
Done:
	call print_eax 
	
    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
