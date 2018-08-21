;   Hello Sprite GB
; Josh Beard, 2018
; github.com/jlbeard84
; Adapted from https://gb-archive.github.io/salvage/tutorial_de_ensamblador/

INCLUDE "gbhw.inc"

; sprite constants
_SPR0_Y     EQU     _OAMRAM     ; sprite Y 0 is the beginning of sprite ram
_SPR0_X     EQU     _OAMRAM+1   
_SPR0_NUM   EQU     _OAMRAM+2
_SPR0_ATT   EQU     _OAMRAM+3

; create movement vars
_MOVX       EQU     _RAM        ; start of ram
_MOVY       EQU     _RAM+1      

SECTION "start", HOME[$0100]
    nop
    jp      i

; rom header
    ROM_HEADER  ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE

appstart:
    nop
    di                          ; disable interrupts
    ld      sp, $ffff           ; top of ram

init:
    ld      a, %11100100        ; palette colors from darkest to lighter
    ld      [rBGP], a
    ld      [rOBP0], a

    ld      a, 0                ; put 0 into rSCX, rSCY
    ld      [rSCX], a
    ld      [rSCY], a

    call    lcd_off

    ; load tiles into ram
    ld      hl, Tiles
    ld      de, _VRAM
    ld      b, 32

.loop_load:
    ld      a, [hl]
    ld      [de], a
    dec     b
    jr      z, .end_loop_load
    inc     hl
    inc     de
    jr      .loop_load
.end_loop_load:

    ; clean screen with tile 0
    ld      hl, _SCRN0
    ld      de, 32*32
.loop_clean:
    ld      a, 0             ; load empty tile into a
    ld      [hl], a
    dec     de

    ld      a, d
    or      e
    jp      z, .end_loop_clean
    inc     hl
    jp      .loop_load
.end_loop_clean

    ; all map tiles filled with empty tile
    ; create sprite

    ld      a, 30
    ld      [_SPR0_Y], a
    ld      a, 30
    ld      [_SPR0_X], a
    ld      a, 1
    ld      [_SPR0_NUM], a
    ld      a, 0
    ld      [_SPR0_ATT], a

    ; config display
    ld      a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJON
    ld      [rLCDC], a

    ; prepare animation vars
    ld      a, 1
    ld      [_MOVX], a
    ld      [_MOVY], a

    ; infinite loop
animation:
    ; wait for vblank
.wait
    ld      a, [rLY]
    cp      145
    jr      nz, .wait