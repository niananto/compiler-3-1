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



void yyerror(char *s) {
	logOut << "Error at line " << lineNo << ": " << s << endl;
	errorOut << "Error at line " << lineNo << ": " << s << endl;
    errorNo++;
}

void yylog(unsigned long lineNo, string left, string right, string symbolName) {
    logOut << "Line " << lineNo << ": " << left << " : " << right << endl << endl;
    logOut << symbolName << endl << endl;
}

vector<string> splitString(string line, char delim) {
    stringstream ss(line);
    vector<string> tokens;
    string intermediate;

    while(getline(ss, intermediate, delim)) {
        tokens.push_back(intermediate);
    }
    return tokens;
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

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program {
        $$ = $1;
        yylog(lineNo, "start", "program", $$->getName());
	}
	;

program : program unit {
        $$ = new SymbolInfo(($1->getName() + "\n" + $2->getName()), "PROGRAM");
        yylog(lineNo, "program", "program unit", $$->getName());
    }
    | unit {
        $$ = $1;
        yylog(lineNo, "program", "unit", $$->getName());
    }
    ;

unit : var_declaration {
        $$ = $1;
        yylog(lineNo, "unit", "var_declaration", $$->getName());
    }
    | func_declaration {
        $$ = $1;
        yylog(lineNo, "unit", "func_declaration", $$->getName());
    }
    | func_definition {
        $$ = $1;
        yylog(lineNo, "unit", "func_definition", $$->getName());
    }
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n"), "FUNC_DECLARATION");
        yylog(lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams(), $$->getName());
    }
	| type_specifier ID LPAREN RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "();\n"), "FUNC_DECLARATION");
        yylog(lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());
        // st.addFunction(yylval.st->getName(), yylval.st->getType(), yylval.st->getParams(), $$->getName());
    }
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "(" + $4->getName() + ")" + $6->getName()), "FUNC_DEFINITION");
        yylog(lineNo, "func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement", $$->getName());
        
        // checking whether this name has been used before
        if(st.lookup($1->getName()) != nullptr) {
            // is that was a function too then
            // check if the declaration and definition matches
            // otherwise throw error
            // if that was not a function then throw error too

            yyerror("Function name already used");
        } else {

            // entering new scope
            st.enterScope();

            // inserting the parameters
            
        }
    }
    | type_specifier ID LPAREN RPAREN compound_statement {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + "()" + $5->getName()), "FUNC_DEFINITION");
        yylog(lineNo, "func_definition", "type_specifier ID LPAREN RPAREN compound_statement", $$->getName());

        // checking whether this name has been used before
        if(st.lookup($1->getName()) != nullptr) {
            yyerror("Function name already used");
        } else {    
            // entering new scope
            st.enterScope();
        }
    }
    ;

parameter_list  : parameter_list COMMA type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + ", " + $3->getName() + " "  + $4->getName()), "PARAMETER_LIST");
        yylog(lineNo, "parameter_list", "parameter_list COMMA type_specifier ID", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    | parameter_list COMMA type_specifier {
        $$ = new SymbolInfo(($1->getName() + ", " + $3->getName()), "PARAMETER_LIST");
        yylog(lineNo, "parameter_list", "parameter_list COMMA type_specifier", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    | type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName()), "PARAMETER_LIST");
        yylog(lineNo, "parameter_list", "type_specifier ID", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    | type_specifier {
        $$ = new SymbolInfo(($1->getName()), "PARAMETER_LIST");
        yylog(lineNo, "parameter_list", "type_specifier", $$->getName());
        // yylval.vst->push_back(new SymbolInfo(yylval.st->getName(), yylval.st->getType()), $$->getName());
    }
    ;

compound_statement : LCURL statements RCURL {
        $$ = new SymbolInfo(("{\n" + $2->getName() + "\n}"), "COMPOUND_STATEMENT");
        yylog(lineNo, "compound_statement", "LCURL statements RCURL", $$->getName());

        st.printAll(logOut);
        
    }
    | LCURL RCURL {
        $$ = new SymbolInfo("{}", "COMPOUND_STATEMENT");
        yylog(lineNo, "compound_statement", "LCURL RCURL", $$->getName());
    }
    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + ";\n"), "VAR_DECLARATION");
        yylog(lineNo, "var_declaration", "type_specifier declaration_list SEMICOLON", $$->getName());
        
        // inserting the variables into current scope
        vector<string> vars = splitString($2->getName(), ',');
        for(string var : vars) {
            st.insert(var, "ID", $1->getName());
        }
    }
    ;
 		 
