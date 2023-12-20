// SyntaxTree.h
#ifndef SYNTAX_TREE_H
#define SYNTAX_TREE_H

#include <stdio.h>
typedef struct ASTNode
{
    char type; 
    int value;
    char variable;
    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *condition; 
} ASTNode;

ASTNode *create_leaf_node(char type, int value);
ASTNode *create_internal_node(char type, ASTNode *left, ASTNode *right);
ASTNode *create_if_condition_node(char type, ASTNode *condition, ASTNode *left, ASTNode *right);
ASTNode * AccessVariable(char type,ASTNode *node);
void free_ast(ASTNode *node);
int execute_ast(ASTNode *node, int sym[], FILE *yyout);

#endif
