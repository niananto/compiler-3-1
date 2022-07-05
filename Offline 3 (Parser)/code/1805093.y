%{
#include<bits/stdc++.h>
#include "SymbolTable.h"
// #include "utils.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

SymbolTable st(30);
ofstream logOut;
ofstream errorOut;

extern unsigned long lineNo;
extern unsigned long errorNo;

void printLog(unsigned long lineNo, string left, string right, string symbolName) {
    logOut << "Line " << lineNo << ": " << left << " : " << right << endl << endl;
    logOut << symbolName << endl << endl;
}

void yyerror(char *s) {
	logOut << "Error at line " << lineNo << ": " << s << endl;
	errorOut << "Error at line " << lineNo << ": " << s << endl;
    errorNo++;
}
%}

%union {
    SymbolInfo* st;
}

%token IF ELSE FOR WHILE DO INT CHAR FLOAT DOUBLE VOID RETURN CONTINUE PRINTLN
%token<st> ID CONST_INT CONST_FLOAT ERROR_FLOAT
%token<st> ADDOP MULOP RELOP LOGICOP 
%token INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%type<st> start program unit func_declaration func_definition parameter_list compound_statement var_declaration
%type<st> type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression
%type<st> term unary_expression factor argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program {
        $$ = $1;
        printLog(lineNo, "start", "program", $$->getName());
	}
	;

program : program unit {
        $$ = new SymbolInfo(($1->getName() + "\n" + $2->getName()), "PROGRAM");
        printLog(lineNo, "program", "program unit", $$->getName());
    }
    | unit {
        $$ = $1;
        printLog(lineNo, "program", "unit", $$->getName());
    }
    ;

unit : var_declaration {
        $$ = $1;
        printLog(lineNo, "unit", "var_declaration", $$->getName());
    }
    | func_declaration {
        $$ = $1;
        printLog(lineNo, "unit", "func_declaration", $$->getName());
    }
    | func_definition {
        $$ = $1;
        printLog(lineNo, "unit", "func_definition", $$->getName());
    }
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n"), "FUNC_DECLARATION");
        printLog(lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams(), $$->getName());
    }
	| type_specifier ID LPAREN RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "();\n"), "FUNC_DECLARATION");
        printLog(lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams(), $$->getName());
    }
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "(" + $4->getName() + ")" + $6->getName()), "FUNC_DEFINITION");
        printLog(lineNo, "func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement", $$->getName());
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams(), $$->getName());
    }
    | type_specifier ID LPAREN RPAREN compound_statement {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + "()" + $5->getName()), "FUNC_DEFINITION");
        printLog(lineNo, "func_definition", "type_specifier ID LPAREN RPAREN compound_statement", $$->getName());
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams(), $$->getName());
    }
    ;

parameter_list  : parameter_list COMMA type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + ", " + $3->getName() + " "  + $4->getName()), "PARAMETER_LIST");
        printLog(lineNo, "parameter_list", "parameter_list COMMA type_specifier ID", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    | parameter_list COMMA type_specifier {
        $$ = new SymbolInfo(($1->getName() + ", " + $3->getName()), "PARAMETER_LIST");
        printLog(lineNo, "parameter_list", "parameter_list COMMA type_specifier", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    | type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName()), "PARAMETER_LIST");
        printLog(lineNo, "parameter_list", "type_specifier ID", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    | type_specifier {
        $$ = new SymbolInfo(($1->getName()), "PARAMETER_LIST");
        printLog(lineNo, "parameter_list", "type_specifier", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    ;

compound_statement : LCURL statements RCURL {
        $$ = new SymbolInfo(("{\n" + $2->getName() + "\n}"), "COMPOUND_STATEMENT");
        printLog(lineNo, "compound_statement", "LCURL statements RCURL", $$->getName());
    }
    | LCURL RCURL {
        $$ = new SymbolInfo("{}", "COMPOUND_STATEMENT");
        printLog(lineNo, "compound_statement", "LCURL RCURL", $$->getName());
    }
    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + ";\n"), "VAR_DECLARATION");
        printLog(lineNo, "var_declaration", "type_specifier declaration_list SEMICOLON", $$->getName());
        // st.addVariable(yylval.st->getName(), yylval.st->getType(), $$->getName());
    }
    ;
 		 
type_specifier : INT {
        $$ = new SymbolInfo("int", "TYPE_SPECIFIER");
        printLog(lineNo, "type_specifier", "INT", $$->getName());
    }
    | FLOAT {
        $$ = new SymbolInfo("float", "TYPE_SPECIFIER");
        printLog(lineNo, "type_specifier", "FLOAT", $$->getName());
    }
    | VOID {
        $$ = new SymbolInfo("void", "TYPE_SPECIFIER");
        printLog(lineNo, "type_specifier", "VOID", $$->getName());
    }
    ;
 		
declaration_list : declaration_list COMMA ID {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName()), "DECLARATION_LIST");
        printLog(lineNo, "declaration_list", "declaration_list COMMA ID", $$->getName());
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName() + "[" + $5->getName() + "]"), "DECLARATION_LIST");
        printLog(lineNo, "declaration_list", "declaration_list COMMA ID LTHIRD CONST_INT RTHIRD", $$->getName());
    }
    | ID {
        $$ = $1;
        printLog(lineNo, "declaration_list", "ID", $$->getName());
    }
    | ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "DECLARATION_LIST");
        printLog(lineNo, "declaration_list", "ID LTHIRD CONST_INT RTHIRD", $$->getName());
    }
    ;
 		  
