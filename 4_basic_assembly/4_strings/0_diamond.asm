; 0.  Diamond

    ; Write a program that asks the user for a number n, and then prints a
    ; "diamond" of size n, made of ASCII stars.

    ; Example:
      ; For n = 1 the expected result is:
	
       ; *
      ; ***
       ; *

      ; For n = 2 the expected result is:

        ; *
       ; ***
      ; *****
       ; ***
        ; *

    ; HINT: You could use tri.asm exercise from the code reading section as a
    ; basis for your program.
	
	; Can refactor later after learning subroutines and stack

format PE console
entry start

include 'win32a.inc'

section '.data' data readable writeable
	enter_size	db	'Enter the size of the diamond:',13,10,0
	no_size		db	'You want a diamond of 0 (or even negative) width?',13,10,0
	new_line	db  13,10,0
	space		db  ' ',0
	star		db  '*',0
	
section '.bss' readable writeable
	diamond_width 			dd		?
	diamond_middle_row		dd 		?
	row_before_bottom 		dd 		?
	
section '.text' code readable executable
		
start:
	mov		esi, enter_size
	call	print_str 
	
	call	read_hex
	cmp		eax, 0 
	jg		move_on
	
	mov		esi, no_size
	call	print_str 
	jmp 	prog_end
	
move_on:	
	inc 	eax 
	mov		dword [diamond_middle_row], eax 
	dec 	eax 
	
	shl		eax, 1
	inc		eax 
	mov		dword [diamond_width], eax 
	
	xor		ebx, ebx 
next_row_top:	
	mov		eax, ebx 
	shl		eax, 1 
	inc		eax 
	
	mov		ecx, dword [diamond_width]
	sub		ecx, eax 
	shr		ecx, 1
		
	test 	ecx, ecx 
	jz		print_star_top
	
print_space_top:
	mov		esi, space 
	call	print_str 
	loop	print_space_top 
		
print_star_top:
	mov		esi, star 
	call	print_str 
	dec		eax 
	jnz 	print_star_top 

done_top_row:
	mov		esi, new_line
	call	print_str 
	
	inc		ebx 
	cmp		ebx, dword [diamond_middle_row]
	jnz 	next_row_top
	
	sub		ebx, 2
next_row_bottom:
	mov		eax, ebx 
	shl		eax, 1 
	inc		eax 	
	
	mov		ecx, dword [diamond_width]
	sub		ecx, eax 
	shr		ecx, 1
		
	test 	ecx, ecx 
	jz		print_star_bottom
	
print_space_bottom:
	mov		esi, space 
	call	print_str 
	loop	print_space_bottom 
	
print_star_bottom:
	mov		esi, star 
	call	print_str 
	dec		eax 
	jnz 	print_star_bottom 
	
done_top_bottom:
	mov		esi, new_line
	call	print_str 
		
	dec		ebx 
	cmp		ebx, 0
	jge		next_row_bottom

prog_end:
	push	0
	call	[ExitProcess]
	
include 'training.inc'