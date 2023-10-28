
.def temp = r16
.def counter = r17
.def delay1 = r18
.def delay2 = r19

RESET:
    ldi temp, 0xFF
    out DDRD, temp      ; Configure PD0 to PD7 as output
    out DDRE, temp      ; Configure PE5 as output

    ldi temp, 0xFF      ; Turn off all LEDs initially
    out PORTD, temp
    out PORTE, temp
    
    cbi DDRA, 1       
    sbi PORTA, 1      
PLUS:
    inc counter                        ; Increment the counter
    cpi counter, 7                     ; Compare the counter with 7
    brne SKIP_RESET                    ; If counter is not equal to 7, skip the reset
    ldi counter, 1                     ; If counter is equal to 7, reset it to 1
SKIP_RESET:
    call DISPLAY_DICE_FACE             ; Call the subroutine to display the dice face corresponding to the counter
    call DELAY                         ; Call the delay subroutine to wait for a while
    rjmp CHECK_BUTTON_RELEASE          ; Jump to check if the button has been released

CHECK_BUTTON_RELEASE:
    sbis PINA, 1                       ; Check if the bit 1 of PINA is set (SW2 released)
    rjmp CHECK_BUTTON_RELEASE          ; If SW2 is not released, keep checking
    rjmp MAIN_LOOP                     ; If SW2 is released, go back to the main loop

DELAY:
    ldi delay1, 255                   
    DELAY_LOOP1:
        ldi delay2, 255               
        DELAY_LOOP2:
            nop                       
            nop                       
            nop                      
            dec delay2                ; Decrement delay2
            brne DELAY_LOOP2          ; If delay2 is not zero, repeat the loop
        dec delay1                    ; Decrement delay1
        brne DELAY_LOOP1              ; If delay1 is not zero, repeat the loop
    ret 

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


