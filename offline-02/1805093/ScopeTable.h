#include "SymbolInfo.h"
using namespace std;

uint32_t sdbmHash(char *str){
    uint32_t hash = 0;
    int c;
    while (c = *str++)
        hash = c + (hash << 6) + (hash << 16) - hash;
    return hash;
}
// int sdbmHash(string str){
//     int h = 0;
//     for(int i=0;i<(int)str.size();i++)
//     {
//         h = (h + str[i]);
//     }
//     return h;
// }

class ScopeTable {
    unsigned long totalBuckets;
    SymbolInfo** buckets;
    ScopeTable* parentScope;
    string id;
    unsigned scopeCount;

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