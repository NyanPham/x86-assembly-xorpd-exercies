; 1.  Check intersection.
		
    ; Assume that we have two rectangles R,Q which are parallel to the X and Y
    ; axes. We say that R and Q intersect if there is a point which is inside both
    ; of them.
		
    ; Example:
      
      ; Intersecting rectangles:        Non intersecting rectangles:

      ; +---------+                     +-----+
      ; | R       |                     | R   |   +------+
      ; |     +---+----+                |     |   | Q    |
      ; |     |   |  Q |                +-----+   |      |
      ; +-----+---+    |                          |      |
            ; |        |                          +------+
            ; +--------+

    ; Write a program that takes the coordinates of two rectangles (Just like in
    ; the previous exercise), and finds out if the rectangles are intersecting.
    ; The program will print 1 if they are intersecting, and 0 otherwise.

    ; Example:
      ; First rectangle:  (1,5) (4,9)
      ; Second rectangle: (3,4) (6,10)

      ; Those two rectangle are intersecting.
	