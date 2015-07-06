cpt : lex.yy.o y.tab.o hash.o utils.o list.o
	gcc -o cpt y.tab.o hash.o utils.o list.o lex.yy.o -ll


y.tab.o : y.tab.c
	gcc -c y.tab.c


y.tab.c, y.tab.h : cpt.y
	yacc -d cpt.y


lex.yy.o : lex.yy.c
	gcc -c lex.yy.c


lex.yy.c : cpt.l y.tab.h
	flex cpt.l

hash.o : hash.c hash.h
	gcc -c hash.c

utils.o : utils.c utils.h
	gcc -c utils.c

list.o : list.c list.h
	gcc -c list.c

clean : 
	rm *.o
	rm lex.yy.c
	rm y.tab.*
	rm cpt
