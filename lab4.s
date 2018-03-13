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
PIODATA EQU 0x8 ; Offset to parallel I/O data regis
prompt      = "Welcome to lab #4  ",0      
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
lab4 
      STMFD SP!,{lr}    ; Store register lr on stack 
	  
	  BL uart_init
	  
	  BL read_character
	  
	  CMP r0, #0x71
	  BEQ stop
	  
	  BL setup_pins
	  
loop	
	BL read_num_from_btns
	BL output_character
	
	CMP r0, #0x71
	BEQ stop
stop
	  
      LDMFD SP!, {lr}   ; Restore register lr from stack     
      BX LR 
      END 
