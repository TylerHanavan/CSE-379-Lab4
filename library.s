	AREA library, CODE, READWRITE
	EXPORT uart_init
	EXPORT read_string
	EXPORT read_character
	EXPORT output_string
	EXPORT output_character
	EXPORT read_bit
	EXPORT setup_pins
	EXPORT read_from_push_btns
	EXPORT read_num_from_btns
	EXPORT clear_display
	EXPORT change_display
	EXPORT illuminate_red
	EXPORT illuminate_green
	EXPORT illuminate_blue
	EXPORT illuminate_yellow
	EXPORT illuminate_white
	EXPORT illuminate_purple
	EXPORT illuminate_reset
	EXPORT digits_SET
	EXPORT new_line
	EXPORT pin_connect_block_setup_for_uart0
input = "                ",0		;input string with 16 max characters

	ALIGN
		
digits_SET   
    DCD 0x00003780  ; 0 
    DCD 0x00000300  ; 1  
	DCD 0x00009580	; 2
	DCD 0x00008780	; 3
	DCD 0x0000A300	; 4
	DCD 0x0000A680 	; 5
	DCD 0x0000B680	; 6
	DCD 0x00000738	; 7
	DCD 0x0000B780	; 8
	DCD 0x0000A730 	; 9
	DCD 0x0000B380	; A
	DCD 0x0000B600	; B
	DCD 0x0000B400	; C
	DCD 0x00009700	; D
	DCD 0x0000B480	; E
                            ; Place other display values here 
    DCD 0x0000B080  ; F 
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

read_string	
	STMFD SP!,{lr, r1, r2}			;push link register to stack
	
	LDR r1, =input			;load address of =input to r1
read_string_2
	BL read_character
	
	CMP r0, #0xD			;compares r0 to ascii value of enter/carriage return
	BEQ terminate_string		;if its equal we must terminate the string, jump to terminate string
	
	STRB r0, [r1], #1		;stores byte from r0 to the memory address in r1 (input), then increments memory address
	
	BL output_character		;jump to output character to display the character as user inputs charaters
	
	B read_string_2			;continue reading

terminate_string
	MOV r2, #0x0
	STRB r2, [r1]			;null-terminate the string stored in [r1]
	LDMFD sp!, {lr, r1, r2}			;pop link register from stack
	BX lr				;move pc,lr


read_character 				;Begin Receive Character block
	STMFD SP!,{lr, r3, r4, r5}
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
read_character_break
	LDMFD sp!, {lr, r3, r4, r5}
	BX lr

output_character 				;Begin Transmit Character block
	STMFD SP!,{lr, r3, r6, r5}
output_character_2
	LDR r3, =0xE000C014			;loads address of uart0 into register r3
	
	LDRB r6, [r3]				;loads bytes at address r3 into r6 (RXFE - RDR)
	
	MOV r5, #32					;immediate value 32 (00010000) copied into r5		
	AND r5, r6, r5				;logically AND r6 and r5 to compare the 5th bit(THRE) of r6
	
	CMP r5, #32					;if the fifth bit is 1, then we are ready to transmit
	BNE output_character_2		;else we redo the process
	
	; Transmitting
	
	LDR r5, =0xE000C000			;loads the address of the transmit holding register (same as receive buffer)
	
	STR r0, [r5]				;stores the value of r0 into the address at r5
	LDMFD sp!, {lr, r3, r6, r5}
	BX lr
	
	
output_string
	STMFD SP!,{lr, r0, r1}
	
output_string_2
	LDRB r0, [r4], #1      		;Load =prompt contents from memory (r4) to r0, one byte at a time. Then increments memory address, r4, by 1.
	BL output_character			;Branch and link to output_character
	
	CMP r0,#0					;compares r0 to null terminator
	BNE output_string_2			;if equal we continue on with program
	
	BL new_line
	
	LDMFD sp!, {lr, r0, r1}
	BX lr
	
new_line
	STMFD SP!,{lr, r10}
	MOV r10, r0					;saves contents of r0 into r10 before using it
	MOV r0, #0xA				;new line character copied into r0
	BL output_character			;branch and link to output character
	MOV r0, #0xD				;carriage return copied into r0
	BL output_character			;branch and link to output character
	MOV r0, r10					;takes saved content from r10 and copies into r0
	;CMP r8, #0xD				;checks if r8 has  carriage return and jumps to clear it
	;BEQ clear_read_character
	LDMFD sp!, {lr, r10}
	BX lr	 
	
