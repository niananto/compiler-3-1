%{
#include<bits/stdc++.h>
#include "includes/SymbolTable.h"
#include "includes/handleGrammers.h"
#include "includes/utils.h"
#include "includes/utilsForAsm.h"
using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

SymbolTable* st = new SymbolTable(30);
ofstream logOut;
ofstream errorOut;

ofstream codeOut;
ofstream dataOut;

extern unsigned long lineNo;
extern unsigned long errorNo;
unsigned labelCount = 0;
unsigned tempCount = 0;

string currentFunctionName = "";

// [what happens when we call a function which is declared not defined and then never really define it]
// to check if every declared only (not defined) functions are defined later if that function was called
// if the function was never called, then declaration with no definition later is not a problem
vector< pair <string, unsigned long> > calledFunctions; // only the valid function calls are stored here

void yyerror(const char *s) {
	logOut << "Error at line " << lineNo << ": " << s << endl << endl;
	errorOut << "Error at line " << lineNo << ": " << s << endl << endl;
    errorNo++;
}

string newLabel() {
	return ("L_" + to_string(labelCount++));
}

string newTemp() {
	return ("t" + to_string(tempCount++));
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
%type<symbol> term unary_expression factor argument_list arguments generate_if_block

%define parse.error verbose
%destructor{ delete $$; }<symbol>

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "start", "program", "");

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
        yylog(logOut, codeOut, lineNo, "program", "program unit", $$->getName());
        delete $1; delete $2;
    }
    | unit {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "program", "unit", $$->getName());
    }
    ;

unit : var_declaration {
        $$ = new SymbolInfo($1->getName() + "\n", "UNIT");
        yylog(logOut, codeOut, lineNo, "unit", "var_declaration", $$->getName());
        delete $1;
    }
    | func_declaration {
        $$ = new SymbolInfo($1->getName(), "UNIT");
        yylog(logOut, codeOut, lineNo, "unit", "func_declaration", $$->getName());
        delete $1;
    }
    | func_definition {
        $$ = new SymbolInfo($1->getName() + "\n", "UNIT");
        yylog(logOut, codeOut, lineNo, "unit", "func_definition", $$->getName());
        delete $1;
    }
    | error {
        $$ = new SymbolInfo("", "UNIT");
    }
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n"), "FUNC_DECLARATION");
        yylog(logOut, codeOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2, $4);
        initializeProcedure(codeOut, $2->getName(), st);

        delete $1; delete $2; delete $4;
    }
    | type_specifier ID LPAREN parameter_list error RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n"), "FUNC_DECLARATION");
        yylog(logOut, codeOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2, $4);

        delete $1; delete $2; delete $4;
    }
    | type_specifier ID LPAREN parameter_list RPAREN error {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n"), "FUNC_DECLARATION");
        yylog(logOut, codeOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2, $4);

        delete $1; delete $2; delete $4;
    }
    | type_specifier ID LPAREN parameter_list error RPAREN error {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n"), "FUNC_DECLARATION");
        yylog(logOut, codeOut, lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2, $4);

        delete $1; delete $2; delete $4;
    }
	| type_specifier ID LPAREN RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "();\n"), "FUNC_DECLARATION");
        yylog(logOut, codeOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2);
        initializeProcedure(codeOut, $2->getName(), st);

        delete $1; delete $2;
    }
    | type_specifier ID LPAREN RPAREN error {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "();\n"), "FUNC_DECLARATION");
        yylog(logOut, codeOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2);

        delete $1; delete $2;
    }| type_specifier ID LPAREN error RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "();\n"), "FUNC_DECLARATION");
        yylog(logOut, codeOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2);

        delete $1; delete $2;
    }| type_specifier ID LPAREN error RPAREN error {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "();\n"), "FUNC_DECLARATION");
        yylog(logOut, codeOut, lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());

        handleFuncDeclaration($1, $2);

        delete $1; delete $2;
    }
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN { // compound_statement here

        handleFuncDefinition($1, $2, $4);
        initializeProcedure(codeOut, $2->getName(), st);

    } compound_statement {

        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "(" + $4->getName() + ")" + $7->getName()), "FUNC_DEFINITION");
        
        // print scopes and exit
        st->printAll(logOut);
        st->exitScope();

        yylog(logOut, codeOut, lineNo, "func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement", $$->getName());

        terminateProcedure(codeOut, $2->getName(), $4->getParams().size());
        currentFunctionName = "";

        delete $1; delete $2; delete $4; delete $7;
    }
    | type_specifier ID LPAREN parameter_list error RPAREN { // compound_statement here

        handleFuncDefinition($1, $2, $4);

    } compound_statement {

        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "(" + $4->getName() + ")" + $8->getName()), "FUNC_DEFINITION");
        
        // print scopes and exit
        st->printAll(logOut);
        st->exitScope();

        yylog(logOut, codeOut, lineNo, "func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement", $$->getName());

        delete $1; delete $2; delete $4; delete $8;
    }
    | type_specifier ID LPAREN RPAREN { // compound_statement here

        handleFuncDefinition($1, $2);
        initializeProcedure(codeOut, $2->getName(), st);

    } compound_statement {

        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "()" + $6->getName()), "FUNC_DEFINITION");

        // print scopes and exit
        st->printAll(logOut);
        st->exitScope();

        yylog(logOut, codeOut, lineNo, "func_definition", "type_specifier ID LPAREN RPAREN compound_statement", $$->getName());

        terminateProcedure(codeOut, $2->getName(), 0);
        currentFunctionName = "";

        delete $1; delete $2; delete $6;
    }
    | type_specifier ID LPAREN error RPAREN { // compound_statement here

        handleFuncDefinition($1, $2);

    } compound_statement {

        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "()" + $7->getName()), "FUNC_DEFINITION");

        // print scopes and exit
        st->printAll(logOut);
        st->exitScope();

        yylog(logOut, codeOut, lineNo, "func_definition", "type_specifier ID LPAREN RPAREN compound_statement", $$->getName());

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
        yylog(logOut, codeOut, lineNo, "parameter_list", "parameter_list COMMA type_specifier", $$->getName());

        // adding the params
        $$->setParams($1->getParams());
        $$->addParam(new SymbolInfo("NOT DEFINED", $3->getName()));

        delete $1; delete $3;
    }
    | parameter_list error COMMA type_specifier {        
        $$ = new SymbolInfo(($1->getName() + "," + $4->getName()), "PARAMETER_LIST");
        yylog(logOut, codeOut, lineNo, "parameter_list", "parameter_list COMMA type_specifier", $$->getName());

        // adding the params
        $$->setParams($1->getParams());
        $$->addParam(new SymbolInfo("NOT DEFINED", $4->getName()));

        delete $1; delete $4;
    }
    | type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName()), "PARAMETER_LIST");
        yylog(logOut, codeOut, lineNo, "parameter_list", "type_specifier ID", $$->getName());

        // adding the params
        $$->addParam(new SymbolInfo($2->getName(), $1->getName()));

        delete $1; delete $2;
    }
    | type_specifier {
        $$ = new SymbolInfo(($1->getName()), "PARAMETER_LIST");
        yylog(logOut, codeOut, lineNo, "parameter_list", "type_specifier", $$->getName());

        // adding the params
        $$->addParam(new SymbolInfo("NOT DEFINED", $1->getName()));

        delete $1;
    }
    ;

