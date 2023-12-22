format PE console 
entry start

include 'win32a.inc'

section '.data' data readable writeable
	summerp			db 	'Welcome to the summer party!',13,10,0
	
section '.text' code readable executable 

start:
	mov		esi, summerp 
	call	print_str 
	
	push	1 
	push	2
	push 	4 
	push 	3 
	call	summer 
	
	
	
	
	
	
	push	0
	call	[ExitProcess]

; =============================================
; summer: sum up its arguments 
;  	
; Input:
;   arg count, and relevant arguments
; Output:
;   eax = sum up of arguments
; Operation:
;   the first argument is for the argument count, excluding itself.
; 	the actual argument for adding starts from the second arg until arg 
;   count.
summer:
	push	ecx 
	push	edi
	
	mov		ecx, dword [esp + 4 + 2*4]		; ecx = args count 
	lea		edi, [esp + 8 + 2*4] 			; edi = 1st arg address
	xor		eax, eax						; total = 0 
	
	jecxz	.no_args						; has no args?
.process_arg:
	add		eax, dword [edi]				
	add		edi, 4 
	loop	.process_arg
	
.no_args:									; yes, return 
	pop		edi
	pop		ecx 
	ret 
	
include '.training.inc'	
	
















	