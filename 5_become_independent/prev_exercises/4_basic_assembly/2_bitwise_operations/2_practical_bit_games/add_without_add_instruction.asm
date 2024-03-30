; 8.  Bonus: Addition using bitwise operations.

    ; 8.0   You are given two bits a,b. Show that their arithmetic sum is of the
          ; form (a AND b, a XOR b).
		
          ; Example:
	
          ; 1 + 0 = 01
          ; And indeed: 0 = 1 AND 0, 1 = 1 XOR 0.

	
    ; 8.1   Write a program that gets as inputs two numbers x,y (Each of size 4
          ; bytes), and calculates their arithmetic sum x+y using only bitwise
          ; instructions. (ADD is not allowed!).

          ; HINT: Try to divide the addition into 32 iterations.
                ; In each iteration separate the immediate result and the carry
                ; bits that are produced from the addition.
