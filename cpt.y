%{
#include <stdio.h>
#include <string.h>

#include "utils.h"
#include "hash.h"
#include "list.h"

extern int yylex();

//Operações
void pushDeclaracao(char *,int,int);
void pushG (char * );
void loadN(char * );
void pushA(char *);
void storeG (char *);

void insereVariaveis (int, int);
void guardaInstrucaoLiteral (char* );
char * retiraNumeroInstrucao (char *);
void guardaInstrucao (char* , int ,int, int);
void guardaErro (char* , char*);
void guardaLabel (char *,int);
void guardaInstrucaoLabel (char*, int);
void guardaInstrucaoString (char*, char*);


LList codigo,erros, para, variaveis;
//Program Counter, Error Counter, Variable Counter, Para Label Counter, Se Label Counter, Enquanto Label Counter.
int pc=1, ec=0, cv = 0, lc_para = 1,lc_se = 1, lc_enquanto = 1;
HTable tabelaSimbolos;
%}

%union {
	char* vals;
	int vali;
	
	struct sVariavel {
		char* ident;
		int tipo;
	} variavel;
	
	struct sTipo {
		int tipo, posicoes;
	} tipo;

	
}
%nonassoc "ENTAO"
%nonassoc SENAO

%left '*' '/' '%' AND
%left '+' '-' OR
%left '<' '>' GEQ LEQ EQ NEQ


%token ERRO
%token id string num
%token DECLARACAO CPT TERMINADA INT
%token ENQUANTO PARA SE SENAO ENTAO
%token READ PRINT
%token AND OR
%token EQ NEQ GEQ LEQ

%type <variavel> Variavel
%type <vals> id string 
%type <vali> OpRel OpAd OpMult num ExpLogica
%type <tipo> Tipo

%start Funcao

%%

Funcao: CPT '{' Corpo '}' {guardaInstrucao("STOP",0,-1,-1);}
	;


Corpo: BlocoDeclaracoes BlocoInstrucoes
	;

BlocoDeclaracoes : 
		 | DECLARACAO ListaDeclaracoes ';' TERMINADA { guardaInstrucao("START", 0,-1,-1);}
		 ;
ListaDeclaracoes : Declaracao
		 | ListaDeclaracoes ';' Declaracao
		 ;

Declaracao : Tipo ListaVars { insereVariaveis ($1.tipo, $1.posicoes);} 
	   ; 

ListaVars : ListaVars ',' id {variaveis = insere (variaveis,$3);} 
	  | id 	{variaveis = insere (variaveis,$1);}
	  ; 

Tipo : INT { $$.tipo = INTEIRO; $$.posicoes = 1;}	
     | INT'['num']' {$$.tipo = ARRAY_INTEIRO; $$.posicoes = $3;}	 
     ;




BlocoInstrucoes : BlocoInstrucoes Instrucao
		| Instrucao
		; 

Instrucao: InstrucaoCiclica
	 | InstrucaoCondicional
	 | InstrucaoIO ';'
	 | InstrucaoAtribuicao ';'
	 | '{' BlocoInstrucoes '}'
	 ;

InstrucaoCiclica : PARA '('ListaAtribuicoes';'{guardaLabel("INICIO_CICLO_",lc_para);$<vali>$=lc_para;} ExpLogica {guardaInstrucaoLabel("JZ FIM_CICLO_",$<vali>5);} ';'ListaAtribuicoes')'
		 {
		   int i,diff;
		   char * s;
		   diff = pc - ($6+1);
		   $6 = diff;
		   for(i=0;i<diff;i++){
			codigo = Lremove(codigo,&s);
			para = insere (para,s);
			pc--;
			}
		   lc_para++; 
			
		 } Instrucao 
		 {
		   int i;
		   char * s;
		   for (i=0;i<$6;i++){
			para = Lremove(para,&s);
			s = retiraNumeroInstrucao(s);
			guardaInstrucaoLiteral(s);
			}
		   guardaInstrucaoLabel ("JUMP INICIO_CICLO_", $<vali>5);
		   guardaLabel("FIM_CICLO_", $<vali>5);
		 }
			
		 | ENQUANTO {guardaLabel("INICIO_CICLO_ENQUANTO_",lc_enquanto);$<vali>$ = lc_enquanto;} '(' ExpLogica ')'{guardaInstrucaoLabel ("JZ FIM_CICLO_ENQUANTO_",$<vali>2);lc_enquanto++;} Instrucao 
		 { 
			guardaInstrucaoLabel("JUMP INICIO_CICLO_ENQUANTO_", $<vali>2);
			guardaLabel("FIM_CICLO_ENQUANTO_",$<vali>2);
		 }
		 ;

