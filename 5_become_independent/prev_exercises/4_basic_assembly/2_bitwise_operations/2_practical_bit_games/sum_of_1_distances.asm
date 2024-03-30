; 3.  Sum of distances:
    
; For a binary number x, we define the "sum of 1 distances" to be the sum of
; distances between every two "1" bits in x's binary representation.

; Small example (8 bits):

  ; x = {10010100}_2
	   ; 7  4 2
  
  ; The total sum of distances: (7-4) + (7-2) + (4-2) = 3 + 5 + 2 = 10


; Create a program that takes a number x (of size 4 bytes) as input, and
; outputs x's "sum of 1 distances".
