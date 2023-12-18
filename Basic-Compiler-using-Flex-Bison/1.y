%token INTEGER VARIABLE PRINT IF ELSE END
%right  '=' UMINUS
%left '+' '-' 
%left '*' '/'



%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(char *);
extern FILE * yyin;
extern FILE * yyout;
FILE * yyError;
int sym[26];
%}


%%

main: lines
    ;

lines:
    | lines line '\n'
    ;

line: expr
    | assignment
    | print_statement
    | if_condition
    ;

if_condition: IF '(' condition ')' ':' '\n' lines END   {
                                                            if($3) {
                                                                // Execute the lines inside if
                                                                $$ = $7;
                                                            } else {
                                                                
                                                            }
                                                        }
            | IF '(' condition ')' ':' '\n' lines ELSE lines END    {
                                                                        if ($3) {
                                                                            fprintf(yyout, "True");
                                                                        } else {
                                                                            fprintf(yyout, "False");
                                                                        }
                                                                    }
            ;

condition: expr '>' expr {$$ = $1 > $3;}
        | expr '<' expr  {$$ = $1 < $3;}
        ;

assignment: VARIABLE '=' expr {
    sym[$1] = $3;
    $$ = sym[$1];
}
|
;

print_statement: PRINT '(' expr ')' {  fprintf(yyout, "%d\r", $3);}
| PRINT '(' VARIABLE ')'            {  fprintf(yyout, "%d\r", sym[$3]);}
| PRINT '(' VARIABLE '+' expr ')'   {  fprintf(yyout, "%d\r", sym[$3] + $5);}
| PRINT '(' VARIABLE '-' expr ')'   {  fprintf(yyout, "%d\r", sym[$3] - $5);}
| PRINT '(' VARIABLE '*' expr ')'   {  fprintf(yyout, "%d\r", sym[$3] * $5);}
| PRINT '(' VARIABLE '+' VARIABLE ')'{ fprintf(yyout, "%d\r", sym[$3] + sym[$5]);}
| PRINT '(' VARIABLE '-' VARIABLE ')'{ fprintf(yyout, "%d\r", sym[$3] - sym[$5]);}
| PRINT '(' VARIABLE '*' VARIABLE ')'{ fprintf(yyout, "%d\r", sym[$3] * sym[$5]);}
| PRINT '(' VARIABLE '/' VARIABLE ')'{  
                                            if(sym[$5]==0){
                                                yyerror("Error: Cannot divide by zero\n");
                                                exit(EXIT_FAILURE);
                                            }
                                              else{ 
                                                fprintf(yyout, "%d\r", sym[$3] / sym[$5]); 
                                                }
}
| PRINT '(' VARIABLE '/' expr ')'  {  
                                            if ($5 == 0){
                                                yyerror("Error: Cannot divide by zero\n");
                                                exit(EXIT_FAILURE);
                                            }
                                                else{  
                                                    fprintf(yyout, "%d\r", sym[$3] / $5);  
                                                }
}
;

expr: INTEGER { $$ = $1;  }
    | '-' expr %prec UMINUS { $$ = - $2; }
    | expr '*' expr { $$ = $1 * $3; }
    | expr '/' expr { if ($3 == 0) {
							yyerror("Error: Cannot divide by zero\n");
							exit(EXIT_FAILURE);
						} else {
							$$ = $1 / $3;
						} 
                    }
    | expr '+' expr { $$ = $1 + $3; }
    | expr '-' expr { $$ = $1 - $3; }
    | '(' expr ')' { $$ = $2; }
    ;

%%

void yyerror(char *s) {
fprintf(yyError, "%s\r\n", s);
}


int main(void) {
yyin = fopen( "in.txt", "r" );
yyout = fopen( "out.txt", "w" );
yyError = fopen( "outError.txt", "w" );

yyparse();

fclose(yyin);
fclose(yyout);
return 0;
}