type_specifier : INT {
        $$ = new SymbolInfo("int", "TYPE_SPECIFIER");
        yylog(lineNo, "type_specifier", "INT", $$->getName());
    }
    | FLOAT {
        $$ = new SymbolInfo("float", "TYPE_SPECIFIER");
        yylog(lineNo, "type_specifier", "FLOAT", $$->getName());
    }
    | VOID {
        $$ = new SymbolInfo("void", "TYPE_SPECIFIER");
        yylog(lineNo, "type_specifier", "VOID", $$->getName());
    }
    ;
 		
declaration_list : declaration_list COMMA ID {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName()), "DECLARATION_LIST");
        yylog(lineNo, "declaration_list", "declaration_list COMMA ID", $$->getName());
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName() + "[" + $5->getName() + "]"), "DECLARATION_LIST");
        yylog(lineNo, "declaration_list", "declaration_list COMMA ID LTHIRD CONST_INT RTHIRD", $$->getName());
    }
    | ID {
        $$ = $1;
        yylog(lineNo, "declaration_list", "ID", $$->getName());
    }
    | ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "DECLARATION_LIST");
        yylog(lineNo, "declaration_list", "ID LTHIRD CONST_INT RTHIRD", $$->getName());
    }
    ;
 		  
statements : statement {
        $$ = $1;
        yylog(lineNo, "statements", "statement", $$->getName());
    }
    | statements statement {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), "STATEMENTS");
        yylog(lineNo, "statements", "statements statement", $$->getName());
    }
    ;
	   
statement : var_declaration {
        $$ = $1;
        yylog(lineNo, "statement", "var_declaration", $$->getName());
    }
    | expression_statement {
        $$ = $1;
        yylog(lineNo, "statement", "expression_statement", $$->getName());
    }
    | compound_statement {
        $$ = $1;
        yylog(lineNo, "statement", "compound_statement", $$->getName());
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
        $$ = new SymbolInfo(("for(" + $3->getName() + ";" + $4->getName() + ";" + $5->getName() + ")" + $7->getName()), "STATEMENT");
        yylog(lineNo, "statement", "FOR LPAREN expression_statement expression_statement expression RPAREN statement", $$->getName());
    }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
        $$ = new SymbolInfo(("if(" + $3->getName() + ")" + $5->getName()), "STATEMENT");
        yylog(lineNo, "statement", "IF LPAREN expression RPAREN statement", $$->getName());
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        $$ = new SymbolInfo(("if(" + $3->getName() + ")" + $5->getName() + "else" + $7->getName()), "STATEMENT");
        yylog(lineNo, "statement", "IF LPAREN expression RPAREN statement ELSE statement", $$->getName());
    }
    | WHILE LPAREN expression RPAREN statement {
        $$ = new SymbolInfo(("while(" + $3->getName() + ")" + $5->getName()), "STATEMENT");
        yylog(lineNo, "statement", "WHILE LPAREN expression RPAREN statement", $$->getName());
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        $$ = new SymbolInfo(("printf(" + $3->getName() + ");"), "STATEMENT");
        yylog(lineNo, "statement", "PRINTLN LPAREN ID RPAREN SEMICOLON", $$->getName());
    }
    | RETURN expression SEMICOLON {
        $$ = new SymbolInfo(("return " + $2->getName() + ";"), "STATEMENT");
        yylog(lineNo, "statement", "RETURN expression SEMICOLON", $$->getName());
    }
    ;
	  
expression_statement : SEMICOLON {
        $$ = new SymbolInfo(";\n", "EXPRESSION_STATEMENT");
        yylog(lineNo, "expression_statement", "SEMICOLON", $$->getName());
    }
    | expression SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + ";\n"), "EXPRESSION_STATEMENT");
        yylog(lineNo, "expression_statement", "expression SEMICOLON", $$->getName());
    }
    ;

variable : ID {
        $$ = $1;
        yylog(lineNo, "variable", "ID", $$->getName());
    } 		
    | ID LTHIRD expression RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "ARRAY");
        yylog(lineNo, "variable", "ID LTHIRD expression RTHIRD", $$->getName());
    }
    ;
	 
