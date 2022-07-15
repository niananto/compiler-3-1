%{
#include<bits/stdc++.h>
#include "includes/SymbolTable.h"
#include "includes/handleGrammers.h"
#include "includes/utils.h"
using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

SymbolTable* st = new SymbolTable(30);
ofstream logOut;
ofstream errorOut;

extern unsigned long lineNo;
extern unsigned long errorNo;

// [what happens when we call a function which is declared not defined and then never really define it]
// to check if every declared only (not defined) functions are defined later if that function was called
// if the function was never called, then declaration with no definition later is not a problem
vector< pair <string, unsigned long> > calledFunctions; // only the valid function calls are stored here

void yyerror(const char *s) {
	logOut << "Error at line " << lineNo << ": " << s << endl << endl;
	errorOut << "Error at line " << lineNo << ": " << s << endl << endl;
    errorNo++;
}

%}

%union {
    SymbolInfo* symbol;
}

%token IF ELSE FOR WHILE DO INT CHAR FLOAT DOUBLE VOID RETURN CONTINUE PRINTLN
%token<symbol> ID CONST_INT CONST_FLOAT ERROR_FLOAT
%token<symbol> ADDOP MULOP RELOP LOGICOP 
%token INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%type<symbol> start program unit func_declaration func_definition parameter_list compound_statement var_declaration
%type<symbol> type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression
%type<symbol> term unary_expression factor argument_list arguments

%define parse.error verbose
%destructor{
    delete $$;
}<symbol>

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program {
        $$ = $1;
        yylog(logOut, lineNo, "start", "program", "");

        // check if every declared only (not defined) functions are defined later if that function was called
        for (pair<string, unsigned long> a : calledFunctions) {
            // these functions will always exist in the symbol table
            // no need to compare with nullptr
            if (st->lookup(a.first)->isDefined() == false) {
                yyerror(("No definition found for function " + a.first + " at line " + to_string(a.second)).c_str());
            }
        }
	}
	;

program : program unit {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), "PROGRAM");
        yylog(logOut, lineNo, "program", "program unit", $$->getName());
        delete $1; delete $2;
    }
    | unit {
        $$ = $1;
        yylog(logOut, lineNo, "program", "unit", $$->getName());
    }
    ;

unit : var_declaration {
        $$ = new SymbolInfo($1->getName() + "\n", "UNIT");
        yylog(logOut, lineNo, "unit", "var_declaration", $$->getName());
        delete $1;
    }
    | func_declaration {
        $$ = new SymbolInfo($1->getName(), "UNIT");
        yylog(logOut, lineNo, "unit", "func_declaration", $$->getName());
        delete $1;
    }
    | func_definition {
        $$ = new SymbolInfo($1->getName() + "\n", "UNIT");
        yylog(logOut, lineNo, "unit", "func_definition", $$->getName());
        delete $1;
    }
    | error {
        $$ = new SymbolInfo("", "UNIT");
    }
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2, $4);

        delete $1; delete $2; delete $4;
    }
    | type_specifier ID LPAREN parameter_list error RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2, $4);

        delete $1; delete $2; delete $4;
    }
    | type_specifier ID LPAREN parameter_list RPAREN error {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2, $4);

        delete $1; delete $2; delete $4;
    }
    | type_specifier ID LPAREN parameter_list error RPAREN error {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2, $4);

        delete $1; delete $2; delete $4;
    }
	| type_specifier ID LPAREN RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "();\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2);

        delete $1; delete $2;
    }
    | type_specifier ID LPAREN RPAREN error {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "();\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2);

        delete $1; delete $2;
    }| type_specifier ID LPAREN error RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "();\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2);

        delete $1; delete $2;
    }| type_specifier ID LPAREN error RPAREN error {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "();\n"), "FUNC_DECLARATION");
        yylog(logOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2);

        delete $1; delete $2;
    }
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN { // compound_statement here

        handleFuncDefinition($1, $2, $4);

    } compound_statement {

        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "(" + $4->getName() + ")" + $7->getName()), "FUNC_DEFINITION");
        
        // print scopes and exit
        st->printAll(logOut);
        st->exitScope();

        yylog(logOut, lineNo, "func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement", $$->getName());

        delete $1; delete $2; delete $4; delete $7;
    }
    | type_specifier ID LPAREN parameter_list error RPAREN { // compound_statement here

        handleFuncDefinition($1, $2, $4);

    } compound_statement {

        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "(" + $4->getName() + ")" + $8->getName()), "FUNC_DEFINITION");
        
        // print scopes and exit
        st->printAll(logOut);
        st->exitScope();

        yylog(logOut, lineNo, "func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement", $$->getName());

        delete $1; delete $2; delete $4; delete $8;
    }
    | type_specifier ID LPAREN RPAREN { // compound_statement here

        handleFuncDefinition($1, $2);

    } compound_statement {

        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "()" + $6->getName()), "FUNC_DEFINITION");

        // print scopes and exit
        st->printAll(logOut);
        st->exitScope();

        yylog(logOut, lineNo, "func_definition", "type_specifier ID LPAREN RPAREN compound_statement", $$->getName());

        delete $1; delete $2; delete $6;
    }
    | type_specifier ID LPAREN error RPAREN { // compound_statement here

        handleFuncDefinition($1, $2);

    } compound_statement {

        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "()" + $7->getName()), "FUNC_DEFINITION");

        // print scopes and exit
        st->printAll(logOut);
        st->exitScope();

        yylog(logOut, lineNo, "func_definition", "type_specifier ID LPAREN RPAREN compound_statement", $$->getName());

        delete $1; delete $2; delete $7;
    }
    ;

