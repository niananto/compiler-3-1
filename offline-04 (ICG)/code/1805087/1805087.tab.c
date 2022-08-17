/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "3.5.1"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 1 "1805087.y"

    #include<bits/stdc++.h>
    #include<iostream>
    #include<string>
    #include<list>
    #include<iterator>
    #include<utility>
    #include<fstream>
    #include "symbolTable.h"
    #include "fileUtils.h"
    #include "optimizer.h"
    
    using namespace std;
    
    extern FILE* yyin;
    extern int lineCount;   
    extern int errorCount;
    
    extern string toUpper(string str);

    SymbolTable symbolTable(31);

    int labelCount = 0;                     //label count for generating labels
    int tempCount = 0;                      //temporary variable count for generating temporary variables
    int asmLineCount = 0;                   //line count for generating assembly code
    int asmDataSegmentEndLine = 0;          //line count for end of data segment
    int asmCodeSegmentEndLine = 0;          //line count for end of code segment

    list<pair<string, string> > parameters; // Contains the parameter list <name, type> of the currently declared function
    list<SymbolInfo*> argList;              // Contans argument list while calling a function
    string varType;                         // Contains recent variable type
    string funcName, funcReturnType;
    bool hasDeclaredId = false, hasFuncDeclared = false, hasFuncDefined = false, hasFoundReturn = false;

    ofstream logFile;
    ofstream errorFile;

    int yyparse(void);
    int yylex(void);

    /**
    * @returns a new label name that can be used in the assembly code
    */
    string newLabel() {
        string label = "L_" + to_string(++labelCount);
        return label;
    }

    /**
    * @returns a new template name that can be used in the assembly code
    */
    string newTemp() {
        string temp = "t" + to_string(tempCount++);
        return temp;
    }

    void logFoundRule(string variable, string rule, string matchedString) {
        logFile << "Line " << lineCount << ": " << variable << " : " << rule << "\n\n";
        logFile << matchedString << "\n\n";
    }

    void logFoundRule(string variable, string rule) {
        logFile << "Line " << lineCount << ": " << variable << " : " << rule << "\n\n";
    }

    void logMatchedString(string matchedString) {
        logFile << matchedString << "\n\n";
    }

    void errorMessage(string message) {
        errorCount++;
        errorFile << "Error at line " << lineCount << ": " << message << "\n\n";
        logFile << "Error at line " << lineCount << ": " << message << "\n\n";
    }

    void yyerror(string s) {
        errorMessage("Syntax Error");
        // cout << s << endl;
    }

    int stringLineCount(string str) {
        int count = 0;
        for (int i = 0; i < str.length(); i++) {
            if (str[i] == '\n') {
                count++;
            }
        }
        return count;
    }
    /**
     * increases the end line of code segment along with asmLineCount
     * @param incAmount amount by which the end line of code segment should be increased
     */
    void increaseCodeSegmentEndLine(int incAmount) {
        asmCodeSegmentEndLine += incAmount;
        asmLineCount += incAmount;
    }

    void writeInCodeSegment(string str) {
        if(errorCount > 0) {
            return;
        }

        writeAt("code.asm", str, asmCodeSegmentEndLine);
        increaseCodeSegmentEndLine(stringLineCount(str) + 1);
    }

    void insertId(string idName, string type, int arraySize = 0) {
        if(symbolTable.hasFunctionWithName(idName)) {
            errorMessage("Multiple declaration of " + idName + ". " + idName + " is a function");
        } else {
            SymbolInfo* idInfo = symbolTable.insert(idName, "ID", "CONST_" + toUpper(type), arraySize);
            if(idInfo == NULL) {
                errorMessage("Multiple declaration of " + idName);
            } else if(symbolTable.getCurrentScopeID() != "1" && errorCount == 0) {
                if(arraySize == 0) {
                    writeInCodeSegment("\t\tPUSH BX    ;line no " + to_string(lineCount) + ": " + idName + " declared");
                } else {
                    // totalIdsInCurrent function has already increased by arraysize during calling insert
                    int arrayOffsetEnd = symbolTable.getTotalIdsInCurrentFunction() * 2;
                    // string code = "\t\t;line no " + to_string(lineCount) + ": 
                    // for(int i=0; i<arraySize; i++) {
                    //     code += "\n\t\tPUSH BX";
                    // }
                    string code = "\t\tMOV SP, [BP+-" + to_string(arrayOffsetEnd) + "]\t;array " + idName + "[" + to_string(arraySize) + "] declared";

                    writeInCodeSegment(code);
                }

                // cout << idName << " offset = " << ((IdInfo*)idInfo)->getStackOffset() << endl;
            }
        }
    }

    /**
     * Checks if the two symbols have the same type or not.
     * If the types are not the same, it shows the message.
     * @param lSymbol left symbolInfo
     * @param rSymbol right symbolInfo
     * @param message show this error message if type mismatch occurs
     */
    void typeCheck(SymbolInfo* lSymbol, SymbolInfo* rSymbol, string message) {
        string lType = lSymbol->getType();
        string rType = rSymbol->getType();

        if(lType == "UNDEC" || rType == "UNDEC")
            return;

        if(lType != rSymbol->getType()) {
            if(lType[lType.size()-1] == '*')
                errorMessage(message +", " + lSymbol->getName() + " is an array");
            else if(rType[rType.size()-1] == '*')
                errorMessage(message + ", " + rSymbol->getName() + " is an array");
            else {
                errorMessage(message);
            }
        }
    }

    /**
     * Checks if the right symbols can be type casted to left symbol or not.
     * If type casting is not possible, it shows the message.
     * @param lSymbol left symbolInfo
     * @param rSymbol right symbolInfo
     * @param message show this error message if type casting fails
     */
    string typeCast(SymbolInfo* lSymbol, SymbolInfo* rSymbol, string message) {
        string lType = lSymbol->getType();
        string rType = rSymbol->getType();

        // if any of the two is an array then there should be no type casting
        if(lType[lType.size()-1] == '*' || rType[rType.size()-1] == '*') 
            typeCheck(lSymbol, rSymbol, message);
        // if lType is float then rType can be any of float, int or char
        // and it will be type casted to float
        else if(lType == "CONST_FLOAT")
            return "CONST_FLOAT";
        // if lType is int then rType can be any of int or char
        // and it will be type casted to int
        else if(lType == "CONST_INT" && (rType == "CONST_CHAR"  || rType == "CONST_INT"))
            return "CONST_INT";
        // else lType and rType have to be the same
        else 
            typeCheck(lSymbol, rSymbol, message);
        
        return lType;
    }

    /**
     * Checks if any of the symbol can be type casted to upper type
     * to match with the other symbol type.
     * If type casting is not possible, it shows the message.
     * @param lSymbol left symbolInfo
     * @param rSymbol right symbolInfo
     * @param message show this error message if type casting fails
     */
    string typeCastIgnoreSide(SymbolInfo* lSymbol, SymbolInfo* rSymbol, string message) {
        string lType = lSymbol->getType();
        string rType = rSymbol->getType();

        // if any of the two is an array then there should be no type casting
        if(lType[lType.size()-1] == '*' || rType[rType.size()-1] == '*') 
            typeCheck(lSymbol, rSymbol, message);
        // if any of the two is float then return float
        else if(lType == "CONST_FLOAT" || rType == "CONST_FLOAT")
            return "CONST_FLOAT";
        // if any of the two is int then return int
        else if(lType == "CONST_INT" || rType == "CONST_INT")
            return "CONST_INT";   
        // else lType and rType have to be the same
        else 
            typeCheck(lSymbol, rSymbol, message);    
        
        return lType;
    }

    bool isVoidFunc(string type) {
        if(type == "FUNC_VOID") {
            errorMessage("Void function used in expression");
            return true;
        } else {
            return false;
        }
    }

    /** 
    * Checks if the ID is already declared or not
    * If declared then throw an error
    * else inserts the function in the root scope
    * and updates the return type
    */
    void handleFuncDeclaration(string name, string returnType) {
        funcName = name;
        funcReturnType = returnType;
        FunctionInfo* functionInfo = (FunctionInfo*)symbolTable.insert(name, "ID", true);

        if(functionInfo == NULL) {
            SymbolInfo* symbolInfo = symbolTable.lookUp(name);
            if(symbolInfo->getIsFunction()) {
                hasFuncDeclared = true;
                functionInfo = (FunctionInfo*)symbolInfo;

                if(functionInfo->getIsDefined())
                    hasFuncDefined = true;    
            } else {
                errorMessage("Multiple declaration of " + funcName);
                hasDeclaredId = true;
            }
        } else {
            functionInfo->setReturnType(returnType);
            // Add all the parameters to the function and then remove
            // those from the parameter list
            list<pair<string, string> >::iterator it = parameters.begin();
            
            int i = 0;
            while(it != parameters.end()) {
                // function definition must have parameter names
                if((*it).first == "")
                    errorMessage(to_string(i + 1) + "th parameter's name not given in function definition of " + funcName);

                functionInfo->addParameter("CONST_" + toUpper((*it).second));
                it++;
                i++;
            }
        }
    }

    void handleFuncDefinition() {
        // Check if it is a function
        // if not then throw an error
        if(hasDeclaredId) {
            return;
        }
        // if the function is already defined, throw an error
        if(hasFuncDefined) {
            errorMessage("Multiple definition of the function " + funcName);
            return;
        }

        // Look up the functionInfo that has been inserted recently in the func_prototype
        FunctionInfo* functionInfo = (FunctionInfo*)symbolTable.lookUpCurrentScope(funcName);
        // Set isDefined
        functionInfo->setIsDefined();      

        if(funcReturnType == functionInfo->getReturnType() && functionInfo->getName() != "main" &&
            functionInfo->getReturnType() != "CONST_VOID" && !hasFoundReturn) {
            errorMessage("Function definition of non void return type ended without any return statement");
        }
    }

    void printSummary() {
        logFile << symbolTable.getNonEmptyList() << '\n';
        logFile << "Total lines: " << lineCount << "\n";
        logFile << "Total errors: " << errorCount << "\n";
    }

    void declareGlobalVariable(string name, string type) {
        if(varType == "float") {
            cout << "Error: float type variable is not supported" << endl;
            errorMessage("float type variable is not supported");
        }

        if(errorCount > 0) {
            return;
        }

        string code = "\t" + name + " DW ?";
        asmLineCount++;
        asmCodeSegmentEndLine++;
        writeAt("code.asm", code, asmDataSegmentEndLine++);
    }

    void declareGlobalArray(string name, string type, string arraySize) {
        if(varType == "float") {
            cout << "Error: float type variable is not supported" << endl;
            errorMessage("float type variable is not supported");
        }

        if(errorCount > 0) {
            return;
        }

        string code = "\t" + name + " DW " + arraySize + " DUP(?)";
        asmLineCount++;
        asmCodeSegmentEndLine++;
        writeAt("code.asm", code, asmDataSegmentEndLine++);
    }

    void initializeAsmMain() {
        if(errorCount > 0) {
            return;
        }

        string code = "\t\tMOV AX, @DATA\n\t\tMOV DS, AX";
        write("code.asm", code, true);
        increaseCodeSegmentEndLine(2);
    }

    void declareProcedure(string id) {
        symbolTable.resetTotalIdsInCurrentFunction();

        if(errorCount > 0) {
            return;
        }

        string code = "\t" + id + " PROC";
        write("code.asm", code, true);
        increaseCodeSegmentEndLine(1);

        if(id == "main") {
            initializeAsmMain();
        } else {
            // ASM code for entering the function
            code = "\t\t;entering function: " + funcName + "\n";
            code += "\t\tPUSH BP\t;saving BP\n";
            code += "\t\tMOV BP, SP\t;BP = SP (all the offsets in this function are based on this value of BP)\n";
            write("code.asm", code, true);
            increaseCodeSegmentEndLine(4);
        }        
    }

    void terminateAsmMain() {
        if(errorCount > 0) {
            return;
        }

        string code = "\t\tMOV AH, 4CH\n\t\tINT 21H";
        write("code.asm", code, true);
        increaseCodeSegmentEndLine(2);
    }

    void endProcedure(string id, int noOfParams) {
        if(errorCount > 0) {
            return;
        }

        if(funcName == "main") {
            terminateAsmMain();
        } else if(funcReturnType == "CONST_VOID") {
            string code = "\t\tMOV SP, BP\t;Restoring SP at the end of function\n";
            code += "\t\tPOP BP\t;restoring BP at the end of function\n";
            code += "\t\tRET " + (noOfParams ? to_string(noOfParams * 2) : "");
            // write("code.asm", code, true);
            // increaseCodeSegmentEndLine(3);
            writeInCodeSegment(code);
        }

        write("code.asm", "\t" + id + " ENDP", true);
        increaseCodeSegmentEndLine(1);
    }

    string relopSymbolToAsmJumpText(string symbol) {
        if(symbol == "==")
            return "JE";
        else if(symbol == "!=")
            return "JNE";
        else if(symbol == "<")
            return "JL";
        else if(symbol == "<=")
            return "JLE";
        else if(symbol == ">")
            return "JG";
        else if(symbol == ">=")
            return "JGE";
        else
            return "";
    }

