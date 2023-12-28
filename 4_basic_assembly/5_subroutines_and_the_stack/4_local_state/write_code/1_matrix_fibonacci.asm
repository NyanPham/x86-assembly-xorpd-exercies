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
	
struct Matrix 
	i 	dd	?
	j   dd	?
	k	dd	?
	z 	dd	? 
ends	
	
section '.data' data readable writeable
	enter_power			db		'Please enter the n-th to compute Fibonacci: ',0
	power_result		db		'The n-th Fibonacci is: ',0
	base_matrix 		Matrix 		1, 1, 1, 0	
	
section '.bss' readable writeable
	matrix_prod			Matrix 		?

section '.text' code readable executable 
		
start:	
	mov		esi, enter_power
	call	print_str
	call	read_hex 	
	
	push	eax 
	mov		esi, base_matrix
	push	esi 
	call	power_matrix
	add		esp, 4*2 	
		
	mov		edi,  matrix_prod
	push	edi
	push	eax
	call	copy_matrix
	add		esp, 4*2 
		
	mov		esi, power_result
	call	print_str 
	
	mov		eax, dword [matrix_prod.j]
	call	print_eax 
	
	push	0
	call	[ExitProcess]
	
;=========================
; print_matrix(matrix_addr)
;
; Operation: load and print each entry in the matrix
;
 
print_matrix:
	.matrix_addr = 8h
	push	ebp 
	mov		ebp, esp 
	
	push	eax 
	push	esi
	
	mov		esi, dword [ebp + .matrix_addr]
	
	mov		eax, dword [esi + Matrix.i]
	call	print_eax 
		
	mov		eax, dword [esi + Matrix.j]
	call	print_eax 
	
	mov		eax, dword [esi + Matrix.k]
	call	print_eax 
		
	mov		eax, dword [esi + Matrix.z]
	call	print_eax 
	
	
	pop		esi 
	pop		eax 
	
	pop		ebp 
	ret 
	
;==========================
; copy_matrix(source_matrix_addr, destination_matrix_addr)
;
; Input: addresses of source and destination matrices
; Operation: load and copy each entry (i, j, k, z) from the source to destination
; Output: void 
; 

copy_matrix: 
	.source_matrix_addr = 8h
	.destination_matrix_addr = 0ch
	push	ebp 
	mov		ebp, esp
	
	push	esi
	push	edi
	push	eax 
	
	mov		esi, dword [ebp + .source_matrix_addr]
	mov		edi, dword [ebp + .destination_matrix_addr]
		
	mov 	eax, dword [esi + Matrix.i]
	mov		dword [edi + Matrix.i], eax 
	
	mov 	eax, dword [esi + Matrix.j]
	mov		dword [edi + Matrix.j], eax 
		
	mov 	eax, dword [esi + Matrix.k]
	mov		dword [edi + Matrix.k], eax 
		
	mov 	eax, dword [esi + Matrix.z]
	mov		dword [edi + Matrix.z], eax 
		
	pop		eax 
	pop		edi 
	pop		esi
	
	pop		ebp 
	ret 
	

;==========================
; mul_matrices(base_matrix_addr, matrix_mulr_addr, matrix_prod_addr)
; 
; Input: address of the matrix as multiplicand, address of the matrix as multiplier, and address of matrix as product 
; Operation: 
; 	A =  | a  b |   ,    B = | e  f |
       ; | c  d |            | g  h |
    
; AB = | ae + bg   af + bh |
	 ; | ce + dg   cf + dh |
; Output: void
;

