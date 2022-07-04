%option noyywrap

%x string_state_start
%x comment_start
%x multicomment_start
%x const_char_start
%x const_char_end
%x const_special_char_start
%x multichar
%X multichar_end

%{
#include <bits/stdc++.h>
#include "SymbolTable.h"

int line_count=1;
int store_line_count;
int error_count=0;
SymbolTable ST{7};
ofstream logout;
ofstream tokenout;

string log_char1="";
string token_char1="";

string log_st1="";
string token_st1="";

string log_comm1="";
string log_multi="";

%}
WHITESPACE [ \t\f\r\v]+
LETTER [a-zA-Z]
DIGIT [0-9]

FLOAT_LITERALS {DIGIT}+?(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?
CHARACTERS [a-zA-Z0-9]
NEWLINE \n
INCOP ("--"|"++")
RELOP ("<"|"<="|">"|">="|"=="|"!=")
LOGICOP ("&&"|"||")
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*
%%

{NEWLINE} {line_count++;}
{WHITESPACE} { }



"if"	{
			tokenout<<"<IF> ";
			logout<<"Line no : "<<line_count<<" TOKEN <IF> Lexeme "<<yytext<<" found\n"<<endl;
		}

"for"	{
			tokenout<<"<FOR> ";
			logout<<"Line no :"<<line_count<<" TOKEN <FOR> Lexeme "<<yytext<<" found\n"<<endl;
		}

"do"	{
			tokenout<<"<DO> ";
			logout<<"Line no :"<<line_count<<" TOKEN <DO> Lexeme "<<yytext<<" found\n"<<endl;
		}


"int"	{
			tokenout<<"<INT> ";
			logout<<"Line no :"<<line_count<<" TOKEN <INT> Lexeme "<<yytext<<" found\n"<<endl;
		}

"float"	{
			tokenout<<"<FLOAT> ";
			logout<<"Line no :"<<line_count<<" TOKEN <FLOAT> Lexeme "<<yytext<<" found\n"<<endl;
		}

"void"	{
			tokenout<<"<VOID> ";
			logout<<"Line no : "<<line_count<<" TOKEN <VOID> Lexeme "<<yytext<<" found\n"<<endl;
		}

"switch"	{
			tokenout<<"<SWITCH> ";
			logout<<"Line no : "<<line_count<<" TOKEN <SWITCH> Lexeme "<<yytext<<" found\n"<<endl;
		}

"default"	{
			tokenout<<"<DEFAULT> ";
			logout<<"Line no : "<<line_count<<" TOKEN <DEFAULT> Lexeme "<<yytext<<" found\n"<<endl;
		}


"else"	{
			tokenout<<"<ELSE> ";
			logout<<"Line no : "<<line_count<<" TOKEN <ELSE> Lexeme "<<yytext<<" found\n"<<endl;
		}


"while"	{
			tokenout<<"<WHILE> ";
			logout<<"Line no : "<<line_count<<" TOKEN <WHILE> Lexeme "<<yytext<<" found\n"<<endl;
		}

"break"	{
			tokenout<<"<BREAK> ";
			logout<<"Line no : "<<line_count<<" TOKEN <BREAK> Lexeme "<<yytext<<" found\n"<<endl;
		}

"char"	{
			tokenout<<"<CHAR> ";
			logout<<"Line no : "<<line_count<<" TOKEN <CHAR> Lexeme "<<yytext<<" found\n"<<endl;
		}


"double" {
			tokenout<<"<DOUBLE> ";
			logout<<"Line no : "<<line_count<<" TOKEN <DOUBLE> Lexeme "<<yytext<<" found\n"<<endl;
		}


"return" {
			tokenout<<"<RETURN> ";
			logout<<"Line no : "<<line_count<<" TOKEN <RETURN> Lexeme "<<yytext<<" found\n"<<endl;
		}

"case"	{
			tokenout<<"<CASE> ";
			logout<<"Line no : "<<line_count<<" TOKEN <CASE> Lexeme "<<yytext<<" found\n"<<endl;
		}

"continue" {
			tokenout<<"<CONTINUE> ";
			logout<<"Line no : "<<line_count<<" TOKEN <CONTINUE> Lexeme "<<yytext<<" found\n"<<endl;
		}



({DIGIT}+\.{DIGIT}+\.{DIGIT}+)+ {

		logout << "Error at line no " <<line_count<< ": " << "Too Many Decimal Points :" <<  yytext << endl;
		logout << endl;
		error_count++;
}
{DIGIT}+([Ee][+-]?{DIGIT}+)+(\.{DIGIT}+)+	{

		logout << "Error at line no " <<line_count<< ": " << "Ill formed number :" <<  yytext << endl;
		logout << endl;
		error_count++;

}
{DIGIT}+(\.[^{DIGIT}])	{
			logout<<"Error at line no "<<line_count<<": Ill Formed Number "<<yytext<<endl;
			error_count++;
			BEGIN INITIAL;
		}



({DIGIT}+{IDENTIFIER}+)+  {
		logout << "Error at line no " <<line_count<< ": " << "Invalid prefix on ID or invalid suffix on Number:" <<  yytext << endl;
		logout << endl;
		error_count++;
}



{DIGIT}+ 	{
			tokenout<<"<CONST_INT, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <CONST_INT> Lexeme "<<yytext<<" found\n"<<endl;
			bool flag= ST.Insert(yytext, "CONST_INT" );

			if(flag==true){
				string print= ST.printAllScopeTable();
                logout<<print;
                logout<<endl;
				//insert in symbol table and print symbol table content(only non empty buckets)
}
			else if(flag==false)
			{
				logout<<yytext<<" already exists in current ScopeTable"<<endl;
				logout<<endl;
			}
}
{FLOAT_LITERALS} {
			tokenout<<"<CONST_FLOAT, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <CONST_FLOAT> Lexeme "<<yytext<<" found\n"<<endl;
				bool flag= ST.Insert(yytext, "CONST_FLOAT" );

			if(flag==true){
				string print= ST.printAllScopeTable();
                logout<<print;
                logout<<endl;
				//insert in symbol table and print symbol table content(only non empty buckets)
			}
			else if(flag==false)
			{
				logout<<yytext<<" already exists in current ScopeTable"<<endl;
				logout<<endl;
			}
			}



"+" 	|
"-"  	{
			tokenout<<"<ADDOP, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <ADDOP> Lexeme "<<yytext<<" found\n"<<endl;
		}

"*"		|
"/"		|
"%"		 {
			tokenout<<"<MULOP, " <<yytext<<">";
			logout<<"Line no :  "<<line_count<<" TOKEN <MULOP> Lexeme "<<yytext<<" found\n"<<endl;
		}

{INCOP} {
			tokenout<<"<INCOP, " <<yytext<<">";
			logout<<"Line no :  "<<line_count<<" TOKEN <INCOP> Lexeme "<<yytext<<" found\n"<<endl;

		}
{RELOP} {
			tokenout<<"<RELOP, " <<yytext<<">";
			logout<<"Line no :  "<<line_count<<" TOKEN <RELOP> Lexeme "<<yytext<<" found\n"<<endl;
		}


{LOGICOP} {
			tokenout<<"<LOGICOP, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <LOGICOP> Lexeme "<<yytext<<" found\n"<<endl;
		}

"=" {
			tokenout<<"<ASSIGNOP, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <ASSIGNOP> Lexeme "<<yytext<<" found\n"<<endl;
		}

"!"		{
			tokenout<<"<NOT, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <NOT> Lexeme "<<yytext<<" found\n"<<endl;
}

"("		{
			tokenout<<"<LPAREN, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <LPAREN> Lexeme "<<yytext<<" found\n"<<endl;
}

")"		{
			tokenout<<"<RPAREN, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <RPAREN> Lexeme "<<yytext<<" found\n"<<endl;
}

"{"		{
			tokenout<<"<LCURL, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <LCURL> Lexeme "<<yytext<<" found\n"<<endl;
			ST.EnterScope();
}


"}"		{
			tokenout<<"<RCURL, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <RCURL> Lexeme "<<yytext<<" found\n"<<endl;
			ST.ExitScope();
}
"["		{
			tokenout<<"<LTHIRD, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <LTHIRD> Lexeme "<<yytext<<" found\n"<<endl;
}

"]"		{
			tokenout<<"<RTHIRD, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <RTHIRD> Lexeme "<<yytext<<" found\n"<<endl;
}

","		{
			tokenout<<"<COMMA, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <COMMA> Lexeme "<<yytext<<" found\n"<<endl;
}

";"		{
			tokenout<<"<SEMICOLON, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <SEMICOLON> Lexeme "<<yytext<<" found\n"<<endl;
}



"\""	{
		log_st1="\"";
		token_st1="\"";
		store_line_count=line_count;
		BEGIN string_state_start;
}

<string_state_start>"\\"{NEWLINE}	{
		log_st1+="\\";
		log_st1+="\n";
		//store_line_count=line_count;
		line_count++;



}



<string_state_start>"\""	{

		token_st1+="\"";
		log_st1+="\"";
		tokenout<<"<STRING, " <<token_st1<<">";
		logout<<"Line no : "<<store_line_count<<" TOKEN <STRING> Lexeme "<<log_st1<<" found --> <STRING, "<<token_st1<<">"<<endl;
		BEGIN INITIAL;

}




<string_state_start>(["\\"]["n"])	{
		log_st1+=yytext;
		token_st1+="\n";

		//store_line_count=line_count;
		line_count++;


}

<string_state_start>(["\\"]["t"])	{
		log_st1+=yytext;
		token_st1+="\t";



}


<string_state_start>(["\\"]["'"])	{
		log_st1+=yytext;
		token_st1+="\'";



}

<string_state_start>(["\\"]["\\"])	{
		log_st1+=yytext;
		token_st1+="\\";



}


<string_state_start>(["\\"]["a"])	{
		log_st1+=yytext;
		token_st1+="a";




}

<string_state_start>(["\\"]["f"])	{
		log_st1+=yytext;
		token_st1+="\f";



}


<string_state_start>(["\\"]["r"])	{
		log_st1+=yytext;
		token_st1+="\r";



}

<string_state_start>(["\\"]["b"])	{
		log_st1+=yytext;
		token_st1+="\b";



}

<string_state_start>(["\\"]["v"])	{
		log_st1+=yytext;
		token_st1+="\v";



}

<string_state_start>(["\\"]["0"])	{
		log_st1+=yytext;
		token_st1+="\0";



}



<string_state_start>{NEWLINE} {
		log_st1+=yytext;
		logout << "Error at line no " <<store_line_count<< ": " << " Unterminated string : " <<  log_st1 << endl;
		logout << endl;
		error_count++;
		line_count++;
		BEGIN INITIAL;
}

<string_state_start><<EOF>> {
		log_st1+=yytext;
		logout << "Error at line no " <<store_line_count<< ": " << " Unterminated	 string : " <<  log_st1 << endl;
		logout << endl;
		error_count++;
		//line_count++;
		BEGIN INITIAL;
}
<string_state_start>. {
		log_st1+=yytext;
		token_st1+=yytext;

}

"//"	{
		log_comm1="//";

		BEGIN comment_start;
		store_line_count=line_count;

	}


<comment_start>{NEWLINE}	{

		logout<<"Line no : "<<line_count<<" TOKEN <COMMENT> Lexeme "<<log_comm1<<" found >"<<endl;
		line_count++;
		BEGIN INITIAL;
		//line_count++;


}

<comment_start>["\\"]{NEWLINE}	{
		log_comm1+="\\";
		log_comm1+="\n";
		line_count++;
		BEGIN comment_start;

}

<comment_start>. {
		log_comm1+=yytext;
		BEGIN comment_start;

}


(["/"]["*"]) {
		log_multi="/*";
		store_line_count=line_count;
		BEGIN multicomment_start;


	}


<multicomment_start>(["*"]["/"])		{
		log_multi+=yytext;
		logout<<"Line no : "<<store_line_count<<" TOKEN <COMMENT> Lexeme "<<log_multi<<" found >"<<endl;
		//line_count++;
		BEGIN INITIAL;

}

<multicomment_start>{NEWLINE}	{
		log_multi+="\n";
		line_count++;

}

<multicomment_start>. {
		log_multi+=yytext;

}
<multicomment_start><<EOF>> {
		log_multi+=yytext;
		logout << "Error at line no " <<store_line_count<< ": " << " Unterminated comment : " <<  log_multi << endl;
		logout << endl;
		error_count++;
		//line_count++;
		BEGIN INITIAL;

}


"'"	{
	log_char1+=yytext;
	BEGIN const_char_start;
}

<const_char_start>["\'"] {
		log_char1+=yytext;
		logout << "Error at line no " <<line_count<< ": " << " Empty character constant error: " <<  log_char1 << endl;
		logout << endl;
		error_count++;
		//line_count++;
		BEGIN INITIAL;

}


<const_char_start>{NEWLINE} {

		log_char1+=yytext;
		logout << "Error at line no " <<line_count<< ": " << " Unterminated character : " <<  log_char1 << endl;
		logout << endl;
		error_count++;
		log_char1="";
		line_count++;
		BEGIN INITIAL;
}

<const_char_start>["\\"] {
	log_char1+=yytext;
	BEGIN const_special_char_start;
}



<const_special_char_start>["t"] {
	log_char1+=yytext;
	token_char1='\t';
	BEGIN const_char_end;

}
<const_special_char_start>["n"]  {
	log_char1+=yytext;
		token_char1="\n";
	BEGIN const_char_end;

}

<const_special_char_start>["f"]  {
	log_char1+=yytext;
		token_char1='\f';
	BEGIN const_char_end;

}

<const_special_char_start>["v"]  {
	log_char1+=yytext;
		token_char1='\v';
	BEGIN const_char_end;

}

<const_special_char_start>["r"]  {
	log_char1+=yytext;
		token_char1='\r';
	BEGIN const_char_end;

}

<const_special_char_start>["a"]  {
	log_char1+=yytext;
		token_char1='\a';
	BEGIN const_char_end;

}


<const_special_char_start>["b"]  {
	log_char1+=yytext;
		token_char1='\b';
	BEGIN const_char_end;

}

<const_special_char_start>["0"]  {
	log_char1+=yytext;
		token_char1='\0';
	BEGIN const_char_end;


}


<const_special_char_start>["\'"]  {
	log_char1+=yytext;
		token_char1='\'';
	BEGIN const_char_end;


}

<const_special_char_start>["\\"]  {
	log_char1+=yytext;
		token_char1='\\';
	BEGIN const_char_end;


}
<const_special_char_start>{NEWLINE} {
	log_char1+=yytext;
	line_count++;
	BEGIN const_char_end;


}


<const_char_start>[^\n\t\r] {
	log_char1+=yytext;
	token_char1+=yytext;
	BEGIN const_char_end;
}




<const_char_end>["\'"] {
	log_char1+=yytext;
	logout<<"Line no : "<<line_count<<" TOKEN <CONST_CHAR> Lexeme "<<log_char1<<" found --> <CONST_CHAR, "<<token_char1<<">"<<endl;
	tokenout<<"<CONST_CHAR, " <<token_char1<<">";
	bool flag= ST.Insert(log_char1, "CONST_CHAR" );

			if(flag==true){
				string print= ST.printAllScopeTable();
                logout<<print;
                logout<<endl;
				//insert in symbol table and print symbol table content(only non empty buckets)
}
			else if(flag==false)
			{
				logout<<log_char1<<" already exists in current ScopeTable"<<endl;
				logout<<endl;
			}

	log_char1="";
	BEGIN INITIAL;
}



<const_char_end>{NEWLINE} {

		log_char1+=yytext;
		logout << "Error at line no " <<line_count<< ": " << " unterminated character : " <<  log_char1 << endl;
		logout << endl;
		error_count++;
		log_char1="";
		line_count++;
		BEGIN INITIAL;
}

<const_char_end>({WHITESPACE}+{NEWLINE}) {

		log_char1+=yytext;
		logout << "Error at line no " <<line_count<< ": " << " unterminated character : " <<  log_char1 << endl;
		logout << endl;
		error_count++;
		log_char1="";
		line_count++;
		BEGIN INITIAL;
}
<const_char_end>[^']	{
		log_char1+=yytext;
		logout << "Error at line no " <<line_count<< ": " << " multi constant error : " <<  log_char1 << endl;
		logout << endl;
		error_count++;
		log_char1="";
		//line_count++;
		BEGIN INITIAL;
}

<const_char_end><<EOF>> {

		log_char1+=yytext;
		logout << "Error at line no " <<line_count<< ": " << " unterminated character : " <<  log_char1 << endl;
		logout << endl;
		error_count++;
		log_char1="";
	//	line_count++;
		BEGIN INITIAL;
}







{IDENTIFIER} {
			tokenout<<"<ID, " <<yytext<<">";
			logout<<"Line no : "<<line_count<<" TOKEN <ID> Lexeme "<<yytext<<" found\n"<<endl;

			bool flag= ST.Insert(yytext, "ID" );

			if(flag==true){
				string print= ST.printAllScopeTable();
                logout<<print;
                logout<<endl;
				//insert in symbol table and print symbol table content(only non empty buckets)
}
			else if(flag==false)
			{
				logout<<yytext<<" already exists in current ScopeTable"<<endl;
				logout<<endl;
			}
}

<<EOF>>	{
	logout<<ST.printAllScopeTable();
	logout<<endl;
	logout<<"Total lines: "<<line_count-1<<endl;
	logout<<"Total errors :" << error_count<<endl;
	return 0;
}

.	{
	logout << "Error at line no " <<line_count<< ": " << " unrecognized character : "<<yytext <<endl;
	logout<<endl;
}


%%

int main(int argc,char *argv[]){

	if(argc!=2){
		cout<<"Please provide input file name and try again\n";
		return 0;
	}

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		cout<<"Cannot open specified file\n";
		return 0;
	}

	logout.open("log.txt");
	tokenout.open("token.txt");

	yyin= fin;
	yylex();
	fclose(yyin);
	tokenout.close();
	logout.close();

	return 0;
}
