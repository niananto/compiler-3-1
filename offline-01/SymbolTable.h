//
// Created by Admin on 5/24/2022.
//

#ifndef OFFLINE_01_SYMBOLTABLE_H
#define OFFLINE_01_SYMBOLTABLE_H

#include<bits/stdc++.h>
#include "ScopeTable.h"
using namespace std;

class SymbolTable {
    ScopeTable* currentScope;
    unsigned scopeCount;
    unsigned long totalBuckets;

public:
    SymbolTable(unsigned long totalBuckets) {
        this->totalBuckets = totalBuckets;
        scopeCount = 1;
        currentScope = new ScopeTable(totalBuckets, nullptr, scopeCount++);
    }

    ~SymbolTable() {
        delete currentScope;
    }

    void enterScope() {
        ScopeTable* newScope = new ScopeTable(totalBuckets, currentScope, scopeCount++);
        currentScope = newScope;
    }

    void exitScope() {
        ScopeTable* temp = currentScope->getParentScope();
        delete currentScope;
        currentScope = temp;
    }

    bool insert(string name, string type) {
        return currentScope->insert(name, type, scopeCount);
    }

    bool remove(string name) {
        return currentScope->remove(name);
    }

    SymbolInfo* lookup(string name) {
        ScopeTable* itr = currentScope;
        SymbolInfo* result = nullptr;
        while(itr != nullptr) {
            result = itr->lookup(name, scopeCount);
            if(result != nullptr) {
                return result;
            }
            itr = itr->getParentScope();
        }
        return nullptr;
    }

    void printThis() {
        currentScope->print();
    }

    void printAll() {
        ScopeTable* itr = currentScope;
        while(itr != nullptr) {
            itr->print();
            itr->getParentScope();
        }
    }
};


#endif //OFFLINE_01_SYMBOLTABLE_H
