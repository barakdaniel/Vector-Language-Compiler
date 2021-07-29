%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
char* getLoopStatement(char* str);
char* getPos(char* str);
int isVector(char* name);
char* createTmpVec();
char* getVecFromConst(char* vector);
void addVec(char* str, char* size);
char* getVecSize(char* name);
extern FILE* yyout;
extern FILE* yyin;
char buffer[256];
char opBuffer[256];
char vecs[256][24];
char vec_sizes[256][24];
int idx_vecs = 0;
int tmp_vec[2] = {0,0};
int num_of_tmp_vecs = 0;
%}

/* Yacc definitions */
%union {
	char num[24]; 
	char id[124];
	char typ[24];
	char expression[124];
	char oper[1];
	char eq[1];
}         
%start line

%token number size equal identifier scl vec semiCol op op2 dot plus minus print loop if_statement position const_vec comma
%right <eq> equal
%left <oper> comma
%left op
%left op2
%left dot position
%left '(' ')'
%type <expression> expr term identifier
%type <typ> const_vec
%type <oper> op op2 '(' ')' dot

%type <num> number size

%%

/* descriptions of expected inputs     corresponding actions (in C) */

line				: statement semiCol						{;}
					| line statement semiCol				{;}
					| assignment semiCol					{;}
					| line assignment semiCol				{;}
					| block_statement block 				{;}
					| line block_statement block			{;}
					;	
statement			: declare								{;}
					| print expr							{ if(isVector($2)) fprintf(yyout, "\tprintVec(%s, %s);\n", $2, getVecSize($2)); 
															  else if(tmp_vec[0]) { fprintf(yyout, "\tprintVec(tmp=%s, %d);\n", $2, tmp_vec[1]); tmp_vec[0]=0; fprintf(yyout, "\tfree(tmp);\n"); }
															  else fprintf(yyout, "\tprintf(\"%%d\\n\", %s);\n", $2); }
					;
block_statement		: loop expr 							{ fprintf(yyout, "%s {\n", getLoopStatement($2)); }
					| if_statement expr						{ fprintf(yyout, "\tif(%s) {\n", $2); }
					;
block				: '{' line '}'							{ fprintf(yyout, "\t}\n"); }
					| '{' '}'								{ fprintf(yyout, "\t}\n"); }
					;
declare				: scl identifier						{ fprintf(yyout, "\tint %s;\n", $2);}
					| vec identifier size					{ strcpy($3, $3+1); int len = strlen($3); $3[len-1]='\0'; fprintf(yyout, "\tint %s[%s];\n", $2, $3); addVec($2, $3) }
					;
assignment			: term equal expr						{ if(isVector($1) && isVector($3)) { fprintf(yyout, "\tvectorGetVector(%s, %s, %s);\n", $1, getVecSize($1), $3);}
															  else if(isVector($1) && tmp_vec[0]) { fprintf(yyout, "\tvectorGetVector(%s, %s, tmp=%s);\n", $1, getVecSize($1), $3); tmp_vec[0]=0; fprintf(yyout, "\tfree(tmp);\n"); }
															  else if(isVector($1) && !isVector($3) ) fprintf(yyout, "\tvectorGetScalar(%s, %s, %s);\n", $1, getVecSize($1), $3);
															  else { fprintf(yyout, "\t%s%s%s;\n", $1, $2, $3); }
															}
					;