clear_read_character
	STMFD SP!,{lr}
	MOV r8, #0x0				;clears r8 to prevent infinite loop
	LDMFD sp!, {lr}
	BX lr

setup_pins
	STMFD SP!,{lr, r1, r2, r3}

	LDR r1, =0xE002C004			;PINSEl1
	LDR r2, [r1]
	MOV r3, #0x0
	BIC r2, r2, r3
	STR r2, [r1]

	LDR r1, =0xE002C000			;PINSEL0
	LDR r2, [r1]
	MOV r3, #0xF00000
	BIC r2, r2, r3
	STR r2, [r1]

	LDR r1, =0xE0028008			;IODIR for Seven-Seg
	LDR r2, [r1]
	LDR r3, =0xB784
	STR r3, [r1]

	LDR r1, =0xE0028008			;IODIR for RGBLED
	LDR r2, [r1]
	MOV r3, #0x26
	MOV r3, r3, LSL #16
	STR r3, [r1]				;somehow illuminates led rgb

	LDMFD sp!, {lr, r1, r2, r3}
	BX lr 

read_from_push_btns
	STMFD SP!,{lr, r1}
	
	LDR r1, =0xE0028010		;IO1PIN
	LDR r1, [r1]
	MVN r1, r1
	AND r1, r1, #0xF00000
	MOV r0, r1, LSR #20
	
	;MOV r5, #22
	;MOV r4, r1
	;BL read_bit
	
	;MVN r0, r0
	;ADD r0, r0, #1
	;AND r0, r0, 0xF

	LDMFD sp!,{lr, r1}
	BX lr

read_num_from_btns
	STMFD SP!,{lr, r1, r2, r3}
	
	MOV r3, #0
	
	BL read_from_push_btns
	
	AND r1, r0, #8
	
	CMP r1, #8
	BNE rnf_add_8_skip

rnf_add_8
	ADD r3, r3, #1
rnf_add_8_skip
	AND r1, r0, #4
	
	CMP r1, #4
	BNE rnf_add_4_skip
	
rnf_add_4
	ADD r3, r3, #2
rnf_add_4_skip
	AND r1, r0, #2
	
	CMP r1, #2
	BNE rnf_add_2_skip
	
rnf_add_2
	ADD r3, r3, #4
rnf_add_2_skip
	AND r1, r0, #1
	
	CMP r1, #1
	BNE rnf_add_1_skip
	
rnf_add_1
	ADD r3, r3, #8
rnf_add_1_skip

	MOV r0, r3

	LDMFD sp!,{lr, r1, r2, r3}
	BX lr

led_set					;set LED at bit r4 to value at bit r5
	STMFD SP!,{lr, r2, r3}
	
	CMP r5, #0
	BEQ low
	
high
	LDR r3, =0xE0028014
	;MOV r2, #1 LSL r4
	STR r2, [r3]
low
	LDR r3, =0xE002800C
	;MOV r2, #1 LSL r4
	STR r2, [r3]
	LDMFD sp!, {lr, r2, r3}
	BX lr

read_bit				;reads and checks if bit locations specified in r5 are set to '1' in r4
	STMFD SP!,{lr, r3}
	MOV r3, r4
	AND r4, r4, r5
	CMP r4, #0x0
	BEQ read_bit_ret_0
read_bit_ret_1
	MOV r0, #0x1
	B read_bit_end
read_bit_ret_0
	MOV r0, #0x0
read_bit_end
	MOV r4, r3
	LDMFD sp!, {lr, r3}
	BX lr