compound_statement : LCURL statements RCURL {
        $$ = new SymbolInfo(("{\n" + $2->getName() + "}\n"), "COMPOUND_STATEMENT");
        yylog(logOut, codeOut, lineNo, "compound_statement", "LCURL statements RCURL", $$->getName());

        delete $2;
    }
    | LCURL RCURL {
        $$ = new SymbolInfo("{}\n", "COMPOUND_STATEMENT");
        yylog(logOut, codeOut, lineNo, "compound_statement", "LCURL RCURL", $$->getName());
    }
    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + ";"), "VAR_DECLARATION");
        handleVarDeclaration($$, $1, $2);

        for (auto param : $2->getParams()) {
            if (param->isArray()) {
                if (st->getScopeId() != "1") {
                    unsigned arrayOffsetEnd = st->getIdCount() * 2;
                    codeOut << "\t\tMOV SP, [BP+-" << arrayOffsetEnd << "] ;line no: " << lineNo 
                        << " pushed " << param->getName() << endl;
                } else {
                    declareGlobalArray(dataOut, param->getName(), param->getType(), param->getArraySize());
                }
            } else {
                if (st->getScopeId() != "1") {
                    codeOut << "\t\tPUSH BX ;line no: " << lineNo << " pushed " << param->getName() << endl;
                } else {
                    declareGlobalVariable(dataOut, param->getName(), param->getType());
                }
            }
        }

        delete $1; delete $2;
    }
    | type_specifier declaration_list error SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + ";"), "VAR_DECLARATION");
        handleVarDeclaration($$, $1, $2);

        for (auto param : $2->getParams()) {
            if (param->isArray()) {
                unsigned arrayOffsetEnd = st->getIdCount() * 2;
                codeOut << "\t\tMOV SP, [BP+-" << arrayOffsetEnd << "] ;line no: " << lineNo 
                    << " pushed " << param->getName() << endl;
            } else {
                codeOut << "\t\tPUSH BX ;line no: " << lineNo << " pushed " << param->getName() << endl;
            }
        }

        delete $1; delete $2;
    }
    ;
 		 
