%option noyywrap

%x TEMPLATE

%{
#include <bits/stdc++.h>
using namespace std;

string str = "";
unsigned depth = 0;
bool isInvalid = false;
bool checked = false;

void tokenize(string const &str, const char delim, vector<string> &out) {
    size_t start;
    size_t end = 0;
 
    while ((start = str.find_first_not_of(delim, end)) != string::npos)
    {
        end = str.find(delim, start);
        out.push_back(str.substr(start, end - start));
    }
}
%}

whitespace [ \t\f\a\v\b\r]
letter_ [a-zA-Z_]
newline [\r]?\n

%%

{whitespace}|{newline} {
    str = "";
}
{letter_} {
    str += yytext;
}
\< {
    depth++;
    str += yytext;
    BEGIN TEMPLATE;
}
<TEMPLATE>{letter_} {
    str += yytext;
}
<TEMPLATE>\< {
    depth++;
    str += yytext;
}
<TEMPLATE>\> {
    if (!checked) {
        vector<string> out;
        tokenize(str, '<', out);
        string t = out[0];
        for (int i = 1; i < out.size(); i++) {
            if (out[i] == t) {
                isInvalid = true;
                break;
            }
        }
        checked = true;
    }

    depth--;
    str += yytext;
    if (depth == 0) {
        if (isInvalid) {
            cout << "Invalid template " << str << endl;
            isInvalid = false;
            checked = false;
        } else {
            cout << str << endl;
        }
        depth = 0;
        str = "";
        BEGIN INITIAL;
    }
}
<TEMPLATE>{newline} {
    cout << "unfinished " << str << endl;
    depth = 0;
    str = "";
    BEGIN INITIAL;
}
<TEMPLATE><<EOF>> {
    cout << "unfinished " << str << endl;
    depth = 0;
    str = "";
    BEGIN INITIAL;
}
<TEMPLATE>. {
    cout << "unfinished " << str << endl;
    depth = 0;
    str = "";
    BEGIN INITIAL;
}
\> {
    cout << "extra > detected" << endl;
}
. {
    // do nothing
}

%%

int main(int argc, char const *argv[]) {
    if (argc != 2) {
        cout << "please specify input file" << endl;
        return 0;
    }

    yyin = fopen(argv[1], "r");
    yylex();
    fclose(yyin);
    
    return 0;
}