expression : logic_expression {
        $$ = $1;
        yylog(lineNo, "expression", "logic_expression", $$->getName());
    }	
    | variable ASSIGNOP logic_expression {
        $$ = new SymbolInfo(($1->getName() + "=" + $3->getName()), $1->getType());
        yylog(lineNo, "expression", "variable ASSIGNOP logic_expression", $$->getName());
    }
    ;
			
logic_expression : rel_expression {
        $$ = $1;
        yylog(lineNo, "logic_expression", "rel_expression", $$->getName());
    } 	
    | rel_expression LOGICOP rel_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "BOOL");
        yylog(lineNo, "logic_expression", "rel_expression LOGICOP rel_expression", $$->getName());
    }
    ;
			
rel_expression : simple_expression {
        $$ = $1;
        yylog(lineNo, "rel_expression", "simple_expression", $$->getName());
    }
    | simple_expression RELOP simple_expression	{
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "BOOL");
        yylog(lineNo, "rel_expression", "simple_expression RELOP simple_expression", $$->getName());
    }
    ;
				
simple_expression : term {
        $$ = $1;
        yylog(lineNo, "simple_expression", "term", $$->getName());
    }
    | simple_expression ADDOP term {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $1->getType());
        yylog(lineNo, "simple_expression", "simple_expression ADDOP term", $$->getName());
    }
    ;
					
term :	unary_expression {
        $$ = $1;
        yylog(lineNo, "term", "unary_expression", $$->getName());
    }
    | term MULOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $1->getType());
        yylog(lineNo, "term", "term MULOP unary_expression", $$->getName());
    }
    ;

unary_expression : ADDOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), $2->getType());
        cout << "sex";
        yylog(lineNo, "unary_expression", "ADDOP unary_expression", $$->getName());
    } 
    | NOT unary_expression {
        $$ = new SymbolInfo(("!" + $2->getName()), $2->getType());
        yylog(lineNo, "unary_expression", "NOT unary_expression", $$->getName());
    }
    | factor {
        $$ = $1;
        yylog(lineNo, "unary_expression", "factor", $$->getName());
    }
    ;
	
factor : variable {
        $$ = $1;
        yylog(lineNo, "factor", "variable", $$->getName());
    }
	| ID LPAREN argument_list RPAREN {
        $$ = new SymbolInfo(($1->getName() + "(" + $3->getName() + ")"), "FUNCTION");
        yylog(lineNo, "factor", "ID LPAREN argument_list RPAREN", $$->getName());
    }
	| LPAREN expression RPAREN {
        $$ = new SymbolInfo(("(" + $2->getName() + ")"), $2->getType());
        yylog(lineNo, "factor", "LPAREN expression RPAREN", $$->getName());
    }
	| CONST_INT {
        $$ = $1;
        yylog(lineNo, "factor", "CONST_INT", $$->getName());
    }
	| CONST_FLOAT {
        $$ = $1;
        yylog(lineNo, "factor", "CONST_FLOAT", $$->getName());
    }
	| variable INCOP {
        $$ = new SymbolInfo(($1->getName() + "++"), $1->getType());
        yylog(lineNo, "factor", "variable INCOP", $$->getName());
    }
	| variable DECOP {
        $$ = new SymbolInfo(($1->getName() + "--"), $1->getType());
        yylog(lineNo, "factor", "variable DECOP", $$->getName());
    }
	;
	
argument_list : arguments {
        $$ = $1;
        yylog(lineNo, "argument_list", "arguments", $$->getName());
    }
    | {
        $$ = new SymbolInfo("", "VOID");
        yylog(lineNo, "argument_list", "", $$->getName());
    }
    ;
	
arguments : arguments COMMA logic_expression {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName()), $1->getType());
        yylog(lineNo, "arguments", "arguments COMMA logic_expression", $$->getName());
    }
    | logic_expression {
        $$ = $1;
        yylog(lineNo, "arguments", "logic_expression", $$->getName());
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

    st.printAll(logOut);
    logOut << endl;
    logOut << "Total lines: " << lineNo << endl;
    logOut << "Total errors: " << errorNo << endl;

    logOut.close();
    errorOut.close();
	
	return 0;
}

