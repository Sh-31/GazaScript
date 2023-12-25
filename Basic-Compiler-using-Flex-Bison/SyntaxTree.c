// SyntaxTree.c
#include "SyntaxTree.h"
#include <stdlib.h>
#include <stdio.h>

ASTNode *Mk_leaf_node(char type, int value)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->value = value;
    return node;
}
ASTNode *Mk_op_Node(char type, ASTNode *left)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->left = left;
    return node;
}
ASTNode *Mk_interbal_Node(char type, ASTNode *left, ASTNode *right)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->left = left;
    node->right = right;
    return node;
}
ASTNode *Mk_if_condtition_Node(char type, ASTNode *condition, ASTNode *left, ASTNode *right)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->condition = condition;
    node->left = left;
    node->right = right;
    return node;
}
ASTNode *Assign_Node(char type, int variableASCII, ASTNode *left)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->variable = variableASCII;
    node->left = left;
    return node;
}
ASTNode *Access_Variable(char type, int variableASCII)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->variable = variableASCII;
    return node;
}
ASTNode *Mk_loop_Node(char type, ASTNode *left, ASTNode *condition, ASTNode *right, ASTNode *lines)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->left = left;
    node->right = right;
    node->condition = condition;
    node->lines = lines;
    return node;
}
ASTNode *Print_Node(char type, char *variableASCII)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->variableASCII = variableASCII;
    return node;
}
void free_ast(struct ASTNode *root)
{
    if (root == NULL)
        return;
    free_ast(root->left);
    free_ast(root->right);
    free_ast(root->lines);
    free_ast(root->condition);
    free(root);
}

int execute_ast(ASTNode *node, int sym[], FILE *yyout)
{
    if (node)
    {
        //  printf("%c\n", node->type);

        if (node->type == 'r')
        {
            execute_ast(node->left, sym, yyout);
            execute_ast(node->right, sym, yyout);
        }
        if (node->type > '0' && node->type < '9')
        {
            execute_ast(node->left, sym, yyout);
        }
        else if (node->type == 'i')
        {
            return node->value;
        }
        else if (node->type == '=')
        {
            sym[node->variable] = execute_ast(node->left, sym, yyout);
        }
        else if (node->type == 'v')
        {
            return sym[node->variable];
        }
        else if (node->type == '+')
        {
            return execute_ast(node->left, sym, yyout) + execute_ast(node->right, sym, yyout);
        }
        else if (node->type == '-')
        {
            return execute_ast(node->left, sym, yyout) - execute_ast(node->right, sym, yyout);
        }
        else if (node->type == 'n')
        {
            return -execute_ast(node->left, sym, yyout);
        }
        else if (node->type == '*')
        {
            return execute_ast(node->left, sym, yyout) * execute_ast(node->right, sym, yyout);
        }
        else if (node->type == '/')
        {
            if (execute_ast(node->right, sym, yyout) == 0)
            {
                yyerror("Error: Divide by zero\n");
                exit(1);
            }
            else
                return execute_ast(node->left, sym, yyout) / execute_ast(node->right, sym, yyout);
        }
        else if (node->type == '<')
        {
            return execute_ast(node->left, sym, yyout) < execute_ast(node->right, sym, yyout);
        }
        else if (node->type == '>')
        {
            return execute_ast(node->left, sym, yyout) > execute_ast(node->right, sym, yyout);
        }
        else if (node->type == 'g')
        {
            return execute_ast(node->left, sym, yyout) <= execute_ast(node->right, sym, yyout);
        }
        else if (node->type == 's')
        {
            return execute_ast(node->left, sym, yyout) >= execute_ast(node->right, sym, yyout);
        }
        else if (node->type == 'q')
        {
            return execute_ast(node->left, sym, yyout) == execute_ast(node->right, sym, yyout);
        }
        else if (node->type == 'N')
        {
            return execute_ast(node->left, sym, yyout) != execute_ast(node->right, sym, yyout);
        }
        else if (node->type == 'l')
        {
            execute_ast(node->left, sym, yyout);
            while (execute_ast(node->condition, sym, yyout))
            {
                execute_ast(node->lines, sym, yyout);
                execute_ast(node->right, sym, yyout);
            }
            return 1;
        }
        else if (node->type == 'p')
        {
            fprintf(yyout, "%d\r", execute_ast(node->left, sym, yyout));
            return 1;
        }
        else if (node->type == 'S')
        {
            fprintf(yyout, "%s\r", node->variableASCII);
            return 1;
        }
        else if (node->type == 'F')
        {
            if (execute_ast(node->condition, sym, yyout))
            {
                return execute_ast(node->left, sym, yyout);
            }
            else
            {
                if (node->right)
                {
                    return execute_ast(node->right, sym, yyout);
                }
            }
        }
    }

    return 0;
}

