.MODEL SMALL
.STACK 400H
.DATA
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
	main PROC
		MOV AX, @DATA
		MOV DS, AX
		PUSH BX    ;line no 3: i declared
		PUSH BX    ;line no 3: j declared
		PUSH BX    ;line no 3: k declared
		PUSH BX    ;line no 3: ll declared
		PUSH BX    ;line no 3: m declared
		PUSH BX    ;line no 3: n declared
		PUSH BX    ;line no 3: o declared
		PUSH BX    ;line no 3: p declared
		PUSH [BP+-2]	; i pushed
		PUSH 1
		POP AX	;1 popped
		MOV [BP+-2], AX	;assigned 1 to i
		POP AX	;Popped out i=1

		PUSH [BP+-2]	;passing i to PRINT_INTEGER
		CALL PRINT_INTEGER

		PUSH [BP+-4]	; j pushed
		PUSH 5
		PUSH 8
		;line no 7: ADD 5 and 8
		POP BX	;8 popped
		POP AX	;5 popped
		ADD AX, BX
		PUSH AX	;pushed 5+8

		POP AX	;5+8 popped
		MOV [BP+-4], AX	;assigned 5+8 to j
		POP AX	;Popped out j=5+8

		PUSH [BP+-4]	;passing j to PRINT_INTEGER
		CALL PRINT_INTEGER

		PUSH [BP+-6]	; k pushed
		PUSH [BP+-2]	; i pushed
		PUSH 2
		PUSH [BP+-4]	; j pushed
		;Multiplication of 2 and j
		POP BX	;j popped
		POP AX	;2 popped
		IMUL BX	;AX = 2 * j
		PUSH AX	;pushed 2*j

		;line no 9: ADD i and 2*j
		POP BX	;2*j popped
		POP AX	;i popped
		ADD AX, BX
		PUSH AX	;pushed i+2*j

		POP AX	;i+2*j popped
		MOV [BP+-6], AX	;assigned i+2*j to k
		POP AX	;Popped out k=i+2*j

		PUSH [BP+-6]	;passing k to PRINT_INTEGER
		CALL PRINT_INTEGER

		PUSH [BP+-10]	; m pushed
		PUSH [BP+-6]	; k pushed
		PUSH 9
		;Modulus of k and 9
		POP BX	;9 popped
		POP AX	;k popped
		XOR DX, DX	;resetting DX to 0
		IDIV BX	;k/9
		MOV AX, DX	;AX = k%9
		PUSH AX	;pushed k%9

		POP AX	;k%9 popped
		MOV [BP+-10], AX	;assigned k%9 to m
		POP AX	;Popped out m=k%9

		PUSH [BP+-10]	;passing m to PRINT_INTEGER
		CALL PRINT_INTEGER

		PUSH [BP+-12]	; n pushed
		PUSH [BP+-10]	; m pushed
		PUSH [BP+-8]	; ll pushed
		;Checking if m<=ll
		POP BX	;popped out ll
		POP AX	;popped out m
		CMP AX, BX	;comparing m and ll
		JLE L_1
		PUSH 0	;false
		JMP L_2
		L_1:
		PUSH 1	;true
		L_2:

		POP AX	;m<=ll popped
		MOV [BP+-12], AX	;assigned m<=ll to n
		POP AX	;Popped out n=m<=ll

		PUSH [BP+-12]	;passing n to PRINT_INTEGER
		CALL PRINT_INTEGER

		PUSH [BP+-14]	; o pushed
		PUSH [BP+-2]	; i pushed
		PUSH [BP+-4]	; j pushed
		;Checking if i!=j
		POP BX	;popped out j
		POP AX	;popped out i
		CMP AX, BX	;comparing i and j
		JNE L_3
		PUSH 0	;false
		JMP L_4
		L_3:
		PUSH 1	;true
		L_4:

		POP AX	;i!=j popped
		MOV [BP+-14], AX	;assigned i!=j to o
		POP AX	;Popped out o=i!=j

		PUSH [BP+-14]	;passing o to PRINT_INTEGER
		CALL PRINT_INTEGER

		PUSH [BP+-16]	; p pushed
		PUSH [BP+-12]	; n pushed
		PUSH [BP+-14]	; o pushed
		;line no 21: n||o
		POP BX	; o popped
		POP AX	; n popped
		CMP AX, 0	; comparing n and 0
		JE L_5	; if n is 0, check o. So, jump to L_5
		PUSH 1	; n is not 0, the whole expression is true. So, set the value to 1
		JMP L_7
		L_5:
		CMP BX, 0	; comparing o and 0
		JE L_6	; if o is 0, the whole expression is false. So, jump to L_6
		PUSH 1	; n and o are true. So, set the value to 1
		JMP L_7
		L_6:
		PUSH 0	; n and o are false. So, set the value to 0
		L_7:

		POP AX	;n||o popped
		MOV [BP+-16], AX	;assigned n||o to p
		POP AX	;Popped out p=n||o

		PUSH [BP+-16]	;passing p to PRINT_INTEGER
		CALL PRINT_INTEGER

		PUSH [BP+-16]	; p pushed
		PUSH [BP+-12]	; n pushed
		PUSH [BP+-14]	; o pushed
		;line no 24: n&&o
		POP BX	; o popped
		POP AX	; n popped
		CMP AX, 0	; comparing n and 0
		JNE L_8	; if n is not 0, check o. So, jump to L_8
		PUSH 0	; n is 0, the whole expression is 0. So, set the value to 0
		JMP L_10
		L_8:
		CMP BX, 0	; comparing o and 0
		JNE L_9	; if o is not 0, the whole expression is true. So, jump to L_9
		PUSH 0	; n and o are false. So, set the value to 0
		JMP L_10
		L_9:
		PUSH 1	; n and o are true. So, set the value to 1
		L_10:

		POP AX	;n&&o popped
		MOV [BP+-16], AX	;assigned n&&o to p
		POP AX	;Popped out p=n&&o

		PUSH [BP+-16]	;passing p to PRINT_INTEGER
		CALL PRINT_INTEGER

		PUSH [BP+-16]	; p pushed
		;line no 27: postfix increment of p
		POP AX	;setting AX to the value of p
		PUSH AX	;pushing the value of p back to stack
		INC AX	;incrementing p
		MOV [BP+-16], AX	;saving the incremented value of p

		POP AX	;Popped out p++

		PUSH [BP+-16]	;passing p to PRINT_INTEGER
		CALL PRINT_INTEGER

		PUSH [BP+-6]	; k pushed
		PUSH [BP+-16]	; p pushed
		;line no 30: Negating p
		POP AX	;popped p
		NEG AX	;negating p
		PUSH AX	;pushed -p

		POP AX	;-p popped
		MOV [BP+-6], AX	;assigned -p to k
		POP AX	;Popped out k=-p

		PUSH [BP+-6]	;passing k to PRINT_INTEGER
		CALL PRINT_INTEGER

		PUSH 0
		MOV AH, 4CH
		INT 21H
		MOV AH, 4CH
		INT 21H
	main ENDP
END MAIN
