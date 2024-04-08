; 0.  Find closest number.
    
    ; Add the following into the data section:

    ; nums  dd  23h,75h,111h,0abch,443h,1000h,5h,2213h,433a34h,0deadbeafh

    ; This is an array of numbers. 
    
    ; Write a program that receives a number x as input, and finds the dword
    ; inside the array nums, which is the closest to x. (We define the distance
    ; between two numbers to be the absolute value of the difference: |a-b|).

    ; Example:

    ; For the input of 100h, the result will be 111h, because 111h is closer to
    ; 100h than any other number in the nums array. (|100h - 111h| = 11h).

