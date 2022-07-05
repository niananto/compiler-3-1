#include <bits/stdc++.h>
using namespace std;

// this is an extended version of the previous symbol info

class SymbolInfo {
    string name;
    string type;
    SymbolInfo* next;

    // string varType;
    // // for functions
    // vector<SymbolInfo*> funcParams;
    // bool isFunc;
    // bool isFuncDefined;
    // // for arrays
    // // arraySize = 0 not an array, a variable
    // unsigned arraySize = 0; 

public:
    SymbolInfo() {
        name = "NOT DEFINED";
        type = "NOT DEFINED";
        next = nullptr;

        // varType = "NOT DEFINED";
        // isFunc = false;
        // isFuncDefined = false;
    }

    SymbolInfo(const string &name, const string &type) {
        this->name = name;
        this->type = type;
        next = nullptr;

        // varType = "NOT DEFINED";
        // isFunc = false;
        // isFuncDefined = false;
    }
    // SymbolInfo(const string &name, const string &type, const string &varType) {
    //     this->name = name;
    //     this->type = type;
    //     next = nullptr;

    //     // this->varType = varType;
    //     // isFunc = false;
    //     // isFuncDefined = false;
    // }

    // // function constructor
    // SymbolInfo* setAsFunction(const string &name, const string &type, const vector<SymbolInfo*> &funcParams) {
    //     this->name = name;
    //     this->type = type;
    //     next = nullptr;
        
    //     varType = "FUNCTION";
    //     this->funcParams = funcParams;
    //     isFunc = true;
    //     isFuncDefined = false;

    //     return this;
    // }

    // array constructor

    ~SymbolInfo() {
        // no dynamic memory allocation
        // so no need to delete anything
    }

    string getName() const {
        return name;
    }

    void setName(const string &name) {
        this->name = name;
    }

    string getType() const {
        return type;
    }

    void setType(const string &type) {
        this->type = type;
    }

    SymbolInfo *getNext() const {
        return next;
    }

    void setNext(SymbolInfo *next) {
        this->next = next;
    }

    // bool getIsFunc() const {
    //     return isFunc;
    // }

    // void setIsFunc(const bool &isFunc) {
    //     this->isFunc = isFunc;
    // }

    // bool getIsFuncDefined() const {
    //     return isFuncDefined;
    // }

    // void setIsFuncDefined(const bool &isFuncDefined) {
    //     this->isFuncDefined = isFuncDefined;
    // }
};

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////


class ScopeTable {
    unsigned long totalBuckets;
    SymbolInfo** buckets;
    ScopeTable* parentScope;
    string id;
    unsigned scopeCount;

    uint32_t sdbmHash(char *str){
    uint32_t hash = 0;
    int c;
    while (c = *str++)
        hash = c + (hash << 6) + (hash << 16) - hash;
    return hash;
}

public:
    ScopeTable(unsigned long totalBuckets, ScopeTable* parentScope) {
        this->totalBuckets = totalBuckets;
        buckets = new SymbolInfo*[totalBuckets];
        for(unsigned long i=0; i<totalBuckets; i++) {
            buckets[i] = nullptr;
        }
        this->parentScope = parentScope;
        this->scopeCount = 1;

        if(parentScope == nullptr) {
            id = "1";
        } else {
            id = parentScope->id + "." + to_string(parentScope->scopeCount++);
        }

        cout << "New ScopeTable with id " + id + " created\n";
    }


