; 4.  Substring

    ; Write a program that asks the user for two strings: s1,s2. 
    
    ; The program then searches for all the occurrences of s2 inside s1, and prints
    ; back to the user the locations of all the found occurrences.
	
    ; Example:
      
      ; Input:  s1 = 'the colors of my seas are always with me.'
              ; s2 = 'th'

      ; Search: s1 = 'the colors of my seas are always with me.'
                    ; th                                 th
                    ; 00000000000000001111111111111111222222222
                    ; 0123456789abcdef0123456789abcdef012345678

      ; Output: Substring was found at locations:
              ; 0
              ; 23 (23 hex ==> 35d)


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 40h

section '.data' data readable writeable 
	enter_str		db	'Please enter a string: ',0
	enter_sub		db	'Enter a substring to search: ',0
	substr_result	db	'Substring was found at locations: ',13,10,0
	index_res		db	'%d',13,10,0
	
section '.bss' readable writeable
	bytes_read		dd 	?
	input_handle	dd	? 
	
	main_string			db	INPUT_BUFFER_MAX_LEN 	dup (?)
	main_string_len		dd	? 
	sub_string			db	INPUT_BUFFER_MAX_LEN	dup (?)
	sub_string_len		dd	?
	
	found_indices 		db	INPUT_BUFFER_MAX_LEN	dup (0)
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_str
	call	[printf]
	add		esp, 4
	
	push	INPUT_BUFFER_MAX_LEN
	push	main_string_len
	push	main_string
	call	get_line
	add		esp, 4*3 
	
	push	enter_sub
	call	[printf]
	add		esp, 4
	
	push	INPUT_BUFFER_MAX_LEN
	push	sub_string_len
	push	sub_string
	call	get_line
	add		esp, 4*3 
	
	push	dword [sub_string_len]
	push	sub_string
	push	dword [main_string_len]
	push	main_string
	push	found_indices
	call	find_sub_string_indices
	add		esp, 4*5
	
	push	INPUT_BUFFER_MAX_LEN
	push	found_indices
	call 	print_found_indices
	add		esp, 4*2
	
	push	0
	call	[ExitProcess]
	
; print_found_indices (arr_addr, arr_len)
print_found_indices:
	.arr_addr = 8h
	.arr_len = 0ch
	
	push	ebp 
	mov		ebp, esp
	
	pusha 
	
	push	substr_result
	call	[printf]
	add		esp, 4
	
	mov		esi, dword [ebp + .arr_addr]
	mov		ecx, dword [ebp + .arr_len]
	xor		ebx, ebx
.print_loop:
	movzx	eax, byte [esi + ebx]
	test	eax, eax 
	jz	 	.next_iter
	
	pusha 
	push	ebx 
	push	index_res 
	call	[printf]
	add		esp, 4*2 
	popa 
	
.next_iter:	
	inc		ebx 
	dec		ecx 
	jnz		.print_loop
	
.end_func:
	popa 
	pop		ebp 
	ret 
	
; find_sub_string_indices(found_indices_addr, str_addr, str_len, substr_addr, substr_len)
find_sub_string_indices:
	.found_indices_addr = 8h
	.str_addr = 0ch
	.str_len = 10h
	.substr_addr = 14h
	.substr_len = 18h
	
	push	ebp 
	mov		ebp, esp
	
	pusha 
	sub		esp, 4
	
	mov		esi, dword [ebp + .str_addr]
	mov		edi, dword [ebp + .substr_addr]
	xor 	ebx, ebx
	
.find_loop:
	mov		dword [ebp - 4], ebx
	
.check_next_char_same:
	movzx	eax, byte [esi]
	cmp		eax, 0
	jz		.end_func 
	
	cmp		al, byte [edi]
	jnz		.next_iter

	inc		ebx
	inc		esi
	
	inc		edi
	movzx	eax, byte [edi]
	cmp		eax, 0
	jz		.push_index 
	
	jmp 	.check_next_char_same
	
.push_index:	
	push	ebx
	mov		ebx, dword [ebp - 4]
	mov		eax, dword [ebp + .found_indices_addr]
	mov		byte [eax + ebx], 1
	mov		edi, dword [ebp + .substr_addr]
	pop		ebx
	
	dec		ebx 
	dec		esi
	
.next_iter:
	mov		edi, dword [ebp + .substr_addr]

	inc		ebx
	inc		esi
	jmp		.find_loop
	
	
.end_func:
	add		esp, 4 

	popa 
	
	pop		ebp
	ret 
	
; get_line(input_buffer, bytes_read, bytes_to_read)
get_line:
	.input_buffer = 8h
	.bytes_read = 0ch
	.bytes_to_read = 10h
	
	push	ebp 
	mov		ebp, esp
	
	pusha
	
	mov		ecx, dword [ebp + .bytes_read]
	mov		esi, dword [ebp + .input_buffer]
	
	push	0
	push	ecx 
	push	dword [ebp + .bytes_to_read]
	push	esi 
	push	dword [input_handle]
	call	[ReadFile]
	
	mov		ebx, dword [ebp + .bytes_read]
	
	mov		eax, dword [ebx]
	mov		byte [esi + eax], 0
	dec		eax 
	mov		byte [esi + eax], 0
	dec		eax
	mov		byte [esi + eax], 0
	inc 	eax 
	
	mov		dword [ebx], eax 

.end_func:
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
		printf,'printf'