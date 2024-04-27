; 2.  Find yourself
    
    ; Write a program that finds the current value of EIP and prints it to the
    ; console.

    ; HINT: Use CALL.
	
	; Explanation: When we use CALL, the EIP value (address of the current instruction) 
	; is stored in the stack. So calling get_eip pushes the eip address to esp. In the subroutine
	; we get the esp using eax. Finally return.
	;
format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	current_eip_is		db	'The current value of EIP is: %p',13,10,0

section '.text' code readable executable 

start:	
	call	get_eip
	
	
	; To this point, eax doesn't store the value
	; of EIP anymore, but it's a deal
	push 	eax 
	push	current_eip_is
	call	[printf]
	add		esp, 4*2
	
	push	0
	call	[ExitProcess]
	
get_eip:
	mov		eax, dword [esp]
	ret 


section '.idata' data import readable 

library kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import	kernel32,\
		ExitProcess,'ExitProcess'
			
import	msvcrt,\
		printf,'printf'