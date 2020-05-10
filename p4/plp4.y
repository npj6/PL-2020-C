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

  TablaSimbolos* tsa = new TablaSimbolos(NULL);

  void abrirAmbito(void);
  void cerrarAmbito(void);

  void nuevoSimbolo(TOKEN id);
  void buscarSimbolo(TOKEN &id);

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
      | ID ASIG expr {cout << 17 << " ";}
      | IF expr DOSP i ip {cout << 18 << " ";}
      | PRINT expr {cout << 21 << " ";}
      ;

ip    : ELSE i FI {cout << 19 << " ";}
      | FI {cout << 20 << " ";}
      ;

expr  : e OPREL e {cout << 22 << " ";}
      | e {cout << 23 << " ";}
      ;

e     : e OPAS t {cout << 24 << " ";}
      | t {cout << 25 << " ";}
      ;

t     : t OPMUL f {cout << 26 << " ";}
      | f {cout << 27 << " ";}
      ;

f     : NUMENTERO {cout << 28 << " ";}
      | NUMREAL {cout << 29 << " ";}
      | ID {buscarSimbolo($1);}
      | PARI expr PARD {cout << 31 << " ";}
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

const int ERRYADECL=1,ERRNODECL=2,ERRTIPOS=3,ERRNOSIMPLE=4,ERRNOENTERO=5;

static void errorSemantico(int nerror,char *lexema,int fila,int columna)
{
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
      errorSemantico(ERRYADECL, strdup(id.lex.c_str()), id.linea, id.columna);
    }
  }

  void buscarSimbolo(TOKEN &id) {
    Simbolo* encontrado = tsa->buscar(id.lex);
    if (!encontrado) {
      errorSemantico(ERRNODECL, strdup(id.lex.c_str()), id.linea, id.columna);
    }
    if (encontrado->tipo == CLASSFUN) {
      errorSemantico(ERRNOSIMPLE, strdup(id.lex.c_str()), id.linea, id.columna);
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
