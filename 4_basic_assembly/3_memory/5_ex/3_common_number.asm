; 3.  Common number.

; Create a program that takes a number n as input, followed by a list of n
; numbers b_1, b_2, ... b_n. You may assume that 0x0 <= b_i <= 0xff for every
; 1 <= i <= n.

; The program will output the most common number.

; Example:

; Assume that the input was n=7, followed by the list: 1,5,1,3,5,5,2.
; The program will output 5, because this is the most common number.

; Note that if there is more than one most common number, the program will
; just print one of the most common numbers.

format PE console
entry start

include 'win32a.inc' 

MAX_NUMS_LEN = 0x40
MAX_FREQ_LEN = 0xff

section '.bss' readable writeable
	nums_len		dd		?
	nums			db		MAX_NUMS_LEN	dup (?)
	nums_freq		dd		MAX_FREQ_LEN	dup (0)
	
	max_idx			dd		?
	max_count		dd		?
section '.text' code readable executable
	
start:
	call	read_hex
	mov		dword [nums_len], eax

	mov		esi, nums
	xor		ecx, ecx
get_num:
	call	read_hex
	mov		byte [esi + ecx], al
	inc		ecx
	cmp		ecx, dword [nums_len]
	jnz		get_num

	mov		esi, nums
	mov		edi, nums_freq
	xor		ecx, ecx
compute_freq:
	movzx	eax, byte [esi + ecx]
	inc		dword [edi + 4*eax]
	inc		ecx
	cmp		ecx, dword [nums_len]
	jnz		compute_freq
	
	mov		dword [max_idx], 0
	mov		dword [max_count], 0
	
	xor		ecx, ecx
	mov		edi, nums_freq
get_common:
	mov		eax, dword [edi + 4*ecx]
	cmp		eax, dword [max_count]
	jbe		.skip_set
	mov		dword [max_count], eax
	mov		dword [max_idx], ecx
.skip_set:
	inc		ecx
	cmp		ecx, MAX_FREQ_LEN
	jnz		get_common
	
	mov		eax, dword [max_idx]
	call	print_eax

    ; Exit the process:
	push	0
	call	[ExitProcess]


include 'training.inc'
