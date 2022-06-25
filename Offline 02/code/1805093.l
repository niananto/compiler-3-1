%option noyywrap

%x CHAR
%x STR
%x S_CMNT
%x M_CMNT

%{
#include <bits/stdc++.h>
#include "SymbolTable.h"
using namespace std;

SymbolTable st(7);
ofstream logOut;
ofstream tokenOut;

unsigned long lineNo = 1;
unsigned long startLineNo;
unsigned long errorNo = 0;
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

whitespace [ \t\f\v\r]+
newline [\r]?\n
letter [a-zA-Z]
letter_ [_a-zA-Z]
digit [0-9]

%%
{whitespace} {
    // ignore whitespace
}
{newline} {
    lineNo++;
}
if|else|for|while|do|break|int|char|float|double|void|return|switch|case|default|continue {
    logOut << endl << "Line no " << lineNo << ": Token <" + toUpper(yytext) + "> Lexeme " << yytext << " found" << endl;
    tokenOut << "<" + toUpper(yytext) + "> ";
}
{letter_}({letter_}|{digit})* {
    logOut << endl << "Line no " << lineNo << ": Token <ID> Lexeme " << yytext << " found" << endl;
    st.insert(yytext, "ID", logOut);
    tokenOut << "<ID, " << yytext << "> ";
}
{digit}+ {
    logOut << endl << "Line no " << lineNo << ": Token <CONST_INT> Lexeme " << yytext << " found" << endl;
    st.insert(yytext, "CONST_INT", logOut);
    tokenOut << "<CONST_INT, " << yytext << "> ";
}
{digit}*(\.{digit}+)?(([eE][+-])?{digit}+)? {
    logOut << endl << "Line no " << lineNo << ": Token <CONST_FLOAT> Lexeme " << yytext << " found" << endl;
    st.insert(yytext, "CONST_FLOAT", logOut);
    tokenOut << "<CONST_FLOAT, " << yytext << "> ";
}
({digit}*\.{digit}+(\.{digit}*)+)+ {
    logOut << endl << "Error at line no " << lineNo << ": Too many decimal points " << yytext << endl;
    errorNo++;
}
({digit}*\.?{digit}*[eE][+-]?{digit}*\.{digit}*)|({digit}*\.([eE][+-]?{digit}*\.?{digit}*)?) {
    logOut << endl << "Error at line no " << lineNo << ": Ill formed number " << yytext << endl;
    errorNo++;
}

{digit}+{letter_}+ {
    logOut << endl << "Error at line no " << lineNo << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl;
    errorNo++;
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
    currentExactChar += "\\\"";
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
    logOut << endl << "Error at line no " << lineNo << ": Unterminated character '" << currentExactChar << endl;
    errorNo++;
    BEGIN INITIAL;
}
<CHAR>{newline} {
    logOut << endl << "Error at line no " << lineNo << ": Unterminated character '" << currentExactChar << endl;
    errorNo++;
    lineNo++;
    BEGIN INITIAL;
}
<CHAR>\' {
    if ((currentChar.length() == 1) || (currentChar.length() == 0 && currentExactChar == "\\0")) {
        logOut << endl << "Line no " << lineNo << ": Token <CONST_CHAR> Lexeme '" << currentExactChar << "' found ";
        logOut << "--> <CHAR_CONST, " << currentChar << "> " << endl;
        st.insert("'"+currentExactChar+"'", "CONST_CHAR", logOut);
        logOut << endl;
        tokenOut << "<CHAR_CONST, " << currentChar << "> ";
    } else if(currentChar.length() == 0) {
        logOut << endl << "Error at line no " << lineNo << ": Empty character constant error '" << currentExactChar << "'" << endl;
        errorNo++;
    } else {
        logOut << endl << "Error at line no " << lineNo << ": Multi character constant error '" << currentExactChar << "'" << endl;
        errorNo++;
    }

    BEGIN INITIAL;
}
<CHAR>. {
    currentChar += yytext;
    currentExactChar += yytext;
}
"+"|"-" {
    logOut << endl << "Line no " << lineNo << ": Token <ADDOP> Lexeme " << yytext << " found" << endl;
    tokenOut << "<ADDOP, " << yytext << "> ";
}
"*"|"/"|"%" {
    logOut << endl << "Line no " << lineNo << ": Token <MULOP> Lexeme " << yytext << " found" << endl;
    tokenOut << "<MULOP, " << yytext << "> ";
}
"++"|"--" {
    logOut << endl << "Line no " << lineNo << ": Token <INCOP> Lexeme " << yytext << " found" << endl;
    tokenOut << "<INCOP, " << yytext << "> ";
}
"<"|"<="|">"|">="|"=="|"!=" {
    logOut << endl << "Line no " << lineNo << ": Token <RELOP> Lexeme " << yytext << " found" << endl;
    tokenOut << "<RELOP, " << yytext << "> ";
}
"=" {
    logOut << endl << "Line no " << lineNo << ": Token <ASSIGNOP> Lexeme " << yytext << " found" << endl;
    tokenOut << "<ASSIGNOP, " << yytext << "> ";
}
"&&"|"||" {
    logOut << endl << "Line no " << lineNo << ": Token <logOutICOP> Lexeme " << yytext << " found" << endl;
    tokenOut << "<logOutICOP, " << yytext << "> ";
}
"!" {
    logOut << endl << "Line no " << lineNo << ": Token <NOT> Lexeme " << yytext << " found" << endl;
    tokenOut << "<NOT, " << yytext << "> ";
}
"(" {
    logOut << endl << "Line no " << lineNo << ": Token <LPAREN> Lexeme " << yytext << " found" << endl;
    tokenOut << "<LPAREN, " << yytext << "> ";
}
")" {
    logOut << endl << "Line no " << lineNo << ": Token <RPAREN> Lexeme " << yytext << " found" << endl;
    tokenOut << "<RPAREN, " << yytext << "> ";
}
"{" {
    logOut << endl << "Line no " << lineNo << ": Token <LCURL> Lexeme " << yytext << " found" << endl;
    tokenOut << "<LCURL, " << yytext << "> ";
    st.enterScope();
}
"}" {
    logOut << endl << "Line no " << lineNo << ": Token <RCURL> Lexeme " << yytext << " found" << endl;
    tokenOut << "<RCURL, " << yytext << "> ";
    st.exitScope();
}
"[" {
    logOut << endl << "Line no " << lineNo << ": Token <LTHIRD> Lexeme " << yytext << " found" << endl;
    tokenOut << "<LTHIRD, " << yytext << "> ";
}
"]" {
    logOut << endl << "Line no " << lineNo << ": Token <RTHIRD> Lexeme " << yytext << " found" << endl;
    tokenOut << "<RTHIRD, " << yytext << "> ";
}
"," {
    logOut << endl << "Line no " << lineNo << ": Token <COMMA> Lexeme " << yytext << " found" << endl;
    tokenOut << "<COMMA, " << yytext << "> ";
}
";" {
    logOut << endl << "Line no " << lineNo << ": Token <SEMICOLON> Lexeme " << yytext << " found" << endl;
    tokenOut << "<SEMICOLON, " << yytext << "> ";
}
\" {
    currentStr = "";
    currentExactStr = "";
    startLineNo = lineNo;
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
    currentExactStr += "\\\r\n";
    lineNo++;
}
<STR>\\\n {
    currentExactStr += "\\\n";
    lineNo++;
}
<STR>{newline} {
    logOut << endl << "Error at line no " << startLineNo << ": Unterminated String \"" << currentExactStr << endl;
    errorNo++;
    lineNo++;
    BEGIN INITIAL;
}
<STR><<EOF>> {
    logOut << endl << "Error at line no " << startLineNo << ": Unterminated String \"" << currentExactStr << "\"" << endl;
    errorNo++;
    BEGIN INITIAL;
}
<STR>\" {
    logOut << endl << "Line no " << startLineNo << ": Token <STRING> Lexeme \"" << currentExactStr << "\" found ";
    logOut << "--> <STRING, \"" << currentStr << "\"> " << endl;
    tokenOut << "<STRING, \"" << currentStr << "\"> ";
    BEGIN INITIAL;
}
<STR>. {
    currentStr += yytext;
    currentExactStr += yytext;
}
\/\/ {
    currExact = "";
    startLineNo = lineNo;
    BEGIN S_CMNT;
}
<S_CMNT>\\{newline} {
    currExact += yytext;
    lineNo++;
}
<S_CMNT>{newline} {
    logOut << endl << "Line no " << startLineNo << ": Token <COMMENT> Lexeme //" << currExact << " found" << endl;
    lineNo++;
    BEGIN INITIAL;
}
<S_CMNT><<EOF>> {
    logOut << endl << "Line no " << startLineNo << ": Token <COMMENT> Lexeme //" << currExact << " found" << endl;
    BEGIN INITIAL;
}
<S_CMNT>. {
    currExact += yytext;
}
\/\* {
    currExact = "";
    startLineNo = lineNo;
    BEGIN M_CMNT;
}
<M_CMNT>\*\/ {
    logOut << endl << "Line no " << startLineNo << ": Token <COMMENT> Lexeme /*" << currExact << "*/ found" << endl;
    BEGIN INITIAL;
}
<M_CMNT><<EOF>> {
    logOut << endl << "Error at line no " << startLineNo << ": Unterminated Comment /*" << currExact << endl;
    errorNo++;
    BEGIN INITIAL;
}
<M_CMNT>{newline} {
    currExact += yytext;
    lineNo++;
}
<M_CMNT>. {
    currExact += yytext;
}
. {
    logOut << endl << "Error at line no " << lineNo << ": Unrecognized character '" << yytext << "'" << endl;
    errorNo++;
}


%%
int main(int argc, char** argv) {
    if (argc < 2) {
        cout << "Specify input file" << endl;
    } else {
        logOut.open("1805093_log.txt");
        tokenOut.open("1805093_token.txt");

        yyin = fopen(argv[1], "r");
        yylex();
        fclose(yyin);   

        st.printSymbols(logOut);
        logOut << endl;
        logOut << "Total lines: " << lineNo << endl;
        logOut << "Total errors: " << errorNo << endl;

        logOut.close();
        tokenOut.close();
    }
    

    return 0;
}
