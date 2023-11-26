; 2. Write a program that takes the number n as input, and prints back all the
; triples (a,b,c), such that a^2 + b^2 = c^2. 

; These are all the pythagorean triples not larger than n.

format PE console
entry start

include 'win32a.inc'

; ===============================================
section '.text' code readable executable
	
start:
	call read_hex 
	mov cl,al 
	
	mov esi,0
	mov ch, cl 
loopA:
	mov bl, cl 			

loopB:
	mov bh, cl 
		
loopC: 
calculate:	
	mov eax,0			; get a^2
	mov al, ch 
	mul eax 
	mov esi,eax
		
	mov eax,0 
	mov al, bl 
	mul eax 
	add esi,eax 		; a^2 + b^2 
	
	mov eax,0
	mov al, bh 
	mul eax 
	cmp esi,eax 		; a^2 + b^2 = c^2
	
	jnz no_print 
		
print_triple:
			
	mov eax,0
	mov al, ch 
	call print_eax 
	mov al, bl 
	call print_eax 
	mov al, bh 
	call print_eax 
	
no_print:
	dec bh
	jns loopC 
			
	dec bl  
	jns loopB 
	
	dec ch 
	jns loopA 
	
    ; Exit the process:
	push	0
	call	[ExitProcess]

include 'training.inc'












7
7
0
7
6
0
6
5
0
5
4
3
5
4
0
4
3
4
5
3
0
3
2
0
2
1
0
1
0
7
7
0
6
6
0
5
5
0
4
4
0
3
3
0
2
2
0
1
1
0
0
0