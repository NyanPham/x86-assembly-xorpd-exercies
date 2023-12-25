; Basic Assembly
; ==============
; 
; Subroutines and the stack - Local state
; ---------------------------------------
; 
; Minggatu
; @@@@@@@@
;
; 0.    Assemble and run this program.
;
; 1.    Give the program some example inputs, and observe the output.
;
; 2.    Skim the code. Take a look at the functions and their descriptions.
;       Understand the dependencies between the functions (Which function calls
;       which function), and what is the special purpose of every function.
;
; 3.    Read the program's code below, and try to understand what does it do. 
;       Try to describe it as simply as you can. Add comments if needed.
;
;       Fill in briefly the Input, Output and Operation comments for every
;       function in the code.
;
; 4.    Bonus: What is the meaning of the output numbers? Can you find a closed
;       formula for those numbers?
;		=> Catala numbers 
;
	
format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.data' data readable writeable
    wanted_elem     db  'Enter wanted element number: ',0
    elem_value      db  'Wanted element value: ',0

; ===============================================
section '.text' code readable executable

start:
    mov     esi,wanted_elem
    call    print_str
    call    read_hex
	
    push    eax							; pass the input as an index 
    call    calc_num					; call subrouinte 
    add     esp,4						; clear the argument from stack 

    mov     esi,elem_value
    call    print_str
    call    print_eax

    ; Exit the process:
    push    0
    call    [ExitProcess]

; ===============================================
; calc_num(index)
;
; Input:
;   index as a length of the whole list 
; Output:
;   eax at the indexed value
; Operation:
;   fill in the next item in array to get the last result at indexed cell
;
calc_num:	
    .index = 8										; .index argument starts at 8th byte (4th byte is the return address of subroutine)
    push    ebp										; store old ebp of any previous subroutine
    mov     ebp,esp									; set current stack frame 
	
    push    ecx					
    push    esi
    push    ebx

    mov     ecx,dword [ebp + .index]				; ecx = index 
    lea     ebx,[4*ecx]								; ebx = dword stack from by index, this is the amount of dword to declare local variables 
    sub     esp,ebx									; preserve the space for the local variables
    mov     esi,esp									; esi = current stack pointer (the beginning of the stack)

    xor     ebx,ebx									; ebx = total 
    mov     eax,1									; eax starts as 1

.calc_next_num:
    ; Store the result into the array:
    mov     dword [esi + 4*ebx],eax					; store eax value into next position in the stack 
    
    inc     ebx										; increase index of the array 
    push    ebx										; pass argument index 
    push    esi										; pass the array address 
    call    calc_next								
    add     esp,4*2									; clear argument offset from stack
	
    cmp     ebx,ecx									; are we at the end of the list just yet? 
    jb      .calc_next_num							; no, continue iteration
    
    mov     ecx,dword [ebp + .index]				; yes, ecx = index 
    lea     ebx,[4*ecx]								; ebx = amount of bytes to offset 
    add     esp,ebx									; clear local variables 

    pop     ebx										
    pop     esi
    pop     ecx

    pop     ebp
    ret

; ===============================================
; calc_next(arr_addr,arr_len)
;
; Input:
;   array address and array length of filled positions 
; Output:
;   eax = value for the next cell of out range of length 
; Operation:
;   Do catalan calculation to get value at the next index
;
calc_next: 
    .arr_addr = 8									; offset of	array address 
    .arr_len = 0ch									; offset of array length 
    push    ebp										; store old ebp (in this case, the calling in the loop in calc_next_num)
    mov     ebp,esp									; make inner stake frame in calc_next 

    push    ebx										; 
    push    ecx
    push    esi
    push    edi
    push    edx
			
    mov     ecx,dword [ebp + .arr_len]				; ecx = current index = length to process 
    jecxz   .arr_len_zero							; is zero? yes then end 
    mov     esi,dword [ebp + .arr_addr]				; no, esi = addresss of the array (beginning of the list) 
    mov     edi,dword [ebp + .arr_addr]				; edi = addresss of the array (beginning of the list) 
    lea     edi,[edi + 4*ecx - 4]					; edi = address of the last element (start address + (length - 1)) * 4) 
			
    xor     ebx,ebx	
.next_mul:
    mov     eax,dword [esi]							; eax = value at index 0
    mul     dword [edi]								; mul with value in indexed one
    add     ebx,eax									; store result in ebx 				
    add     esi,4									; esi advance 
    sub     edi,4									; edi retreat 
    loop    .next_mul								; not end yet, continue the multiplication iteration
	
    mov     eax,ebx
    jmp     .end_func								; return eax with value for next cell to store.
.arr_len_zero:
    xor     eax,eax
.end_func:
    
    pop     edx
    pop     edi
    pop     esi
    pop     ecx
    pop     ebx

    pop     ebp
    ret

include 'training.inc'