#line 479 "1805087.tab.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 1
#endif

/* Use api.header.include to #include this header
   instead of duplicating it here.  */
#ifndef YY_YY_1805087_TAB_H_INCLUDED
# define YY_YY_1805087_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    IF = 258,
    ELSE = 259,
    FOR = 260,
    WHILE = 261,
    DO = 262,
    BREAK = 263,
    INT = 264,
    CHAR = 265,
    FLOAT = 266,
    DOUBLE = 267,
    VOID = 268,
    RETURN = 269,
    SWITCH = 270,
    CASE = 271,
    DEFAULT = 272,
    CONTINUE = 273,
    PRINTLN = 274,
    STRING = 275,
    NOT = 276,
    LPAREN = 277,
    RPAREN = 278,
    LCURL = 279,
    RCURL = 280,
    LTHIRD = 281,
    RTHIRD = 282,
    COMMA = 283,
    SEMICOLON = 284,
    ASSIGNOP = 285,
    CONST_INT = 286,
    CONST_FLOAT = 287,
    CONST_CHAR = 288,
    ADDOP = 289,
    MULOP = 290,
    RELOP = 291,
    LOGICOP = 292,
    INCOP = 293,
    ID = 294,
    ARITHASSIGNOP = 295,
    PREFIX_INCOP = 296,
    POSTFIX_INCOP = 297,
    LOWER_THAN_ELSE = 298
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 412 "1805087.y"

    SymbolInfo* symbolInfo;
    int intValue;

#line 580 "1805087.tab.c"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_1805087_TAB_H_INCLUDED  */



#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))

/* Stored state numbers (used for stacks). */
typedef yytype_uint8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif

#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(E) ((void) (E))
#else
# define YYUSE(E) /* empty */
#endif

#if defined __GNUC__ && ! defined __ICC && 407 <= __GNUC__ * 100 + __GNUC_MINOR__
/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                            \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  12
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   219

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  44
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  34
/* YYNRULES -- Number of rules.  */
#define YYNRULES  84
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  143

#define YYUNDEFTOK  2
#define YYMAXUTOK   298


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   445,   445,   454,   460,   467,   472,   476,   483,   496,
     507,   521,   539,   558,   578,   624,   643,   659,   663,   680,
     697,   707,   717,   733,   739,   745,   754,   770,   776,   792,
     803,   812,   827,   838,   842,   851,   867,   871,   875,   879,
     887,   899,   900,   879,   925,   935,   935,   959,   963,   959,
     992,  1015,  1026,  1062,  1085,  1089,  1099,  1108,  1131,  1196,
    1200,  1245,  1253,  1257,  1330,  1334,  1379,  1383,  1424,  1428,
    1484,  1500,  1522,  1529,  1536,  1599,  1604,  1612,  1616,  1620,
    1666,  1711,  1715,  1722,  1730
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 1
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "IF", "ELSE", "FOR", "WHILE", "DO",
  "BREAK", "INT", "CHAR", "FLOAT", "DOUBLE", "VOID", "RETURN", "SWITCH",
  "CASE", "DEFAULT", "CONTINUE", "PRINTLN", "STRING", "NOT", "LPAREN",
  "RPAREN", "LCURL", "RCURL", "LTHIRD", "RTHIRD", "COMMA", "SEMICOLON",
  "ASSIGNOP", "CONST_INT", "CONST_FLOAT", "CONST_CHAR", "ADDOP", "MULOP",
  "RELOP", "LOGICOP", "INCOP", "ID", "ARITHASSIGNOP", "PREFIX_INCOP",
  "POSTFIX_INCOP", "LOWER_THAN_ELSE", "$accept", "start", "program",
  "unit", "func_prototype", "func_declaration", "func_definition",
  "enter_scope", "parameter_list", "compound_statement", "var_declaration",
  "type_specifier", "declaration_list", "statements", "generate_if_block",
  "statement", "@1", "@2", "@3", "$@4", "@5", "@6", "@7",
  "expression_statement", "variable", "expression", "logic_expression",
  "rel_expression", "simple_expression", "term", "unary_expression",
  "factor", "argument_list", "arguments", YY_NULLPTR
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[NUM] -- (External) token number corresponding to the
   (internal) symbol number NUM (which must be that of a token).  */
static const yytype_int16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298
};
# endif

#define YYPACT_NINF (-69)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int16 yypact[] =
{
      56,   -69,   -69,   -69,     9,    56,   -69,    14,   -69,   -69,
     -69,    -5,   -69,   -69,   -69,   -69,   -69,   -69,    38,    20,
      78,    17,     1,    -3,     2,   -69,    32,    46,   -69,   180,
      48,   180,   180,   -69,   -69,   -69,   -69,   -69,   180,    37,
      79,   -69,   -69,    39,   115,   -69,   -69,    -7,    15,   -69,
      34,   -16,    42,   -69,   -69,   -69,    85,    49,    58,    68,
     -69,    88,   180,   166,    82,    21,    76,    81,   -69,    99,
     -69,    97,   -69,   180,   180,   101,   -69,   -69,    41,   -69,
     -69,   -69,   180,   180,   180,   180,   102,   -69,    26,   -69,
     -69,   -69,    16,   107,   -69,   180,   -69,   -69,   108,   -69,
     -69,   109,   105,   111,   -69,   -69,   -69,    42,   116,   -69,
     -69,   -69,    96,   114,   118,   -69,   166,   -69,    24,   -69,
     180,   -69,   -69,   -69,   -69,   152,   -69,   119,   -69,   -69,
     -69,   139,   -69,   152,   -69,   180,   -69,   152,   -69,   -69,
     128,   152,   -69
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       0,    23,    24,    25,     0,     2,     4,     0,     6,     7,
       5,     0,     1,     3,    12,    14,    11,    13,    30,     0,
       0,     0,     0,     0,     0,    22,     0,     0,    47,     0,
       0,     0,     0,    21,    54,    76,    77,    78,     0,     0,
      57,    38,    36,     0,     0,    33,    37,    73,     0,    59,
      62,    64,    66,    68,    72,    10,     0,    19,     0,     0,
      27,    26,     0,     0,     0,     0,     0,    73,    71,     0,
      70,    57,    80,    82,     0,    30,    20,    34,     0,    79,
      56,    55,     0,     0,     0,     0,     0,     8,     0,    18,
      32,    31,     0,     0,    39,     0,    53,    52,     0,    75,
      84,     0,    81,     0,    61,    60,    63,    67,    65,    69,
       9,    17,    16,     0,     0,    35,     0,    48,     0,    74,
       0,    58,    15,    29,    28,     0,    40,     0,    51,    50,
      83,    44,    41,     0,    45,     0,    49,     0,    42,    46,
       0,     0,    43
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
     -69,   -69,   -69,   147,   -69,   -69,   -69,   -69,   -69,   149,
      19,     8,   -69,   -69,   -69,   -43,   -69,   -69,   -69,   -69,
     -69,   -69,   -69,   -57,   -27,   -29,   -68,    77,    80,    84,
     -24,   -69,   -69,   -69
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     4,     5,     6,     7,     8,     9,    20,    56,    41,
      42,    43,    19,    44,   125,    45,   116,   132,   135,   140,
     137,    64,   127,    46,    47,    48,    49,    50,    51,    52,
      53,    54,   101,   102
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_uint8 yytable[] =
{
      65,    77,    58,    69,    67,   100,    94,    68,    11,    12,
     105,    67,    72,    11,    70,    14,    80,   113,    83,    10,
      84,    23,    96,    78,    10,   128,     1,   111,     2,    57,
       3,    79,    59,    93,    18,     1,    60,     2,    15,     3,
      55,    61,   104,    16,    81,   103,    67,   114,    24,    25,
      97,    67,   130,   129,    62,    67,    67,    67,    67,   126,
      21,   109,    31,    32,    22,     1,   117,     2,    63,     3,
      66,    82,    35,    36,    37,    38,    71,    85,    75,    39,
      40,    26,   131,    27,    28,    90,    86,     1,    89,     2,
     136,     3,    29,    67,   139,    91,   112,    30,   142,    31,
      32,    73,    15,    33,    95,    74,   138,    34,    87,    35,
      36,    37,    38,    88,    92,    98,    39,    40,    26,    79,
      27,    28,    99,    74,     1,   110,     2,    22,     3,    29,
     115,   118,   119,   120,    30,   122,    31,    32,   121,    15,
      76,   123,   133,   134,    34,   124,    35,    36,    37,    38,
      83,   141,    13,    39,    40,    26,    17,    27,    28,   106,
       0,     1,     0,     2,   108,     3,    29,   107,     0,     0,
       0,    30,     0,    31,    32,     0,    15,     0,     0,     0,
       0,    34,     0,    35,    36,    37,    38,    31,    32,     0,
      39,    40,     0,     0,     0,    34,     0,    35,    36,    37,
      38,    31,    32,     0,    39,    40,     0,     0,     0,     0,
       0,    35,    36,    37,    38,     0,     0,     0,    39,    40
};

static const yytype_int16 yycheck[] =
{
      29,    44,     1,    32,    31,    73,    63,    31,     0,     0,
      78,    38,    39,     5,    38,     1,     1,     1,    34,     0,
      36,     1,     1,    30,     5,     1,     9,     1,    11,    21,
      13,    38,    31,    62,    39,     9,    39,    11,    24,    13,
      23,    39,     1,    29,    29,    74,    73,    31,    28,    29,
      29,    78,   120,    29,    22,    82,    83,    84,    85,   116,
      22,    85,    21,    22,    26,     9,    95,    11,    22,    13,
      22,    37,    31,    32,    33,    34,    39,    35,    39,    38,
      39,     3,   125,     5,     6,    27,     1,     9,    39,    11,
     133,    13,    14,   120,   137,    27,    88,    19,   141,    21,
      22,    22,    24,    25,    22,    26,   135,    29,    23,    31,
      32,    33,    34,    28,    26,    39,    38,    39,     3,    38,
       5,     6,    23,    26,     9,    23,    11,    26,    13,    14,
      23,    23,    23,    28,    19,    39,    21,    22,    27,    24,
      25,    27,    23,     4,    29,    27,    31,    32,    33,    34,
      34,    23,     5,    38,    39,     3,     7,     5,     6,    82,
      -1,     9,    -1,    11,    84,    13,    14,    83,    -1,    -1,
      -1,    19,    -1,    21,    22,    -1,    24,    -1,    -1,    -1,
      -1,    29,    -1,    31,    32,    33,    34,    21,    22,    -1,
      38,    39,    -1,    -1,    -1,    29,    -1,    31,    32,    33,
      34,    21,    22,    -1,    38,    39,    -1,    -1,    -1,    -1,
      -1,    31,    32,    33,    34,    -1,    -1,    -1,    38,    39
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,     9,    11,    13,    45,    46,    47,    48,    49,    50,
      54,    55,     0,    47,     1,    24,    29,    53,    39,    56,
      51,    22,    26,     1,    28,    29,     3,     5,     6,    14,
      19,    21,    22,    25,    29,    31,    32,    33,    34,    38,
      39,    53,    54,    55,    57,    59,    67,    68,    69,    70,
      71,    72,    73,    74,    75,    23,    52,    55,     1,    31,
      39,    39,    22,    22,    65,    69,    22,    68,    74,    69,
      74,    39,    68,    22,    26,    39,    25,    59,    30,    38,
       1,    29,    37,    34,    36,    35,     1,    23,    28,    39,
      27,    27,    26,    69,    67,    22,     1,    29,    39,    23,
      70,    76,    77,    69,     1,    70,    71,    73,    72,    74,
      23,     1,    55,     1,    31,    23,    60,    69,    23,    23,
      28,    27,    39,    27,    27,    58,    67,    66,     1,    29,
      70,    59,    61,    23,     4,    62,    59,    64,    69,    59,
      63,    23,    59
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_int8 yyr1[] =
{
       0,    44,    45,    46,    46,    47,    47,    47,    48,    48,
      48,    49,    49,    50,    51,    52,    52,    52,    52,    52,
      53,    53,    54,    55,    55,    55,    56,    56,    56,    56,
      56,    56,    56,    57,    57,    58,    59,    59,    59,    60,
      61,    62,    63,    59,    59,    64,    59,    65,    66,    59,
      59,    59,    59,    59,    67,    67,    67,    68,    68,    69,
      69,    69,    70,    70,    71,    71,    72,    72,    73,    73,
      74,    74,    74,    75,    75,    75,    75,    75,    75,    75,
      75,    76,    76,    77,    77
};

  /* YYR2[YYN] -- Number of symbols on the right hand side of rule YYN.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     2,     1,     1,     1,     1,     5,     6,
       4,     2,     2,     2,     0,     4,     3,     3,     2,     1,
       4,     3,     3,     1,     1,     1,     3,     3,     6,     6,
       1,     4,     4,     1,     2,     0,     1,     1,     1,     0,
       0,     0,     0,    11,     6,     0,     9,     0,     0,     7,
       5,     5,     3,     3,     1,     2,     2,     1,     4,     1,
       3,     3,     1,     3,     1,     3,     1,     3,     1,     3,
       2,     2,     1,     1,     4,     3,     1,     1,     1,     2,
       2,     1,     0,     3,     1
};


#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         (-2)
#define YYEOF           0

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Error token number */
#define YYTERROR        1
#define YYERRCODE       256



/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)

/* This macro is provided for backward compatibility. */
#ifndef YY_LOCATION_PRINT
# define YY_LOCATION_PRINT(File, Loc) ((void) 0)
#endif


# define YY_SYMBOL_PRINT(Title, Type, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Type, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo, int yytype, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YYUSE (yyoutput);
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyo, yytoknum[yytype], *yyvaluep);
# endif
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo, int yytype, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yytype < YYNTOKENS ? "token" : "nterm", yytname[yytype]);

  yy_symbol_value_print (yyo, yytype, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp, int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       yystos[+yyssp[yyi + 1 - yynrhs]],
                       &yyvsp[(yyi + 1) - (yynrhs)]
                                              );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen(S) (YY_CAST (YYPTRDIFF_T, strlen (S)))
