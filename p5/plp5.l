d [0-9]
l [a-zA-Z]
alfnum [a-zA-Z0-9]

%{
  #include "comun.h"
  #include "plp5.tab.h"

  int column = 1;
  int line = 1;

  int findefichero = 0;

  void crearToken(string lex);
  void crearToken(char *lex) {string l; if(!lex) l = ""; else l = lex; crearToken(l);}
%}

%x COMENTARIO

%%
"//".* {column += strlen(yytext);}
"(*" {BEGIN(COMENTARIO); column += 2;}
<COMENTARIO>"*)" {BEGIN(INITIAL); column += 2;}
<COMENTARIO><<EOF>> {msgError(ERRLEXEOF, -1, -1, "");}
<COMENTARIO>\n {column = 1; line++;}
<COMENTARIO>[^*)\n]+ {column += strlen(yytext);}
<COMENTARIO>[*)] {column++;}

prg {crearToken(nullptr); column += 3; return PRG;}
var {crearToken(nullptr); column += 3; return VAR;}
int {crearToken(nullptr); column += 3; return INTT;}
real {crearToken(nullptr); column += 4; return REALT;}
char {crearToken(nullptr); column += 4; return CHART;}
println {crearToken(nullptr); column += 7; return PRN;}
print {crearToken(nullptr); column += 5; return PRN;}
read {crearToken(nullptr); column += 4; return READ;}
if {crearToken(nullptr); column += 2; return IF;}
else {crearToken(nullptr); column += 4; return ELSE;}
while {crearToken(nullptr); column += 5; return WHILE;}
toChr {crearToken(nullptr); column += 5; return TOCHR;}
toInt {crearToken(nullptr); column += 5; return TOINT;}
{l}{alfnum}* {crearToken(yytext); column += strlen(yytext); return ID;}
{d}+ {crearToken(yytext); column += strlen(yytext); return NUMENTERO;}
{d}+\.{d}+ {crearToken(yytext); column += strlen(yytext); return NUMREAL;}
\'[\040-\377]\' {crearToken(to_string(yytext[1])); column += 3; return CTECHAR;}
\'\\[n0\\]\' {
  string lex;
  switch(yytext[2]) {
    case 'n': lex = "10"; break;
    case '0': lex = "0"; break;
    case '\\': lex = "92"; break;
  }
  crearToken(lex);
  column += 4;
  return CTECHAR;
}
, {crearToken(nullptr); column++; return COMA;}
; {crearToken(nullptr); column++; return PYC;}
: {crearToken(nullptr); column++; return DOSP;}
\( {crearToken(nullptr); column++; return PARI;}
\) {crearToken(nullptr); column++; return PARD;}
\{ {crearToken(nullptr); column++; return LBRA;}
\} {crearToken(nullptr); column++; return RBRA;}
[<>=!]= {crearToken(yytext); column += 2; return OPREL;}
[<>] {crearToken(yytext); column++; return OPREL;}
[+-] {crearToken(yytext); column++; return OPAS;}
[*/] {crearToken(yytext); column++; return OPMD;}
= {crearToken(nullptr); column++; return ASIG;}
\[ {crearToken(nullptr); column++; return CORI;}
\] {crearToken(nullptr); column++; return CORD;}
\.\. {crearToken(nullptr); column += 2; return PTOPTO;}

[\t ]+ {column += strlen(yytext);}
\n {column = 1; line++;}

. {msgError(ERRLEXICO, line, column, yytext);}

%%

int yywrap(void) {findefichero=1; return 1;}

void crearToken(string lex) {
  yylval.lex = lex;
  yylval.linea = line;
  yylval.columna = column;

  yylval.limites = nullptr;

  yylval.indices = nullptr;
}
