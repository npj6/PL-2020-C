%token PRG VAR
%token INTT REALT CHART
%token IF ELSE WHILE
%token PRN READ TOCHR TOINT
%token ID NUMENTERO NUMREAL CTECHAR
%token COMA PYC DOSP PTOPTO
%token PARI PARD OPREL OPAS OPMD ASIG CORI CORD
%token LBRA RBRA

%{
  #include "comun.h"
  #include "TablaSimbolos.h"
  #include "TablaTipos.h"
  #include "MemoryManager.h"

  extern int column, line, findefichero;

  extern int yylex();
  extern char *yytext;
  extern FILE *yyin;

  TablaTipos tipos;
  TablaSimbolos simbolos(NULL);
  MemoryManager memoria(16000);

  void mostrarTipos(void);
  string nombreTipo(unsigned tipo);
  void nombreTipo(unsigned tipo, string &tipoString);

  void nuevoSimbolo(const TOKEN &id, const TOKEN &dosp);
  void buscarSimbolo(TOKEN &id);

  unsigned comprobarTipo(const vector<tuple<unsigned, unsigned> > &limites, unsigned tbase);
  unsigned nuevoTipoArray(unsigned linf, unsigned lsup, unsigned tbase);

  int yyerror(char *s);

%}

%%
s           : PRG ID DOSP blvar bloque {mostrarTipos();}
            ;
bloque      : LBRA seqinstr RBRA
            ;
blvar       : VAR decl PYC
            ;
decl        : decl PYC dvar
            | dvar
            ;
dvar        : tipo {$$.tipo = comprobarTipo(*$1.limites, $1.tipo); delete $1.limites;} DOSP {$$.tipo = $2.tipo;} lident
            ;
tiposimple  : INTT {$$.tipo = ENTERO; $$.limites = new vector<tuple<unsigned, unsigned> >();}
            | REALT {$$.tipo = REAL; $$.limites = new vector<tuple<unsigned, unsigned> >();}
            | CHART {$$.tipo = CHAR; $$.limites = new vector<tuple<unsigned, unsigned> >();}
            ;
tipo        : tiposimple {$$.tipo = $1.tipo; $$.limites = $1.limites;}
            | CORI rango dims {$$.tipo = $3.tipo; $$.limites = $3.limites; $$.limites->push_back(make_tuple($2.lInf, $2.lSup));}
            ;
dims        : COMA rango dims {$$.limites = $3.limites; $$.limites->push_back(make_tuple($2.lInf, $2.lSup));}
            | CORD tiposimple {$$.limites = $2.limites; $$.tipo = $2.tipo;}
            ;
rango       : NUMENTERO PTOPTO NUMENTERO {$$.lInf = stoi($1.lex); $$.lSup = stoi($3.lex); if($$.lSup<$$.lInf) errorSemantico(ERR_RANGO, $3);}
            ;
lident      : lident COMA ID {$3.tipo = $0.tipo; nuevoSimbolo($1, $-1);}
            | ID {$1.tipo = $0.tipo; nuevoSimbolo($1, $-1);}
            ;
seqinstr    : seqinstr PYC instr
            | instr
            ;
instr       : bloque
            | ref ASIG expr {
            if($1.tipo==REAL && $3.tipo==ENTERO) {/*ITOR*/}
                else if($1.tipo != $3.tipo) {errorSemantico(ERR_ASIG, $2);}
              }
            | PRN expr
            | READ expr
            | IF expr DOSP instr
            | IF expr DOSP instr ELSE instr
            | WHILE expr DOSP instr
            ;
expr        : esimple OPREL esimple {
                $$.tipo = ENTERO;
                if($1.tipo == CHAR) {
                  $2.tipo = CHAR;
                  if($3.tipo != CHAR) {msgErrorOperador(CHAR, $2, ERR_OPDER);}
                } else {
                  if($3.tipo == CHAR) {msgErrorOperador(NUMERICO, $2, ERR_OPDER);}
                }
                if ($1.tipo == ENTERO && $3.tipo == ENTERO) {$2.tipo = ENTERO;}
                  else {
                    $2.tipo = REAL;
                    if($1.tipo == ENTERO) {/*ITOR*/}
                    if($3.tipo == ENTERO) {/*ITOR*/}
                  }
              }
            | esimple {$$.tipo = $1.tipo;}
            ;
