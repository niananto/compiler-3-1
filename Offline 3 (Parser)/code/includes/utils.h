#ifndef UTILS_H
#define UTILS_H

#include <bits/stdc++.h>
#include "SymbolInfo.h"
using namespace std;

vector<string> intFamily{"int", "CONST_INT"};
vector<string> floatFamily{"float", "CONST_FLOAT"};

void yylog(ofstream &logOut, unsigned long lineNo, string left, string right, string symbolName) {
    logOut << "Line " << lineNo << ": " << left << " : " << right << endl << endl;
    logOut << symbolName << endl << endl;
}

vector<string> splitString(string line, char delim) {
    stringstream ss(line);
    vector<string> tokens;
    string intermediate;

    while (getline(ss, intermediate, delim)) {
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

bool compareTypes(vector<SymbolInfo*> v1, vector<SymbolInfo*> v2) {
    if (v1.size() != v2.size()) {
        return false;
    }
    for (int i = 0; i < v1.size(); i++) {
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

template<typename T>
bool vectorContains(const std::vector<T> &v, T x) {
	return find(v.begin(), v.end(), x) != v.end();
}

bool typeMatch(string type1, string type2) {
    if (type1 == type2) {
        return true;
    }
    else if ((vectorContains(intFamily, type1)) && (vectorContains(intFamily, type2))) {
        return true;
    }
    else if ((vectorContains(floatFamily, type1)) && (vectorContains(floatFamily, type2) || vectorContains(intFamily, type2))) {
        return true;
    }
    return false;
}

// bool containsSubstring(string s1, string s2) {
//     if (s1.find(s2) != string::npos) {
//         return true;
//     }
//     return false;
// }

// c++17 features - tuple
tuple<bool, SymbolInfo*> implicitTypeCast(SymbolInfo* left, SymbolInfo* right) {
    bool successful = true;
    SymbolInfo* s = new SymbolInfo();

    if (left->getType() == right->getType()) { // including void = void
        s->setType(left->getType());
    } else if (left->getType() == "float" && right->getType() == "int") {
        s->setType(left->getType());
    } else if (left->getType() == "int" && right->getType() == "float") {
        successful = false;
    } else { // everything with "void" except void = void
        successful = false;
    }

    return {successful, s};
}

#endif // UTILS_H