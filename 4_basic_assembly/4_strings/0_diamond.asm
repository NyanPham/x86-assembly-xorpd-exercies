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
	enter_text		db 	'Enter a star size: ',0xd,0xa,0x0
	invalid_n		db	'Invalid size entered. ',0xd,0xa,0x0
	space			db	0x20,0
	star			db	'*',0
	newline			db	0xd,0xa,0
	
section '.bss' readable writeable
	size_n			dd		?
	diamond_size	dd		?
	mid_idx		dd		?

section '.text' code readable executable

start:
	mov		esi, enter_text
	call	print_str
	
	call	read_hex
	mov		dword [size_n], eax
	
	cmp		dword [size_n], 0
	jle		invalid_input
	
	; Compute diamond width
	mov		eax, dword [size_n]
	shl		eax, 0x1
	inc		eax
	mov		dword [diamond_size], eax
	
	mov		eax, dword [size_n]
	mov		dword [mid_idx], eax
	
	mov		esi, newline
	call	print_str
	
	; Draw diamond 
	mov		ecx, dword [diamond_size]
	xor		ebx, ebx
draw_line:
	; Find num of stars in line
	cmp		ebx, dword [mid_idx]
	ja		lower_half
	
	mov		eax, ebx
	shl		eax, 0x1
	inc		eax
	jmp		find_spaces
lower_half:
	mov		eax, ecx
	dec		eax
	shl		eax, 0x1
	inc		eax
	
find_spaces:
	; Find num of spaces on left/right size in line
	mov		edx, dword [diamond_size]
	sub		edx, eax
	shr		edx, 0x1
	mov		edi, edx
	

print_left_space:	
	cmp		edx, 0
	jz		print_star
	mov		esi, space
	call	print_str
	dec		edx
	jmp		print_left_space

print_star:
	cmp		eax, 0
	jz		print_right_space
	mov		esi, star
	call	print_str
	dec		eax
	jmp		print_star

print_right_space:
	cmp		edi, 0
	jz		done_line
	mov		esi, space
	call	print_str
	dec		edi
	jmp		print_right_space

done_line:
	mov		esi, newline
	call	print_str
	
	inc		ebx
	dec		ecx 
	jnz		draw_line
	
	jmp		end_prog
invalid_input:
	mov		esi, invalid_n
	call	print_str
	
end_prog:
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'