char *lookup(int type)
{
    char *buffer = (char *)malloc(20 * sizeof(char));
    switch (type)
    {
    case 'F':
        return "IF";
    case 'p':
        return "PRINT";
    case 'l':
        return "LINK";
    case 'w':
        return "WHILE";
    case 'L':
        return "FOR";
    default:
        sprintf(buffer, "%c", type); // Convert the integer to a string
        return buffer;
    }
}

void print_tree(struct ASTNode *root, int isLeft, char *prefix)
{
    if (root == NULL)
        return;
    fprintf(treeFile, prefix);
    fprintf(treeFile, isLeft ? "├──" : "└──");
    if (root->type == 'i')
        fprintf(treeFile, " %d\n", root->value);
    else if (root->type == 'v')
        fprintf(treeFile, " %c\n", root->variable + 'a');  
    else
    {
        static char buffer[20];
        snprintf(buffer, sizeof(buffer), lookup(root->type));
        fprintf(treeFile, " %s\n", buffer);
    }
    // Enter the next tree level - left and right branch
    char *newPrefix = (char *)malloc(strlen(prefix) + 5);
    sprintf(newPrefix, "%s%s", prefix, isLeft ? "│   " : "    ");

    print_tree(root->left, 1, newPrefix);
    print_tree(root->right, 0, newPrefix);
}

int maxx(int a, int b)
{
    return (a > b ? a : b);
}

int height(struct ASTNode *root)
{
    if (root == NULL)
        return 0;
    return maxx(height(root->left), height(root->right)) + 1;
}

int getcol(int h)
{
    if (h == 1)
        return 1;
    return getcol(h - 1) + getcol(h - 1) + 1;
}

void printTree(char ***M, struct ASTNode *root, int col, int row, int height)
{
    if (root == NULL)
        return;
    char buffer[20];
    if (root->type == 'i')
        fprintf(treeFile, " %d\n", root->value);
    else if (root->type == 'v')
        fprintf(treeFile, " %c\n", root->variable + 'a');
    else if (root->type == 'S'){
        fprintf(treeFile, " %s\n", root->variableASCII);
    } 
    else
    {
        snprintf(buffer, sizeof(buffer), lookup(root->type));
    }
    M[row][col] = strdup(buffer);
    printTree(M, root->left, col - pow(2, height - 2), row + 1, height - 1);
    printTree(M, root->right, col + pow(2, height - 2), row + 1, height - 1);
}

void TreePrinter(struct ASTNode *root)
{
    int h = height(root);
    int col = getcol(h);
    char ***M = (char ***)malloc(h * sizeof(char **));
    for (int i = 0; i < h; i++)
    {
        M[i] = (char **)malloc(col * sizeof(char *));
        for (int j = 0; j < col; j++)
        {
            M[i][j] = NULL; // Initialize to 0
        }
    }
    printTree(M, root, col / 2, 0, h);
    for (int i = 0; i < h; i++)
    {
        for (int j = 0; j < col; j++)
        {
            if (M[i][j] == 0)
                fprintf(treeFile, "  ");
            else
                fprintf(treeFile, "%s ", M[i][j]);
        }
        fprintf(treeFile, "\n");
    }
}