parameter_list  : parameter_list COMMA type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName() + " "  + $4->getName()), "PARAMETER_LIST");

        handleParameterList($$, $1, $3, $4);

        delete $1; delete $3; delete $4;
    }
    | parameter_list error COMMA type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + "," + $4->getName() + " "  + $5->getName()), "PARAMETER_LIST");

        handleParameterList($$, $1, $4, $5);

        delete $1; delete $4; delete $5;
    }
    | parameter_list COMMA type_specifier {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName()), "PARAMETER_LIST");
        yylog(logOut, lineNo, "parameter_list", "parameter_list COMMA type_specifier", $$->getName());

        // adding the params
        $$->setParams($1->getParams());
        $$->addParam(new SymbolInfo("NOT DEFINED", $3->getName()));

        delete $1; delete $3;
    }
    | parameter_list error COMMA type_specifier {        
        $$ = new SymbolInfo(($1->getName() + "," + $4->getName()), "PARAMETER_LIST");
        yylog(logOut, lineNo, "parameter_list", "parameter_list COMMA type_specifier", $$->getName());

        // adding the params
        $$->setParams($1->getParams());
        $$->addParam(new SymbolInfo("NOT DEFINED", $4->getName()));

        delete $1; delete $4;
    }
    | type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName()), "PARAMETER_LIST");
        yylog(logOut, lineNo, "parameter_list", "type_specifier ID", $$->getName());

        // adding the params
        $$->addParam(new SymbolInfo($2->getName(), $1->getName()));

        delete $1; delete $2;
    }
    | type_specifier {
        $$ = new SymbolInfo(($1->getName()), "PARAMETER_LIST");
        yylog(logOut, lineNo, "parameter_list", "type_specifier", $$->getName());

        // adding the params
        $$->addParam(new SymbolInfo("NOT DEFINED", $1->getName()));

        delete $1;
    }
    ;

compound_statement : LCURL statements RCURL {
        $$ = new SymbolInfo(("{\n" + $2->getName() + "}\n"), "COMPOUND_STATEMENT");
        yylog(logOut, lineNo, "compound_statement", "LCURL statements RCURL", $$->getName());

        delete $2;
    }
    | LCURL RCURL {
        $$ = new SymbolInfo("{}\n", "COMPOUND_STATEMENT");
        yylog(logOut, lineNo, "compound_statement", "LCURL RCURL", $$->getName());
    }
    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + ";"), "VAR_DECLARATION");
        handleVarDeclaration($$, $1, $2);        
        delete $1; delete $2;
    }
    | type_specifier declaration_list error SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + ";"), "VAR_DECLARATION");
        handleVarDeclaration($$, $1, $2);
        delete $1; delete $2;
    }
    ;
 		 
