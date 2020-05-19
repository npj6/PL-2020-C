d [0-9]
l [a-zA-Z]
alfnum [a-zA-Z0-9]

%{
  #include "comun.h"
  #include "plp5.tab.h"

  int column = 1;
  int line = 1;

  int findefichero = 0;

%}

%%

test {return TEST;}

.
\n

%%

int yywrap(void) {findefichero=1; return 1;}
