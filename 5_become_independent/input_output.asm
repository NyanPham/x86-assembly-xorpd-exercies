format PE console 
entry start

include 'win32a.inc'

MAX_INPUT_SIZE = 20h 

section '.bss' readable writeable
	input_handle 	dd 	?
	output_handle	dd 	? 
	
	bytes_read		dd	? 
	bytes_written 	dd 	? 
	
	input_str 		db 	MAX_INPUT_SIZE dup (?)
	
section '.text' code readable executable

start:
	push 	STD_INPUT_HANDLE
	call 	[GetStdHandle] 
	mov 	dword [input_handle], eax 
	
	push 	STD_OUTPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [output_handle], eax 
		
	push 	0
	push 	bytes_read 
	push	MAX_INPUT_SIZE 
	push	input_str 
	push 	dword [input_handle]  
	call	[ReadFile] 	
		
	push	0
	push	bytes_written
	push	dword [bytes_read]
	push	input_str 
	push	dword [output_handle]
	call	[WriteFile]
		
	push	0 
	call	[ExitProcess]
	
section '.idata' import data readable
	
library kernel32, 'kernel32.dll'
	
import 	kernel32,\
		GetStdHandle, 'GetStdHandle',\
		ReadFile, 'ReadFile',\
		WriteFile, 'WriteFile',\
		ExitProcess, 'ExitProcess' 
	 