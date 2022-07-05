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

    string varType;

public:
    SymbolInfo() {
        name = "NOT DEFINED";
        type = "NOT DEFINED";
        next = nullptr;

        varType = "NOT DEFINED";
    }

    // SymbolInfo(const string &name, const string &type) {
    //     this->name = name;
    //     this->type = type;
    //     next = nullptr;

    //     varType = "NOT DEFINED";
    // }

    SymbolInfo(const string &name, const string &type, const string &varType = "NOT DEFINED") {
        this->name = name;
        this->type = type;
        next = nullptr;

        this->varType = varType;
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

    string getVarType() const {
        return varType;
    }

    void setVarType(const string &varType) {
        this->varType = varType;
    }
};


#endif //OFFLINE_01_SYMBOLINFO_H
