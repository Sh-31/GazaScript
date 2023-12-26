// 1.y

%code requires{
extern int yylex();
extern int yyline;    
#include "SyntaxTree.h"
ASTNode *root;
FILE *yyin, *yyout, *yyError,* treeFile;; 

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

main : lines { $$ = $1; root = $$; }
     ;   
     
lines:  line '\n' lines   { $$ = Mk_interbal_Node('r', $1, $3);   }
      | line              { $$ = Mk_interbal_Node('r', $1, NULL); }              
      ; 

line: expr            { $$ = $1; }
    | assignment      { $$ = $1; }
    | print_statement { $$ = $1; }
    | if_condition    { $$ = $1; }
    | for_loop        { $$ = $1; }
    | /* empty */     { $$ = NULL;} 
    ;

if_condition: IF '(' expr ')' ':' '\n' matched END  { $$ = Mk_if_condtition_Node('F', $3, $7, NULL); }
            | IF '(' expr ')' ':' '\n' matched ELSE ':'  matched END { $$ = Mk_if_condtition_Node('F', $3, $7, $10); }
            ;

for_loop    : FOR '(' assignment ';' expr ';' assignment ')' ':' '\n' matched END { $$ = Mk_loop_Node('l', $3, $5, $7, $11); }
            ;

matched : line '\n' lines     { $$ = Mk_interbal_Node('r', $1,$3); }
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
    | expr EQUAL expr  { $$ = Mk_interbal_Node('q', $1, $3);  }
    | expr '!''=' expr { $$ = Mk_interbal_Node('N', $1, $4);  }
    | VARIABLE         { $$ = Access_Variable('v',$1);        }
    ;
%%

void yyerror(char *s){
    fprintf(yyError, "%s\r\n", s);
}

int main(void)
{
     
    yyin    = fopen("in.txt", "r");
    yyout   = fopen("out.txt", "w");
    yyError = fopen("outError.txt", "w");
    treeFile  = fopen("tree.txt", "w");
    
    yyparse();   
   
/*
    if (root != NULL) 
    printf("yes\n");
    else
    printf("NO\n");

*/
   
    // TreePrinter(root);
    execute_ast(root, sym, yyout); 
    print_tree(root, 0, "",treeFile);
    fclose(yyin);
    fclose(yyout);
    fclose(yyError);
    free_ast(root);


    return 0;
}