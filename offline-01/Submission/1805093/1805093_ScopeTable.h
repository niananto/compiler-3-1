//
// Created by Admin on 5/24/2022.
//

#ifndef OFFLINE_01_SCOPETABLE_H
#define OFFLINE_01_SCOPETABLE_H

#include <bits/stdc++.h>
#include "1805093_SymbolInfo.h"
#include "1805093_outputToFilleAndConsole.h"
using namespace std;

// unsigned long sdbmHash(char *str){
//     unsigned long hash = 0;
uint32_t sdbmHash(char *str)
{
    uint32_t hash = 0;
    int c;
    while (c = *str++)
        hash = c + (hash << 6) + (hash << 16) - hash;
    return hash;
}

class ScopeTable
{
    unsigned long totalBuckets;
    SymbolInfo **buckets;
    ScopeTable *parentScope;
    string id;
    unsigned scopeCount;

public:
    ScopeTable(unsigned long totalBuckets, ScopeTable *parentScope)
    {
        this->totalBuckets = totalBuckets;
        buckets = new SymbolInfo *[totalBuckets];
        for (unsigned long i = 0; i < totalBuckets; i++)
        {
            buckets[i] = nullptr;
        }
        this->parentScope = parentScope;
        this->scopeCount = 1;

        if (parentScope == nullptr)
        {
            id = "1";
        }
        else
        {
            id = parentScope->id + "." + to_string(parentScope->scopeCount++);
        }

        printOutput("New ScopeTable with id " + id + " created\n");
    }

    ~ScopeTable()
    {
        //        printOutput("Destroying the ScopeTable\n");
        SymbolInfo *itr, *prev;
        for (unsigned long i = 0; i < totalBuckets; i++)
        {
            if (buckets[i] == nullptr)
                continue;

            prev = buckets[i];
            itr = prev->getNext();
            while (itr != nullptr)
            {
                delete prev;
                prev = itr;
                itr = prev->getNext();
            }
            delete prev;
        }
        delete[] buckets;
    }

    unsigned long hashFunction(char *str)
    {
        unsigned long hash = 0;
        return sdbmHash(str) % totalBuckets;
    }

    bool insert(string name, string type)
    {
        SymbolInfo *symbol = new SymbolInfo(name, type);

        unsigned long index = hashFunction(&name[0]);

        if (buckets[index] == nullptr)
        {
            buckets[index] = symbol;
            printOutput("Inserted in ScopeTable# " + id + " at position " + to_string(index) + ", 0\n");
            return true;
        }

        if (buckets[index]->getName() == name)
        {
            printOutput("This word already exists\n");
            printOutput("<" + name + ", " + type + "> already exists in current ScopeTable\n");
            delete symbol;
            return false;
        }

        SymbolInfo *prev = buckets[index];
        SymbolInfo *itr = prev->getNext();
        unsigned secondaryIndex = 1;
        while (itr != nullptr)
        {
            if (itr->getName() == name)
            {
                printOutput("<" + name + "," + type + "> already exists in current ScopeTable\n");
                return false;
            }
            prev = itr;
            itr = itr->getNext();
            secondaryIndex++;
        }
        prev->setNext(symbol);
        printOutput("Inserted in ScopeTable# " + id + " at position " + to_string(index) + ", " + to_string(secondaryIndex) + "\n");
        return true;
    }

    SymbolInfo *lookup(string name)
    {
        unsigned long index = hashFunction(&name[0]);
        SymbolInfo *itr = buckets[index];
        unsigned secondaryIndex = 0;
        while (itr != nullptr)
        {
            if (itr->getName() == name)
            {
                printOutput("Found in ScopeTable# " + id + " at position " + to_string(index) + ", " + to_string(secondaryIndex) + "\n");
                return itr;
            }
            itr = itr->getNext();
            secondaryIndex++;
        }
        return nullptr;
    }

    bool remove(string name)
    {
        unsigned long index = hashFunction(&name[0]);

        if (buckets[index] == nullptr)
        {
            printOutput("Not found\n");
            printOutput(name + " is not found\n");
            return false;
        }

        if (buckets[index]->getName() == name)
        {
            delete buckets[index];
            buckets[index] = nullptr;
            printOutput("Found in ScopeTable# " + id + " at position " + to_string(index) + ", 0\n");
            printOutput("Found it\n");
            printOutput("Deleted entry at " + to_string(index) + ", 0 in the current ScopeTable\n");
            return true;
        }

        SymbolInfo *prev = buckets[index];
        SymbolInfo *itr = prev->getNext();
        unsigned secondaryIndex = 1;
        while (itr != nullptr)
        {
            if (itr->getName() == name)
            {
                delete itr;
                prev->setNext(nullptr);
                printOutput("Found in ScopeTable# " + id + " at position " + to_string(index) + ", " + to_string(secondaryIndex) + "\n");
                printOutput("Found it\n");
                printOutput("Deleted entry at " + to_string(index) + ", " + to_string(secondaryIndex) + " in the current ScopeTable\n");
                return true;
            }
            prev = itr;
            itr = itr->getNext();
            secondaryIndex++;
        }
        printOutput("Not found\n");
        printOutput(name + " is not found\n");
        return true;
    }

    void print()
    {
        printOutput("ScopeTable #" + id + "\n");
        SymbolInfo *itr;
        for (unsigned long i = 0; i < totalBuckets; i++)
        {
            printOutput(to_string(i) + " --> ");
            itr = buckets[i];
            while (itr != nullptr)
            {
                printOutput("< " + itr->getName() + " : " + itr->getType() + ">  ");
                itr = itr->getNext();
            }
            printOutput("\n");
        }
    }

    ScopeTable *getParentScope() const
    {
        return parentScope;
    }

    const string &getId() const
    {
        return id;
    }
};

#endif // OFFLINE_01_SCOPETABLE_H
