; Basic Assembly
; ==============
; 
; Subroutines and the stack - Calling conventions
; -----------------------------------------------
; 
; Copy machine
; @@@@@@@@@@@@
;

format PE console
entry start

include 'win32a.inc' 

; ===============================================
section '.data' data readable writeable
    src_data        db  'This is the source data!',0
    SRC_DATA_LEN = $ - src_data
    dest_data       db  SRC_DATA_LEN    dup ('A')

; ===============================================
section '.text' code readable executable

start:
    ; Copy src_data into dest_data:
	
	push 	SRC_DATA_LEN
	push 	src_data
	push 	dest_data
    call  	copy_data
	add	  	esp, 0ch
	
    ; Print dest_data to console:
    mov     esi,dest_data
    call    print_str

    ; Exit the process:
	push	0
	call	[ExitProcess]


; ================================================
; copy_data(dest,src,length)
;
; Calling convention: 
;  	Data Stack
; Operation:
;   Copy a data buffer.
; Input:
;   dest    -- destination address.
;   src     -- src address.
;   length  -- amount of data to copy (In bytes).
;	
copy_data:
    push    esi     ; Keep registers on stack.
    push    edi
    push    ecx
	
    ; Think: Why do we have to add 0ch here?
		
	; => Answer: Because we also pushed another 3 registers
	; in the stack, thus increase the offset to the 
	; arguments by 0ch.
	
    mov     edi,dword [esp+4+0ch]   ; dest
    mov     esi,dword [esp+8+0ch]   ; src
    mov     ecx,dword [esp+0ch+0ch] ; length

    rep     movsb   ; Copy data.

    pop     ecx     ; Restore registers from stack.
    pop     edi
    pop     esi
    ret

include 'training.inc'
