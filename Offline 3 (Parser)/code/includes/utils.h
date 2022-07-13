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

bool isInt(string s) {
    return vectorContains(intFamily, s);
}

bool isFloat(string s) {
    return vectorContains(floatFamily, s);
}

bool typeMatch(string type1, string type2) {
    if (type1 == "UNDEFINED" || type2 == "UNDEFINED") {
        return true;
    } else if (type1 == type2) {
        return true;
    } else if ((isInt(type1)) && (isInt(type2))) {
        return true;
    } else if ((isFloat(type1)) && (isFloat(type2) || isInt(type2))) {
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
tuple<bool, SymbolInfo*> typeCast(string left, string right) { // ASSIGNOP
    bool successful = true;
    SymbolInfo* s = new SymbolInfo();

    if (isFloat(left) && (right != "void")) {
        s->setType(left);
    } else if (isInt(left) && isInt(right)) {
        s->setType(left);
    } else { 
        successful = false;
    }

    // have to make 1.2 to 1 when assigned to an int????

    return {successful, s};
}

// c++17 features - tuple
tuple<bool, SymbolInfo*> implicitTypeCast(string left, string right) { // ADDOP MULOP
    bool successful = true;
    SymbolInfo* s = new SymbolInfo();

    if (left == "void" || right == "void") {
        successful = false;
    } else if (isFloat(left) || isFloat(right)) {
        s->setType("float");
    } else { // both int
        s->setType(left);
    }
    
    return {successful, s};
}

#endif // UTILS_H