expr				: term									{ ; }
					| expr op expr							{ if(isVector($1) && isVector($3)) { opBuffer[0] = '\0'; strcpy(opBuffer, "vectorOpVector("); strcat(opBuffer, $1); strcat(opBuffer, ", "); 
															  strcat(opBuffer, getVecSize($1)); strcat(opBuffer, ", "); strcat(opBuffer, $3); strcat(opBuffer, ", '"); strcat(opBuffer, $2); strcat(opBuffer, "')"); strcpy($$, createTmpVec(getVecSize($1))); }
															  else if(isVector($1) && !isVector($3)) { opBuffer[0] = '\0'; strcpy(opBuffer, "vectorOpScalar("); strcat(opBuffer, $1); strcat(opBuffer, ", "); 
															  strcat(opBuffer, getVecSize($1)); strcat(opBuffer, ", "); strcat(opBuffer, $3); strcat(opBuffer, ", '"); strcat(opBuffer, $2); strcat(opBuffer, "')"); strcpy($$, createTmpVec(getVecSize($1)));}
															  else if(!isVector($1) && isVector($3)) { opBuffer[0] = '\0'; strcpy(opBuffer, "vectorOpScalar("); strcat(opBuffer, $3); strcat(opBuffer, ", "); 
															  strcat(opBuffer, getVecSize($3)); strcat(opBuffer, ", "); strcat(opBuffer, $1); strcat(opBuffer, ", '"); strcat(opBuffer, $2); strcat(opBuffer, "')"); strcpy($$, createTmpVec(getVecSize($3)));}
															  else {buffer[0]='\0'; strcat(buffer, $1); strcat(buffer, $2); strcat(buffer, $3); strcpy($$, buffer); } }
					| expr op2 expr							{ if(isVector($1) && isVector($3)) { opBuffer[0] = '\0'; strcpy(opBuffer, "vectorOpVector("); strcat(opBuffer, $1); strcat(opBuffer, ", "); 
															  strcat(opBuffer, getVecSize($1)); strcat(opBuffer, ", "); strcat(opBuffer, $3); strcat(opBuffer, ", '"); strcat(opBuffer, $2); strcat(opBuffer, "')"); strcpy($$, createTmpVec(getVecSize($1))); }
															  else if(isVector($1) && !isVector($3)) { opBuffer[0] = '\0'; strcpy(opBuffer, "vectorOpScalar("); strcat(opBuffer, $1); strcat(opBuffer, ", "); 
															  strcat(opBuffer, getVecSize($1)); strcat(opBuffer, ", "); strcat(opBuffer, $3); strcat(opBuffer, ", '"); strcat(opBuffer, $2); strcat(opBuffer, "')"); strcpy($$, createTmpVec(getVecSize($1)));}
															  else if(!isVector($1) && isVector($3)) { opBuffer[0] = '\0'; strcpy(opBuffer, "vectorOpScalar("); strcat(opBuffer, $3); strcat(opBuffer, ", "); 
															  strcat(opBuffer, getVecSize($3)); strcat(opBuffer, ", "); strcat(opBuffer, $1); strcat(opBuffer, ", '"); strcat(opBuffer, $2); strcat(opBuffer, "')"); strcpy($$, createTmpVec(getVecSize($3)));}
															  else {buffer[0]='\0'; strcat(buffer, $1); strcat(buffer, $2); strcat(buffer, $3); strcpy($$, buffer); } }	
					| expr dot term							{ strcpy($$, "\tvectorDotVector("); strcat($$, $1); strcat($$, ", "); strcat($$, getVecSize($1)); strcat($$, ", "); strcat($$, $3); strcat($$, ")"); }													  
					| '(' expr ')'							{ if(isVector($2)) { strcpy($$, $2); }
															  else { strcpy($$, "("); strcat($$, $2); strcat($$, ")"); } }
					| expr comma expr						{ if(isVector($1)) {fprintf(yyout, "\tprintVec(%s, %s);\n", $1, getVecSize($1)); strcpy($$, $3);}
															  else { fprintf(yyout, "\tprintf(\"%%d\\n\", %s);\n", $1);} strcpy($$, $3);}
					| op term								{ if(isVector($2)) { opBuffer[0] = '\0'; strcpy(opBuffer, "vectorOpScalar("); strcat(opBuffer, $2); strcat(opBuffer, ", "); 
															  strcat(opBuffer, getVecSize($2)); strcat(opBuffer, ", -1, '"); strcat(opBuffer, "*"); strcat(opBuffer, "')"); strcpy($$, createTmpVec(getVecSize($2))); }
															  else { if(strcmp($1, "-") == 0) { strcpy($$, $1); strcat($$, $2); }
															  else { strcpy($$, $2); } 
															  } }
					;
term				: number								{ ; }
					| identifier							{ ; }
					| const_vec								{ strcpy($$, getVecFromConst($1)); }
					| identifier position expr				{ if(isVector($3)) { buffer[0]='\0'; strcpy(buffer, "vectorsIndexing("); strcat(buffer, $1); strcat(buffer, ","); strcat(buffer, getVecSize($1)); 
															  strcat(buffer, ","); strcat(buffer, $3); strcat(buffer, ")"); strcpy(opBuffer, buffer); strcpy($$, createTmpVec(getVecSize($3))); } 
															  else { buffer[0]='\0'; strcat(buffer, $1); strcat(buffer, "["); strcat(buffer, $3); strcat(buffer,"]"); strcpy($$, buffer); } }
					| const_vec	position expr				{ strcpy($1, getVecFromConst($1));
															  if(isVector($3)) { buffer[0]='\0'; strcpy(buffer, "vectorsIndexing("); strcat(buffer, $1); strcat(buffer, ","); strcat(buffer, getVecSize($1)); 
															  strcat(buffer, ","); strcat(buffer, $3); strcat(buffer, ")"); strcpy(opBuffer, buffer); strcpy($$, createTmpVec(getVecSize($3)));} 
															  else { buffer[0]='\0'; strcat(buffer, $1); strcat(buffer, "["); strcat(buffer, $3); strcat(buffer,"]"); strcpy($$, buffer); } }
					;

