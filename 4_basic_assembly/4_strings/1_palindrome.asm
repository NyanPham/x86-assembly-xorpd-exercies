; 1.  Palindrome

    ; A palindrome is a sequence of symbols which is interpreted the same if read in
    ; the usual order, or in reverse order.
    
    ; Examples:

      ; 1234k4321   is a palindrome.
      ; 5665        is a palindrome.
	
      ; za1221at    is not a palindrome.


    ; Write a program that takes a string as input, and decides whether it is a
    ; palindrome or not. It then prints an appropriate message to the user.

format PE console 
entry start 

include 'win32a.inc'

MAX_USER_TEXT = 40h

section '.data' data readable writeable
	enter_text				db 	'Please enter a string of anything: ',13,10,0 
	is_palindrome_text 		db	'Your text is a palindrome',0
	not_palindrome_text		db	'Your text is not a palindrome',0
	
section '.bss' readable writeable
	user_text		db 	 MAX_USER_TEXT 	dup 	(?)
	stack_arr		dd 	 MAX_USER_TEXT 	dup 	(?)
	text_len 		dd 	 ? 
	mid_idx			dd 	 ?
	
section '.text' code readable executable
	
start:
	;==========================================================================
	; print prompt
	;==========================================================================
	mov		esi, enter_text						
	call	print_str 
	
	;==========================================================================
	; get user input of char sequence
	;==========================================================================
	mov		edi, user_text 						
	mov		ecx, MAX_USER_TEXT
	call	read_line 
	
	;==========================================================================	
	; get the length of input 
	;==========================================================================		
	mov		edi, user_text 						
	mov		ecx, MAX_USER_TEXT	
	xor		al, al 
	repnz	scasb	
		
	neg		ecx
	add		ecx, MAX_USER_TEXT 
	dec		ecx 
	;==========================================================================
	; then find the middle index by length / 2 to separte left half and right.
	;==========================================================================	
	mov 	dword [text_len], ecx				 
	shr		ecx, 1	
	mov		dword [mid_idx], ecx 
	
	;==========================================================================
	; start to push right half of the original string,
	;==========================================================================
	mov		ebx, dword [text_len] 				
	dec		ebx 								; ebx = last index (length - 1) 
	xor		ecx, ecx 							; ecx = 0 (index in stack_arr) to store the reversed
	mov		esi, user_text
	mov		edi, stack_arr
			
push_next_byte:									; push and reverse the right half of the orignal string
	cmp		ebx, 0
	jl		end_stack_push
	cmp		ecx, dword [mid_idx]
	jz		end_stack_push
		
	mov		al, byte [esi + ebx]
	mov		byte [edi + ecx], al
	inc		ecx 
	dec		ebx 
	jmp		push_next_byte
	
	;==========================================================================
	; compare each byte between the original left with reversed right
	;==========================================================================
end_stack_push:
	mov		esi, stack_arr  					
	mov		edi, user_text 
	xor 	ecx, ecx 
		
check_next:
	mov		al, byte [esi + ecx] 
	test	al, al
	jz		is_palindrome
		
	cmp		al, byte [edi + ecx]	
	jnz 	not_palindrome
			
	inc		ecx 
	jmp 	check_next
	
is_palindrome:
	mov		eax, is_palindrome_text
	jmp 	done_check
not_palindrome:
	mov		eax, not_palindrome_text
		
done_check:
	mov		esi, eax 
	call	print_str 
	
	push	0
	call	[ExitProcess]
	
include 'training.inc'
	
	
	
	
	
	
	