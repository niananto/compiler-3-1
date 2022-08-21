#ifndef HANDLEGRAMMERS_H
#define HANDLEGRAMMERS_H

#include <bits/stdc++.h>
#include "SymbolTable.h"
#include "utils.h"
#include "../y.tab.h"
using namespace std;

extern void yyerror(const char *);

extern SymbolTable* st;
extern ofstream logOut;
extern ofstream errorOut;
extern ofstream codeOut;

extern unsigned long lineNo;

// func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
void handleFuncDeclaration(SymbolInfo* s1, SymbolInfo* s2, SymbolInfo* s4) {

    // check if function already exists
    SymbolInfo* previous = st->lookup(s2->getName());
    if (previous != nullptr) {
        if (previous->isDefined()) {
            yyerror(("Function " + s2->getName() + " already defined").c_str());
        } else {
            // double declaration
            // check for matching return type and parameter list
            // it's only a problem when they don't match

            vector<SymbolInfo*> params;
            for (int i = 1; i < previous->getParams().size(); i++) {
                params.push_back(previous->getParams()[i]);
            }
            
            if (previous->getReturnType()->getType() != s1->getName()) {
                yyerror(("Return type mismatch with function declaration in function " + s2->getName()).c_str());
            } else if (params.size() != s4->getParams().size()) {
                yyerror(("Total number of arguments mismatch with declaration in function " + s2->getName()).c_str());
            } else if(compareTypes(params, s4->getParams()) == false) {
                yyerror(("Function " + s2->getName() + " has different parameters from the previous declaration").c_str());
            } else {
                // all is well
            }
        }
    }
    
    // dummy enter and exit scope
    st->enterScope();
    st->exitScope();

    // get the params from parameter_list and concat it with return type
    // we will insert this ID into Symbol Table
    vector<SymbolInfo*> params;
    params.push_back(new SymbolInfo("RETURN_TYPE", s1->getName()));
    for (SymbolInfo* param : s4->getParams()) {
        params.push_back((new SymbolInfo())->copySymbol(param));
        
    }
    st->insert((new SymbolInfo(s2->getName(), "FUNCTION"))->setParams(params));
}

// func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON
void handleFuncDeclaration(SymbolInfo* s1, SymbolInfo* s2) {

    // check if function already exists
    SymbolInfo* previous = st->lookup(s2->getName());
    if (previous != nullptr) {
        if (previous->isDefined()) {
            yyerror(("Function " + s2->getName() + " already defined").c_str());
        } else {
            // double declaration
            // check for matching return type and parameter list
            // it's only a problem when they don't match
            
            if (previous->getReturnType()->getType() != s1->getName()) {
                yyerror(("Return type mismatch with function declaration in function " + s2->getName()).c_str());
            } else if (previous->getParams().size() > 1) {
                yyerror(("Function " + s2->getName() + " should not have any parameter from previous declaration").c_str());
            } else {
                // all is well
            }
        }
    }

    // dummy enter and exit scope
    st->enterScope();
    st->exitScope();

    // we will insert this ID into Symbol Table
    // no params in this case just the return type
    st->insert((new SymbolInfo(s2->getName(), "FUNCTION"))->addParam(new SymbolInfo("RETURN_TYPE", s1->getName())));
}

// func_definition : type_specifier ID LPAREN parameter_list RPAREN
void handleFuncDefinition(SymbolInfo* s1, SymbolInfo* s2, SymbolInfo* s4) {
    vector<SymbolInfo*> paramsToBeInserted;

    // check if some paramters don't have a name
    bool paramsInDefinitionHaveNames = true;
    for (int i=0; i<s4->getParams().size(); i++) {
        SymbolInfo* param = s4->getParams()[i];
        if (param->getName() == "NOT DEFINED") {
            yyerror((to_string(i+1) + "th parameter's name not given in function definition of " + s2->getName()).c_str());
            paramsInDefinitionHaveNames = false;

        // check if that param's name clashes with some other func's name
        } else if (st->lookupGlobalScope(param->getName()) != nullptr && st->lookupGlobalScope(param->getName())->isFunction()) {
            yyerror(("Parameter " + param->getName() + " clashes with a function").c_str());

        } else {
            paramsToBeInserted.push_back(param);
        }
    }

    // checking whether this function name has been used before
    SymbolInfo *previous = st->lookup(s2->getName());
    if(previous != nullptr) {

        // was that a function too
        if(previous->isFunction() == false) {
            yyerror(("Multiple declaration of " + s2->getName()).c_str());

        // check for double definition
        } else if (previous->isDefined()) {
            yyerror(("Redefinition of " + s2->getName()).c_str());

        } else {
            previous->setDefined();

            // check if the return type and params are the same
            // params is just for comparing, not inserting parameters
            SymbolInfo *returnType = previous->getReturnType();
            vector<SymbolInfo*> params;
            bool paramsInDeclarationHaveNames = true;
            for (int i = 1; i < previous->getParams().size(); i++) {
                params.push_back(previous->getParams()[i]);
                if(previous->getParams()[i]->getName() == "NOT DEFINED") {
                    paramsInDeclarationHaveNames = false;
                }
            }

            if (returnType->getType() != s1->getName()) {
                yyerror(("Return type mismatch with function declaration in function " + s2->getName()).c_str());
            
            } else if (params.size() != s4->getParams().size()) {
                yyerror(("Total number of arguments mismatch with declaration in function " + s2->getName()).c_str());

            } else if(compareTypes(params, s4->getParams()) == false) {
                yyerror(("Function " + s2->getName() + " has different parameters from the previous definition").c_str());
            
            } else {
                if (!paramsInDeclarationHaveNames && paramsInDefinitionHaveNames) {
                    // replace previous's params with s4's params
                    vector<SymbolInfo*> replaceParams;
                    for (SymbolInfo* p : s4->getParams()) {
                        replaceParams.push_back((new SymbolInfo())->copySymbol(p));
                    }
                    previous->setParams(replaceParams);
                } else if (paramsInDefinitionHaveNames) {
                    // all is well
                } else {
                    // nothing to do
                }
            }
        }

    } else {
        // inserting the function
        vector<SymbolInfo*> params;
        params.push_back(new SymbolInfo("RETURN_TYPE", s1->getName()));
        for (SymbolInfo* param : s4->getParams()) {
            params.push_back((new SymbolInfo())->copySymbol(param));
        }
        st->insert((new SymbolInfo(s2->getName(), "FUNCTION"))->setParams(params)->setDefined());
    }

    // enter scope
    st->enterScope();

    // whatever happens, params should be inserted into the symbol table
    // into the scope. huh
    // inserting the params
    int i = paramsToBeInserted.size();
    for (SymbolInfo* param : paramsToBeInserted) {
        st->insert(param->setOffset(2 + i*2));
        i--;
    }
}

