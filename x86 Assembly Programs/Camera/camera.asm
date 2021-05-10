.386

.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

INCLUDE debug.h
INCLUDE sqrt.h
INCLUDE io.h

cr      EQU     0dh     ; carriage return character
Lf      EQU     0ah     ; line feed

.STACK 4096

.DATA

eye_prompt1		        BYTE	"Enter the x-coordinate of the camera eyepoint:"
eye_prompt2		        BYTE	"Enter the y-coordinate of the camera eyepoint:"
eye_prompt3		        BYTE	"Enter the z-coordinate of the camera eyepoint:"

look_prompt1	        BYTE	"Enter the x-coordinate of the camera look at point:"
look_prompt2	        BYTE	"Enter the y-coordinate of the camera look at point:"
look_prompt3	        BYTE	"Enter the z-coordinate of the camera look at point:"

up_prompt3		        BYTE	"Enter the x-coordinate of the camera up direction:"
up_prompt3		        BYTE	"Enter the y-coordinate of the camera up direction:"
up_prompt3		        BYTE	"Enter the z-coordinate of the camera up direction:"

label1  	            BYTE    cr, Lf, "u: ()"     ;going to be labels for output. FORMAT LATER
label1  	            BYTE    cr, Lf, "v: ()"
label1  	            BYTE    cr, Lf, "n:()"

dot_product_result  	BYTE    11 DUP (?)
dot_product_temp        BYTE    11 DUP (?)
n_result                BYTE    11 DUP (?)
			            BYTE    cr, Lf, 0

coordinateOutput        BYTE  50 DUP (?)

E1                      WORD  8 DUP (?)  
E2	                    WORD  8 DUP (?)       
E3                      WORD  8 DUP (?)

L1                      WORD  8 DUP (?)  
L2	                    WORD  8 DUP (?)       
L3                      WORD  8 DUP (?)

up1                      WORD  8 DUP (?)  
up2	                    WORD  8  DUP (?)       
up3                      WORD  8 DUP (?)

nx                      WORD  8 DUP (?)
ny                      WORD  8 DUP (?)
nz                      WORD  8 DUP (?)

vx                      WORD  8 DUP (?)
vy                      WORD  8 DUP (?)
vz                      WORD  8 DUP (?)

ux                      WORD  8 DUP (?)
uy                      WORD  8 DUP (?)
uz                      WORD  8 DUP (?)

v_length                WORD  8 DUP (?)
u_length                WORD  8 DUP (?)
n_length                WORD  8 DUP (?)
length                  WORD  8 DUP (?)



.CODE

;A macro to output prompts for data, reads in the input
GetCoordinates MACRO pr1, pr2, pr3, x, y, z  
        output pr1                      ; prompt for x-coord.
	    input string, 8                 ; read ASCII characters
	    atod string                     ; Convert to integer (atoi) - Word size. Default result in eax
	    mov x, ax                       ; store in memory 

		
		

        output pr2                      ; prompt for y-coord.
	    input string, 8                 ; read ASCII characters
	    atod string                     ; Convert to integer (atoi) - Word size. Default result in eax
	    mov y, ax                       ; store in memory 

        output pr3                      ; prompt for z-coord.
	    input string, 8                 ; read ASCII characters
	    atod string                     ; Convert to integer (atoi) - Word size. Default result in eax
	    mov z, ax                       ; store in memory
		
		mov coord, "("
		itoa coord + 1, x
		mov coord + 7, ","
		mov coord + 8, " "
		itoa coord + 9, y
		mov coord + 15, ","
		mov coord + 16, " "
		itoa coord + 17, z
		mov coord + 23, " "
		mov coord + 24, ")"
		output coord
		
		output carriage

        ENDM

DisplayXYZCoord MACRO outX, outY, outZ               ; A macro for displaying (x, y, z)
       output     carriage

       mov        coordinateOutput , "("
       itoa       coordinateOutput  + 1, outX             ;6 Spaces to display integer
       mov        coordinateOutput  + 7, ","   
       mov        coordinateOutput  + 8, " "
       itoa       coordinateOutput  + 9, outY
       mov        coordinateOutput  + 15, ","
       mov        coordinateOutput + 16, " "
       itoa       coordinateOutput + 17, outZ
       mov        coordinateOutput  + 23, " "
       mov        coordinateOutput + 24, ")"
       output     coordinateOutput 

       output     carriage

                 ENDM

