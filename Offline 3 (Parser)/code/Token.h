#ifndef TOKEN_H
#define TOKEN_H

#include <bits/stdc++.h>
#include "SymbolInfo.h"
using namespace std;

class Token {
    string name;
    SymbolInfo* symbol;

public:
    Token(const string &name, SymbolInfo* symbol) {
        this->name = name;
        this->symbol = symbol;
    }

    string getName() const {
        return this->name;
    }

    void setName(const string &name) {
        this->name = name;
    }

    SymbolInfo* getSymbol() const {
        return this->symbol;
    }
    
    void setSymbol(SymbolInfo* symbol) {
        this->symbol = symbol;
    }
};

#endif //TOKEN_H
