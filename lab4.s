		AREA  GPIO, CODE, READWRITE    
		EXPORT lab4 
		EXTERN uart_init
		EXTERN read_string
		EXTERN read_character
		EXTERN output_string
		EXTERN output_character
		EXTERN read_bit
		EXTERN setup_pins
		EXTERN read_from_push_btns
		EXTERN read_num_from_btns
		EXTERN change_display
		EXTERN clear_display
		EXTERN illuminate_red
		EXTERN illuminate_blue
		EXTERN illuminate_green
		EXTERN illuminate_yellow
		EXTERN illuminate_white
		EXTERN illuminate_purple
		EXTERN illuminate_reset
		EXTERN digits_SET
PIODATA EQU 0x8 ; Offset to parallel I/O data regis
prompt = "Welcome to lab #4  ",0
color = "Press 'c' to change a color",0
leds = "Press 'l' to modify LEDs",0
segment = "Press 's' to change the seven-segment display",0
quit = "Press 'q' at anytime to quit",0
pick_color = "Pick a color: [w : white, b : blue, g : green, r : red, p : purple, y : yellow]",0
menu = "Press 'm' to return to the main menu at any time",0
display = "Enter a hexadecimal character to display (capitalized)",0      
      ALIGN 

lab4 
      STMFD SP!,{lr}    ; Store register lr on stack 
	  
	  BL uart_init

	MOV r1, #0
	MOV r2, #0
	  	  
	  BL setup_pins
	  BL illuminate_reset

loop	
	
	BL read_character
	CMP r0, #0x63
	BLEQ init_color

	CMP r0, #0x71
	BEQ stop
	B loop

init_seven_segment
	STMFD SP!, {lr}

loop_seven_segment

	BL read_character
	CMP r0, #0x6D
	BEQ end_seven_segment

	CMP r0, #0x71
	BEQ stop

	BL output_character	
	SUB r0, r0, #0x30
	CMP r0, #0x0
	BLT loop_seven_segment
	CMP r0, #0xF
	BGT loop_seven_segment
	BL change_display

	B loop_seven_segment

end_seven_segment

	LDMFD SP!, {lr}
	BX lr
	
init_color
	STMFD SP!,{lr}

	LDR r4, =color
	BL read_string

	MOV r1, #1
loop_color
	BL read_character
	CMP r0, #0x72
	BEQ color_red
	CMP r0, #0x79
	BEQ color_yellow
	CMP r0, #0x62
	BEQ color_blue
	CMP r0, #0x77
	BEQ color_white
	CMP r0, #0x67
	BEQ color_green
	CMP r0, #0x70
	BEQ color_purple
	CMP r0, #0x71
	BEQ stop

	B loop_color


color_red
	BL illuminate_red
	B color_end

color_green
	BL illuminate_green
	B color_end

color_blue
	BL illuminate_blue
	B color_end

color_white
	BL illuminate_white
	B color_end

color_purple
	BL illuminate_purple
	B color_end

color_yellow
	BL illuminate_yellow
	B color_end

color_end	

	LDMFD SP!,{lr}
	BX lr

stop
	  
      LDMFD SP!, {lr}   ; Restore register lr from stack     
      BX LR 
      END 