change_display				;Displays hex value passed in r0
	STMFD SP!,{lr, r1, r2, r3}

	LDR r1, =0xE0028000 		; Base address 
	LDR r3, =digits_SET 
	;MOV r0, r0, LSL #2 		; Each stored value is 32 bits 
	LDR r2, [r3, r0]   		; Load IOSET pattern for digit in r0 
	STR r2, [r1, #4]   		; Display (0x4 = offset to IOSET) 

	LDMFD sp!, {lr, r1, r2, r3}
	BX lr
	
clear_display
	
	
illuminate_red
	STMFD SP!, {lr, r0, r1, r2}

	LDR r0, =0xE002800C	
	LDR r1, [r0]
	MOV r2, #0x2
	MOV r2, r2, LSL #16 
	ORR r1, r1, r2
	STR r1, [r0]	

	LDMFD SP!, {lr, r0, r1, r2}
	BX lr


illuminate_blue
	STMFD SP!, {lr, r0, r1, r2}

	LDR r0, =0xE002800C
	LDR r1, [r0]
	MOV r2, #0x4
	MOV r2, r2, LSL #16
	ORR r1, r1, r2
	STR r1, [r0]

	LDMFD SP!, {lr, r0, r1, r2}
	BX lr


illuminate_green
	STMFD SP!, {lr, r0, r1, r2}

	LDR r0, =0xE002800C
	LDR r1, [r0]
	MOV r2, #0x20
	MOV r2, r2, LSL #16
	ORR r1, r1, r2
	STR r1, [r0]

	LDMFD SP!, {lr, r0, r1, r2}
	BX lr

illuminate_white
	STMFD SP!, {lr}

	LDR r0, =0xE002800C
	LDR r1, [r0]
	MOV r2, #0x26
	MOV r2, r2, LSL #16
	ORR r1, r1, r2
	STR r1, [r0]

	LDMFD SP!, {lr}
	BX lr

illuminate_purple
	STMFD SP!, {lr}

	LDR r0, =0xE002800C
	LDR r1, [r0]
	MOV r2, #0x6
	MOV r2, r2, LSL #16
	ORR r1, r1, r2
	STR r1, [r0]

	LDMFD SP!, {lr}
	BX lr

illuminate_yellow
	STMFD SP!, {lr}

	LDR r0, =0xE002800C
	LDR r1, [r0]
	MOV r2, #0x24
	MOV r2, r2, LSL #16
	ORR r1, r1, r2
	STR r1, [r0]

	LDMFD SP!, {lr}
	BX lr

illuminate_reset
	STMFD SP!, {lr, r0, r1, r2}

	LDR r0, =0xE0028004
	LDR r1, [r0]
	MOV r2, #0x26
	MOV r2, r2, LSL #16
	ORR r1, r1, r2
	STR r1, [r0]
	
	;BL clear_green

	LDMFD SP!, {lr, r0, r1, r2}
	BX lr
		
clear_green
	STMFD SP!, {lr, r0, r1, r2}
	
	LDR r0, =0xE0028004
	LDR r1, [r0]
	MOV r2, #0x1
	MOV r2, r2, LSL #21
	ORR r1, r1, r2
	STR r1, [r0]
		
	LDMFD SP!, {lr, r0, r1, r2}
	BX lr


output_to_decimal
	STMFD SP!, {lr, r0, r1, r2}
	MOV r2, r0
	MOV r0, #0
otd_loop_1000
	MOV r1, #1000
	CMP r2, r1
	BGT otd_loop_1000_skip

	SUB r2, r2, r1
	ADD r0, r0, #1

otd_loop_1000_skip
	BL output_character
	MOV r0, #0

otd_loop_100
        MOV r1, #100
        CMP r2, r1
        BGT otd_loop_100_skip

        SUB r2, r2, r1
        ADD r0, r0, #1

otd_loop_100_skip
        BL output_character
        MOV r0, #0

otd_loop_10
        MOV r1, #10
        CMP r2, r1
        BGT otd_loop_10_skip

        SUB r2, r2, r1
        ADD r0, r0, #1

otd_loop_10_skip
        BL output_character
        MOV r0, #0

otd_loop_1
        MOV r1, #1
        CMP r2, r1
        BGT otd_loop_1_skip

        SUB r2, r2, r1
        ADD r0, r0, #1

otd_loop_1_skip
        BL output_character
        MOV r0, #0

	LDMFD SP!, {lr, r0, r1, r2}
	BX lr

pin_connect_block_setup_for_uart0
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000  ; PINSEL0
	LDR r1, [r0]
	ORR r1, r1, #5
	BIC r1, r1, #0xA
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr





	END
