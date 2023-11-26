; 5.  Rotation overflow.

; The ror/rol instructions receive two arguments: dest and k. k is the amount
; of bit locations we rotate. (k=1 means rotate one bit location).

; What happens if k is larger than the size of the argument? For example, what
; would the following instructions do:

; 5.0   ror   eax,54d

; 5.1   rol   bx,19d

; 5.2   ror   dh,10d

; 5.3   mov   cl,0feh
	  ; ror   edx,cl

; 5.4   ror   eax,1001d

; For each of those instructions:
; - Check if it assembles.
; - Write some code that includes that instruction, and find out what it does.


format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.text' code readable executable
	
start: 
	mov eax,20d
	call print_eax_binary
				
	ror eax, 35d
					
	call print_eax_binary 

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
