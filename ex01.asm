        org $2000

        .zpvar increment, counter .byte
        .zpvar taddr_l, taddr_h .byte 


start:
        lda #<tab
        sta taddr+1
        lda #>tab
        sta taddr+2

        lda #$00
        sta $022f   ; 559          	22F          	SDMCTL
                    ; Direct Memory Access (DMA) enable. POKEing with zero allows
                    ; you to turn off ANTIC and speed up processing by 30%. Of
                    ; course, it also means the screen goes blank when ANTIC is
                    ; turned off! This is useful to speed things up when you are doing a
                    ; calculation that would take a long time. It is also handy to turn off
                    ; the screen when loading a drawing, then turning it on when the
                    ; screen is loaded so that it appears instantly, complete on the
                    ; screen. To use it you must first PEEK(559) and save the result in
                    ; order to return your screen to you. Then POKE 559,0 to turn off
                    ; ANTIC. When you are ready to bring the screen back to life,
                    ; POKE 559 with the number saved earlier.
                    ; 
                    ; This location is the shadow register for 54272 ($D400), and the
                    ; number you PEEKed above defines the playfield size, whether or
                    ; not the missiles and players are enabled, and the player size
                    ; resolution. To enable your options by using POKE 559, simply
                    ; add up the values below to obtain the correct number to POKE
                    ; into SDMCTL. Note that you must choose only one of the four
                    ; playfield options appearing at the beginning of the list:
                    ;
                    ; Option                          Decimal   Bit
                    ; No playfield                          0   0
                    ; Narrow playfield                      1   0
                    ; Standard playfield                    2   0,1
                    ; Wide playfield                        3   0,1
                    ; Enable missle DMA                     4   2
                    ; Enable player DMA                     8   3
                    ; Enable player and missile
                    ;   DMA                                12   2,3
                    ; One line player resolution           16   4
                    ; Enable instructions to fetch
                    ;   DMA                                32   5 (see below)
                    ;
                    ; Note that two-line player resolution is the default and that it is not
                    ; necessary to add a value to 559 to obtain it. I have included the
                    ; appropriate bits affected in the table above. The default is 34
                    ; ($22).
                    ;
                    ; The playfield is the area of the TV screen you will use for display,
                    ; text, and graphics. Narrow playfield is 128 color clocks (32
                    ; characters wide in GR.0), standard playfield is 160 color clocks
                    ; (40 characters), and wide playfield is 192 color clocks wide (48
                    ; characters). A color clock is a physical measure of horizontal
                    ; distance on the TV screen. There are a total of 228 color clocks on
                    ; a line, but only some of these (usually 176 maximum) will be
                    ; visible due to screen limitations. A pixel, on the other hand, is a
                    ; logical unit which varies in size with the GRAPHICS mode. Due
                    ; to the limitations of most TV sets, you will not be able to see all of
                    ; the wide playfield unless you scroll into the offscreen portions.
                    ; BIT 5 must be set to enable ANTIC operation; it enables DMA for
                    ; fetching the display list instructions.
    
        ldx #$00
loop:
        lda $d40b   ; 54283          	D40B          	VCOUNT
                    ; (R) Vertical line counter. Used to keep track of which line is
                    ; currently being generated on the screen. Used during Display
                    ; List Interrupts to change color or graphics modes. PEEKing here
                    ; returns the line count divided by two, ranging from zero to 130
                    ; ($82; zero to 155 on the PAL system; see 53268; $D014) for the
                    ; 262 lines per TV frame.

        bne not_zero ; jump if not in 2 first lines on the screen
        inc taddr+1  ; on line zero, 
not_zero:
        pha
        inc counter
        lda counter
        and #%00111111
        bne next
        ; uncomment below line to add vertical scrolling 
        ; inc increment
next:   pla

        clc
        adc increment

        tax