esimple     : esimple OPAS term {
                if ($1.tipo == CHAR) {msgErrorOperador(NUMERICO, $2, ERR_OPIZQ);}
                if ($3.tipo == CHAR) {msgErrorOperador(NUMERICO, $2, ERR_OPDER);}
                if ($1.tipo == ENTERO && $3.tipo == ENTERO) {$2.tipo = ENTERO; $$.tipo = ENTERO;}
                  else {
                    $2.tipo = REAL; $$.tipo = REAL;
                    if($1.tipo == ENTERO) {/*ITOR*/}
                    if($3.tipo == ENTERO) {/*ITOR*/}
                  }
              }
            | term {$$.tipo = $1.tipo;}
            | OPAS term {
                if ($2.tipo == CHAR) {msgErrorOperador(NUMERICO, $1, ERR_OPDER);}
                $$.tipo = $2.tipo;
              }
            ;
term        : term OPMD factor {
                if ($1.tipo == CHAR) {msgErrorOperador(NUMERICO, $2, ERR_OPIZQ);}
                if ($3.tipo == CHAR) {msgErrorOperador(NUMERICO, $2, ERR_OPDER);}
                if ($1.tipo == ENTERO && $3.tipo == ENTERO) {$2.tipo = ENTERO; $$.tipo = ENTERO;}
                  else {
                    $2.tipo = REAL; $$.tipo = REAL;
                    if($1.tipo == ENTERO) {/*ITOR*/}
                    if($3.tipo == ENTERO) {/*ITOR*/}
                  }
              }
            | factor {$$.tipo = $1.tipo;}
            ;
factor      : ref {$$.tipo = $1.tipo;}
            | NUMENTERO {$$.tipo = ENTERO;}
            | NUMREAL {$$.tipo = REAL;}
            | CTECHAR {$$.tipo = CHAR;}
            | PARI expr PARD {$$.tipo = $2.tipo;}
            | TOCHR PARI esimple PARD {$$.tipo = CHAR; if($3.tipo != ENTERO) {$1.lex="toChr"; errorSemantico(ERR_TOCHR, $1);}}
            | TOINT PARI esimple PARD {$$.tipo = ENTERO;}
            ;
ref         : ID {
                buscarSimbolo($1);
                if(tipos.tipos[$1.tipo].clase == ARRAY) {errorSemantico(ERR_FALTAN, $1);} //comprueba que no falten indices
                //guarda los datos de la referencia
                $$.tipo = $1.tipo;
                $$.dir = $1.tipo;
              }
            | ID {buscarSimbolo($1);} CORI {$$.indices = new vector<TOKEN*>(); $$.numIndices = tipos.tipos[$1.tipo].arrTams.size();} lisexpr CORD {
                unsigned max_size = tipos.tipos[$1.tipo].arrTams.size();
                if ($4.indices->size() < max_size) {errorSemantico(ERR_FALTAN, $6);} //comprueba que no sobren indices
                //libera la memoria reservada para las expresiones
                for(unsigned i=0; i<$4.indices->size(); i++) {
                  delete (*$4.indices)[i];
                }
                delete $4.indices;
                //guarda los datos de la referencia
                $$.tipo = tipos.tipos[$1.tipo].tipoOrigen;
                $$.dir = $1.tipo; //cambiar despues!
              }
            ;
lisexpr     : lisexpr COMA expr {
                $0.numIndices--;
                if($0.numIndices < 0) {errorSemantico(ERR_SOBRAN, $2);} //comprueba el numero de indices
                if($3.tipo != ENTERO) {errorSemantico(ERR_INDICE_ENTERO, $2);} //comprueba el tipo de la expresion
                $0.indices->push_back(new TOKEN($3)); //guarda la expresion del indice
              }
            | expr {
                $0.numIndices--;
                if($0.numIndices < 0) {errorSemantico(ERR_SOBRAN, $-1);} //comprueba el numero de indices
                if($1.tipo != ENTERO) {errorSemantico(ERR_INDICE_ENTERO, $-1);} //comprueba el tipo de la expresion
                $0.indices->push_back(new TOKEN($1)); //guarda la expresion del indice
              }
            ;
