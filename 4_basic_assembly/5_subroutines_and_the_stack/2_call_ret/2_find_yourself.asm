; 2.  Find yourself
    
    ; Write a program that finds the current value of EIP and prints it to the
    ; console.

    ; HINT: Use CALL.

format PE console 
entry start 

include 'win32a.inc'

section '.data' data readable writeable
	current_eip		db		'The current value of EIP is ',0

section '.text' code readable executable

start:
	mov		esi, current_eip
	call	print_str 
	call	get_eip 
	call	print_eax 
	
get_eip:
	mov		eax, [esp]
	ret 
	
include 'training.inc'