#  else
/* Return the length of YYSTR.  */
static YYPTRDIFF_T
yystrlen (const char *yystr)
{
  YYPTRDIFF_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYPTRDIFF_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYPTRDIFF_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            else
              goto append;

          append:
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (yyres)
    return yystpcpy (yyres, yystr) - yyres;
  else
    return yystrlen (yystr);
}
# endif

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return 1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return 2 if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYPTRDIFF_T *yymsg_alloc, char **yymsg,
                yy_state_t *yyssp, int yytoken)
{
  enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat: reported tokens (one for the "unexpected",
     one per "expected"). */
  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
  /* Actual size of YYARG. */
  int yycount = 0;
  /* Cumulated lengths of YYARG.  */
  YYPTRDIFF_T yysize = 0;

  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yytoken != YYEMPTY)
    {
      int yyn = yypact[+*yyssp];
      YYPTRDIFF_T yysize0 = yytnamerr (YY_NULLPTR, yytname[yytoken]);
      yysize = yysize0;
      yyarg[yycount++] = yytname[yytoken];
      if (!yypact_value_is_default (yyn))
        {
          /* Start YYX at -YYN if negative to avoid negative indexes in
             YYCHECK.  In other words, skip the first -YYN actions for
             this state because they are default actions.  */
          int yyxbegin = yyn < 0 ? -yyn : 0;
          /* Stay within bounds of both yycheck and yytname.  */
          int yychecklim = YYLAST - yyn + 1;
          int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
          int yyx;

          for (yyx = yyxbegin; yyx < yyxend; ++yyx)
            if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR
                && !yytable_value_is_error (yytable[yyx + yyn]))
              {
                if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
                  {
                    yycount = 1;
                    yysize = yysize0;
                    break;
                  }
                yyarg[yycount++] = yytname[yyx];
                {
                  YYPTRDIFF_T yysize1
                    = yysize + yytnamerr (YY_NULLPTR, yytname[yyx]);
                  if (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM)
                    yysize = yysize1;
                  else
                    return 2;
                }
              }
        }
    }

  switch (yycount)
    {
# define YYCASE_(N, S)                      \
      case N:                               \
        yyformat = S;                       \
      break
    default: /* Avoid compiler warnings. */
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
# undef YYCASE_
    }

  {
    /* Don't count the "%s"s in the final size, but reserve room for
       the terminator.  */
    YYPTRDIFF_T yysize1 = yysize + (yystrlen (yyformat) - 2 * yycount) + 1;
    if (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM)
      yysize = yysize1;
    else
      return 2;
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return 1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yyarg[yyi++]);
          yyformat += 2;
        }
      else
        {
          ++yyp;
          ++yyformat;
        }
  }
  return 0;
}
#endif /* YYERROR_VERBOSE */

/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
{
  YYUSE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  switch (yytype)
    {
    case 31: /* CONST_INT  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1616 "1805087.tab.c"
        break;

    case 32: /* CONST_FLOAT  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1622 "1805087.tab.c"
        break;

    case 33: /* CONST_CHAR  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1628 "1805087.tab.c"
        break;

    case 34: /* ADDOP  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1634 "1805087.tab.c"
        break;

    case 35: /* MULOP  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1640 "1805087.tab.c"
        break;

    case 36: /* RELOP  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1646 "1805087.tab.c"
        break;

    case 37: /* LOGICOP  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1652 "1805087.tab.c"
        break;

    case 38: /* INCOP  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1658 "1805087.tab.c"
        break;

    case 39: /* ID  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1664 "1805087.tab.c"
        break;

    case 40: /* ARITHASSIGNOP  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1670 "1805087.tab.c"
        break;

    case 46: /* program  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1676 "1805087.tab.c"
        break;

    case 47: /* unit  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1682 "1805087.tab.c"
        break;

    case 48: /* func_prototype  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1688 "1805087.tab.c"
        break;

    case 49: /* func_declaration  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1694 "1805087.tab.c"
        break;

    case 50: /* func_definition  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1700 "1805087.tab.c"
        break;

    case 52: /* parameter_list  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1706 "1805087.tab.c"
        break;

    case 53: /* compound_statement  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1712 "1805087.tab.c"
        break;

    case 54: /* var_declaration  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1718 "1805087.tab.c"
        break;

    case 55: /* type_specifier  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1724 "1805087.tab.c"
        break;

    case 56: /* declaration_list  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1730 "1805087.tab.c"
        break;

    case 57: /* statements  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1736 "1805087.tab.c"
        break;

    case 58: /* generate_if_block  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1742 "1805087.tab.c"
        break;

    case 59: /* statement  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1748 "1805087.tab.c"
        break;

    case 67: /* expression_statement  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1754 "1805087.tab.c"
        break;

    case 68: /* variable  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1760 "1805087.tab.c"
        break;

    case 69: /* expression  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1766 "1805087.tab.c"
        break;

    case 70: /* logic_expression  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1772 "1805087.tab.c"
        break;

    case 71: /* rel_expression  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1778 "1805087.tab.c"
        break;

    case 72: /* simple_expression  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1784 "1805087.tab.c"
        break;

    case 73: /* term  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1790 "1805087.tab.c"
        break;

    case 74: /* unary_expression  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1796 "1805087.tab.c"
        break;

    case 75: /* factor  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1802 "1805087.tab.c"
        break;

    case 76: /* argument_list  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1808 "1805087.tab.c"
        break;

    case 77: /* arguments  */
#line 425 "1805087.y"
            {delete ((*yyvaluep).symbolInfo);}
#line 1814 "1805087.tab.c"
        break;

      default:
        break;
    }
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}




/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;


/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       'yyss': related to states.
       'yyvs': related to semantic values.

       Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss;
    yy_state_t *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYPTRDIFF_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYPTRDIFF_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yyssp = yyss = yyssa;
  yyvsp = yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */
  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    goto yyexhaustedlab;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          goto yyexhaustedlab;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
# undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 2:
#line 445 "1805087.y"
            {
        logFoundRule("start", "program");
        printSummary();

        delete (yyvsp[0].symbolInfo);
    }
#line 2089 "1805087.tab.c"
    break;

  case 3:
#line 454 "1805087.y"
                 {
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-1].symbolInfo)->getName() + "\n" + (yyvsp[0].symbolInfo)->getName(), "VARIABLE");
        logFoundRule("program", "program unit", (yyval.symbolInfo)->getName());
        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 2100 "1805087.tab.c"
    break;

  case 4:
#line 460 "1805087.y"
         {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("program", "unit", (yyval.symbolInfo)->getName());
    }
#line 2109 "1805087.tab.c"
    break;

  case 5:
#line 467 "1805087.y"
                    {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("unit", "var_declaration", (yyval.symbolInfo)->getName());
        // insertNewDeclaredVars();
    }
#line 2119 "1805087.tab.c"
    break;

  case 6:
#line 472 "1805087.y"
                     {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("unit", "func_declaration", (yyval.symbolInfo)->getName());
    }
#line 2128 "1805087.tab.c"
    break;

  case 7:
#line 476 "1805087.y"
                    {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("unit", "func_definition", (yyval.symbolInfo)->getName());
    }
#line 2137 "1805087.tab.c"
    break;

  case 8:
#line 483 "1805087.y"
                                                   {
        string returnType = "CONST_" + toUpper((yyvsp[-4].symbolInfo)->getName());
        string id = (yyvsp[-3].symbolInfo)->getName();
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-4].symbolInfo)->getName() + " " + id + "(" + (yyvsp[-1].symbolInfo)->getName() + ")", "parameter_list");

        handleFuncDeclaration(id, returnType);

        declareProcedure(id);

        delete (yyvsp[-4].symbolInfo);
        delete (yyvsp[-3].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
}
#line 2155 "1805087.tab.c"
    break;

  case 9:
#line 496 "1805087.y"
                                                         {
        string returnType = "CONST_" + toUpper((yyvsp[-5].symbolInfo)->getName());
        string id = (yyvsp[-4].symbolInfo)->getName();
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-5].symbolInfo)->getName() + " " + id + "(" + (yyvsp[-2].symbolInfo)->getName() + ")", "parameter_list");

        handleFuncDeclaration(id, returnType);

        delete (yyvsp[-5].symbolInfo);
        delete (yyvsp[-4].symbolInfo);
        delete (yyvsp[-2].symbolInfo);
}
#line 2171 "1805087.tab.c"
    break;

  case 10:
#line 507 "1805087.y"
                                    {
        string returnType = "CONST_" + toUpper((yyvsp[-3].symbolInfo)->getName());
        string id = (yyvsp[-2].symbolInfo)->getName();
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-3].symbolInfo)->getName() + " " + id + "()", "");

        handleFuncDeclaration(id, returnType);

        declareProcedure(id);

        delete (yyvsp[-3].symbolInfo);
        delete (yyvsp[-2].symbolInfo);
}
#line 2188 "1805087.tab.c"
    break;

  case 11:
#line 521 "1805087.y"
                             {
        symbolTable.enterScope();
        symbolTable.exitScope();

        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-1].symbolInfo)->getName() + ";", "VARIABLE");
        logFoundRule("func_declaration", "type_specifier ID LPAREN " + (yyvsp[-1].symbolInfo)->getType() + " RPAREN SEMICOLON");

        if(hasFuncDeclared)
            errorMessage("Multiple declaration of " + funcName);
        
        hasDeclaredId = hasFuncDeclared = hasFuncDefined = false;
        funcName.clear();
        funcReturnType.clear();
        parameters.clear();

        logMatchedString((yyval.symbolInfo)->getName());
        delete (yyvsp[-1].symbolInfo);
    }
#line 2211 "1805087.tab.c"
    break;

  case 12:
