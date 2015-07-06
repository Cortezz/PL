/* The authors of this work have released all rights to it and placed it
in the public domain under the Creative Commons CC0 1.0 waiver
(http://creativecommons.org/publicdomain/zero/1.0/).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Retrieved from: http://en.literateprograms.org/Hash_table_(C)?oldid=19638
*/

#ifndef HASHTBL_H_INCLUDE_GUARD
#define HASHTBL_H_INCLUDE_GUARD

#define INTEIRO 1000
#define ARRAY_INTEIRO 1001 

#define VARIAVEL 900

#include<stdlib.h>

typedef struct hashnode_s *HNode;
typedef struct hashtbl *HTable;
typedef struct sVariavel *Propriedades;

typedef size_t hash_size;



HTable hashtbl_create(hash_size size, hash_size (*hashfunc)(const char *));
void hashtbl_destroy(HTable hashtbl);
int hashtbl_insert(HTable hashtbl, const char *key, int,int,int,int,int);
int hashtbl_remove(HTable hashtbl, const char *key);
Propriedades hashtbl_get(HTable hashtbl, const char *key);
int hashtbl_resize(HTable hashtbl, hash_size size);



/******************************
	Funções Extra
	 -Propriedades-
********************************/
int inicializada (Propriedades);
int getEndereco (Propriedades);
int getTipo (Propriedades);
int getPosicoes (Propriedades);
void setEndereco (Propriedades, int);
void inicializa (Propriedades);
void printProp (Propriedades);


#endif
