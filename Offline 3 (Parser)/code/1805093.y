%{
#include<bits/stdc++.h>
#include "SymbolTable.h"
// #include "Token.h"
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

void yyerror(const char *s) {
	logOut << "Error at line " << lineNo << ": " << s << endl << endl;
	errorOut << "Error at line " << lineNo << ": " << s << endl << endl;
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

// unsigned extractArraySize(string var) {
//     unsigned size = 0;
//     size = var.find(']');
//     if(size == string::npos) {
//         return -1;
//     }
//     size = var.find('[');
//     if(size == string::npos) {
//         return -1;
//     }
//     string sizeStr = var.substr(size+1, var.length()-size-1);
//     stringstream ss; ss << sizeStr; ss >> size; // stoi isn't working for some reason
//     return size;
// }

bool compareTypes(vector<SymbolInfo*> v1, vector<SymbolInfo*> v2) {
    if(v1.size() != v2.size()) {
        return false;
    }
    for(int i = 0; i < v1.size(); i++) {
        if(v1[i]->getType() != v2[i]->getType()) {
            return false;
        }
    }
    return true;
}

// string toUpper(string s) {
//     for (int i = 0; i < s.length(); i++) {
//         s[i] = toupper(s[i]);
//     }
//     return s;
// }

bool typeMatch(string type1, string type2) {
    if(type1 == type2) {
        return true;
    } else if((type1 == "int") && (type2 == "CONST_INT")) {
        return true;
    } else if((type1 == "float") && (type2 == "CONST_FLOAT" || type2 == "CONST_INT" || type2 == "int")) {
        return true;
    }
    return false;
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
        yylog(lineNo, "start", "program", "");
	}
	;

program : program unit {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), "PROGRAM");
        yylog(lineNo, "program", "program unit", $$->getName());
    }
    | unit {
        $$ = new SymbolInfo($1->getName(), "PROGRAM");
        yylog(lineNo, "program", "unit", $$->getName());
    }
    ;

unit : var_declaration {
        $$ = new SymbolInfo($1->getName() + "\n", "VAR_DECLARATION");
        yylog(lineNo, "unit", "var_declaration", $$->getName());
    }
    | func_declaration {
        $$ = new SymbolInfo($1->getName(), "FUNC_DECLARATION");
        yylog(lineNo, "unit", "func_declaration", $$->getName());
    }
    | func_definition {
        $$ = new SymbolInfo($1->getName() + "\n", "FUNC_DEFINITION");
        yylog(lineNo, "unit", "func_definition", $$->getName());
    }
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n"), "FUNC_DECLARATION");
        yylog(lineNo, "func_declaration", "type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", $$->getName());
        
        // dummy enter and exit scope
        st.enterScope();
        st.exitScope();

        // get the params from parameter_list and concat it with return type
        // we will insert this ID into Symbol Table
        vector<SymbolInfo*> params;
        params.push_back(new SymbolInfo("RETURN_TYPE", $1->getName()));
        for (auto param : $4->getParams()) {
            params.push_back(param);
        }
        st.insert((new SymbolInfo($2->getName(), "FUNCTION"))->setParams(params));
    }
	| type_specifier ID LPAREN RPAREN SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "();\n"), "FUNC_DECLARATION");
        yylog(lineNo, "func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON", $$->getName());

        // dummy enter and exit scope
        st.enterScope();
        st.exitScope();

        // we will insert this ID into Symbol Table
        // no params in this case just the return type
        vector<SymbolInfo*> params;
        params.push_back(new SymbolInfo("RETURN_TYPE", $1->getName()));
        st.insert((new SymbolInfo($2->getName(), "FUNCTION"))->setParams(params));
    }
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN { // compound_statement here
        
        // will insert the params at the end
        vector<SymbolInfo*> paramsToBeInserted;

        // checking whether this name has been used before
        SymbolInfo *previous = st.lookup($2->getName());
        if(previous != nullptr) {

            // was that a function too
            if(previous->getType() != "FUNCTION") {
                yyerror(("Multiple declaration of " + $2->getName()).c_str());

                // cannot insert the function
                // but insert this scope's params
                paramsToBeInserted = $4->getParams();

            } else {
                // check if the return type and params are the same
                SymbolInfo *returnType = previous->getParams()[0];
                vector<SymbolInfo*> params;
                for (int i = 1; i < previous->getParams().size(); i++) {
                    params.push_back(previous->getParams()[i]);
                }

                if (returnType->getType() != $1->getName()) {
                    yyerror(("Return type mismatch with function declaration in function " + $2->getName()).c_str());
                
                } else if (params.size() != $4->getParams().size()) {
                    yyerror(("Total number of arguments mismatch with declaration in function " + $2->getName()).c_str());

                } else if(compareTypes(params, $4->getParams()) == false) {
                    yyerror(("Function " + $2->getName() + " has different parameters from the previous definition").c_str());
                
                } else {
                    // all is well
                    // later I will check if some paramters don't have a name
                    
                }

                // whatever happens, params should be paramsToBeInserted
                // into the scope. huh
                // handling the parameters
                paramsToBeInserted = $4->getParams();
            }

        } else {
            // inserting the function
            vector<SymbolInfo*> params;
            params.push_back(new SymbolInfo("RETURN_TYPE", $1->getName()));
            for (auto param : $4->getParams()) {
                params.push_back(param);
            }
            st.insert((new SymbolInfo($2->getName(), "FUNCTION"))->setParams(params));

            // handling the parameters
            paramsToBeInserted = $4->getParams();
        }

        // enter scope
        st.enterScope();

        // inserting the params
        for (SymbolInfo* param : paramsToBeInserted) {
            st.insert(param);
        }

    } compound_statement {

        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName() + "(" + $4->getName() + ")" + $7->getName()), "FUNC_DEFINITION");
        
        // print scopes
        st.printAll(logOut);

        yylog(lineNo, "func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement", $$->getName());

        // exit scope
        st.exitScope();
    }
    | type_specifier ID LPAREN RPAREN { // compound_statement here

        // checking whether this name has been used before
        SymbolInfo *previous = st.lookup($2->getName());
        if(previous != nullptr) {

            // was that a function too
            if(previous->getType() != "FUNCTION") {
                yyerror(("Multiple declaration of " + $2->getName()).c_str());
            } else {
                // check if the return type and params are the same
                // in this case params should be empty
                SymbolInfo *returnType = previous->getParams()[0];

                if (returnType->getType() != $1->getName()) {
                    yyerror(("Return type mismatch with function declaration in function " + $2->getName()).c_str());

                } else if(previous->getParams().size() != 1) {
                    yyerror(("Total number of arguments mismatch with declaration in function " + $2->getName()).c_str());
                                    
                } else {
                    // all is well
            
                    // no params so no insertion
                }
            }

        } else {
            // inserting the function
            st.insert((new SymbolInfo($2->getName(), "FUNCTION"))->addParam(new SymbolInfo("RETURN_TYPE", $1->getName())));

            // no params so no insertion
        }

        // enter scope
        st.enterScope();

    } compound_statement {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + "()" + $6->getName()), "FUNC_DEFINITION");

        // print scopes
        st.printAll(logOut);

        yylog(lineNo, "func_definition", "type_specifier ID LPAREN RPAREN compound_statement", $$->getName());

        // exit scope
        st.exitScope();
    }
    ;

