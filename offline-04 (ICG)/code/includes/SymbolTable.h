#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

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
            // cout << "NO CURRENT SCOPE\n";
            return;
        }
        ScopeTable* temp = currentScope->getParentScope();
        if(temp == nullptr) {
            // cout << "Cannot destroy the global scope\n";
        } else {
            // cout << "ScopeTable with id " + currentScope->getId() + " removed\n";
            delete currentScope;
            currentScope = temp;
        }
    }

    string getScopeId() {
        return currentScope->getId();
    }

    bool insert(string name, string type) {
        if(currentScope == nullptr) enterScope();
        return currentScope->insert(name, type);
    }

    bool insert(SymbolInfo* symbol) {
        if(currentScope == nullptr) enterScope();
        return currentScope->insert(symbol);
    }

    // bool insertIntoParent(SymbolInfo* symbol) {
    //     if(currentScope == nullptr) return false;
    //     ScopeTable* temp = currentScope->getParentScope();
    //     if(temp == nullptr) return false;
    //     return temp->insert(symbol);
    // }

//     bool remove(string name) {
//         if(currentScope == nullptr) {
// //            cout << "NO CURRENT SCOPE\n";
//             cout << "Not found\n";
//             return false;
//         }
//         return currentScope->remove(name);
//     }

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
        // cout << "Not found\n";
        return nullptr;
    }
    
    SymbolInfo* lookupGlobalScope(string name) {
        ScopeTable* itr = currentScope;
        while(itr->getParentScope() != nullptr) {
            itr = itr->getParentScope();
        }

        return itr->lookup(name);
    }

    // void printThis() {
    //     if(currentScope == nullptr) {
    //         cout << "NO CURRENT SCOPE\n";
    //         return;
    //     }
    //     currentScope->print();
    // }

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
        logOut << endl;
        if(currentScope == nullptr) {
            // logOut << "NO CURRENT SCOPE\n";
            return;
        }
        ScopeTable* itr = currentScope;
        while(itr != nullptr) {
            logOut << endl;
            itr->print(logOut);
            itr = itr->getParentScope();
            logOut << endl << endl;
        }
    }
};


#endif //SYMBOLTABLE_H