type_specifier : INT {
        $$ = new SymbolInfo("int", "TYPE_SPECIFIER");
        yylog(logOut, codeOut, lineNo, "type_specifier", "INT", $$->getName());
    }
    | FLOAT {
        $$ = new SymbolInfo("float", "TYPE_SPECIFIER");
        yylog(logOut, codeOut, lineNo, "type_specifier", "FLOAT", $$->getName());
    }
    | VOID {
        $$ = new SymbolInfo("void", "TYPE_SPECIFIER");
        yylog(logOut, codeOut, lineNo, "type_specifier", "VOID", $$->getName());
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
        yylog(logOut, codeOut, lineNo, "declaration_list", "ID", $$->getName());

        delete $1;
    }
    | ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "DECLARATION_LIST");
        // adding this array to declaration_list for assiginng type later
        $$->addParam((new SymbolInfo())->copySymbol($1)->setArraySize(stoi($3->getName())));
        yylog(logOut, codeOut, lineNo, "declaration_list", "ID LTHIRD CONST_INT RTHIRD", $$->getName());

        delete $1; delete $3;
    }
    ;
 		  
statements : statement {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "statements", "statement", $$->getName());
    }
    | statements statement {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), "STATEMENTS");
        yylog(logOut, codeOut, lineNo, "statements", "statements statement", $$->getName());

        delete $1; delete $2;
    }
    | statements error {
        $$ = new SymbolInfo(($1->getName()), "STATEMENTS");
        // yylog(logOut, codeOut, lineNo, "statements", "statements statement", $$->getName());
        logOut << $$->getName() << endl << endl;

        delete $1;
    }
    ;
	   
generate_if_block : {
        string labelElse = newLabel();
        string labelElseBypass = newLabel();
        $$ = new SymbolInfo(labelElse, "LABEL");

        codeOut << endl;
        codeOut << "\t\tPOP AX ;line no: " << lineNo << endl;
        codeOut << "\t\tCMP AX, 0 ;line no: " << lineNo << endl;
        codeOut << "\t\tJNE " + labelElseBypass + " ;line no: " << lineNo << endl;
        codeOut << "\t\tJMP " + labelElse + " ;line no: " << lineNo << endl;
        codeOut << "\t\t" + labelElseBypass + ": ;line no: " << lineNo << endl;
    }

