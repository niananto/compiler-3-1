%option noyywrap yylineno

%x CHAR
%x STR
%x S_CMNT
%x B_CMNT

%{
#include <iostream>
using namespace std;

string currentChar;
string currentExactChar;
string currentStr;
string currentExactStr;
string curr;
string currExact;

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
    currentExactChar = "";
    BEGIN CHAR;
}
<CHAR>\\n {
    currentChar += '\n';
    currentExactChar += "\\n";
}
<CHAR>\\t {
    currentChar += '\t';
    currentExactChar += "\\t";
}
<CHAR>\\\\ {
    currentChar += '\\';
    currentExactChar += "\\\\";
}
<CHAR>\\\" {
    currentChar += '\"';
    currentExactChar += "\\"";
}
<CHAR>\\\' {
    currentChar += '\'';
    currentExactChar += "\\\'";    
}
<CHAR>\\a {
    currentChar += '\a';
    currentExactChar += "\\a";
}
<CHAR>\\f {
    currentChar += '\f';
    currentExactChar += "\\f";
}
<CHAR>\\r {
    currentChar += '\r';
    currentExactChar += "\\r";
}
<CHAR>\\b {
    currentChar += '\b';
    currentExactChar += "\\b";
}
<CHAR>\\v {
    currentChar += '\v';
    currentExactChar += "\\v";
}
<CHAR>\\0 {
    currentChar += '\0';
    currentExactChar += "\\0";
}
<CHAR><<EOF>> {
    cout << "Error at line no " << yylineno << ": Unterminated character '" << currentExactChar << endl;
    BEGIN INITIAL;
}
<CHAR>{newline} {
    cout << "Error at line no " << yylineno << ": Unterminated character '" << currentExactChar << endl;
    BEGIN INITIAL;
}
<CHAR>\' {
    if (currentChar.length() == 1) {
        cout << "<CHAR," << currentChar << ">" << endl;
    } else {
        cout << "Error at line no " << yylineno << ": Multi character constant error '" << currentExactChar << "'" << endl;
    }

    BEGIN INITIAL;
}
<CHAR>. {
    currentChar += yytext;
    currentExactChar += yytext;
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
\" {
    currentStr = "";
    currentExactStr = "";
    BEGIN STR;
}
<STR>\\n {
    currentStr += '\n';
    currentExactStr += "\\n";
}
<STR>\\t {
    currentStr += '\t';
    currentExactStr += "\\t";
}
<STR>\\\\ {
    currentStr += '\\';
    currentExactStr += "\\\\";
}
<STR>\\\" {
    currentStr += '\"';
    currentExactStr += "\\\"";
}
<STR>\\\' {
    currentStr += '\'';
    currentExactStr += "\\\'";
}
<STR>\\a {
    currentStr += '\a';
    currentExactStr += "\\a";
}
<STR>\\f {
    currentStr += '\f';
    currentExactStr += "\\f";
}
<STR>\\r {
    currentStr += '\r';
    currentExactStr += "\\r";
}
<STR>\\b {
    currentStr += '\b';
    currentExactStr += "\\b";
}
<STR>\\v {
    currentStr += '\v';
    currentExactStr += "\\v";
}
<STR>\\0 {
    currentStr += '\0';
    currentExactStr += "\\0";
}
<STR>\\\r\n {
    currentStr += '';
    currentExactStr += "\\\r\n";
}
<STR>\\\n {
    currentStr += '';
    currentExactStr += "\\\n";
}
<STR>{newline} {
    cout << "Error at line no " << yylineno << ": Unterminated string '" << currentExactStr << endl;
    BEGIN INITIAL;
}
<STR><<EOF>> {
    cout << "Error at line no " << yylineno << ": Unterminated string '" << currentExactStr << endl;
    BEGIN INITIAL;
}
<STR>\" {
    cout << "Line no " << yylineno << ": String \"" << currentExactStr << "\"" << endl;
    BEGIN INITIAL;
}
<STR>. {
    currentStr += yytext;
    currentExactStr += yytext;
}
\/\/ {
    curr = "";
    currExact = "";
    BEGIN S_CMNT;
}
<S_CMNT>\\ {
    curr += "\";
    currExact += "\\";
}
<S_CMNT>{newline} {
    cout << "Line no " << yylineno << ": Token <COMMENT> Lexeme " << currExact << " found" << endl;
    BEGIN INITIAL;
}
<S_CMNT>.* {
    curr += yytext;
    currExact += yytext;
}
. {
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