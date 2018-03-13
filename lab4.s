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
PIODATA EQU 0x8 ; Offset to parallel I/O data regis
prompt      = "Welcome to lab #4  ",0      
      ALIGN 
digits_SET   
            DCD 0x00001F80  ; 0 
            DCD 0x00003000  ; 1  
			DCD 0x00003080	; 2
			DCD 0x000
                            ; Place other display values here 
            DCD 0x00003880  ; F 
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
	
stop
	  
      LDMFD SP!, {lr}   ; Restore register lr from stack     
      BX LR 
      END 