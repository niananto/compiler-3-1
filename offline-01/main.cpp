#include <bits/stdc++.h>
#include "SymbolTable.h"
using namespace std;

int main() {
    freopen("input.txt", "r", stdin);

    int n;
    cin >> n;
    SymbolTable* symbolTable = new SymbolTable(n);

    string menuInput;
    while(true) {
        cin >> menuInput;
        if(menuInput == "I") {
            string name, type;
            cin >> name >> type;
            symbolTable->insert(name, type);

        } else if(menuInput == "L") {
            string name;
            cin >> name;
            symbolTable->lookup(name);

        } else if(menuInput == "D") {
            string name;
            cin >> name;
            symbolTable->remove(name);

        } else if(menuInput == "P") {
            string nextInput;
            cin >> nextInput;
            if(nextInput == "A") {
                symbolTable->printAll();
            } else if(nextInput == "C") {
                symbolTable->printThis();
            } else {
                ;
            }
        } else if(menuInput == "S") {
            symbolTable->enterScope();

        } else if(menuInput == "E") {
            symbolTable->exitScope();

        } else {
            break;

        }
    }


    return 0;
}