%%

int main(int argc, char *argv[]) {
  FILE *fent;

  if (argc==2) {
    fent = fopen(argv[1], "rt");
    if (fent) {
      yyin = fent;
      yyparse();
      fclose(fent);
    } else {
      fprintf(stderr, "No puedo abrir el fichero\n");
    }
  } else {
    fprintf(stderr, "USO: ejemplo <nombre de fichero>\n");
  }
  return 0;
}

void errorSemantico(int nerror,int fila,int columna,const char *s) {
    fprintf(stderr,"Error semantico (%d,%d): ",fila,columna);
    switch (nerror) {
        case ERR_YADECL: fprintf(stderr,"variable '%s' ya declarada\n",s);//USADO
               break;
        case ERR_NODECL: fprintf(stderr,"variable '%s' no declarada\n",s);//USADO
               break;
        case ERR_NOCABE:fprintf(stderr,"la variable '%s' ya no cabe en memoria\n",s);//USADO
               // fila,columna de ':'
               break;
        case ERR_MAXTEMP:fprintf(stderr,"no hay espacio para variables temporales\n");
               // fila,columna da igual
               break;
        case ERR_RANGO:fprintf(stderr,"el segundo valor debe ser mayor o igual que el primero.\n");//USADO
               // fila,columna del segundo número del rango
               break;
        case ERR_IFWHILE:fprintf(stderr,"la expresion del '%s' debe ser de tipo entero\n",s);
               break;

        case ERR_TOCHR:fprintf(stderr,"el argumento de '%s' debe ser entero.\n",s);//USADO
               break;

        case ERR_FALTAN: fprintf(stderr,"faltan indices\n");//USADO
               // fila,columna del id (si no hay ningún índice) o del último ']'
               break;
        case ERR_SOBRAN: fprintf(stderr,"sobran indices\n");//USADO
               // fila,columna del '[' si no es array, o de la ',' que sobra
               break;
        case ERR_INDICE_ENTERO: fprintf(stderr,"el indice de un array debe ser de tipo entero\n");//USADO
               // fila,columna del '[' si es el primero, o de la ',' inmediatamente anterior
               break;

        case ERR_ASIG: fprintf(stderr,"tipos incompatibles en la asignacion\n");//USADO
               // fila,columna del '='
               break;
        case ERR_OPIZQ: fprintf(stderr,"el operando de la izquierda de %s\n",s);//USADO
               // fila,columna del operador
               break;
        case ERR_OPDER: fprintf(stderr,"el operando de la derecha de %s\n",s);//USADO
               // fila,columna del operador
               break;
    }
    exit(-1);
}
/*-------------------------------------------------------------------------*/
// función para dar mensajes de error de operadores aritméticos y relacionales
//  tipoesp  :  tipo que se espera  (p.ej. CHAR < CHAR, NUMERICO + NUMERICO
//  op : operador (+,-,>= ...)
//  lado : ERR_OPIZQ / ERR_OPDER


void msgErrorOperador(int tipoesp, const TOKEN &t, int lado) {
  msgErrorOperador(tipoesp, t.lex.c_str(), t.linea, t.columna, lado);
}

void msgErrorOperador(int tipoesp,const char *op,int linea,int columna,int lado) {
   string tipoEsp,mensaje;

   switch (tipoesp) {
     case ENTERO: tipoEsp="entero";
       break;
     case REAL: tipoEsp="real";
       break;
     case CHAR: tipoEsp="caracter";
       break;
     case NUMERICO: tipoEsp="entero o real";
       break;
   }

   mensaje= "'" ;
   mensaje += op ;
   mensaje += "' debe ser de tipo " ;
   mensaje += tipoEsp ;
   errorSemantico(lado,linea,columna,mensaje.c_str());
}