    ~ScopeTable() {
//        cout << "Destroying the ScopeTable\n";
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

    bool insert(string name, string type) {
        SymbolInfo* symbol = new SymbolInfo(name, type);

        unsigned long index = hashFunction(&name[0]);

        if(buckets[index] == nullptr) {
            buckets[index] = symbol;
            cout << "Inserted in ScopeTable# " + id + " at position " + to_string(index) + ", 0\n";
            return true;
        }

        if(buckets[index]->getName() == name) {
            cout << "This word already exists\n";
            cout << "<" + name + ", " + buckets[index]->getType() + "> already exists in current ScopeTable\n";
            delete symbol;
            return false;
        }

        SymbolInfo* prev = buckets[index];
        SymbolInfo* itr = prev->getNext();
        unsigned secondaryIndex = 1;
        while(itr != nullptr) {
            if(itr->getName() == name) {
                cout << "<" + name + "," + buckets[index]->getType() + "> already exists in current ScopeTable\n";
                return false;
            }
            prev = itr;
            itr = itr->getNext();
            secondaryIndex++;
        }
        prev->setNext(symbol);
        cout << "Inserted in ScopeTable# " + id + " at position " + to_string(index) + ", " + to_string(secondaryIndex) + "\n";
        return true;
    }

    bool insert(string name, string type, ofstream &fout) {
        SymbolInfo* symbol = new SymbolInfo(name, type);

        unsigned long index = hashFunction(&name[0]);

        if(buckets[index] == nullptr) {
            buckets[index] = symbol;
            return true;
        }

        if(buckets[index]->getName() == name) {
            fout << endl << name << " already exists in current ScopeTable\n";
            delete symbol;
            return false;
        }

        SymbolInfo* prev = buckets[index];
        SymbolInfo* itr = prev->getNext();
        unsigned secondaryIndex = 1;
        while(itr != nullptr) {
            if(itr->getName() == name) {
                fout << name << " already exists in current ScopeTable\n";
                return false;
            }
            prev = itr;
            itr = itr->getNext();
            secondaryIndex++;
        }
        prev->setNext(symbol);
        return true;
    }

    SymbolInfo* lookup(string name) {
        unsigned long index = hashFunction(&name[0]);
        SymbolInfo* itr = buckets[index];
        unsigned secondaryIndex = 0;
        while(itr != nullptr) {
            if(itr->getName() == name) {
                cout << "Found in ScopeTable# " + id + " at position " + to_string(index) + ", " + to_string(secondaryIndex) + "\n";
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
            cout << "Not found\n";
            cout << name + " is not found\n";
            return false;
        }

        if(buckets[index]->getName() == name) {
            SymbolInfo* temp = buckets[index];
            buckets[index] = buckets[index]->getNext();
            delete temp;
            cout << "Found in ScopeTable# " + id + " at position " + to_string(index) + ", 0\n";
            cout << "Found it\n";
            cout << "Deleted entry at " + to_string(index) + ", 0 in the current ScopeTable\n";
            return true;
        }

        SymbolInfo* prev = buckets[index];
        SymbolInfo* itr = prev->getNext();
        unsigned secondaryIndex = 1;
        while(itr != nullptr) {
            if(itr->getName() == name) {
                prev->setNext(itr->getNext());
                delete itr;
                cout << "Found in ScopeTable# " + id + " at position " + to_string(index) + ", " + to_string(secondaryIndex) + "\n";
                cout << "Found it\n";
                cout << "Deleted entry at " + to_string(index) + ", " + to_string(secondaryIndex) + " in the current ScopeTable\n";
                return true;
            }
            prev = itr;
            itr = itr->getNext();
            secondaryIndex++;
        }
        cout << "Not found\n";
        cout << name + " is not found\n";
        return true;
    }

    void print() {
        cout << "ScopeTable #" + id + "\n";
        SymbolInfo* itr;
        for(unsigned long i=0; i<totalBuckets; i++) {
            cout << to_string(i) + " --> ";
            itr = buckets[i];
            while(itr != nullptr) {
                cout << "< " + itr->getName() + " : " + itr->getType() + ">  ";
                itr = itr->getNext();
            }
            cout << "\n";
        }
        cout << "\n";
    }

    void printPopulated(ofstream &fout) {
        fout << "\n";
        fout << "ScopeTable # " + id + "\n";
        SymbolInfo* itr;
        for(unsigned long i=0; i<totalBuckets; i++) {
            if (buckets[i] == nullptr) continue;
            fout << " " << to_string(i) + " --> ";
            itr = buckets[i];
            while(itr != nullptr) {
                fout << "< " + itr->getName() + " : " + itr->getType() + "> ";
                itr = itr->getNext();
            }
            fout << "\n";
        }
    }

    ScopeTable *getParentScope() const {
        return parentScope;
    }

    const string &getId() const {
        return id;
    }
};

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////




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

    bool insert(string name, string type) {
        if(currentScope == nullptr) enterScope();
        return currentScope->insert(name, type);
    }

    bool insert(string name, string type, ofstream &fout) {
        if(currentScope == nullptr) enterScope();
        if (currentScope->insert(name, type, fout)) {
            printSymbols(fout);
            return true;
        } else {
            return false;
        }
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

    void printAll() {
        if(currentScope == nullptr) {
            cout << "NO CURRENT SCOPE\n";
            return;
        }
        ScopeTable* itr = currentScope;
        while(itr != nullptr) {
            itr->print();
            itr = itr->getParentScope();
        }
    }

    void printSymbols(ofstream &fout) {
        if(currentScope == nullptr) {
            fout << "NO CURRENT SCOPE\n";
            return;
        }
        ScopeTable* itr = currentScope;
        while(itr != nullptr) {
            itr->printPopulated(fout);
            itr = itr->getParentScope();
        }
    }
};
