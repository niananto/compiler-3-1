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
        for(unsigned long i=0; i<totalBuckets; i++) {
            buckets[i] = nullptr;
        }
        this->parentScope = parentScope;
        this->scopeCount = scopeCount;

        if(parentScope == nullptr) {
            id = to_string(scopeCount);
        } else {
            id = parentScope->id + "." + to_string(scopeCount);
        }

        cout << "New ScopeTable with id " << id << " created" << endl;
    }


    ~ScopeTable() {
        cout << "Destroying the ScopeTable" << endl;
        SymbolInfo *itr, *prev;
        for (unsigned long i=0; i<totalBuckets; i++) {
            if(buckets[i] == nullptr) continue;

            prev = buckets[i];
            itr = prev->getNext();
            while(itr != nullptr) {
                delete prev;
                prev = itr;
                itr = prev->getNext();
            }
            delete prev;
        }
        delete [] buckets;
    }


    unsigned long hashFunction(char *str) {
        unsigned long hash = 0;
        return sdbmHash(str) % totalBuckets;
    }

    bool insert(string name, string type, unsigned scopeCount) {
        SymbolInfo* symbol = new SymbolInfo(name, type);

        unsigned long index = hashFunction(&name[0]);

        if(buckets[index] == nullptr) {
            buckets[index] = symbol;
            cout << "Inserted in ScopeTable# " << id << " at position " << index << ", 0" << endl;
            return true;
        }

        if(buckets[index]->getName() == name) {
            cout << "This word already exists" << endl;
            cout << "<" << name << ", " << type << "> already exists in current ScopeTable" << endl;
            return false;
        }

        SymbolInfo* prev = buckets[index];
        SymbolInfo* itr = prev->getNext();
        unsigned secondaryIndex = 1;
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
                cout << "Found in ScopeTable# " << id << " at position " << index << ", " << secondaryIndex << endl;
                return itr;
            }
            itr = itr->getNext();
            secondaryIndex++;
        }
        return nullptr;
    }

    bool remove(string name) {
        unsigned long index = hashFunction(&name[0]);

        if(buckets[index] == nullptr) {
            cout << "Not found" << endl;
            cout << name << " is not found" << endl;
            return false;
        }

        if(buckets[index]->getName() == name) {
            delete buckets[index];
            buckets[index] = nullptr;
            cout << "Found in ScopeTable# " << id << " at position " << index << ", 0" << endl;
            cout << "Found it" << endl;
            cout << "Deleted entry at " << index << ", 0 in the current ScopeTable" << endl;
            return true;
        }

        SymbolInfo* prev = buckets[index];
        SymbolInfo* itr = prev->getNext();
        unsigned secondaryIndex = 1;
        while(itr != nullptr) {
            if(itr->getName() == name) {
                delete itr;
                prev->setNext(nullptr);
                cout << "Found in ScopeTable# " << id << " at position " << index << ", 0" << endl;
                cout << "Found it" << endl;
                cout << "Deleted entry at " << index << ", " << secondaryIndex << " in the current ScopeTable" << endl;
                return true;
            }
            prev = itr;
            itr = itr->getNext();
            secondaryIndex++;
        }
        cout << "Not found" << endl;
        cout << name << " is not found" << endl;
        return true;




//        if(itr->getName() == name) {
//            buckets[index] = nullptr;
//            cout << "Found in ScopeTable# " << id << " at position " << index << ", " << secondaryIndex << endl;
//            cout << "Found it" << endl;
//            cout << "Deleted entry at " << index << "," << " in the current ScopeTable" << endl;
//            delete itr;
//            return true;
//        }
//
//        secondaryIndex++;
//        while(itr->getNext() != nullptr) {
//            if(itr->getNext()->getName() == name) {
//                cout << "Found in ScopeTable# " << id << " at position " << index << ", " << secondaryIndex << endl;
//                cout << "Found it" << endl;
//                cout << "Deleted entry at " << index << "," << " in the current ScopeTable" << endl;
//                delete itr->getNext();
//                itr->setNext(nullptr);
//                return true;
//            }
//            itr = itr->getNext();
//            secondaryIndex++;
//        }
//        cout << "Not found" << endl;
//        cout << name << " is not found" << endl;
//        return false;
    }

    void print() {
        cout << "ScopeTable #" << id << endl;
        SymbolInfo* itr;
        for(unsigned long i=0; i<totalBuckets; i++) {
            cout << i << " --> ";
            itr = buckets[i];
            while(itr != nullptr) {
                cout << "< " << itr->getName() << " : " << itr->getType() << ">  ";
                itr = itr->getNext();
            }
            cout << endl;
        }
    }

    ScopeTable *getParentScope() const {
        return parentScope;
    }

    const string &getId() const {
        return id;
    }
};


#endif //OFFLINE_01_SCOPETABLE_H