statement : var_declaration {
        $$ = new SymbolInfo(($1->getName() + "\n"), "STATEMENT");
        yylog(logOut, codeOut, lineNo, "statement", "var_declaration", $$->getName());

        delete $1;
    }
    | expression_statement {
        $$ = new SymbolInfo(($1->getName() + "\n"), "STATEMENT");
        yylog(logOut, codeOut, lineNo, "statement", "expression_statement", $$->getName());

        delete $1;
    }
    | func_declaration {
        $$ = $1;
        yyerror("Function declaration is only allowed in the global scope");
        yylog(logOut, codeOut, lineNo, "statement", "func_declaration", $$->getName());
    }
    | func_definition {
        $$ = $1;
        yyerror("Function definition is only allowed in the global scope");
        yylog(logOut, codeOut, lineNo, "statement", "func_definition", $$->getName());
    }
    | {st->enterScope();} compound_statement {
        $$ = new SymbolInfo(($2->getName()), "STATEMENT");

        // print scopes and exit
        st->printAll(logOut);
        st->exitScope();

        yylog(logOut, codeOut, lineNo, "statement", "compound_statement", $$->getName());

        delete $2;
    }
    | FOR LPAREN expression_statement {






        // eta kora lagbe







        string labelFor = newLabel();
        // codeOut << endl;
        // codeOut << labelFor << ": ;line no: " << lineNo << endl;
    } expression_statement {
        string labelEnd = newLabel();
        string labelContinue = newLabel();
        // codeOut << "\t\tCMP AX, 0 ;line no: " << lineNo << endl;
        // codeOut << "\t\tJNE " << labelContinue << " ;line no: " << lineNo << endl;
        // codeOut << "\t\tJMP " << labelEnd << " ;line no: " << lineNo << endl;
        // codeOut << labelContinue << ": ;line no: " << lineNo << endl;
    } {

    } expression {
        
    } RPAREN statement {
        $$ = new SymbolInfo(("for(" + $3->getName() + $5->getName() + $8->getName() + ")" + $11->getName()), "FOR_LOOP");
        yylog(logOut, codeOut, lineNo, "statement", "FOR LPAREN expression_statement expression_statement expression RPAREN statement", $$->getName());

        delete $3; delete $5; delete $8; delete $11;
    }
    | IF LPAREN expression RPAREN generate_if_block statement %prec LOWER_THAN_ELSE {
        $$ = new SymbolInfo(("if (" + $3->getName() + ")" + $6->getName()), "IF");
        yylog(logOut, codeOut, lineNo, "statement", "IF LPAREN expression RPAREN statement", $$->getName());

        codeOut << "\t\t" + $5->getName() + ": ;line no: " << lineNo << endl;

        delete $3; delete $5; delete $6;
    }
    | IF LPAREN expression RPAREN generate_if_block statement ELSE {
        string labelEnd = newLabel();
        codeOut << "\t\tJMP " << labelEnd << " ;line no: " << lineNo << endl;
        codeOut << "\t\t" << $5->getName() << ": ;line no: " << lineNo << endl;

        $<symbol>$ = new SymbolInfo(labelEnd, "LABEL");
    } statement {
        $$ = new SymbolInfo(("if (" + $3->getName() + ")" + $6->getName() + "else\n" + $9->getName()), "IF_ELSE");
        yylog(logOut, codeOut, lineNo, "statement", "IF LPAREN expression RPAREN statement ELSE statement", $$->getName());

        codeOut << "\t\t" + $<symbol>8->getName() + ": ;line no: " << lineNo << endl;

        delete $3; delete $5; delete $6; delete $9;
        delete $<symbol>8;
    }
    | WHILE {
        string labelWhile = newLabel();
        $<symbol>$ = new SymbolInfo(labelWhile, "LABEL");
        codeOut << "\t\t" + labelWhile + ": ;line no: " << lineNo << endl;
    } LPAREN expression {
        string labelEnd = newLabel();
        string labelEndBypass = newLabel();
        $<symbol>$ = new SymbolInfo(labelEnd, "LABEL");

        codeOut << "\t\tPOP AX ;line no: " << lineNo << endl;
        codeOut << "\t\tCMP AX, 0 ;line no: " << lineNo << endl;
        codeOut << "\t\tJNE " << labelEndBypass << " ;line no: " << lineNo << endl;
        codeOut << "\t\tJMP " << labelEnd << " ;line no: " << lineNo << endl;
        codeOut << "\t\t" << labelEndBypass << ": ;line no: " << lineNo << endl;
    } RPAREN statement {
        $$ = new SymbolInfo(("while (" + $4->getName() + ")" + $7->getName()), "WHILE_LOOP");
        yylog(logOut, codeOut, lineNo, "statement", "WHILE LPAREN expression RPAREN statement", $$->getName());

        string labelWhile = $<symbol>2->getName();
        string labelEnd = $<symbol>5->getName();
        codeOut << "\t\tJMP " << labelWhile << " ;line no: " << lineNo << endl;
        codeOut << "\t\t" << labelEnd << ": ;line no: " << lineNo << endl;

        delete $4; delete $7;
        delete $<symbol>2; delete $<symbol>5;
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        $$ = new SymbolInfo(("printf(" + $3->getName() + ");\n"), "PRINT_STATEMENT");

        SymbolInfo* previous = st->lookup($3->getName());
        if (previous == nullptr) {
            yyerror(("Undeclared variable " + $3->getName()).c_str());
        }
        
        yylog(logOut, codeOut, lineNo, "statement", "PRINTLN LPAREN ID RPAREN SEMICOLON", $$->getName());

        codeOut << endl;
        if (previous->getOffset() != -1) {
            // codeOut << "\t\tPUSH [BP+" << previous->getOffset() << "] ;line no: " << lineNo << endl;
            codeOut << "\t\tPUSH [BP+-" << previous->getOffset() << "] ;line no: " << lineNo << endl;
        } else {
            codeOut << "\t\tPUSH " << $3->getName() << " ;line no: " << lineNo << endl;
        }
        codeOut << "\t\tCALL PRINT_INTEGER ;line no: " << lineNo << endl;
        codeOut << endl;

        delete $3;
    }
    | RETURN expression SEMICOLON {
        $$ = new SymbolInfo(("return " + $2->getName() + ";\n"), "RETURN_STATEMENT");
        yylog(logOut, codeOut, lineNo, "statement", "RETURN expression SEMICOLON", $$->getName());

        codeOut << endl;
        codeOut << "\t\tPOP AX ;line no: " << lineNo << endl;
        if (currentFunctionName == "main") {
            // terminate main
        } else {
            unsigned temp = st->lookup(currentFunctionName)->getParams().size();
            unsigned paramsCount = (temp > 0) ? temp-1 : 0;

            codeOut << "\t\tMOV SP, BP ;Restoring SP at the end of function" << endl;
            codeOut << "\t\tPOP BP ;Restoring BP at the end of function" << endl;
            codeOut << "\t\tRET " + (paramsCount ? to_string(paramsCount*2) : "") << endl;
        }

        delete $2;
    }
    // | error {
    //     $$ = new SymbolInfo("", "STATEMENT");
    // }
    ;
	  
expression_statement : SEMICOLON {
        $$ = new SymbolInfo(";", "EXPRESSION_STATEMENT");
        yylog(logOut, codeOut, lineNo, "expression_statement", "SEMICOLON", $$->getName());
    }
    | expression SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + ";"), "EXPRESSION_STATEMENT");
        yylog(logOut, codeOut, lineNo, "expression_statement", "expression SEMICOLON", $$->getName());

        codeOut << endl << "\t\tPOP AX ;line no " << lineNo << endl << endl;

        delete $1;
    }
    ;

