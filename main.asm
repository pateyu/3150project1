.def temp = r16

ldi r17, 0b00000000
.def counter = r17
ldi r18, 0    ; Clock timer, initialize to 0
MOV r20,r17
.EQU MAX = 0x00
.def count =r27



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
	cbi DDRA, 7
	cbi DDRA, 6
	cbi DDRA, 5
    sbi PORTA, 0
	sbi PORTA, 1
	sbi PORTA, 2
	sbi PORTA, 3
	sbi PORTA, 4
	sbi PORTA, 7
	sbi PORTA, 6
	sbi PORTA, 5
    
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
	rjmp CHECK_PA7
	rjmp DICE_START
CHECK_PA7:
	sbic PINA,7
	rjmp CHECK_PA6
	call delay
	rjmp CHECK_COUNTER
CHECK_PA6:
	sbic PINA,6
	rjmp CHECK_PA5
	call delay
	rjmp CHECK_BUTTON_RELEASE6

CHECK_PA5:
	sbic PINA,5
	rjmp MAIN_LOOP
	RJMP BUZZER_START


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

PLUS_ZERO: ; this subroutine is called when increment button is pressed when the counter is already at 31, this function resets counter back to 0
	clr counter ; BEEP function should be called but I can't get it to work rn
	call TURN_ON_SPEAKER
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
	call TURN_ON_SPEAKER
	mov r20, r17
	com r20
	out PORTD, r20
	call delay
check_minus_zero:  sbis PINA,1
   	rjmp check_minus_zero
   	call delay
   	rjmp MAIN_LOOP

TURN_ON_SPEAKER:	LDI R31, 0x2F 
	SQUARE_WAVE:
		CBI PORTE, 4 ; set buzzer to high
		CALL SM_DELAY
		SBI PORTE, 4 ; set buzzer to low
		CALL SM_DELAY
		DEC R31
		BRNE SQUARE_WAVE
	RET

; Delay Function used for the buzzer
SM_DELAY:
	LDI R30, 100				
	OUT_LOOP:
		LDI R29, MAX
		IN_LOOP:
			NOP
			DEC R29
			BRNE IN_LOOP
		DEC R30
		BRNE OUT_LOOP
	RET

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

CHECK_COUNTER:
    cpi counter, 0
    breq H_LIGHT
    call delay
    call delay
    call delay
    rjmp I_LIGHT


H_LIGHT:
    ldi counter, 1       ; Update counter
    ldi r16, 0b01000010
    ldi r17, 0b11011111
    out PORTD, r16
    out PORTE, r17
    rjmp WAIT_FOR_RELEASE

I_LIGHT:
    ldi counter, 0       ; Reset counter
    ldi r16, 0b00011000
    ldi r17, 0b11001111  ; Turn on LED5 on PORTE (PE5)
    out PORTD, r16
    out PORTE, r17
    rjmp WAIT_FOR_RELEASE

WAIT_FOR_RELEASE:
    sbis PINA, 7
    rjmp WAIT_FOR_RELEASE
	rjmp MAIN_LOOP


CHECK_BUTTON_RELEASE6:
    sbis PINA, 6          ; Check if the button is released
    rjmp CHECK_BUTTON_RELEASE6
    rjmp SOS_SIGNAL

SOS_SIGNAL:
    call DOT
    call SPACE
    call DOT
    call SPACE
    call DOT
    call SPACE
    call DASH
    call SPACE
    call DASH
    call SPACE
    call DASH
    call SPACE
    call DOT
    call SPACE
    call DOT
    call SPACE
    call DOT
    rjmp CHECK_PA6

DOT:
    ldi temp, 0b11111110  ; Turn on LED
    out PORTD, temp
    call NEWDELAY
    ldi temp, 0b11111111  ; Turn off LED
    out PORTD, temp
    ret

DASH:
    ldi temp, 0b11111110  ; Turn on LED
    out PORTD, temp
    call NEWDELAY
    call NEWDELAY            ; Longer delay for DASH
    ldi temp, 0b11111111  ; Turn off LED
    out PORTD, temp
    ret

SPACE:
    call NEWDELAY
    ret

NEWDELAY:
    LDI R19, 255
LOOP10:
    LDI R20, 255
LOOP20:
    LDI R21, 50
LOOP30:
    NOP
    DEC R21
    BRNE LOOP30
    DEC R20
    BRNE LOOP20
    DEC R19
    BRNE LOOP10
    ret

BUZZER_START:
    CALL NOTE1 ; this is the note we want to call to play the actual buzzer sound
    RJMP MAIN_LOOP ; Return to the main loop after playing the buzzer
NOTE1:
    SBI PORTE, 4 ; this is turning the speaker on
    CALL DELAY100 ; this is calling the delay loop
    CBI PORTE, 4 ; this is turning the speaker off
DELAY100: LDI R17, 200 ; this is the delay loop where most of my calculations were made
    LOOP100: LDI R18, 59 ; the 59 in this section is the number that I mainly took time calculating
        LOOP200: 
            NOP ; the NOPs where added to have the proper loop timing
            NOP
            DEC r18
            BRNE LOOP200
            DEC  R17
            BRNE LOOP100
            RET

