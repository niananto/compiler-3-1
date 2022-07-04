//
// Created by Admin on 5/24/2022.
//

#ifndef OFFLINE_01_SYMBOLINFO_H
#define OFFLINE_01_SYMBOLINFO_H

#include "iostream"
using namespace std;

class SymbolInfo {
    string name;
    string type;
    SymbolInfo* next;

public:
    SymbolInfo() {
        name = "NOT DEFINED";
        type = "NOT DEFINED";
        next = nullptr;
    }

    SymbolInfo(const string &name, const string &type) {
        this->name = name;
        this->type = type;
        next = nullptr;
    }

    ~SymbolInfo() {
//        if(next != nullptr) delete next;
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

    SymbolInfo *getNext() {
        return next;
    }

    void setNext(SymbolInfo *next) {
        this->next = next;
    }
};


#endif //OFFLINE_01_SYMBOLINFO_H