variable : ID {        
        $$ = $1;

        // check if variable is declared
        SymbolInfo* previous = st->lookup($1->getName());
        if (previous != nullptr) {
            $$ = (new SymbolInfo())->copySymbol(previous);
            if (previous->isVariable() == true) {
                // all is well
            } else {
                yyerror(("Type mismatch, " + $1->getName() + " is not a variable").c_str());
            }
        } else {
            // $$ = $1;
            $$->setType("UNDEFINED");
            yyerror(("Undeclared variable " + $1->getName()).c_str());
        }
        yylog(logOut, codeOut, lineNo, "variable", "ID", $$->getName());

        if (previous != nullptr && previous->isVariable() == true) {
            codeOut << endl;
            if (previous->getOffset() == -1) {
                codeOut << "\t\tPUSH " << $1->getName() << " ;line no: " << lineNo << endl;
            } else {
                // codeOut << "\t\tPUSH [BP+" << previous->getOffset() << "] ;line no: " << lineNo << endl;
                codeOut << "\t\tPUSH [BP+-" << previous->getOffset() << "] ;line no: " << lineNo << endl;
            }
        }
    } 		
    | ID LTHIRD expression RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "VARIABLE");

        // check if array is declared
        SymbolInfo* previous = st->lookup($1->getName());
        if (previous != nullptr) {
            if (previous->isArray() == true) {
                // all is well
            } else {
                yyerror(("Type mismatch, " + $1->getName() + " is not an array").c_str());
            }
            $$ = previous;

        } else {
            yyerror(("Undeclared array " + $1->getName()).c_str());
            $$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "UNDEFINED");
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

        yylog(logOut, codeOut, lineNo, "variable", "ID LTHIRD expression RTHIRD", $$->getName());

        if (previous != nullptr) {
            codeOut << endl;
            codeOut << "\t\tPOP BX ;line no: " << lineNo << endl;
            codeOut << "\t\tSHL BX, 1 ;line no: " << lineNo << endl;
            if (previous->getOffset() != -1) {
                if (previous->getOffset() < 0) {
                    codeOut << "\t\tNEG BX ;line no: " << lineNo << " offset is negative" << endl;
                }
                codeOut << "\t\tADD BX, " << previous->getOffset() << " ;line no: " << lineNo << endl;
                codeOut << "\t\tADD BX, BP ;line no: " << lineNo << endl;
                codeOut << "\t\tMOV AX, [BX] ;line no: " << lineNo << endl;
            } else {
                codeOut << "\t\tMOV AX, " + $1->getName() + "[BX] ;line no: " << lineNo << endl;
            }
            codeOut << "\t\tPUSH AX ;line no: " << lineNo << endl;
            codeOut << "\t\tPUSH BX ;line no: " << lineNo << endl;
            codeOut << endl;
        }
        

        delete $1; delete $3;
    }
    ;
	 
expression : logic_expression {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "expression", "logic_expression", $$->getName());
    }	
    | variable ASSIGNOP logic_expression {
        $$ = new SymbolInfo(($1->getName() + "=" + $3->getName()), $3->getType());
        yylog(logOut, codeOut, lineNo, "expression", "variable ASSIGNOP logic_expression", $$->getName());

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

        codeOut << endl;
        codeOut << "\t\tPOP AX ;line no: " << lineNo << endl;
        if ($1->isArray()) {
            codeOut << "\t\tPOP BX ;line no: " << lineNo << endl;
        }
        if ($1->getOffset() == -1) {
            if ($1->isArray()) {
                codeOut << "\t\tMOV " + $1->getName() + "[BX], AX ;line no: " << lineNo << endl;
            } else {
                codeOut << "\t\tMOV " << $1->getName() << ", AX ;line no: " << lineNo << endl;
            }
        } else {
            if ($1->isArray()) {
                codeOut << "\t\tMOV [BX], AX ;line no: " << lineNo << endl;
            } else {
                // codeOut << "\t\tMOV [BP+" << $1->getOffset() << "], AX ;line no: " << lineNo << endl;
                codeOut << "\t\tMOV [BP+-" << $1->getOffset() << "], AX ;line no: " << lineNo << endl;
            }
        }
        codeOut << endl;

        delete $1; delete $3;
    }
    ;
			
