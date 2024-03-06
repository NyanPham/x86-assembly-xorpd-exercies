format PE console 
entry start

include 'win32a.inc'

MAX_INPUT_SIZE = 20h

section '.data' data readable writeable
	filename 		db 	'my_file.txt',0
	
section '.bss' readable writeable
	input_handle 	dd 	?
	file_handle 	dd	? 
	
	bytes_read		dd 	?
	bytes_written	dd 	? 
	
	input_str 		db	MAX_INPUT_SIZE 	dup (?)

section '.text' code readable executable

start:
	push 	STD_INPUT_HANDLE
	call 	[GetStdHanldle]
	mov  	dword [input_handle], eax 
	
	push	0
	push 	bytes_read
	push	MAX_INPUT_SIZE 
	push	input_str
	push 	dword [input_handle]
	call	[ReadFile]
	
	push0
	
section '.idata' import data readable 

library kernel32, 'kernel32.dll'

import 	kernel32,\
		GetStdHandle, 'GetStdHandle',\
		ReadFile, 'ReadFile',\
		CreateFileA, 'CreateFileA',\
		WriteFile, 'WriteFile',\
		CloseHandle, 'CloseHandle',\
		ExitProcess, 'ExitProcess'