InstrucaoCondicional : SE '(' ExpLogica ')' {guardaInstrucaoLabel("JZ FIM_SE_",lc_se); $<vali>$ = lc_se;lc_se++;} Instrucao {guardaLabel("FIM_SE_",$<vali>5);} %prec "ENTAO"
		     | SE '(' ExpLogica ')' ENTAO {guardaInstrucaoLabel("JZ SENAO_", lc_se); $<vali>$ = lc_se;} Instrucao 
		     {
		      guardaInstrucaoLabel("JUMP FIM_SE_",$<vali>6); 
		      guardaLabel("SENAO_",$<vali>6);
		     } SENAO Instrucao {lc_se++;}
		     ; 



InstrucaoIO : InstrucaoOutput
	    | InstrucaoInput
	    ; 

InstrucaoInput : Variavel READ 
	       { 
		  guardaInstrucao("READ",0,-1,-1); 
		  guardaInstrucao("ATOI",0,-1,-1); 
		  Propriedades p = hashtbl_get(tabelaSimbolos,$1.ident);
		  if (p!=NULL) {
		  	if ($1.tipo==INTEIRO)
		  		storeG($1.ident);
			else {
				guardaInstrucao("STOREN",0,-1,-1);
			}
			inicializa(p);			
	       	  }
	       }
	       ;

InstrucaoOutput : PRINT Exp { guardaInstrucao("WRITEI ",0,-1,-1);}
	        | PRINT string {guardaInstrucaoString ("PUSHS ",$2);guardaInstrucao("WRITES",0,-1,-1);} 
	        ;

Variavel : id 
	 { $$.ident = $1;$$.tipo = INTEIRO;
	   Propriedades p = hashtbl_get(tabelaSimbolos,$1);
	   if (p==NULL) guardaErro ("Erro de declaracao: A variável ainda não foi declarada: ", $1);
	 } 
	 | id { pushA($1);} '['Exp']' 
	 { $$.ident = $1; $$.tipo = ARRAY_INTEIRO;
	   Propriedades p = hashtbl_get(tabelaSimbolos,$1);
	   if (p==NULL) guardaErro ("Erro de declaracao: A variável ainda não foi declarada: ", $1);
	 }
	 ; 

InstrucaoAtribuicao : Variavel '=' Exp 
		    {
			Propriedades p = hashtbl_get(tabelaSimbolos, $1.ident);
			if ($1.tipo == INTEIRO) {
				if (p!=NULL){
					if (!inicializada(p)) inicializa(p);
					storeG($1.ident);
					}
				}
			else {
				if (p!=NULL){
					if (!inicializada(p)) inicializa(p);
					guardaInstrucao("STOREN ", 0, -1,-1);
				}
		    	}
		    }
    		    ;
	 

