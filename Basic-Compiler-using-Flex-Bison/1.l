
%{
#include "1.tab.h"
#include <string.h>
%}

%%

[a-z]                      {
                            if (*yytext >= 'a' && *yytext <= 'z') {
                                yylval.value = *yytext - 'a';
                                return VARIABLE;
                            } else {
                                yyerror("Invalid variable");
                            }
                           }
[0-9]+                     {
                            yylval.value = atoi(yytext); 
                            return INTEGER; 
                           }   
[=][=]                     { return  EQUAL;  }             
[-+()*/<>:\n;=]            { return *yytext; }
[ \t]        ; /* skip whitespace */
[Pp][Rr][Ii][Nn][Tt]       { return PRINT; }
[Ii][Ff]                   { return IF;}
[Ee][Ll][Ss][Ee]           { return ELSE;}
[Ee][Nn][Dd]               { return END;}
[Ff][Oo][Rr]               { return FOR;}
\"[a-zA-Z0-9[:space:]:]+\" { yylval.strvalue = strdup(yytext); return STRING; }
.                          { yyerror("invalid character"); /* anything else is an error */ }

%%

int yywrap(void) {
    return 1;
}
