.def temp = r16

ldi r17, 0b00000000
.def counter = r17
ldi r18, 0    ; Clock timer, initialize to 0
MOV r20,r17



RESET:
	; Initialization code
	ldi temp, 0b11111111
	out DDRD, temp      	; Configure PD0 to PD7 as output
	out DDRE, temp      	; Configure PE4 as output
	clr counter         	; Clear counter
	;clr temp            	; Clear temp to ensure LEDs are off
	out PORTD,temp     	; Set LEDs off initially
	out PORTE,temp
    cbi DDRA, 0
	cbi DDRA, 1
	cbi DDRA, 2
	cbi DDRA, 3
	cbi DDRA, 4
    sbi PORTA, 0
	sbi PORTA, 1
	sbi PORTA, 2
	sbi PORTA, 3
	sbi PORTA, 4
    
    ; switch is active low
MAIN_LOOP:
    sbic PINA, 0
    rjmp CHECK_PA1
    rjmp PLUS_CHECK_MAX

CHECK_PA1:
    sbic PINA, 1
    rjmp CHECK_PA2
    rjmp MINUS_CHECK_MIN

CHECK_PA2:
    sbic PINA, 2
    rjmp CHECK_PA3
    rjmp CLEAR_BOARD

CHECK_PA3:
	sbic PINA, 3
	rjmp CHECK_PA4
	rjmp INC_BOARD

CHECK_PA4:
	sbic PINA, 4
	rjmp MAIN_LOOP
	rjmp DICE_START

PLUS_CHECK_MAX:
	 cpi counter, 31
	 breq PLUS_ZERO

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

PLUS_ZERO:
	clr counter
   	mov r20,r17
   	com r20
   	out PORTD, r20
   	call delay
check_plus_zero:  sbis PINA,0
   	rjmp check_plus_zero
   	call delay
   	rjmp MAIN_LOOP

MINUS_CHECK_MIN:
	cpi counter, 0
	breq MINUS_ZERO

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

MINUS_ZERO:
	ldi counter, 31
	mov r20, r17
	com r20
	out PORTD, r20
	call delay
check_minus_zero:  sbis PINA,1
   	rjmp check_minus_zero
   	call delay
   	rjmp MAIN_LOOP

BEEP:
    SBI PORTE, 4 ; pushing the speaker out 

    LDI R19, 95
    LOOP6: LDI R22, 20
    LOOP7: NOP
        DEC R22
        BRNE LOOP6
        DEC R19
        BRNE LOOP7

    CBI PORTE, 4 ; pulling the speaker in 

    LDI R19, 95
    LOOP4: LDI R22, 20
    LOOP5: NOP
        DEC R22
        BRNE LOOP5
        DEC R19
        BRNE LOOP4
	ret

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

DICE_START:
	call CLEAR_BOARD
	ldi counter, 0

CHECK_DICE:
	sbic PINA, 4
	rjmp DICE_CLEAR
	rjmp PLUS_DICE

DICE_CLEAR:
	sbic PINA, 2
	rjmp CHECK_DICE
	rjmp CLEAR_BOARD_MENU

PLUS_DICE:
    inc counter                        ; Increment the counter
    cpi counter, 7                     ; Compare the counter with 7
    brne SKIP_RESET_DICE                    ; If counter is not equal to 7, skip the reset
    ldi counter, 1                     ; If counter is equal to 7, reset it to 1
SKIP_RESET_DICE:
    call DISPLAY_DICE_FACE             ; Call the subroutine to display the dice face corresponding to the counter
    call DELAY                         ; Call the delay subroutine to wait for a while

CHECK_BUTTON_RELEASE:
    sbis PINA, 4                       ; Check if the bit 4 of PINA is set (SW5 released)
    rjmp CHECK_BUTTON_RELEASE          ; If SW2 is not released, keep checking
    rjmp CHECK_DICE                     ; If SW2 is released, go back to the main loop 

DISPLAY_DICE_FACE:
    ; Check the counter and call the corresponding subroutine
    cpi counter, 1       ; If counter is 1, display face 1
    breq DICE_ONE
    cpi counter, 2       ; If counter is 2, display face 2
    breq DICE_TWO
    cpi counter, 3       ; If counter is 3, display face 3
    breq DICE_THREE
    cpi counter, 4       ; If counter is 4, display face 4
    breq DICE_FOUR
    cpi counter, 5       ; If counter is 5, display face 5
    breq DICE_FIVE
    cpi counter, 6       ; If counter is 6, display face 6
    breq DICE_SIX
    ret

DICE_ONE:
    ldi temp, 0b11111111  ; Turn off all LEDs
    out PORTD, temp
    ldi temp, 0b11111111  ; Turn off LED5 
    out PORTE, temp
    call DELAY
    cbi PORTE, 5          ; Turn on LED5 
    ret

DICE_TWO:
	ldi temp,0b11111111
	out PORTD,temp
	ldi temp, 0b11111111  ; Turn off all LEDs
    out PORTE, temp
    ldi temp, 0b11011011  ; LEDs 3 and 7 
    out PORTD, temp
    call DELAY
    ret

DICE_THREE:
	ldi temp, 0b11111111
	out PORTD, temp
    ldi temp, 0b11011011 ; LEDs 3 and 7 on
    out PORTD, temp
	ldi temp, 0b00010000
    out PORTE, temp          ; Turn on LED5 
    call DELAY
	call DELAY
    ret

DICE_FOUR:
	ldi temp,0b11111111		; turn off LEDS
	out PORTD, temp
	ldi temp, 0b11111111   ; turn off PORT E
    out PORTE, temp
	ldi temp, 0b01011010 ; Turn on LED 7,3,1,and 9
    out PORTD, temp
    call DELAY
    ret

DICE_FIVE:
	ldi temp,0b11111111
	out PORTD, temp
    ldi temp, 0b01011010  ; LEDs 1, 3, 7, and 9 on
    out PORTD, temp
    ldi temp, 0b00010000
    out PORTE, temp             ; Turn on LED5 
    call DELAY
    ret

DICE_SIX:

	ldi temp,0b11111111
	out PORTD, temp
	ldi temp,0b11111111
	out PORTE,temp
    ldi temp, 0b01000010  ; LEDs 1, 3, 4, 6, 7, and 9 on
    out PORTD, temp
    call DELAY
    ret


CLEAR_BOARD:
	clr counter
	mov r20, r17
	com r20
	out PORTD, r20
	ldi temp, 0b11111111  ; Turn off LED5 
    out PORTE, temp
	ret

CLEAR_BOARD_MENU:
	clr counter
	mov r20, r17
	com r20
	out PORTD, r20
	ldi temp, 0b11111111  ; Turn off LED5 
    out PORTE, temp
	rjmp MAIN_LOOP


Delay:  LDI R19, 255

   	 LOOP2: LDI  R21, 255

   	 LOOP3: NOP
   		 DEC R21
   		 BRNE LOOP3
   		 DEC R19
   		 BRNE LOOP2
   		 ret