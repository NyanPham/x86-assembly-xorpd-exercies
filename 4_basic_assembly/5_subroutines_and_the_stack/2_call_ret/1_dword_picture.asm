format PE console
entry start

include 'win32a.inc'

BUFFER_LENGTH = 10h
NEWLINES_LENGTH = 4h
	
section '.data' data readable writeable
	enter_hex		db		'Please enter a hex number: ',0
	newline 		db		13,10,0
	picture_is		db		'The dword picture is: ',13,10,0
	
	star			db		'*',0
	colon			db 		':',0
	hash			db 		'#',0
	atSign			db		'@',0 
	
section '.bss' readable writeable
	buffer 			db		BUFFER_LENGTH + NEWLINES_LENGTH + 1 	dup ('*')	
	BUFFER_LENGTH 	=	($ - buffer) 
	
section '.text' code readable executable
		
start:
	call	read_hex 
	call	split_fill_buffer
		
	mov		esi, picture_is
	call	print_str 
			
	mov		esi, buffer	 
	call	print_str 
		
	push	0
	call	[ExitProcess]
	
	
;====================================================
; Transform a number of 2 bits into the ASCII code
; Input: eax = 2 bits to convert 
; Operation: acts as a map to return a corressponding 
; 			ASCII char 
; Ouput: eax = ASCII char
;====================================================
bits_2_ascii:
	test 	al, al 
	jz 		.is_star
	cmp		al, 1h
	je 		.is_colon
	cmp		al, 2h
	je		.is_hash 
	cmp		al, 3h
	je 		.is_at 
	jmp 	.convert_done
.is_star:
	mov		al, byte [star] 
	jmp		.convert_done
.is_colon:
	mov		al, byte [colon] 
	jmp		.convert_done
.is_hash:
	mov		al, byte [hash] 
	jmp		.convert_done
.is_at:
	mov		al, byte [atSign]
.convert_done:
	ret 
	
;====================================================
; Split bits pairs and fill buffer
; Input: eax = the hex number to split into bit pairs
; Operation: convert each pair into ascii char 
;			and fill in the 
; Ouput: eax = ASCII char
;====================================================
split_fill_buffer:
	push 	eax 
	push	ebx 
	push	ecx 
	push	edx 
	
	mov		ebx, eax 
	mov		esi, buffer 
	mov		edi, BUFFER_LENGTH + NEWLINES_LENGTH
	xor 	ecx, ecx 
	
.split_or_newline:
	push	ecx 
	xor		edx, edx  
	mov		eax, ecx  
	
	mov		ecx, 6
	div		ecx 
	test	edx, edx 
	jnz		.split
		
	pop		ecx 
	mov		ax, word [newline]
	mov		word [esi + ecx], ax 
	inc 	ecx 
	jmp		.check_next 
	
.split:
	pop		ecx 
	xor		eax, eax 
	shl		ebx, 1 
	rcl		al, 1
	shl		ebx, 1 
	rcl		al, 1
	
	call	bits_2_ascii
	mov		byte [esi + ecx], al 
	
.check_next:
	inc		ecx 
	cmp		ecx, edi 
	jbe		.split_or_newline

.split_fill_done:
	mov		ecx, BUFFER_LENGTH + NEWLINES_LENGTH + 1
	mov		byte [esi + ecx], 0 
	
	pop		edx 
	pop		ecx 
	pop		ebx
	pop		eax 
	
	ret 
	
include 'training.inc'