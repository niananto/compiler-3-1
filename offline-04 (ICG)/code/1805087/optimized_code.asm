.MODEL SMALL
.STACK 400H
	;println(n)
.DATA
.CODE
	PRINT_INTEGER PROC NEAR
        PUSH BP             ;Saving BP
        ;if(BX < -1) then the number is positive
        MOV BP, SP          ;BP points to the top of the stack
        MOV BX, [BP+4]    ;The number to be printed
        ;else, the number is negative
        CMP BX, 0
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
            ;quotient is in AX and remainder is in DX
            MOV BX, 10  ;BX has the divisor //// AX has the dividend
            DIV BX
            ;if(AX == 0) then break the loop
            PUSH DX     ;Division by 10 will have a remainder less than 8 bits
            INC CX       ;CX++
            ;else continue
            CMP AX, 0
            JE END_PUSH_WHILE
            JMP PUSH_WHILE
        END_PUSH_WHILE:
        MOV AH, 2
        POP_WHILE:
            POP DX      ;Division by 10 will have a remaainder less than 8 bits
            ADD DL, '0'
            ;if(CX <= 0) then end loop
            INT 21H     ;So DL will have the desired character
            DEC CX       ;CX--
            ;else continue
            CMP CX, 0
            JLE END_POP_WHILE
        ;Print newline
            JMP POP_WHILE
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
		PUSH BX    ;line no 2: a declared
;		PUSH 10
;		POP AX	;10 popped
		PUSH [BP+-2]	; a pushed
		MOV AX, 10
		MOV [BP+-2], AX	;assigned 10 to a
		POP AX	;Popped out a=10
		PUSH [BP+-2]	;passing a to PRINT_INTEGER
		CALL PRINT_INTEGER
		MOV AH, 4CH
		INT 21H
	main ENDP
END MAIN