ExpLogica : Exp	 {$$ = pc;}
	  | Exp OpRel Exp 
	  {
		switch($2){
			case IGUAL:
				guardaInstrucao("EQUAL", 0, -1, -1);
				$$ = pc;
				break;
			case DIFERENTE:
				guardaInstrucao("EQUAL",0,-1,-1);
				guardaInstrucao("NOT",0,-1,-1);
				$$ = pc;
				break;
			case MAIOR:
				guardaInstrucao("SUP", 0,-1,-1);
				$$ = pc;
				break;
			case MAIORIGUAL:
				guardaInstrucao("SUPEQ",0,-1,-1);
				$$ = pc;
				break;
			case MENOR:
				guardaInstrucao("INF",0,-1,-1);
				$$ = pc;
				break;
			case MENORIGUAL:
				guardaInstrucao("INFEQ",0,-1,-1);
				$$ = pc;
				break;
		}
		
		
	  }
	  ;

Exp : Termo
    | Exp OpAd Termo 
    {
	switch ($2) {
		case ADICAO: 
			guardaInstrucao("ADD",0,-1,-1);
			break;
		case SUBTRACCAO:
			guardaInstrucao("SUB",0,-1,-1);
			break;
		case OU:
			guardaInstrucao("ADD", 0, -1, -1);
			break; 
		}	
    }
    ;

Termo : Termo OpMult Factor 
      {
	switch ($2) {
	   	case MULTI: 
		     guardaInstrucao("MUL", 0,-1,-1); 
	  	     break;
		case DIVISAO:
		     guardaInstrucao("DIV", 0,-1,-1);
		     break;
		case RESTO:
		     guardaInstrucao("MOD",0,-1,-1);
		     break;
		case EE:
		     guardaInstrucao("MUL", 0, -1,-1);
		     break;
		}

      }
      | Factor
      ;

Factor : num { guardaInstrucao("PUSHI ", 1,$1,-1);}
       | Variavel
       {
	 switch ($1.tipo) {
		case INTEIRO:
			pushG ($1.ident);
			break;
		case ARRAY_INTEIRO:	
			loadN($1.ident);
			break;
		}
			
       }
       | '(' ExpLogica ')'
       | '!' ExpLogica {guardaInstrucao("NOT",0,-1,-1);}
       ; 




OpRel	 : EQ	{$$ = IGUAL;}
	 | NEQ	{$$ = DIFERENTE;}
	 | GEQ	{$$ = MAIORIGUAL;}
	 | LEQ	{$$ = MENORIGUAL;}
	 | '<'	{$$ = MENOR;}
	 | '>'	{$$ = MAIOR;}
	 ;

OpAd	 : '+' { $$ = ADICAO;}
	 | '-' { $$ = SUBTRACCAO;}
	 | OR  { $$ = OU;}
	 ;

OpMult   : '*'	{ $$ = MULTI;}
	 | '/'	{ $$ = DIVISAO;}
	 | '%'	{ $$ = RESTO;}
	 | AND  { $$ = EE;}
	 ;


ListaAtribuicoes : ListaAtribuicoes ',' InstrucaoAtribuicao
		 | InstrucaoAtribuicao
		 ; 	  
 


%%

/*Trata da escrita das instruções de pseudo-código assembly relativas às declarações de variáveis.
	@key - Identificador da variável que é usada como chave para a tabela de hash.
	@tipo - Tipo da variável.
	@posicoes - Número de posições do array. Utilizado somente quando se trata deste mesmo.
*/
void pushDeclaracao (char *key, int tipo, int posicoes) {
	int i;
	
	//Tabela de símbolos 
	Propriedades p = hashtbl_get(tabelaSimbolos,key);
	switch (tipo) {
		case INTEIRO:
			setEndereco(p,cv);
			cv++;
			//Código
			guardaInstrucao("PUSHI", 1, 0, -1);
			break;
		case ARRAY_INTEIRO:
			setEndereco(p,cv);
			cv += getPosicoes(p)+1;
			guardaInstrucao("PUSHN", 1, posicoes, -1);
			break;
	}
}

