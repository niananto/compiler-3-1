//
// Created by ni on 5/26/22.
//

#ifndef OFFLINE_01_OUTPUTTOFILLEANDCONSOLE_H
#define OFFLINE_01_OUTPUTTOFILLEANDCONSOLE_H

#include "bits/stdc++.h"
using namespace std;

void printOutput(string s) {
    static ofstream fout;
    if(!fout.is_open()) {
//        fout.open("/home/ni/3-1/compiler-3-1/offline-01/test.txt");
        fout.open("symboltabledump.txt");
    }

    // cout << s;
    // fout << s;
}

#endif //OFFLINE_01_OUTPUTTOFILLEANDCONSOLE_H
