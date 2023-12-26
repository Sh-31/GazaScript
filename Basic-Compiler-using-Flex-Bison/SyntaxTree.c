// SyntaxTree.c

#include "SyntaxTree.h"


ASTNode *Mk_leaf_node(char type, int value)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->value = value;
    node->left = NULL;
    node->right = NULL;
    node->condition = NULL;
    node->lines = NULL;
    node->variableASCII = NULL;
    return node;
}
ASTNode *Mk_op_Node(char type, ASTNode *left)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->left = left;
    node->right = NULL;
    node->condition = NULL;
    node->lines = NULL;
    return node;
}
ASTNode *Mk_interbal_Node(char type, ASTNode *left, ASTNode *right)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->left = left;
    node->right = right;
    node->condition = NULL;
    node->lines = NULL; 
    node->variableASCII = NULL;
    node->variable = 0;
    return node;
}
ASTNode *Mk_if_condtition_Node(char type, ASTNode *condition, ASTNode *left, ASTNode *right)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->condition = condition;
    node->left = left;
    node->right = right;
    node->lines = NULL;
    node->variableASCII = NULL;
    node->variable = 0;
    node->value = 0;
    node->variableASCII = NULL;
    return node;
}
ASTNode *Assign_Node(char type, int variableASCII, ASTNode *left)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->variable = variableASCII;
    node->left = left;
    node->right = NULL;
    node->condition = NULL;
    node->lines = NULL;
    node->variableASCII = NULL;
    return node;
}
ASTNode *Access_Variable(char type, int variableASCII)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->variable = variableASCII;
    node->left = NULL;
    node->right = NULL;
    node->condition = NULL;
    node->lines = NULL;
    node->variableASCII = NULL;
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
    node->variableASCII = NULL;
    return node;
}
ASTNode *Print_Node(char type, char *variableASCII)
{
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    node->variableASCII = variableASCII;
    node->left = NULL;
    node->right = NULL;
    node->condition = NULL;
    node->lines = NULL;
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

char *lookup(int type) {
    char *buffer = (char *)malloc(20 * sizeof(char));
    switch(type) {
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
            sprintf(buffer, "%c", type);  // Convert the integer to a string
            return buffer;
    }
}
void print_tree(struct ASTNode* root, int isLeft, char* prefix,FILE *treeFile) {
    if (root == NULL)
        return;
    fprintf(treeFile, "%s", prefix);
    fprintf(treeFile, "%s", isLeft ? "|--" : "|__");
    if (root->type == 'i')
        fprintf(treeFile, " %d\n", root->value);
    else if (root->type == 'v')
        fprintf(treeFile, " %c\n", root->variable + 'a');
    else if (root->type == 'P') {
        fprintf(treeFile, " %s\n", root->variableASCII);
    }
    else {
        static char buffer[20]; 
        snprintf(buffer, sizeof(buffer), lookup(root->type));
        fprintf(treeFile, " %s\n", buffer);
    }
    // Enter the next tree level - left and right branch
    char* newPrefix = (char*)malloc(strlen(prefix) + 5);
    sprintf(newPrefix, "%s%s", prefix, isLeft ? "|   " : "    ");
    
    print_tree(root->right, 1, newPrefix,treeFile);
    print_tree(root->left, 0, newPrefix,treeFile);
    // print_tree(root->cond, 0, newPrefix);
    // print_tree(root->flow, 0, newPrefix);
}