%%                     /* C code */

void addVec(char* str, char* size) {
	strcpy(vecs[idx_vecs], str);
	strcpy(vec_sizes[idx_vecs], size);
	idx_vecs++;
}

int isVector(char* name) {
	for(int i = 0; i<idx_vecs; i++) {
		if(strcmp(vecs[i], name) == 0) return 1;
	}
	return 0;
}

char* getVecSize(char* name) {
	for(int i = 0; i<idx_vecs; i++) {
		if(strcmp(vecs[i], name) == 0) return vec_sizes[i];
	}

	return "0";
}

char* createTmpVec(char* size) {
	buffer[0] = '\0';
	char charNum[12];
	strcat(buffer, "int* tmp_vec");
	strcat(buffer, itoa(num_of_tmp_vecs++, charNum, 10));
	strcat(buffer, " = ");
	strcat(buffer, opBuffer);

	fprintf(yyout, "\t%s;\n", buffer);

	char name_of_vec[24];
	strcpy(name_of_vec, "tmp_vec");
	strcat(name_of_vec, charNum);
	addVec(name_of_vec, size);

	strcpy(buffer, name_of_vec);

	return buffer;
}

char* getVecFromConst(char* vector) {
	int len = strlen(vector);
	char charNum[12];
	int cnt_number = 1;
	for( int i=0; i<len; i++) {
		if(vector[i] == '[') vector[i] = '{';
		if(vector[i] == ']') vector[i] = '}';
		if(vector[i] == ',') cnt_number++;
	}
	buffer [0] = '\0';

	strcat(buffer, "int tmp_vec");
	strcat(buffer, itoa(num_of_tmp_vecs++, charNum, 10));
	strcat(buffer, "[] = ");
	strcat(buffer, vector);
	
	char name_of_vec[24];
	strcpy(name_of_vec, "tmp_vec");
	strcat(name_of_vec, charNum);
	addVec(name_of_vec, itoa(cnt_number, charNum, 10));

	fprintf(yyout, "\t%s;\n", buffer);

	strcpy(buffer, name_of_vec);

	return buffer;
}

char* getLoopStatement(char* str) {
	buffer[0] = '\0';
	strcat(buffer, "\tfor(iter_idx=0; iter_idx<");
	strcat(buffer, str);
	strcat(buffer, "; iter_idx++)");
	return buffer;
}

char* getPos(char* str) {
	buffer[0] = '\0';
	strcpy(buffer, str);
	int len = strlen(str);
	for(int i=0; i<len; i++) {
		if(buffer[i] == ':') buffer[i] = '[';
	}
	buffer[len-1] = ']';
	return buffer;
}