taddr:  adc tab,x

        sta $d40a   ;54282          	D40A          	WSYNC

                    ;(W) Wait for horizontal synchronization. Allows the OS to
                    ;synchronize the vertical TV display by causing the 6502 to halt
                    ;and restart seven machine cycles before the beginning of the
                    ;next TV line. It is used to synchronize the VBI's or DLI's with the
                    ;screen display.
                    ;To see the effect of the WSYNC register, type in the second
                    ;example of a Display List Interrupt at location 512. RUN it and
                    ;observe that it causes a clean separation of the colors at the
                    ;change boundary. Now change line 50 to:
                    ;
                    ;50  DATA 72,169,222,234,234,234,141,24,208,104,64
                    ;
                    ;This eliminates the WSYNC command. RUN it and see the
                    ;difference in the boundary line.
                    ;
                    ;The keyboard handler sets WSYNC repeatedly while generating
                    ;the keyboard click on the console speaker at 53279 ($D01F).
                    ;When interrupts are generated during the WSYNC period, they
                    ;get delayed by one scan line. To bypass this, examine the
                    ;VCOUNT register below and delay the interrupt processing by
                    ;one line when no WSYNC delay has occurred.



        sta $d01a   ; 53274          	D01A          	COLBK
                    ;  Color and luminance of the background (BAK).(712).

        jmp loop

        org $3000
tab:
        .byte 30, 30, 31, 31, 32, 32, 33, 33, 34, 34, 35, 35, 36, 36, 37
        .byte 37, 38, 38, 39, 39, 39, 40, 40, 41, 41, 42, 42, 42, 43, 43
        .byte 44, 44, 44, 45, 45, 45, 46, 46, 46, 46, 47, 47, 47, 47, 48
        .byte 48, 48, 48, 49, 49, 49, 49, 49, 49, 49, 50, 50, 50, 50, 50
        .byte 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 49, 49
        .byte 49, 49, 49, 49, 49, 48, 48, 48, 48, 47, 47, 47, 47, 46, 46
        .byte 46, 46, 45, 45, 45, 44, 44, 44, 43, 43, 42, 42, 42, 41, 41
        .byte 40, 40, 39, 39, 39, 38, 38, 37, 37, 36, 36, 35, 35, 34, 34
        .byte 33, 33, 32, 32, 31, 31, 30, 30, 30, 29, 29, 28, 28, 27, 27
        .byte 26, 26, 25, 25, 24, 24, 23, 23, 22, 22, 21, 21, 21, 20, 20
        .byte 19, 19, 18, 18, 18, 17, 17, 16, 16, 16, 15, 15, 15, 14, 14
        .byte 14, 14, 13, 13, 13, 13, 12, 12, 12, 12, 11, 11, 11, 11, 11
        .byte 11, 11, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
        .byte 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12
        .byte 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 16, 16, 16
        .byte 17, 17, 18, 18, 18, 19, 19, 20, 20, 21, 21, 21, 22, 22, 23
        .byte 23, 24, 24, 25, 25, 26, 26, 27, 27, 28, 28, 29, 29, 30, 30
        .byte 30

        .byte 30, 30, 31, 31, 32, 32, 33, 33, 34, 34, 35, 35, 36, 36, 37
        .byte 37, 38, 38, 39, 39, 39, 40, 40, 41, 41, 42, 42, 42, 43, 43
        .byte 44, 44, 44, 45, 45, 45, 46, 46, 46, 46, 47, 47, 47, 47, 48
        .byte 48, 48, 48, 49, 49, 49, 49, 49, 49, 49, 50, 50, 50, 50, 50
        .byte 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 49, 49
        .byte 49, 49, 49, 49, 49, 48, 48, 48, 48, 47, 47, 47, 47, 46, 46
        .byte 46, 46, 45, 45, 45, 44, 44, 44, 43, 43, 42, 42, 42, 41, 41
        .byte 40, 40, 39, 39, 39, 38, 38, 37, 37, 36, 36, 35, 35, 34, 34
        .byte 33, 33, 32, 32, 31, 31, 30, 30, 30, 29, 29, 28, 28, 27, 27
        .byte 26, 26, 25, 25, 24, 24, 23, 23, 22, 22, 21, 21, 21, 20, 20
        .byte 19, 19, 18, 18, 18, 17, 17, 16, 16, 16, 15, 15, 15, 14, 14
        .byte 14, 14, 13, 13, 13, 13, 12, 12, 12, 12, 11, 11, 11, 11, 11
        .byte 11, 11, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
        .byte 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12
        .byte 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 16, 16, 16
        .byte 17, 17, 18, 18, 18, 19, 19, 20, 20, 21, 21, 21, 22, 22, 23
        .byte 23, 24, 24, 25, 25, 26, 26, 27, 27, 28, 28, 29, 29, 30, 30
        .byte 30

; - - - - - - - - - - - - 
        run start  
; - - - - - - - - - - - - 