logic_expression : rel_expression {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "logic_expression", "rel_expression", $$->getName());
    } 	
    | rel_expression LOGICOP rel_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "int");
        yylog(logOut, codeOut, lineNo, "logic_expression", "rel_expression LOGICOP rel_expression", $$->getName());

        // check if both of them are int or not
        if (isInt($1->getType()) && isInt($3->getType())) {
            // all is well
        } else {
            yyerror("Type mismatch - LOGICOP expects int");
            $$->setType("UNDEFINED");
        }

        if($2->getName() == "&&") {
            string labelLeftTrue = newLabel();
            string labelTrue = newLabel();
            string labelEnd = newLabel();

            codeOut << "\t\tPOP BX ;line no: " << lineNo << endl;
            codeOut << "\t\tPOP AX ;line no: " << lineNo << endl;
            codeOut << "\t\tCMP AX, 0 ;line no: " << lineNo << endl;
            codeOut << "\t\tJNE " << labelLeftTrue << " ;line no: " << lineNo << endl;
            codeOut << "\t\tPUSH 0 ;line no: " << lineNo << endl;
            codeOut << "\t\tJMP " << labelEnd << " ;line no: " << lineNo << endl;
            codeOut << "\t\t" << labelLeftTrue << ": ;line no: " << lineNo << endl;
            codeOut << "\t\tCMP BX, 0 ;line no: " << lineNo << endl;
            codeOut << "\t\tJNE " << labelTrue << " ;line no: " << lineNo << endl;
            codeOut << "\t\tPUSH 0 ;line no: " << lineNo << endl;
            codeOut << "\t\tJMP " << labelEnd << " ;line no: " << lineNo << endl;
            codeOut << "\t\t" << labelTrue << ": ;line no: " << lineNo << endl;
            codeOut << "\t\tPUSH 1 ;line no: " << lineNo << endl;
            codeOut << "\t\t" << labelEnd << ": ;line no: " << lineNo << endl;
        } else { // "||"
            string labelLeftFalse = newLabel();
            string labelFalse = newLabel();
            string labelEnd = newLabel();

            codeOut << "\t\tPOP BX ;line no: " << lineNo << endl;
            codeOut << "\t\tPOP AX ;line no: " << lineNo << endl;
            codeOut << "\t\tCMP AX, 0 ;line no: " << lineNo << endl;
            codeOut << "\t\tJE " << labelLeftFalse << " ;line no: " << lineNo << endl;
            codeOut << "\t\tPUSH 1 ;line no: " << lineNo << endl;
            codeOut << "\t\tJMP " << labelEnd << " ;line no: " << lineNo << endl;
            codeOut << "\t\t" << labelLeftFalse << ": ;line no: " << lineNo << endl;
            codeOut << "\t\tCMP BX, 0 ;line no: " << lineNo << endl;
            codeOut << "\t\tJE " << labelFalse << " ;line no: " << lineNo << endl;
            codeOut << "\t\tPUSH 1 ;line no: " << lineNo << endl;
            codeOut << "\t\tJMP " << labelEnd << " ;line no: " << lineNo << endl;
            codeOut << "\t\t" << labelFalse << ": ;line no: " << lineNo << endl;
            codeOut << "\t\tPUSH 0 ;line no: " << lineNo << endl;
            codeOut << "\t\t" << labelEnd << ": ;line no: " << lineNo << endl;
        }

        delete $1; delete $2; delete $3;
    }
    ;
			
rel_expression : simple_expression {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "rel_expression", "simple_expression", $$->getName());
    }
    | simple_expression RELOP simple_expression	{
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "int");
        yylog(logOut, codeOut, lineNo, "rel_expression", "simple_expression RELOP simple_expression", $$->getName());

        // check if any of them are void
        if ($1->getType() == "void" || $3->getType() == "void") {
            yyerror("Type mismatch - RELOP expects int");
            $$->setType("UNDEFINED");
        } else {
           // all is well
        }

        string labelIfTrue = newLabel();
        string labelEnd = newLabel();

        codeOut << endl;
        codeOut << "\t\tPOP BX" << " ;line no: " << lineNo << endl;
        codeOut << "\t\tPOP AX" << " ;line no: " << lineNo << endl;
        codeOut << "\t\tCMP AX, BX" << " ;line no: " << lineNo << endl;

        if($2->getName() == "==")
            codeOut << "\t\tJE " << labelIfTrue << " ;line no: " << lineNo << endl;
        else if($2->getName() == "!=")
            codeOut << "\t\tJNE " << labelIfTrue << " ;line no: " << lineNo << endl;
        else if($2->getName() == "<")
            codeOut << "\t\tJL " << labelIfTrue << " ;line no: " << lineNo << endl;
        else if($2->getName() == "<=")
            codeOut << "\t\tJLE " << labelIfTrue << " ;line no: " << lineNo << endl;
        else if($2->getName() == ">")
            codeOut << "\t\tJG " << labelIfTrue << " ;line no: " << lineNo << endl;
        else if($2->getName() == ">=")
            codeOut << "\t\tJGE " << labelIfTrue << " ;line no: " << lineNo << endl;
        
        codeOut << "\t\tPUSH 0" << " ;line no: " << lineNo << endl;
        codeOut << "\t\tJMP " << labelEnd << " ;line no: " << lineNo << endl;
        codeOut << labelIfTrue << ":" << endl;
        codeOut << "\t\tPUSH 1" << " ;line no: " << lineNo << endl;
        codeOut << labelEnd << ":" << endl;
        codeOut << endl;

        delete $1; delete $2; delete $3;
    }
    ;
				
simple_expression : term {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "simple_expression", "term", $$->getName());
    }
    | simple_expression ADDOP term {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $3->getType());
        yylog(logOut, codeOut, lineNo, "simple_expression", "simple_expression ADDOP term", $$->getName());

        // type cast
        auto [success, changedSymbol] = implicitTypeCast($1->getType(), $3->getType());
        if (success) {
            // all is well
            $$->setType(changedSymbol->getType());
        } else {
            yyerror("Type mismatch - void cannot be an operand of ADDOP");
            $$->setType("UNDEFINED");
        }

        codeOut << endl;
        codeOut << "\t\tPOP BX" << " ;line no: " << lineNo << endl;
        codeOut << "\t\tPOP AX" << " ;line no: " << lineNo << endl;
        codeOut << "\t\t" << ($2->getName() == "+" ? "ADD" : "SUB") << " AX, BX" << " ;line no: " << lineNo << endl;
        codeOut << "\t\tPUSH AX" << " ;line no: " << lineNo << endl;
        codeOut << endl;

        delete $1; delete $2; delete $3;
    }
    ;
					