parameter_list  : parameter_list COMMA type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName() + " "  + $4->getName()), "PARAMETER_LIST");

        // adding the params
        $$->setParams($1->getParams());
        // check if there was a parameter with same name before
        for (SymbolInfo* param : $1->getParams()) {
            if(param->getName() == $4->getName()) {
                yyerror(("Multiple declaration of " + $4->getName() + " in parameter").c_str());
            }
        }
        $$->addParam(new SymbolInfo($4->getName(), $3->getName()));

        yylog(lineNo, "parameter_list", "parameter_list COMMA type_specifier ID", $$->getName());
    }
    | parameter_list COMMA type_specifier {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName()), "PARAMETER_LIST");
        yylog(lineNo, "parameter_list", "parameter_list COMMA type_specifier", $$->getName());

        // adding the params
        $$->setParams($1->getParams());
        $$->addParam(new SymbolInfo("NOT DEFINED", $3->getName()));
    }
    | type_specifier ID {
        $$ = new SymbolInfo(($1->getName() + " "  + $2->getName()), "PARAMETER_LIST");
        yylog(lineNo, "parameter_list", "type_specifier ID", $$->getName());

        // adding the params
        $$->addParam(new SymbolInfo($2->getName(), $1->getName()));
    }
    | type_specifier {
        $$ = new SymbolInfo(($1->getName()), "PARAMETER_LIST");
        yylog(lineNo, "parameter_list", "type_specifier", $$->getName());

        // adding the params
        $$->addParam(new SymbolInfo("NOT DEFINED", $1->getName()));
    }
    ;