char* getVectorFuncs() {
	char vecFuncs[2048];
	vecFuncs[0] = '\0';

	strcat(vecFuncs, "int* vectorsToFree[1024];\n");
	strcat(vecFuncs, "int vecsToFreeIdx = 0;\n");
	strcat(vecFuncs, "void freeVectors() {\n");
	strcat(vecFuncs, "\tint sum = 0;\n");
	strcat(vecFuncs, "\tfor(int i=0; i<vecsToFreeIdx; i++) { free(vectorsToFree[i]); }\n");
	strcat(vecFuncs, "}\n\n");

	strcat(vecFuncs, "void vectorGetScalar(int* arr, int size, int val) {\n");
	strcat(vecFuncs, "\tfor(int i=0; i<size; i++) {\n");
	strcat(vecFuncs, "\t\tarr[i] = val;\n");
	strcat(vecFuncs, "\t}\n");
	strcat(vecFuncs, "}\n\n");

	strcat(vecFuncs, "void vectorGetVector(int* arr, int size, int* arr2) {\n");
	strcat(vecFuncs, "\tfor(int i=0; i<size; i++) {\n");
	strcat(vecFuncs, "\t\tarr[i] = arr2[i];\n");
	strcat(vecFuncs, "\t}\n");
	strcat(vecFuncs, "}\n\n");

	strcat(vecFuncs, "int* vectorsIndexing(int* arr, int size, int* arr2) {\n");
	strcat(vecFuncs, "\tint* tmp = malloc(sizeof(int)*size);\n");
	strcat(vecFuncs, "\tvectorsToFree[vecsToFreeIdx++] = tmp;\n");
	strcat(vecFuncs, "\tfor(int i=0; i<size; i++) {\n");
	strcat(vecFuncs, "\t\ttmp[i] = arr[arr2[i]];\n");
	strcat(vecFuncs, "\t}\n");
	strcat(vecFuncs, "\treturn tmp;\n");
	strcat(vecFuncs, "}\n\n");

	strcat(vecFuncs, "int* vectorOpScalar(int* arr, int size, int scl, char op) {\n");
	strcat(vecFuncs, "\tint* tmp = malloc(sizeof(int)*size);\n");
	strcat(vecFuncs, "\tvectorsToFree[vecsToFreeIdx++] = tmp;\n");
	strcat(vecFuncs, "\tif(op == '+') { for(int i=0; i<size; i++) tmp[i] = arr[i] + scl; }\n");
	strcat(vecFuncs, "\telse if(op == '-') { for(int i=0; i<size; i++) tmp[i] = arr[i] - scl; }\n");
	strcat(vecFuncs, "\telse if(op == '*') { for(int i=0; i<size; i++) tmp[i] = arr[i] * scl; }\n");
	strcat(vecFuncs, "\telse if(op == '/') { for(int i=0; i<size; i++) tmp[i] = arr[i] / scl; }\n");
	strcat(vecFuncs, "\treturn tmp;\n");
	strcat(vecFuncs, "}\n\n");

	strcat(vecFuncs, "int* vectorOpVector(int* arr, int size, int* arr2, char op) {\n");
	strcat(vecFuncs, "\tint* tmp = malloc(sizeof(int)*size);\n");
	strcat(vecFuncs, "\tvectorsToFree[vecsToFreeIdx++] = tmp;\n");
	strcat(vecFuncs, "\tif(op == '+') { for(int i=0; i<size; i++) tmp[i] = arr[i] + arr2[i]; }\n");
	strcat(vecFuncs, "\telse if(op == '-') { for(int i=0; i<size; i++) tmp[i] = arr[i] - arr2[i]; }\n");
	strcat(vecFuncs, "\telse if(op == '*') { for(int i=0; i<size; i++) tmp[i] = arr[i] * arr2[i]; }\n");
	strcat(vecFuncs, "\telse if(op == '/') { for(int i=0; i<size; i++) tmp[i] = arr[i] / arr2[i]; }\n");
	strcat(vecFuncs, "\treturn tmp;\n");
	strcat(vecFuncs, "}\n\n");

	strcat(vecFuncs, "int vectorDotVector(int* arr, int size, int* arr2) {\n");
	strcat(vecFuncs, "\tint sum = 0;\n");
	strcat(vecFuncs, "\tfor(int i=0; i<size; i++) { sum += arr[i] * arr2[i]; }\n");
	strcat(vecFuncs, "\treturn sum;\n");
	strcat(vecFuncs, "}\n\n");

	strcat(vecFuncs, "void printVec(int* arr, int size) {\n");
	strcat(vecFuncs, "\tprintf(\"[\");\n");
	strcat(vecFuncs, "\tfor(int i=0; i<size-1; i++) {\n");
	strcat(vecFuncs, "\t\tprintf(\"%d, \", arr[i]);\n");
	strcat(vecFuncs, "\t}\n");
	strcat(vecFuncs, "\tprintf(\"%d\", arr[size-1]);\n");
	strcat(vecFuncs, "\tprintf(\"]\\n\");\n");
	strcat(vecFuncs, "}\n\n");

	FILE* header_file = fopen("vector_functions.h", "w");
	fprintf(header_file, "// Author: Barak Daniel\n");
	fprintf(header_file, "// Project: vcc compiler\n");
	fprintf(header_file, "#include <stdio.h>\n");
	fprintf(header_file, "#include <stdlib.h>\n\n");
	fprintf(header_file, "%s", vecFuncs);
}

int main (int argc, char** argv) {	
	yyin = fopen(argv[1], "r");
	if(yyin == NULL) {
		printf("Could not open source code from '%s'\n", argv[1]);
		return 1;
	}

	yyout = fopen(argv[2], "w");
	if(yyout == NULL) {
		printf("Could not open destination file '%s'\n", argv[1]);
		return 1;
	}

	fprintf(yyout, "#include <stdio.h>\n");
	fprintf(yyout, "#include <stdlib.h>\n\n");
	fprintf(yyout, "#include \"vector_functions.h\"\n\n");

	getVectorFuncs();
	
	fprintf(yyout, "int main(void) {\n\n");
	fprintf(yyout, "\tint* tmp;\n");
	fprintf(yyout, "\tint iter_idx=0;\n\n");
	fprintf(yyout, "/* Start of your source code translation */\n");

	yyparse ( );
	
	fprintf(yyout, "/* End of your source code translation */\n\n");

	fprintf(yyout, "\tfreeVectors();\n");
	fprintf(yyout, "\treturn 0;\n}");

	return 0;
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 