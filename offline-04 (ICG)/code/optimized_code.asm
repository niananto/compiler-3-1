.MODEL SMALL
.STACK 400H
.DATA
	;println(n)
.CODE
	PRINT_INTEGER PROC NEAR
        PUSH BP             ;Saving BP
        MOV BP, SP          ;BP points to the top of the stack
        ;if(BX < -1) then the number is positive
        MOV BX, [BP+4]    ;The number to be printed
        CMP BX, 0
        ;else, the number is negative
        JGE POSITIVE
        MOV AH, 2           
        MOV DL, '-'         ;Print a '-' sign
        INT 21H
        NEG BX              ;make BX positive
        POSITIVE:
        MOV AX, BX
        MOV CX, 0        ;Initialize character count
        PUSH_WHILE:
            XOR DX, DX  ;clear DX
            MOV BX, 10  ;BX has the divisor //// AX has the dividend
            ;quotient is in AX and remainder is in DX
            DIV BX
            PUSH DX     ;Division by 10 will have a remainder less than 8 bits
            ;if(AX == 0) then break the loop
            INC CX       ;CX++
            CMP AX, 0
            ;else continue
            JE END_PUSH_WHILE
            JMP PUSH_WHILE
        END_PUSH_WHILE:
        MOV AH, 2
        POP_WHILE:
            POP DX      ;Division by 10 will have a remaainder less than 8 bits
            ADD DL, '0'
            INT 21H     ;So DL will have the desired character
            ;if(CX <= 0) then end loop
            DEC CX       ;CX--
            CMP CX, 0
            ;else continue
            JLE END_POP_WHILE
            JMP POP_WHILE
        ;Print newline
        END_POP_WHILE:
        MOV DL, 0DH
        INT 21H
        MOV DL, 0AH
        INT 21H
        POP BP          ; Restore BP
        RET 2
    PRINT_INTEGER ENDP
	main PROC
		MOV AX, @DATA
		MOV DS, AX
		MOV SP, [BP+-6]	;array a[3] declared
		MOV AH, 4CH
		INT 21H
	main ENDP
END MAIN
