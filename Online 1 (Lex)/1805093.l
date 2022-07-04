%option noyywrap

%{
#include <bits/stdc++.h>
using namespace std;
%}

whitespace [ \t\f\v\r]+
newline [\r]?\n
letter [a-zA-Z]
letter_ [_a-zA-Z]
digit [0-9]
lower [a-z]
upper [A-Z]
lower_ [a-z_]
upper_ [A-Z_]
lowerNum [a-z0-9]
upperNum [A-Z0-9]
lowerNum_ [a-z0-9_]
upperNum_ [A-Z0-9_]
alphaNum [a-zA-Z0-9]


%%
{whitespace}|{newline} {
    // ignore whitespace
}
{lower}{lowerNum}*({upper}{lowerNum}*)* {
    cout << "CamelCase " << yytext << endl;
}
({lower}{alphaNum}*)?(\_{lowerNum}{alphaNum}*)*\_? {
    cout << "snake_case " << yytext << endl;
}
.* {
    cout << "unknown " << yytext << endl;
}


%%
int main(int argc, char** argv) {
    if (argc < 2) {
        cout << "Specify input file" << endl;
    } else {
        yyin = fopen(argv[1], "r");
        yylex();
        fclose(yyin);   
    }
    
    return 0;
}
