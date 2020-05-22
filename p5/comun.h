#include <string>
#include <iostream>
#include <cstring>
#include <tuple>
#include <vector>

using namespace std;

typedef struct {
  string lex;
  int linea;
  int columna;

  unsigned lInf, lSup;
  vector<tuple<unsigned, unsigned> > *limites;
  int tipo; //dentro de los tipos se usa como tipoBase

  unsigned dir;
} TOKEN;

#define YYSTYPE TOKEN


const int ERRLEXICO=1,
          ERRSINT=2,
          ERREOF=3,
          ERRLEXEOF=4,

          ERR_YADECL=5,
          ERR_NODECL=6,
          ERR_NOCABE=7,
          ERR_MAXTEMP=8,

          ERR_RANGO=9,
          ERR_IFWHILE=10,

          ERR_TOCHR=11,

          ERR_FALTAN=12,
          ERR_SOBRAN=13,
          ERR_INDICE_ENTERO=14,

          ERR_ASIG=15,

          ERR_OPIZQ=16,
          ERR_OPDER=17;

void errorSemantico(int nerror,int fila,int columna,const char *s);
void errorSemantico(int nerror, const TOKEN &t);
void msgErrorOperador(int tipoesp,const char *op,int linea,int columna,int lado);
void msgError(int nerror,int nlin,int ncol,const char *s);
