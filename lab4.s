		AREA  GPIO, CODE, READWRITE    
		EXPORT lab4 
		EXTERN uart_init
		EXTERN read_string
		EXTERN read_character
		EXTERN output_string
		EXTERN output_character
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
		EXTERN output_to_decimal
		EXTERN digits_SET
		EXTERN pin_connect_block_setup_for_uart0
		EXTERN new_line
PIODATA EQU 0x8 ; Offset to parallel I/O data regis
prompt = "Welcome to lab #4  ",0
color = "(c) : Pick a color for RGB-LED",0
leds = "(l) : Modify LEDs and display value in decimal (press & hold buttons prior to this option)",0
segment = "(s) : To display a hexadecimal number (LETTERS IN CAPS ONLY)",0
quit = "(q) : Quit the program",0
pick_color = "Pick a color: [w : white, b : blue, g : green, r : red, p : purple, y : yellow, d : off]",0
menu = "Press 'm' to return to the main menu at any time",0
display = "Enter a hexadecimal character to display (capitalized)",0      
goodbye = "Exiting program, goodbyte!",0
returning_menu = "Returning to main menu.",0
white = "White selected",0
red = "Red selected",0
green = "Green selected",0
blue = "Blue selected",0
yellow = "Yellow selected",0
purple = "Purple selected",0
	  ALIGN 

lab4 
	STMFD SP!,{lr}    ; Store register lr on stack 
	
	BL pin_connect_block_setup_for_uart0
	BL uart_init			;init uart and pin connect block

	MOV r1, #0			;Copy 0 to r1
	MOV r2, #0			;Copy 0 to r2
	  	  
	BL setup_pins			;setup pins
	BL illuminate_reset		;clear rgbled
	
	BL illuminate_white		;illuminate rgbled to white

	BL clear_display		;clear the 7seg display
	  
	;BL read_character
	
	;BL output_character	

	BL display_menu			;display the menu

loop	
	
	BL read_character		;read character
	BL output_character
	BL new_line
	CMP r0, #0x63			
	BLEQ init_color			;branch init_color if c is pressed
	CMP r0, #0x73
	BLEQ init_seven_segment		;branch init_seven_segment if s is pressed
	CMP r0, #0x6C
	BLEQ init_led			;branch init_led if l is pressed

	CMP r0, #0x71			
	BEQ stop			;quit if q is pressed
	B loop				;loop above
	
display_menu
	STMFD SP!, {lr}
	
	BL new_line

	LDR r4, =color			
	BL output_string		;display color prompt
	LDR r4, =segment		
	BL output_string		;display segment prompt
	LDR r4, =leds
	BL output_string		;display leds prompt
	LDR r4, =quit
	BL output_string		;display goodbyte quit prompt

	LDMFD SP!, {lr}
	BX lr

init_seven_segment
	STMFD SP!, {lr}
	
	LDR r4, =display
	BL output_string		;display display prompt

loop_seven_segment

	BL read_character
	CMP r0, #0x6D
	BEQ end_seven_segment		;quit seven segment if m is pressed

	CMP r0, #0x71			;quit if q is pressed
	BEQ stop

	BL output_character	
	BL new_line
	CMP r0, #0x30	
	BLT loop_seven_segment		;check if number is less than ascii 0
	CMP r0, #0x46	
	BGT loop_seven_segment		;check if number is greater than ascii F
	CMP r0, #0x3A
	BLT lss_num			;check if is number, branch lss_num if so
lss_let		
	SUB r0, r0, #0x41		;convert Ascii capital letter to decimal
	ADD r0, r0, #10			;increment r0 by 10
	B lss_skip			; branch skip
lss_num
	SUB r0, r0, #0x30		;convert ascii number to decimal number
lss_skip

	BL clear_display		;clear display
	
	BL change_display		;show display changes

end_seven_segment

	BL display_menu			;display menu

	LDMFD SP!, {lr}
	BX lr
	
init_led	
	STMFD SP!,{lr}
	
	BL read_num_from_btns
	BL output_to_decimal
	BL new_line
	
	BL display_menu

	LDMFD SP!, {lr}
	BX lr
	
init_color
	STMFD SP!,{lr}

	LDR r4, =pick_color		;display pick color menu
	BL output_string		

	MOV r1, #1
loop_color
	BL read_character		;read a character
	CMP r0, #0x72		
	BEQ color_red			;branch color_red if r
	CMP r0, #0x79
	BEQ color_yellow		;branch color_yellow if y
	CMP r0, #0x62
	BEQ color_blue			;branch color_blue if b
	CMP r0, #0x77
	BEQ color_white			;branch color_white if w
	CMP r0, #0x67
	BEQ color_green			;branch color_green if g
	CMP r0, #0x70
	BEQ color_purple		;branch color_purple if p
	CMP r0, #0x64
	BEQ color_off			;branch color_off if d
	CMP r0, #0x71
	BEQ stop			;branch stop if q

	B loop_color			;repeat loop

color_off
	BL illuminate_reset
	B color_end

color_red
	LDR r4, =red
	BL output_string		;output red string
	BL illuminate_reset
	BL illuminate_red
	B color_end

color_green
	LDR r4, =blue
	BL output_string		;output blue string
	BL illuminate_reset
	BL illuminate_green
	B color_end

color_blue
	LDR r4, =red			;output blue string
	BL output_string
	BL illuminate_reset
	BL illuminate_blue
	B color_end

color_white
	LDR r4, =white			;output white string
	BL output_string
	BL illuminate_reset
	BL illuminate_white
	B color_end

color_purple
	LDR r4, =purple			;output purple string
	BL output_string
	BL illuminate_reset
	BL illuminate_purple
	B color_end

color_yellow
	LDR r4, =yellow			;output yellow string
	BL output_string
	BL illuminate_reset
	BL illuminate_yellow
	B color_end

color_end	

	BL display_menu			;display menu

	LDMFD SP!,{lr}
	BX lr

stop
	LDR r4, =goodbye		;output goodbye string
	BL output_string
	
  
  LDMFD SP!, {lr}   ; Restore register lr from stack     
  BX LR 
  END 