term :	unary_expression {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "term", "unary_expression", $$->getName());
    }
    | term MULOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $3->getType());
        yylog(logOut, codeOut, lineNo, "term", "term MULOP unary_expression", $$->getName());

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

        codeOut << endl;
        codeOut << "\t\tPOP BX" << " ;line no: " << lineNo << endl;
        codeOut << "\t\tPOP AX" << " ;line no: " << lineNo << endl;
        if ($2->getName() == "*") {
            codeOut << "\t\tIMUL BX" << " ;line no: " << lineNo << endl;
        } else {
            codeOut << "\t\tXOR DX, DX" << " ;line no: " << lineNo << endl;
            codeOut << "\t\tIDIV BX" << " ;line no: " << lineNo << endl;
            if ($2->getName() == "%") {
                codeOut << "\t\tMOV AX, DX" << " ;line no: " << lineNo << endl;
            }
        }
        codeOut << "\t\tPUSH AX" << " ;line no: " << lineNo << endl;
        codeOut << endl;

        delete $1; delete $2; delete $3;
    }
    ;

unary_expression : ADDOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), $2->getType());
        yylog(logOut, codeOut, lineNo, "unary_expression", "ADDOP unary_expression", $$->getName());

        if ($1->getName() == "-") {
            codeOut << endl;
            codeOut << "\t\tPOP AX" << " ;line no: " << lineNo << endl;
            codeOut << "\t\tNEG AX" << " ;line no: " << lineNo << endl;
            codeOut << "\t\tPUSH AX" << " ;line no: " << lineNo << endl;
            codeOut << endl;
        }

        delete $1; delete $2;
    } 
    | NOT unary_expression {
        $$ = new SymbolInfo(("!" + $2->getName()), $2->getType());
        yylog(logOut, codeOut, lineNo, "unary_expression", "NOT unary_expression", $$->getName());

        string labelIfZero = newLabel();
        string labelEnd = newLabel();

        codeOut << endl;
        codeOut << "\t\tPOP AX" << " ;line no: " << lineNo << endl;
        codeOut << "\t\tCMP AX, 0" << " ;line no: " << lineNo << endl;
        codeOut << "\t\tJE " << labelIfZero << " ;line no: " << lineNo << endl;
        codeOut << "\t\tPUSH 0" << " ;line no: " << lineNo << endl;
        codeOut << "\t\tJMP " << labelEnd << " ;line no: " << lineNo << endl;
        codeOut << labelIfZero << ":" << " ;line no: " << lineNo << endl;
        codeOut << "\t\tPUSH 1" << " ;line no: " << lineNo << endl;
        codeOut << labelEnd << ":" << " ;line no: " << lineNo << endl;
        codeOut << endl;

        delete $2;
    }
    | factor {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "unary_expression", "factor", $$->getName());
    }
    ;
	
