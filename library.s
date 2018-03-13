	EXPORT uart_init
	EXPORT read_string
	EXPORT read_character
	EXPORT output_string
	EXPORT output_character
	EXPORT read_bit
	EXPORT setup_pins
	EXPORT read_from_push_btns

input = "                ",0		;input string with 16 max characters

	ALIGN

uart_init
	STMFD SP!,{lr}			;push link register to stack
	LDR r0, =0xE000C00C		;loads the memory address 0xE000C00C into r0
	MOV r1, #131			;copies decimal 131 into r1
	STR r1, [r0]			;stores r1 into the memory address at r0
	LDR r0, =0xE000C000		;loads the memory address 0xE000C000 into r0
	MOV r1, #120			;copies decimal 120 into r1
	STR r1, [r0]			;stores r1 into the memory address at r0
	LDR r0, =0xE000C004		;loads the memory address 0xE000C004 into r0
	MOV r1, #0			;copies decimal 0 into r1
	STR r1, [r0]			;stores r1 into the memory address at r0
	LDR r0, =0xE000C00C		;loads the memory address 0xE000C00C into r0
	MOV r1, #3			;copies decimal 3 into r1
	STR r1, [r0]			;stores r1 into the memory address at r0
	LDMFD sp!, {lr}			;pop link register from stack
	BX lr				;move pc,lr

read_character
	STMFD SP!,{lr}			;push link register to stack
	STMFD SP!,{r3}			;push r3 to stack
	STMFD SP!,{r4}			;push r4 to stack
	STMFD SP!,{r5}			;push r5 to stack
read_character_2
	LDR r3, =0xE000C014		;loads the address of uart0 into register r3 
	
	LDRB r4, [r3]			;loads the bytes at address r3 into r4 (RXFE - RDR)
	
	MOV r5, #1			;immediate value 1 is copied into r5
	AND r5, r4, r5			;logically AND r4 and r5 to compare the LSB(RDR) of r4
	
	CMP r5, #1			;if the value of r5 is one, we are ready to receive data
	BNE read_character_2		;else redo the process
	
	; Receiving
	
	LDR r3, =0xE000C000		;loads the address of the receive buffer register into r5
	LDR r0, [r3]			;hex value at r3 is loaded into r0
	LDMFD sp!, {r5}			;pop r5 from stack
	LDMFD sp!, {r4}			;pop r4 from stack
	LDMFD sp!, {r3}			;pop r3 from stack
	LDMFD sp!, {lr}			;pop link register from stack
	BX lr				;move pc,lr

read_string	
	STMFD SP!,{lr}			;push link register to stack
	STMFD SP!,{r1}			;push r1 to stack
	
	LDR r1, =input			;load address of =input to r1
read_string_2
	BL read_character
	
	CMP r0, #0xD			;compares r0 to ascii value of enter/carriage return
	BEQ terminate_string		;if its equal we must terminate the string, jump to terminate string
	
	STRB r0, [r1], #1		;stores byte from r0 to the memory address in r1 (input), then increments memory address
	
	BL output_character		;jump to output character to display the character as user inputs charaters
	
	B read_string_2			;continue reading

terminate_string
	STRB 0x0 [r1]			;null-terminate the string stored in [r1]
	LDMFD sp!, {r1}			;pop r1 from stack
	LDMFD sp!, {lr}			;pop link register from stack
	BX lr				;move pc,lr


read_character 				;Begin Receive Character block
	STMFD SP!,{lr}
	STMFD SP!,{r3}
	STMFD SP!,{r4}
	STMFD SP!,{r5}
read_character_2
	LDR r3, =0xE000C014		;loads the address of uart0 into register r3 
	
	LDRB r4, [r3]			;loads the bytes at address r3 into r4 (RXFE - RDR)
	
	MOV r5, #1			;immediate value 1 is copied into r5
	AND r5, r4, r5			;logically AND r4 and r5 to compare the LSB(RDR) of r4
	
	CMP r5, #1			;if the value of r5 is one, we are ready to receive data
	BNE read_character_2		;else redo the process
	
	; Receiving
	
	LDR r3, =0xE000C000		;loads the address of the receive buffer register into r5
	LDR r0, [r3]			;hex value at r3 is loaded into r8
	LDMFD sp!, {r5}
	LDMFD sp!, {r4}
	LDMFD sp!, {r3}	
	LDMFD sp!, {lr}
	BX lr



setup_pins
	STMFD SP!,{lr}
	STMFD SP!,{r1}
	STMFD SP!,{r2}	

	LDR r1, 0xE002C004
	;MOV r2, 0x2
	STR r2, [r1]

	LDMFD sp!, {r2}
	LDMFD sp!, {r1}
	LDMFD sp!, {lr}
	BX lr 

read_from_push_btns
	STMFD SP!,{lr}
	STMFD SP!,{r1}
	
	LDR r1, 0xE0028010		;IO1PIN
	

	LDMFD sp!,{r1}
	LDMFD sp!,{lr}
	BX lr



read_bit				;reads and checks if bit locations specified in r5 are set to '1' in r4
	STMFD SP!,{lr}
	STMFD SP!,{r3}
	MOV r3, r4
	AND r4, r4, r5
	CMP r4, 0x0
	BEQ read_bit_ret_0
read_bit_ret_1
	MOV r0, 0x1
	B read_bit_end
read_bit_ret_0
	MOV r0, 0x0
read_bit_end
	MOV r4, r3
	LDMFD sp!, {r3}
	LDMFD sp!, {lr}
	BX lr