type_specifier : INT {
        $$ = new SymbolInfo("int", "TYPE_SPECIFIER");
        yylog(logOut, lineNo, "type_specifier", "INT", $$->getName());
    }
    | FLOAT {
        $$ = new SymbolInfo("float", "TYPE_SPECIFIER");
        yylog(logOut, lineNo, "type_specifier", "FLOAT", $$->getName());
    }
    | VOID {
        $$ = new SymbolInfo("void", "TYPE_SPECIFIER");
        yylog(logOut, lineNo, "type_specifier", "VOID", $$->getName());
    }
    ;
 		
declaration_list : declaration_list COMMA ID {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName()), "DECLARATION_LIST");
        handleDeclarationList($$, $1, $3);
        delete $1; delete $3;
    }
    | declaration_list error COMMA ID {
        $$ = new SymbolInfo(($1->getName() + "," + $4->getName()), "DECLARATION_LIST");
        handleDeclarationList($$, $1, $4);
        delete $1; delete $4;
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName() + "[" + $5->getName() + "]"), "DECLARATION_LIST");
        handleDeclarationList($$, $1, $3, $5);
        delete $1; delete $3; delete $5;
    }
    | declaration_list error COMMA ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "," + $4->getName() + "[" + $6->getName() + "]"), "DECLARATION_LIST");
        handleDeclarationList($$, $1, $4, $6);
        delete $1; delete $4; delete $6;
    }
    | ID {
        $$ = new SymbolInfo($1->getName(), "DECLARATION_LIST");

        // adding this id to declaration_list for assigning type later
        $$->addParam((new SymbolInfo())->copySymbol($1));

        yylog(logOut, lineNo, "declaration_list", "ID", $$->getName());

        delete $1;
    }
    | ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "DECLARATION_LIST");

        // adding this array to declaration_list for assiginng type later
        $$->addParam((new SymbolInfo())->copySymbol($1)->setArraySize(stoi($3->getName())));

        yylog(logOut, lineNo, "declaration_list", "ID LTHIRD CONST_INT RTHIRD", $$->getName());

        delete $1; delete $3;
    }
    ;
 		  
statements : statement {
        $$ = $1;
        yylog(logOut, lineNo, "statements", "statement", $$->getName());
    }
    | statements statement {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), "STATEMENTS");
        yylog(logOut, lineNo, "statements", "statements statement", $$->getName());

        delete $1; delete $2;
    }
    | statements error {
        $$ = new SymbolInfo(($1->getName()), "STATEMENTS");
        // yylog(logOut, lineNo, "statements", "statements statement", $$->getName());
        logOut << $$->getName() << endl << endl;

        delete $1;
    }
    ;
	   