#line 539 "1805087.y"
                         {
        symbolTable.enterScope();
        symbolTable.exitScope();

        (yyval.symbolInfo) = (yyvsp[-1].symbolInfo);

        if(hasFuncDeclared)
            errorMessage("Multiple declaration of " + funcName);
        
        hasDeclaredId = hasFuncDeclared = hasFuncDefined = false;
        funcName.clear();
        funcReturnType.clear();
        parameters.clear();

        logMatchedString((yyval.symbolInfo)->getName());
}
#line 2232 "1805087.tab.c"
    break;

  case 13:
#line 558 "1805087.y"
                                      {
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-1].symbolInfo)->getName() + (yyvsp[0].symbolInfo)->getName(), "VARIABLE");
        logFoundRule("func_definition", "type_specifier ID LPAREN " + (yyvsp[-1].symbolInfo)->getType() + " RPAREN compound_statement");
        
        handleFuncDefinition();

        endProcedure(funcName, ((FunctionInfo*)symbolTable.lookUp(funcName))->getNumberOfParameters());

        hasDeclaredId = hasFuncDeclared = hasFuncDefined = hasFoundReturn = false;
        funcName.clear();
        funcReturnType.clear();
        parameters.clear();

        logMatchedString((yyval.symbolInfo)->getName());
        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 2254 "1805087.tab.c"
    break;

  case 14:
#line 578 "1805087.y"
    {
        if(hasFuncDeclared) {
            FunctionInfo* functionInfo = (FunctionInfo*)symbolTable.lookUp(funcName);

            // check the return type
            if(funcReturnType != functionInfo->getReturnType()) {
                errorMessage("Return type mismatch with function declaration in function " + funcName);
            }

            if(functionInfo->getNumberOfParameters() != parameters.size()) {
                errorMessage("Total number of arguments mismatch with declaration in function " + funcName);
            }

            // Check if the parameter types matched with the function declaration
            int i = 0;
            for(pair<string, string> parameter : parameters) {
                if(("CONST_" + toUpper(parameter.second)) != functionInfo->getParameterTypeAtIdx(i)) {
                    errorMessage("Function parameter/s does not match with the declaration");
                }
                // function definition must have parameter names
                if(parameter.first == "")
                    errorMessage(to_string(i + 1) + "th parameter's name not given in function definition of " + funcName);
                i++;
            }
        }     

        symbolTable.enterScope();

        // Insert the parameters in the scope
        list<pair<string, string> >::iterator it = parameters.begin();

        int i = parameters.size();
        while(it != parameters.end()) {      
            IdInfo* idInfo = (IdInfo*)symbolTable.insert((*it).first, "ID", "CONST_" + toUpper((*it).second),0 , true);
            if((*it).first != "" && idInfo == NULL)
                errorMessage("Multiple declaration of " + (*it).first + " in parameter");
            else {
                // set the offset of the parameter
                idInfo->setStackOffset(2 + i * 2);
            }
            it++;
            i--;
        }        
}
#line 2303 "1805087.tab.c"
    break;

  case 15:
#line 624 "1805087.y"
                                           {
        string id = (yyvsp[0].symbolInfo)->getName();
        string type = (yyvsp[-1].symbolInfo)->getName();

        // Save the name and type of the parameter
        parameters.push_back(make_pair(id, type));

        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-3].symbolInfo)->getName() + "," + type + " " + id, "VARIABLE");
        logFoundRule("parameter_list", "parameter_list COMMA type_specifier ID");

        if(type == "void")
            errorMessage("Variable type cannot be void");

        logMatchedString((yyval.symbolInfo)->getName());

        delete (yyvsp[-3].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 2327 "1805087.tab.c"
    break;

  case 16:
#line 643 "1805087.y"
                                        {
        string type = (yyvsp[0].symbolInfo)->getName();

        // Save the name and type of the parameter
        parameters.push_back(make_pair("", type));

        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-2].symbolInfo)->getName() + "," + type, "VARIABLE");
        logFoundRule("parameter_list", "parameter_list COMMA type_specifier");
        
        if(type == "void")
            errorMessage("Variable type cannot be void");

        logMatchedString((yyval.symbolInfo)->getName());
        delete (yyvsp[-2].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 2348 "1805087.tab.c"
    break;

  case 17:
#line 659 "1805087.y"
                               {
        (yyval.symbolInfo) = (yyvsp[-2].symbolInfo);
        logMatchedString((yyval.symbolInfo)->getName());
}
#line 2357 "1805087.tab.c"
    break;

  case 18:
#line 663 "1805087.y"
                      {
        string type = (yyvsp[-1].symbolInfo)->getName();
        string id =  (yyvsp[0].symbolInfo)->getName();

        // Save the name and type of the parameter
        parameters.push_back(make_pair(id, type));

        (yyval.symbolInfo) = new SymbolInfo(type + " " + id, "VARIABLE");
        logFoundRule("parameter_list", "type_specifier ID");

        if(type == "void")
            errorMessage("Variable type cannot be void");

        logMatchedString((yyval.symbolInfo)->getName());
        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 2379 "1805087.tab.c"
    break;

  case 19:
#line 680 "1805087.y"
                   {
        string type = (yyvsp[0].symbolInfo)->getName();

        // Save the name and type of the parameter
        parameters.push_back(make_pair("", type));

        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("parameter_list", "type_specifier");

        if(type == "void")
            errorMessage("Variable type cannot be void");
        
        logMatchedString((yyval.symbolInfo)->getName());
    }
#line 2398 "1805087.tab.c"
    break;

  case 20:
#line 697 "1805087.y"
                                       {
        (yyval.symbolInfo) = new SymbolInfo("{\n" + (yyvsp[-1].symbolInfo)->getName() + "\n}", "VARIABLE");
        logFoundRule("compound_statement", "LCURL statements RCURL", (yyval.symbolInfo)->getName());
        
        // Print the symbol table and then exit the current scope
        logFile << symbolTable.getNonEmptyList() << "\n\n";
        symbolTable.exitScope();

        delete (yyvsp[-1].symbolInfo);
    }
#line 2413 "1805087.tab.c"
    break;

  case 21:
#line 707 "1805087.y"
                            {
        (yyval.symbolInfo) = new SymbolInfo("{}", "VARIABLE");
        logFoundRule("compound_statement", "LCURL RCURL", (yyval.symbolInfo)->getName());
        
        logFile << symbolTable.getNonEmptyList() << "\n\n";
        symbolTable.exitScope();
    }
#line 2425 "1805087.tab.c"
    break;

  case 22:
#line 717 "1805087.y"
                                              {
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-2].symbolInfo)->getName() + " " + (yyvsp[-1].symbolInfo)->getName() + ";", "VARIABLE");
        logFoundRule("var_declaration", "type_specifier declaration_list SEMICOLON");

        if(varType == "void")
            errorMessage("Variable type cannot be void");
        
        logMatchedString((yyval.symbolInfo)->getName());

        varType.clear();
        delete (yyvsp[-2].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
    }
#line 2443 "1805087.tab.c"
    break;

  case 23:
#line 733 "1805087.y"
        {
        varType = "int";

        (yyval.symbolInfo) = new SymbolInfo("int", "VARIABLE");
        logFoundRule("type_specifier", "INT", (yyval.symbolInfo)->getName());
    }
#line 2454 "1805087.tab.c"
    break;

  case 24:
#line 739 "1805087.y"
          {
        varType = "float";

        (yyval.symbolInfo) = new SymbolInfo("float", "VARIABLE");
        logFoundRule("type_specifier", "FLOAT", (yyval.symbolInfo)->getName());
    }
#line 2465 "1805087.tab.c"
    break;

  case 25:
#line 745 "1805087.y"
         {
        varType = "void";

        (yyval.symbolInfo) = new SymbolInfo("void", "VARIABLE");
        logFoundRule("type_specifier", "VOID", (yyval.symbolInfo)->getName());
    }
#line 2476 "1805087.tab.c"
    break;

  case 26:
#line 754 "1805087.y"
                              {
        string id = (yyvsp[0].symbolInfo)->getName();
        
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-2].symbolInfo)->getName() + "," + id, "VARIABLE");
        logFoundRule("declaration_list", "declaration_list COMMA ID");

        insertId(id, varType);

        if(symbolTable.getCurrentScopeID() == "1")
            declareGlobalVariable(id, varType);

        logMatchedString((yyval.symbolInfo)->getName());

        delete (yyvsp[-2].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 2497 "1805087.tab.c"
    break;

  case 27:
#line 770 "1805087.y"
                              {       
        // cout << "Error with " << $3->getName() << endl;  
        (yyval.symbolInfo) = (yyvsp[-2].symbolInfo);
        delete (yyvsp[0].symbolInfo);
}
#line 2507 "1805087.tab.c"
    break;

  case 28:
#line 776 "1805087.y"
                                                      {
        string id = (yyvsp[-3].symbolInfo)->getName();
        
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-5].symbolInfo)->getName() + "," + id + "[" + (yyvsp[-1].symbolInfo)->getName() + "]", "VARIABLE");
        logFoundRule("declaration_list", "declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");

        insertId(id, varType + "*", stoi((yyvsp[-1].symbolInfo)->getName()));
        if(symbolTable.getCurrentScopeID() == "1")
            declareGlobalArray(id, varType, (yyvsp[-1].symbolInfo)->getName());

        logMatchedString((yyval.symbolInfo)->getName());

        delete (yyvsp[-5].symbolInfo);
        delete (yyvsp[-3].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
    }
#line 2528 "1805087.tab.c"
    break;

  case 29:
#line 792 "1805087.y"
                                                  {
        string id = (yyvsp[-3].symbolInfo)->getName();
        insertId(id, varType + "*");
        
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-5].symbolInfo)->getName() + "," + id + "[]", "VARIABLE");

        errorMessage("Expression inside third brackets not an integer");
        
        delete (yyvsp[-5].symbolInfo);
        delete (yyvsp[-3].symbolInfo);
}
#line 2544 "1805087.tab.c"
    break;

  case 30:
#line 803 "1805087.y"
       {
        insertId((yyvsp[0].symbolInfo)->getName(), varType);

        if(symbolTable.getCurrentScopeID() == "1")
            declareGlobalVariable((yyvsp[0].symbolInfo)->getName(), varType);

        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("declaration_list", "ID", (yyval.symbolInfo)->getName());
    }
#line 2558 "1805087.tab.c"
    break;

  case 31:
#line 812 "1805087.y"
                               {
        string id = (yyvsp[-3].symbolInfo)->getName();

        (yyval.symbolInfo) = new SymbolInfo(id + "[" + (yyvsp[-1].symbolInfo)->getName() + "]", "VARIABLE");
        logFoundRule("declaration_list", "ID LTHIRD CONST_INT RTHIRD");

        insertId(id, varType + "*", stoi((yyvsp[-1].symbolInfo)->getName()));
        if(symbolTable.getCurrentScopeID() == "1")
            declareGlobalArray(id, varType, (yyvsp[-1].symbolInfo)->getName());

        logMatchedString((yyval.symbolInfo)->getName());

        delete (yyvsp[-3].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
    }
#line 2578 "1805087.tab.c"
    break;

  case 32:
#line 827 "1805087.y"
                           {
        string id = (yyvsp[-3].symbolInfo)->getName();
        insertId(id, varType + "*");
        
        (yyval.symbolInfo) = new SymbolInfo(id + "[]", "VARIABLE");
        
        delete (yyvsp[-3].symbolInfo);
    }
#line 2591 "1805087.tab.c"
    break;

  case 33:
#line 838 "1805087.y"
              {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("statements", "statement", (yyval.symbolInfo)->getName());
    }
#line 2600 "1805087.tab.c"
    break;

  case 34:
#line 842 "1805087.y"
                         {
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-1].symbolInfo)->getName() + "\n" + (yyvsp[0].symbolInfo)->getName(), "VARIABLE");
        logFoundRule("statements", "statements statement", (yyval.symbolInfo)->getName());
        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 2611 "1805087.tab.c"
    break;

  case 35:
