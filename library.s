	AREA library, CODE, READWRITE
	EXPORT uart_init
	EXPORT read_string
	EXPORT read_character
	EXPORT output_string
	EXPORT output_character
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
	EXPORT output_to_decimal	
	EXPORT pin_connect_block_setup_for_uart0
input = "                ",0		;input string with 16 max characters

	ALIGN
		
digits_SET   
    DCD 0x00003780  ; 0 
    DCD 0x00003000  ; 1  
	DCD 0x00009580	; 2
	DCD 0x00008780	; 3
	DCD 0x0000A300	; 4
	DCD 0x0000A680 	; 5
	DCD 0x0000B680	; 6
	DCD 0x00000380	; 7
	DCD 0x0000B780	; 8
	DCD 0x0000A380 	; 9
	DCD 0x0000B380	; A
	DCD 0x0000B600	; B
	DCD 0x00003480	; C
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

	LDR r1, =0xE002C004			;PINSEl1 -> r1
	LDR r2, [r1]				;load contents to r2
	MOV r3, #0x0				;copy #0 to r3
	BIC r2, r2, r3				;bitclear r2 masked r3
	STR r2, [r1]				;store results in r1

	LDR r1, =0xE002C000			;PINSEL0 -> r1
	LDR r2, [r1]				;Load contents to r2
	MOV r3, #0xF00000			;copy 0xF00000 to r3
	BIC r2, r2, r3				;bitclear r2 by mask r3
	STR r2, [r1]				;store results in r1

	LDR r1, =0xE0028008			;IODIR for Seven-Seg
	;LDR r2, [r1]	
	LDR r3, =0x26B784			;Load 0x26B784 (for bit manipulation) to r3
	STR r3, [r1]				;store results to r1
	
	LDR r1, =0xE0028018			
	LDR r3, =0xF0000
	STR r3, [r1]				;store contents 0xF0000 to memory at 0xE0028018
 
	;LDR r1, =0xE0028008			;IODIR for RGBLED
	;LDR r2, [r1]
	;MOV r3, #0x26
	;MOV r3, r3, LSL #16
	;STR r3, [r1]				;somehow illuminates led rgb
;
	LDMFD sp!, {lr, r1, r2, r3}
	BX lr 

read_from_push_btns
	STMFD SP!,{lr, r1, r4, r5}
	
	LDR r1, =0xE0028010		;IO1PIN
	LDR r1, [r1]				; Load memory contents of IO1PIN to r1
	MVN r1, r1					;Negate r1
	AND r1, r1, #0xF00000		;Clear all bits besides the 6th byte's bits
	MOV r0, r1, LSR #20			;Logical shift right r1 and store in r0
	MOV r1, r0					;Copy r0 to r1
	
	BL clear_leds				;clear the leds
	
l23_pushed

	AND r1, r1, #1				;AND r1 against #1 and store r1
	CMP r1, #1
	BNE l22_pushed				;Branch to l22_pushed if r1 != #1
	
	MOV r4, #16					;Copy 16 dec. to r4
	MOV r5, #1					;Copy 1 to r5
	
	BL led_set					;Set bit at r4 to value at r5
	
l22_pushed

	MOV r1, r0					;Copy r0 to r1

	AND r1, r1, #2  			;AND r1 against #2 and store r1
	CMP r1, #2
	BNE l21_pushed				;Branch to l21_pushed if r1 != #2
	
	MOV r4, #17					;Copy #17 to r4
	MOV r5, #1					;Copy #1 to r5
	
	BL led_set					;Set bit at r4 to value at r5
	
l21_pushed

	MOV r1, r0					;Copy r0 to r1

	AND r1, r1, #4  			;AND r1 against #4 and store r1
	CMP r1, #4		
	BNE l20_pushed				;Branch to l20_pushed if r1 != #4				
	
	MOV r4, #18					;Copy 18 dec. to r4
	MOV r5, #1					;Copy 1 to r5
	
	BL led_set					;Set bit at r4 to value at r5
	
l20_pushed

	MOV r1, r0					;Copy r0 to r1

	AND r1, r1, #8				;And r1 against 8
	CMP r1, #8					
	BNE rfpb_end				;Branch to rfpb_end if r1 != 8
	
	MOV r4, #19					;Copy #19 dec. to r4
	MOV r5, #1					;Move #1 to r5
	
	BL led_set					;Set led at r4 to value at r5
	
