%{
#include "y.tab.h"

char *aux;
%}

id [a-zA-Z][a-zA-Z0-9_]*
num [0-9]+
%%
"<<"			{ return READ;}
">>"			{ return PRINT;}

[ \t\n\r]			;

"{"			{ return '{';}
"}"			{ return '}';}
"("			{ return '(';}
")"			{ return ')';}
";"			{ return ';';}
"="			{ return '=';}
","			{ return ',';}
"!"			{ return '!';}
"<"			{ return '<';}
">"			{ return '>';}
"+"			{ return '+';}
"-"			{ return '-';}
"*"			{ return '*';}
"%"			{ return '%';}
"/"			{ return '/';}
"["			{ return '[';}
"]"			{ return ']';}

"entao"			{ return ENTAO;}
"para"			{ return PARA;}
"enquanto"		{ return ENQUANTO;}
"se"			{ return SE;}
"senao"			{ return SENAO;}
"DECLARACAO"		{ return DECLARACAO;}
"TERMINADA"		{ return TERMINADA;}
"CPT"			{ return CPT;}
"int"			{ return INT;}

"=="			{ return EQ;}
"!="			{ return NEQ;}
"<="			{ return LEQ;}
">="			{ return GEQ;}

"&&"			{ return AND;}
"||"			{ return OR;}



\".+\"			{ 
			  yylval.vals = strdup(yytext);
			  return string;
			}
{num}			{
			  yylval.vali = atoi(yytext);
			  return num;
			}
{id}			{
			  yylval.vals = strdup(yytext); 
			  return id;
			}

.			{ return ERRO;}

%%

int yywrap() {
	return 1;
}