compound_statement : LCURL statements RCURL {
        $$ = new SymbolInfo(("{\n" + $2->getName() + "}\n"), "COMPOUND_STATEMENT");
        yylog(lineNo, "compound_statement", "LCURL statements RCURL", $$->getName());
    }
    | LCURL RCURL {
        $$ = new SymbolInfo("{}", "COMPOUND_STATEMENT");
        yylog(lineNo, "compound_statement", "LCURL RCURL", $$->getName());
    }
    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + " " + $2->getName() + ";"), "VAR_DECLARATION");
        
        // inserting the variables into current scope
        for (SymbolInfo* var : $2->getParams()) {
            // setting type of each var to type_specifier
            // unless it's void
            if ($1->getName() == "void") {
                yyerror("Variable type cannot be void");
            } else if (st.insert(var->setType($1->getName())) == false) {
                yyerror(("Multiple declaration of " + var->getName()).c_str());
            }
        }
        yylog(lineNo, "var_declaration", "type_specifier declaration_list SEMICOLON", $$->getName());
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
        // adding previous id/arrays first
        for (SymbolInfo* var : $1->getParams()) {
            $$->addParam(var);
        }
        // now adding this id
        $$->addParam($3);
        yylog(lineNo, "declaration_list", "declaration_list COMMA ID", $$->getName());
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName() + "[" + $5->getName() + "]"), "DECLARATION_LIST");
        // adding previous id/arrays first
        for (SymbolInfo* var : $1->getParams()) {
            $$->addParam(var);
        }
        // now adding this array
        $$->addParam($3->setArraySize(stoi($5->getName())));
        yylog(lineNo, "declaration_list", "declaration_list COMMA ID LTHIRD CONST_INT RTHIRD", $$->getName());
    }
    | ID {
        $$ = new SymbolInfo($1->getName(), "DECLARATION_LIST");
        // adding this id to declaration_list for assigning type later
        $$->addParam($1);
        yylog(lineNo, "declaration_list", "ID", $$->getName());
    }
    | ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "DECLARATION_LIST");
        // adding this array to declaration_list for assiginng type later
        $$->addParam($1->setArraySize(stoi($3->getName())));
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
        $$ = new SymbolInfo(($1->getName() + "\n"), "STATEMENT");
        yylog(lineNo, "statement", "var_declaration", $$->getName());
    }
    | expression_statement {
        $$ = new SymbolInfo(($1->getName() + "\n"), "STATEMENT");
        yylog(lineNo, "statement", "expression_statement", $$->getName());
    }
    | {st.enterScope();} compound_statement {
        $$ = new SymbolInfo(($2->getName()), "STATEMENT");

        // print scopes
        st.printAll(logOut);

        yylog(lineNo, "statement", "compound_statement", $$->getName());

        // exit scope
        st.exitScope();
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
        $$ = new SymbolInfo(("for(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName()), "FOR_LOOP");
        yylog(lineNo, "statement", "FOR LPAREN expression_statement expression_statement expression RPAREN statement", $$->getName());
    }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
        $$ = new SymbolInfo(("if (" + $3->getName() + ")" + $5->getName()), "IF");
        yylog(lineNo, "statement", "IF LPAREN expression RPAREN statement", $$->getName());
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        $$ = new SymbolInfo(("if (" + $3->getName() + ")" + $5->getName() + "else\n" + $7->getName()), "IF_ELSE");
        yylog(lineNo, "statement", "IF LPAREN expression RPAREN statement ELSE statement", $$->getName());
    }
    | WHILE LPAREN expression RPAREN statement {
        $$ = new SymbolInfo(("while (" + $3->getName() + ")" + $5->getName()), "WHILE_LOOP");
        yylog(lineNo, "statement", "WHILE LPAREN expression RPAREN statement", $$->getName());
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        $$ = new SymbolInfo(("printf(" + $3->getName() + ");\n"), "PRINT_STATEMENT");
        yylog(lineNo, "statement", "PRINTLN LPAREN ID RPAREN SEMICOLON", $$->getName());
    }
    | RETURN expression SEMICOLON {
        $$ = new SymbolInfo(("return " + $2->getName() + ";\n"), "RETURN_STATEMENT");
        yylog(lineNo, "statement", "RETURN expression SEMICOLON", $$->getName());
    }
    ;
	  
expression_statement : SEMICOLON {
        $$ = new SymbolInfo(";", "EXPRESSION_STATEMENT");
        yylog(lineNo, "expression_statement", "SEMICOLON", $$->getName());
    }
    | expression SEMICOLON {
        $$ = new SymbolInfo(($1->getName() + ";"), "EXPRESSION_STATEMENT");
        yylog(lineNo, "expression_statement", "expression SEMICOLON", $$->getName());
    }
    ;

variable : ID {
        $$ = $1;
        
        // check if variable is declared
        SymbolInfo* previous = st.lookup($1->getName());
        if (previous != nullptr) {
            $$->setType(previous->getType());
            if (previous->getArraySize() == -1) {
                // all is well
            } else {
                yyerror(("Type mismatch, " + $1->getName() + " is an array").c_str());
            }
        } else {
            $$->setType("ERROR");
            yyerror(("Undeclared variable " + $1->getName()).c_str());
        }
        yylog(lineNo, "variable", "ID", $$->getName());
    } 		
    | ID LTHIRD expression RTHIRD {
        $$ = new SymbolInfo(($1->getName() + "[" + $3->getName() + "]"), "ARRAY");

        // check if array is declared
        SymbolInfo* previous = st.lookup($1->getName());
        if (previous != nullptr) {
            $$->setType(previous->getType());
            if (previous->getArraySize() != -1) {
                // all is well
            } else {
                yyerror(("Type mismatch, " + $1->getName() + " is an array").c_str());
            }
        } else {
            $$->setType("ERROR");
            yyerror(("Undeclared array " + $1->getName()).c_str());
        }

        // check if expression is INT
        if ($3->getType() != "CONST_INT") {
            if (st.lookup($3->getName()) == nullptr) {
                yyerror("Expression inside third brackets not an integer");
            } else {
                // have to check for a[1+c] here
                // will do that later
                if (st.lookup($3->getName())->getType() != "int") {
                    yyerror("Expression inside third brackets not an integer");
                } else {
                    // all is well
                }
            }
        } else {
            // all is well
        }
        // cout << $3->getName() << $3->getType() << endl;
        // check if expression is within bounds of array

        yylog(lineNo, "variable", "ID LTHIRD expression RTHIRD", $$->getName());
    }
    ;
	 
expression : logic_expression {
        $$ = $1;
        yylog(lineNo, "expression", "logic_expression", $$->getName());
    }	
    | variable ASSIGNOP logic_expression {
        $$ = new SymbolInfo(($1->getName() + "=" + $3->getName()), $3->getType());
        yylog(lineNo, "expression", "variable ASSIGNOP logic_expression", $$->getName());

        // check for type mismatch
        if (typeMatch($1->getType(), $3->getType())) {
            // all is well
        } else {
            if ($1->getType() == "ERROR") {
                // do nothing
            } else {
                yyerror("Type mismatch");
                cout << lineNo << " " << $1->getType() << " " << $3->getType() << endl;
            }
            
        }
    }
    ;
			
logic_expression : rel_expression {
        $$ = $1;
        yylog(lineNo, "logic_expression", "rel_expression", $$->getName());
    } 	
    | rel_expression LOGICOP rel_expression {
        // check if both of them are BOOL/int or not
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "int");
        yylog(lineNo, "logic_expression", "rel_expression LOGICOP rel_expression", $$->getName());
    }
    ;
			