rfpb_end

	LDMFD sp!,{lr, r1, r4, r5}
	BX lr

read_num_from_btns
	STMFD SP!,{lr, r1, r2, r3}
	
	MOV r3, #0						;Copy 0 to r3
	
	BL read_from_push_btns			
	
	AND r1, r0, #8					;AND r0 & #8 and store in r1. To check if a certain bit is set
	
	CMP r1, #8
	BNE rnf_add_8_skip				;Branch to rnf_add_8_skip if r1 != #8

rnf_add_8
	ADD r3, r3, #1					;Increment r3
rnf_add_8_skip
	AND r1, r0, #4					;AND r0 & #4, store results to r1. To check if a certain bit is set
	
	CMP r1, #4
	BNE rnf_add_4_skip				;Branch to rnf_add_4_skip if r1 != #4
	
rnf_add_4
	ADD r3, r3, #2					;ADD r3 + #2, store results to r3
rnf_add_4_skip
	AND r1, r0, #2					;AND r0 & #2, store results to r1. To check if a certain bit is set
	
	CMP r1, #2
	BNE rnf_add_2_skip				;Branch to rnf_add_2_skip if r1 != #2
	
rnf_add_2
	ADD r3, r3, #4					;ADD r3 + 4
rnf_add_2_skip
	AND r1, r0, #1					;AND r0 against #1, store r1. To check if a certain bit is set
	
	CMP r1, #1
	BNE rnf_add_1_skip				;Branch to rnf_add_1_skip if r1 != #1
	
rnf_add_1
	ADD r3, r3, #8					;Add 8 to r3
rnf_add_1_skip

	MOV r0, r3						;Copy r3 to r0 to return result and preserve r3

	LDMFD sp!,{lr, r1, r2, r3}
	BX lr
	
clear_leds							;Clears all LEDS. Values in r4 are LEDs to clear
	STMFD SP!, {lr, r4, r5}

	MOV r5, #0						;Copy 0 to r5
	MOV r4, #16						;Copy #16 dec. to r4
	BL led_set						
	MOV r4, #17						;Copy #17 tp r4
	BL led_set
	MOV r4, #18						;Copy #18 to r4
	BL led_set
	MOV r4, #19						;Copy #19 to r4
	BL led_set	

	LDMFD SP!, {lr, r4, r5}
	BX lr
	
led_set					;set LED at bit r4 to value at bit r5
	STMFD SP!,{lr, r2, r3}
	
	MOV r2, #1					;#1 -> r2
	
	CMP r5, #0					
	BEQ low						;Branch to low if r5 == #0
	
high
	LDR r3, =0xE002801C			;P1xCLR to r3
	MOV r2, r2, LSL r4			;Logical shift left r2 by r4
	STR r2, [r3]				;Store results in P1xCLR
	B led_set_end
low
	LDR r3, =0xE0028014			;P1xSET to r3
	MOV r2, r2, LSL r4			;Logical shift left r2 by r4
	STR r2, [r3]				;Store results in r3
led_set_end
	LDMFD sp!, {lr, r2, r3}
	BX lr


