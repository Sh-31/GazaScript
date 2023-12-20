// 1.y

%code requires{
extern int yylex();
extern int yyline;    
extern void yyerror(char *s);  
#include "SyntaxTree.h"
ASTNode *root;
FILE *yyin, *yyout, *yyError; 
}

%union {
    ASTNode *node;
    int value;
}

%token <value> INTEGER
%token <node> VARIABLE
%token PRINT IF ELSE END
%left '+' '-'
%left '*' '/'
%left UMINUS

%start main
%type <node>  main lines line if_condition assignment print_statement expr

%%

main : lines
     |
     ;   
     
lines: lines line '\n'  {$$ = create_internal_node('r', $2,NULL); root=$$;}
      | /* empty */ {}
      ;

line: expr  {$$ = create_internal_node('r', $1,NULL);}
    | assignment {$$ = create_internal_node('r', $1,NULL);}
    | print_statement {$$ = create_internal_node('r', $1,NULL);}
    | if_condition {$$ = create_internal_node('r', $1,NULL);}
    ;


if_condition: IF '(' expr ')' ':' '\n' lines END  { $$ = create_if_condition_node('F', $3, $7, NULL); }
            | IF '(' expr ')' ':' '\n' lines ELSE ':' lines END { $$ = create_if_condition_node('E', $3, $7, $10); }
            | /* empty */ {}
            ;

assignment: VARIABLE '=' expr {  $$ = create_internal_node('=', $1, $3); }
           | /* empty */ {}
           ;

print_statement: PRINT '(' expr ')'                  { $$ = create_internal_node('p', $3, NULL); }
               | PRINT '(' VARIABLE ')'              { $$ = create_internal_node('p', AccessVariable('v', $3), NULL); }
               | PRINT '(' VARIABLE '+' expr ')'     { $$ = create_internal_node('p', create_internal_node('+', AccessVariable('v', $3), $5), NULL); }
               | PRINT '(' VARIABLE '-' expr ')'     { $$ = create_internal_node('p', create_internal_node('-', AccessVariable('v', $3), $5), NULL); }
               | PRINT '(' VARIABLE '*' expr ')'     { $$ = create_internal_node('p', create_internal_node('*', AccessVariable('v', $3), $5), NULL); }
               | PRINT '(' VARIABLE '+' VARIABLE ')' { $$ = create_internal_node('p', create_internal_node('+', AccessVariable('v', $3), AccessVariable('v', $5)), NULL); }
               | PRINT '(' VARIABLE '-' VARIABLE ')' { $$ = create_internal_node('p', create_internal_node('-', AccessVariable('v', $3), AccessVariable('v', $5)), NULL); }
               | PRINT '(' VARIABLE '*' VARIABLE ')' { $$ = create_internal_node('p', create_internal_node('*', AccessVariable('v', $3), AccessVariable('v', $5)), NULL); }
               | PRINT '(' VARIABLE '/' VARIABLE ')' { $$ = create_internal_node('p', create_internal_node('/', AccessVariable('v', $3), AccessVariable('v', $5)), NULL); }
               | PRINT '(' VARIABLE '/' expr ')'     { $$ = create_internal_node('p', create_internal_node('/', AccessVariable('v', $3), $5), NULL); }
               | /* empty */ {}
               ;

expr: INTEGER { $$ = create_leaf_node('i', $1); }
    | '-' expr %prec UMINUS { $$ = create_internal_node('n', $2, NULL); }
    | expr '*' expr { $$ = create_internal_node('*', $1, $3); printf("%c", $$->type); }
    | expr '/' expr { $$ = create_internal_node('/', $1, $3); printf("%c", $$->type); }
    | expr '+' expr { $$ = create_internal_node('+', $1, $3); printf("%c", $$->type); }
    | expr '-' expr { $$ = create_internal_node('-', $1, $3); printf("%c", $$->type); }
    | expr '>' expr { $$ = create_internal_node('>', $1, $3); }
    | expr '<' expr { $$ = create_internal_node('<', $1, $3); }
    | '(' expr ')'  { $$ = $2; }
    | /* empty */ {}
    ;
%%


void yyerror(char *s)
{
    fprintf(yyError, "%s\r\n", s);
}

int main(void)
{
     
    yyin = fopen("in.txt", "r");
    yyout = fopen("out.txt", "w");
    yyError = fopen("outError.txt", "w");

    yyparse();

    
    int sym[26] = {0};
    /*root = create_internal_node('p', create_internal_node('+', create_leaf_node('i', 2),create_leaf_node('i', 10) ), NULL);*/

    if (root != NULL) printf("yes");
    else printf("NO");
    execute_ast(root, sym, yyout);
    free_ast(root);
    

    fclose(yyin);
    fclose(yyout);
    fclose(yyError);

    return 0;
}