void msgError(int nerror,int nlin,int ncol,const char *s) {
     switch (nerror) {
         case ERRLEXICO: fprintf(stderr,"Error lexico (%d,%d): caracter '%s' incorrecto\n",nlin,ncol,s);
            break;
         case ERRSINT: fprintf(stderr,"Error sintactico (%d,%d): en '%s'\n",nlin,ncol,s);
            break;
         case ERREOF: fprintf(stderr,"Error sintactico: fin de fichero inesperado\n");
            break;
         case ERRLEXEOF: fprintf(stderr,"Error lexico: fin de fichero inesperado\n");
            break;
        }
     exit(1);
}

void errorSemantico(int nerror, const TOKEN &t) {
  errorSemantico(nerror, t.linea, t.columna, t.lex.c_str());
}

int yyerror(char *s) {
    extern int findefichero;  // de plp5.l
    if (findefichero)
    {
       msgError(ERREOF,0,0,"");
    }
    else
    {
       msgError(ERRSINT,line,column-strlen(yytext),yytext);
    }
    return 0;  // no llega, msgError hace exit
}


unsigned nuevoTipoArray(unsigned linf, unsigned lsup, unsigned tbase) {
  for(int i=tipos.tipos.size()-1; 0 <= i; i--) {
    unTipo &t = tipos.tipos[i];
    if(t.clase == ARRAY && t.tipoBase == tbase
      && t.limiteInferior == linf && t.limiteSuperior == lsup) {
        return i;
    }
  }
  return tipos.nuevoTipoArray(linf, lsup, tbase);
}

/*comprueba que un tipo exista y si no, lo crea.
limites tiene que ser creado al reves!*/
unsigned comprobarTipo(const vector<tuple<unsigned, unsigned> > &limites, unsigned tbase) {
  int ultimoTipo = tbase;
  for(int i=0; i < limites.size(); i++) {
    ultimoTipo = nuevoTipoArray(get<0>(limites[i]), get<1>(limites[i]), ultimoTipo);
  }
  return ultimoTipo;
}

void nuevoSimbolo(const TOKEN &id, const TOKEN &dosp) {
  Simbolo nuevo;
  nuevo.nombre = id.lex;
  nuevo.tipo = id.tipo;
  nuevo.tam = tipos.tipos[id.tipo].tam;
  try {
    nuevo.dir = memoria.getVarDir(nuevo.tam);
  } catch (no_memory_left &e) {
    errorSemantico(ERR_NOCABE, dosp.linea, dosp.columna, id.lex.c_str());
  }
  if (!simbolos.anyadir(nuevo)) {
    errorSemantico(ERR_YADECL, id);
  }
}

void buscarSimbolo(TOKEN &id) {
  Simbolo* encontrado = simbolos.buscar(id.lex);
  if (!encontrado) {
    errorSemantico(ERR_NODECL, id);
  }
  id.tipo = encontrado->tipo;
  id.dir = encontrado->dir;
}

void mostrarTipos(void) {
  for(int i=0; i<tipos.tipos.size(); i++) {
    cout << i << "\t" << tipos.tipos[i].tam << " celdas\t" << nombreTipo(i)  << endl;
  }

  cout << endl;

  for(int i=0; i<simbolos.simbolos.size(); i++) {
    cout << i << "\t" << simbolos.simbolos[i].nombre << "\ttipo " << simbolos.simbolos[i].tipo
      << "\t" << simbolos.simbolos[i].tam << " celdas\tdireccion "
      << simbolos.simbolos[i].dir << endl;
  }
}

string nombreTipo(unsigned tipo) {
  string tString = "";
  nombreTipo(tipo, tString);
  return tString;
}
void nombreTipo(unsigned tipo, string &tipoString) {
  if (tipo == ENTERO) {
    tipoString = "int" + tipoString;
  } else if (tipo==REAL) {
    tipoString = "real" + tipoString;
  } else if (tipo==CHAR) {
    tipoString = "char" + tipoString;
  } else {
    tipoString += "["+to_string(tipos.tipos[tipo].limiteInferior)+".."+to_string(tipos.tipos[tipo].limiteSuperior)+"]";
    nombreTipo(tipos.tipos[tipo].tipoBase, tipoString);
  }
}
