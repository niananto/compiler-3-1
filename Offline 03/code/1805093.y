%{
#include<bits/stdc++.h>
#include "SymbolTable.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

SymbolTable st = SymbolTable(7);
ofstream logOut;
ofstream errorOut;

extern unsigned long lineNo;
extern unsigned long errorNo;

void yyerror(char *s) {
	logOut << "Error at line " << lineNo << ": " << s << endl;
	errorOut << "Error at line " << lineNo << ": " << s << endl;
    errorNo++;
}

void logGrammer(string left, string right) {
    logOut << "Line " << lineNo << ": " << left << " : " << right << endl;
}
%}

%error-verbose
%union {
    SymbolInfo* st;
    vector<SymbolInfo*>* vst;
}

%token IF ELSE FOR WHILE DO INT CHAR FLOAT DOUBLE VOID RETURN CONTINUE PRINTLN
%token<st> ID CONST_INT CONST_FLOAT ERROR_FLOAT
%token ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program {
        logGrammer("start", "program");
	}
	;

program : program unit {
        logGrammer("program", "program unit");
    }
    | unit {
        logGrammer("program", "unit");
    }
    ;

unit : var_declaration {
        logGrammer("unit", "var_declaration");
    }
    | func_declaration {
        logGrammer("unit", "func_declaration");
    }
    | func_definition {
        logGrammer("unit", "func_definition");
    }
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        logGrammer("func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams());
    }
	| type_specifier ID LPAREN RPAREN SEMICOLON {
        logGrammer("func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON");
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams());
    }
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement {
        logGrammer("func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement");
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams());
    }
    | type_specifier ID LPAREN RPAREN compound_statement {
        logGrammer("func_definition", "type_specifier ID LPAREN RPAREN compound_statement");
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams());
    }
    ;

parameter_list  : parameter_list COMMA type_specifier ID {
        logGrammer("parameter_list", "parameter_list COMMA type_specifier ID");
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()));
    }
    | parameter_list COMMA type_specifier {
        logGrammer("parameter_list", "parameter_list COMMA type_specifier");
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()));
    }
    | type_specifier ID {
        logGrammer("parameter_list", "type_specifier ID");
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()));
    }
    | type_specifier {
        logGrammer("parameter_list", "type_specifier");
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()));
    }
    ;

compound_statement : LCURL statements RCURL {
        logGrammer("compound_statement", "LCURL statements RCURL");
    }
    | LCURL RCURL {
        logGrammer("compound_statement", "LCURL RCURL");
    }
    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
        logGrammer("var_declaration", "type_specifier declaration_list SEMICOLON");
        // st.addVariable(yylval.st->getName(), yylval.st->getType());
    }
    ;
 		 
type_specifier : INT {
        logGrammer("type_specifier", "INT");
    }
    | FLOAT {
        logGrammer("type_specifier", "FLOAT");
    }
    | VOID {
        logGrammer("type_specifier", "VOID");
    }
    ;
 		
declaration_list : declaration_list COMMA ID {
        logGrammer("declaration_list", "declaration_list COMMA ID");
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        logGrammer("declaration_list", "declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
    }
    | ID {
        logGrammer("declaration_list", "ID");
    }
    | ID LTHIRD CONST_INT RTHIRD {
        logGrammer("declaration_list", "ID LTHIRD CONST_INT RTHIRD");
    }
    ;
 		  
statements : statement {
        logGrammer("statements", "statement");
    }
    | statements statement {
        logGrammer("statements", "statements statement");
    }
    ;
	   
statement : var_declaration {
        logGrammer("statement", "var_declaration");
    }
    | expression_statement {
        logGrammer("statement", "expression_statement");
    }
    | compound_statement {
        logGrammer("statement", "compound_statement");
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
        logGrammer("statement", "FOR LPAREN expression_statement expression_statement expression RPAREN statement");
    }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
        logGrammer("statement", "IF LPAREN expression RPAREN statement");
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        logGrammer("statement", "IF LPAREN expression RPAREN statement ELSE statement");
    }
    | WHILE LPAREN expression RPAREN statement {
        logGrammer("statement", "WHILE LPAREN expression RPAREN statement");
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        logGrammer("statement", "PRINTLN LPAREN ID RPAREN SEMICOLON");
    }
    | RETURN expression SEMICOLON {
        logGrammer("statement", "RETURN expression SEMICOLON");
    }
    ;
	  
expression_statement : SEMICOLON {
        logGrammer("expression_statement", "SEMICOLON");
    }
    | expression SEMICOLON {
        logGrammer("expression_statement", "expression SEMICOLON");
    }
    ;

variable : ID {
        logGrammer("variable", "ID");
    } 		
    | ID LTHIRD expression RTHIRD {
        logGrammer("variable", "ID LTHIRD expression RTHIRD");
    }
    ;
	 
expression : logic_expression {
        logGrammer("expression", "logic_expression");
    }	
    | variable ASSIGNOP logic_expression {
        logGrammer("expression", "variable ASSIGNOP logic_expression");
    }
    ;
			
logic_expression : rel_expression {
        logGrammer("logic_expression", "rel_expression");
    } 	
    | rel_expression LOGICOP rel_expression {
        logGrammer("logic_expression", "rel_expression LOGICOP rel_expression");
    }
    ;
			
rel_expression : simple_expression {
        logGrammer("rel_expression", "simple_expression");
    }
    | simple_expression RELOP simple_expression	{
        logGrammer("rel_expression", "simple_expression RELOP simple_expression");
    }
    ;
				
simple_expression : term {
        logGrammer("simple_expression", "term");
    }
    | simple_expression ADDOP term {
        logGrammer("simple_expression", "simple_expression ADDOP term");
    }
    ;
					
term :	unary_expression {
        logGrammer("term", "unary_expression");
    }
    | term MULOP unary_expression {
        logGrammer("term", "term MULOP unary_expression");
    }
    ;

unary_expression : ADDOP unary_expression {
        logGrammer("unary_expression", "ADDOP unary_expression");
    } 
    | NOT unary_expression {
        logGrammer("unary_expression", "NOT unary_expression");
    }
    | factor {
        logGrammer("unary_expression", "factor");
    }
    ;
	
factor	: variable {
        logGrammer("factor", "variable");
    }
	| ID LPAREN argument_list RPAREN {
        logGrammer("factor", "ID LPAREN argument_list RPAREN");
    }
	| LPAREN expression RPAREN {
        logGrammer("factor", "LPAREN expression RPAREN");
    }
	| CONST_INT {
        logGrammer("factor", "CONST_INT");
    }
	| CONST_FLOAT {
        logGrammer("factor", "CONST_FLOAT");
    }
	| variable INCOP {
        logGrammer("factor", "variable INCOP");
    }
	| variable DECOP {
        logGrammer("factor", "variable DECOP");
    }
	;
	
argument_list : arguments {
        logGrammer("argument_list", "arguments");
    }
    ;
	
arguments : arguments COMMA logic_expression {
        logGrammer("arguments", "arguments COMMA logic_expression");
    }
    | logic_expression {
        logGrammer("arguments", "logic_expression");
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

