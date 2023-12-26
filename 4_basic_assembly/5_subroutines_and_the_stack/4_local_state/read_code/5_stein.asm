format PE console
entry start

;===========================================================================
; This code uses the Stein's algorithm to find the GCD of numbers a and b
;===========================================================================

include 'win32a.inc' 

; ===============================================
section '.data' data readable writeable
    enter_two       db  'Enter two numbers:',13,10,0
    result          db  'Result: ',0
; ===============================================
section '.text' code readable executable

start:
    ; Ask for two numbers:
    mov     esi,enter_two
    call    print_str

    ; Read two numbers:
    call    read_hex
    mov     edx,eax
    call    read_hex

    ; Calculate result:
    push    eax
    push    edx
    call    stein
    add     esp,2*4

    ; Print result:
    mov     esi,result
    call    print_str
    call    print_eax

    ; Exit the process:
	push	0
	call	[ExitProcess]

; ===========================================================
; stein(a,b)
;
; Input:
;   number a and number b 
; Output:
;   Greatest Common Divisor between a & b 
; Operations:
;   continuously check a and b if they are odd/even 
;	if a is even => a = a / 2
;   if b is even => b = b / 2
;	if both are odd, a = |a - b| / 2
;	continue until any a or b is 0, the remainder is the GCD 
;

stein:
    .a = 8
    .b = 0ch
    enter   0,0
    push    esi
    push    edi
    push    ecx
    push    ebx

    mov     esi,[ebp + .a]
    mov     edi,[ebp + .b]

    mov     eax,esi						; b = 0?
    test    edi,edi							
    jz      .end_func					; yes, return a
	
    mov     eax,edi						; a = 0?
    test    esi,esi						; return b
    jz      .end_func
	
    xor     ebx,ebx						; ebx = 0
	
    mov     ecx,esi					
    not     ecx							
    and     ecx,1						; a is odd? if yes ecx = 0, else ecx = 1 
    shr     esi,cl						; if a is even, divide a by 2
    add     ebx,ecx
		
    mov     ecx,edi						
    not     ecx
    and     ecx,1
    shr     edi,cl						; b is odd? if yes ecx = 0, else ecx = 1
    add     ebx,ecx						; if b is even, divide b by 2 

    test    ebx,ebx						; a and b are both odd?
    jnz     .not_both_odd				; no, stein next 

    cmp     esi,edi						; a > b?
    jae     .a_bigger_equal				; no, exchange a and b 
    xchg    esi,edi         ; Exchanges the contents of esi,edi
.a_bigger_equal:
				
    sub     esi,edi						; a = a - b 
    shr     esi,1						; a = a / 2 
.not_both_odd:
    push    edi
    push    esi
    call    stein
    add     esp,4*2

    mov     ecx,ebx
    shr     ecx,1
    shl     eax,cl

.end_func:
    pop     ebx
    pop     ecx
    pop     edi
    pop     esi

    leave
    ret

include 'training.inc'