; computes the dot product of two vectors
;DONE
dot_product MACRO   x1, y1, z1, x2, y2, z2
    mov ax, x1                          ;moves value of x1 into eax
	imul ax, y1                        ;x1*y1
    imul ax, z1                        ;x1*y1*z1
    mov bx, x2                         ;stores value of x2 and eventually x2*y2*z2
    imul bx, y2                        ;x2*y2
    imul bx, z2                        ;x2*y2*z2
    add ax, bx                         ;(x1*y1*z1)+(x2*y2*z2)  
    mov dot_product_result, ax        ;stores result of dot product in dot_product_result
	mov ax, 0                          ;clear out eax for next use                   
               
            ENDM


; computes the cross product of two vectors
;DONE
cross_product MACRO   x1, y1, z1, x2, y2, z2, x3, y3, z3
    mov ax, x2         ;moves value of x2 into eax
    imul ax, y3        ;x2*y3
    mov dx, x3         ;moves value of x3 into edx
    imul dx, y2        ;x2*y2
    sub ax, edx        ;x2*y3-x3*y2
    mov z1, eax         ; stores x2*y3-x3*y2 in z1
    mov ax, 0          ;    clear out eax register
    mov dx, 0          ; clear out edx register

    mov ax, x3         ;moves value of x3 into eax
    imul ax, y1        ;x3*y1
    mov ax, x1         ;moves value of x1 into edx
    imul ax, y3        ;x3*y3
    sub eax, edx        ;x3*y1-x1*y3
    mov z2, eax         ; stores x3*y1-x1*y3 in z2
    mov eax, 0          ;clear out eax register
    mov edx, 0          ;clear out edx register

    mov ax, x1       ;moves value of x1 into eax
    imul ax, y2      ;x1*y2
    mov ax, x2       ;moves value of x2 into edx
    imul ax, y1      ;x2*y1
    sub ax, edx      ;x1*y2-x2*y1
    mov z3, ax       ; stores x1*y2-x2*y1 in z3
    mov ax, 0        ;clear out eax register
    mov dx, 0        ;clear out edx register
              

            ENDM


vector_length MACRO x, y, z, result                       
    mov ax, 0
    dot_product x, y, z, x, y, z
    mov ax, dot_product_result
    sqrt ax
    mov result, ax
                   
            ENDM


normalize MACRO x, y, z, length
        mov ax, 0
        mov ax, x
        idiv ax, length
        mov x, ax

        mov ax, 0
        mov ax, y
        idiv ax, length
        mov y, ax

        mov ax, 0
        mov ax, z
        idiv ax, length
        mov z, ax
  
            ENDM



_start:

; Prompt User for X,Y,Z input, and store informatio
GetCoordinates eye_prompt1, eye_prompt2, eye_prompt3, E1, E2, E3
GetCoordinates look_prompt1, look_prompt2, look_prompt3, L1, L2, L3
GetCoordinates up_prompt3, up_prompt2, up_prompt3, U1, U2, U3

    ;computing n
    mov, ax, 0

    mov ax, E1                                 ;stores the value of e in eax
    sub ax, L1  
    neg ax                                     ;e - a for first vector
    mov n1, ax

    mov ax, E2
    sub ax, L2
    neg ax
    mov n2, ax

    mov ax, E3
    sub axx, L3
    neg ax
    mov n3, ax
  



;Call dot product n.n
dot_product n1, n2, n3, n1, n2, n3
mov eax, 0
mov eax, dot_product_result
mov dot_product_temp, eax



;find (n.n)v = -(vup.n)n + (n.n)vup
dot_product up1, up2, up3, n1, n2, n3      ;dot_product_result = vup.n
neg dot_product_result 
mov ax, dot_product_result
imul ax, n1
mov vx, ax

mov ax, 0
mov ax, dot_product_result
imul ax, n2
mov vy, ax

mov ax, 0
mov ax, dot_product_result
imul ax, n3
mov vz, ax

mov ax, 0
mov ax, dot_product_temp
imul ax, up1         ;(n.n)vup
add vx, ax


mov ax, 0
mov ax, dot_product_temp
imul ax, up2
add vy, ax

mov ax, 0
mov ax, dot_product_temp
imul ax, up3
add vz, ax

 ; claculate cross_product of v and n to get u 
cross_product MACRO   vx, vy, vz, n1, n2, n3, ux, uy, uz



;vector length call dot product on self then sqrt 

vector_length ux, uy, uz, u_length
vector_length vx, vy, vz, v_length
vector_length n1, n2, n3, n_length

normalize ux, uy, uz, u_length
normalize vx, vy, vz, v_length
normalize n1, n2, n3, n_length








	

INVOKE  ExitProcess, 0  ; exit with return code 0

PUBLIC _start                   ; make entry point public

END                             ; end of source code

			