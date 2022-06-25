%option noyywrap

%{
#include <bits/stdc++.h>
using namespace std;

ofstream fout;
%}

%%

float {
    fout << "double";
}
\n {
    fout << endl;
}
. {
    fout << yytext;
}

%%

int main(int argc, char const *argv[]) {
    if (argc != 2) {
        cout << "please specify input file" << endl;
        return 0;
    }

    fout.open("output.txt");
    yyin = fopen(argv[1], "r");
    yylex();
    fclose(yyin);
    fout.close();
    
    return 0;
}