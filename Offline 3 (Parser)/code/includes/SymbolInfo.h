#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H

// #include<bits/stdc++.h>
#include "iostream"
using namespace std;

class SymbolInfo {
    string name;
    string type;
    SymbolInfo* next;

    vector<SymbolInfo*> params; // for function & declaration_list
    unsigned arraySize; // for array

public:
    SymbolInfo() {
        name = "NOT DEFINED";
        type = "NOT DEFINED";
        next = nullptr;

        arraySize = -1;
    }

    SymbolInfo(const string &name, const string &type) {
        this->name = name;
        this->type = type;
        next = nullptr;

        arraySize = -1;
    }

    // copy constructor
    // SymbolInfo(const SymbolInfo &other) {
    //     name = other.name;
    //     type = other.type;
    //     next = other.next;

    //     params = other.params;
    //     arraySize = other.arraySize;
    // }

    SymbolInfo* copySymbol(SymbolInfo* symbol) {
        name = symbol->name;
        type = symbol->type;
        next = symbol->next;

        params = symbol->params;
        arraySize = symbol->arraySize;

        return this;
    }

    ~SymbolInfo() {
        params.clear();
    }

    string getName() const {
        return name;
    }

    SymbolInfo* setName(const string &name) {
        this->name = name;
        return this;
    }

    string getType() const {
        return type;
    }

    SymbolInfo* setType(const string &type) {
        this->type = type;
        return this;
    }

    SymbolInfo *getNext() {
        return next;
    }

    SymbolInfo* setNext(SymbolInfo *next) {
        this->next = next;
        return this;
    }

    vector<SymbolInfo*> getParams() const {
        return this->params;
    }

    SymbolInfo* setParams(const vector<SymbolInfo*> &params) {
        this->params = params;
        return this;
    }

    SymbolInfo* addParam(SymbolInfo* param) {
        params.push_back(param);
        return this;
    }

    unsigned getArraySize() const {
        return arraySize;
    }

    SymbolInfo* setArraySize(unsigned arraySize) {
        this->arraySize = arraySize;
        return this;
    }

    // SymbolInfo* getReturnType() {
    //     if (containsSubstring(type, "FUNCTION")) {
    //         // we are assuming there is always a return type
    //         // pushed in the 0th index of params
    //         // if it is a "FUNCTION" type already
    //         // both declared only and defined ones
    //         return params[0];
    //     }
    //     return nullptr;
    // }
};


#endif //SYMBOLINFO_H
