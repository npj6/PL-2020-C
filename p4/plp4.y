%token CLASS FUN INT FLOAT
%token ID NUMENTERO NUMREAL
%token LBRA RBRA
%token PYC DOSP PARI PARD ASIG
%token OPREL OPAS OPMUL
%token IF ELSE FI PRINT

%{
  #include "comun.h"

  extern int column, line, findefichero;

  extern int yylex();
  extern char *yytext;
  extern FILE *yyin;

  int yyerror(char *s);

  void errorSemantico(int nerror,char *lexema,int fila,int columna);

%}

%%
x     : s {if (yylex()) yyerror(""); $$.trad = $1.trad;}
      ;

s     : CLASS ID LBRA m RBRA {cout << 2 << " ";}
      ;

m     : m sf {cout << 3 << " ";}
      | {cout << 4 << " ";}
      ;

sf    : s {cout << 5 << " ";}
      | fun {cout << 6 << " ";}
      ;

fun   : FUN ID a LBRA m cod RBRA {cout << 7 << " ";}
      ;

a     : a PYC dv {cout << 8 << " ";}
      | dv {cout << 9 << " ";}
      ;

dv    : tipo ID {cout << 10 << " ";}
      ;

tipo  : INT {cout << 11 << " ";}
      | FLOAT {cout << 12 << " ";}
      ;

cod   : cod PYC i {cout << 13 << " ";}
      | i {cout << 14 << " ";}
      ;

i     : dv {cout << 15 << " ";}
      | LBRA cod RBRA {cout << 16 << " ";}
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
      | ID {cout << 30 << " ";}
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

void errorSemantico(int nerror,char *lexema,int fila,int columna)
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

int main(int argc, char *argv[]) {
  yyin = fopen("test.in", "r");
  yyparse();
  fclose(yyin);
  cout << endl;
  return 0;
}