#line 851 "1805087.y"
     {
        string labelElse = newLabel();
        string labelElseBypass = newLabel();
        (yyval.symbolInfo) = new SymbolInfo(labelElse, "LABEL");

        string code = "\t\t;line no " + to_string(lineCount) + ": evaluating if block\n";
        code += "\t\tPOP AX\t;popped expression value\n";
        code += "\t\tCMP AX, 0\t;compare with 0 to see if the expression is false\n";
        code += "\t\tJNE " + labelElseBypass + "\n";
        code += "\t\tJMP " + labelElse + "\t;if false jump to end of if block\n";
        code += "\t\t" + labelElseBypass + ":\n";

        writeInCodeSegment(code);
    }
#line 2630 "1805087.tab.c"
    break;

  case 36:
#line 867 "1805087.y"
                    {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("statement", "var_declaration", (yyval.symbolInfo)->getName());
    }
#line 2639 "1805087.tab.c"
    break;

  case 37:
#line 871 "1805087.y"
                         {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("statement", "expression_statement", (yyval.symbolInfo)->getName());
    }
#line 2648 "1805087.tab.c"
    break;

  case 38:
#line 875 "1805087.y"
                       {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("statement", "compound_statement", (yyval.symbolInfo)->getName());
    }
#line 2657 "1805087.tab.c"
    break;

  case 39:
#line 879 "1805087.y"
                                    {
        string labelFor = newLabel();
        string code = "\t\t;line no " + to_string(lineCount) + ": evaluating for loop\n";
        code += "\t\t" + labelFor + ":\t;For loop start label\n";

        writeInCodeSegment(code);
        (yyval.symbolInfo) = new SymbolInfo(labelFor, "LABEL");
    }
#line 2670 "1805087.tab.c"
    break;

  case 40:
#line 887 "1805087.y"
                         {
        string labelEnd = newLabel();
        string labelEndBypass = newLabel();

        string code = "\t\tCMP AX, 0\t;compare with 0 to see if the expression is false\n";
        code += "\t\tJNE " + labelEndBypass + "\n";
        code += "\t\tJMP " + labelEnd + "\t;if false jump to end of for loop\n";
        code += "\t\t" + labelEndBypass + ":\n";

        writeInCodeSegment(code);
        (yyval.symbolInfo) = new SymbolInfo(labelEnd, "LABEL");
    }
#line 2687 "1805087.tab.c"
    break;

  case 41:
#line 899 "1805087.y"
    { (yyval.intValue) = asmCodeSegmentEndLine; }
#line 2693 "1805087.tab.c"
    break;

  case 42:
#line 900 "1805087.y"
               {
        string labelFor = (yyvsp[-4].symbolInfo)->getName();
        string labelEnd = (yyvsp[-2].symbolInfo)->getName();
        string code = "\t\tPOP AX\t;popped " + (yyvsp[0].symbolInfo)->getName() + "\n";
        code += "\t\tJMP " + labelFor + "\t;jump back to for loop\n";
        code += "\t\t" + labelEnd + ":\n";
        
        writeInCodeSegment(code);
        // forcefully changing asmCodeSegment end line before the line of the expression
        // so that the expression is evaluated after the for loop statement is executed
        asmCodeSegmentEndLine = (yyvsp[-1].intValue);
    }
#line 2710 "1805087.tab.c"
    break;

  case 43:
