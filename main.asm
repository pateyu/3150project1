.def temp = r16

ldi r17, 0b00000000
.def counter = r17
MOV r20,r17



RESET:
	; Initialization code
	ldi temp, 0b00011111
	out DDRD, temp      	; Configure PD0 to PD4 as output
	out DDRE, temp      	; Configure PE4 as output
	clr counter         	; Clear counter
	;clr temp            	; Clear temp to ensure LEDs are off
	out PORTD,temp     	; Set LEDs off initially
    cbi DDRA, 0
    sbi PORTA, 0
    
    ; switch is active low
MAIN_LOOP:
    sbic PINA, 0
    
    rjmp MAIN_LOOP
    rjmp PLUS

	sbic PINB, 0
	
	rjmp MAIN_LOOP
	rjmp MINUS

	sbic PINC, 0

	rjmp MAIN_LOOP
	rjmp CLEAR_BOARD



PLUS:
   	 inc counter
   	 mov r20,r17
   	 com r20
   	 out PORTD, r20
   	 call delay
check:  sbis PINA,0
   	 rjmp check
   	 call delay
   	 rjmp MAIN_LOOP

MINUS:
   	 dec counter
	 mov r20, r17
	 com r20
	 out PORTD, r20
	 call delay
check_minus:  sbis PINB,0
   	 rjmp check
   	 call delay
   	 rjmp MAIN_LOOP
   	
CLEAR_BOARD:
	clr counter
	mov r20, r17
	out PORTD, r20
	rjmp MAIN_LOOP


Delay:  LDI R18, 255

   	 LOOP2: LDI  R19, 255

   	 LOOP3: NOP
   		 DEC R19
   		 BRNE LOOP3
   		 DEC R18
   		 BRNE LOOP2
   		 ret
