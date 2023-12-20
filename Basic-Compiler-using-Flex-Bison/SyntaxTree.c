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
         fprintf(yyout,"%c\r",node->type);
        switch (node->type) {
        case 'r':
            return execute_ast(node->left, sym, yyout);     
        case 'i':
            return node->value;
        case '=':
            sym[node->left->variable] = execute_ast(node->right, sym, yyout);
            break;
        case 'v':  
            return sym[node->variable];    
        case '+':
            return execute_ast(node->left, sym, yyout) + execute_ast(node->right, sym, yyout);
        case '-':
            return execute_ast(node->left, sym, yyout) - execute_ast(node->right, sym, yyout);
        case 'n':
            return -execute_ast(node->left, sym, yyout);
        case '*':
            return execute_ast(node->left, sym, yyout) * execute_ast(node->right, sym, yyout);
        case '/':
            return execute_ast(node->left, sym, yyout) / execute_ast(node->right, sym, yyout);
        case '<':
            return execute_ast(node->left, sym, yyout) < execute_ast(node->right, sym, yyout);
        case '>':
            return execute_ast(node->left, sym, yyout) > execute_ast(node->right, sym, yyout);
        case 'p':
            fprintf(yyout, "%d\r", execute_ast(node->left, sym, yyout));
            return 0;
        case 'F':
            if (execute_ast(node->condition, sym,yyout))
                return execute_ast(node->left, sym, yyout);
            else
                return 0;
        case 'E':
            if (execute_ast(node->condition, sym,yyout))
                return execute_ast(node->left, sym, yyout);
            else
                return execute_ast(node->right, sym, yyout);
        default:
            return 0;
        }
    }
    return 0;
}