#line 912 "1805087.y"
                     {
        (yyval.symbolInfo) = new SymbolInfo("for(" + (yyvsp[-8].symbolInfo)->getName() + (yyvsp[-6].symbolInfo)->getName() + (yyvsp[-3].symbolInfo)->getName() + ")" + (yyvsp[0].symbolInfo)->getName(), "VARIABLE");
        logFoundRule("statement", "FOR LPAREN expression_statement expression_statement expression RPAREN statement", (yyval.symbolInfo)->getName());

        // relocating the asmCodeSegment end line to the end of the for loop statement
        asmCodeSegmentEndLine = asmLineCount;
        delete (yyvsp[-8].symbolInfo);
        delete (yyvsp[-7].symbolInfo);
        delete (yyvsp[-6].symbolInfo);
        delete (yyvsp[-5].symbolInfo);
        delete (yyvsp[-3].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 2728 "1805087.tab.c"
    break;

  case 44:
#line 925 "1805087.y"
                                                                                  {
        writeInCodeSegment("\t\t" + (yyvsp[-1].symbolInfo)->getName() + ":\n");
        
        (yyval.symbolInfo) = new SymbolInfo("if(" + (yyvsp[-3].symbolInfo)->getName() + ")" + (yyvsp[0].symbolInfo)->getName(), "VARIABLE");
        logFoundRule("statement", "IF LPAREN expression RPAREN statement", (yyval.symbolInfo)->getName());

        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[-3].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 2743 "1805087.tab.c"
    break;

  case 45:
#line 935 "1805087.y"
                                                                 {
        // if "if" block is executed then jump directly to the end of if else block
        // else start the else block
        // pass the end label
        string labelEnd = newLabel();
        string code = "\t\tJMP " + labelEnd + "\n";
        code += "\t\t" + (yyvsp[-2].symbolInfo)->getName() + ":";

        writeInCodeSegment(code);

        (yyval.symbolInfo) = new SymbolInfo(labelEnd, "LABEL");
    }
#line 2760 "1805087.tab.c"
    break;

  case 46:
#line 946 "1805087.y"
                {
        (yyval.symbolInfo) = new SymbolInfo("if(" + (yyvsp[-6].symbolInfo)->getName() + ")" + (yyvsp[-3].symbolInfo)->getName() + "else\n" + (yyvsp[0].symbolInfo)->getName(), "VARIABLE");
        logFoundRule("statement", "IF LPAREN expression RPAREN statement ELSE statement", (yyval.symbolInfo)->getName());

        // just insert the end label
        writeInCodeSegment("\t\t" + (yyvsp[-1].symbolInfo)->getName() + ":\n");

        delete (yyvsp[-6].symbolInfo);
        delete (yyvsp[-4].symbolInfo);
        delete (yyvsp[-3].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 2778 "1805087.tab.c"
    break;

  case 47:
#line 959 "1805087.y"
          { 
        string labelWhile = newLabel();
        (yyval.symbolInfo) = new SymbolInfo(labelWhile, "LABEL");
        writeInCodeSegment("\t\t" + labelWhile + ":\t;while loop start label\n");
    }
#line 2788 "1805087.tab.c"
    break;

  case 48:
#line 963 "1805087.y"
                        {
        string labelEnd = newLabel();
        string labelEndBypass = newLabel();
        (yyval.symbolInfo) = new SymbolInfo(labelEnd, "LABEL");

        string code = "\t\tPOP AX\t;popped " + (yyvsp[0].symbolInfo)->getName() + "\n";
        code += "\t\tCMP AX, 0\t;compare with 0 to see if the expression is false\n";
        code += "\t\tJNE " + labelEndBypass + "\n";
        code += "\t\tJMP " + labelEnd + "\t;if false jump to end of while loop\n";
        code += "\t\t" + labelEndBypass + ":\n";

        writeInCodeSegment(code);
    }
#line 2806 "1805087.tab.c"
    break;

  case 49:
#line 976 "1805087.y"
                     {
        (yyval.symbolInfo) = new SymbolInfo("while(" + (yyvsp[-3].symbolInfo)->getName() + ")" + (yyvsp[0].symbolInfo)->getName(), "VARIABLE");
        logFoundRule("statement", "WHILE LPAREN expression RPAREN statement", (yyval.symbolInfo)->getName());

        string labelWhile = (yyvsp[-5].symbolInfo)->getName();
        string labelEnd = (yyvsp[-2].symbolInfo)->getName();
        string code = "\t\tJMP " + labelWhile + "\n";
        code += "\t\t" + labelEnd + ":\t;while loop end label\n";

        writeInCodeSegment(code);

        delete (yyvsp[-5].symbolInfo);
        delete (yyvsp[-3].symbolInfo);
        delete (yyvsp[-2].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 2827 "1805087.tab.c"
    break;

  case 50:
#line 992 "1805087.y"
                                       {
        string id = (yyvsp[-2].symbolInfo)->getName();
        (yyval.symbolInfo) = new SymbolInfo("println(" + id + ");", "VARIABLE");
        logFoundRule("statement", "PRINTLN LPAREN ID RPAREN SEMICOLON");
        
        IdInfo* idInfo = (IdInfo*)symbolTable.lookUp(id);
        string code = "\n";

        if(idInfo->getStackOffset() != -1)
            code += "\t\tPUSH [BP+" + to_string(idInfo->getStackOffset()) + "]\t;passing " + id + " to PRINT_INTEGER\n";
        else
            code += "\t\tPUSH " + id + "\t;passing " + id + " to PRINT_INTEGER\n";

        code += "\t\tCALL PRINT_INTEGER\n";
        writeInCodeSegment(code);

        if(symbolTable.lookUp(id) == NULL) 
            errorMessage("Undeclared variable " + id);

        logMatchedString((yyval.symbolInfo)->getName());

        delete (yyvsp[-2].symbolInfo);
    }
#line 2855 "1805087.tab.c"
    break;

  case 51:
#line 1015 "1805087.y"
                                   {
        string id = (yyvsp[-2].symbolInfo)->getName();
        (yyval.symbolInfo) = new SymbolInfo("printf(" + id + ")", "VARIABLE");

        if(symbolTable.lookUp(id) == NULL) 
            errorMessage("Undeclared variable " + id);

        logMatchedString((yyval.symbolInfo)->getName());

        delete (yyvsp[-2].symbolInfo);
}
#line 2871 "1805087.tab.c"
    break;

  case 52:
#line 1026 "1805087.y"
                                {
        hasFoundReturn = true;
        string type = (yyvsp[-1].symbolInfo)->getType();
        string name = "return " + (yyvsp[-1].symbolInfo)->getName() + ";";
        
        logFoundRule("statement", "RETURN expression SEMICOLON");

        if(funcReturnType != ""){
            if(funcReturnType == "CONST_FLOAT" && (type == "CONST_FLOAT" || type == "CONST_INT"))
                type = "CONST_FLOAT";
            else {
                SymbolInfo* tempSymbol = new SymbolInfo("dummy", funcReturnType);
                typeCast(tempSymbol, (yyvsp[-1].symbolInfo), "Return type does not match with the return value in function " + funcName);

                delete tempSymbol;
            }
        }

        string code = "\t\tPOP AX\t;saving returned value in AX\n";
        if(funcName != "main") {
            // save the return value in AX
            // and return to the caller            
            FunctionInfo* funcInfo = (FunctionInfo*)symbolTable.lookUp(funcName);
            int noOfParams = funcInfo != NULL ? funcInfo->getNumberOfParameters() : 0;
            
            code += "\t\tMOV SP, BP\t;Restoring SP at the end of function\n";
            code += "\t\tPOP BP\t;restoring BP at the end of function\n";
            code += "\t\tRET " + (noOfParams ? to_string(noOfParams * 2) : "");
            writeInCodeSegment(code);
        } else {
            terminateAsmMain();
        }
        logMatchedString(name);
        (yyval.symbolInfo) = new SymbolInfo(name, type);
        delete (yyvsp[-1].symbolInfo);
    }
#line 2912 "1805087.tab.c"
    break;

  case 53:
#line 1062 "1805087.y"
                            {
        hasFoundReturn = true;
        string type = (yyvsp[-1].symbolInfo)->getType();
        string name = "return " + (yyvsp[-1].symbolInfo)->getName();

        if(funcReturnType != ""){
            if(funcReturnType == "CONST_FLOAT" && (type == "CONST_FLOAT" || type == "CONST_INT"))
                type = "CONST_FLOAT";
            else {
                SymbolInfo* tempSymbol = new SymbolInfo("dummy", funcReturnType);
                typeCast(tempSymbol, (yyvsp[-1].symbolInfo), "Return type does not match with the return value in function " + funcName);

                delete tempSymbol;
            }
        }
            
        logMatchedString(name);
        (yyval.symbolInfo) = new SymbolInfo(name, type);
        delete (yyvsp[-1].symbolInfo);
    }
#line 2937 "1805087.tab.c"
    break;

  case 54:
#line 1085 "1805087.y"
              {
        (yyval.symbolInfo) = new SymbolInfo(";", "VARIABLE");
        logFoundRule("expression_statement", "SEMICOLON", (yyval.symbolInfo)->getName());  
    }
#line 2946 "1805087.tab.c"
    break;

  case 55:
#line 1089 "1805087.y"
                         {
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-1].symbolInfo)->getName() + ";", (yyvsp[-1].symbolInfo)->getType());
        logFoundRule("expression_statement", "expression SEMICOLON", (yyval.symbolInfo)->getName());

        // There is always an extra push after every expression
        // So, we need to pop it out after we get a semicolon after an expression
        writeInCodeSegment("\t\tPOP AX\t;Popped out " + (yyvsp[-1].symbolInfo)->getName());

        delete (yyvsp[-1].symbolInfo);
    }
#line 2961 "1805087.tab.c"
    break;

  case 56:
#line 1099 "1805087.y"
                     {
        // cout << "Error at expression error " << $1->getName() << "\n";
        (yyval.symbolInfo) = new SymbolInfo("", "ERROR");

        delete (yyvsp[-1].symbolInfo);
    }
#line 2972 "1805087.tab.c"
    break;

  case 57:
#line 1108 "1805087.y"
       {
        string id = (yyvsp[0].symbolInfo)->getName();
        logFoundRule("variable", "ID");

        IdInfo* idInfo = (IdInfo*)symbolTable.lookUp(id);
        if(idInfo == NULL) {
            errorMessage("Undeclared variable " + id);
            (yyval.symbolInfo) = new SymbolInfo(id, "UNDEC");
        } else {
            // $$ = new SymbolInfo(idInfo->getName(), idInfo->getIdType());
            (yyval.symbolInfo) = new IdInfo(idInfo->getName(),idInfo->getIdType(), idInfo->getIdType(), idInfo->getStackOffset(), idInfo->getArraySize());

            // Write in ASM code
            if(idInfo->getStackOffset() == -1) {
                writeInCodeSegment("\t\tPUSH " + id + "\t;expression evaluation");
            } else {
                writeInCodeSegment("\t\tPUSH [BP+" + to_string(idInfo->getStackOffset()) + "]\t; " + idInfo->getName() + " pushed");
            }
        }
        
        logMatchedString(id);
        delete (yyvsp[0].symbolInfo);
    }
#line 3000 "1805087.tab.c"
    break;

  case 58:
#line 1131 "1805087.y"
                                {
        string id = (yyvsp[-3].symbolInfo)->getName();
        string varType = "VARIABLE";
        string name = id + "[" + (yyvsp[-1].symbolInfo)->getName() + "]";
        SymbolInfo* symbolInfo = symbolTable.lookUp(id);

        
        logFoundRule("variable", "ID LTHIRD expression RTHIRD");
        // check if the id is an array or not
        if(symbolInfo == NULL) {
            errorMessage("Undeclared variable " + id);
            varType = "UNDEC";
            (yyval.symbolInfo) = new SymbolInfo(name, varType);
        } else if(symbolInfo->getType() == "ID") {
            IdInfo* idInfo = (IdInfo*)symbolInfo;
            string idType = idInfo->getIdType();

            if(idType.size() > 0 && idType[idType.size()-1] != '*') {
                errorMessage(id + " not an array");
                varType = idType;
            } else {
                // the type of the variable will be the original type of the array elements
                // So, truncate the '*'
                varType = idType.substr(0, idType.size() - 1);
                int stackOffset = idInfo->getStackOffset();
                
                (yyval.symbolInfo) = new IdInfo(id, varType, varType, stackOffset, idInfo->getArraySize());
                // $$ = new SymbolInfo(name, varType);
                // get the value of the id[index]
                string code = "\t\t;line no " + to_string(lineCount) + ": getting the value of " + id + "[" + (yyvsp[-1].symbolInfo)->getName() + "]\n";
                code += "\t\tPOP BX\t;saving the index of the array in BX\n";
                code += "\t\tSHL BX, 1\t;multiplying index by 2 to match the size of word\n";
                if(stackOffset != -1) {
                    if(stackOffset < 0)
                        code += "\t\tNEG BX\t;offset is negative\n";
                    code += "\t\tADD BX, " + to_string(stackOffset) + "\t;adding the offset of the array to get the offset of array element\n";
                    code += "\t\tADD BX, BP\t;adding BP to BX to get the address of the array\n";
                    code += "\t\tMOV AX, [BX]\t;getting the value of the array at index BX\n";
                } else {
                    code += "\t\tMOV AX, " + id + "[BX]\t;getting the value of the array at index BX\n";
                }
                
                // push the index and value of the array element on the stack
                // this will allow the ASSIGNOP and INCOP to use it later
                code += "\t\tPUSH AX\t;pushing the value of the array element at index " + (yyvsp[-1].symbolInfo)->getName() + "\n";
                code += "\t\tPUSH BX\t;pushing the index of the array";
                writeInCodeSegment(code);
            }            
        } else {
            errorMessage(id + " not an array");
            varType = symbolInfo->getType();
        }
        
        if((yyvsp[-1].symbolInfo)->getType() != "CONST_INT")
            errorMessage("Expression inside third brackets not an integer");
        
        logMatchedString(name);

        // $$ = new SymbolInfo(name, varType);
        delete (yyvsp[-3].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
    }
#line 3067 "1805087.tab.c"
    break;

  case 59:
#line 1196 "1805087.y"
                     {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("expression", "logic_expression", (yyval.symbolInfo)->getName());
    }
#line 3076 "1805087.tab.c"
    break;

  case 60:
#line 1200 "1805087.y"
                                       {
        string lName = (yyvsp[-2].symbolInfo)->getName();
        string name = lName + "=" + (yyvsp[0].symbolInfo)->getName();
        string lType = (yyvsp[-2].symbolInfo)->getType();
        string rType = (yyvsp[0].symbolInfo)->getType();
        string type = lType;
        
        logFoundRule("expression", "variable ASSIGNOP logic_expression");

        if(isVoidFunc(rType)) {
            // Do nothing
            // Error message handled in isVoidFunction
        } else if(lType != "UNDEC"){
            typeCast((yyvsp[-2].symbolInfo), (yyvsp[0].symbolInfo), "Type Mismatch");
        }
        // Undeclared variables are detected in 'variable' rule
        // and are handled there

        logMatchedString(name);

        IdInfo* idInfo = (IdInfo*)(yyvsp[-2].symbolInfo); // variable always passed an IdInfo. So it is safe to cast it
        int arraySize = idInfo->getArraySize();

        string code = "\t\tPOP AX\t;" + (yyvsp[0].symbolInfo)->getName() + " popped\n";
        if(arraySize > 0)
            code += "\t\tPOP BX\t;index of the array element popped\n";

        if(idInfo->getStackOffset() == -1) {
            if(arraySize > 0)
                code += "\t\tMOV " + lName + "[BX], AX\t;assigning the value of " + (yyvsp[0].symbolInfo)->getName() + " to " + lName + "[BX]\n";
            else
                code += "\t\tMOV " + (yyvsp[-2].symbolInfo)->getName() + ", AX\t;" + "assigned " + (yyvsp[0].symbolInfo)->getName() + " to " + (yyvsp[-2].symbolInfo)->getName();
        } else {
            if(arraySize > 0)
                code += "\t\tMOV [BX], AX\t;assigning the value of " + (yyvsp[0].symbolInfo)->getName() + " to " + lName + "[BX]\n";
            else  
                code += "\t\tMOV [BP+" + to_string(idInfo->getStackOffset()) + "], AX\t;" + "assigned " + (yyvsp[0].symbolInfo)->getName() + " to " + (yyvsp[-2].symbolInfo)->getName();
        }

        writeInCodeSegment(code);        

        (yyval.symbolInfo) = new SymbolInfo(name, type);
        delete (yyvsp[-2].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 3126 "1805087.tab.c"
    break;

  case 61:
#line 1245 "1805087.y"
                            {
        // cout << "Error at variable ASSIGNOP\n";
        (yyval.symbolInfo) = (yyvsp[-2].symbolInfo);
        logMatchedString((yyvsp[-2].symbolInfo)->getName());
}
#line 3136 "1805087.tab.c"
    break;

  case 62:
#line 1253 "1805087.y"
                   {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("logic_expression", "rel_expression", (yyval.symbolInfo)->getName());
    }
#line 3145 "1805087.tab.c"
    break;

  case 63:
#line 1257 "1805087.y"
                                          {
        string lName = (yyvsp[-2].symbolInfo)->getName();
        string rName = (yyvsp[0].symbolInfo)->getName();
        string logicop = (yyvsp[-1].symbolInfo)->getName();

        (yyval.symbolInfo) = new SymbolInfo(lName + logicop + rName, "CONST_INT");
        logFoundRule("logic_expression", "rel_expression LOGICOP rel_expression");

        if(isVoidFunc((yyvsp[-2].symbolInfo)->getType())) {
            // Do nothing
            // Error message handled in isVoidFunction
        } else if(isVoidFunc((yyvsp[0].symbolInfo)->getType())) {
            // Do nothing
            // Error message handled in isVoidFunction
        }
        // No need for a type check because, it is okay to have any arbitrary const on 
        // both sides of logical operator
        
        logMatchedString((yyval.symbolInfo)->getName());

        string code = "\t\t;line no " + to_string(lineCount) + ": " + lName + logicop + rName + "\n";
        if(logicop == "&&") {
            string labelLeftTrue = newLabel();
            string labelTrue = newLabel();
            string labelEnd = newLabel();

            // logical and operation in ASM
            code += "\t\tPOP BX\t; " + rName + " popped\n";
            code += "\t\tPOP AX\t; " + lName + " popped\n";
            code += "\t\tCMP AX, 0\t; comparing " + lName + " and 0\n";
            code += "\t\tJNE " + labelLeftTrue + "\t; if " + lName + " is not 0, check " 
                + rName + ". So, jump to " + labelLeftTrue + "\n";
            code += "\t\tPUSH 0\t; " + lName + " is 0, the whole expression is 0. So, set the value to 0\n";
            code += "\t\tJMP " + labelEnd + "\n";
            code += "\t\t" + labelLeftTrue + ":\n";
            code += "\t\tCMP BX, 0\t; comparing " + rName + " and 0\n";
            code += "\t\tJNE " + labelTrue + "\t; if " + rName + " is not 0, the whole expression is true. So, jump to " + labelTrue + "\n";
            code += "\t\tPUSH 0\t; " + lName + " and " + rName + " are false. So, set the value to 0\n";
            code += "\t\tJMP " + labelEnd + "\n";
            code += "\t\t" + labelTrue + ":\n";
            code += "\t\tPUSH 1\t; " + lName + " and " + rName + " are true. So, set the value to 1\n";
            code += "\t\t" + labelEnd + ":\n";
        } else {
            string labelLeftFalse = newLabel();
            string labelFalse = newLabel();
            string labelEnd = newLabel();

            // logical or operation in ASM
            code += "\t\tPOP BX\t; " + rName + " popped\n";
            code += "\t\tPOP AX\t; " + lName + " popped\n";
            code += "\t\tCMP AX, 0\t; comparing " + lName + " and 0\n";
            code += "\t\tJE " + labelLeftFalse + "\t; if " + lName + " is 0, check " 
                + rName + ". So, jump to " + labelLeftFalse + "\n";
            code += "\t\tPUSH 1\t; " + lName + " is not 0, the whole expression is true. So, set the value to 1\n";
            code += "\t\tJMP " + labelEnd + "\n";
            code += "\t\t" + labelLeftFalse + ":\n";
            code += "\t\tCMP BX, 0\t; comparing " + rName + " and 0\n";
            code += "\t\tJE " + labelFalse + "\t; if " + rName + " is 0, the whole expression is false. So, jump to " + labelFalse + "\n";
            code += "\t\tPUSH 1\t; " + lName + " and " + rName + " are true. So, set the value to 1\n";
            code += "\t\tJMP " + labelEnd + "\n";
            code += "\t\t" + labelFalse + ":\n";
            code += "\t\tPUSH 0\t; " + lName + " and " + rName + " are false. So, set the value to 0\n";
            code += "\t\t" + labelEnd + ":\n";
        }

        writeInCodeSegment(code);
        delete (yyvsp[-2].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 3220 "1805087.tab.c"
    break;

  case 64:
#line 1330 "1805087.y"
                      {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("rel_expression", "simple_expression", (yyval.symbolInfo)->getName());
    }
#line 3229 "1805087.tab.c"
    break;

  case 65:
#line 1334 "1805087.y"
                                              {
        string lType = (yyvsp[-2].symbolInfo)->getType();
        string rType = (yyvsp[0].symbolInfo)->getType();
        string lName = (yyvsp[-2].symbolInfo)->getName();
        string rName = (yyvsp[0].symbolInfo)->getName();
        string relop = (yyvsp[-1].symbolInfo)->getName();
        
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-2].symbolInfo)->getName() + (yyvsp[-1].symbolInfo)->getName() + (yyvsp[0].symbolInfo)->getName(), "CONST_INT");
        logFoundRule("rel_expression", "simple_expression RELOP simple_expression");

        if(isVoidFunc(lType)) {
            // Do nothing
            // Error message handled in isVoidFunction
        } else if(isVoidFunc(rType)) {
            // Do nothing
            // Error message handled in isVoidFunction
        } else {
            typeCastIgnoreSide((yyvsp[-2].symbolInfo), (yyvsp[0].symbolInfo), "Type Mismatch");
        }

        logMatchedString((yyval.symbolInfo)->getName());

        string labelIfTrue = newLabel();
        string labelIfFalse = newLabel();

        string code = "\t\t;Checking if " + lName + relop + rName + "\n";
        code += "\t\tPOP BX\t;popped out " + rName + "\n";
        code += "\t\tPOP AX\t;popped out " + lName + "\n";
        code += "\t\tCMP AX, BX\t;comparing " + lName + " and " + rName + "\n";
        code += "\t\t" + relopSymbolToAsmJumpText(relop) + " " + labelIfTrue + "\n";
        code += "\t\tPUSH 0\t;false\n";
        code += "\t\tJMP " + labelIfFalse + "\n";
        code += "\t\t" + labelIfTrue + ":\n";
        code += "\t\tPUSH 1\t;true\n";
        code += "\t\t" + labelIfFalse + ":\n";

        writeInCodeSegment(code);

        delete (yyvsp[-2].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 3276 "1805087.tab.c"
    break;

  case 66:
#line 1379 "1805087.y"
         {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("simple_expression", "term", (yyval.symbolInfo)->getName());
    }
#line 3285 "1805087.tab.c"
    break;

  case 67:
#line 1383 "1805087.y"
                                 {
        string lType = (yyvsp[-2].symbolInfo)->getType();
        string rType = (yyvsp[0].symbolInfo)->getType();
        string name = (yyvsp[-2].symbolInfo)->getName() + (yyvsp[-1].symbolInfo)->getName() + (yyvsp[0].symbolInfo)->getName();
        string addop = (yyvsp[-1].symbolInfo)->getName();
        string type = rType;

        logFoundRule("simple_expression", "simple_expression ADDOP term");

        if(isVoidFunc(lType)) {
            // Do nothing
            // Error message handled in isVoidFunction
            // type is already equals rType
        }
        else if(isVoidFunc(rType)) {
            type = lType;
        } else {
            type = typeCastIgnoreSide((yyvsp[-2].symbolInfo), (yyvsp[0].symbolInfo), "Type Mismatch");
        }

        logMatchedString(name);

        string addopText = addop == "+" ? "ADD" : "SUB";
        string code = "\t\t;line no " + to_string(lineCount) + ": " + addopText + " " +  (yyvsp[-2].symbolInfo)->getName() + " and " + (yyvsp[0].symbolInfo)->getName() + "\n";
        code += "\t\tPOP BX\t;" + (yyvsp[0].symbolInfo)->getName() + " popped\n";
        code += "\t\tPOP AX\t;" + (yyvsp[-2].symbolInfo)->getName() + " popped\n";

        code += "\t\t" + addopText + " AX, BX\n";

        code += "\t\tPUSH AX\t;pushed " + (yyvsp[-2].symbolInfo)->getName() + addop + (yyvsp[0].symbolInfo)->getName() + "\n";
        writeInCodeSegment(code);

        (yyval.symbolInfo) = new SymbolInfo(name, type);
        delete (yyvsp[-2].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 3327 "1805087.tab.c"
    break;

  case 68:
#line 1424 "1805087.y"
                     {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("term", "unary_expression", (yyval.symbolInfo)->getName());
    }
#line 3336 "1805087.tab.c"
    break;

  case 69:
#line 1428 "1805087.y"
                                {
        string mulop = (yyvsp[-1].symbolInfo)->getName();
        string lType = (yyvsp[-2].symbolInfo)->getType();
        string ueName = (yyvsp[0].symbolInfo)->getName();
        string rType = (yyvsp[0].symbolInfo)->getType();
        string name = (yyvsp[-2].symbolInfo)->getName() + mulop + ueName;
        string type = rType;

        logFoundRule("term", "term MULOP unary_expression");

        if(isVoidFunc(lType)) {
            // Do nothing
            // Error message handled in isVoidFunction
            // Type is already equals rType
        }
        else if(isVoidFunc(rType)) {
            type = lType;
        } else if(mulop == "%") {
            if(lType != "CONST_INT" || rType != "CONST_INT")
                errorMessage("Non-Integer operand on modulus operator");
            else if(ueName == "0")
                errorMessage("Modulus by Zero");
            // result of modulus will always be integer
            type = "CONST_INT";
        } else if(mulop == "%" && ueName == "0") {
                errorMessage("Division by Zero");
        } else {
            type = typeCastIgnoreSide((yyvsp[-2].symbolInfo), (yyvsp[0].symbolInfo), "Type Mismatch");
        }

        logMatchedString(name);

        (yyval.symbolInfo) = new SymbolInfo(name, type);

        string operation = mulop == "%" ? "Modulus" : mulop == "*" ? "Multiplication" : "Division";
        string code = "\t\t;" + operation + " of " + (yyvsp[-2].symbolInfo)->getName() + " and " + (yyvsp[0].symbolInfo)->getName() + "\n";
        code += "\t\tPOP BX\t;" + (yyvsp[0].symbolInfo)->getName() + " popped\n";
        code += "\t\tPOP AX\t;" + (yyvsp[-2].symbolInfo)->getName() + " popped\n";
        if(mulop == "*") {
            code += "\t\tIMUL BX\t;AX = " + (yyvsp[-2].symbolInfo)->getName() + " * " + (yyvsp[0].symbolInfo)->getName() + "\n";
        } else {
            code += "\t\tXOR DX, DX\t;resetting DX to 0\n";
            code += "\t\tIDIV BX\t;" + (yyvsp[-2].symbolInfo)->getName() + "/" + (yyvsp[0].symbolInfo)->getName() + "\n";
            if(mulop == "%")
                code += "\t\tMOV AX, DX\t;AX = " + (yyvsp[-2].symbolInfo)->getName() + "%" + (yyvsp[0].symbolInfo)->getName() + "\n";
        }
        code += "\t\tPUSH AX\t;pushed " + (yyvsp[-2].symbolInfo)->getName() + mulop + (yyvsp[0].symbolInfo)->getName() + "\n";
        writeInCodeSegment(code);
        
        delete (yyvsp[-2].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 3394 "1805087.tab.c"
    break;

  case 70:
#line 1484 "1805087.y"
                           {
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-1].symbolInfo)->getName() + (yyvsp[0].symbolInfo)->getName(), (yyvsp[0].symbolInfo)->getType());
        logFoundRule("unary_expression", "ADDOP unary_expression", (yyval.symbolInfo)->getName());

        string rName = (yyvsp[0].symbolInfo)->getName();
        if((yyvsp[-1].symbolInfo)->getName() == "-") {
            string code = "\t\t;line no " + to_string(lineCount) + ": Negating " + rName + "\n";
            code += "\t\tPOP AX\t;popped " + rName + "\n";
            code += "\t\tNEG AX\t;negating " + rName + "\n";
            code += "\t\tPUSH AX\t;pushed -" + rName + "\n";
            writeInCodeSegment(code);
        }

        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 3415 "1805087.tab.c"
    break;

  case 71:
#line 1500 "1805087.y"
                         {
        (yyval.symbolInfo) = new SymbolInfo("!" + (yyvsp[0].symbolInfo)->getName(), (yyvsp[0].symbolInfo)->getType());
        logFoundRule("unary_expression", "NOT unary_expression", (yyval.symbolInfo)->getName());

        string rName = (yyvsp[0].symbolInfo)->getName();
        string labelIfZero = newLabel();
        string labelEnd = newLabel();

        string code = "\t\t;line no " + to_string(lineCount) + ": Logical NOT of " + rName + "\n";
        code += "\t\tPOP AX\t;popped " + rName + "\n";
        code += "\t\tCMP AX, 0\t;comparing " + rName + " with 0\n";
        code += "\t\tJE " + labelIfZero + "\t;jumping if " + rName + " is 0\n";
        code += "\t\tPUSH 0\t;" + rName + " is not 0 so setting it to 0\n";
        code += "\t\tJMP " + labelEnd + "\t;jumping to end\n";
        code += "\t\t" + labelIfZero + ":\n";
        code += "\t\tPUSH 1\t;" + rName + " is 0 so setting it to 1\n";
        code += "\t\t" + labelEnd + ":";
        
        writeInCodeSegment(code);

        delete (yyvsp[0].symbolInfo);
    }
#line 3442 "1805087.tab.c"
    break;

  case 72:
#line 1522 "1805087.y"
           {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("unary_expression", "factor", (yyval.symbolInfo)->getName());
    }
#line 3451 "1805087.tab.c"
    break;

  case 73:
#line 1529 "1805087.y"
             {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("factor", "variable", (yyval.symbolInfo)->getName());

        if(((IdInfo*)(yyvsp[0].symbolInfo))->getArraySize() > 0)
            writeInCodeSegment("\t\tPOP BX\t;array index popped because it is no longer required");
    }
#line 3463 "1805087.tab.c"
    break;

  case 74:
#line 1536 "1805087.y"
                                   {
        // It's a function call
        string id = (yyvsp[-3].symbolInfo)->getName();
        string varName = id + "(" + (yyvsp[-1].symbolInfo)->getName() + ")";
    
        logFoundRule("factor", "ID LPAREN argument_list RPAREN");
    
        SymbolInfo* symbolInfo = symbolTable.lookUp(id);
        
        if(symbolInfo == NULL) {
            // if it was not declared before
            errorMessage("Undeclared function " + id);
            (yyval.symbolInfo) = new SymbolInfo(varName, "UNDEC");
        } else if(symbolInfo->getIsFunction()) {
            FunctionInfo* functionInfo = (FunctionInfo*)symbolInfo;
            // if it is a function then set the return type as the type of the expression
            string retType = functionInfo->getReturnType();
            if(retType == "CONST_VOID")
                retType = "FUNC_VOID";

            (yyval.symbolInfo) = new SymbolInfo(varName, retType);
            // check the consistency of the prameters
            if(functionInfo->getNumberOfParameters() != argList.size())
                errorMessage("Total number of arguments mismatch in function " + id);
            else {
                int i = 0;
                list<SymbolInfo*>::iterator it = argList.begin();
                
                while(it != argList.end()) {
                    SymbolInfo* tempSymbol = new SymbolInfo("dummy", functionInfo->getParameterTypeAtIdx(i));
                    typeCast(tempSymbol, *it, to_string(1 + i) + "th argument mismatch in function " + id);
                    
                    delete tempSymbol;
                    delete (*it);
                    argList.erase(it++);
                    i++;
                }
            }

        } else {
            // then it must be an id. Set the id type as the type of the expression
            errorMessage(id + " is not a function");
            (yyval.symbolInfo) = new SymbolInfo(varName, ((IdInfo*)symbolInfo)->getIdType());
        }
        
        // call the function
        string code = "\t\tCALL " + id + "\n";
        code += "\t\tPUSH AX\t;pushed return value of " + id;
        writeInCodeSegment(code);

        // Clear the argList
        list<SymbolInfo*>::iterator it = argList.begin();
                
        while(it != argList.end()) {
            delete (*it);
            argList.erase(it++);
        }

        logMatchedString(varName);

        delete (yyvsp[-3].symbolInfo);
        delete (yyvsp[-1].symbolInfo);
    }
#line 3531 "1805087.tab.c"
    break;

  case 75:
#line 1599 "1805087.y"
                             {
        (yyval.symbolInfo) = new SymbolInfo("(" + (yyvsp[-1].symbolInfo)->getName() + ")", (yyvsp[-1].symbolInfo)->getType());
        logFoundRule("factor", "LPAREN expression RPAREN", (yyval.symbolInfo)->getName());
        delete (yyvsp[-1].symbolInfo);
    }
#line 3541 "1805087.tab.c"
    break;

  case 76:
#line 1604 "1805087.y"
              {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);

        string value = (yyval.symbolInfo)->getName();
        logFoundRule("factor", "CONST_INT", value);

        writeInCodeSegment("\t\tPUSH " + value);
    }
#line 3554 "1805087.tab.c"
    break;

  case 77:
#line 1612 "1805087.y"
                {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("factor", "CONST_FLOAT", (yyval.symbolInfo)->getName());
    }
#line 3563 "1805087.tab.c"
    break;

  case 78:
#line 1616 "1805087.y"
               {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("factor", "CONST_CHAR", (yyval.symbolInfo)->getName());
    }
#line 3572 "1805087.tab.c"
    break;

  case 79:
#line 1620 "1805087.y"
                                       {
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-1].symbolInfo)->getName() + (yyvsp[0].symbolInfo)->getName(), (yyvsp[-1].symbolInfo)->getType());
        logFoundRule("factor", "variable INCOP", (yyval.symbolInfo)->getName());

        string varName = (yyvsp[-1].symbolInfo)->getName();
        string incopVal = (yyvsp[0].symbolInfo)->getName();
        string incopText = incopVal == "++" ? "increment" : "decrement";
        IdInfo* idInfo = (IdInfo*)(yyvsp[-1].symbolInfo);
        // first save the value of the variable to AX
        // then increment the value of the variable by 1 using AX
        // set the value of the variable to its offset or to the global variable
        string code = "\t\t;line no " + to_string(lineCount) + ": postfix " + incopText + " of " + varName + "\n";

        int arraySize = idInfo->getArraySize();
        if(arraySize > 0) {
            code += "\t\tPOP BX\t;popped array index address\n";
            code += "\t\tMOV AX, [BX]\t;setting AX to the value of " + varName + "\n";
        }
        else {
            code += "\t\tPOP AX\t;setting AX to the value of " + varName + "\n";
            code += "\t\tPUSH AX\t;pushing the value of " + varName + " back to stack\n";
        }
        

        if(incopVal == "++")
            code += "\t\tINC AX\t;incrementing " + varName + "\n";
        else
            code += "\t\tDEC AX\t;decrementing " + varName + "\n";
        
        if(idInfo->getStackOffset() != -1) {
            if(arraySize > 0) 
                code += "\t\tMOV [BX], AX\t;saving the " + incopText + "ed value of " + varName + "\n";
            else
                code += "\t\tMOV [BP+" + to_string(idInfo->getStackOffset()) + "], AX\t;saving the " + incopText + "ed value of " + varName + "\n";
        } else {
            if(arraySize > 0)
                code += "\t\tMOV " + varName + "[BX], AX\t;saving the " + incopText + "ed value of " + varName + "\n";
            else
                code += "\t\tMOV " + varName + ", AX\t;saving the " + incopText + "ed value of " + varName + "\n";
        }

        writeInCodeSegment(code);

        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 3623 "1805087.tab.c"
    break;

  case 80:
#line 1666 "1805087.y"
                                      {
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-1].symbolInfo)->getName() + (yyvsp[0].symbolInfo)->getName(), (yyvsp[0].symbolInfo)->getType());
        logFoundRule("factor", "INCOP variable", (yyval.symbolInfo)->getName());

        string varName = (yyvsp[0].symbolInfo)->getName();
        string incopVal = (yyvsp[-1].symbolInfo)->getName();
        string incopText = incopVal == "++" ? "increment" : "decrement";
        IdInfo* idInfo = (IdInfo*)(yyvsp[0].symbolInfo);
        // first pop the value of the variable to AX
        // then increment the value of the variable by 1 using AX
        // push AX to the stack as it is a prefix operation
        // set the value of the variable to its offset or to the global variable
        int arraySize = idInfo->getArraySize();
        string code = "\t\t;line no " + to_string(lineCount) + ": prefix " + incopText + " of " + varName + "\n";

        if(arraySize > 0)
            code += "\t\tPOP BX\t;popped array index address\n";
        code += "\t\tPOP AX\t;popped " + varName + "\n";

        if(incopVal == "++")
            code += "\t\tINC AX\t;incrementing " + varName + "\n";
        else
            code += "\t\tDEC AX\t;decrementing " + varName + "\n";
        code += "\t\tPUSH AX\t;pushed " + varName + "\n";

        if(idInfo->getStackOffset() != -1) {
            if(arraySize > 0) 
                code += "\t\tMOV [BX], AX\t;saving the " + incopText + "ed value of " + varName + "\n";
            else
                code += "\t\tMOV [BP+" + to_string(idInfo->getStackOffset()) + "], AX\t;saving the " + incopText + "ed value of " + varName + "\n";
        } else {
            if(arraySize > 0)
                code += "\t\tMOV " + varName + "[BX], AX\t;saving the " + incopText + "ed value of " + varName + "\n";
            else
                code += "\t\tMOV " + varName + ", AX\t;saving the " + incopText + "ed value of " + varName + "\n";
        }

        writeInCodeSegment(code);

        delete (yyvsp[-1].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 3670 "1805087.tab.c"
    break;

  case 81:
#line 1711 "1805087.y"
              {
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("argument_list", "arguments", (yyval.symbolInfo)->getName());
    }
#line 3679 "1805087.tab.c"
    break;

  case 82:
#line 1715 "1805087.y"
    {
        (yyval.symbolInfo) = new SymbolInfo("", "VARIABLE");
        logFoundRule("argument_list", "arguments", "");
    }
#line 3688 "1805087.tab.c"
    break;

  case 83:
#line 1722 "1805087.y"
                                     {
        argList.push_back(new SymbolInfo((yyvsp[0].symbolInfo)->getName(), (yyvsp[0].symbolInfo)->getType()));
        (yyval.symbolInfo) = new SymbolInfo((yyvsp[-2].symbolInfo)->getName() + "," + (yyvsp[0].symbolInfo)->getName(), "VARIABLE");
        logFoundRule("arguments", "arguments COMMA logic_expression", (yyval.symbolInfo)->getName());

        delete (yyvsp[-2].symbolInfo);
        delete (yyvsp[0].symbolInfo);
    }
#line 3701 "1805087.tab.c"
    break;

  case 84:
#line 1730 "1805087.y"
                     {
        argList.push_back(new SymbolInfo((yyvsp[0].symbolInfo)->getName(), (yyvsp[0].symbolInfo)->getType()));
        (yyval.symbolInfo) = (yyvsp[0].symbolInfo);
        logFoundRule("arguments", "logic_expression", (yyval.symbolInfo)->getName());
    }
#line 3711 "1805087.tab.c"
    break;


#line 3715 "1805087.tab.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYEMPTY : YYTRANSLATE (yychar);

  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
# define YYSYNTAX_ERROR yysyntax_error (&yymsg_alloc, &yymsg, \
                                        yyssp, yytoken)
      {
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = YYSYNTAX_ERROR;
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == 1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = YY_CAST (char *, YYSTACK_ALLOC (YY_CAST (YYSIZE_T, yymsg_alloc)));
            if (!yymsg)
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = 2;
              }
            else
              {
                yysyntax_error_status = YYSYNTAX_ERROR;
                yymsgp = yymsg;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == 2)
          goto yyexhaustedlab;
      }
# undef YYSYNTAX_ERROR
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYTERROR;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;


#if !defined yyoverflow || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif


/*-----------------------------------------------------.
| yyreturn -- parsing is finished, return the result.  |
`-----------------------------------------------------*/
yyreturn:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  yystos[+*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  return yyresult;
}
#line 1737 "1805087.y"


/**
* Function that prints the code for println in code.asm
*/
void writeProcPrintln() {
    string str = "\t;println(n)\n";
    str += 
    "\tPRINT_INTEGER PROC NEAR\n\
        PUSH BP             ;Saving BP\n\
        MOV BP, SP          ;BP points to the top of the stack\n\
        MOV BX, [BP+4]    ;The number to be printed\n\
        ;if(BX < -1) then the number is positive\n\
        CMP BX, 0\n\
        JGE POSITIVE\n\
        ;else, the number is negative\n\
        MOV AH, 2           \n\
        MOV DL, '-'         ;Print a '-' sign\n\
        INT 21H\n\
        NEG BX              ;make BX positive\n\
        POSITIVE:\n\
        MOV AX, BX\n\
        MOV CX, 0        ;Initialize character count\n\
        PUSH_WHILE:\n\
            XOR DX, DX  ;clear DX\n\
            MOV BX, 10  ;BX has the divisor //// AX has the dividend\n\
            DIV BX\n\
            ;quotient is in AX and remainder is in DX\n\
            PUSH DX     ;Division by 10 will have a remainder less than 8 bits\n\
            INC CX       ;CX++\n\
            ;if(AX == 0) then break the loop\n\
            CMP AX, 0\n\
            JE END_PUSH_WHILE\n\
            ;else continue\n\
            JMP PUSH_WHILE\n\
        END_PUSH_WHILE:\n\
        MOV AH, 2\n\
        POP_WHILE:\n\
            POP DX      ;Division by 10 will have a remaainder less than 8 bits\n\
            ADD DL, '0'\n\
            INT 21H     ;So DL will have the desired character\n\
            DEC CX       ;CX--\n\
            ;if(CX <= 0) then end loop\n\
            CMP CX, 0\n\
            JLE END_POP_WHILE\n\
            ;else continue\n\
            JMP POP_WHILE\n\
        END_POP_WHILE:\n\
        ;Print newline\n\
        MOV DL, 0DH\n\
        INT 21H\n\
        MOV DL, 0AH\n\
        INT 21H\n\
        POP BP          ; Restore BP\n\
        RET 2\n\
    PRINT_INTEGER ENDP";

    write("code.asm", str, true);
    increaseCodeSegmentEndLine(stringLineCount(str) + 1);
}
/**
* Function that writes the required starting code to run the 8086 assembly code to the code.asm file
*/
void initializeAssembplyFile() {
    ofstream codeFile;
    codeFile.open("code.asm");

    if(!codeFile.is_open()) {
        cout << "code.asm file could not be opened" << endl;
        return;
    }

    codeFile << ".MODEL SMALL\n";
    codeFile << ".STACK 400H\n";
    codeFile << ".DATA\n";
    asmLineCount += 3;
    asmDataSegmentEndLine = asmLineCount;

    codeFile << ".CODE\n";
    asmCodeSegmentEndLine = ++asmLineCount;

    codeFile.close();
    
}

/**
* Function that writes the required ending code to run the 8086 assembly code to the code.asm file
*/
void terminateAssemblyCode() {
    ofstream codeFile;
    codeFile.open("code.asm", ios_base::app);

    if(!codeFile.is_open()) {
        cout << "code.asm file could not be opened" << endl;
        return;
    }

    codeFile << "END MAIN\n";
    asmLineCount++;

    codeFile.close();
}

void optimize() {
    bool isOptimized = false;
    int count = 0;
    if(errorCount == 0) {
        cout << "Optimizing..." << endl;
        isOptimized = optimizeAsmCode("code.asm", "temp_optimized_code.asm");
        rename("temp_optimized_code.asm", "optimized_code.asm");
    }

    while(isOptimized) {
        count++;
        isOptimized = optimizeAsmCode("optimized_code.asm", "temp_optimized_code.asm");
        remove("optimized_code.asm");
        rename("temp_optimized_code.asm", "optimized_code.asm");
    }

    cout << "optimization completed after " << count << " passes" << endl;
}

int main(int argc, char* argv[]) {
    if(argc != 2) {
        cout << "Please provide input file name and try again\n";
        return 0;
    }

    FILE* fin = fopen(argv[1], "r");
    
    if(fin == NULL) {
        printf("Cannot open input file\n");
        return 0;
    } 

    logFile.open("1805087_log.txt");
    errorFile.open("1805087_error.txt");
    
    initializeAssembplyFile();
    writeProcPrintln();
    
    yyin = fin;
    yyparse();

    if(errorCount > 0) {
        cout << "Compilation failed\n";
        cout << errorCount << " errors found\n";
        ofstream codeFile("code.asm");
        codeFile.close();
    } else {
        terminateAssemblyCode();
    }

    errorFile.close();
    logFile.close();
    fclose(fin);


    optimize();
    
    return 0;
}