rel_expression : simple_expression {
        $$ = $1;
        yylog(lineNo, "rel_expression", "simple_expression", $$->getName());
    }
    | simple_expression RELOP simple_expression	{
        // check if both of them are BOOL/int or not
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), "int");
        yylog(lineNo, "rel_expression", "simple_expression RELOP simple_expression", $$->getName());
    }
    ;
				
simple_expression : term {
        $$ = $1;
        yylog(lineNo, "simple_expression", "term", $$->getName());
    }
    | simple_expression ADDOP term {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $3->getType());
        yylog(lineNo, "simple_expression", "simple_expression ADDOP term", $$->getName());
    }
    ;
					
term :	unary_expression {
        $$ = $1;
        yylog(lineNo, "term", "unary_expression", $$->getName());
    }
    | term MULOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName() + $3->getName()), $3->getType());
        yylog(lineNo, "term", "term MULOP unary_expression", $$->getName());

        // check for non-integer in modulus
        if ($2->getName() == "%") {
            if (typeMatch("int", $3->getType())) {
                // all is well
            } else {
                yyerror("Non-Integer operand on modulus operator");
                $$->setType("int");
            }
        }
    }
    ;

unary_expression : ADDOP unary_expression {
        $$ = new SymbolInfo(($1->getName() + $2->getName()), $2->getType());
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
        $$ = new SymbolInfo(($1->getName() + "(" + $3->getName() + ")"), "FUNCTION_CALL");
        
        // check if function is declared
        // assign the return type of function to this factor's type
        SymbolInfo* previous = st.lookup($1->getName());
        if (previous == nullptr) {
            $$->setType("ERROR");
            yyerror(("Undeclared function " + $1->getName()).c_str());
        } else {
            if (previous->getType() == "FUNCTION") {
                if (previous->getParams().size() > 0) {
                    // all is well
                    SymbolInfo* s = previous->getParams()[0];
                    $$->setType(previous->getParams()[0]->getType());
                } else {
                    $$->setType("ERROR");
                    yyerror(("Function " + $1->getName() + " has no return type / parameters declared").c_str());
                }
            } else {
                $$->setType("ERROR");
                yyerror(("Type mismatch, " + $1->getName() + " is not a function").c_str());
            }
        }

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
        $$ = new SymbolInfo(($1->getName() + "0"), "CONST_FLOAT"); // just to match the samples
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
        $$ = new SymbolInfo(($1->getName() + "," + $3->getName()), $3->getType());
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
    logOut << "Total lines: " << lineNo << endl;
    logOut << "Total errors: " << errorNo << endl;

    logOut.close();
    errorOut.close();
	
	return 0;
}

