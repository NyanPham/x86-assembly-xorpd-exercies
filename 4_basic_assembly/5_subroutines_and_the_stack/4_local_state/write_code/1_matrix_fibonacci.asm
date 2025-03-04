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

; ==> Need time to anaylize the 5. Bonus
;

format PE console
entry start

include 'win32a.inc' 

struct MATRIX
	a	dd	?
	b	dd	?
	c	dd	?
	d	dd 	?
ends

section '.data' data readable writeable
	enter_k				db		'Enter the k of fibonacci: ',0
	init_matrix			MATRIX 	1,1,1,0
	result_is			db		'The fibonacci is: ',0
	
section '.bss' readable writeable
	res_matrix		MATRIX		?
	
section '.text' code readable executable

start:
	mov		esi, enter_k
	call	print_str
	
	call	read_hex
	
	push	res_matrix
	push	eax
	push	init_matrix
	call	matrix_power
	add		esp, 4*3
	
	mov		esi, result_is
	call	print_str
	
	mov		eax, dword [res_matrix.b]
	call	print_eax

    ; Exit the process:
	push	0
	call	[ExitProcess]

;======================================================
; mul_matrices(matrix_1_addr, matrix_2_addr, res_addr)
;======================================================
mul_matrices:
	.matrix_1_addr = 0x8
	.matrix_2_addr = 0xc
	.res_addr = 0x10
	.local_res = -sizeof.MATRIX
	
	push	ebp
	mov		ebp, esp
	
	sub		esp, sizeof.MATRIX
	
	pusha
	
	mov		esi, dword [ebp + .matrix_1_addr]
	mov		edi, dword [ebp + .matrix_2_addr]
		
	; matrix_1.a * matrix_2.a + matrix_1.b * matrix_2.c
	mov		eax, dword [esi + MATRIX.a]
	mov		ebx, dword [edi + MATRIX.a]
	xor		edx, edx
	mul		ebx
	mov		ecx, eax		; save matrix_1.a * matrix_2.a
	
	mov		eax, dword [esi + MATRIX.b]
	mov		ebx, dword [edi + MATRIX.c]
	xor		edx, edx 
	mul		ebx
	add		eax, ecx
	
	mov		dword [ebp + .local_res + MATRIX.a], eax
	
	; matrix_1.a * matrix_2.b + matrix_1.b * matrix_2.d
	mov		eax, dword [esi + MATRIX.a]
	mov		ebx, dword [edi + MATRIX.b]
	xor		edx, edx 
	mul		ebx
	mov		ecx, eax
	
	mov		eax, dword [esi + MATRIX.b]
	mov		ebx, dword [edi + MATRIX.d]
	xor		edx, edx
	mul		ebx
	add		eax, ecx
	
	mov		dword [ebp + .local_res + MATRIX.b], eax
	
	; matrix_1.c * matrix_2.a + matrix_1.d * matrix_2.c
	mov		eax, dword [esi + MATRIX.c]
	mov		ebx, dword [edi + MATRIX.a]
	xor		edx, edx 
	mul		ebx
	mov		ecx, eax
	
	mov		eax, dword [esi + MATRIX.d]
	mov		ebx, dword [edi + MATRIX.c]
	xor		edx, edx 
	mul		ebx
	add		eax, ecx
	
	mov		dword [ebp + .local_res + MATRIX.c], eax
	
	; matrix_1.c * matrix_2.b + matrix_1.d * matrix_2.d
	mov		eax, dword [esi + MATRIX.c]
	mov		ebx, dword [edi + MATRIX.b]
	xor		edx, edx
	mul		ebx
	mov		ecx, eax
	
	mov		eax, dword [esi + MATRIX.d]
	mov		ebx, dword [edi + MATRIX.d]
	xor		edx, edx
	mul		ebx
	add		eax, ecx 
	
	mov		dword [ebp + .local_res + MATRIX.d], eax
	
	; Finally, copy local reuslt into the res_addr for to return
	lea 	esi, dword [ebp + .local_res]
	mov		edi, dword [ebp + .res_addr]
	
	mov		eax, dword [esi + MATRIX.a]
	mov		dword [edi + MATRIX.a], eax
	
	mov		eax, dword [esi + MATRIX.b]
	mov		dword [edi + MATRIX.b], eax
	
	mov		eax, dword [esi + MATRIX.c]
	mov		dword [edi + MATRIX.c], eax
	
	mov		eax, dword [esi + MATRIX.d]
	mov		dword [edi + MATRIX.d], eax
	
.done:
	popa 

	mov		esp, ebp
	pop		ebp
	ret
	
	
;============================================
; matrix_power(matrix_addr, power, res_addr)
;============================================
matrix_power:
	.matrix_addr = 0x8
	.power = 0xc
	.res_addr = 0x10
	
	push	ebp
	mov		ebp, esp
	
	push	esi
	push	edi
	push	eax
	push	ecx
	
	mov		esi, dword [ebp + .matrix_addr]
	mov		edi, dword [ebp + .res_addr]
	
	push	edi
	push	esi
	call	copy_matrix
	add		esp, 4*2

	mov		ecx, dword [ebp + .power]
	test	ecx, ecx
	jz		.empty_matrix
	cmp		ecx, 1
	jbe		.done
	dec		ecx
	
.next_mul:
	push	edi
	push	edi
	push	esi
	call	mul_matrices
	add		esp, 4*3
	
	dec		ecx
	cmp		ecx, 0
	ja		.next_mul
	
	jmp		.done
.empty_matrix:
	mov		dword [edi + MATRIX.a], 1
	mov		dword [edi + MATRIX.b], 0
	mov		dword [edi + MATRIX.c], 1
	mov		dword [edi + MATRIX.d], 0

.done:
	pop		ecx
	pop		eax
	pop		edi
	pop		esi

	mov		esp, ebp
	pop		ebp
	ret
	

;======================================================
; copy_matrix(src_addr, dst_addr)
;======================================================
copy_matrix:
	.src_addr = 0x8
	.dst_addr = 0xc
	
	push	ebp
	mov		ebp, esp
	
	push	esi
	push	edi
	push	eax
	
	mov		esi, dword [ebp + .src_addr]
	mov		edi, dword [ebp + .dst_addr]
	
	mov		eax, dword [esi + MATRIX.a]
	mov		dword [edi + MATRIX.a], eax
	
	mov		eax, dword [esi + MATRIX.b]
	mov		dword [edi + MATRIX.b], eax
	
	mov		eax, dword [esi + MATRIX.c]
	mov		dword [edi + MATRIX.c], eax
		
	mov		eax, dword [esi + MATRIX.d]
	mov		dword [edi + MATRIX.d], eax
	
.done:
	pop		eax
	pop		edi
	pop		esi

	mov		esp, ebp
	pop		ebp
	ret

;======================================================
; print_matrix(matrix_addr)
;======================================================
print_matrix:
	.matrix_addr = 0x8
	
	push	ebp
	mov		ebp, esp
	
	push	esi
	push	eax
	
	mov		esi, dword [ebp + .matrix_addr]
	
	mov		eax, dword [esi + MATRIX.a]
	call	print_eax
	
	mov		eax, dword [esi + MATRIX.b]
	call	print_eax
	
	mov		eax, dword [esi + MATRIX.c]
	call	print_eax
		
	mov		eax, dword [esi + MATRIX.d]
	call	print_eax
	
.done:
	pop		eax 
	pop		esi

	mov		esp, ebp
	pop		ebp
	ret

include 'training.inc'
