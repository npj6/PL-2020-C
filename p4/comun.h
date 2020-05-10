#include <string>
#include <iostream>
#include <cstring>

using namespace std;

typedef struct {
  string lex;
  string trad;
  int linea;
  int columna;
  int tipo;
  string prefix;
  string indent;
} TOKEN;

#define YYSTYPE TOKEN


#define ERRLEXICO    1
#define ERRSINT      2
#define ERREOF       3
#define ERRLEXEOF    4

void msgError(int nerror,int nlin,int ncol,const char *s);
