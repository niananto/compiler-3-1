%option noyywrap

%x CHAR_STATE
%x STR
%x S_CMNT
%x M_CMNT

%{
#include <bits/stdc++.h>
#include "includes/SymbolTable.h"
#include "y.tab.h"
using namespace std;

void yyerror(char *);

extern ofstream logOut;
extern ofstream errorOut;

unsigned long lineNo = 1;
unsigned long startLineNo;
unsigned long errorNo = 0;

string curr;
string currExact;

%}

whitespace [ \t\f\v\r]+
newline \r?\n
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
"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"do" {return DO;}
"int" {return INT;}
"float" {return FLOAT;}
"double" {return DOUBLE;}
"char" {return CHAR;}
"return" {return RETURN;}
"continue" {return CONTINUE;}
"void" {return VOID;}
"printf" {return PRINTLN;}
"println" {return PRINTLN;}

{letter_}({letter_}|{digit})* {
    // will be changing this "ID" type later
    yylval.symbol = new SymbolInfo(yytext, "ID");
    return ID;
}
{digit}+ {
    yylval.symbol = new SymbolInfo(yytext, "CONST_INT");
    return CONST_INT;
}
{digit}*(\.{digit}+)?(([eE][+-])?{digit}+)? {
    yylval.symbol = new SymbolInfo(yytext, "CONST_FLOAT");
    return CONST_FLOAT;
}
({digit}*\.{digit}+(\.{digit}*)+)+ {
    logOut << endl << "Error at line " << lineNo << ": Too many decimal points " << yytext << endl;
    errorOut << endl << "Error at line " << lineNo << ": Too many decimal points " << yytext << endl;
    errorNo++;

    yylval.symbol = new SymbolInfo(yytext, "ERROR_FLOAT");
    return ERROR_FLOAT;
}
({digit}*\.?{digit}*[eE][+-]?{digit}*\.{digit}*)|({digit}*\.([eE][+-]?{digit}*\.?{digit}*)?) {
    logOut << endl << "Error at line " << lineNo << ": Ill formed number " << yytext << endl;
    errorOut << endl << "Error at line " << lineNo << ": Ill formed number " << yytext << endl;
    errorNo++;

    yylval.symbol = new SymbolInfo(yytext, "ERROR_FLOAT");
    return ERROR_FLOAT;
}
{digit}+{letter_}+ {
    logOut << endl << "Error at line " << lineNo << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl;
    errorOut << endl << "Error at line " << lineNo << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl;
    errorNo++;

    // considering this ID for error recovery
    yylval.symbol = new SymbolInfo(yytext, "ID");
    return ID;
}
"+"|"-" {
    yylval.symbol = new SymbolInfo(yytext, "ADDOP");
    return ADDOP;
}
"*"|"/"|"%" {
    yylval.symbol = new SymbolInfo(yytext, "MULOP");
    return MULOP;
}
"++" {return INCOP;}
"--" {return DECOP;}
"<"|"<="|">"|">="|"=="|"!=" {
    yylval.symbol = new SymbolInfo(yytext, "RELOP");
    return RELOP;
}
"=" {return ASSIGNOP;}
"&&"|"||" {
    yylval.symbol = new SymbolInfo(yytext, "LOGICOP");
    return LOGICOP;
}
"!" {return NOT;}
"(" {return LPAREN;}
")" {return RPAREN;}
"{" {
    // enter scope
    // handled in bison
    return LCURL;
}
"}" {
    // exit scope
    // handled in bison
    return RCURL;
}
"[" {return LTHIRD;}
"]" {return RTHIRD;}
"," {return COMMA;}
";" {return SEMICOLON;}
\' {
    curr = "";
    currExact = "";
    BEGIN CHAR_STATE;
}
<CHAR_STATE>\\n {
    curr += '\n';
    currExact += "\\n";
}
<CHAR_STATE>\\t {
    curr += '\t';
    currExact += "\\t";
}
<CHAR_STATE>\\\\ {
    curr += '\\';
    currExact += "\\\\";
}
<CHAR_STATE>\\\" {
    curr += '\"';
    currExact += "\\\"";
}
<CHAR_STATE>\\\' {
    curr += '\'';
    currExact += "\\\'";    
}
<CHAR_STATE>\\a {
    curr += '\a';
    currExact += "\\a";
}
<CHAR_STATE>\\f {
    curr += '\f';
    currExact += "\\f";
}
<CHAR_STATE>\\r {
    curr += '\r';
    currExact += "\\r";
}
<CHAR_STATE>\\b {
    curr += '\b';
    currExact += "\\b";
}
<CHAR_STATE>\\v {
    curr += '\v';
    currExact += "\\v";
}
<CHAR_STATE>\\0 {
    curr += '\0';
    currExact += "\\0";
}
<CHAR_STATE><<EOF>> {
    logOut << endl << "Error at line " << lineNo << ": Unterminated character '" << currExact << endl;
    errorNo++;
    BEGIN INITIAL;
}
<CHAR_STATE>{newline} {
    logOut << endl << "Error at line " << lineNo << ": Unterminated character '" << currExact << endl;
    errorNo++;
    lineNo++;
    BEGIN INITIAL;
}
<CHAR_STATE>\' {
    if ((curr.length() == 1) || (curr.length() == 0 && currExact == "\\0")) {
        // logOut << endl << "Line no " << lineNo << ": Token <CONST_CHAR> Lexeme '" << currExact << "' found ";
        // logOut << "--> <CHAR_CONST, " << curr << "> " << endl;
        // st.insert("'"+currExact+"'", "CONST_CHAR", logOut);
        // logOut << endl;
        // tokenOut << "<CHAR_CONST, " << curr << "> ";
    } else if(curr.length() == 0) {
        logOut << endl << "Error at line " << lineNo << ": Empty character constant error '" << currExact << "'" << endl;
        errorOut << endl << "Error at line " << lineNo << ": Empty character constant error '" << currExact << "'" << endl;
        errorNo++;
    } else {
        logOut << endl << "Error at line " << lineNo << ": Multi character constant error '" << currExact << "'" << endl;
        errorOut << endl << "Error at line " << lineNo << ": Multi character constant error '" << currExact << "'" << endl;
        errorNo++;
    }

    BEGIN INITIAL;
}
<CHAR_STATE>. {
    curr += yytext;
    currExact += yytext;
}
\" {
    curr = "";
    currExact = "";
    startLineNo = lineNo;
    BEGIN STR;
}
<STR>\\n {
    curr += '\n';
    currExact += "\\n";
}
<STR>\\t {
    curr += '\t';
    currExact += "\\t";
}
<STR>\\\\ {
    curr += '\\';
    currExact += "\\\\";
}
<STR>\\\" {
    curr += '\"';
    currExact += "\\\"";
}
<STR>\\\' {
    curr += '\'';
    currExact += "\\\'";
}
<STR>\\a {
    curr += '\a';
    currExact += "\\a";
}
<STR>\\f {
    curr += '\f';
    currExact += "\\f";
}
<STR>\\r {
    curr += '\r';
    currExact += "\\r";
}
<STR>\\b {
    curr += '\b';
    currExact += "\\b";
}
<STR>\\v {
    curr += '\v';
    currExact += "\\v";
}
<STR>\\0 {
    curr += '\0';
    currExact += "\\0";
}
<STR>\\\r\n {
    currExact += "\\\r\n";
    lineNo++;
}
<STR>\\\n {
    currExact += "\\\n";
    lineNo++;
}
<STR>{newline} {
    logOut << endl << "Error at line " << startLineNo << ": Unterminated String \"" << currExact << endl;
    errorOut << endl << "Error at line " << startLineNo << ": Unterminated String \"" << currExact << endl;
    errorNo++;
    lineNo++;
    BEGIN INITIAL;
}
<STR><<EOF>> {
    logOut << endl << "Error at line " << startLineNo << ": Unterminated String \"" << currExact << "\"" << endl;
    errorOut << endl << "Error at line " << startLineNo << ": Unterminated String \"" << currExact << "\"" << endl;
    errorNo++;
    BEGIN INITIAL;
}
<STR>\" {
    // logOut << endl << "Line no " << startLineNo << ": Token <STRING> Lexeme \"" << currExact << "\" found ";
    // logOut << "--> <STRING, \"" << curr << "\"> " << endl;
    // tokenOut << "<STRING, \"" << curr << "\"> ";
    BEGIN INITIAL;
}
<STR>. {
    curr += yytext;
    currExact += yytext;
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
    // logOut << endl << "Line " << startLineNo << ": Token <COMMENT> Lexeme //" << currExact << " found" << endl;
    lineNo++;
    BEGIN INITIAL;
}
<S_CMNT><<EOF>> {
    // logOut << endl << "Line " << startLineNo << ": Token <COMMENT> Lexeme //" << currExact << " found" << endl;
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
    // logOut << endl << "Line " << startLineNo << ": Token <COMMENT> Lexeme /*" << currExact << "*/ found" << endl;
    BEGIN INITIAL;
}
<M_CMNT><<EOF>> {
    logOut << endl << "Error at line " << startLineNo << ": Unterminated Comment /*" << currExact << endl;
    errorOut << endl << "Error at line " << startLineNo << ": Unterminated Comment /*" << currExact << endl;
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
    logOut << endl << "Error at line " << lineNo << ": Unrecognized character '" << yytext << "'" << endl;
    errorOut << endl << "Error at line " << lineNo << ": Unrecognized character '" << yytext << "'" << endl;
    errorNo++;
}
