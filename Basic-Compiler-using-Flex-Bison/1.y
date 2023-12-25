// 1.y

%code requires{
extern int yylex();
extern int yyline;    
extern void yyerror(char *s);  
#include "SyntaxTree.h"
ASTNode *root;
FILE *yyin, *yyout, *yyError; 
}

%union{
    ASTNode *node;
    int value;
    char * strvalue;
}

%token <value> INTEGER VARIABLE
%token <strvalue> STRING
%token <node> PRINT IF ELSE END FOR
%nonassoc '>=' '<=' '==' '!='
%left '+' '-'
%left '*' '/'
%left UMINUS
%start main
%type <node> main lines line if_condition assignment print_statement expr matched for_loop


%%

main : lines 
     ;   
     
lines:  line '\n' lines   { $$ = create_internal_node('r', $1, $3);   root=$$; }
      | line              { $$ = create_internal_node('r', $1, NULL); root=$$; }  
      ; 

line: expr            { $$ = create_op_node('1', $1); }
    | assignment      { $$ = create_op_node('2', $1); }
    | print_statement { $$ = create_op_node('3', $1); }
    | if_condition    { $$ = create_op_node('4', $1); }
    | for_loop        { $$ = create_op_node('5', $1); }
    | /* empty */ {}
    ;

if_condition: IF '(' expr ')' ':' '\n' matched END  { $$ = create_if_condition_node('F', $3, $7, NULL); }
            | IF '(' expr ')' ':' '\n' matched ELSE ':'  matched END { $$ = create_if_condition_node('F', $3, $7, $10); }
            ;

for_loop    : FOR '(' assignment ';' expr ';' assignment ')' ':' '\n' matched END { $$ = loopNode('l', $3, $5, $7, $11); }
            ;

matched :  line '\n' lines    { $$ = create_internal_node('r', $1,$3); }
        ;      

assignment: VARIABLE '=' expr { $$ = AssignNode('=', $1, $3); }
           ;

print_statement: PRINT '(' expr ')'    { $$ = create_internal_node('p', $3, NULL); }
               | PRINT '(' STRING ')'  { $$ = PrintNode('S', $3); }
               ;

expr: INTEGER               { $$ = create_leaf_node('i', $1); }
    | '-' expr %prec UMINUS { $$ = create_internal_node('n', $2, NULL); }
    | expr '*'  expr   { $$ = create_internal_node('*', $1, $3);  }
    | expr '/'  expr   { $$ = create_internal_node('/', $1, $3);  }
    | expr '+'  expr   { $$ = create_internal_node('+', $1, $3);  }
    | expr '-'  expr   { $$ = create_internal_node('-', $1, $3);  }
    | expr '>'  expr   { $$ = create_internal_node('>', $1, $3);  }
    | expr '<'  expr   { $$ = create_internal_node('<', $1, $3);  }
    | expr '<''=' expr { $$ = create_internal_node('g', $1, $4);  }
    | expr '>''=' expr { $$ = create_internal_node('s', $1, $4);  }
    | expr '=''=' expr { $$ = create_internal_node('q', $1, $4);  }
    | expr '!''=' expr { $$ = create_internal_node('N', $1, $4);  }
    | VARIABLE         { $$ = AccessVariable('v',$1)}
    ;
%%

void yyerror(char *s){
    fprintf(yyError, "%s\r\n", s);
}

int main(void)
{
     
    yyin = fopen("in.txt", "r");
    yyout = fopen("out.txt", "w");
    yyError = fopen("outError.txt", "w");

    yyparse();   
    int sym[26] = {0};

    if (root != NULL) 
    printf("yes\n");
    else
    printf("NO\n");

    execute_ast(root, sym, yyout);

    fclose(yyin);
    fclose(yyout);
    fclose(yyError);
    // free_ast(root);


    return 0;
}