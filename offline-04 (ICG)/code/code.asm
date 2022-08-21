.MODEL SMALL
.STACK 400H
.DATA

	b DW ?

.CODE

	;println(n)
	PRINT_INTEGER PROC NEAR
        PUSH BP             ;Saving BP
        MOV BP, SP          ;BP points to the top of the stack
        MOV BX, [BP+4]    ;The number to be printed
        ;if(BX < -1) then the number is positive
        CMP BX, 0
        JGE POSITIVE
        ;else, the number is negative
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
            DIV BX
            ;quotient is in AX and remainder is in DX
            PUSH DX     ;Division by 10 will have a remainder less than 8 bits
            INC CX       ;CX++
            ;if(AX == 0) then break the loop
            CMP AX, 0
            JE END_PUSH_WHILE
            ;else continue
            JMP PUSH_WHILE
        END_PUSH_WHILE:
        MOV AH, 2
        POP_WHILE:
            POP DX      ;Division by 10 will have a remaainder less than 8 bits
            ADD DL, '0'
            INT 21H     ;So DL will have the desired character
            DEC CX       ;CX--
            ;if(CX <= 0) then end loop
            CMP CX, 0
            JLE END_POP_WHILE
            ;else continue
            JMP POP_WHILE
        END_POP_WHILE:
        ;Print newline
        MOV DL, 0DH
        INT 21H
        MOV DL, 0AH
        INT 21H
        POP BP          ; Restore BP
        RET 2
    PRINT_INTEGER ENDP
			;type_specifier : INT
			;declaration_list : ID
			;var_declaration : type_specifier declaration_list SEMICOLON
			;unit : var_declaration
			;program : unit
			;type_specifier : INT
	main PROC
		MOV AX, @DATA
		MOV DS, AX
			;type_specifier : INT
			;declaration_list : ID
			;declaration_list : declaration_list COMMA ID
			;declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
			;var_declaration : type_specifier declaration_list SEMICOLON
		PUSH BX ;line no: 4 pushed a
		PUSH BX ;line no: 4 pushed b
		MOV SP, [BP+-10] ;line no: 4 pushed c
			;statement : var_declaration
			;statements : statement
			;variable : ID

		PUSH [BP+-2] ;line no: 5
			;factor : CONST_INT
		PUSH 1 ;line no: 5
			;unary_expression : factor
			;term : unary_expression
			;factor : CONST_INT
		PUSH 2 ;line no: 5
			;unary_expression : factor
			;term : unary_expression
			;simple_expression : term
			;factor : CONST_INT
		PUSH 3 ;line no: 5
			;unary_expression : factor
			;term : unary_expression
			;simple_expression : simple_expression ADDOP term

		POP BX ;line no: 5
		POP AX ;line no: 5
		ADD AX, BX ;line no: 5
		PUSH AX ;line no: 5

			;rel_expression : simple_expression
			;logic_expression : rel_expression
			;expression : logic_expression
			;factor : LPAREN expression RPAREN
			;unary_expression : factor
			;term : term MULOP unary_expression

		POP BX ;line no: 5
		POP AX ;line no: 5
		IMUL BX ;line no: 5
		PUSH AX ;line no: 5

			;factor : CONST_INT
		PUSH 3 ;line no: 5
			;unary_expression : factor
			;term : term MULOP unary_expression

		POP BX ;line no: 5
		POP AX ;line no: 5
		XOR DX, DX ;line no: 5
		IDIV BX ;line no: 5
		MOV AX, DX ;line no: 5
		PUSH AX ;line no: 5

			;simple_expression : term
			;rel_expression : simple_expression
			;logic_expression : rel_expression
			;expression : variable ASSIGNOP logic_expression

		POP AX ;line no: 5
		MOV [BP+-2], AX ;line no: 5

			;expression_statement : expression SEMICOLON

		POP AX ;line no 5

			;statement : expression_statement
			;statements : statements statement
			;variable : ID

		PUSH [BP+-4] ;line no: 7
			;factor : CONST_INT
		PUSH 6 ;line no: 7
			;unary_expression : factor
			;term : unary_expression
			;simple_expression : term
			;rel_expression : simple_expression
			;logic_expression : rel_expression
			;expression : variable ASSIGNOP logic_expression

		POP AX ;line no: 7
		MOV [BP+-4], AX ;line no: 7

			;expression_statement : expression SEMICOLON

		POP AX ;line no 7

			;statement : expression_statement
			;statements : statements statement
			;statement : PRINTLN LPAREN ID RPAREN SEMICOLON

		PUSH [BP+-2] ;line no: 13
		CALL PRINT_INTEGER ;line no: 13

			;statements : statements statement
			;statement : PRINTLN LPAREN ID RPAREN SEMICOLON

		PUSH [BP+-4] ;line no: 14
		CALL PRINT_INTEGER ;line no: 14

			;statements : statements statement
			;compound_statement : LCURL statements RCURL
			;func_definition : type_specifier ID LPAREN RPAREN compound_statement
		MOV AH, 4CH
		INT 21H
	main ENDP
			;unit : func_definition
			;program : program unit
			;start : program
END MAIN
