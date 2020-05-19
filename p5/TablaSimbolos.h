

#ifndef _TablaSimbolos_
#define _TablaSimbolos_

#include <string>
#include <vector>

using namespace std;

const unsigned ENTERO=0;
const unsigned REAL=1;
const unsigned CHAR=2;

struct Simbolo {

  string nombre;
  unsigned tipo;
  unsigned dir;
  unsigned tam;
};


class TablaSimbolos {

   public:
   
      TablaSimbolos *padre;
      vector<Simbolo> simbolos;
   
   
   TablaSimbolos(TablaSimbolos *padre);

   bool buscarAmbito(Simbolo s); // ver si está en el ámbito actual
   
   bool anyadir(Simbolo s);
   Simbolo* buscar(string nombre);
};


#endif
