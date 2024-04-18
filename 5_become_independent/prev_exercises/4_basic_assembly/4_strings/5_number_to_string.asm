; 5.  Number to String

    ; We are going to write a program that converts a number into its base 10
    ; representation, as a string.

    ; The program will read a number as input (Using the read_hex helper
    ; subroutine). It will then print back the number, in base 10.
	
    ; Example:
      
      ; Input:  1f23
      ; output: 7971 (Decimal representation).

    ; HINTS:
      ; - Recall that the input number could be imagined to be in the form:
        ; input = (10^0)*a_0 + (10^1)*a_1 + ... + (10^t)*a_t

      ; - Use repeated division method to calculate the decimal digits
        ; a_0,a_1,...,a_t.

      ; - Find out how to translate each decimal digit into the corresponding
        ; ASCII symbol. (Recall the codes for the digits '0'-'9').

      ; - Build a string and print it. Remember the null terminator!
