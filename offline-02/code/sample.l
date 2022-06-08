%option noyywrap yylineno
%{
#include <iostream>
using namespace std;
%}

letter [a-zA-Z]

%%
[ ] {
    cout << "space found" << endl;
}
"CSE" {
    BEGIN <CSE>;
}
<CSE>"310" {
    cout << "inside cse" << endl;
}
<CSE>. {}
"310" {
    cout << "outside cse" << endl;
}
. {}
{letter} {
    cout << "letter found" << endl;
}

%%
int main() {
    yyin = fopen("input.txt", "r");
    yylex();
    fclose(yyin);

    return 0;
}