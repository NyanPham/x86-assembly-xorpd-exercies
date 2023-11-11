format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
    ; The program begins here:
    call read_hex 
    add eax,eax 
    inc eax             ; eax = 2n + 1
    mov esi,eax 
    mov ecx,2   
	xor ebx,ebx 
NextCheck:
    xor edx,edx 
    mov eax,esi 
    div ecx     
    cmp edx,0 
    je SkipAdd
    
    add ebx,esi 

SkipAdd:
    dec esi 
    jnz NextCheck   

Done:
    mov eax,ebx
    call print_eax 

    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'