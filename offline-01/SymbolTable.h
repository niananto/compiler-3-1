//
// Created by Admin on 5/24/2022.
//

#ifndef OFFLINE_01_SYMBOLTABLE_H
#define OFFLINE_01_SYMBOLTABLE_H

#include<bits/stdc++.h>
#include "ScopeTable.h"
#include "outputToFilleAndConsole.h"
using namespace std;

class SymbolTable {
    ScopeTable* currentScope;
    unsigned long totalBuckets;

public:
    SymbolTable(unsigned long totalBuckets) {
        this->totalBuckets = totalBuckets;
        currentScope = nullptr;
        enterScope();
    }

    ~SymbolTable() {
        delete currentScope;
    }

    void enterScope() {
        ScopeTable* newScope = new ScopeTable(totalBuckets, currentScope);
        currentScope = newScope;
    }

    void exitScope() {
        if(currentScope == nullptr) {
            printOutput("NO CURRENT SCOPE\n");
            return;
        }
        ScopeTable* temp = currentScope->getParentScope();
        printOutput("ScopeTable with id " + currentScope->getId() + " removed\n");
        if(currentScope->getParentScope() == nullptr) {
            printOutput("Destroying the First Scope\n");
        }
        delete currentScope;
        currentScope = temp;
    }

    bool insert(string name, string type) {
        if(currentScope == nullptr) enterScope();
        return currentScope->insert(name, type);
    }

    bool remove(string name) {
        return currentScope->remove(name);
    }

    SymbolInfo* lookup(string name) {
        ScopeTable* itr = currentScope;
        SymbolInfo* result = nullptr;
        while(itr != nullptr) {
            result = itr->lookup(name);
            if(result != nullptr) {
                return result;
            }
            itr = itr->getParentScope();
        }
        printOutput("Not found\n");
        return nullptr;
    }

    void printThis() {
        currentScope->print();
    }

    void printAll() {
        ScopeTable* itr = currentScope;
        while(itr != nullptr) {
            itr->print();
            itr = itr->getParentScope();
            printOutput("\n");
        }
    }
};


#endif //OFFLINE_01_SYMBOLTABLE_H
