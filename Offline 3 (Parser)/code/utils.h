#include <bits/stdc++.h>
using namespace std;

void printLog(ofstream logOut, unsigned long lineNo, string left, string right, string symbolName) {
    logOut << "Line " << lineNo << ": " << left << " : " << right << endl;
    logOut << symbolName << endl;
}