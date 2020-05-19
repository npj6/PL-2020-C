%token TEST

%{
  #include "comun.h"

  int TEST_NUM = 0;

  extern int column, line, findefichero;

  extern int yylex();
  extern FILE *yyin;

  int yyerror(char *s) {return 0;}

%}

%%

x : TEST {TEST_NUM++;} x
  | {cout << "numero de TEST: " << TEST_NUM << endl;}
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
