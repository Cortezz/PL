#include "list.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct nodo {
	char* s;
	struct nodo * prox;
} nodo;


LList insere (LList l, char* ss) {
	LList novo, prim;
	novo = (LList) malloc (sizeof(struct nodo));
	novo->s = strdup(ss);
	novo->prox = NULL;
	
	if (l!=NULL) {
		prim = l;
		while (l->prox!=NULL) 
			l = l->prox;
		l->prox = novo; 
	}
	if (l==NULL) prim = novo;
	return prim;
}

LList  Lremove (LList l, char ** s) {
	LList ant,trav;
	trav = l;
	if (l!=NULL) {
		if (l->prox==NULL) {
			*s = strdup (l->s);
			free(l);
			l = NULL;
			}
		else {
			trav = l;
			while (trav->prox!=NULL) {
				ant = trav;
				trav = trav->prox;
				}
			ant->prox = NULL;
			*s = strdup(trav->s);
			free(trav);
			}
		}
	return l;
}

LList removeCabeca (LList l, char ** s) {
	LList aux;
	if (l!=NULL) {
		if (l->prox==NULL) {
			*s = strdup(l->s);
			free(l);
			l = NULL;
			}
		else {
			*s = strdup(l->s);
			aux = l;
			l = l->prox;
			free(aux);
			}
	}
	return l;
}
		


void libertaLista (LList l) {
	LList seg;
	while (l->prox!=NULL) {
		l = seg;
		seg = l->prox;
		free(l);
		}
	free (seg);
}

void imprimeLista (LList l) {
	if (l!=NULL) {
		while (l->prox!=NULL) {
			printf ("%s\n", l->s);
			l=l->prox;
			}
		printf ("%s\n", l->s);
	}
}

void LLtoFile (LList l,char *nomeFich) {
	if (l!=NULL) {
		FILE *f;
		int i;
		f = fopen (nomeFich, "w");
		while (l->prox!=NULL) {
			fprintf (f, "%s\n", l->s);
			l=l->prox;
			}
		fprintf(f,"%s\n", l->s);
	}
}



		 	
