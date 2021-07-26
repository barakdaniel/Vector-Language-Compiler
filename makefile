vcc.exe: lex.yy.c vcc.tab.c
	gcc lex.yy.c vcc.tab.c -o vcc.exe

lex.yy.c: vcc.tab.c vcc.l
	flex vcc.l

vcc.tab.c: vcc.y
	bison -d vcc.y --debug

clean: 
	del lex.yy.c vcc.tab.c vcc.tab.h vcc.exe