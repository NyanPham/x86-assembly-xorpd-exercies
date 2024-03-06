format PE console
entry start

include 'win32a.inc'

section '.data' data readable writeable 
	my_str 	db 	'I am just a small string in the big world.',0
	
	ssize 	db 	'The length of my_str is 0x%x characters.',13,10
			db 	'Its first character is: %c.',13,10,0

section '.text' code readable executable 

start:
	push	my_str
	call	[strlen]
	add		esp, 4 
	
	movzx 	edx, byte [my_str]
	
	push	edx
	push	eax 
	push	ssize
	call	[printf]
	add		esp,4*3
	
	push	0
	call	[ExitProcess] 


section '.idata' import data readable

library kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll' 
		
import 	kernel32,\
		ExitProcess,'ExitProcess'
			
import 	msvcrt,\
		strlen,'strlen',\
		printf,'printf' 