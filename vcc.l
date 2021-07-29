%{
#include "vcc.tab.h"
#include "string.h"
void yyerror (char *s);
int yylex();
%}
%%
"scl"                                                   { return scl; }
"vec"                                                   { return vec; }
\[[ ]*-?[ ]*[0-9]+([ ]*,[ ]*-?[ ]*[0-9]+[ ]*)*\]        { strcpy(yylval.expression, yytext); return const_vec; }
"print"                                                 { return print; }
"loop"                                                  { return loop; }
"if"                                                    { return if_statement; }
[{][0-9]+[}]                                            { sscanf(yytext, "%s", yylval.num); return size; }
[{}]                                                    { return yytext[0]; }
"="                                                     { sscanf(yytext, "%s", yylval.eq); return equal; }
";"                                                     { return semiCol; }
[a-zA-Z]([a-zA-Z0-9]+)?                                 { sscanf(yytext, "%s", yylval.id); return identifier; }
[0-9]+                                                  { sscanf(yytext, "%s", yylval.num); return number; }
[+-]                                                    { sscanf(yytext, "%s", yylval.oper); return op; }
[*/]                                                    { sscanf(yytext, "%s", yylval.oper); return op2; }
[.]                                                     { sscanf(yytext, "%s", yylval.oper); return dot; }
[(]                                                     { sscanf(yytext, "%s", yylval.oper); return yytext[0]; }
[)]                                                     { sscanf(yytext, "%s", yylval.oper); return yytext[0]; }
[:]                                                     { sscanf(yytext, "%s", yylval.oper); return position; }
[,]                                                     { sscanf(yytext, "%s", yylval.oper); return comma; }
[ \t\n]                                                 ;
.                                                       { ECHO; yyerror ("unexpected character"); }

%%
int yywrap (void) {return 1;}
