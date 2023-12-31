// SyntaxTree.h

#ifndef SYNTAX_TREE_H
#define SYNTAX_TREE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

extern void yyerror(char *s);

typedef struct ASTNode
{
    char type;
    int value;
    int variable;
    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *condition;
    struct ASTNode *lines;
    char *variableASCII;
} ASTNode;

int sym[26];

ASTNode *Mk_leaf_node(char type, int value);
ASTNode *Mk_interbal_Node(char type, ASTNode *left, ASTNode *right);
ASTNode *Mk_if_condtition_Node(char type, ASTNode *condition, ASTNode *left, ASTNode *right);
ASTNode *Mk_op_Node(char type, ASTNode *left);
ASTNode *Access_Variable(char type, int variableASCII);
ASTNode *Mk_loop_Node(char type, ASTNode *left, ASTNode *condition, ASTNode *right, ASTNode *lines);
ASTNode *Assign_Node(char type, int variableASCII, ASTNode *left);
ASTNode *Print_Node(char type, char *variableASCII);
void free_ast(ASTNode *node);
int execute_ast(ASTNode *node, int sym[], FILE *yyout);
void print_tree(struct ASTNode* root, int isLeft, char* prefix, FILE *yyout);

#endif
