
#include <string>
#include <vector>

using namespace std;

const int ENTERO=1;
const int REAL=2;
const int CLASSFUN=3;

struct Simbolo {

  string nombre;
  int tipo;
  string nomtrad;
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


