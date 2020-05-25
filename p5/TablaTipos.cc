
#include "TablaTipos.h"

TablaTipos::TablaTipos()
{
  // inicializar con los tipos básicos

  unTipo b;

  b.clase = TIPOBASICO;
  b.tipoBase = ENTERO;  // por si acaso, aunque no se debe usar ENTERO==0 == posición en el vector 'tipos'
  b.tipoOrigen = b.tipoBase;
  b.tam = 1;
  tipos.push_back(b);

  b.tipoBase = REAL;  // tampoco se usa
  b.tipoOrigen = b.tipoBase;
  b.tam = 1;
  tipos.push_back(b);

  b.tipoBase = CHAR;  // tampoco se usa
  b.tipoOrigen = b.tipoBase;
  b.tam = 1;
  tipos.push_back(b);
}

unsigned TablaTipos::nuevoTipoArray(unsigned linf,unsigned lsup,unsigned tbase)
{
  unTipo a;

  a.clase = ARRAY;
  a.limiteInferior = linf;
  a.limiteSuperior = lsup;
  a.tipoBase = tbase;

  a.tipoOrigen = tipos[tbase].tipoOrigen;

  a.tam = (lsup-linf +1) * tipos[tbase].tam;

  a.arrTams.push_back(a.tam);
  for (unsigned i=0; i<tipos[tbase].arrTams.size(); i++) {
    a.arrTams.push_back(tipos[tbase].arrTams[i]);
  }

  tipos.push_back(a);
  return tipos.size()-1;
}
