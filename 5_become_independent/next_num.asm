format PE console 
entry start 

include 'win32a.inc'

MAX_INPUT_SIZE = 12 

section '.data' data readable writeable
	enter_number 	db 	'Please enter a number: ',0
	next_num		db 	'Please next number is %u, Such a nice number...'
					db	13,10,0
	
section '.bss' readable writeable 
	input_handle	dd 	?
	bytes_read		dd 	?
	number			dd 	?
		
	input_str 		dd 	MAX_INPUT_SIZE+1 dup (?) 


section '.text' code readable executable

start:
	push 	STD_INPUT_HANDLE 
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_number
	call	[printf]
	add		esp, 4
	
	push	0
	push 	bytes_read 
	push 	MAX_INPUT_SIZE
	push 	input_str
	push	dword [input_handle] 
	call	[ReadFile]

	mov		edi, input_str
	add		edi, MAX_INPUT_SIZE
	mov		byte [edi], 0
	
	
	push	10
	push	0
	push	input_str 
	call	[strtoul]
	add		esp,4*3
		
	mov		dword [number], eax 
	inc 	dword [number]  
	
	push	dword [number] 
	push 	next_num
	call	[printf]
	add		esp,4*2
	
	push	0
	call	[ExitProcess]


section '.idata' import data readable 
	
library kernel32,'kernel32.dll',\	
		msvcrt,'msvcrt.dll' 
		
import 	kernel32,\
		ExitProcess,'ExitProcess',\
		GetStdHandle,'GetStdHandle',\
		ReadFile,'ReadFile'

import	msvcrt,\
		printf,'printf',\
		strtoul,'strtoul' 