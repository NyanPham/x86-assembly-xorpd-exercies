; Basic Assembly
; ==============
; 
; Subroutines and the stack - Calling conventions
; -----------------------------------------------
; 
; Scalar product
; @@@@@@@@@@@@@@
;    
; 0.    Skim the code. Take a look at the functions and their descriptions.
;       Understand the dependencies between the functions (Which function calls
;       which function), and what is the special purpose of every function.
;
; 1.    Read the main code (Beginning from start), and see how the function
;       scalar_product is being called. Which calling convention is being used?
;
; 2.    Fill in the scalar_product function. This function calculates the scalar
;       product (Sometimes referred to as inner product) between two vectors.
;       See exact formula in the comments below.
;       
;       Note that you may only fill in the scalar_product function. Do not
;       change the rest of the code.
;       
;       Make sure that you deal with arguments and the stack according to the
;       correct calling convention. Think about the following:
;       - Who should clean the stack?
;       - Where should the return value be?
;       - Saving registers to the stack, so that your function will not have
;         side effects.
;
; 3.    Assemble and run the code. Verify the result that you get.
;
;       Just to be sure, check the value of esp before and after
;       the call to scalar_product, to verify that the stack is balanced.
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
    scalar_result   db  	'Scalar product result: %d',13,10,0
	
; ===============================================
section '.text' code readable executable
	
start:
    ; Invoke scalar product of vec1 and vec2:
    push    vec1
    push    vec2
    call    scalar_product
	
    ; Print result to the console:
	push	eax
	push	scalar_result
	call	[printf]
	add		esp, 4*2
		
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
;   STDCALL
;
	
scalar_product:
	.v2 = 8h
	.v1 = 0ch
		
	push	ebp
	mov		ebp, esp
	
	push	esi
	push	edi
	push	ebx 
	
	mov		esi, dword [ebp + .v1]
	mov		edi, dword [ebp + .v2]
		
	xor		edx, edx 
	
	mov		eax, dword [esi + VEC.x]
	mul		dword [edi + VEC.x]
	mov		ebx, eax 
	
	xor		edx, edx 
	
	mov		eax, dword [esi + VEC.y]
	mul		dword [edi + VEC.y]
	add		eax, ebx
		
.end_func:
	pop		ebx 
	pop		edi
	pop		esi

	pop		ebp 
	ret 	4*2

section '.idata' data import readable 

library kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import	kernel32,\
		ExitProcess,'ExitProcess'
		
import	msvcrt,\
		printf,'printf'