// func_definition : type_specifier ID LPAREN RPAREN
void handleFuncDefinition(SymbolInfo* s1, SymbolInfo* s2) {

    // checking whether this name has been used before
    SymbolInfo *previous = st->lookup(s2->getName());
    if(previous != nullptr) {

        // was that a function too
        if(previous->isFunction() == false) {
            yyerror(("Multiple declaration of " + s2->getName()).c_str());

        // check for double definition
        } else if (previous->isDefined()) {
            yyerror(("Redefinition of " + s2->getName()).c_str());

        } else {
            previous->setDefined();

            // check if the return type and params are the same
            // in this case params should be empty
            SymbolInfo *returnType = previous->getReturnType();

            if (returnType->getType() != s1->getName()) {
                yyerror(("Return type mismatch with function declaration in function " + s2->getName()).c_str());

            } else if(previous->getParams().size() != 1) {
                yyerror(("Total number of arguments mismatch with declaration in function " + s2->getName()).c_str());
                                
            } else {
                // all is well
        
                // no params so no insertion
            }
        }

    } else {
        // inserting the function
        st->insert((new SymbolInfo(s2->getName(), "FUNCTION"))->addParam(new SymbolInfo("RETURN_TYPE", s1->getName()))->setDefined());

        // no params so no insertion
    }

    // enter scope
    st->enterScope();
}

// parameter_list : parameter_list COMMA type_specifier ID
void handleParameterList(SymbolInfo* ss, SymbolInfo* s1, SymbolInfo* s3, SymbolInfo* s4) {

    // adding the params
    ss->setParams(s1->getParams());
    // check if there was a parameter with same name before
    for (SymbolInfo* param : s1->getParams()) {
        if(param->getName() == s4->getName()) {
            yyerror(("Multiple declaration of " + s4->getName() + " in parameter").c_str());
        }
    }
    ss->addParam(new SymbolInfo(s4->getName(), s3->getName()));

    yylog(logOut, codeOut, lineNo, "parameter_list", "parameter_list COMMA type_specifier ID", ss->getName());
}

// var_declaration : type_specifier declaration_list SEMICOLON
void handleVarDeclaration(SymbolInfo* ss, SymbolInfo* s1, SymbolInfo* s2) {
    // inserting the variables into current scope
    // unsigned i = s2->getParams().size();
    unsigned i = 0;
    for (SymbolInfo* var : s2->getParams()) {
        SymbolInfo* toBeInserted = (new SymbolInfo())->copySymbol(var)->setType(s1->getName());
        if (st->getScopeId() != "1") {
            toBeInserted->setOffset(2 + i*2);
        } else {
            toBeInserted->setOffset(-1);
        }
        // i--;
        i++;

        // setting type of each var to type_specifier
        // unless it's void
        if (s1->getName() == "void") {
            yyerror("Variable type cannot be void");

        // first look for function with the same name in global scope
        } else if (st->lookupGlobalScope(var->getName()) != nullptr && st->lookupGlobalScope(var->getName())->isFunction()) {
            yyerror(("A function exists with the name " + var->getName()).c_str());

        // then try to insert in the currentscope
        // if fails, then there is another variable with the same name in that scope
        } else if ((st->insert(toBeInserted)) == false) {
            yyerror(("Multiple declaration of " + var->getName()).c_str());
        }
    }
    yylog(logOut, codeOut, lineNo, "var_declaration", "type_specifier declaration_list SEMICOLON", ss->getName());
}

// declaration_list : declaration_list COMMA ID
void handleDeclarationList(SymbolInfo* ss, SymbolInfo* s1, SymbolInfo* s3) {

    // adding previous id/arrays first
    for (SymbolInfo* var : s1->getParams()) {
        ss->addParam((new SymbolInfo())->copySymbol(var));
    }
    // now adding this id
    ss->addParam((new SymbolInfo())->copySymbol(s3));
    yylog(logOut, codeOut, lineNo, "declaration_list", "declaration_list COMMA ID", ss->getName());
}

// declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
void handleDeclarationList(SymbolInfo* ss, SymbolInfo* s1, SymbolInfo* s3, SymbolInfo* s5) {
    // adding previous id/arrays first
    for (SymbolInfo* var : s1->getParams()) {
        ss->addParam((new SymbolInfo())->copySymbol(var));
    }
    // now adding this array
    ss->addParam((new SymbolInfo())->copySymbol(s3)->setArraySize(stoi(s5->getName())));
    yylog(logOut, codeOut, lineNo, "declaration_list", "declaration_list COMMA ID LTHIRD CONST_INT RTHIRD", ss->getName());
}


#endif // HANDLEGRAMMERS_H