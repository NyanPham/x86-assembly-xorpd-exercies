format PE console 
entry start
	
include 'win32a.inc'
	
section '.data' data readable writeable 
	s_date 	db 	'The date is %d/%d/%d,',13,10
			db	'Have a great day!',13,10,0
					 
section '.bss' readable writeable 
	systime 	SYSTEMTIME 		?
	
section '.text' code readable executable
	
start:
	push	systime 
	call	[GetSystemTime] 
	
	movzx 	eax, word [systime.wYear]
	push	eax 
	movzx 	eax, word [systime.wMonth]
	push	eax 
	movzx 	eax, word [systime.wDay]
	push	eax 
	push	s_date 
	call	[printf]
	add		esp,4*4 
	
	push	0
	call	[ExitProcess]
		

section '.idata' import data readable 

library	kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import 	kernel32,\
		ExitProcess,'ExitProcess',\
		GetSystemTime,'GetSystemTime' 
			
import 	msvcrt,\
		printf,'printf'