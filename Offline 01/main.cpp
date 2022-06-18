#include <bits/stdc++.h>
#include "SymbolTable.h"
#include "outputToFilleAndConsole.h"
using namespace std;

int main() {
    freopen("input2.txt", "r", stdin);
//    freopen("/home/ni/3-1/compiler-3-1/offline-01/input2.txt", "r", stdin);

    int n;
    cin >> n;
    SymbolTable* symbolTable = new SymbolTable(n);

    string menuInput;
    while(!feof(stdin)) {
        cin >> menuInput;
        printOutput("\n");
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

        } else if(menuInput == "exit") {
            break;
        }
        printOutput("\n");
    }

    delete symbolTable;
}
