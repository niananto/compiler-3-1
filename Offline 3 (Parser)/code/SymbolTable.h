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
            cout << "NO CURRENT SCOPE\n";
            return;
        }
        ScopeTable* temp = currentScope->getParentScope();
        cout << "ScopeTable with id " + currentScope->getId() + " removed\n";
        if(currentScope->getParentScope() == nullptr) {
            cout << "Destroying the First Scope\n";
        }
        delete currentScope;
        currentScope = temp;
    }

    bool insert(string name, string type, string varType = "NOT DEFINED") {
        if(currentScope == nullptr) enterScope();
        return currentScope->insert(name, type, varType);
    }

    bool remove(string name) {
        if(currentScope == nullptr) {
//            cout << "NO CURRENT SCOPE\n";
            cout << "Not found\n";
            return false;
        }
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
        cout << "Not found\n";
        return nullptr;
    }

    void printThis() {
        if(currentScope == nullptr) {
            cout << "NO CURRENT SCOPE\n";
            return;
        }
        currentScope->print();
    }

    // void printAll() {
    //     if(currentScope == nullptr) {
    //         cout << "NO CURRENT SCOPE\n";
    //         return;
    //     }
    //     ScopeTable* itr = currentScope;
    //     while(itr != nullptr) {
    //         itr->print();
    //         itr = itr->getParentScope();
    //         cout << "\n";
    //     }
    // }

    void printAll(ofstream &logOut) {
        if(currentScope == nullptr) {
            logOut << "NO CURRENT SCOPE\n";
            return;
        }
        ScopeTable* itr = currentScope;
        while(itr != nullptr) {
            itr->print(logOut);
            itr = itr->getParentScope();
            logOut << "\n";
        }
    }
};


#endif //OFFLINE_01_SYMBOLTABLE_H
