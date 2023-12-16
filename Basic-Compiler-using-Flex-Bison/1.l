%{
#include "y.tab.h"
void yyerror(char *);
%}

%%
[a-z] {
    if (*yytext >= 'a' && *yytext <= 'z') {
        yylval = *yytext - 'a';
        return VARIABLE;
    } else {
        yyerror("Invalid variable");
    }
}

[0-9]+      {   /* integers */
                yylval = atoi(yytext);
                return INTEGER;
            }
[-+()*/=\n] { /* operators */ return *yytext; }
[ \t]        ; /* skip whitespace */

[Pp][Rr][Ii][Nn][Tt]    { return PRINT; }

.            yyerror("invalid character"); /* anything else is an error */
%%

int yywrap(void) {
    return 1;
}