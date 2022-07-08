#include <bits/stdc++.h>
#include "SymbolTable.h"
using namespace std;

void yylog(ofstream &logOut, unsigned long lineNo, string left, string right, string symbolName) {
    logOut << "Line " << lineNo << ": " << left << " : " << right << endl << endl;
    logOut << symbolName << endl << endl;
}

vector<string> splitString(string line, char delim)
{
    stringstream ss(line);
    vector<string> tokens;
    string intermediate;

    while (getline(ss, intermediate, delim))
    {
        tokens.push_back(intermediate);
    }
    return tokens;
}

// unsigned extractArraySize(string var) {
//     unsigned size = 0;
//     size = var.find(']');
//     if(size == string::npos) {
//         return -1;
//     }
//     size = var.find('[');
//     if(size == string::npos) {
//         return -1;
//     }
//     string sizeStr = var.substr(size+1, var.length()-size-1);
//     stringstream ss; ss << sizeStr; ss >> size; // stoi isn't working for some reason
//     return size;
// }

bool compareTypes(vector<SymbolInfo *> v1, vector<SymbolInfo *> v2)
{
    if (v1.size() != v2.size())
    {
        return false;
    }
    for (int i = 0; i < v1.size(); i++)
    {
        if (v1[i]->getType() != v2[i]->getType())
        {
            return false;
        }
    }
    return true;
}

// string toUpper(string s) {
//     for (int i = 0; i < s.length(); i++) {
//         s[i] = toupper(s[i]);
//     }
//     return s;
// }

bool typeMatch(string type1, string type2)
{
    if (type1 == type2)
    {
        return true;
    }
    else if ((type1 == "int") && (type2 == "CONST_INT"))
    {
        return true;
    }
    else if ((type1 == "float") && (type2 == "CONST_FLOAT" || type2 == "CONST_INT" || type2 == "int"))
    {
        return true;
    }
    return false;
}