factor : variable {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "factor", "variable", $$->getName());

        if ($1->isArray()) {
            codeOut << "\t\tPOP BX" << " ;line no: " << lineNo << endl;
        }
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


        yylog(logOut, codeOut, lineNo, "factor", "ID LPAREN argument_list RPAREN", $$->getName());

        // for (int i=0; i<$3->getParams().size(); i++) {
        //     codeOut << "PUSH " + $3->getParams()[i]->getName() << endl;
        // }
        codeOut << "\t\tCALL " + $1->getName() << " ;line no: " << lineNo << endl;
        // pushing return value to stack
        codeOut << "\t\tPUSH AX" << " ;line no: " << lineNo << endl;

        delete $1; delete $3;
    }
	| LPAREN expression RPAREN {
        $$ = new SymbolInfo(("(" + $2->getName() + ")"), $2->getType());
        yylog(logOut, codeOut, lineNo, "factor", "LPAREN expression RPAREN", $$->getName());

        delete $2;
    }
	| CONST_INT {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "factor", "CONST_INT", $$->getName());

        codeOut << "\t\tPUSH " + $1->getName() << " ;line no: " << lineNo << endl;
    }
	| CONST_FLOAT {
        $$ = new SymbolInfo(($1->getName() + "0"), "CONST_FLOAT"); // just to match the samples
        yylog(logOut, codeOut, lineNo, "factor", "CONST_FLOAT", $$->getName());

        // why can't I delete this?
        // delete $1;
    }
	| variable INCOP {
        $$ = new SymbolInfo(($1->getName() + "++"), $1->getType());
        yylog(logOut, codeOut, lineNo, "factor", "variable INCOP", $$->getName());

        if ($1->isArray()) {
            codeOut << "\t\tPOP BX" << " ;line no: " << lineNo << endl;
            codeOut << "\t\tMOV AX, [BX]" << " ;line no: " << lineNo << endl;
        } else {
            codeOut << "\t\tPOP AX" << " ;line no: " << lineNo << endl;
            codeOut << "\t\tPUSH AX" << " ;line no: " << lineNo << endl;
        }
        codeOut << "\t\tINC AX" << " ;line no: " << lineNo << endl;

        if($1->getOffset() != -1) {
            if($1->isArray())
                codeOut << "\t\tMOV [BX], AX" << " ;line no: " << lineNo << endl;
            else
                // codeOut << "\t\tMOV [BP+" + to_string($1->getOffset()) + "], AX" << " ;line no: " << lineNo << endl;
                codeOut << "\t\tMOV [BP+-" + to_string($1->getOffset()) + "], AX" << " ;line no: " << lineNo << endl;
        } else {
            if($1->isArray())
                codeOut << "\t\tMOV " + $1->getName() + "[BX], AX" << " ;line no: " << lineNo << endl;
            else
                codeOut << "\t\tMOV " + $1->getName() + ", AX" << " ;line no: " << lineNo << endl;
        }

        delete $1;
    }
	| variable DECOP {
        $$ = new SymbolInfo(($1->getName() + "--"), $1->getType());
        yylog(logOut, codeOut, lineNo, "factor", "variable DECOP", $$->getName());

        if ($1->isArray()) {
            codeOut << "\t\tPOP BX" << " ;line no: " << lineNo << endl;
            codeOut << "\t\tMOV AX, [BX]" << " ;line no: " << lineNo << endl;
        } else {
            codeOut << "\t\tPOP AX" << " ;line no: " << lineNo << endl;
            codeOut << "\t\tPUSH AX" << " ;line no: " << lineNo << endl;
        }
        codeOut << "\t\tDEC AX" << " ;line no: " << lineNo << endl;

        if($1->getOffset() != -1) {
            if($1->isArray())
                codeOut << "\t\tMOV [BX], AX" << " ;line no: " << lineNo << endl;
            else
                // codeOut << "\t\tMOV [BP+" + to_string($1->getOffset()) + "], AX" << " ;line no: " << lineNo << endl;
                codeOut << "\t\tMOV [BP+-" + to_string($1->getOffset()) + "], AX" << " ;line no: " << lineNo << endl;
        } else {
            if($1->isArray())
                codeOut << "\t\tMOV " + $1->getName() + "[BX], AX" << " ;line no: " << lineNo << endl;
            else
                codeOut << "\t\tMOV " + $1->getName() + ", AX" << " ;line no: " << lineNo << endl;
        }

        delete $1;
    }
	;
	
argument_list : arguments {
        $$ = $1;
        yylog(logOut, codeOut, lineNo, "argument_list", "arguments", $$->getName());
    }
    | {
        $$ = new SymbolInfo("", "VOID");
        yylog(logOut, codeOut, lineNo, "argument_list", "", $$->getName());
    }
    ;
	
arguments : arguments COMMA logic_expression {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName()), $3->getType());
        // argument_list should have arguments in it's params vector
        for (SymbolInfo* s : $1->getParams()) {
            $$->addParam((new SymbolInfo())->copySymbol(s));
        }
        $$->addParam((new SymbolInfo())->copySymbol($3));
        yylog(logOut, codeOut, lineNo, "arguments", "arguments COMMA logic_expression", $$->getName());

        delete $1; delete $3;
    }
    | logic_expression {
        $$ = $1;
        $$->addParam($1);
        yylog(logOut, codeOut, lineNo, "arguments", "logic_expression", $$->getName());
    }
    ;


%%
int main(int argc,char *argv[])
{
	if (argc < 2) {
        cout << "Specify input file" << endl;
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if(yyin == NULL){
		cout << "Cannot open specified input file" << endl;
		return 1;
	}

    logOut.open("1805093_log.txt");
    errorOut.open("1805093_error.txt");  
    codeOut.open("code.txt");
    dataOut.open("data.txt");

    if (!codeOut.is_open()) {
        cout << "Cannot open code.txt" << endl;
        return 1;
    }
    
	yyparse();
    fclose(yyin);
    codeOut << "END MAIN" << endl;

    st->printAll(logOut);
    logOut << "Total lines: " << lineNo << endl;
    logOut << "Total errors: " << errorNo << endl;

    logOut.close();
    errorOut.close();
    codeOut.close();
    dataOut.close();
    if (errorNo == 0) {
        ofstream code("code.asm");
        code << ".MODEL SMALL\n.STACK 400H\n.DATA\n\n";
        ifstream tempDataIn("data.txt");
        code << tempDataIn.rdbuf();
        code << "\n.CODE\n\n";
        writeProcPrintln(code);
        ifstream tempCodeIn("code.txt");
        code << tempCodeIn.rdbuf();
        code.close();
    }
	
    delete st;

	return 0;
}