statement : var_declaration {
        $$ = new SymbolInfo(($1->getName() + "\n"), "STATEMENT");
        yylog(logOut, lineNo, "statement", "var_declaration", $$->getName());

        delete $1;
    }
    | expression_statement {
        $$ = new SymbolInfo(($1->getName() + "\n"), "STATEMENT");
        yylog(logOut, lineNo, "statement", "expression_statement", $$->getName());

        delete $1;
    }
    | func_declaration {
        $$ = $1;
        yyerror("Function declaration is only allowed in the global scope");
        yylog(logOut, lineNo, "statement", "func_declaration", $$->getName());
    }
    | func_definition {
        $$ = $1;
        yyerror("Function definition is only allowed in the global scope");
        yylog(logOut, lineNo, "statement", "func_definition", $$->getName());
    }
    | {st->enterScope();} compound_statement {
        $$ = new SymbolInfo(($2->getName()), "STATEMENT");

        // print scopes and exit
        st->printAll(logOut);
        st->exitScope();

        yylog(logOut, lineNo, "statement", "compound_statement", $$->getName());

        delete $2;
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
        $$ = new SymbolInfo(("for(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName()), "FOR_LOOP");
        yylog(logOut, lineNo, "statement", "FOR LPAREN expression_statement expression_statement expression RPAREN statement", $$->getName());

        delete $3; delete $4; delete $5; delete $7;
    }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
        $$ = new SymbolInfo(("if (" + $3->getName() + ")" + $5->getName()), "IF");
        yylog(logOut, lineNo, "statement", "IF LPAREN expression RPAREN statement", $$->getName());

        delete $3; delete $5;
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        $$ = new SymbolInfo(("if (" + $3->getName() + ")" + $5->getName() + "else\n" + $7->getName()), "IF_ELSE");
        yylog(logOut, lineNo, "statement", "IF LPAREN expression RPAREN statement ELSE statement", $$->getName());

        delete $3; delete $5; delete $7;
    }
    | WHILE LPAREN expression RPAREN statement {
        $$ = new SymbolInfo(("while (" + $3->getName() + ")" + $5->getName()), "WHILE_LOOP");
        yylog(logOut, lineNo, "statement", "WHILE LPAREN expression RPAREN statement", $$->getName());

        delete $3; delete $5;
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        $$ = new SymbolInfo(("printf(" + $3->getName() + ");\n"), "PRINT_STATEMENT");

        if (st->lookup($3->getName()) == nullptr) {
            yyerror(("Undeclared variable " + $3->getName()).c_str());
        }
        
        yylog(logOut, lineNo, "statement", "PRINTLN LPAREN ID RPAREN SEMICOLON", $$->getName());

        delete $3;
    }
    | RETURN expression SEMICOLON {
        $$ = new SymbolInfo(("return " + $2->getName() + ";\n"), "RETURN_STATEMENT");
        yylog(logOut, lineNo, "statement", "RETURN expression SEMICOLON", $$->getName());

        delete $2;
    }
    // | error {
    //     $$ = new SymbolInfo("", "STATEMENT");
    // }
    ;
	  
expression_statement : SEMICOLON {
        $$ = new SymbolInfo(";", "EXPRESSION_STATEMENT");
        yylog(logOut, lineNo, "expression_statement", "SEMICOLON", $$->getName());
    }
    | expression SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + ";"), "EXPRESSION_STATEMENT");
        yylog(logOut, lineNo, "expression_statement", "expression SEMICOLON", $$->getName());

        delete $1;
    }
    ;

variable : ID {
        $$ = $1;
        
        // check if variable is declared
        SymbolInfo* previous = st->lookup($1->getName());
        if (previous != nullptr) {
            $$->setType(previous->getType());
            if (previous->isVariable() == true) {
                // all is well
            } else {
                yyerror(("Type mismatch, " + $1->getName() + " is not a variable").c_str());
            }
        } else {
            $$->setType("UNDEFINED");
            yyerror(("Undeclared variable " + $1->getName()).c_str());
        }
        yylog(logOut, lineNo, "variable", "ID", $$->getName());
    } 		
    | ID LTHIRD expression RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "ARRAY");

        // check if array is declared
        SymbolInfo* previous = st->lookup($1->getName());
        if (previous != nullptr) {
            $$->setType(previous->getType());
            if (previous->isArray() == true) {
                // all is well
            } else {
                yyerror(("Type mismatch, " + $1->getName() + " is not an array").c_str());
            }
        } else {
            $$->setType("UNDEFINED");
            yyerror(("Undeclared array " + $1->getName()).c_str());
        }

        // check if expression is INT
        if ($3->getType() != "CONST_INT") {
            if (st->lookup($3->getName()) == nullptr) {
                if ($3->getType() != "int") {
                    yyerror("Expression inside third brackets not an integer");
                }
            } else {
                if (st->lookup($3->getName())->getType() != "int") {
                    yyerror("Expression inside third brackets not an integer");
                } else {
                    // all is well
                }
            }
        } else {
            // all is well
        }
        
        // check if expression is within bounds of array

        yylog(logOut, lineNo, "variable", "ID LTHIRD expression RTHIRD", $$->getName());

        delete $1; delete $3;
    }
    ;
	 
expression : logic_expression {
        $$ = $1;
        yylog(logOut, lineNo, "expression", "logic_expression", $$->getName());
    }	
    | variable ASSIGNOP logic_expression {
        $$ = new SymbolInfo(($1->getName() + "=" + $3->getName()), $3->getType());
        yylog(logOut, lineNo, "expression", "variable ASSIGNOP logic_expression", $$->getName());

        // check for type mismatch
        // if (typeMatch($1->getType(), $3->getType())) {
        //     // all is well
        // } else {
        //     yyerror("Type mismatch");
        // }
        // c++17 features - auto, tuple
        auto [success, changedSymbol] = typeCast($1->getType(), $3->getType());
        if (success) {
            // all is well
            $$->setType(changedSymbol->getType());
        } else {
            yyerror("Type mismatch");
            $$->setType("UNDEFINED");
        }

        delete $1; delete $3;
    }
    ;
			
