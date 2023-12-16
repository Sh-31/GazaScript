# GazaScript
Basic Compiler Using Flex and Bison


| **Terminals/Tokens**               | **Rules**                               | **Semantic Action**                                       |
|------------------------------------|------------------------------------------|----------------------------------------------------------|
| 1. VARIABLE                        |                                          |                                                          |
| 2. INTEGER                        |                                          | Store value of the INTEGER to the Expr value              |
| 3. Saved Keyword:                  | Print                                    |                                                          |
|                                    | IF                                       |                                                          |
|                                    | THEN                                     |                                                          |
|                                    | ELSE                                     |                                                          |
|                                    | WHILE                                    |                                                          |
| **Non-terminals**                  | Main (whole text)                        | No action                                                |
|                                    | Lines (all the lines of the text)        | I want to look for all lines                             |
|                                    | Line (one statement)                     |                                                          |
|                                    | Expr                                     | Expression (Arithmetic - Logical - Rational or a value)  |
|                                    | Assignment                               | VARIABLE '=' expr: Assign the value of expr to VARIABLE   |
|                                    | Print_statement                          | 'PRINT' '(' expr ')' : Print the value of expr           |
| **Rules**                          | Symantec Action                          |                                                          |
| Main -> lines                      | Main is the start symbol                 | I want to look for all lines                             |
| Lines -> lines line '\n'           | Lines consist of lines and line ending with '\n' | I want to look for what is line                    |
| Line -> expr                       | Line can be Expression (Arithmetic - Logical - Rational or just a value) |                                                          |
|         | Assignment                 | Variable assignment                      | Assign the value of expr to VARIABLE                     |
|         | Print_statement            | Print statement                          | 'PRINT' '(' expr ')' : Print the value of expr           |
| Assignment -> VARIABLE '=' expr    | Assign the value of expr to VARIABLE      |                                                          |
| Print_statement -> 'PRINT' '(' expr ')' | Print the value of expr               |                                                          |
|                 | 'PRINT' '(' VARIABLE ')' | Print the value stored at VARIABLE                        |
| Expr -> INTEGER                    | Store value of the INTEGER to the Expr value |                                                          |
|        | expr '+' expr               | Calculate exp1 + exp2 and store it at expr3             |                                                          |