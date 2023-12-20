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

[0-9]+      {
                yylval = atoi(yytext);
                return INTEGER;
            }
[-+()*/=<>:\n] { return *yytext; }
[ \t]        ; /* skip whitespace */

[Pp][Rr][Ii][Nn][Tt]    { return PRINT; }
[Ii][Ff]                { return IF;}
[Ee][Ll][Ss][Ee]        { return ELSE;}
[Ee][Nn][Dd]            { return END;}

.            { yyerror("invalid character"); /* anything else is an error */ }

%%

int yywrap(void) {
    return 1;
}