logic_expression : rel_expression {
        $$ = $1;
        yylog(logOut, lineNo, "logic_expression", "rel_expression", $$->getName());
    } 	
    | rel_expression LOGICOP rel_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "int");
        yylog(logOut, lineNo, "logic_expression", "rel_expression LOGICOP rel_expression", $$->getName());

        // check if both of them are int or not
        if (isInt($1->getType()) && isInt($3->getType())) {
            // all is well
        } else {
            yyerror("Type mismatch - LOGICOP expects int");
            $$->setType("UNDEFINED");
        }

        delete $1; delete $2; delete $3;
    }
    ;
			
rel_expression : simple_expression {
        $$ = $1;
        yylog(logOut, lineNo, "rel_expression", "simple_expression", $$->getName());
    }
    | simple_expression RELOP simple_expression	{
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "int");
        yylog(logOut, lineNo, "rel_expression", "simple_expression RELOP simple_expression", $$->getName());

        // check if any of them are void
        if ($1->getType() == "void" || $3->getType() == "void") {
            yyerror("Type mismatch - RELOP expects int");
            $$->setType("UNDEFINED");
        } else {
           // all is well
        }

        delete $1; delete $2; delete $3;
    }
    ;
				
simple_expression : term {
        $$ = $1;
        yylog(logOut, lineNo, "simple_expression", "term", $$->getName());
    }
    | simple_expression ADDOP term {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $3->getType());
        yylog(logOut, lineNo, "simple_expression", "simple_expression ADDOP term", $$->getName());

        // type cast
        auto [success, changedSymbol] = implicitTypeCast($1->getType(), $3->getType());
        if (success) {
            // all is well
            $$->setType(changedSymbol->getType());
        } else {
            yyerror("Type mismatch - void cannot be an operand of ADDOP");
            $$->setType("UNDEFINED");
        }

        delete $1; delete $2; delete $3;
    }
    ;
					
term :	unary_expression {
        $$ = $1;
        yylog(logOut, lineNo, "term", "unary_expression", $$->getName());
    }
    | term MULOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $3->getType());
        yylog(logOut, lineNo, "term", "term MULOP unary_expression", $$->getName());

        // check for non-integers in modulus
        if ($2->getName() == "%") {
            if (typeMatch("int", $1->getType()) && typeMatch("int", $3->getType())) {
                // all is well
            } else {
                yyerror("Non-Integer operand on modulus operator");
                $$->setType("UNDEFINED");
            }
        } else {
            // type cast
            auto [success, changedSymbol] = implicitTypeCast($1->getType(), $3->getType());
            if (success) {
                // all is well
                $$->setType(changedSymbol->getType());
            } else {
                yyerror("Type mismatch - void cannot be an operand of MULOP");
                $$->setType("UNDEFINED");
            }
        }

        // check for divide by zero
        if ($2->getName() == "/" || $2->getName() == "%") {
            if ($3->getType() == "CONST_INT" && $3->getName() == "0") {
                yyerror("Divide by zero");
                $$->setType("UNDEFINED");
            } // how to check for expressions evaluating into 0? later
        }

        delete $1; delete $2; delete $3;
    }
    ;

unary_expression : ADDOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), $2->getType());
        yylog(logOut, lineNo, "unary_expression", "ADDOP unary_expression", $$->getName());

        delete $1; delete $2;
    } 
    | NOT unary_expression {
        $$ = new SymbolInfo(("!" + $2->getName()), $2->getType());
        yylog(logOut, lineNo, "unary_expression", "NOT unary_expression", $$->getName());

        delete $2;
    }
    | factor {
        $$ = $1;
        yylog(logOut, lineNo, "unary_expression", "factor", $$->getName());
    }
    ;
	
