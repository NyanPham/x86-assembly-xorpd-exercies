; Basic Assembly
; ==============
; 
; Subroutines and the stack - Calling conventions
; -----------------------------------------------
; 
; Scalar product
; @@@@@@@@@@@@@@
;
	
format PE console
entry start

include 'win32a.inc' 

struct VEC
    x   dd  ?
    y   dd  ?
ends

; ===============================================
section '.data' data readable writeable
    vec1            VEC     5,-4
    vec2            VEC     0c3h,-45h
    scalar_result   db  'Scalar product result: ',0
; ===============================================
section '.text' code readable executable
	
start:
    ; Invoke scalar product of vec1 and vec2:
    push    vec1
    push    vec2
    call    scalar_product
	
    ; Print result to the console:
    mov     esi,scalar_result
    call    print_str
    call    print_eax

    ; Exit the process:
	push	0
	call	[ExitProcess]


; =================================================
; scalar_product(v1,v2)
;
; Input:
;   v1,v2 vectors.
; Output:
;   (v1.x * v2.x) + (v1.y * v2.y)
; Calling Covention:
;   Data Stack
;

; **** Fill in this function ****
scalar_product:
	push	ebx 
	push	ecx 
	push	edx 
	
	xor 	ebx, ebx 		
	xor 	ecx, ecx 
	xor 	edx, edx 
			
	mov		eax, dword [esp + 8 + 0ch]	
	mov		ebx, dword [esp + 4 + 0ch]  
	
	mov		eax, dword [eax + VEC.x]
	mov		ebx, dword [ebx + VEC.x]
		
	mul		ebx 		
	mov		ecx, eax 						; ecx = v1.x * v2.x 
			
	xor 	edx, edx 
	mov		eax, dword [esp + 8 + 0ch]	
	mov		ebx, dword [esp + 4 + 0ch]  
	
	mov		eax, dword [eax + VEC.y] 
	mov		ebx, dword [ebx + VEC.y] 
		
	mul 	ebx 							; eax = v1.y * v2.y 
	add		eax, ecx 						; eax = (v1.x * v2.x) + (v1.y * v2.y)
	
	pop 	edx 
	pop		ecx
	pop		ebx 
	
	ret 	8 
	

include 'training.inc'
