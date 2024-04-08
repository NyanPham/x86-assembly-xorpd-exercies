; 2.  Count paths.
    
    ; We consider a two dimensional table of size N X N:

      ; +---+---+---+---+
      ; |   |   |   |   |
      ; | S |   |   |   |
      ; |   |   |   |   |
      ; +---+---+---+---+
      ; |   |   |   |   |
      ; |   |   |   |   |
      ; |   |   |   |   |
      ; +---+---+---+---+
      ; |   |   |   |   |
      ; |   |   |   |   |
      ; |   |   |   |   |
      ; +---+---+---+---+
      ; |   |   |   |   |
      ; |   |   |   | E |
      ; |   |   |   |   |
      ; +---+---+---+---+

    ; With two special cells: Start (S) and End (E). Start is the top left cell,
    ; and End is the bottom right cell. 
    
    ; A valid path from S to E is a path that begins with S, ends with E, and
    ; every step in the path could either be in the down direction, or in the
    ; right direction. (Up or left are not allowed).

      ; Example for a valid path: right, right, down, down, right, down:

      ; +---+---+---+---+
      ; |   |   |   |   |
      ; | S-|---|-+ |   |
      ; |   |   | | |   |
      ; +---+---+---+---+
      ; |   |   | | |   |
      ; |   |   | | |   |
      ; |   |   | | |   |
      ; +---+---+---+---+
      ; |   |   | | |   |
      ; |   |   | +-|-+ |
      ; |   |   |   | | |
      ; +---+---+---+---+
      ; |   |   |   | | |
      ; |   |   |   | E |
      ; |   |   |   |   |
      ; +---+---+---+---+

    ; We would like to count the amount of possible valid paths from S
    ; to E.


    ; 2.0   Let T be some cell in the table:

             ; |   |   |
             ; |   |   |
           ; --+---+---+--
             ; |   |   |
             ; |   | R |
             ; |   |   |
           ; --+---+---+--
             ; |   |   |
             ; | Q | T |
             ; |   |   |
           ; --+---+---+--
             ; |   |   |
             ; |   |   |

          ; Prove that the amount of valid paths from S to T equals to the amount
          ; of paths from S to Q plus the amount of paths from S to R.

    ; 2.1   Define a constant N in your program, and create a two dimensional
          ; table of size N X N (of dwords). Call it num_paths. We will use this
          ; table to keep the amount of possible valid paths from S to any cell in
          ; the table.

    ; 2.2   The amount of paths from S to each of the cells in the top row, or the
          ; leftmost column, is 1. 
			
          ; Write a piece of code that initializes all the top row and the
          ; leftmost column to be 1.

    ; 2.3   Write a piece of code that iterates over the table num_paths. For
          ; every cell num_paths(i,j) it will assign:

          ; num_paths(i,j) <-- num_paths(i-1,j) + num_paths(i,j-1)

          ; Note that you should not iterate over the top row and the leftmost
          ; column, because you have already assigned them to be 1.

    ; 2.4   The last cell in num_paths, num_paths(N-1,N-1) contains the amount of
          ; valid paths possible from S to E. 

          ; Add a piece of code to print this number.

