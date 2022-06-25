%{
#include<bits/stdc++.h>
#include "SymbolTable.h"
#include "utils.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

SymbolTable st(30);
ofstream logOut;
ofstream errorOut;

extern unsigned long lineNo;
extern unsigned long errorNo;

void yyerror(char *s) {
	logOut << "Error at line " << lineNo << ": " << s << endl;
	errorOut << "Error at line " << lineNo << ": " << s << endl;
    errorNo++;
}
%}

%error-verbose
%union {
    SymbolInfo* st;
}

%token IF ELSE FOR WHILE DO INT CHAR FLOAT DOUBLE VOID RETURN CONTINUE PRINTLN
%token<st> ID CONST_INT CONST_FLOAT ERROR_FLOAT
%token ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program {
        printLog(logOut, lineNo, "start", "program", $$->getName());
	}
	;

program : program unit {
        printLog(logOut, lineNo, "program", "program unit", $$->getName());
    }
    | unit {
        printLog(logOut, lineNo, "program", "unit", $$->getName());
    }
    ;

unit : var_declaration {
        printLog(logOut, lineNo, "unit", "var_declaration", $$->getName());
    }
    | func_declaration {
        printLog(logOut, lineNo, "unit", "func_declaration", $$->getName());
    }
    | func_definition {
        printLog(logOut, lineNo, "unit", "func_definition", $$->getName());
    }
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        printLog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams(), $$->getName());
    }
	| type_specifier ID LPAREN RPAREN SEMICOLON {
        printLog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams(), $$->getName());
    }
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement {
        printLog(logOut, lineNo, "func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement", $$->getName());
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams(), $$->getName());
    }
    | type_specifier ID LPAREN RPAREN compound_statement {
        printLog(logOut, lineNo, "func_definition", "type_specifier ID LPAREN RPAREN compound_statement", $$->getName());
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams(), $$->getName());
    }
    ;

