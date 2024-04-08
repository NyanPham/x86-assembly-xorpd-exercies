; 2.  Count paths.

    ; 2.5   Bonus: Could you find out num_paths(N-1,N-1) with less memory?
          ; Currently we use about O(N^2) dwords of memory. Could you do it with
          ; about O(N) dwords of memory?
	
    ; 2.6*  Bonus: Could you calculate the number num_paths(N-1,N-1) without using
          ; the computer at all?
		
	; Plan:	
		; Instead of creating the whole matrix, create only 2 rows and work all the 
		; down to the Nth row.
		