/* Efectua o tratamento necessário para escrever a instrução PUSHG.
	Cobre os seguintes erros semânticos:
		- Erro de tipo - Quando a variável é usada como array em vez de inteiro.
		- Erro de atribuição - Quando é usada sem ter sido previamente atribuído um valor.

		@ident - Identificador da variável.
*/
void pushG (char* ident) {
	int end;
	
	//Tabela de símbolos
	Propriedades p = hashtbl_get(tabelaSimbolos, ident);
	if (p!=NULL) {
		if (getTipo(p)==ARRAY_INTEIRO) guardaErro ("Erro de Tipo: A variável é do tipo array e está a ser usada como um inteiro escalar: ", ident);
		else {
			if (!inicializada(p)) guardaErro ("Erro de Atribuição: Não foi atribuído nenhum valor à variável: ", ident);
			else {
				end = getEndereco(p);

				//Código
				guardaInstrucao("PUSHG", 1, end, -1);
			}
		}
	}
}

/*Efectua os tratamentos necessários para escrever a instrução LOADN.
	Cobre os seguintes erros semânticos:
		- Erro de tipo: Array a ser usado como inteiro
		- Erro de atribuição: Nenhuma das células do array foi inicializada.
*/
void loadN (char* ident) {
	
	Propriedades p = hashtbl_get(tabelaSimbolos, ident);
	if (p!=NULL) {
		if (getTipo(p)==INTEIRO) guardaErro ("Erro de Tipo: A variável é do tipo inteiro escalar e está a ser usada como um array: ", ident);
		else {
			if (!inicializada(p)) guardaErro ("Erro de Atribuição: Nenhuma das células do array foi inicializado: ", ident);
			else {
				guardaInstrucao("LOADN",0,-1,-1);
			}
		}
	}
}

/* Efectua o tratamento necessário para escrever a instrução PUSHA.
	Cobre os sguintes erros semânticos:
		- Erro de tipo - Quando a variável é usada como se fosse um inteiro em vez de array.

		@ident - Identificador da variável.
*/
void pushA (char* ident) {
	int end;
	
	//Tabela de símbolos
	Propriedades p = hashtbl_get(tabelaSimbolos, ident);
	if (p!=NULL) {
		if (getTipo(p)==INTEIRO) guardaErro ("Erro de Tipo: A variável é do tipo inteiro escalar e está a ser usada como um array: ", ident);
		else {
			end = getEndereco(p);
			//Código
			guardaInstrucao("PUSHA ", 1, end, -1);
		}
	}
}

/* Efectua o tratamento necessário para escrever a instrução STOREG
	@key - Identificador da variável.
*/
	
void storeG (char *key) {
	int end,valor;
	
	//Tabela de símbolos
	Propriedades p = hashtbl_get(tabelaSimbolos, key);
	if (getTipo(p)== ARRAY_INTEIRO) guardaErro ("Erro de Tipo: A variável é um array e está a ser usado como um inteiro escalar: ",key);
	else { 
		end = getEndereco(p);
		//Código
		guardaInstrucao ("STOREG", 1, end, -1);
	}
}

		
/* Concatena o PC com o código da operação e respectivos argumentos.
 Em suma, guarda a instrução na lista ligada de pseudo-código, incrementando o PC depois.
 É utilizado para guardar a maior parte das instruções (há algumas excepções).
	@codOp - Código da operação.
	@nArgs - Número de argumentos utilizados (0, 1 ou 2).
	@arg1 - Valor do primeiro argumento (somente utilizado se nArgs >=1).
	@arg2 - Valor do segundo argumento (somente utilizado se nArgs == 2).
*/
void guardaInstrucao (char* codOp, int nArgs, int arg1, int arg2) {
	char* aux, *s;
	aux = itoa(pc);
	s = strcat_copy (aux, "\t\t");
	s = strcat_copy (s, codOp);
	if (nArgs==0)  
		codigo = insere(codigo,s);
	else if (nArgs==1) {
		aux = itoa(arg1);
		s = strcat_copy (s," ");
		s = strcat_copy(s,aux);
		codigo = insere(codigo,s);
		}
	else if (nArgs ==2) {
		aux = itoa(arg1);
		s = strcat_copy (s, aux);
		aux = itoa(arg2);
		s = strcat_copy(s,aux);
		codigo = insere(codigo,s);
		}
	pc++;
}

