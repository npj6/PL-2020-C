%{

extern int yylex();

int yyerror(char *s);

%}

%%
x : ;
%%

int yyerror(char *s) {}

int main(int argc, char *argv[]) {
}
