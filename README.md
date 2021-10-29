# Vector-Language-Compiler

## Description
	Course name: Automats and compilation.
	This is the course final project, building a compiler from vector language to a c file.
	The compiler built with the usage of Bison and Flex.

## Vector Language
	Please refer to the pdf file in the repositry, file name is vlang.pdf .

## Guide to run the compiler
	1	- Use the "make" command to compile the file and generate the "vcc" compiler 
		  (output = vcc.exe).

	2	- Run the vcc compiler with input file and output file:
		  ./vcc.exe <input file> <output file>
		  Example: " ./vcc.exe ./source.vlang out.c "

	3	- Compile the c code with just the output file you requested.
		  Example: " gcc out.c -o out.exe "

	4	- Run to see the result of your vlang file.


### Important note
	The compiler creates header file named "vector_functions.h"
	please make sure you are compiling the output file when you have
	the header file in the same directory. 