parameter_list  : parameter_list COMMA type_specifier ID {
        printLog(logOut, lineNo, "parameter_list", "parameter_list COMMA type_specifier ID", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    | parameter_list COMMA type_specifier {
        printLog(logOut, lineNo, "parameter_list", "parameter_list COMMA type_specifier", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    | type_specifier ID {
        printLog(logOut, lineNo, "parameter_list", "type_specifier ID", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    | type_specifier {
        printLog(logOut, lineNo, "parameter_list", "type_specifier", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    ;

compound_statement : LCURL statements RCURL {
        printLog(logOut, lineNo, "compound_statement", "LCURL statements RCURL", $$->getName());
    }
    | LCURL RCURL {
        printLog(logOut, lineNo, "compound_statement", "LCURL RCURL", $$->getName());
    }
    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
        printLog(logOut, lineNo, "var_declaration", "type_specifier declaration_list SEMICOLON", $$->getName());
        // st.addVariable(yylval.st->getName(), yylval.st->getType(), $$->getName());
    }
    ;
 		 
type_specifier : INT {
        printLog(logOut, lineNo, "type_specifier", "INT", $$->getName());
    }
    | FLOAT {
        printLog(logOut, lineNo, "type_specifier", "FLOAT", $$->getName());
    }
    | VOID {
        printLog(logOut, lineNo, "type_specifier", "VOID", $$->getName());
    }
    ;
 		
declaration_list : declaration_list COMMA ID {
        printLog(logOut, lineNo, "declaration_list", "declaration_list COMMA ID", $$->getName());
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        printLog(logOut, lineNo, "declaration_list", "declaration_list COMMA ID LTHIRD CONST_INT RTHIRD", $$->getName());
    }
    | ID {
        printLog(logOut, lineNo, "declaration_list", "ID", $$->getName());
    }
    | ID LTHIRD CONST_INT RTHIRD {
        printLog(logOut, lineNo, "declaration_list", "ID LTHIRD CONST_INT RTHIRD", $$->getName());
    }
    ;
 		  
statements : statement {
        printLog(logOut, lineNo, "statements", "statement", $$->getName());
    }
    | statements statement {
        printLog(logOut, lineNo, "statements", "statements statement", $$->getName());
    }
    ;
	   
statement : var_declaration {
        printLog(logOut, lineNo, "statement", "var_declaration", $$->getName());
    }
    | expression_statement {
        printLog(logOut, lineNo, "statement", "expression_statement", $$->getName());
    }
    | compound_statement {
        printLog(logOut, lineNo, "statement", "compound_statement", $$->getName());
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
        printLog(logOut, lineNo, "statement", "FOR LPAREN expression_statement expression_statement expression RPAREN statement", $$->getName());
    }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
        printLog(logOut, lineNo, "statement", "IF LPAREN expression RPAREN statement", $$->getName());
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        printLog(logOut, lineNo, "statement", "IF LPAREN expression RPAREN statement ELSE statement", $$->getName());
    }
    | WHILE LPAREN expression RPAREN statement {
        printLog(logOut, lineNo, "statement", "WHILE LPAREN expression RPAREN statement", $$->getName());
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        printLog(logOut, lineNo, "statement", "PRINTLN LPAREN ID RPAREN SEMICOLON", $$->getName());
    }
    | RETURN expression SEMICOLON {
        printLog(logOut, lineNo, "statement", "RETURN expression SEMICOLON", $$->getName());
    }
    ;
	  
expression_statement : SEMICOLON {
        printLog(logOut, lineNo, "expression_statement", "SEMICOLON", $$->getName());
    }
    | expression SEMICOLON {
        printLog(logOut, lineNo, "expression_statement", "expression SEMICOLON", $$->getName());
    }
    ;

variable : ID {
        printLog(logOut, lineNo, "variable", "ID", $$->getName());
    } 		
    | ID LTHIRD expression RTHIRD {
        printLog(logOut, lineNo, "variable", "ID LTHIRD expression RTHIRD", $$->getName());
    }
    ;
	 
expression : logic_expression {
        printLog(logOut, lineNo, "expression", "logic_expression", $$->getName());
    }	
    | variable ASSIGNOP logic_expression {
        printLog(logOut, lineNo, "expression", "variable ASSIGNOP logic_expression", $$->getName());
    }
    ;
			
logic_expression : rel_expression {
        printLog(logOut, lineNo, "logic_expression", "rel_expression", $$->getName());
    } 	
    | rel_expression LOGICOP rel_expression {
        printLog(logOut, lineNo, "logic_expression", "rel_expression LOGICOP rel_expression", $$->getName());
    }
    ;
			
rel_expression : simple_expression {
        printLog(logOut, lineNo, "rel_expression", "simple_expression", $$->getName());
    }
    | simple_expression RELOP simple_expression	{
        printLog(logOut, lineNo, "rel_expression", "simple_expression RELOP simple_expression", $$->getName());
    }
    ;
				
simple_expression : term {
        printLog(logOut, lineNo, "simple_expression", "term", $$->getName());
    }
    | simple_expression ADDOP term {
        printLog(logOut, lineNo, "simple_expression", "simple_expression ADDOP term", $$->getName());
    }
    ;
					
term :	unary_expression {
        printLog(logOut, lineNo, "term", "unary_expression", $$->getName());
    }
    | term MULOP unary_expression {
        printLog(logOut, lineNo, "term", "term MULOP unary_expression", $$->getName());
    }
    ;

unary_expression : ADDOP unary_expression {
        printLog(logOut, lineNo, "unary_expression", "ADDOP unary_expression", $$->getName());
    } 
    | NOT unary_expression {
        printLog(logOut, lineNo, "unary_expression", "NOT unary_expression", $$->getName());
    }
    | factor {
        printLog(logOut, lineNo, "unary_expression", "factor", $$->getName());
    }
    ;
	
factor : variable {
        printLog(logOut, lineNo, "factor", "variable", $$->getName());
    }
	| ID LPAREN argument_list RPAREN {
        printLog(logOut, lineNo, "factor", "ID LPAREN argument_list RPAREN", $$->getName());
    }
	| LPAREN expression RPAREN {
        printLog(logOut, lineNo, "factor", "LPAREN expression RPAREN", $$->getName());
    }
	| CONST_INT {
        printLog(logOut, lineNo, "factor", "CONST_INT", $$->getName());
    }
	| CONST_FLOAT {
        printLog(logOut, lineNo, "factor", "CONST_FLOAT", $$->getName());
    }
	| variable INCOP {
        printLog(logOut, lineNo, "factor", "variable INCOP", $$->getName());
    }
	| variable DECOP {
        printLog(logOut, lineNo, "factor", "variable DECOP", $$->getName());
    }
	;
	
argument_list : arguments {
        printLog(logOut, lineNo, "argument_list", "arguments", $$->getName());
    }
    | {
        printLog(logOut, lineNo, "argument_list", "", $$->getName());
    }
    ;
	
arguments : arguments COMMA logic_expression {
        printLog(logOut, lineNo, "arguments", "arguments COMMA logic_expression", $$->getName());
    }
    | logic_expression {
        printLog(logOut, lineNo, "arguments", "logic_expression", $$->getName());
    }
    ;


%%
int main(int argc,char *argv[])
{

	if (argc < 2) {
        cout << "Specify input file" << endl;
        return 1;
    }

    logOut.open("1805093_log.txt");
    errorOut.open("1805093_token.txt");  

    yyin = fopen(argv[1], "r");
    if(yyin == NULL){
		cout << "Cannot open specified input file" << endl;
		return 1;
	}
	yyparse();
    fclose(yyin);

    st.printSymbols(logOut);
    logOut << endl;
    logOut << "Total lines: " << lineNo << endl;
    logOut << "Total errors: " << errorNo << endl;

    logOut.close();
    errorOut.close();
	
	return 0;
}