mul_matrices:
	.base_matrix_addr = 8h
	.matrix_mulr_addr = 0ch
	.matrix_prod_addr = 010h
	push	ebp 
	mov		ebp, esp
	
	push	eax 
	push	ebx 
	push	edi
	push	edx 	
	push	esi 
	push	ecx 
	
	mov		esi, dword [ebp + .base_matrix_addr]
	mov		ebx, dword [ebp + .matrix_mulr_addr]
	mov		edi, dword [ebp + .matrix_prod_addr]
	
	mov		eax, dword [esi + Matrix.i]
	mul		dword [ebx + Matrix.i]
	mov		dword [edi + Matrix.i], eax
	
	mov		eax, dword [esi + Matrix.j]
	mul		dword [ebx + Matrix.k]
	add		eax, dword [edi + Matrix.i]
	mov		dword [edi + Matrix.i], eax
	
	mov		eax, dword [esi + Matrix.i]
	mul		dword [ebx + Matrix.j]
	mov		dword [edi + Matrix.j], eax
	
	mov		eax, dword [esi + Matrix.j]
	mul 	dword [ebx + Matrix.z]
	add		eax, dword [edi + Matrix.j]
	mov		dword [edi + Matrix.j], eax
		
	mov		eax, dword [esi + Matrix.k]
	mul 	word [ebx + Matrix.i]
	mov		dword [edi + Matrix.k], eax
	
	mov		eax, dword [esi + Matrix.z]
	mul		dword [ebx + Matrix.k] 
	add		eax, dword [edi + Matrix.k]
	mov		dword [edi + Matrix.k], eax
	
	mov		eax, dword [esi + Matrix.k]
	mul		dword [ebx + Matrix.j]
	mov		dword [edi + Matrix.z], eax
		
	mov		eax, dword [esi + Matrix.z] 
	mul		dword [ebx + Matrix.z]
	add		eax, dword [edi + Matrix.z]
	mov		dword [edi + Matrix.z], eax		
		
	pop		ecx 
	pop		esi
	pop		edx 
	pop  	edi 
	pop		ebx 
	pop		eax 
	
	pop		ebp
	ret 
	
;==========================
; power_matrix(matrix_addr, exp)
; 
; Input: address of the matrix to power, and the exponent
; Operation: repeitive the matrix to itself exponent time
; Ouput: eax = address of the result of 16 bytes
;

power_matrix:
	.matrix_addr = 8h 
	.exp = 0ch
	push	ebp 
	mov		ebp, esp
	sub		esp, sizeof.Matrix * 2
	
	.matrix_mulr = sizeof.Matrix
	.matrix_prod = sizeof.Matrix * 2
	
	push	esi
	push	edi
	push	ecx 
	
	mov		ecx, dword [ebp + .exp] 
	jecxz 	.identity_matrix 
	cmp		ecx, 1h
	je		.power_1
	mov		esi, dword [ebp + .matrix_addr]
		
	lea		eax, dword [ebp - .matrix_prod]
	push	eax 
	push	esi
	call	copy_matrix
	add		esp, 4*2 
	
	lea		eax, dword [ebp - .matrix_mulr]
	push	eax 
	push	esi
	call	copy_matrix
	add		esp, 4*2 
	
.next_mul:
	lea 	eax, dword [ebp - .matrix_prod]
	push	eax 
	lea		eax, dword [ebp - .matrix_mulr]
	push	eax 
	mov		esi, dword [ebp + .matrix_addr]
	push	esi
	call	mul_matrices
	add		esp, 4*3
		
	lea		eax, dword [ebp - .matrix_mulr]
	push	eax 
	lea 	eax, dword [ebp - .matrix_prod]
	push	eax 
	call	copy_matrix
	add		esp, 4*2 
		
	dec		ecx 
	cmp		ecx, 1h
	jnz		.next_mul 
	jmp		.power_done
		
.identity_matrix:
	lea 	eax, dword [ebp - .matrix_prod] 
	mov		dword [eax + Matrix.i], 1
	mov		dword [eax + Matrix.j], 0
	mov		dword [eax + Matrix.k], 0
	mov		dword [eax + Matrix.z], 1
	jmp		.power_done
	
.power_1:
	lea 	eax, dword [ebp - .matrix_prod]
	push	eax
	push	esi 
	call	copy_matrix
	add		esp, 4*2 
		
.power_done:	
	lea 	eax, dword [ebp - .matrix_prod] 
		
	pop		ecx 
	pop		edi
	pop		esi
		
	add		esp, sizeof.Matrix * 2
	
	pop		ebp 
	ret 


include 'training.inc'