
; 1.  Matrix Fibonacci

    ; A matrix is a two dimensional table of numbers.
    ; Assume we have two matrices of size 2X2:

    ; A =  | a  b |   ,    B = | e  f |
         ; | c  d |            | g  h |

    ; We define their multiplication to be the following 2X2 matrix:
    
    ; AB = | ae + bg   af + bh |
         ; | ce + dg   cf + dh |

    ; Example:

    ; For:  A = | 1 1 |  ,   B = | 1 1 |  We get:  AB = | 2 1 |
              ; | 1 0 |          | 1 0 |                | 1 1 |

    
    ; We define matrix powers to be repetitive multiplication. A matrix M to the
    ; power of k equals M*M*M...*M (k times). We also use the notation M^k to
    ; express the k-th power of the matrix M.

    ; Example:

            ; 2
    ; | 1 1 |     =   | 2 1 |
    ; | 1 0 |         | 1 1 |


    ; 0.    Consider the matrix  A = | 1 1 |
                                   ; | 1 0 |

          ; Convince yourself that  A^n = | F_{n+1}  F_n     |
                                        ; | F_n      F_{n-1} |

          ; Where F_n is the n-th element of the fibonacci series.

          ; Recall that the Fibonacci series is the series in which every element
          ; equals to the sum of the previous two elements. It begins with the
          ; elements: F_0 = 0, F_1 = 1, F_2 = 1, F_3 = 2, F_4 = 3, F_5 = 5.

    ; 1.    Define a struct to hold the contents of a 2X2 matrix. 
    
    ; 2.    Write a function that multiplies two matrices.

          ; HINTS: 
            ; How to take matrices as arguments?
            ; - Give the addresses of the matrices in memory as arguments.

            ; How to return a matrix from the function? There is more than one
            ; option:
            ; - You could supply a third argument to the function, which will be
              ; the address of the result.
            ; - You could override one of the matrices that you got as an
              ; argument with the result.


    ; 3.    Write a function that takes a matrix M and an integer k as arguments,
          ; and outputs M^k. (M to the power of k).

    ; 4.    Read the number n from the user, and output F_n. (Fibonacci element
          ; number n).

    ; 5.    Bonus: How many matrix multiplications does it take to calculate F_n
          ; using this method? Could you use less matrix multiplications?


format PE console 
entry start 

include 'win32a.inc'
	
struct Matrix
	a 	dd 	?
	b 	dd 	?
	c 	dd 	?
	d 	dd 	?
ends 	
	
INPUT_BUFFER_MAX_LEN = 20h

section '.data' data readable writeable 
	enter_number	db	'Enter the nth Fibonacci element: ',0
	matrix_val		db	'|%d, %d|',13,10
					db	'|%d, %d|',13,10,0
					
	fib_at_n_is		db	'F_%d is: %d',13,10,0
	
section '.bss' readable writeable
	input_buffer 	dd	INPUT_BUFFER_MAX_LEN 	dup	(?)
	bytes_read		dd 	?
	input_handle	dd	? 
	
	nth				dd 	?
	fib_based_matrix 	Matrix  1,1,1,0
	
section '.text' code readable executable 

start:	
	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov		dword [input_handle], eax 
	
	push	enter_number
	call	get_num
	add		esp, 4
	
	mov		dword [nth], eax
	
	push	dword [nth]
	push	fib_based_matrix 
	call	matrix_expo
	add		esp, 4*2
	
	push	dword [fib_based_matrix + Matrix.c]
	push	dword [nth]
	push	fib_at_n_is
	call	[printf]
	add		esp, 4*3 
	
	push	0
	call	[ExitProcess]

; matrix_expo(matrix_addr, exp)
matrix_expo:	
	.matrix_addr = 8h
	.exp = 0ch

	push	ebp
	mov		ebp, esp 
	
	pusha 
	
	sub		esp, 4*4
	
	mov		esi, dword [ebp + .matrix_addr]
	mov		ecx, dword [ebp + .exp]
	jecxz	.zero
	
	lea		edi, dword [ebp - 10h]	
		
	; Copy argument to the local var to persist the matrix
	mov		eax, dword [esi + Matrix.a]
	mov		dword [edi + Matrix.a], eax 
	
	mov		eax, dword [esi + Matrix.b]
	mov		dword [edi + Matrix.b], eax 
	
	mov		eax, dword [esi + Matrix.c]
	mov		dword [edi + Matrix.c], eax 
		
	mov		eax, dword [esi + Matrix.d]
	mov		dword [edi + Matrix.d], eax 
	
	dec		ecx 