statements : statement {
        $$ = $1;
        printLog(lineNo, "statements", "statement", $$->getName());
    }
    | statements statement {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), "STATEMENTS");
        printLog(lineNo, "statements", "statements statement", $$->getName());
    }
    ;
	   
statement : var_declaration {
        $$ = $1;
        printLog(lineNo, "statement", "var_declaration", $$->getName());
    }
    | expression_statement {
        $$ = $1;
        printLog(lineNo, "statement", "expression_statement", $$->getName());
    }
    | compound_statement {
        $$ = $1;
        printLog(lineNo, "statement", "compound_statement", $$->getName());
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
        $$ = new SymbolInfo(("for(" + $3->getName() + ";" + $4->getName() + ";" + $5->getName() + ")" + $7->getName()), "STATEMENT");
        printLog(lineNo, "statement", "FOR LPAREN expression_statement expression_statement expression RPAREN statement", $$->getName());
    }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
        $$ = new SymbolInfo(("if(" + $3->getName() + ")" + $5->getName()), "STATEMENT");
        printLog(lineNo, "statement", "IF LPAREN expression RPAREN statement", $$->getName());
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        $$ = new SymbolInfo(("if(" + $3->getName() + ")" + $5->getName() + "else" + $7->getName()), "STATEMENT");
        printLog(lineNo, "statement", "IF LPAREN expression RPAREN statement ELSE statement", $$->getName());
    }
    | WHILE LPAREN expression RPAREN statement {
        $$ = new SymbolInfo(("while(" + $3->getName() + ")" + $5->getName()), "STATEMENT");
        printLog(lineNo, "statement", "WHILE LPAREN expression RPAREN statement", $$->getName());
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        $$ = new SymbolInfo(("printf(" + $3->getName() + ");"), "STATEMENT");
        printLog(lineNo, "statement", "PRINTLN LPAREN ID RPAREN SEMICOLON", $$->getName());
    }
    | RETURN expression SEMICOLON {
        $$ = new SymbolInfo(("return " + $2->getName() + ";"), "STATEMENT");
        printLog(lineNo, "statement", "RETURN expression SEMICOLON", $$->getName());
    }
    ;
	  
expression_statement : SEMICOLON {
        $$ = new SymbolInfo(";\n", "EXPRESSION_STATEMENT");
        printLog(lineNo, "expression_statement", "SEMICOLON", $$->getName());
    }
    | expression SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + ";\n"), "EXPRESSION_STATEMENT");
        printLog(lineNo, "expression_statement", "expression SEMICOLON", $$->getName());
    }
    ;

variable : ID {
        $$ = yylval.st;
        printLog(lineNo, "variable", "ID", $$->getName());
    } 		
    | ID LTHIRD expression RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "ARRAY");
        printLog(lineNo, "variable", "ID LTHIRD expression RTHIRD", $$->getName());
    }
    ;
	 
