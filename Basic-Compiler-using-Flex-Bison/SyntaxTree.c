// SyntaxTree.c
#include "SyntaxTree.h"
#include <stdlib.h>
#include <stdio.h>

ASTNode *create_leaf_node(char type, int value)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type; 
    node->value = value;
    node->left = NULL;
    node->right = NULL;
    return node;
}
ASTNode *create_op_node(char type,  ASTNode *left){
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type; 
    node->left = left;
    return node;
}
ASTNode *create_internal_node(char type, ASTNode *left, ASTNode *right)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type; 
    node->left = left;
    node->right = right;
    return node;
}

ASTNode *create_if_condition_node(char type, ASTNode *condition, ASTNode *left, ASTNode *right)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type; 
    node->condition = condition;
    node->left = left;
    node->right = right;
    return node;
}
ASTNode * AccessVariable(char type,ASTNode *node){
    return node;
}
void free_ast(ASTNode *node)
{
    if (node)
    {
        free_ast(node->left);
        free_ast(node->right);
        free(node);
    }
}
int execute_ast(ASTNode *node, int sym[], FILE *yyout) {
   
    if (node) {
        //  printf("%c\n", node->type);

        if (node->type == 'r') {
            execute_ast(node->left, sym, yyout);
            execute_ast(node->right, sym, yyout);
        }
        if (node->type > '0'&& node->type < '9') {
            execute_ast(node->left, sym, yyout);
        }
        else if (node->type == 'i') {
            return node->value;
        }
        else if (node->type == '=') {
            sym[node->left->variable] = execute_ast(node->right, sym, yyout);
        }
        else if (node->type == 'v') {
            return sym[node->variable];
        }
        else if (node->type == '+') {
            return execute_ast(node->left, sym, yyout) + execute_ast(node->right, sym, yyout);
        }
        else if (node->type == '-') {
            return execute_ast(node->left, sym, yyout) - execute_ast(node->right, sym, yyout);
        }
        else if (node->type == 'n') {
            return -execute_ast(node->left, sym, yyout);
        }
        else if (node->type == '*') {
            return execute_ast(node->left, sym, yyout) * execute_ast(node->right, sym, yyout);
        }
        else if (node->type == '/') {
            return execute_ast(node->left, sym, yyout) / execute_ast(node->right, sym, yyout);
        }
        else if (node->type == '<') {
            return execute_ast(node->left, sym, yyout) < execute_ast(node->right, sym, yyout);
        }
        else if (node->type == '>') {
            return execute_ast(node->left, sym, yyout) > execute_ast(node->right, sym, yyout);
        }
        else if (node->type == 'p') {
             fprintf(yyout, "%d\r", execute_ast(node->left, sym, yyout));
             printf("%d\n", execute_ast(node->left, sym, yyout));
            return 1;
        }
        else if (node->type == 'F') {
            if (execute_ast(node->condition, sym, yyout))
                { printf("yes\n");return execute_ast(node->left, sym, yyout);}
            else
                {printf("no\n");return execute_ast(node->right, sym, yyout);
}        }
    }

    return 0;
}
