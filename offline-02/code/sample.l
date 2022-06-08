%option noyywrap yylineno

%x CHAR
%x CHAR_TAKEN

%{
#include <iostream>
using namespace std;

string currentChar;

string toUpper(string s) {
    for (int i = 0; i < s.length(); i++) {
        s[i] = toupper(s[i]);
    }
    return s;
}

%}

whitespace [ \t\r\f\v]+
newline [\r]?\n
letter [a-zA-Z]
letter_ [_a-zA-Z]
digit [0-9]



%%
{whitespace} {
    // ignore whitespace
}
if|else|for|while|do|break|int|char|float|double|void|return|switch|case|default|continue {
    // make uppercase
    cout << "<" + toUpper(yytext) + ">" << endl;
}
{digit}+ {
    cout << "<CONST_INT," << yytext << ">" << endl;
}
{digit}*\.{digit}+([eE]?[+-]?{digit}+)? {
    cout << "<CONST_FLOAT," << yytext << ">" << endl;
}
\' {
    currentChar = "";
    BEGIN CHAR;
}
<CHAR>\\n {
    currentChar += '\n';
}
<CHAR>\\t {
    currentChar += '\t';
}
<CHAR>\\\\ {
    currentChar += '\\';
}
<CHAR>\\\' {
    currentChar += '\'';
}
<CHAR>\\a {
    currentChar += '\a';
}
<CHAR>\\f {
    currentChar += '\f';
}
<CHAR>\\r {
    currentChar += '\r';
}
<CHAR>\\b {
    currentChar += '\b';
}
<CHAR>\\v {
    currentChar += '\v';
}
<CHAR>\\0 {
    currentChar += '\0';
}
<CHAR><<EOF>> {
    
}
<CHAR>\' {
    cout << "<CONST_CHAR," << currentChar << ">" << endl;
    BEGIN INITIAL;
}
<CHAR>. {
    currentChar += yytext;
    BEGIN CHAR_TAKEN;
}
<CHAR_TAKEN>\' {
    cout << "<CONST_CHAR," << currentChar << ">" << endl;
    BEGIN INITIAL;
}
<CHAR_TAKEN>. {
    cout << "Error at line no " << yylineno << ": Multi character constant error" << endl;
    BEGIN INITIAL;
}

"+"|"-" {
    cout << "<ADDOP," << yytext << ">" << endl;
}
"*"|"/"|"%" {
    cout << "<MULOP," << yytext << ">" << endl;
}
"++"|"--" {
    cout << "<INCOP," << yytext << ">" << endl;
}
"<"|"<="|">"|">="|"=="|"!=" {
    cout << "<RELOP," << yytext << ">" << endl;
}
"=" {
    cout << "<ASSIGNOP," << yytext << ">" << endl;
}
"&&"|"||" {
    cout << "<LOGICOP," << yytext << ">" << endl;
}
"!" {
    cout << "<NOT," << yytext << ">" << endl;
}
"(" {
    cout << "<LPAREN," << yytext << ">" << endl;
}
")" {
    cout << "<RPAREN," << yytext << ">" << endl;
}
"{" {
    cout << "<LCURL," << yytext << ">" << endl;
}
"}" {
    cout << "<RCURL," << yytext << ">" << endl;
}
"[" {
    cout << "<LTHIRD," << yytext << ">" << endl;
}
"]" {
    cout << "<RTHIRD," << yytext << ">" << endl;
}
"," {
    cout << "<COMMA," << yytext << ">" << endl;
}
";" {
    cout << "<SEMICOLON," << yytext << ">" << endl;
}
{letter_}({letter_}|{digit})* {
    cout << "<ID," << yytext << ">" << endl;
}
.* {
    // ignore everything else
}


%%
int main(int argc, char** argv) {
    if (argc < 2) {
        yylex();
    } else {
        yyin = fopen(argv[1], "r");
        yylex();
        fclose(yyin);   
    }
    

    return 0;
}