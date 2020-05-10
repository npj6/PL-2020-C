%token CLASS FUN INT FLOAT
%token ID NUMENTERO NUMREAL
%token LBRA RBRA
%token PYC DOSP PARI PARD ASIG
%token OPREL OPAS OPMUL
%token IF ELSE FI PRINT

%{
  #include "comun.h"
  #include "TablaSimbolos.h"

  extern int column, line, findefichero;

  extern int yylex();
  extern char *yytext;
  extern FILE *yyin;

  int yyerror(char *s);

  static void errorSemantico(int nerror,char *lexema,int fila,int columna);
  static void errorSemantico(int nerror, TOKEN token) {
    errorSemantico(nerror, strdup(token.lex.c_str()), token.linea, token.columna);
  }

  void castItor(string &expr) {
    expr = "itor("+expr+")";
  }

  TablaSimbolos* tsa = new TablaSimbolos(NULL);

  void abrirAmbito(void);
  void cerrarAmbito(void);

  void nuevoSimbolo(TOKEN id);
  void buscarSimbolo(TOKEN &id);

  void tipoExpresion(TOKEN &S1, TOKEN &S2, TOKEN &S3);

  const int ERRYADECL=1,ERRNODECL=2,ERRTIPOS=3,ERRNOSIMPLE=4,ERRNOENTERO=5;

%}

%%
x     : s {if (yylex()) yyerror(""); $$.trad = $1.trad;}
      ;

s     : CLASS ID {$2.tipo = CLASSFUN; nuevoSimbolo($2); abrirAmbito();} LBRA m RBRA {cerrarAmbito();}
      ;

m     : m sf {cout << 3 << " ";}
      | {cout << 4 << " ";}
      ;

sf    : s {cout << 5 << " ";}
      | fun {cout << 6 << " ";}
      ;

fun   : FUN ID {$2.tipo = CLASSFUN; nuevoSimbolo($2); abrirAmbito();} a LBRA m cod RBRA {cerrarAmbito();}
      ;

a     : a PYC dv {cout << 8 << " ";}
      | dv {cout << 9 << " ";}
      ;

dv    : tipo ID {$2.tipo = $1.tipo; nuevoSimbolo($2);}
      ;

tipo  : INT {$$.tipo = ENTERO;}
      | FLOAT {$$.tipo = REAL;}
      ;

cod   : cod PYC i {cout << 13 << " ";}
      | i {cout << 14 << " ";}
      ;

i     : dv {cout << 15 << " ";}
      | {abrirAmbito();} LBRA cod RBRA {cerrarAmbito();}
      | ID {buscarSimbolo($1);} ASIG expr { if ($1.tipo == ENTERO && $4.tipo == REAL) {
                                              errorSemantico(ERRTIPOS, $3);
                                            } else if ($1.tipo == REAL && $4.tipo == ENTERO) {
                                              castItor($4.trad);
                                            }
                                            $$.trad = $1.trad + " = " + $4.trad + ";";
                                          }
      | IF expr {if ($2.tipo != ENTERO) errorSemantico(ERRNOENTERO, $1);} DOSP i ip {cout << 18 << " ";}
      | PRINT expr {cout << 21 << " ";}
      ;

ip    : ELSE i FI {cout << 19 << " ";}
      | FI {$$.trad = "";}
      ;

expr  : e OPREL e  { tipoExpresion($1, $2, $3);
                    $$.tipo = ENTERO;
                    $$.trad = $1.trad + " " + $2.trad + " " + $3.trad;
                  }
      | e {$$.tipo = $1.tipo; $$.trad = $1.trad;}
      ;

e     : e OPAS t  { tipoExpresion($1, $2, $3);
                    $$.tipo = $2.tipo;
                    $$.trad = $1.trad + " " + $2.trad + " " + $3.trad;
                  }
      | t {$$.tipo = $1.tipo; $$.trad = $1.trad;}
      ;

t     : t OPMUL f { tipoExpresion($1, $2, $3);
                    $$.tipo = $2.tipo;
                    $$.trad = $1.trad + " " + $2.trad + " " + $3.trad;
                  }
      | f {$$.tipo = $1.tipo; $$.trad = $1.trad;}
      ;

f     : NUMENTERO {$$.tipo = ENTERO; $$.trad = $1.trad;}
      | NUMREAL {$$.tipo = REAL; $$.trad = $1.trad;}
      | ID {buscarSimbolo($1); $$.tipo = $1.tipo; $$.trad = $1.trad;}
      | PARI expr PARD {$$.tipo = $2.tipo; $$.trad = "("+$2.trad+")";}
      ;

%%

  int yyerror(char *s) {
      if (findefichero)
      {
         msgError(ERREOF,-1,-1,"");
      }
      else
      {
         msgError(ERRSINT,line,column-strlen(yytext),yytext);
      }
      return 0;
  }

  static void errorSemantico(int nerror,char *lexema,int fila,int columna) {
      fprintf(stderr,"Error semantico (%d,%d): en '%s', ",fila,columna,lexema);
      switch (nerror) {
        case ERRYADECL: fprintf(stderr,"ya existe en este ambito\n");
           break;
        case ERRNODECL: fprintf(stderr,"no ha sido declarado\n");
           break;
        case ERRTIPOS: fprintf(stderr,"tipos incompatibles entero/real\n");
           break;
        case ERRNOSIMPLE: fprintf(stderr,"debe ser de tipo entero o real\n");
           break;
        case ERRNOENTERO: fprintf(stderr,"debe ser de tipo entero\n");
           break;
      }
      exit(-1);
  }

  void tipoExpresion(TOKEN &S1, TOKEN &S2, TOKEN &S3) {
    if(S1.tipo == ENTERO && S3.tipo == ENTERO) {
     S2.tipo = ENTERO; S2.trad += "i";
    } else {
     S2.tipo = REAL; S2.trad += "r";
     if (S1.tipo == ENTERO) {
       castItor(S1.trad);
     } else if (S3.tipo == ENTERO) {
       castItor(S3.trad);
     }
    }
  }

  void abrirAmbito(void) {
    tsa = new TablaSimbolos(tsa);
  }
  void cerrarAmbito(void) {
    TablaSimbolos* antigua = tsa;
    tsa = tsa->padre;
    delete antigua;
  }

  void nuevoSimbolo(TOKEN id) {
    Simbolo nuevo;
    nuevo.nombre = id.lex;
    nuevo.tipo = id.tipo;
    nuevo.nomtrad = id.trad;
    if (!tsa->anyadir(nuevo)) {
      errorSemantico(ERRYADECL, id);
    }
  }

  void buscarSimbolo(TOKEN &id) {
    Simbolo* encontrado = tsa->buscar(id.lex);
    if (!encontrado) {
      errorSemantico(ERRNODECL, id);
    }
    if (encontrado->tipo == CLASSFUN) {
      errorSemantico(ERRNOSIMPLE, id);
    }
    id.tipo = encontrado->tipo;
    id.trad = encontrado->nomtrad;
  }

int main(int argc, char *argv[]) {
  yyin = fopen("test.in", "r");
  yyparse();
  fclose(yyin);
  cout << endl;
  return 0;
}
