.def temp = r16

ldi r17, 0b00000000
.def counter = r17
ldi r18, 0    ; Clock timer, initialize to 0
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
	cbi DDRA, 1
	cbi DDRA, 2
	cbi DDRA, 3
    sbi PORTA, 0
	sbi PORTA, 1
	sbi PORTA, 2
	sbi PORTA, 3
    
    ; switch is active low
MAIN_LOOP:
    sbic PINA, 0
    rjmp CHECK_PA1
    rjmp PLUS

CHECK_PA1:
    sbic PINA, 1
    rjmp CHECK_PA2
    rjmp MINUS

CHECK_PA2:
    sbic PINA, 2
    rjmp CHECK_PA3
    rjmp CLEAR_BOARD

CHECK_PA3:
	sbic PINA, 3
	rjmp MAIN_LOOP
	rjmp INC_BOARD

PLUS:
   	 inc counter
   	 mov r20,r17
   	 com r20
   	 out PORTD, r20
   	 call delay
check_plus:  sbis PINA,0
   	 rjmp check_plus
   	 call delay
   	 rjmp MAIN_LOOP

MINUS:
   	 dec counter
	 mov r20, r17
	 com r20
	 out PORTD, r20
	 call delay
check_minus:  sbis PINA,1
   	 rjmp check_minus
   	 call delay
   	 rjmp MAIN_LOOP

INC_BOARD:
    ; Increment the board based on a timer
    inc r18
    cpi r18, 255    ; Check if r18 reached a certain value (adjust as needed)
    brne NO_SOUND
    inc counter    ; Increment the counter
	; Introduce a delay loop to slow down the increment
    ldi r21, 255   ; Adjust this value for your desired delay
	OUTER_DELAY_LOOP:
		ldi r19, 255
		INNER_DELAY_LOOP:
		dec r19
		brne INNER_DELAY_LOOP
		dec r21
		brne OUTER_DELAY_LOOP

	mov r20, r17
	com r20
	out PORTD, r20
	call PLAY_SOUND

    ; No specific sound for other counter values
    rjmp MAIN_LOOP


PLAY_SOUND:
    LDI R22, 20 ; Adjust this value for sound duration
    LDI R21, 1  ; Initialize the sound control bit

SOUND_LOOP:
    SBI PORTE, 4   ; Push out the speaker (sound on)
    LDI R19, 20   ; Adjust this value for the sound delay

SOUND_DELAY_LOOP_ON:
    NOP
    DEC R19
    BRNE SOUND_DELAY_LOOP_ON

    CBI PORTE, 4   ; Pull back the speaker (sound off)
    LDI R19, 20   ; Adjust this value for the sound delay

SOUND_DELAY_LOOP_OFF:
    NOP
    DEC R19
    BRNE SOUND_DELAY_LOOP_OFF

    DEC R22   ; Decrement the sound duration
    BRNE SOUND_LOOP

    RET
   
NO_SOUND:
    rjmp MAIN_LOOP

CLEAR_BOARD:
	clr counter
	mov r20, r17
	com r20
	out PORTD, r20
	rjmp MAIN_LOOP


Delay:  LDI R19, 255

   	 LOOP2: LDI  R21, 255

   	 LOOP3: NOP
   		 DEC R21
   		 BRNE LOOP3
   		 DEC R19
   		 BRNE LOOP2
   		 ret