/* Concatena o PC com o código da operação e depois com um String que é passada como argumento.
 É usada para guardar a instrução PUSHS <string>.
	@codOp - Código da operação.
	@argS - String a ser concatenada. 
*/
void guardaInstrucaoString (char* codOp, char* argS) {
	char * s;
	s = strcat_copy (itoa(pc),"\t\t");
	s = strcat_copy (s, codOp);
	s = strcat_copy (s, argS);
	codigo = insere (codigo,s);
	pc++;
}


/* Guarda uma label na lista ligada de pseudo-código. Não incrementa o PC.
	@lab - Nome da label
	@ident - Número da label
*/ 
void guardaLabel (char *lab, int ident) {
	char *s;
	s = strcat_copy (lab, itoa(ident));
	s = strcat_copy (s, ":");
	codigo = insere(codigo, s);
	
}


/* Concatena uma string ao PC, incrementado-o no final. 
 Utilizada somente nos ciclos para (for).
	@cod - String a ser concatenada.
*/
void guardaInstrucaoLiteral (char* cod) {
	char *s;
	s = strcat_copy (itoa(pc), "\t\t");
	s = strcat_copy (s, cod);
	codigo = insere(codigo,s);
	pc++;
}

/* Guarda uma instrução que que utilize uma Label como argumento.
 Usada nas instruções cíclicas e condicionais.
	@ cod - Código da instrução
	@ label - Número da label
*/
void guardaInstrucaoLabel (char* cod, int label) {
	char *s = strcat_copy (itoa(pc), "\t\t");
	s = strcat_copy(s, cod);
	s = strcat_copy(s, itoa(label));
	codigo = insere(codigo, s);
	pc++;
}

/* Retira o número (pc) associado a uma instrução. 
   Utilizada nos ciclos para(for) para garantir que a ordenação dos números está correcta.
	@inst - Instrução completa.
	@ret - Instrução sem o número de identificação.
*/
char * retiraNumeroInstrucao (char *inst) {
	char * s;
	s = strtok (inst, "\t\t");
	s = strtok (NULL, "\t\t");
	return s;
}


/* Insere todas as variáveis da lista ligada "variaveis" na tabela de hash.
   Verifica os seguintes erros semânticos:
	- Erro de declaração : Já foi usado o mesmo identificador para declarar outra variável.

	@tipo - Tipo de todas as variáveis da lista.
	@posicoes - Número de posições que ocupam (1 no caso de ser escalar e N no caso de ser um array).
*/
void insereVariaveis (int tipo, int posicoes) {
	char *s; 

	while (variaveis!=NULL) {
		variaveis = removeCabeca (variaveis,&s); 
		
		Propriedades p= hashtbl_get(tabelaSimbolos, s);
		if (p!=NULL) guardaErro("Erro de Declaração: Já foi declarada uma variável com o nome: ", s);
		else {
			hashtbl_insert (tabelaSimbolos, s, tipo ,0,posicoes,0,VARIAVEL);
		pushDeclaracao(s,tipo,posicoes);
		}
	}
		
	 
}

/* Guarda um erro na lista ligada "erros".
	@erro - String que corresponde ao erro 
	@ident - Identificador da variável
*/
void guardaErro (char* erro, char* ident) {
	char * s;
	s  = strcat_copy (erro,ident);
	erros = insere(erros, s);
	ec++;
}


int yyerror (char *s) {
	printf("Erro Sintáctico: %s\n", s);
}

int main () {
	int i;
	tabelaSimbolos = hashtbl_create(10,NULL);
	yyparse();
	if (ec==0) {
		imprimeLista(codigo);
		LLtoFile(codigo,"meuprog.s");
		printf ("Program Counter - %d\n", pc);
	}
	else { 
		printf ("O programa não foi compilado devido à existência de erros:\n");
		imprimeLista(erros);
		}
		
	return 0;	
}
