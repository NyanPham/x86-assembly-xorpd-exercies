format PE GUI 4.0
entry start 

include 'win32a.inc'

section '.data' data readable writeable
	welcome_body		db	'Welcome to this program!',0
	welcome_title		db 	'Important message',0
	
	question_body		db 	'Do you like bananas?',0
	question_title		db 	'Question',0
	
	answer_yes_body		db 	'Bring on the bananas!',0
	answer_yes_title	db	'Yesss!',0
	
	answer_no_body		db 	'So disappointing...',0
	answer_no_title		db 	'Ohh',0
	
section '.text' code readable executable

start:
	push	MB_OK or MB_ICONINFORMATION
	push	welcome_title
	push	welcome_body 
	push	0
	call	[MessageBoxA]
	
	push	MB_YESNO or MB_ICONQUESTION 
	push	question_title
	push	question_body
	push	0
	call	[MessageBoxA] 
		
	cmp 	eax, IDYES
	jz 		.like_bananas 
	
	push	MB_OK or MB_ICONHAND
	push	answer_no_title
	push	answer_no_body
	push	0
	call	[MessageBoxA]
		
	jmp 	.end_prog
		
.like_bananas:
	push 	MB_OK or MB_ICONEXCLAMATION 
	push	answer_yes_title
	push	answer_yes_body
	push	0
	call	[MessageBoxA]
	
.end_prog:
	push	0
	call	[ExitProcess]

	
section '.idata' import data readable

library	kernel32,'kernel32.dll',\
		user32,'user32.dll'
		
import 	kernel32,\
		ExitProcess,'ExitProcess'

import	user32,\
		MessageBoxA,'MessageBoxA'
	
	