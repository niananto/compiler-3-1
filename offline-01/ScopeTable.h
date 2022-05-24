//
// Created by Admin on 5/24/2022.
//

#ifndef OFFLINE_01_SCOPETABLE_H
#define OFFLINE_01_SCOPETABLE_H

#include <bits/stdc++.h>
#include "SymbolInfo.h"
using namespace std;

unsigned long sdbmHash(char *str){
    unsigned long hash = 0;
    int c;
    while (c = *str++)
        hash = c + (hash << 6) + (hash << 16) - hash;
    return hash;
}

class ScopeTable {
    unsigned long totalBuckets;
    SymbolInfo** buckets;
    ScopeTable* parentScope;
    string id;
    unsigned scopeCount;

public:
    ScopeTable(unsigned long totalBuckets, ScopeTable* parentScope, unsigned scopeCount) {
        this->totalBuckets = totalBuckets;
        buckets = new SymbolInfo*[totalBuckets];
        this->parentScope = parentScope;
        this->scopeCount = scopeCount;

        id = parentScope->id + to_string(scopeCount);

        cout << "New ScopeTable with id " << id << " created" << endl;
    }


    virtual ~ScopeTable() {
        cout << "ScopeTable with id " << id << " removed" << endl;

        SymbolInfo *itr, *nxt;
        for (unsigned long i=0; i<totalBuckets; i++) {
            itr = buckets[i];
            while(itr->getNext() != nullptr) {
                nxt = itr->getNext();
                delete itr;
                itr = nxt;
            }
        }
        delete [] buckets;
        delete parentScope;
    }


    unsigned long hashFunction(char *str) {
        unsigned long hash = 0;
        return sdbmHash(str) % totalBuckets;
    }

    bool insert(string name, string type, unsigned scopeCount) {
        SymbolInfo* symbol = new SymbolInfo(name, type);

        unsigned long index = hashFunction(&name[0]);
        SymbolInfo* itr = buckets[index];
        SymbolInfo* prev = itr;
        unsigned secondaryIndex = 0;
        while(itr != nullptr) {
            if(itr->getName() == name) {
                cout << "<" << name << "," << type << "> already exists in current ScopeTable" << endl;
                return false;
            }
            prev = itr;
            itr = itr->getNext();
            secondaryIndex++;
        }
        prev->setNext(symbol);
        cout << "Inserted in ScopeTable# " << id << " at position " << index << ", " << secondaryIndex << endl;
        return true;
    }

    SymbolInfo* lookup(string name, unsigned scopeCount) {
        unsigned long index = hashFunction(&name[0]);
        SymbolInfo* itr = buckets[index];
        unsigned secondaryIndex = 0;
        while(itr != nullptr) {
            if(itr->getName() == name) {
                cout << "Not found" << endl;
                return nullptr;
            }
            itr = itr->getNext();
            secondaryIndex++;
        }
        cout << "Found in ScopeTable# " << id << " at position " << index << ", " << secondaryIndex << endl;
        return itr;
    }

    bool remove(string name) {
        unsigned long index = hashFunction(&name[0]);
        SymbolInfo* itr = buckets[index];
        unsigned secondaryIndex = 0;

        if(itr->getName() == name) {
            buckets[index] = nullptr;
            cout << "Found in ScopeTable# " << id << " at position " << index << ", " << secondaryIndex << endl;
            cout << "Found it" << endl;
            cout << "Deleted entry at " << index << "," << " in the current ScopeTable" << endl;
            delete itr;
            return true;
        }

        secondaryIndex++;
        while(itr->getNext() != nullptr) {
            if(itr->getNext()->getName() == name) {
                cout << "Found in ScopeTable# " << id << " at position " << index << ", " << secondaryIndex << endl;
                cout << "Found it" << endl;
                cout << "Deleted entry at " << index << "," << " in the current ScopeTable" << endl;
                delete itr->getNext();
                itr->setNext(nullptr);
                return true;
            }
            itr = itr->getNext();
            secondaryIndex++;
        }
        cout << "Not found" << endl;
        cout << name << " is not found" << endl;
        return false;
    }

    void print() {
        cout << "ScopeTable #" << id << endl;
        SymbolInfo* itr;
        for(unsigned long i=0; i<totalBuckets; i++) {
            cout << i << " --> ";
            itr = buckets[i];
            while(itr != nullptr) {
                cout << "< " << itr->getName() << " : " << itr->getType() << ">  ";
            }
            cout << endl;
        }
    }

    ScopeTable *getParentScope() const {
        return parentScope;
    }
};


#endif //OFFLINE_01_SCOPETABLE_H
