#ifndef UTILS_FOR_ASM_H
#define UTILS_FOR_ASM_H

#include <bits/stdc++.h>
#include "SymbolTable.h"
#include "utils.h"
using namespace std;

void declareGlobalVariable(ofstream& out, string name, string type) {
    if (isFloat(type)) {
        return;
    }

    out << "\t" << name << " DW ?" << endl;
}

void declareGlobalArray(ofstream& out, string name, string type, int size) {
    if (isFloat(type)) {
        return;
    }
    out << "\t" << name << " DW " << size << " DUP(?)" << endl;
}

void initializeMain(ofstream& out) {
    out << "\t\tMOV AX, @DATA" << endl;
    out << "\t\tMOV DS, AX" << endl;
}

void terminateMain(ofstream& out) {
    out << "\t\tMOV AH, 4CH" << endl;
    out << "\t\tINT 21H" << endl;
}

void initializeProcedure(ofstream& out, string name, SymbolTable* st) {
    st->resetIdCount();

    out << "\t" << name << " PROC" << endl;

    if (name == "main") {
        initializeMain(out);
    } else {
        out << "\t\t; getting things ready" << endl;
        out << "\t\tPUSH BP" << endl;
        out << "\t\tMOV BP, SP ;offsets are based on BP" << endl;
    }
}

void terminateProcedure(ofstream& out, string name, unsigned paramCount) {
    if (name == "main") {
        terminateMain(out);
    } else {
        out << "\t\t;returning from procedure" << endl;
        out << "\t\tMOV SP, BP ;restoring SP" << endl;
        out << "\t\tPOP BP" << endl;
        out << "\t\tRET " << (paramCount ? to_string(paramCount*2) : "") << endl;
    }

    out << "\t" << name << " ENDP" << endl;
}

void insertId(ofstream& out, string name, string type, unsigned ) {
    // assuming no multiple declaration

}

void writeProcPrintln(ofstream& out) {
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

    out << str << endl;
}

#endif //UTILS_FOR_ASM_H