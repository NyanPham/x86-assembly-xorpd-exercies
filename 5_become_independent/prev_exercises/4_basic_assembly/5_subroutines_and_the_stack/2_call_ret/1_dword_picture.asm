; 1.  Dword picture
    
    ; Given a dword x, we create a corresponding ASCII picture.
    ; We use the following procedure:

    ; 0.  We look at the binary representation of x, and divide it to pairs of
        ; bits. We then order the pairs of bits in a square of size 4 X 4.

        ; Example: 
          ; For the dword 0xdeadbeef, we get:
          ; 0xdeadbeef = 11011110101011011011111011101111
          ; 0xdeadbeef = 11 01 11 10 10 10 11 01 10 11 11 10 11 10 11 11

          ; Ordered in a square:
          
          ; 11 01 11 10 	4, 5
          ; 10 10 11 01		10, 11
          ; 10 11 11 10		16, 17
          ; 11 10 11 11 	22, 23

    ; 1.  Next we convert every pair of bits into one ASCII symbol, as follows:

        ; 00 -> *
        ; 01 -> :
        ; 10 -> #
        ; 11 -> @

        ; Example:
          ; For the dword 0xdeadbeef, we get the following interesting picture:

          ; @:@#
          ; ##@:
          ; #@@#
          ; @#@@

    ; Write a program that takes a dword x as input, and prints the corresponding
    ; picture representation as output.

    ; HINT: Organize your program using functions:

      ; - Create a function that transforms a number into the ASCII code of the
        ; corresponding symbol. {0 -> * , 1 -> : , 2 -> # , 3 -> @}

      ; - Create a function that takes as arguments an address of a buffer and a
        ; number x. This function will fill the buffer with the resulting ascii
        ; picture. Make sure to leave room for the newline character sequences,
        ; and for the null terminator.

      ; - Finally allocate a buffer on the bss section, read a number from the
        ; user and use the previous function to fill in the buffer on the bss
        ; section with the ASCII picture. Then print the ASCII picture to the
        ; user.
		


format PE console 
entry start 

include 'win32a.inc'
	
INPUT_BUFFER_MAX_LEN = 20h
DWORD_PIC_BUFFER_LEN = 19h

section '.data' data readable writeable 
	enter_number	db	'Please enter a number: ',0
	linebreak		db 	 13,10,0
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	number 			dd	?
	
	dword_pic_buffer 	db	DWORD_PIC_BUFFER_LEN dup (?)
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_number
	call	get_num
	add		esp, 4
	
	mov		dword [number], eax
	
	push	linebreak
	call	[printf]
	add		esp, 4 
	
	push	dword [number] 
	push 	dword_pic_buffer
	call	draw_dword_pic
	add		esp, 4
	
	push	dword_pic_buffer
	call	[printf]
	add		esp, 4
	
	push	0
	call	[ExitProcess]

draw_dword_pic: 
	.pic_buffer = 8h
	.num = 0ch
	
	push	ebp
	mov		ebp, esp
	
	pusha 
	
	mov		edi, dword [ebp + .pic_buffer]
	xor 	esi, esi 
	mov		ebx, dword [ebp + .num]
	
	xor		eax, eax
	mov		ecx, 16d
	mov		edx, 4
.fill_buffer_loop:
	clc 
	shl		ebx, 1
	jnc		.shift_bit_2
	inc		eax 
	shl		eax, 1 
	
.shift_bit_2:
	clc		
	shl		ebx, 1 
	jnc		.done_shift
	inc		eax 

.done_shift:
	; eax has the upper 2 bits of the number, value 0 -> 3 
	
	push	eax
	call	num_to_special
	add		esp, 4
	
	; Store eax into the current cell
	mov		byte [edi + esi], al
		
	; Reset eax for the next cell
	xor		eax, eax 
	inc		esi
	
	; If edx == 0, we complete a row of 4 cells.
	; Then we need to fill the next 2 index with 13 and 10
	dec		edx 
	jnz		.next_iter
	
	mov		byte [edi + esi], 13
	inc		esi
	mov		byte [edi + esi], 10	
	inc		esi
	
	mov		edx, 4
.next_iter:	
	dec		ecx
	jnz		.fill_buffer_loop
		
	; The last byte should be null terminated 
	mov		byte [edi + esi], 0
	
.end_func:
	popa 
	
	pop		ebp
	ret 

; num_to_special(num)
num_to_special:
	.num = 8h
	
	push	ebp
	mov		ebp, esp
	
	mov		eax, dword [ebp + .num]
	cmp		eax, 0
	jl		.end_func
	cmp		eax, 3
	jg		.end_func

	cmp		eax, 0
	je		.is_star
	cmp		eax, 1
	je		.is_colon 
	cmp		eax, 2
	je		.is_hash
	jmp		.is_at
	
.is_star:
	mov		eax, 2ah
	jmp		.end_func 

.is_colon:
	mov		eax, 3ah
	jmp		.end_func

.is_hash:	
	mov		eax, 23h
	jmp		.end_func
	
.is_at:
	mov		eax, 40h
	
.end_func:
	pop		ebp
	ret 
	
; get_num(prompt_addr)
get_num:
	.prompt_addr = 8h
	
	push	ebp 
	mov		ebp, esp 
		
	push	dword [ebp + .prompt_addr]
	call	[printf]
	add		esp, 4 
	
	push	INPUT_BUFFER_MAX_LEN
	push	bytes_read
	push	input_buffer 
	call	get_line
	add		esp, 4*3
	
	push	input_buffer 
	call	str_to_dec
	add		esp, 4
	
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
	
; str_to_dec(str_addr)
str_to_dec:
	.str_addr = 8h 
	
	push	ebp
	mov		ebp, esp 
	
	push	10
	push	0
	push	dword [ebp + .str_addr]
	call 	[strtoul]
	add		esp, 4*3 
	
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
