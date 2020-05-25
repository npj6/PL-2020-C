
#ifndef _TablaTipos_
#define _TablaTipos_

#include <vector>

using namespace std;

#include "TablaSimbolos.h"

const unsigned TIPOBASICO=0,ARRAY=1;



struct unTipo {
  unsigned clase;             // TIPOBASICO o ARRAY
  unsigned limiteInferior;
  unsigned limiteSuperior;
  unsigned tipoBase;
  unsigned tipoOrigen;
  unsigned tam;
  vector<unsigned> arrTams;
  //tenia que elegir entre redundancia por cada tipo nuevo
  //o tener que recorrer una mini lista por cada acceso a un array
  //elegi lo primero.
};

class TablaTipos {

  public:

     vector<unTipo> tipos;

     TablaTipos();
     unsigned nuevoTipoArray(unsigned linf,unsigned lsup,unsigned tbase);

};

#endif
