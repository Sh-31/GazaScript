// 1.y

%code requires{
extern int yylex();
extern int yyline;    
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
%token <strvalue> STRING ASSIGN
%token <node> PRINT IF ELSE END FOR
%nonassoc '>' '<' EQUAL '!'
%right '='
%left '+' '-'
%left '*' '/'
%left UMINUS
%start main
%type <node> main lines line if_condition assignment print_statement expr matched for_loop


%%

main : lines 
     ;   
     
lines:  line '\n' lines   { $$ = Mk_interbal_Node('r', $1, $3);   root=$$; }
      | line              { $$ = Mk_interbal_Node('r', $1, NULL); root=$$; }  
      ; 

line: expr            { $$ = Mk_op_Node('1', $1); }
    | assignment      { $$ = Mk_op_Node('2', $1); }
    | print_statement { $$ = Mk_op_Node('3', $1); }
    | if_condition    { $$ = Mk_op_Node('4', $1); }
    | for_loop        { $$ = Mk_op_Node('5', $1); }
    | /* empty */ {}
    ;

if_condition: IF '(' expr ')' ':' '\n' matched END  { $$ = Mk_if_condtition_Node('F', $3, $7, NULL); }
            | IF '(' expr ')' ':' '\n' matched ELSE ':'  matched END { $$ = Mk_if_condtition_Node('F', $3, $7, $10); }
            ;

for_loop    : FOR '(' assignment ';' expr ';' assignment ')' ':' '\n' matched END { $$ = Mk_loop_Node('l', $3, $5, $7, $11); }
            ;

matched : line '\n' lines    { $$ = Mk_interbal_Node('r', $1,$3); }
        ;      

assignment: VARIABLE '=' expr { $$ = Assign_Node('=', $1, $3); }
          ;

print_statement: PRINT '(' expr ')'    { $$ = Mk_interbal_Node('p', $3, NULL); }
               | PRINT '(' STRING ')'  { $$ = Print_Node('S', $3); }
               ;

expr: INTEGER               { $$ = Mk_leaf_node('i', $1); }
    | '-' expr %prec UMINUS { $$ = Mk_interbal_Node('n', $2, NULL); }
    | expr '*'  expr   { $$ = Mk_interbal_Node('*', $1, $3);  }
    | expr '/'  expr   { $$ = Mk_interbal_Node('/', $1, $3);  }
    | expr '+'  expr   { $$ = Mk_interbal_Node('+', $1, $3);  }
    | expr '-'  expr   { $$ = Mk_interbal_Node('-', $1, $3);  }
    | expr '>'  expr   { $$ = Mk_interbal_Node('>', $1, $3);  }
    | expr '<'  expr   { $$ = Mk_interbal_Node('<', $1, $3);  }
    | expr '<''=' expr { $$ = Mk_interbal_Node('g', $1, $4);  }
    | expr '>''=' expr { $$ = Mk_interbal_Node('s', $1, $4);  }
    | expr EQUAL expr { $$ = Mk_interbal_Node('q', $1, $3);  }
    | expr '!''=' expr { $$ = Mk_interbal_Node('N', $1, $4);  }
    | VARIABLE         { $$ = Access_Variable('v',$1);        }
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
/*
    if (root != NULL) 
    printf("yes\n");
    else
    printf("NO\n");

*/
    execute_ast(root, sym, yyout);
    // TreePrinter(root);

    fclose(yyin);
    fclose(yyout);
    fclose(yyError);
    // free_ast(root);


    return 0;
}