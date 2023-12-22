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
%token <value> INTEGER VARIABLE
%token PRINT IF ELSE END
%nonassoc '>=' '<=' '==' '!='
%left '+' '-'
%left '*' '/'
%left UMINUS

%start main
%type <node>  main lines line if_condition assignment print_statement expr matched 

%%

main : lines
     |
     ;   
     
lines: line '\n' lines    {$$ = create_internal_node('r', $1,$3);   root=$$;}
      | lines  line '\n'  {$$ = create_internal_node('r', $2,NULL); root=$$;} 
      |  /* empty */ {}
      ;

line: expr  {$$ = create_op_node('1', $1);}
    | assignment {$$ = create_op_node('2', $1);}
    | print_statement {$$ = create_op_node('3', $1);}
    | if_condition {$$ = create_op_node('4', $1);}
    | /* empty */ {}
    ;


if_condition: IF '(' expr ')' ':' '\n' matched END  { $$ = create_if_condition_node('F', $3, $7, NULL); }
            | IF '(' expr ')' ':' '\n' matched ELSE ':'  matched END { $$ = create_if_condition_node('F', $3, $7, $10); }
            | IF '(' VARIABLE ')' ':' '\n' matched END  { $$ = create_if_condition_node('F', AccessVariable('v', $3), $7, NULL); }
            | IF '(' VARIABLE ')' ':' '\n' matched ELSE ':'  matched END { $$ = create_if_condition_node('F',  AccessVariable('v', $3), $7, $10); }
            | /* empty */ {}
            ;

matched :  line '\n' lines  {$$ = create_internal_node('r', $1,$3);}
        |  lines line '\n'  {$$ = create_internal_node('r', $2,NULL);}
        |  /* empty */ {}
        ;      

assignment: VARIABLE '=' expr {  $$ = AssignNode('=', $1, $3); }
           | /* empty */ {}
           ;

print_statement: PRINT '(' expr ')'  { $$ = create_internal_node('p', $3, NULL); }
               | /* empty */ {}
               ;

expr: INTEGER { $$ = create_leaf_node('i', $1); }
    | '-' expr %prec UMINUS { $$ = create_internal_node('n', $2, NULL); }
    | expr '*'  expr { $$ = create_internal_node('*', $1, $3);  }
    | expr '/'  expr { $$ = create_internal_node('/', $1, $3);  }
    | expr '+'  expr { $$ = create_internal_node('+', $1, $3);  }
    | expr '-'  expr { $$ = create_internal_node('-', $1, $3);  }
    | expr '>'  expr { $$ = create_internal_node('>', $1, $3);  }
    | expr '<'  expr { $$ = create_internal_node('<', $1, $3);  }
    | expr '<''=' expr { $$ = create_internal_node('g', $1, $4);  }
    | expr '>''=' expr { $$ = create_internal_node('s', $1, $4);  }
    | expr '=''=' expr { $$ = create_internal_node('q', $1, $4);  }
    | expr '!''=' expr { $$ = create_internal_node('N', $1, $4);  }
    | VARIABLE {$$ = AccessVariable('v',$1)}
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