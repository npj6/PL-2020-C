
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
  unsigned tam;
};

class TablaTipos {

  public:

     vector<unTipo> tipos;

     TablaTipos();
     unsigned nuevoTipoArray(unsigned linf,unsigned lsup,unsigned tbase);

};

#endif