factor : variable {
        $$ = $1;
        yylog(logOut, lineNo, "factor", "variable", $$->getName());
    }
	| ID LPAREN argument_list RPAREN {
        $$ = new SymbolInfo(($1->getName() + "(" + $3->getName() + ")"), "FUNCTION_CALL");        

        // check if function is declared
        // assign the return type of function to this factor's type
        SymbolInfo* previous = st->lookup($1->getName());
        if (previous == nullptr) {
            $$->setType("UNDEFINED");
            yyerror(("Undeclared function " + $1->getName()).c_str());
        } else {
            if (previous->isFunction()) {
                if (previous->getParams().size() > 0) {
                    // check if number of arguments matches
                    if ((previous->getParams().size() - 1) != $3->getParams().size()) {
                        yyerror(("Total number of arguments mismatch in function " + $1->getName()).c_str());
                    } else {
                        // check if types of arguments and parameters match
                        for (int i = 1; i < previous->getParams().size(); i++) {
                            
                            if (typeMatch(previous->getParams()[i]->getType(), $3->getParams()[i-1]->getType())) {
                                // last iteration
                                if (i == (previous->getParams().size() - 1)) {
                                    // all is well
                                    calledFunctions.push_back(make_pair($1->getName(), lineNo));
                                }
                            } else {
                                yyerror((to_string(i) + "th argument mismatch in function " + $1->getName()).c_str());
                                // according to sample log
                                // no need to look further if you got one mismatch
                                break;
                            }
                        }
                    }
                    // set previous's return type to it's type
                    if (previous->getReturnType()->getType() == "void") {
                        $$->setType("UNDEFINED");
                        yyerror("Void function used in expression");
                    } else {
                        $$->setType(previous->getReturnType()->getType());
                    }
                } else {
                    $$->setType("UNDEFINED");
                    yyerror(("Function " + $1->getName() + " has no return type / parameters declared").c_str());
                }
            } else {
                $$->setType("UNDEFINED");
                yyerror(("Type mismatch, " + $1->getName() + " is not a function").c_str());
            }
        }


        yylog(logOut, lineNo, "factor", "ID LPAREN argument_list RPAREN", $$->getName());

        delete $1; delete $3;
    }
	| LPAREN expression RPAREN {
        $$ = new SymbolInfo(("(" + $2->getName() + ")"), $2->getType());
        yylog(logOut, lineNo, "factor", "LPAREN expression RPAREN", $$->getName());

        delete $2;
    }
	| CONST_INT {
        $$ = $1;
        yylog(logOut, lineNo, "factor", "CONST_INT", $$->getName());
    }
	| CONST_FLOAT {
        $$ = new SymbolInfo(($1->getName() + "0"), "CONST_FLOAT"); // just to match the samples
        yylog(logOut, lineNo, "factor", "CONST_FLOAT", $$->getName());

        // why can't I delete this?
        // delete $1;
    }
	| variable INCOP {
        $$ = new SymbolInfo(($1->getName() + "++"), $1->getType());
        yylog(logOut, lineNo, "factor", "variable INCOP", $$->getName());

        delete $1;
    }
	| variable DECOP {
        $$ = new SymbolInfo(($1->getName() + "--"), $1->getType());
        yylog(logOut, lineNo, "factor", "variable DECOP", $$->getName());

        delete $1;
    }
	;
	
argument_list : arguments {
        $$ = $1;
        yylog(logOut, lineNo, "argument_list", "arguments", $$->getName());
    }
    | {
        $$ = new SymbolInfo("", "VOID");
        yylog(logOut, lineNo, "argument_list", "", $$->getName());
    }
    ;
	
arguments : arguments COMMA logic_expression {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName()), $3->getType());
        // argument_list should have arguments in it's params vector
        for (SymbolInfo* s : $1->getParams()) {
            $$->addParam((new SymbolInfo())->copySymbol(s));
        }
        $$->addParam((new SymbolInfo())->copySymbol($3));
        yylog(logOut, lineNo, "arguments", "arguments COMMA logic_expression", $$->getName());

        delete $1; delete $3;
    }
    | logic_expression {
        $$ = $1;
        $$->addParam($1);
        yylog(logOut, lineNo, "arguments", "logic_expression", $$->getName());
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

    st->printAll(logOut);
    logOut << "Total lines: " << lineNo << endl;
    logOut << "Total errors: " << errorNo << endl;

    logOut.close();
    errorOut.close();
	
    delete st;

	return 0;
}

