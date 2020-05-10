d [0-9]
l [a-zA-Z]
alfnum [a-zA-Z0-9]

%{
  #include "comun.h"
  #include "plp4.tab.h"

  int column = 1;
  int line = 1;

  int findefichero = 0;

  void crearToken(void);
%}

%x COMENTARIO

%%
"//".* {column += strlen(yytext);}
"/*" {BEGIN(COMENTARIO); column += 2;}
<COMENTARIO>"*/" {BEGIN(INITIAL); column += 2;}
<COMENTARIO><<EOF>> {msgError(ERRLEXEOF, -1, -1, "");}
<COMENTARIO>\n {column = 1; line++;}
<COMENTARIO>[^/*\n]+ {column += strlen(yytext);}
<COMENTARIO>[*/]+ {column += strlen(yytext);}
class {crearToken(); column += 5; return CLASS;}
fun {crearToken(); column += 3; return FUN;}
int {crearToken(); column += 3; return INT;}
float {crearToken(); column += 5; return FLOAT;}
if {crearToken(); column += 2; return IF;}
else {crearToken(); column += 4; return ELSE;}
fi {crearToken(); column += 2; return FI;}
print {crearToken(); column += 5; return PRINT;}
\{ {crearToken(); column++; return LBRA;}
\} {crearToken(); column++; return RBRA;}
; {crearToken(); column++; return PYC;}
: {crearToken(); column++; return DOSP;}
\( {crearToken(); column++; return PARI;}
\) {crearToken(); column++; return PARD;}
= {crearToken(); column++; return ASIG;}
[<>=!]=|[<>] {crearToken(); column += strlen(yytext); return OPREL;}
[+-] {crearToken(); column++; return OPAS;}
[*/] {crearToken(); column++; return OPMUL;}
{l}{alfnum}* {crearToken(); column += strlen(yytext); return ID;}
{d}+ {crearToken(); column += strlen(yytext); return NUMENTERO;}
{d}+\.{d}+ {crearToken(); column += strlen(yytext); return NUMREAL;}
[ \t]+ {column += strlen(yytext);}
\n {column = 1; line++;};
. {msgError(ERRLEXICO, line, column, yytext);}
%%

int yywrap(void) {findefichero=1; return 1;}

void crearToken (void) {
  yylval.lex = yytext;
  yylval.linea = line;
  yylval.columna = column;
  yylval.trad = yytext;
  yylval.tipo = -1;
  yylval.prefix = "";
  yylval.indent = "";
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
