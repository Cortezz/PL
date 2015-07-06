#ifndef list_h
#define list_h

typedef struct nodo *LList;

LList insere (LList, char*);
void libertaLista (LList);
void imprimeLista (LList);
void LLtoFile (LList, char *);
LList Lremove (LList, char **);
LList removeCabeca (LList, char**);
#endif
