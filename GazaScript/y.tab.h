typedef union 
{
    int value;
    char * strvalue;
} symbol;

#ifndef YYSTYPE
#define YYSTYPE symbol
#endif
#define INTEGER 258
#define VARIABLE 259
#define PRINT 260
#define IF  261
#define ELSE 262
#define END 263
#define FOR 264
#define STRING 265
extern YYSTYPE yylval;