expression : logic_expression {
        $$ = $1;
        printLog(lineNo, "expression", "logic_expression", $$->getName());
    }	
    | variable ASSIGNOP logic_expression {
        $$ = new SymbolInfo(($1->getName() + "=" + $3->getName()), $1->getType());
        printLog(lineNo, "expression", "variable ASSIGNOP logic_expression", $$->getName());
    }
    ;
			
logic_expression : rel_expression {
        $$ = $1;
        printLog(lineNo, "logic_expression", "rel_expression", $$->getName());
    } 	
    | rel_expression LOGICOP rel_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "BOOL");
        printLog(lineNo, "logic_expression", "rel_expression LOGICOP rel_expression", $$->getName());
    }
    ;
			
rel_expression : simple_expression {
        $$ = $1;
        printLog(lineNo, "rel_expression", "simple_expression", $$->getName());
    }
    | simple_expression RELOP simple_expression	{
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "BOOL");
        printLog(lineNo, "rel_expression", "simple_expression RELOP simple_expression", $$->getName());
    }
    ;
				
simple_expression : term {
        $$ = $1;
        printLog(lineNo, "simple_expression", "term", $$->getName());
    }
    | simple_expression ADDOP term {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $1->getType());
        printLog(lineNo, "simple_expression", "simple_expression ADDOP term", $$->getName());
    }
    ;
					
term :	unary_expression {
        $$ = $1;
        printLog(lineNo, "term", "unary_expression", $$->getName());
    }
    | term MULOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $1->getType());
        printLog(lineNo, "term", "term MULOP unary_expression", $$->getName());
    }
    ;

unary_expression : ADDOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), $2->getType());
        printLog(lineNo, "unary_expression", "ADDOP unary_expression", $$->getName());
    } 
    | NOT unary_expression {
        $$ = new SymbolInfo(("!" + $2->getName()), $2->getType());
        printLog(lineNo, "unary_expression", "NOT unary_expression", $$->getName());
    }
    | factor {
        $$ = $1;
        printLog(lineNo, "unary_expression", "factor", $$->getName());
    }
    ;
	
factor : variable {
        $$ = $1;
        printLog(lineNo, "factor", "variable", $$->getName());
    }
	| ID LPAREN argument_list RPAREN {
        $$ = new SymbolInfo(($1->getName() + "(" + $3->getName() + ")"), "FUNCTION");
        printLog(lineNo, "factor", "ID LPAREN argument_list RPAREN", $$->getName());
    }
	| LPAREN expression RPAREN {
        $$ = new SymbolInfo(("(" + $2->getName() + ")"), $2->getType());
        printLog(lineNo, "factor", "LPAREN expression RPAREN", $$->getName());
    }
	| CONST_INT {
        $$ = yylval.st;
        printLog(lineNo, "factor", "CONST_INT", $$->getName());
    }
	| CONST_FLOAT {
        $$ = yylval.st;
        printLog(lineNo, "factor", "CONST_FLOAT", $$->getName());
    }
	| variable INCOP {
        $$ = new SymbolInfo(($1->getName() + "++"), $1->getType());
        printLog(lineNo, "factor", "variable INCOP", $$->getName());
    }
	| variable DECOP {
        $$ = new SymbolInfo(($1->getName() + "--"), $1->getType());
        printLog(lineNo, "factor", "variable DECOP", $$->getName());
    }
	;
	
argument_list : arguments {
        $$ = $1;
        printLog(lineNo, "argument_list", "arguments", $$->getName());
    }
    | {
        $$ = new SymbolInfo("", "VOID");
        printLog(lineNo, "argument_list", "", $$->getName());
    }
    ;
	
arguments : arguments COMMA logic_expression {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName()), $1->getType());
        printLog(lineNo, "arguments", "arguments COMMA logic_expression", $$->getName());
    }
    | logic_expression {
        $$ = $1;
        printLog(lineNo, "arguments", "logic_expression", $$->getName());
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
    errorOut.open("1805093_error.txt");  

    yyin = fopen(argv[1], "r");
    if(yyin == NULL){
		cout << "Cannot open specified input file" << endl;
		return 1;
	}
    
	yyparse();
    fclose(yyin);

    // st.printSymbols(logOut);
    logOut << endl;
    logOut << "Total lines: " << lineNo << endl;
    logOut << "Total errors: " << errorNo << endl;

    logOut.close();
    errorOut.close();
	
	return 0;
}

