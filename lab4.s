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
        DCD 0x00001F80  ; 0 
        DCD 0x00003000  ; 1  
	DCD 0x00002D80	; 2
	DCD 0x00002780	; 3
	DCD 0x00003300	; 4
	DCD 0x00003680 	; 5
	DCD 0x00003E80	; 6
	DCD 0x00000380	; 7
	DCD 0x00003F80	; 8
	DCD 0x00003380 	; 9
	DCD 0x00003B80	; A
	DCD 0x00003000	; B
	DCD 0x00001C80	; C
	DCD 0x00002F00	; D
	DCD 0x	; E
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
	
	CMP r0, #0x71
	BEQ stop
stop
	  
      LDMFD SP!, {lr}   ; Restore register lr from stack     
      BX LR 
      END 
