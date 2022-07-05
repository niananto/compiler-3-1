%option noyywrap

%x CHAR_STATE
%x STR
%x S_CMNT
%x M_CMNT

%{
#include <bits/stdc++.h>
#include "SymbolTable.h"
#include "y.tab.h"

#define YYSTYPE SymbolInfo*

using namespace std;

// extern YYSTYPE yylval;
// extern SymbolTable st;
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
    // cout << lineNo << endl;
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

{letter_}({letter_}|{digit})* {
    SymbolInfo* s = new SymbolInfo(yytext, "ID");
    yylval.st = s;
    return ID;
}
{digit}+ {
    SymbolInfo* s = new SymbolInfo(yytext, "CONST_INT");
    yylval.st = s;
    return CONST_INT;
}
{digit}*(\.{digit}+)?(([eE][+-])?{digit}+)? {
    SymbolInfo* s = new SymbolInfo(yytext, "CONST_FLOAT");
    yylval.st = s;
    return CONST_FLOAT;
}
({digit}*\.{digit}+(\.{digit}*)+)+ {
    logOut << endl << "Error at line no " << lineNo << ": Too many decimal points " << yytext << endl;
    errorOut << endl << "Error at line no " << lineNo << ": Too many decimal points " << yytext << endl;
    errorNo++;

    SymbolInfo* s = new SymbolInfo(yytext, "ERROR_FLOAT");
    yylval.st = s;
    return ERROR_FLOAT;
}
({digit}*\.?{digit}*[eE][+-]?{digit}*\.{digit}*)|({digit}*\.([eE][+-]?{digit}*\.?{digit}*)?) {
    logOut << endl << "Error at line no " << lineNo << ": Ill formed number " << yytext << endl;
    errorOut << endl << "Error at line no " << lineNo << ": Ill formed number " << yytext << endl;
    errorNo++;

    SymbolInfo* s = new SymbolInfo(yytext, "ERROR_FLOAT");
    yylval.st = s;
    return ERROR_FLOAT;
}
{digit}+{letter_}+ {
    logOut << endl << "Error at line no " << lineNo << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl;
    errorOut << endl << "Error at line no " << lineNo << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl;
    errorNo++;

    // considering this ID for error recovery
    SymbolInfo* s = new SymbolInfo(yytext, "ID");
    yylval.st = s;
    return ID;
}
"+"|"-" {
    SymbolInfo* s = new SymbolInfo(yytext, "ADDOP");
    yylval.st = (YYSTYPE)s;
    return ADDOP;
}
"*"|"/"|"%" {
    SymbolInfo* s = new SymbolInfo(yytext, "MULOP");
    yylval.st = s;
    return MULOP;
}
"++" {return INCOP;}
"--" {return DECOP;}
"<"|"<="|">"|">="|"=="|"!=" {
    SymbolInfo* s = new SymbolInfo(yytext, "RELOP");
    yylval.st = s;
    return RELOP;
}
"=" {return ASSIGNOP;}
"&&"|"||" {
    SymbolInfo* s = new SymbolInfo(yytext, "LOGICOP");
    yylval.st = s;
    return LOGICOP;
}
"!" {return NOT;}
"(" {return LPAREN;}
")" {return RPAREN;}
"{" {
    // enter scope
    return LCURL;
}
"}" {
    // exit scope
    return RCURL;
}
"[" {return LTHIRD;}
"]" {return RTHIRD;}
"," {return COMMA;}
";" {return SEMICOLON;}
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
    errorOut << endl << "Error at line no " << startLineNo << ": Unterminated Comment /*" << currExact << endl;
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
    errorOut << endl << "Error at line no " << lineNo << ": Unrecognized character '" << yytext << "'" << endl;
    errorNo++;
}
