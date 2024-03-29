; 0.2 Write a program that finds every double word (4 bytes) that satisfies the
; following condition: When decomposed into 4 bytes, if we multiply those
; four bytes, we get the original double word number.
	
format PE console 
entry start 

include 'win32a.inc'

section '.data' data readable writeable 
	value			db 	'%d',13,10,0
	
section '.text' code readable executable 

start:	
	call	find_4_bytes_original
		
	push	0
	call	[ExitProcess]

find_4_bytes_original:
	push	ebp 
	mov		ebp, esp
	
	pusha
	mov ecx, 0x10101010

.find_loop:
	push	ecx 

	push	ecx 
	call	multiply_bytes
	add		esp, 4 
		
	pop		ecx 
	cmp		eax, ecx 
	jne		.not_equal
	
	call	print_eax 

.not_equal:
	cmp		ecx, 0xffffffff
	jz		.end_func
		
	inc		ecx 
	jmp		.find_loop

.end_func:
	popa
	pop		ebp 
	ret 

; multiply_bytes(num)
multiply_bytes:
	.num = 8h
	
	push	ebp 
	mov		ebp, esp
	
	push	ebx 
	push	ecx 
	push	edx 
	push	esi 
	
	xor		ebx, ebx
	xor		ecx, ecx
	xor		edx, edx
	xor		esi, esi
	
	mov		ecx, dword [ebp + .num]
	
	movzx	eax, cl 
	mul		ch 				; multily byte 4 and byte 3 
	
	xor		edx, edx 
	mov		ebx, ecx 
	shr		ebx, 16d 		; shift right 2 bytes to get the high bytes 
	movzx	esi, bl
	mul		esi
		
	xor		edx, edx 
	movzx 	esi, bh 
	mul		esi
	
.end_func:
	pop		esi
	pop		edx 
	pop		ecx 
	pop		ebx 
	
	pop		ebp 
	ret 
	
	
print_eax:
	push	ebp
	mov		ebp, esp 
	pusha 
	
	push	eax 
	push	value
	call	[printf]
	add		esp, 4*2
	
	popa
	pop		ebp
	ret 

section '.idata' data import readable 

library kernel32,'kernel32.dll',\
		msvcrt,'msvcrt.dll'
		
import	kernel32,\
		ReadFile,'ReadFile',\
		GetStdHandle,'GetStdHandle',\
		ExitProcess,'ExitProcess'
		
import	msvcrt,\
		printf,'printf',\
		strtoul,'strtoul'