.mul_loop:
	push	ecx 
	push	edi
	push	esi
	call	mul_matrix
	add		esp, 4*2 
	pop		ecx 	
		
	dec		ecx 
	cmp		ecx, 0
	jg		.mul_loop
	jmp		.end_func

.zero:
	mov		dword [esi + Matrix.a], 0
	mov		dword [esi + Matrix.b], 0
	mov		dword [esi + Matrix.c], 0
	mov		dword [esi + Matrix.d], 0
	
.end_func: 
	add		esp, 4*4
	popa 
	pop		ebp 

	ret 

; mul_matrix(matrix1_addr, matrix2_addr)
mul_matrix:
	.matrix1_addr = 8h
	.matrix2_addr = 0ch 
	
	push	ebp
	mov		ebp, esp
	
	pusha 
	
	sub		esp, 4*4
	
	mov		esi, dword [ebp + .matrix1_addr]
	mov		edi, dword [ebp + .matrix2_addr]
	
	; Computing [ae + bg]
	mov		eax, dword [esi + Matrix.a]
	mov		ebx, dword [edi + Matrix.a]
	mul		ebx
	mov 	ecx, eax 
	
	mov		eax, dword [esi + Matrix.b]
	mov		ebx, dword [edi + Matrix.c]
	mul		ebx
	add		eax, ecx 
	
	mov		dword [ebp - 4h], eax
	
	; Computing [af + bh]
	mov		eax, dword [esi + Matrix.a]
	mov		ebx, dword [edi + Matrix.b]
	mul		ebx 
	mov		ecx, eax 
	
	mov		eax, dword [esi + Matrix.b]
	mov		ebx, dword [edi + Matrix.d]
	mul		ebx 
	add		eax, ecx 
	
	mov		dword [ebp - 8h], eax
	
	; Computing [ce + dg]
	mov		eax, dword [esi + Matrix.c]
	mov		ebx, dword [edi + Matrix.a]
	mul		ebx 
	mov		ecx, eax 
	
	mov		eax, dword [esi + Matrix.d]
	mov		ebx, dword [edi + Matrix.c]
	mul		ebx 
	add		eax, ecx 
		
	mov		dword [ebp - 0ch], eax
	
	; Computing [cf + dh]
	mov		eax, dword [esi + Matrix.c]
	mov		ebx, dword [edi + Matrix.b]
	mul		ebx 
	mov		ecx, eax 
	
	mov		eax, dword [esi + Matrix.d]
	mov		ebx, dword [edi + Matrix.d]
	mul		ebx 
	add		eax, ecx 
	
	mov		dword [ebp - 10h], eax
	
	; Override matrix 1
	mov		eax, 	dword [ebp - 4h]
	mov		dword [esi + Matrix.a], eax
	mov		eax, 	dword [ebp - 8h]
	mov		dword [esi + Matrix.b], eax
	mov		eax, 	dword [ebp - 0ch]
	mov		dword [esi + Matrix.c], eax
	mov		eax, 	dword [ebp - 10h]
	mov		dword [esi + Matrix.d], eax
	
.end_func:
	add		esp, 4*4

	popa 
	pop		ebp
	ret 

; print_matrix(matrix_addr)
print_matrix:
	.matrix_addr = 8h
	
	push	ebp 
	mov		ebp, esp 
	
	pusha 
	mov		esi, dword [ebp + .matrix_addr]
	
	push	dword [esi + Matrix.d]
	push	dword [esi + Matrix.c]
	push	dword [esi + Matrix.b]
	push	dword [esi + Matrix.a]
	push	matrix_val
	call	[printf]
	add		esp, 4*5 

	
.end_func:	
	popa 
	
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