change_display				;Displays hex value passed in r0
	STMFD SP!,{lr, r1, r2, r3}

	LDR r1, =0xE0028000 		; Base address 
	LDR r3, =digits_SET 
	MOV r0, r0, LSL #2 		; Each stored value is 32 bits 
	LDR r2, [r3, r0]   		; Load IOSET pattern for digit in r0 
	STR r2, [r1, #4]   		; Display (0x4 = offset to IOSET) 

	LDMFD sp!, {lr, r1, r2, r3}
	BX lr
	
clear_display
	STMFD SP!,{lr, r1, r2, r3}
	
	LDR r1, =0xE002800C							;Load P0xCLR to r1
	LDR r2, =0xB784								;Load number (to r2) for bits of seven-segment display
	STR r2, [r1]								;Store number in P0xClr at r1
	
	LDMFD sp!, {lr, r1, r2, r3}
	BX lr
	
	
illuminate_red
	STMFD SP!, {lr, r0, r1, r2}

	LDR r0, =0xE002800C							;Load P0xCLR to r0
	LDR r1, [r0]								;Load contents to r1
	MOV r2, #0x2								;Copy 0x3 to r2
	MOV r2, r2, LSL #16 						;Logical shift left r2 by 16
	ORR r1, r1, r2								;Or r1 with r2
	STR r1, [r0]								;Store result in r0

	LDMFD SP!, {lr, r0, r1, r2}
	BX lr


illuminate_blue
	STMFD SP!, {lr, r0, r1, r2}

	LDR r0, =0xE002800C							;Load P0xCLR to r0
	LDR r1, [r0]								;Load contents to r1
	MOV r2, #0x4								;Mov 0x4 to r2
	MOV r2, r2, LSL #16							;logical shift left r2 by 16
	ORR r1, r1, r2								; or r1 with r2
	STR r1, [r0]								; store result to r0

	LDMFD SP!, {lr, r0, r1, r2}
	BX lr


illuminate_green
	STMFD SP!, {lr, r0, r1, r2}

	LDR r0, =0xE002800C							;Load P0xCLR to r0
	LDR r1, [r0]								;Load contents to r1
	MOV r2, #0x20								;Move 0x20 to r2 (to manipulate respective bits)
	MOV r2, r2, LSL #16							;logical shift left r2 by 16
	ORR r1, r1, r2								; or r1 with r2
	STR r1, [r0]								; store its contents to r0

	LDMFD SP!, {lr, r0, r1, r2}
	BX lr

illuminate_white
	STMFD SP!, {lr}

	LDR r0, =0xE002800C							;Load P0xCLR to r0
	LDR r1, [r0]								; load its contents to r1
	MOV r2, #0x26								;Move 0x26 to r2 (to manipulate bits in P0xCLR)
	MOV r2, r2, LSL #16							;logical shift left by 16 on r2
	ORR r1, r1, r2								; or r1 with r2
	STR r1, [r0]								; store contents r0

	LDMFD SP!, {lr}
	BX lr

illuminate_purple
	STMFD SP!, {lr}
	
	BL illuminate_red
	BL illuminate_blue

	LDMFD SP!, {lr}
	BX lr

illuminate_yellow
	STMFD SP!, {lr}
	
	BL illuminate_blue
	BL illuminate_green

	LDMFD SP!, {lr}
	BX lr

illuminate_reset
	STMFD SP!, {lr, r0, r1, r2}

	LDR r0, =0xE0028004							; load P0xSET -> r0
	LDR r1, [r0]								; load its contents
	MOV r2, #0x26								; 0x26 (respective bits to maniupulate in the P0xSET) -> r2
	MOV r2, r2, LSL #16							; shift left 16 places
	ORR r1, r1, r2								; or r1 with r2
	STR r1, [r0]								; store results to r0

	LDMFD SP!, {lr, r0, r1, r2}
	BX lr


output_to_decimal
	STMFD SP!, {lr, r0, r1, r2}	
	MOV r2, r0									; r0 -> r2
	MOV r0, #0									; 0 -> r0

otd_loop_10
	MOV r1, #10									; 10 dec. -> r1
	CMP r2, r1
	BLT otd_loop_10_skip						; branch otd_loop_10_skip if r2 < r1

	SUB r2, r2, r1								; subtract r1 from r2, store r2
	ADD r0, r0, #1								; increment r0
	
	CMP r2, r1
	BGE otd_loop_10								;branch otd_loop_10 if r2 > r1

otd_loop_10_skip
	ADD r0, r0, #0x30							; add 0x30 to r0
	BL output_character							; output that character
	MOV r0, #0									; 

otd_loop_1
	MOV r1, #1									; 1 -> r1
	CMP r2, r1									; compare r2 and r1, branch otd_loop_1_skip if less than
	BLT otd_loop_1_skip

	SUB r2, r2, r1								; subtract r1 from r2 store r2
	ADD r0, r0, #1								; increment r0
		
	CMP r2, r1
	BGE otd_loop_1								; branch otd_loop_1 if r2 > r1

otd_loop_1_skip
	ADD r0, r0, #0x30							; Add 0x30 to r0
	BL output_character							
	MOV r0, #0									;  0 -> r0

	LDMFD SP!, {lr, r0, r1, r2}
	BX lr

pin_connect_block_setup_for_uart0
	STMFD sp!, {r0, r1, lr}						;Push stack
	LDR r0, =0xE002C000  ; PINSEL0				;Load pinsel0 r0
	LDR r1, [r0]								;Load pinsel0 contents to r1
	ORR r1, r1, #5								; Or with 5 dec.
	BIC r1, r1, #0xA							; Clear against 0xA
	STR r1, [r0]								; Store results to r0 in memory
	LDMFD sp!, {r0, r1, lr}						;Pop stack
	BX lr										;Branch back





	END
