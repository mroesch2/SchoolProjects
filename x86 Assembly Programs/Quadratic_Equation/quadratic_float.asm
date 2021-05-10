INCLUDE     irvine32.inc
INCLUDE     macros.inc
INCLUDELIB  kernel32.lib
INCLUDELIB  user32.lib
INCLUDELIB  Irvine32.lib


.DATA
determinant 	real4 	4.0
denominator 	real4 	2.0
a 				real4 	?
b 				real4 	?
cc 				real4 	?
resulta 		real4 	?
resultb 		real4 	?
zero			real4	0.0

.CODE

main proc


mWrite "Enter a number for a: "
call ReadFloat

fstp a

mWrite "Enter a number for b: "
call ReadFloat
fstp b

mWrite "Enter a number for c: "
call ReadFloat
fstp cc


fld determinant			;4	in ST(0)
fmul a					;4a in ST(0)	
fmul cc ;4ac			;4ac in ST(0)


fld b					;b in ST(0)
;fxch					;b in ST(1) and 4ac in ST(1)
fmul st, st				;b^2 in ST(1)
fxch					;4ac in ST(0) and b^2 in ST(1)
fsubr ST(0), ST(1)		;b^2-4ac stored in ST(0). b^2 in ST(1)


fld zero				;in ST(0)
fcomi st(0), st(1)
je complex

fxch				;ST(0) now holds b^2-4ac and ST(1) holds 0
fsqrt				;sqrt(b^2-4ac)

fcomi st(0), st(1)
jle complex

fld b				 ;b in ST(0), sqrt(b^2-4ac) in ST(1)
fchs				;-b in ST(0)
fld ST(1)			;sqrt(b^2-4ac) in ST(0), -b ST(1), sqrt(b^2-4ac)in ST(3)
fxch				; -b in ST(0), sqrt(b^2-4ac) in ST(1)
fadd ST(2), ST(0)	;-b+sqrt(b^2-4ac) in ST(2)
fsubrp ST(1), ST(0)	; -b - sqrt(b^2-4ac) in ST(0) after -b pops from stack


fld denominator		 ;denominator ST(0), -b - sqrt(b^2-4ac) in ST(1),  -b + sqrt(b^2-4ac) in ST(2)
fmul a				 ;2a in ST(0)
fdiv ST(2), ST(0)	 ;[-b + sqrt(b^2-4ac)]/2a  in ST(1)
fdivp ST(1), ST(0)	 ;[-b - sqrt(b^2-4ac)]/2a	in ST(0) after 2a is popped		




fstp resultb		;-b - sqrt(b^2-4ac)]/2a 
fstp resulta		;-b + sqrt(b^2-4ac)]/2a 

jmp printResult



complex:
	mWrite "Imaginary numbers can't exist here."
	jmp done


printResult:
	fld resulta
	mWrite "Answer 1: "
	call WriteFloat ;resulta
	fstp resulta
	
	mWrite "     "

	fld resultb
	mWrite"Answer 2: "
	call WriteFloat ;resultb
	fstp resultb

	


done:
	exit 
	main endp 
	end main