/* The authors of this work have released all rights to it and placed it
in the public domain under the Creative Commons CC0 1.0 waiver
(http://creativecommons.org/publicdomain/zero/1.0/).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
ERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Retrieved from: http://en.literateprograms.org/Hash_table_(C)?oldid=19638
*/

#include"hash.h"
#include<string.h>
#include<stdio.h>

struct hashnode_s {
	char *key;
	Propriedades prop;
	struct hashnode_s *next;
} hashnode_s;

typedef struct hashtbl {
	hash_size size;	
	struct hashnode_s **nodes;
	hash_size (*hashfunc)(const char *);
} HASHTBL;

typedef struct sVariavel {
	int tipo, endereco, posicoes, inicializado, categoria;
} sVariavel;


static char *mystrdup(const char *s)
{
	char *b;
	if(!(b=malloc(strlen(s)+1))) return NULL;
	strcpy(b, s);
	return b;
}

static hash_size def_hashfunc(const char *key)
{
	hash_size hash=0;
	
	while(*key) hash+=(unsigned char)*key++;

	return hash;
}

HTable hashtbl_create(hash_size size, hash_size (*hashfunc)(const char *))
{
	HTable hashtbl;

	if(!(hashtbl=malloc(sizeof(HASHTBL)))) return NULL;

	if(!(hashtbl->nodes=calloc(size, sizeof(HNode)))) {
		free(hashtbl);
		return NULL;
	}

	hashtbl->size=size;

	if(hashfunc) hashtbl->hashfunc=hashfunc;
	else hashtbl->hashfunc=def_hashfunc;

	return hashtbl;
}

void hashtbl_destroy(HTable hashtbl)
{
	hash_size n;
	HNode node, oldnode;
	
	for(n=0; n<hashtbl->size; ++n) {
		node=hashtbl->nodes[n];
		while(node) {
			free(node->key);
			oldnode=node;
			node=node->next;
			free(oldnode);
		}
	}
	free(hashtbl->nodes);
	free(hashtbl);
}

int hashtbl_insert(HTable hashtbl, const char *key, int tip, int end, int pos, int inic, int cate)
{
	HNode node;
	hash_size hash=hashtbl->hashfunc(key)%hashtbl->size;

	Propriedades p = (Propriedades) malloc(sizeof(struct sVariavel));
	p->endereco = end;
	p->tipo = tip;
	p->posicoes = pos;
	p->inicializado = inic;
	p->categoria = cate;
/*	fprintf(stderr, "hashtbl_insert() key=%s, hash=%d, =%s\n", key, hash, (char*)data);*/

	node=hashtbl->nodes[hash];
	while(node) {
		if(!strcmp(node->key, key)) {
			node->prop = p;
			return 0;
		}
		node=node->next;
	}

	if(!(node=malloc(sizeof(struct hashnode_s)))) return -1;
	if(!(node->key=mystrdup(key))) {
		free(node);
		return -1;
	}
	node->prop = p;
	node->next=hashtbl->nodes[hash];
	hashtbl->nodes[hash]=node;
	
	

	return 0;
}

int hashtbl_remove(HTable hashtbl, const char *key)
{
	HNode node, prevnode=NULL;
	hash_size hash=hashtbl->hashfunc(key)%hashtbl->size;

	node=hashtbl->nodes[hash];
	while(node) {
		if(!strcmp(node->key, key)) {
			free(node->key);
			if(prevnode) prevnode->next=node->next;
			else hashtbl->nodes[hash]=node->next;
			free(node);
			return 0;
		}
		prevnode=node;
		node=node->next;
	}

	return -1;
}

Propriedades hashtbl_get(HTable hashtbl, const char *key)
{
	HNode node;
	hash_size hash=hashtbl->hashfunc(key)%hashtbl->size;

/*	fprintf(stderr, "hashtbl_get() key=%s, hash=%d\n", key, hash);*/

	node=hashtbl->nodes[hash];
	while(node) {
		if(!strcmp(node->key, key)) return node->prop;
		node=node->next;
	}

	return NULL;
}
int hashtbl_resize(HTable hashtbl, hash_size size)
{
	HASHTBL newtbl;
	hash_size n;
	HNode node, nextnode;

	newtbl.size=size;
	newtbl.hashfunc=hashtbl->hashfunc;

	if(!(newtbl.nodes=calloc(size, sizeof(struct hashnode_s*)))) return -1;

	for(n=0; n<hashtbl->size; ++n) {
		for(node=hashtbl->nodes[n]; node; node=nextnode) {
			nextnode=node->next;
			Propriedades p = node->prop;
			hashtbl_insert(&newtbl, node->key,p->tipo, p->endereco, p->posicoes, p->inicializado,p->categoria );
			hashtbl_remove(hashtbl, node->key);
		}
	}

	free(hashtbl->nodes);
	hashtbl->size=newtbl.size;
	hashtbl->nodes=newtbl.nodes;

	return 0;
}



/************************************
	Funções Auxiliares
	  -Propriedades-
************************************/

int inicializada (Propriedades p) {
	return p->inicializado;
}

int getEndereco (Propriedades p) {
	return p->endereco;
}

int getPosicoes (Propriedades p) {
	return p->posicoes;
}

int getTipo (Propriedades p) {
	return p->tipo;
}

void setEndereco (Propriedades p, int end) {
	p->endereco = end;
}

void inicializa (Propriedades p){
	p->inicializado = 1;
}

void printProp (Propriedades p) {
	if (p!=NULL) printf ("Tipo : %d | Endereço : %d | Posições : %d | Está Inicializado? : %d \n", p->tipo, p->endereco, p->posicoes, p->inicializado);
	else printf ("Nulo!!\n");
}

