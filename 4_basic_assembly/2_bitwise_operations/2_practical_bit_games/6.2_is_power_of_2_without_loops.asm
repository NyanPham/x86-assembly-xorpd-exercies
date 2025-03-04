; 6.  Bonus: Identifying powers of two.
    ; 6.2   Try to write that program again, this time without any loops.
          
          ; HINT: try to decrease the original number by 1.
		  
format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable

start:
	call	read_hex
	;==============================================
	; Need this part to check if input is 0 or not
	;==============================================
	cmp eax,0
	jz 	print_result 
	
	mov		esi, eax
	
	dec		esi
	and		eax, esi
	jnz		not_power_2
	mov		eax, 1
	jmp		print_result
not_power_2:
	mov		eax, 0
print_result:
	call	print_eax
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'

