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
          
          ; 11 01 11 10
          ; 10 10 11 01
          ; 10 11 11 10
          ; 11 10 11 11 

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

PIC_SIZE = 0x4

section '.data' data readable writeable
	symbols		db		'*:#@',0
	enter_num	db		'Enter a number: ',0xd,0xa,0
	new_line	db		0xd,0xa,0
	
section '.bss' readable writeable
	pic			db		4*PIC_SIZE+2*3+1	dup (0)	
	pic_idx		dd		?
	
section '.text' code readable executable

start:
	mov		esi, enter_num
	call	print_str
	
	call	read_hex

	mov		edi, pic
	mov		esi, eax
	call	fill_pic
	
	mov		esi, new_line
	call	print_str
	
	mov		esi, pic
	call	print_str
	
	mov		esi, new_line
	call	print_str
	mov		esi, new_line
	call	print_str
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

;================================
; void fill_pic(char* pic, int num)
; 
; edi: char* pic
; esi: int num
;================================
fill_pic:
	pusha 
	
	mov		dword [pic_idx], 0
	mov		ecx, 0x14
.inner_loop:
	mov		eax, dword [pic_idx]
	cmp		eax, 0x4
	jz		.is_new_line
	cmp		eax, 0xa
	jz		.is_new_line
	cmp		eax, 0x10
	jz		.is_new_line
	
	rol		esi, 2
	
	mov		ebx, edi				; save char* pic
	mov		edx, esi				; and save num
		
	mov		eax, esi				; num 
	and		eax, 0x3				; num &= b11
	
	mov		edi, eax
	call	num_to_symbol
	
	mov		edi, ebx				; restore char* pic
	mov		esi, edx				; and restore num
		
	mov		ebx, dword [pic_idx]
	mov		byte [edi + ebx], al
	
	jmp		.skip_new_line
	
.is_new_line:
	mov		byte [edi + eax], 0xd
	mov		byte [edi + eax + 1], 0xa
	add		dword [pic_idx], 2
	jmp		.next
	
.skip_new_line:
	inc		dword [pic_idx]
.next:
	dec		ecx 
	jnz		.inner_loop
	
.done:	
	mov		eax, dword [pic_idx]
	mov		byte [edi + eax - 1], 0x0		

	popa 
	ret 


;================================
; char num_to_symbol(int num)
; 0 <= num <= 3 (2-bit num)
;
; edi: num
; eax: return char
;================================
num_to_symbol:
	push	esi
	
	
	cmp		edi, 0x3
	ja		.done
	mov		esi, symbols
	xor		eax, eax
	mov		al, byte [esi + edi]
	
.done:
	pop		esi
	ret


include 'training.inc'
