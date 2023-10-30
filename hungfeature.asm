.def temp = r16
ldi r17, 0b00000000
.def counter = r17
ldi r18, 0    ; Clock timer, initialize to 0
MOV r20, r17

RESET:
    ; Initialization code
    ldi temp, 0b00011111
    out DDRD, temp       ; Configure PD0 to PD4 as output
    out DDRE, temp       ; Configure PE4 as output
    clr counter          ; Clear counter
    out PORTD, temp      ; Set LEDs off initially
    cbi DDRA, 0
    sbi PORTA, 0
    cbi DDRC, 0    ; Configure PC0 as input for the clear button

MAIN_LOOP:
    sbis PINA3, 0
    rjmp INC_BOARD

    ; Check if the clear button (PINA2) is pressed
    sbic PINA2, 0
    rjmp MAIN_LOOP    ; If it's not pressed, continue checking
    rjmp CLEAR_BOARD

INC_BOARD:
    ; Increment the board based on a timer
    inc r18
    cpi r18, 255    ; Check if r18 reached a certain value (adjust as needed)
    brne NO_SOUND
    inc counter    ; Increment the counter

    ; Control sound frequency based on counter value
    cpi counter, 1
    breq SOUND_LOW
    cpi counter, 2
    breq SOUND_MEDIUM
    cpi counter, 3
    breq SOUND_HIGH

    ; No specific sound for other counter values
    rjmp MAIN_LOOP

SOUND_LOW:
    ldi r16, 50   ; Adjust this value for a low-frequency sound
    rjmp PLAY_SOUND

SOUND_MEDIUM:
    ldi r16, 95   ; Adjust this value for a medium-frequency sound
    rjmp PLAY_SOUND

SOUND_HIGH:
    ldi r16, 140  ; Adjust this value for a high-frequency sound
    rjmp PLAY_SOUND

PLAY_SOUND:
    LDI R17, 20

SOUND_LOOP:
    LDI R19, 20
SOUND_DELAY_LOOP:
    NOP
    DEC R19
    BRNE SOUND_DELAY_LOOP
    DEC R16
    BRNE SOUND_LOOP

    rjmp MAIN_LOOP

NO_SOUND:
    rjmp MAIN_LOOP

CLEAR_BOARD:
    clr counter    ; Clear the counter
    out PORTD, r17
    rjmp MAIN_LOOP
