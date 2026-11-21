; =====================================================================
;  MARIO_COMPLETE.ASM  --  the whole project in ONE file
;  EL-2003 COAL Semester Project : Super Mario style platformer (16-bit x86)
;
;  Build : nasm -f bin MARIO_COMPLETE.ASM -o MARIO.COM
;  Run   : MARIO.COM   (DOSBox)
;  Needs LEVEL1.TXT, LEVEL2.TXT (and HISCORE.TXT for the high score) in
;  the same folder when you ASSEMBLE; HISCORE.TXT also when you RUN.
;
;  This file is generated from the module files in  src\  (same code).
;  Every "FILE:" banner marks where one module file begins, so each
;  student can see which part is theirs.  BONUS code is marked with
;  "===== BONUS" comments and can be switched off at the top.
; =====================================================================
; =====================================================================
;  MAIN.ASM  --  Module 1 : program skeleton (build target)
;  Owner : Student 1
;  Build :  nasm -f bin src\main.asm -o MARIO.COM -i src\
;  This file only contains the entry point and the main loop; it pulls
;  in every module with %include.
; =====================================================================
;  MAIN.ASM  --  Module 1 : program skeleton (build target)
;  Owner : Student 1
;  Build :  nasm -f bin src\main.asm -o MARIO.COM -i src\
;  This file only contains the entry point and the main loop; it pulls
;  in every module with %include.
; =====================================================================
        cpu     8086                    ; reject anything newer than the 8086
        bits    16
        org     100h                    ; .COM program

;#####################################################################
;#  FILE: config.asm
;#####################################################################
; =====================================================================
;  CONFIG.ASM  --  Module 1 : constants, bonus switches, helper macros
;  Owner : Student 1
; =====================================================================
;  Only the instructions taught in class are used (mov, add/sub, or/and/
;  xor, cmp + jumps, mul/div, test) plus the basics every program needs
;  (push/pop, call/ret, int, inc/dec/neg, in/out, iret).
;  There are NO shifts, NO loop/rep instructions and NO cbw.
;  Repetition is done with  cmp + conditional jump.
; =====================================================================

; ---------------------------------------------------------------------
;  BONUS SWITCHES
;  Put a ';' in front of a line to REMOVE that bonus feature completely.
;  The game still assembles and works without any of them.
; ---------------------------------------------------------------------
%define BONUS_SOUND             ; BONUS 1: PC-speaker sound effects
%define BONUS_WALK_ANIM         ; BONUS 2: walking animation
%define BONUS_LEVEL2            ; BONUS 3: second level (LEVEL2.TXT)
%define BONUS_HISCORE           ; BONUS 4: saved high score (HISCORE.TXT)
%define BONUS_FIRE              ; BONUS 5: fire flower + fireballs (key X)
%define BONUS_POPUPS            ; BONUS 6: score pop-ups above the action
%define BONUS_HURRY             ; BONUS 7: "hurry" blink when time < 100
%define BONUS_CLOUDS            ; BONUS 8: clouds scrolling at half speed

; ---------------------------------------------------------------------
;  Screen (80 x 25 colour text mode, one map tile = one character cell)
; ---------------------------------------------------------------------
SCREEN_COLS     equ 80
SCREEN_ROWS     equ 25
SCREEN_CELLS    equ 2000
VIDEO_SEG       equ 0B800h

; ---------------------------------------------------------------------
;  Level map : one byte per tile, 240 columns x 25 rows.
;  The level text files have CR+LF at the end of every row, so one map
;  row is 242 bytes long (MAP_STRIDE).
; ---------------------------------------------------------------------
MAP_COLS        equ 240
MAP_ROWS        equ 25
MAP_STRIDE      equ 242
MAP_SIZE        equ 6050                ; 25 * 242
CAMERA_FOLLOW   equ 40                  ; Mario stays at screen column 40
CAMERA_MAX      equ 160                 ; 240 - 80
START_COL       equ 10
START_ROW       equ 22
PIT_ROW         equ 25                  ; feet at row 25 = fell into a pit

; ---------------------------------------------------------------------
;  Tile codes (the characters used inside LEVEL1.TXT / LEVEL2.TXT)
; ---------------------------------------------------------------------
T_SKY           equ ' '
T_GROUND        equ '#'
T_BRICK         equ 'B'
T_QCOIN         equ '?'                 ; question block holding a coin
T_QMUSH         equ 'M'                 ; question block holding a mushroom
T_EMPTY         equ 'E'                 ; used-up block
T_PIPE_TL       equ '<'
T_PIPE_TR       equ '>'
T_PIPE_BL       equ '('
T_PIPE_BR       equ ')'
T_STAIR         equ 'S'
T_COIN          equ 'o'
T_POLE          equ '|'

; ---------------------------------------------------------------------
;  Colours (text attribute = background*16 + foreground)
;  Backgrounds are kept 0..7 so nothing blinks.
; ---------------------------------------------------------------------
ATTR_SKY        equ 33h
ATTR_GROUND     equ 26h
ATTR_BRICK      equ 47h
ATTR_QBLOCK     equ 6Eh
ATTR_EMPTY      equ 68h
ATTR_PIPE_TOP   equ 3Ah
ATTR_PIPE_BODY  equ 32h
ATTR_STAIR      equ 37h
ATTR_COIN       equ 3Eh
ATTR_POLE       equ 3Fh
ATTR_HUD        equ 1Fh
ATTR_HUD_RED    equ 1Ch
ATTR_HUD_GREY   equ 18h
ATTR_TEXT       equ 0Fh
ATTR_TITLE      equ 1Eh
ATTR_MENU_ON    equ 70h
ATTR_MENU_OFF   equ 1Fh
ATTR_SCREEN     equ 10h
ATTR_BORDER     equ 1Bh
ATTR_POPUP      equ 3Eh

; Sprite foreground colours (the background of the cell is kept)
FG_SMALL        equ 0Ch
FG_SUPER_HEAD   equ 0Ch
FG_SUPER_BODY   equ 09h
FG_FIRE_HEAD    equ 0Fh
FG_FIRE_BODY    equ 0Ch
FG_GOOMBA       equ 06h
FG_KOOPA        equ 0Ah
FG_SHELL        equ 02h
FG_MUSHROOM     equ 0Ch
FG_FLOWER       equ 0Eh
FG_FIREBALL     equ 0Ch

; Sprite characters (code page 437 glyphs)
GLYPH_STAND     equ 02h                 ; smiley face
GLYPH_JUMP      equ 18h                 ; up arrow
GLYPH_RUN_R     equ 10h
GLYPH_RUN_L     equ 11h
GLYPH_RUN_R2    equ 1Ah                 ; BONUS walk animation frame 2
GLYPH_RUN_L2    equ 1Bh                 ; BONUS walk animation frame 2
GLYPH_BODY      equ 0DBh                ; Super Mario body
GLYPH_GOOMBA    equ 0EAh
GLYPH_GOOMBA2   equ 0E9h                ; BONUS walk animation frame 2
GLYPH_FLAT      equ 0C4h
GLYPH_KOOPA     equ 05h
GLYPH_SHELL     equ 0FEh
GLYPH_MUSHROOM  equ 06h
GLYPH_FLOWER    equ 0Fh
GLYPH_FIREBALL  equ 07h
GLYPH_HEART     equ 03h

; ---------------------------------------------------------------------
;  Keyboard scan codes
; ---------------------------------------------------------------------
KEY_ESC         equ 01h
KEY_P           equ 19h
KEY_ENTER       equ 1Ch
KEY_LSHIFT      equ 2Ah
KEY_X           equ 2Dh
KEY_SPACE       equ 39h
KEY_F1          equ 3Bh                 ; debug: time = 5 seconds
KEY_F2          equ 3Ch                 ; debug: coins = 99
KEY_F3          equ 3Dh                 ; debug: jump to the end of the level
KEY_UP          equ 48h
KEY_LEFT        equ 4Bh
KEY_RIGHT       equ 4Dh
KEY_DOWN        equ 50h

; ---------------------------------------------------------------------
;  Physics (8.8 fixed point: high byte = whole cells, low byte = fraction)
;  Values are in cells per frame, scaled for the 80-column text screen.
; ---------------------------------------------------------------------
WALK_ACCEL      equ 0010h               ; 0.0625
BRAKE_ACCEL     equ 0020h               ; 0.125  (turning around)
FRICTION        equ 0008h               ; 0.03125
MAX_WALK        equ 0080h               ; 0.5
MAX_RUN         equ 00C0h               ; 0.75
GRAVITY         equ 0020h               ; 0.125
JUMP_START      equ 0FF00h              ; -1.0
JUMP_CUTOFF     equ 0FF80h              ; -0.5
MAX_FALL        equ 0100h               ; 1.0 (never more than 1 cell/frame)
STOMP_BOUNCE    equ 0FF60h              ; -0.625
STOMP_BOUNCE_UP equ 0FF20h              ; -0.875 (jump key held)
GOOMBA_SPEED    equ 0030h
KOOPA_SPEED     equ 0048h
SHELL_SPEED     equ 00E0h
MUSH_SPEED      equ 0040h
FIRE_SPEED      equ 00C0h
HIT_WIDTH       equ 0120h               ; horizontal overlap limit (1.125 cells)

; ---------------------------------------------------------------------
;  Game limits / timings (a frame = one timer tick, about 18.2 per second)
; ---------------------------------------------------------------------
START_LIVES     equ 3
MAX_LIVES       equ 99
LEVEL_TIME      equ 300
TICKS_PER_SEC   equ 18
INVULN_FRAMES   equ 36                  ; about 2 seconds
FLAT_FRAMES     equ 18                  ; flat Goomba, about 1 second
KICK_GRACE      equ 8                   ; shell ignores Mario after a kick
DEATH_FRAMES    equ 27                  ; about 1.5 seconds
PIT_DEATH_FRAMES equ 12
LIFELOST_FRAMES equ 36                  ; about 2 seconds
WIN_WAIT_FRAMES equ 18
POPUP_FRAMES    equ 14
MAX_ACTIVE_ENEMIES equ 8
MAX_SCORE_LO    equ 423Fh               ; 999,999 = 000F:423F
MAX_SCORE_HI    equ 000Fh

; ---------------------------------------------------------------------
;  Enemy table : fixed-size records
; ---------------------------------------------------------------------
ENEMY_COUNT     equ 12
ENEMY_SIZE      equ 10
EN_TYPE         equ 0                   ; 0 = unused, 1 = Goomba, 2 = Koopa
EN_STATE        equ 1
EN_X            equ 2                   ; word, 8.8 world x
EN_Y            equ 4                   ; byte, row
EN_DIR          equ 5                   ; 0 = left, 1 = right
EN_TIMER        equ 6
EN_SPEED        equ 7                   ; word, 8.8
TYPE_GOOMBA     equ 1
TYPE_KOOPA      equ 2
ES_WAIT         equ 0                   ; not on screen yet
ES_WALK         equ 1
ES_FLAT         equ 2                   ; squashed Goomba
ES_SHELL_STILL  equ 3
ES_SHELL_SLIDE  equ 4

; Item table (mushroom / flower)
ITEM_COUNT      equ 2
ITEM_SIZE       equ 8
IT_ACTIVE       equ 0
IT_KIND         equ 1                   ; 0 = mushroom, 1 = flower (BONUS)
IT_X            equ 2
IT_Y            equ 4
IT_DIR          equ 5

; ---------------------------------------------------------------------
;  Game states
; ---------------------------------------------------------------------
STATE_TITLE     equ 0
STATE_PLAYING   equ 1
STATE_PAUSED    equ 2
STATE_DYING     equ 3
STATE_LIFELOST  equ 4
STATE_WIN       equ 5
STATE_LEVELDONE equ 6
STATE_GAMEOVER  equ 7
STATE_EXIT      equ 8

; ---------------------------------------------------------------------
;  MACROS
; ---------------------------------------------------------------------
%macro SAVE_ALL 0
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
%endmacro

%macro RESTORE_ALL 0
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
%endmacro

; Push a constant (8086 has no "push immediate").  Clobbers AX.
%macro PUSHI 1
        mov     ax, %1
        push    ax
%endmacro

; PCELL x, y, char, attr : PutCell with arguments.  Clobbers AX.
; x and y must be 16-bit registers; char and attr may be constants or [mem].
%macro PCELL 4
        push    %1
        push    %2
        mov     ax, %3
        push    ax
        mov     ax, %4
        push    ax
        call    PutCell
%endmacro

; TEXT x, y, attr, string_label : draw a zero-terminated string.
%macro TEXT 4
        PUSHI   %1
        PUSHI   %2
        PUSHI   %3
        PUSHI   %4
        call    DrawString
%endmacro

; NUMBER lo, hi, digits, x, y, attr : print a 32-bit number, zero padded.
%macro NUMBER 6
        mov     ax, %1
        push    ax
        mov     ax, %2
        push    ax
        PUSHI   %3
        PUSHI   %4
        PUSHI   %5
        PUSHI   %6
        call    PrintNum32
%endmacro

; BOX x, y, w, h, attr : double-line border.
%macro BOX 5
        PUSHI   %1
        PUSHI   %2
        PUSHI   %3
        PUSHI   %4
        PUSHI   %5
        call    DrawBox
%endmacro

; FILL x, y, w, h, char, attr : solid rectangle.
%macro FILL 6
        PUSHI   %1
        PUSHI   %2
        PUSHI   %3
        PUSHI   %4
        PUSHI   %5
        PUSHI   %6
        call    FillRect
%endmacro

; CLEAR char, attr : fill the whole frame buffer.
%macro CLEAR 2
        PUSHI   %1
        PUSHI   %2
        call    ClearBuffer
%endmacro

; DRAWSPR x, y, glyph, fg : transparent sprite.  x,y = registers / word [mem]
%macro DRAWSPR 4
        push    %1
        push    %2
        mov     ax, %3
        push    ax
        mov     ax, %4
        push    ax
        call    DrawSprite
%endmacro

; GETTILE col, row : push two words and call GetTile (tile returned in AL).
%macro GETTILE 2
        push    %1
        push    %2
        call    GetTile
%endmacro

; SCORE points : add a constant to the score (calls AddScore).  Clobbers AX.
%macro SCORE 1
        PUSHI   %1
        PUSHI   0
        call    AddScore
%endmacro

; SETTILE col, row, tile : change a tile of the working map.  Clobbers AX.
%macro SETTILE 3
        push    %1
        push    %2
        PUSHI   %3
        call    SetTile
%endmacro

; IF_HIT key, not_hit_label : if the key was pressed since the last check,
; consume it, otherwise jump to not_hit_label.
%macro IF_HIT 2
        cmp     byte [key_hit + %1], 0
        je      %2
        mov     byte [key_hit + %1], 0
%endmacro

; ---------------------------------------------------------------------
;  BONUS HOOKS : each one disappears when its bonus switch is removed.
; ---------------------------------------------------------------------
%macro SOUND 1                          ; BONUS 1
 %ifdef BONUS_SOUND
        call    snd_ %+ %1
 %endif
%endmacro

%macro HOOK_SOUND_UPDATE 0
 %ifdef BONUS_SOUND
        call    SoundUpdate
 %endif
%endmacro

%macro HOOK_SOUND_OFF 0
 %ifdef BONUS_SOUND
        call    SoundOff
 %endif
%endmacro

%macro HOOK_CLOUDS 0                    ; BONUS 8
 %ifdef BONUS_CLOUDS
        call    DrawClouds
 %endif
%endmacro

%macro HOOK_HURRY_DRAW 0                ; BONUS 7
 %ifdef BONUS_HURRY
        call    DrawHurry
 %endif
%endmacro

%macro TIME_ATTR 0                      ; AL = attribute of the HUD time
 %ifdef BONUS_HURRY
        call    GetTimeAttr
 %else
        mov     al, ATTR_HUD
 %endif
%endmacro

%macro HOOK_HISCORE_LOAD 0              ; BONUS 4
 %ifdef BONUS_HISCORE
        call    LoadHighScore
 %endif
%endmacro

%macro HOOK_HISCORE_SAVE 0
 %ifdef BONUS_HISCORE
        call    SaveHighScore
 %endif
%endmacro

%macro HOOK_HISCORE_DRAW 2              ; x, y
 %ifdef BONUS_HISCORE
        PUSHI   %1
        PUSHI   %2
        call    DrawHighScore
 %endif
%endmacro

%macro HOOK_POPUP_SPAWN 0               ; BONUS 6 (points in AX)
 %ifdef BONUS_POPUPS
        call    SpawnPopup
 %endif
%endmacro

%macro HOOK_POPUP_UPDATE 0
 %ifdef BONUS_POPUPS
        call    UpdatePopups
 %endif
%endmacro

%macro HOOK_POPUP_DRAW 0
 %ifdef BONUS_POPUPS
        call    DrawPopups
 %endif
%endmacro

%macro HOOK_POPUP_RESET 0
 %ifdef BONUS_POPUPS
        call    ResetPopups
 %endif
%endmacro

%macro HOOK_FIRE_INPUT 0                ; BONUS 5
 %ifdef BONUS_FIRE
        call    FireInput
 %endif
%endmacro

%macro HOOK_FIRE_UPDATE 0
 %ifdef BONUS_FIRE
        call    UpdateFireballs
 %endif
%endmacro

%macro HOOK_FIRE_DRAW 0
 %ifdef BONUS_FIRE
        call    DrawFireballs
 %endif
%endmacro

%macro HOOK_FIRE_RESET 0
 %ifdef BONUS_FIRE
        call    ResetFireballs
 %endif
%endmacro


        jmp     start                   ; skip over the data

;#####################################################################
;#  FILE: data.asm
;#####################################################################
; =====================================================================
;  DATA.ASM  --  Module 1 : all game variables, grouped by purpose
;  Owner : Student 1
; =====================================================================

; ---------------- hero ----------------
hero_x          dw 0            ; world x, 8.8 (high byte = column)
hero_y          dw 0            ; FEET row, 8.8 (high byte = row)
hero_vx         dw 0            ; signed 8.8
hero_vy         dw 0            ; signed 8.8
hero_dir        db 1            ; 1 = facing right, 0 = left
hero_on_ground  db 0
hero_form       db 0            ; 0 = Small, 1 = Super, 2 = Fire (BONUS)
hero_hp         db 1            ; 1 or 2
hero_invuln     db 0            ; frames of invulnerability left
hero_chain      db 0            ; stomp chain counter
hero_falling    db 0            ; 1 = Mario was moving down this frame
hero_prev_row   db 0            ; feet row in the previous frame
jump_ready      db 1            ; 0 until Space has been released

; ---------------- score / lives / clock ----------------
score_lo        dw 0            ; 32-bit score (two words)
score_hi        dw 0
hiscore_lo      dw 0            ; BONUS high score
hiscore_hi      dw 0
coins           dw 0
lives           dw START_LIVES
time_left       dw LEVEL_TIME
sec_ticks       db 0            ; frames counted towards one second
bonus_lo        dw 0            ; time bonus shown on the Level Complete screen
bonus_hi        dw 0

; ---------------- game state ----------------
game_state      db STATE_TITLE
state_timer     dw 0
menu_sel        db 0            ; 0 = START GAME, 1 = EXIT
cur_level       db 0            ; 0 = level 1, 1 = level 2 (BONUS)
win_phase       db 0
camera_x        dw 0            ; world column at the left of the screen
frame_count     db 0            ; counts frames (used for blinking)

; ---------------- interrupts ----------------
tick_count      dw 0            ; incremented by the timer handler
last_tick       dw 0
old_int09       dd 0            ; saved keyboard vector (offset, segment)
old_int1c       dd 0            ; saved timer vector

; ---------------- keyboard tables (128 bytes each) ----------------
key_state       times 128 db 0  ; 1 = key is held down
key_hit         times 128 db 0  ; 1 = key was pressed (until consumed)

; ---------------- enemies and items ----------------
enemy_active    db 0
enemy_self      dw 0            ; record being updated (for "other enemy" test)
enemy_table     times ENEMY_COUNT*ENEMY_SIZE db 0
item_table      times ITEM_COUNT*ITEM_SIZE db 0
tmp_col         dw 0
tmp_row         dw 0

; ---------------- tables ----------------
tile_gfx        times 256 dw 0  ; tile character -> (attribute*256 + glyph)
stomp_points    dw 100, 200, 400, 500, 800, 1000, 2000, 4000, 5000, 8000

; ---------------- debug / BONUS data lives in the bonus files ----------

;#####################################################################
;#  FILE: leveldata.asm
;#####################################################################
; =====================================================================
;  LEVELDATA.ASM  --  Module 3 : the level maps and enemy start tables
;  Owner : Student 1
;  The maps are plain text files (LEVEL1.TXT, LEVEL2.TXT) that are
;  copied into the program at assembly time with INCBIN.  They are the
;  ORIGINAL maps and are never changed while playing; the game works on
;  a copy (map_work) that ResetMap refreshes.
; =====================================================================
level1_data:
        incbin "LEVEL1.TXT"
%if ($ - level1_data) != MAP_SIZE
 %error "LEVEL1.TXT must be 25 rows of 240 characters + CR LF (6050 bytes)"
%endif

%ifdef BONUS_LEVEL2
; ----- BONUS 3 : second level -----
level2_data:
        incbin "LEVEL2.TXT"
%if ($ - level2_data) != MAP_SIZE
 %error "LEVEL2.TXT must be 25 rows of 240 characters + CR LF (6050 bytes)"
%endif
%endif

; Pointers indexed by cur_level (word table)
level_ptrs:
        dw level1_data
%ifdef BONUS_LEVEL2
        dw level2_data
%endif

enemy_ptrs:
        dw enemy_init1
%ifdef BONUS_LEVEL2
        dw enemy_init2
%endif

; Enemy start tables:  type, column, row   (type 0 ends the list)
; type 1 = Goomba, type 2 = Koopa Troopa.  Max 12 enemies per level.
enemy_init1:
        db 1, 34, 22
        db 1, 40, 22
        db 2, 46, 22
        db 1, 53, 22
        db 2, 62, 22
        db 1, 74, 22
        db 1, 86, 22
        db 2, 100, 22
        db 1, 112, 22
        db 2, 126, 22
        db 1, 142, 22
        db 1, 160, 22
        db 0

%ifdef BONUS_LEVEL2
enemy_init2:
        db 1, 26, 22
        db 2, 38, 22
        db 1, 48, 22
        db 1, 54, 22
        db 2, 64, 22
        db 1, 78, 22
        db 2, 90, 22
        db 1, 104, 22
        db 1, 116, 22
        db 2, 126, 22
        db 1, 138, 22
        db 1, 150, 22
        db 0
%endif


; ---- Student 1 : display ----
;#####################################################################
;#  FILE: video.asm
;#####################################################################
; =====================================================================
;  VIDEO.ASM  --  Modules 2 and 5 : text mode, frame buffer, drawing
;  Owner : Student 1
;  Everything is drawn into screen_buf (an off-screen copy of the text
;  screen).  FlipBuffer copies it to video memory once per frame, so
;  nothing flickers.  Parameters are passed on the STACK (pushed left to
;  right, removed by the procedure with RET n).
; =====================================================================

; ---------------------------------------------------------------------
; SetTextMode
;   Purpose : 80x25 colour text mode, cursor hidden.
;   Input   : none         Output : none      Changes : nothing
; ---------------------------------------------------------------------
SetTextMode:
        push    ax
        push    cx
        mov     ax, 0003h
        int     10h
        mov     ah, 01h
        mov     cx, 2000h               ; cursor start bit 5 set = hidden
        int     10h
        pop     cx
        pop     ax
        ret

; ---------------------------------------------------------------------
; FlipBuffer
;   Purpose : copy the whole frame buffer to video memory (B800:0000).
;   Input   : none         Output : none      Changes : nothing
; ---------------------------------------------------------------------
FlipBuffer:
        push    ax
        push    cx
        push    si
        push    di
        push    es
        mov     ax, VIDEO_SEG
        mov     es, ax
        mov     si, screen_buf
        xor     di, di
        mov     cx, SCREEN_CELLS
.copy:
        mov     ax, [si]
        mov     [es:di], ax
        add     si, 2
        add     di, 2
        dec     cx
        jnz     .copy
        pop     es
        pop     di
        pop     si
        pop     cx
        pop     ax
        ret

; ---------------------------------------------------------------------
; ClearBuffer(char, attr)
;   Purpose : fill the whole frame buffer with one character cell.
;   Input   : [bp+6] = char, [bp+4] = attribute (pushed char first)
;   Output  : none         Changes : nothing        Removes 4 bytes
; ---------------------------------------------------------------------
ClearBuffer:
        push    bp
        mov     bp, sp
        push    ax
        push    cx
        push    di
        mov     ax, [bp+6]
        mov     ah, [bp+4]
        mov     di, screen_buf
        mov     cx, SCREEN_CELLS
.fill:
        mov     [di], ax
        add     di, 2
        dec     cx
        jnz     .fill
        pop     di
        pop     cx
        pop     ax
        pop     bp
        ret     4

; ---------------------------------------------------------------------
; PutCell(x, y, char, attr)
;   Purpose : write one character cell into the frame buffer.  Cells
;             outside the screen are ignored (clipping).
;   Input   : [bp+10]=x  [bp+8]=y  [bp+6]=char  [bp+4]=attr
;   Output  : none         Changes : nothing        Removes 8 bytes
;   offset = (y*80 + x) * 2
; ---------------------------------------------------------------------
PutCell:
        push    bp
        mov     bp, sp
        push    ax
        push    bx
        push    cx
        push    dx
        mov     ax, [bp+10]
        cmp     ax, SCREEN_COLS         ; negative x looks huge: skipped too
        jae     .done
        mov     ax, [bp+8]
        cmp     ax, SCREEN_ROWS
        jae     .done
        mov     cx, SCREEN_COLS
        mul     cx                      ; DX:AX = y * 80
        add     ax, [bp+10]             ; + x
        add     ax, ax                  ; 2 bytes per cell
        mov     bx, ax
        mov     ax, [bp+6]
        mov     ah, [bp+4]
        mov     [screen_buf + bx], ax
.done:
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     bp
        ret     8

; ---------------------------------------------------------------------
; DrawString(x, y, attr, address)
;   Purpose : draw a zero-terminated string.
;   Input   : [bp+10]=x [bp+8]=y [bp+6]=attr [bp+4]=address of string
;   Output  : none         Changes : nothing        Removes 8 bytes
; ---------------------------------------------------------------------
DrawString:
        push    bp
        mov     bp, sp
        push    ax
        push    bx
        push    si
        mov     si, [bp+4]
        mov     bx, [bp+10]             ; current column
.next:
        mov     al, [si]
        cmp     al, 0
        je      .done
        xor     ah, ah
        PCELL   bx, word [bp+8], ax, [bp+6]
        inc     bx
        inc     si
        jmp     .next
.done:
        pop     si
        pop     bx
        pop     ax
        pop     bp
        ret     8

; ---------------------------------------------------------------------
; FillRect(x, y, w, h, char, attr)
;   Purpose : fill a rectangle of cells.
;   Input   : [bp+14]=x [bp+12]=y [bp+10]=w [bp+8]=h [bp+6]=char [bp+4]=attr
;   Output  : none         Changes : nothing        Removes 12 bytes
; ---------------------------------------------------------------------
FillRect:
        push    bp
        mov     bp, sp
        SAVE_ALL
        mov     bx, [bp+12]             ; current row
        mov     dx, [bp+8]              ; rows left
.row:
        test    dx, dx
        jz      .done
        mov     di, [bp+14]             ; current column
        mov     cx, [bp+10]             ; columns left
.col:
        test    cx, cx
        jz      .nextrow
        PCELL   di, bx, [bp+6], [bp+4]
        inc     di
        dec     cx
        jmp     .col
.nextrow:
        inc     bx
        dec     dx
        jmp     .row
.done:
        RESTORE_ALL
        pop     bp
        ret     12

; ---------------------------------------------------------------------
; DrawBox(x, y, w, h, attr)
;   Purpose : draw a double-line border (outline only).
;   Input   : [bp+12]=x [bp+10]=y [bp+8]=w [bp+6]=h [bp+4]=attr
;   Output  : none         Changes : nothing        Removes 10 bytes
; ---------------------------------------------------------------------
DrawBox:
        push    bp
        mov     bp, sp
        SAVE_ALL
        mov     si, [bp+12]             ; left column
        mov     di, [bp+10]             ; top row
        mov     bx, si
        add     bx, [bp+8]
        dec     bx                      ; BX = right column
        mov     dx, di
        add     dx, [bp+6]
        dec     dx                      ; DX = bottom row
        PCELL   si, di, 0C9h, [bp+4]    ; four corners
        PCELL   bx, di, 0BBh, [bp+4]
        PCELL   si, dx, 0C8h, [bp+4]
        PCELL   bx, dx, 0BCh, [bp+4]
        mov     cx, si
        inc     cx
.horiz:
        cmp     cx, bx
        jae     .vert_start
        PCELL   cx, di, 0CDh, [bp+4]
        PCELL   cx, dx, 0CDh, [bp+4]
        inc     cx
        jmp     .horiz
.vert_start:
        mov     cx, di
        inc     cx
.vert:
        cmp     cx, dx
        jae     .done
        PCELL   si, cx, 0BAh, [bp+4]
        PCELL   bx, cx, 0BAh, [bp+4]
        inc     cx
        jmp     .vert
.done:
        RESTORE_ALL
        pop     bp
        ret     10

; ---------------------------------------------------------------------
; PrintNum32(lo, hi, digits, x, y, attr)
;   Purpose : print a 32-bit number as a fixed number of decimal digits
;             (zero padded).  The number is divided by 10 again and
;             again; every remainder is pushed on the stack and popped
;             back in reverse order so the digits come out left to right.
;   Input   : [bp+14]=lo [bp+12]=hi [bp+10]=digits [bp+8]=x [bp+6]=y
;             [bp+4]=attr
;   Output  : none         Changes : nothing        Removes 12 bytes
; ---------------------------------------------------------------------
PrintNum32:
        push    bp
        mov     bp, sp
        SAVE_ALL
        mov     si, [bp+14]             ; SI = low word
        mov     di, [bp+12]             ; DI = high word
        mov     cx, [bp+10]             ; digits still to convert
        mov     bx, 10
.divide:
        mov     ax, di                  ; high word / 10
        xor     dx, dx
        div     bx
        mov     di, ax                  ; new high word, remainder in DX
        mov     ax, si                  ; (remainder:low word) / 10
        div     bx
        mov     si, ax                  ; new low word, remainder in DX
        push    dx                      ; remember this digit
        dec     cx
        jnz     .divide
        mov     cx, [bp+10]
        mov     bx, [bp+8]              ; current column
.print:
        pop     ax                      ; most significant digit first
        add     al, '0'
        xor     ah, ah
        PCELL   bx, word [bp+6], ax, [bp+4]
        inc     bx
        dec     cx
        jnz     .print
        RESTORE_ALL
        pop     bp
        ret     12

;#####################################################################
;#  FILE: map.asm
;#####################################################################
; =====================================================================
;  MAP.ASM  --  Module 3 : level map, tile drawing, tile lookup
;  Owner : Student 1
; =====================================================================

; ---------------------------------------------------------------------
; InitTileTable
;   Purpose : build tile_gfx: for every tile character the screen
;             character and colour.  Unknown characters look like sky.
;   Input / Output : none        Changes : nothing
; ---------------------------------------------------------------------
InitTileTable:
        push    ax
        push    bx
        push    cx
        mov     bx, tile_gfx
        mov     cx, 256
        mov     ax, ATTR_SKY*256 + ' '
.fill:
        mov     [bx], ax
        add     bx, 2
        dec     cx
        jnz     .fill
        mov     word [tile_gfx + T_GROUND*2],  ATTR_GROUND*256   + 0B1h
        mov     word [tile_gfx + T_BRICK*2],   ATTR_BRICK*256    + 0B2h
        mov     word [tile_gfx + T_QCOIN*2],   ATTR_QBLOCK*256   + '?'
        mov     word [tile_gfx + T_QMUSH*2],   ATTR_QBLOCK*256   + '?'
        mov     word [tile_gfx + T_EMPTY*2],   ATTR_EMPTY*256    + 0FEh
        mov     word [tile_gfx + T_PIPE_TL*2], ATTR_PIPE_TOP*256 + 0DBh
        mov     word [tile_gfx + T_PIPE_TR*2], ATTR_PIPE_TOP*256 + 0DBh
        mov     word [tile_gfx + T_PIPE_BL*2], ATTR_PIPE_BODY*256 + 0DBh
        mov     word [tile_gfx + T_PIPE_BR*2], ATTR_PIPE_BODY*256 + 0DBh
        mov     word [tile_gfx + T_STAIR*2],   ATTR_STAIR*256    + 0DBh
        mov     word [tile_gfx + T_COIN*2],    ATTR_COIN*256     + 09h
        mov     word [tile_gfx + T_POLE*2],    ATTR_POLE*256     + 0B3h
        pop     cx
        pop     bx
        pop     ax
        ret

; ---------------------------------------------------------------------
; ResetMap
;   Purpose : copy the ORIGINAL map of the current level over the
;             working map (so broken bricks / taken coins come back).
;   Input   : cur_level    Output : none      Changes : nothing
; ---------------------------------------------------------------------
ResetMap:
        push    ax
        push    bx
        push    cx
        push    si
        push    di
        mov     bl, [cur_level]
        xor     bh, bh
        add     bx, bx                  ; word table
        mov     si, [level_ptrs + bx]
        mov     di, map_work
        mov     cx, MAP_SIZE
.copy:
        mov     al, [si]
        mov     [di], al
        inc     si
        inc     di
        dec     cx
        jnz     .copy
        pop     di
        pop     si
        pop     cx
        pop     bx
        pop     ax
        ret

; ---------------------------------------------------------------------
; GetTile(col, row)
;   Purpose : tile code at a map position (working map).  Outside the
;             map the answer is sky.
;   Input   : [bp+6] = column, [bp+4] = row
;   Output  : AL = tile code     Changes : AL only     Removes 4 bytes
; ---------------------------------------------------------------------
GetTile:
        push    bp
        mov     bp, sp
        push    bx
        push    cx
        push    dx
        mov     al, T_SKY
        mov     bx, [bp+6]
        cmp     bx, MAP_COLS
        jae     .done
        mov     ax, [bp+4]
        cmp     ax, MAP_ROWS
        jae     .outside
        mov     cx, MAP_STRIDE
        mul     cx                      ; row * 242
        add     ax, bx                  ; + column
        mov     bx, ax
        mov     al, [map_work + bx]
        jmp     .done
.outside:
        mov     al, T_SKY
.done:
        pop     dx
        pop     cx
        pop     bx
        pop     bp
        ret     4

; ---------------------------------------------------------------------
; SetTile(col, row, tile)
;   Purpose : change one tile of the WORKING map.
;   Input   : [bp+8] = column, [bp+6] = row, [bp+4] = tile code
;   Output  : none         Changes : nothing        Removes 6 bytes
; ---------------------------------------------------------------------
SetTile:
        push    bp
        mov     bp, sp
        push    ax
        push    bx
        push    cx
        push    dx
        mov     bx, [bp+8]
        cmp     bx, MAP_COLS
        jae     .done
        mov     ax, [bp+6]
        cmp     ax, MAP_ROWS
        jae     .done
        mov     cx, MAP_STRIDE
        mul     cx
        add     ax, bx
        mov     bx, ax
        mov     al, [bp+4]
        mov     [map_work + bx], al
.done:
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     bp
        ret     6

; ---------------------------------------------------------------------
; IsSolid
;   Purpose : decide if a tile blocks Mario.
;   Input   : AL = tile code
;   Output  : carry flag = 1 solid, 0 not solid     Changes : flags
; ---------------------------------------------------------------------
IsSolid:
        cmp     al, T_SKY
        je      .no
        cmp     al, T_COIN
        je      .no
        cmp     al, T_POLE
        je      .no
        stc
        ret
.no:
        clc
        ret

; ---------------------------------------------------------------------
; DrawMap
;   Purpose : draw the 80 visible columns of all 25 rows from the
;             working map into the frame buffer, starting at camera_x.
;   Input   : camera_x     Output : none      Changes : nothing
; ---------------------------------------------------------------------
DrawMap:
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        mov     si, map_work
        add     si, [camera_x]          ; first visible column of row 0
        mov     di, screen_buf
        mov     dx, SCREEN_ROWS
.row:
        mov     cx, SCREEN_COLS
.col:
        mov     bl, [si]
        xor     bh, bh
        add     bx, bx
        mov     ax, [tile_gfx + bx]
        mov     [di], ax
        add     di, 2
        inc     si
        dec     cx
        jnz     .col
        add     si, MAP_STRIDE - SCREEN_COLS    ; start of next map row
        dec     dx
        jnz     .row
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret

;#####################################################################
;#  FILE: sprites.asm
;#####################################################################
; =====================================================================
;  SPRITES.ASM  --  Module 4 : sprites (characters on the text screen)
;  Owner : Student 1
;  A sprite is one character cell (Small Mario, enemies, items) or two
;  cells on top of each other (Super Mario).  The BACKGROUND colour of
;  the cell is kept, so the sprite is "transparent".  Sprites that are
;  off the screen are clipped.  Facing left/right is shown with a
;  different glyph (the "mirror").
; =====================================================================

; ---------------------------------------------------------------------
; DrawSprite(x, y, glyph, fg)
;   Purpose : draw one transparent glyph at a SCREEN position.
;   Input   : [bp+10]=x [bp+8]=y [bp+6]=glyph [bp+4]=foreground colour
;   Output  : none         Changes : nothing        Removes 8 bytes
; ---------------------------------------------------------------------
DrawSprite:
        push    bp
        mov     bp, sp
        push    ax
        push    bx
        push    cx
        push    dx
        mov     ax, [bp+10]
        cmp     ax, SCREEN_COLS         ; clipping (negative = huge)
        jae     .done
        mov     ax, [bp+8]
        cmp     ax, SCREEN_ROWS
        jae     .done
        mov     cx, SCREEN_COLS
        mul     cx
        add     ax, [bp+10]
        add     ax, ax
        mov     bx, ax
        mov     ah, [screen_buf + bx + 1]       ; background of the cell
        and     ah, 0F0h
        or      ah, [bp+4]                      ; + sprite colour
        mov     al, [bp+6]
        mov     [screen_buf + bx], ax
.done:
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     bp
        ret     8

; ---------------------------------------------------------------------
; DrawHero
;   Purpose : draw Mario (Small = 1 cell, Super/Fire = 2 cells).  While
;             invulnerable he is drawn only on alternate frames (blink).
;   Input   : hero_* variables, camera_x     Output : none
;   Changes : nothing
; ---------------------------------------------------------------------
DrawHero:
        SAVE_ALL
        cmp     byte [hero_invuln], 0
        je      .visible
        test    byte [frame_count], 1
        jnz     .done
.visible:
        mov     al, [hero_x + 1]
        xor     ah, ah
        sub     ax, [camera_x]
        mov     si, ax                  ; SI = screen column
        mov     al, [hero_y + 1]
        xor     ah, ah
        mov     di, ax                  ; DI = feet row
        xor     bh, bh
        mov     bl, GLYPH_STAND         ; pose: standing
        cmp     byte [hero_on_ground], 0
        jne     .on_ground
        mov     bl, GLYPH_JUMP          ; pose: jumping / falling
        jmp     .pose_done
.on_ground:
        cmp     word [hero_vx], 0
        je      .pose_done
        mov     bl, GLYPH_RUN_R         ; pose: running (mirror = facing)
        cmp     byte [hero_dir], 0
        jne     .run_frame
        mov     bl, GLYPH_RUN_L
.run_frame:
; ===== BONUS 2 : walking animation (second running frame) ============
%ifdef BONUS_WALK_ANIM
        test    byte [frame_count], 2
        jz      .pose_done
        mov     bl, GLYPH_RUN_R2
        cmp     byte [hero_dir], 0
        jne     .pose_done
        mov     bl, GLYPH_RUN_L2
%endif
; ===== END BONUS 2 ===================================================
.pose_done:
        cmp     byte [hero_form], 0
        jne     .big
        DRAWSPR si, di, bx, FG_SMALL
        jmp     .done
.big:
        cmp     byte [hero_form], 2
        je      .fire
        DRAWSPR si, di, GLYPH_BODY, FG_SUPER_BODY
        dec     di
        DRAWSPR si, di, bx, FG_SUPER_HEAD
        jmp     .done
.fire:                                  ; Fire Mario colours (BONUS 5)
        DRAWSPR si, di, GLYPH_BODY, FG_FIRE_BODY
        dec     di
        DRAWSPR si, di, bx, FG_FIRE_HEAD
.done:
        RESTORE_ALL
        ret

; ---------------------------------------------------------------------
; DrawEnemies
;   Purpose : draw every enemy of the table that is on the screen.
;   Input   : enemy_table, camera_x     Output : none   Changes : nothing
; ---------------------------------------------------------------------
DrawEnemies:
        SAVE_ALL
        xor     bx, bx
.next:
        cmp     bx, ENEMY_COUNT * ENEMY_SIZE
        jae     .done
        cmp     byte [enemy_table + bx + EN_TYPE], 0
        je      .skip
        mov     al, [enemy_table + bx + EN_X + 1]
        xor     ah, ah
        sub     ax, [camera_x]
        mov     si, ax                  ; screen column
        mov     al, [enemy_table + bx + EN_Y]
        xor     ah, ah
        mov     di, ax                  ; row
        mov     al, [enemy_table + bx + EN_STATE]
        cmp     al, ES_FLAT
        je      .flat
        cmp     al, ES_SHELL_STILL
        je      .shell
        cmp     al, ES_SHELL_SLIDE
        je      .shell
        cmp     byte [enemy_table + bx + EN_TYPE], TYPE_KOOPA
        je      .koopa
        mov     cx, GLYPH_GOOMBA        ; walking Goomba
; ===== BONUS 2 : walking animation for Goombas =======================
%ifdef BONUS_WALK_ANIM
        test    byte [frame_count], 2
        jz      .goomba_draw
        mov     cx, GLYPH_GOOMBA2
%endif
; ===== END BONUS 2 ===================================================
.goomba_draw:
        DRAWSPR si, di, cx, FG_GOOMBA
        jmp     .skip
.flat:
        DRAWSPR si, di, GLYPH_FLAT, FG_GOOMBA
        jmp     .skip
.koopa:
        DRAWSPR si, di, GLYPH_KOOPA, FG_KOOPA
        jmp     .skip
.shell:
        DRAWSPR si, di, GLYPH_SHELL, FG_SHELL
.skip:
        add     bx, ENEMY_SIZE
        jmp     .next
.done:
        RESTORE_ALL
        ret

; ---------------------------------------------------------------------
; DrawItems
;   Purpose : draw mushrooms and flowers (power-ups).
;   Input   : item_table, camera_x      Output : none   Changes : nothing
; ---------------------------------------------------------------------
DrawItems:
        SAVE_ALL
        xor     bx, bx
.next:
        cmp     bx, ITEM_COUNT * ITEM_SIZE
        jae     .done
        cmp     byte [item_table + bx + IT_ACTIVE], 0
        je      .skip
        mov     al, [item_table + bx + IT_X + 1]
        xor     ah, ah
        sub     ax, [camera_x]
        mov     si, ax
        mov     al, [item_table + bx + IT_Y]
        xor     ah, ah
        mov     di, ax
        cmp     byte [item_table + bx + IT_KIND], 0
        jne     .flower
        DRAWSPR si, di, GLYPH_MUSHROOM, FG_MUSHROOM
        jmp     .skip
.flower:
        DRAWSPR si, di, GLYPH_FLOWER, FG_FLOWER
.skip:
        add     bx, ITEM_SIZE
        jmp     .next
.done:
        RESTORE_ALL
        ret

;#####################################################################
;#  FILE: camera.asm
;#####################################################################
; =====================================================================
;  CAMERA.ASM  --  Module 6 : camera and scrolling
;  Owner : Student 1
;  screen column = world column - camera_x
; =====================================================================

; ---------------------------------------------------------------------
; UpdateCamera
;   Purpose : follow Mario once he passes screen column 40, clamp to
;             0..160, NEVER move the camera left, then keep Mario from
;             walking out of the left side of the screen.
;   Input   : hero_x, camera_x    Output : camera_x, hero_x, hero_vx
;   Changes : nothing (registers preserved)
; ---------------------------------------------------------------------
UpdateCamera:
        push    ax
        push    bx
        mov     al, [hero_x + 1]        ; Mario's world column
        xor     ah, ah
        mov     bx, ax
        sub     ax, [camera_x]          ; screen column
        cmp     ax, CAMERA_FOLLOW
        jle     .left_wall              ; not past the middle: no scrolling
        mov     ax, bx
        sub     ax, CAMERA_FOLLOW       ; new camera
        cmp     ax, CAMERA_MAX
        jbe     .limited
        mov     ax, CAMERA_MAX          ; stop at the last position
.limited:
        cmp     ax, [camera_x]
        jbe     .left_wall              ; never decrease the camera
        mov     [camera_x], ax
.left_wall:
        ; invisible wall at the left edge of the screen
        mov     al, [hero_x + 1]
        xor     ah, ah
        cmp     ax, [camera_x]
        jae     .done
        mov     ax, [camera_x]
        mov     ah, al                  ; AH = column, AL = 0 fraction
        xor     al, al
        mov     [hero_x], ax
        mov     word [hero_vx], 0
.done:
        pop     bx
        pop     ax
        ret

;#####################################################################
;#  FILE: bonus_visuals.asm
;#####################################################################
; =====================================================================
;  BONUS_VISUALS.ASM  --  BONUS 7 (hurry blink) and BONUS 8 (clouds)
;  Owner : Student 1
;  To remove: comment out BONUS_HURRY / BONUS_CLOUDS in config.asm.
;  (BONUS 2, the walking animation, is inside sprites.asm and is
;   marked with  ===== BONUS 2  comments.)
; =====================================================================

; ---------------------------------------------------------------------
; BONUS 7 : when the time is below 100 the HUD time and the word
;           HURRY! blink red.
; ---------------------------------------------------------------------
%ifdef BONUS_HURRY
str_hurry       db "HURRY!", 0

; GetTimeAttr : AL = attribute for the HUD time (red blink if time<100)
GetTimeAttr:
        mov     al, ATTR_HUD
        cmp     word [time_left], 100
        jae     .done
        test    byte [frame_count], 4
        jz      .done
        mov     al, ATTR_HUD_RED
.done:
        ret

; DrawHurry : "HURRY!" under the clock while the time is below 100.
DrawHurry:
        push    ax
        push    bx
        cmp     word [time_left], 100
        jae     .done
        test    byte [frame_count], 4
        jz      .done
        TEXT    39, 1, 3Ch, str_hurry
.done:
        pop     bx
        pop     ax
        ret
%endif

; ---------------------------------------------------------------------
; BONUS 8 : clouds that scroll at HALF the camera speed (depth effect).
; ---------------------------------------------------------------------
%ifdef BONUS_CLOUDS
cloud_x         dw 6, 40, 75, 112, 150, 185      ; world columns (parallax)
cloud_row       db 4, 7, 3, 6, 4, 7
cloud_half      dw 0

; DrawClouds : 6 clouds of 4 cells; x = cloud_x - camera_x / 2.
DrawClouds:
        SAVE_ALL
        mov     ax, [camera_x]
        xor     dx, dx
        mov     cx, 2
        div     cx                      ; AX = camera_x / 2
        mov     [cloud_half], ax
        xor     si, si                  ; index of the cloud
.next:
        cmp     si, 6
        jae     .done
        mov     bx, si
        add     bx, bx
        mov     ax, [cloud_x + bx]
        sub     ax, [cloud_half]        ; screen column of the cloud
        mov     bx, ax
        mov     dl, [cloud_row + si]
        xor     dh, dh
        mov     cx, 4
.cell:
        PCELL   bx, dx, 0DBh, 3Fh
        inc     bx
        dec     cx
        jnz     .cell
        inc     si
        jmp     .next
.done:
        RESTORE_ALL
        ret
%endif


; ---- Student 2 : input, time, physics, collision ----
;#####################################################################
;#  FILE: keyboard.asm
;#####################################################################
; =====================================================================
;  KEYBOARD.ASM  --  Module 7 : our own keyboard interrupt (INT 09h)
;  Owner : Student 2
;  key_state[code] = 1 while the key is held   (several keys at once)
;  key_hit[code]   = 1 when the key has just been pressed (menus, P ...)
; =====================================================================

; ---------------------------------------------------------------------
; InstallKeyboard
;   Purpose : save the old INT 09h vector and install keyboard_isr.
;   Input / Output : none      Changes : nothing
; ---------------------------------------------------------------------
InstallKeyboard:
        push    ax
        push    bx
        push    dx
        push    es
        mov     ax, 3509h               ; DOS: get vector -> ES:BX
        int     21h
        mov     [old_int09], bx
        mov     [old_int09 + 2], es
        mov     dx, keyboard_isr        ; DS:DX = new handler (DS = CS)
        mov     ax, 2509h               ; DOS: set vector
        int     21h
        pop     es
        pop     dx
        pop     bx
        pop     ax
        ret

; ---------------------------------------------------------------------
; RestoreKeyboard
;   Purpose : put the original INT 09h vector back (every exit path).
;   Input / Output : none      Changes : nothing
; ---------------------------------------------------------------------
RestoreKeyboard:
        push    ax
        push    dx
        push    ds
        mov     dx, [old_int09]
        mov     ax, [old_int09 + 2]
        mov     ds, ax                  ; DS:DX = old handler
        mov     ax, 2509h
        int     21h
        pop     ds
        pop     dx
        pop     ax
        ret

; ---------------------------------------------------------------------
; keyboard_isr  (hardware interrupt handler)
;   Purpose : read the scan code from port 60h.  Bit 7 set = key
;             released.  The E0h prefix byte of the arrow keys is
;             ignored (the code that follows is processed).  Finish with
;             end-of-interrupt (OUT 20h,20h) and IRET.
;   Changes : nothing (all registers are saved and restored)
; ---------------------------------------------------------------------
keyboard_isr:
        push    ax
        push    bx
        push    ds
        push    cs
        pop     ds                      ; DS = our segment
        in      al, 60h                 ; scan code
        cmp     al, 0E0h
        je      .finish                 ; ignore the prefix byte
        mov     ah, al                  ; AH = full code (bit 7 = release)
        and     al, 7Fh                 ; AL = key number
        mov     bl, al
        xor     bh, bh
        test    ah, 80h
        jnz     .released
        cmp     byte [key_state + bx], 1
        je      .finish                 ; typematic repeat: ignore
        mov     byte [key_state + bx], 1
        mov     byte [key_hit + bx], 1
        jmp     .finish
.released:
        mov     byte [key_state + bx], 0
.finish:
        mov     al, 20h                 ; end of interrupt
        out     20h, al
        pop     ds
        pop     bx
        pop     ax
        iret

; ---------------------------------------------------------------------
; ClearKeyHits
;   Purpose : forget all pending "just pressed" keys.
;   Input / Output : none      Changes : nothing
; ---------------------------------------------------------------------
ClearKeyHits:
        push    bx
        xor     bx, bx
.clear:
        mov     byte [key_hit + bx], 0
        inc     bx
        cmp     bx, 128
        jb      .clear
        pop     bx
        ret

;#####################################################################
;#  FILE: timer.asm
;#####################################################################
; =====================================================================
;  TIMER.ASM  --  Module 8 : timer interrupt and game clock
;  Owner : Student 2
;  INT 1Ch is called by the BIOS about 18.2 times per second.  Our
;  handler counts the ticks and then CHAINS to the old handler.
;  The game loop waits for the tick counter to change, so the speed is
;  the same on every computer.  One game second = 18 ticks.
; =====================================================================

; ---------------------------------------------------------------------
; InstallTimer / RestoreTimer
;   Purpose : save + replace / restore the INT 1Ch vector.
;   Input / Output : none      Changes : nothing
; ---------------------------------------------------------------------
InstallTimer:
        push    ax
        push    bx
        push    dx
        push    es
        mov     ax, 351Ch
        int     21h
        mov     [old_int1c], bx
        mov     [old_int1c + 2], es
        mov     dx, timer_isr
        mov     ax, 251Ch
        int     21h
        pop     es
        pop     dx
        pop     bx
        pop     ax
        ret

RestoreTimer:
        push    ax
        push    dx
        push    ds
        mov     dx, [old_int1c]
        mov     ax, [old_int1c + 2]
        mov     ds, ax
        mov     ax, 251Ch
        int     21h
        pop     ds
        pop     dx
        pop     ax
        ret

; ---------------------------------------------------------------------
; timer_isr  (hardware interrupt handler)
;   Purpose : tick_count = tick_count + 1, then jump to the old handler
;             (which ends with IRET).
;   Changes : nothing
; ---------------------------------------------------------------------
timer_isr:
        push    ds
        push    cs
        pop     ds
        inc     word [tick_count]
        pop     ds
        jmp     far [cs:old_int1c]

; ---------------------------------------------------------------------
; WaitForTick
;   Purpose : wait until the timer handler has counted a new tick.
;             This is what keeps the game at a steady speed.
;   Input / Output : none      Changes : nothing
; ---------------------------------------------------------------------
WaitForTick:
        push    ax
.wait:
        mov     ax, [tick_count]
        cmp     ax, [last_tick]
        je      .wait
        mov     [last_tick], ax
        pop     ax
        ret

; ---------------------------------------------------------------------
; UpdateClock
;   Purpose : once per frame; every 18 frames (one second) time_left
;             goes down by one.  It never goes below zero.
;   Input   : none         Output : time_left     Changes : nothing
; ---------------------------------------------------------------------
UpdateClock:
        inc     byte [sec_ticks]
        cmp     byte [sec_ticks], TICKS_PER_SEC
        jb      .done
        mov     byte [sec_ticks], 0
        cmp     word [time_left], 0
        je      .done
        dec     word [time_left]
.done:
        ret

;#####################################################################
;#  FILE: physics.asm
;#####################################################################
; =====================================================================
;  PHYSICS.ASM  --  Module 9 : player movement and physics
;  Owner : Student 2
;  Position and speed are 8.8 fixed point: the HIGH byte is the whole
;  cell, the LOW byte is the fraction (1/256 of a cell).
;  hero_y is the row of Mario's FEET, so the feet stay fixed when he
;  grows from Small to Super.
; =====================================================================

; ---------------------------------------------------------------------
; UpdateHero
;   Purpose : one frame of Mario movement: horizontal speed, jump and
;             gravity, then move one axis at a time with tile collision.
;   Input   : key_state, hero_*     Output : hero_*     Changes : nothing
; ---------------------------------------------------------------------
UpdateHero:
        push    ax
        mov     al, [hero_y + 1]
        mov     [hero_prev_row], al     ; needed for the stomp test
        call    HeroHorizontalSpeed
        call    HeroJumpAndGravity
        call    HeroMoveX
        call    HeroMoveY
        pop     ax
        ret

; ---------------------------------------------------------------------
; HeroHorizontalSpeed
;   Purpose : Left / Right accelerate up to the walk speed (run speed
;             with Left Shift).  Turning around brakes faster.  With no
;             key friction slows Mario down to zero.
;   Input   : key_state, hero_vx     Output : hero_vx, hero_dir
;   Changes : nothing
; ---------------------------------------------------------------------
HeroHorizontalSpeed:
        push    ax
        push    bx
        push    dx
        mov     ax, [hero_vx]
        mov     bx, MAX_WALK
        cmp     byte [key_state + KEY_LSHIFT], 0
        je      .have_max
        mov     bx, MAX_RUN
.have_max:
        cmp     byte [key_state + KEY_RIGHT], 0
        je      .right_up
        cmp     byte [key_state + KEY_LEFT], 0
        jne     .friction               ; both keys: treat as none
        mov     byte [hero_dir], 1
        cmp     ax, 0
        jge     .accel_right
        add     ax, BRAKE_ACCEL         ; moving left: brake first
        jmp     .limit
.accel_right:
        add     ax, WALK_ACCEL
        jmp     .limit
.right_up:
        cmp     byte [key_state + KEY_LEFT], 0
        je      .friction
        mov     byte [hero_dir], 0
        cmp     ax, 0
        jle     .accel_left
        sub     ax, BRAKE_ACCEL
        jmp     .limit
.accel_left:
        sub     ax, WALK_ACCEL
.limit:
        cmp     ax, bx                  ; not faster than +max
        jle     .check_min
        mov     ax, bx
.check_min:
        mov     dx, bx
        neg     dx                      ; -max
        cmp     ax, dx
        jge     .store
        mov     ax, dx
        jmp     .store
.friction:
        cmp     ax, 0
        je      .store
        jl      .friction_neg
        sub     ax, FRICTION
        jge     .store
        xor     ax, ax
        jmp     .store
.friction_neg:
        add     ax, FRICTION
        jle     .store
        xor     ax, ax
.store:
        mov     [hero_vx], ax
        pop     dx
        pop     bx
        pop     ax
        ret

; ---------------------------------------------------------------------
; HeroJumpAndGravity
;   Purpose : Space starts a jump ONLY when Mario stands on the ground
;             and Space was released since the last jump (no double
;             jump).  If Space is released while rising fast, the
;             upward speed is cut (small hop).  Gravity is added every
;             frame, limited to the maximum fall speed.
;   Input   : key_state, hero_on_ground, hero_vy     Output : hero_vy
;   Changes : nothing
; ---------------------------------------------------------------------
HeroJumpAndGravity:
        push    ax
        mov     ax, [hero_vy]
        cmp     byte [key_state + KEY_SPACE], 0
        jne     .space_down
        mov     byte [jump_ready], 1
        cmp     ax, 0                   ; variable jump height
        jge     .gravity
        cmp     ax, JUMP_CUTOFF
        jge     .gravity
        mov     ax, JUMP_CUTOFF
        jmp     .gravity
.space_down:
        cmp     byte [hero_on_ground], 0
        je      .gravity                ; in the air: no jump
        cmp     byte [jump_ready], 0
        je      .gravity
        mov     ax, JUMP_START
        mov     byte [jump_ready], 0
        mov     byte [hero_on_ground], 0
        SOUND   jump
.gravity:
        add     ax, GRAVITY
        cmp     ax, MAX_FALL
        jle     .store
        mov     ax, MAX_FALL
.store:
        mov     [hero_vy], ax
        pop     ax
        ret

; ---------------------------------------------------------------------
; HeroMoveX
;   Purpose : move Mario sideways.  If he enters a new column that is
;             solid he stays where he was and his speed becomes 0.  He
;             cannot leave either end of the level.
;   Input   : hero_x, hero_vx     Output : hero_x, hero_vx
;   Changes : nothing
; ---------------------------------------------------------------------
HeroMoveX:
        push    ax
        push    bx
        mov     bx, [hero_vx]
        test    bx, bx
        jz      .done
        mov     ax, [hero_x]
        add     ax, bx                  ; AX = new x
        test    bx, bx
        js      .going_left
        cmp     ax, 0F000h              ; beyond the right end?
        jb      .check_tile
        mov     word [hero_x], 0EF80h   ; last column
        mov     word [hero_vx], 0
        jmp     .done
.going_left:
        cmp     ax, 0F000h              ; wrapped below zero?
        jb      .check_tile
        mov     word [hero_x], 0
        mov     word [hero_vx], 0
        jmp     .done
.check_tile:
        cmp     ah, [hero_x + 1]        ; same column: nothing to test
        je      .commit
        push    ax
        mov     bl, ah
        xor     bh, bh
        push    bx
        call    HeroColumnBlocked       ; carry = wall
        pop     ax
        jnc     .commit
        mov     word [hero_vx], 0       ; wall in front
        jmp     .done
.commit:
        mov     [hero_x], ax
.done:
        pop     bx
        pop     ax
        ret

; ---------------------------------------------------------------------
; HeroMoveY
;   Purpose : move Mario up / down by hero_vy.
;             Falling : if the tile below the feet is solid, place him
;                       on top of it, vy = 0, on_ground = 1, stomp
;                       chain = 0.
;             Rising  : if the tile at the head is solid, he stops
;                       rising (vy = 0) and the block is hit (HitBlock).
;             hero_falling = 1 when he moved down this frame (stomp
;             test).  A feet row >= 25 means he fell into a pit; the
;             game logic checks that.
;   Input   : hero_*      Output : hero_y, hero_vy, hero_on_ground, ...
;   Changes : nothing
; ---------------------------------------------------------------------
HeroMoveY:
        SAVE_ALL
        mov     byte [hero_on_ground], 0
        mov     byte [hero_falling], 0
        mov     ax, [hero_vy]
        mov     bx, [hero_y]
        add     bx, ax                  ; BX = new y
        cmp     ax, 0
        jl      .rising
        je      .down
        mov     byte [hero_falling], 1
.down:
        mov     [hero_y], bx
        cmp     bh, PIT_ROW
        jae     .done                   ; fell into a pit
        mov     dl, bh
        inc     dl
        xor     dh, dh                  ; DX = row below the feet
        mov     al, [hero_x + 1]
        xor     ah, ah                  ; AX = column
        GETTILE ax, dx
        call    IsSolid
        jnc     .done
        mov     byte [hero_y], 0        ; stand exactly on top of the tile
        mov     word [hero_vy], 0
        mov     byte [hero_on_ground], 1
        mov     byte [hero_chain], 0    ; landing resets the stomp chain
        jmp     .done
.rising:
        mov     dl, bh                  ; new feet row
        cmp     byte [hero_form], 0
        je      .head_row
        dec     dl                      ; Super/Fire: head is one row up
.head_row:
        xor     dh, dh                  ; DX = head row
        mov     al, [hero_x + 1]
        xor     ah, ah                  ; AX = column
        GETTILE ax, dx
        call    IsSolid
        jc      .head_hit
        mov     [hero_y], bx            ; free: move up
        jmp     .done
.head_hit:
        mov     word [hero_vy], 0       ; bump: start falling
        mov     al, [hero_x + 1]
        xor     ah, ah
        push    ax
        push    dx
        call    HitBlock                ; (blocks.asm) trigger the block
.done:
        RESTORE_ALL
        ret

;#####################################################################
;#  FILE: collision.asm
;#####################################################################
; =====================================================================
;  COLLISION.ASM  --  Module 10 : collision detection
;  Owner : Student 2
; =====================================================================

; ---------------------------------------------------------------------
; HeroColumnBlocked(col)
;   Purpose : is any tile of Mario's body (feet row, plus head row when
;             Super) in this column solid?
;   Input   : [bp+4] = column
;   Output  : carry = 1 blocked, 0 free     Changes : flags    Removes 2
; ---------------------------------------------------------------------
HeroColumnBlocked:
        push    bp
        mov     bp, sp
        push    ax
        push    bx
        mov     bl, [hero_y + 1]
        xor     bh, bh                  ; BX = feet row
        GETTILE word [bp+4], bx
        call    IsSolid
        jc      .blocked
        cmp     byte [hero_form], 0
        je      .free
        dec     bx                      ; head row
        GETTILE word [bp+4], bx
        call    IsSolid
        jc      .blocked
.free:
        clc
.blocked:
        pop     bx
        pop     ax
        pop     bp
        ret     2

; ---------------------------------------------------------------------
; HeroNear(x)
;   Purpose : rectangle-overlap test in x: is the 8.8 world position x
;             closer to Mario than HIT_WIDTH (a bit more than 1 cell)?
;   Input   : [bp+4] = other object's 8.8 world x
;   Output  : carry = 1 overlap          Changes : flags     Removes 2
; ---------------------------------------------------------------------
HeroNear:
        push    bp
        mov     bp, sp
        push    ax
        mov     ax, [hero_x]
        sub     ax, [bp+4]
        jns     .abs
        neg     ax
.abs:
        cmp     ax, HIT_WIDTH           ; carry = (distance < HIT_WIDTH)
        pop     ax
        pop     bp
        ret     2

; ---------------------------------------------------------------------
; StompOrHurt(row)
;   Purpose : decide what a contact with an enemy standing in `row`
;             means (x overlap was already checked with HeroNear):
;               stomp : Mario is moving DOWN and in the previous frame
;                       his feet were above the enemy's row
;               side  : the enemy is at Mario's body height otherwise
;   Input   : [bp+4] = enemy row
;   Output  : AL = 0 no contact, 1 stomp, 2 side/bottom contact
;   Changes : AL, flags        Removes 2 bytes
; ---------------------------------------------------------------------
StompOrHurt:
        push    bp
        mov     bp, sp
        push    bx
        push    cx
        mov     bl, [bp+4]              ; BL = enemy row
        mov     bh, [hero_y + 1]        ; BH = Mario's feet row
        xor     al, al
        mov     cl, bh
        inc     cl                      ; row just below Mario's feet
        cmp     bl, cl
        ja      .out                    ; enemy far below: no contact
        cmp     byte [hero_falling], 0
        je      .side
        cmp     bl, [hero_prev_row]
        jbe     .side                   ; enemy was not below him: side hit
        mov     al, 1                   ; STOMP
        jmp     .out
.side:
        mov     cl, bh                  ; CL = top row of Mario
        cmp     byte [hero_form], 0
        je      .have_top
        dec     cl
.have_top:
        cmp     bl, cl
        jb      .out                    ; enemy above his head
        cmp     bl, bh
        ja      .out                    ; enemy below his feet
        mov     al, 2                   ; SIDE CONTACT
.out:
        pop     cx
        pop     bx
        pop     bp
        ret     2

; ---------------------------------------------------------------------
; CheckFlagPole
;   Purpose : does Mario overlap a flag pole tile?
;   Input   : hero_x, hero_y, hero_form
;   Output  : carry = 1 touching the pole, 0 not    Changes : flags
; ---------------------------------------------------------------------
CheckFlagPole:
        push    ax
        push    bx
        push    dx
        mov     al, [hero_x + 1]
        xor     ah, ah                  ; AX = column
        mov     bl, [hero_y + 1]
        xor     bh, bh                  ; BX = feet row
        GETTILE ax, bx
        cmp     al, T_POLE
        je      .touch
        cmp     byte [hero_form], 0
        je      .no
        mov     al, [hero_x + 1]
        xor     ah, ah
        dec     bx
        GETTILE ax, bx
        cmp     al, T_POLE
        je      .touch
.no:
        clc
        jmp     .out
.touch:
        stc
.out:
        pop     dx
        pop     bx
        pop     ax
        ret

;#####################################################################
;#  FILE: bonus_sound.asm
;#####################################################################
; =====================================================================
;  BONUS_SOUND.ASM  --  BONUS 1 : PC-speaker sound effects
;  Owner : Student 2
;  To remove: comment out  %define BONUS_SOUND  in config.asm
;  (this whole file and every SOUND call disappear).
;  Each effect is one beep: frequency (Hz) and length (frames).
;  The PIT channel 2 is programmed with 1193180 / frequency.
; =====================================================================
%ifdef BONUS_SOUND

snd_timer       db 0            ; frames of the current beep still to play

; ---------------------------------------------------------------------
; SoundStart
;   Purpose : start a beep.   Input : AX = PIT divisor, CL = frames
;   Output  : none            Changes : nothing
; ---------------------------------------------------------------------
SoundStart:
        push    ax
        mov     [snd_timer], cl
        push    ax
        mov     al, 0B6h                ; channel 2, square wave
        out     43h, al
        pop     ax
        out     42h, al                 ; divisor low byte
        mov     al, ah
        out     42h, al                 ; divisor high byte
        in      al, 61h
        or      al, 03h                 ; speaker on
        out     61h, al
        pop     ax
        ret

; ---------------------------------------------------------------------
; SoundUpdate : called once per frame; stops the beep when it is over.
; ---------------------------------------------------------------------
SoundUpdate:
        cmp     byte [snd_timer], 0
        je      .done
        dec     byte [snd_timer]
        jnz     .done
        call    SoundOff
.done:
        ret

; ---------------------------------------------------------------------
; SoundOff : speaker off (also used on exit).     Changes : nothing
; ---------------------------------------------------------------------
SoundOff:
        push    ax
        in      al, 61h
        and     al, 0FCh
        out     61h, al
        pop     ax
        ret

%macro SNDDEF 3                         ; name, frequency in Hz, frames
snd_ %+ %1:
        push    ax
        push    cx
        mov     ax, 1193180 / %2
        mov     cl, %3
        call    SoundStart
        pop     cx
        pop     ax
        ret
%endmacro

        SNDDEF  jump,    523, 3
        SNDDEF  coin,    988, 3
        SNDDEF  stomp,   300, 3
        SNDDEF  kick,    200, 3
        SNDDEF  powerup, 784, 6
        SNDDEF  hurt,    180, 6
        SNDDEF  die,     110, 12
        SNDDEF  flag,   1175, 8
        SNDDEF  oneup,  1319, 8
        SNDDEF  break,   150, 3
        SNDDEF  fire,    700, 2

%endif

;#####################################################################
;#  FILE: bonus_hiscore.asm
;#####################################################################
; =====================================================================
;  BONUS_HISCORE.ASM  --  BONUS 4 : high score saved in HISCORE.TXT
;  Owner : Student 2
;  To remove: comment out  %define BONUS_HISCORE  in config.asm.
;  The file holds 6 decimal digits (+ CR LF).  It is read when the game
;  starts and written when a game ends with a new record.
; =====================================================================
%ifdef BONUS_HISCORE

hs_filename     db "HISCORE.TXT", 0
hs_buffer       db "000000", 13, 10
str_hi          db "HI-SCORE ", 0

; ---------------------------------------------------------------------
; LoadHighScore
;   Purpose : read HISCORE.TXT (if it exists) into hiscore_lo/hi.
;   Input / Output : none (hiscore_lo/hi)      Changes : nothing
; ---------------------------------------------------------------------
LoadHighScore:
        SAVE_ALL
        mov     word [hiscore_lo], 0
        mov     word [hiscore_hi], 0
        mov     dx, hs_filename
        mov     ax, 3D00h               ; DOS: open for reading
        int     21h
        jc      .done                   ; no file yet: high score 0
        mov     bx, ax                  ; file handle
        mov     dx, hs_buffer
        mov     cx, 6
        mov     ah, 3Fh                 ; DOS: read 6 bytes
        int     21h
        mov     si, ax                  ; bytes read
        mov     ah, 3Eh                 ; DOS: close
        int     21h
        cmp     si, 6
        jne     .done
        mov     si, hs_buffer
        mov     cx, 6
.digit:
        mov     al, [si]
        sub     al, '0'
        cmp     al, 9
        ja      .bad                    ; not a digit: ignore the file
        xor     ah, ah
        mov     bx, ax                  ; BX = digit
        mov     ax, [hiscore_lo]        ; value = value * 10 + digit
        mov     dx, 10
        mul     dx
        mov     [hiscore_lo], ax
        mov     di, dx
        mov     ax, [hiscore_hi]
        mov     dx, 10
        mul     dx
        add     ax, di
        mov     [hiscore_hi], ax
        add     [hiscore_lo], bx
        adc     word [hiscore_hi], 0
        inc     si
        dec     cx
        jnz     .digit
        jmp     .done
.bad:
        mov     word [hiscore_lo], 0
        mov     word [hiscore_hi], 0
.done:
        RESTORE_ALL
        ret

; ---------------------------------------------------------------------
; SaveHighScore
;   Purpose : if score > hiscore, remember it and write HISCORE.TXT.
;   Input   : score_lo/hi          Output : file, hiscore_lo/hi
;   Changes : nothing
; ---------------------------------------------------------------------
SaveHighScore:
        SAVE_ALL
        mov     ax, [score_hi]
        cmp     ax, [hiscore_hi]
        jb      .done
        ja      .newrecord
        mov     ax, [score_lo]
        cmp     ax, [hiscore_lo]
        jbe     .done
.newrecord:
        mov     ax, [score_lo]
        mov     [hiscore_lo], ax
        mov     ax, [score_hi]
        mov     [hiscore_hi], ax
        mov     si, [hiscore_lo]        ; convert to 6 digits (divide by 10)
        mov     di, [hiscore_hi]
        mov     cx, 6
        mov     bx, 10
.divide:
        mov     ax, di
        xor     dx, dx
        div     bx
        mov     di, ax
        mov     ax, si
        div     bx
        mov     si, ax
        push    dx
        dec     cx
        jnz     .divide
        mov     bx, hs_buffer
        mov     cx, 6
.store:
        pop     ax
        add     al, '0'
        mov     [bx], al
        inc     bx
        dec     cx
        jnz     .store
        mov     dx, hs_filename
        xor     cx, cx
        mov     ah, 3Ch                 ; DOS: create / truncate file
        int     21h
        jc      .done
        mov     bx, ax
        mov     dx, hs_buffer
        mov     cx, 8                   ; 6 digits + CR LF
        mov     ah, 40h                 ; DOS: write
        int     21h
        mov     ah, 3Eh                 ; DOS: close
        int     21h
.done:
        RESTORE_ALL
        ret

; ---------------------------------------------------------------------
; DrawHighScore(x, y)   draws "HI-SCORE 000000"
; ---------------------------------------------------------------------
DrawHighScore:
        push    bp
        mov     bp, sp
        push    ax
        push    bx
        push    word [bp+6]
        push    word [bp+4]
        PUSHI   ATTR_TEXT
        PUSHI   str_hi
        call    DrawString
        mov     bx, [bp+6]
        add     bx, 9
        NUMBER  [hiscore_lo], [hiscore_hi], 6, bx, [bp+4], ATTR_TEXT
        pop     bx
        pop     ax
        pop     bp
        ret     4

%endif


; ---- Student 3 : game rules and flow ----
;#####################################################################
;#  FILE: blocks.asm
;#####################################################################
; =====================================================================
;  BLOCKS.ASM  --  Module 12 : blocks, coins and power-ups
;  Owner : Student 3
;  All changes are made to the WORKING map; the original map stays
;  untouched, so ResetMap can restore everything.
; =====================================================================

; ---------------------------------------------------------------------
; HitBlock(col, row)
;   Purpose : Mario's head hit the tile at (col,row) from below.
;             Brick   : Small = nothing, Super = destroyed, +50
;             ? coin  : becomes an empty block, coin +200, coins + 1
;             ? mush. : becomes an empty block, a mushroom appears on
;                       top (a Fire flower if Mario is Super - BONUS 5)
;   Input   : [bp+6] = column, [bp+4] = row
;   Output  : working map, score, items       Changes : nothing
;   Removes 4 bytes
; ---------------------------------------------------------------------
HitBlock:
        push    bp
        mov     bp, sp
        push    ax
        push    bx
        GETTILE word [bp+6], word [bp+4]
        cmp     al, T_BRICK
        je      .brick
        cmp     al, T_QCOIN
        je      .qcoin
        cmp     al, T_QMUSH
        je      .qmush
        jmp     .done
.brick:
        cmp     byte [hero_form], 0
        je      .done                   ; Small Mario: the brick stays
        SETTILE word [bp+6], word [bp+4], T_SKY
        SCORE   50
        SOUND   break
        jmp     .done
.qcoin:
        SETTILE word [bp+6], word [bp+4], T_EMPTY
        call    AddCoin
        SCORE   200
        SOUND   coin
        jmp     .done
.qmush:
        SETTILE word [bp+6], word [bp+4], T_EMPTY
        mov     bx, [bp+4]
        dec     bx                      ; row above the block
        xor     ax, ax                  ; kind 0 = mushroom
; ===== BONUS 5 : a Super Mario gets a Fire flower instead ============
%ifdef BONUS_FIRE
        cmp     byte [hero_form], 0
        je      .spawn
        mov     ax, 1                   ; kind 1 = flower
%endif
; ===== END BONUS 5 ===================================================
.spawn:
        push    word [bp+6]
        push    bx
        push    ax
        call    SpawnItem
.done:
        pop     bx
        pop     ax
        pop     bp
        ret     4

; ---------------------------------------------------------------------
; SpawnItem(col, row, kind)
;   Purpose : put a mushroom (kind 0) or flower (kind 1) in a free slot
;             of the item table, standing in (col,row).
;   Input   : [bp+8] = column, [bp+6] = row, [bp+4] = kind
;   Output  : item_table          Changes : nothing     Removes 6 bytes
; ---------------------------------------------------------------------
SpawnItem:
        push    bp
        mov     bp, sp
        push    ax
        push    bx
        xor     bx, bx
.find:
        cmp     bx, ITEM_COUNT * ITEM_SIZE
        jae     .done                   ; table full
        cmp     byte [item_table + bx + IT_ACTIVE], 0
        je      .use
        add     bx, ITEM_SIZE
        jmp     .find
.use:
        mov     byte [item_table + bx + IT_ACTIVE], 1
        mov     al, [bp+4]
        mov     [item_table + bx + IT_KIND], al
        mov     ax, [bp+8]
        mov     ah, al                  ; AH = column, AL = fraction 0
        xor     al, al
        mov     [item_table + bx + IT_X], ax
        mov     al, [bp+6]
        mov     [item_table + bx + IT_Y], al
        mov     byte [item_table + bx + IT_DIR], 1      ; moves right
.done:
        pop     bx
        pop     ax
        pop     bp
        ret     6

; ---------------------------------------------------------------------
; ResetItems : remove every item (new life / new game).
; ---------------------------------------------------------------------
ResetItems:
        push    bx
        xor     bx, bx
.clear:
        mov     byte [item_table + bx], 0
        inc     bx
        cmp     bx, ITEM_COUNT * ITEM_SIZE
        jb      .clear
        pop     bx
        ret

; ---------------------------------------------------------------------
; UpdateItems : move every active item (BX = record offset).
; ---------------------------------------------------------------------
UpdateItems:
        push    bx
        xor     bx, bx
.next:
        cmp     bx, ITEM_COUNT * ITEM_SIZE
        jae     .done
        call    UpdateOneItem
        add     bx, ITEM_SIZE
        jmp     .next
.done:
        pop     bx
        ret

; ---------------------------------------------------------------------
; UpdateOneItem
;   Purpose : a mushroom falls when nothing is below it, walks right at
;             1 cell/4 frames, turns at walls, disappears in pits or far
;             to the left.  A flower stays where it is.
;   Input   : BX = record offset         Changes : nothing
; ---------------------------------------------------------------------
UpdateOneItem:
        push    ax
        push    cx
        push    dx
        cmp     byte [item_table + bx + IT_ACTIVE], 0
        je      .out
        mov     al, [item_table + bx + IT_X + 1]
        xor     ah, ah
        add     ax, 2
        cmp     ax, [camera_x]
        jae     .alive
        mov     byte [item_table + bx + IT_ACTIVE], 0   ; left behind
        jmp     .out
.alive:
        cmp     byte [item_table + bx + IT_KIND], 0
        jne     .out                    ; flower: does not move
        mov     al, [item_table + bx + IT_X + 1]
        xor     ah, ah                  ; AX = column
        mov     dl, [item_table + bx + IT_Y]
        xor     dh, dh
        inc     dx                      ; DX = row below
        GETTILE ax, dx
        call    IsSolid
        jc      .grounded
        inc     byte [item_table + bx + IT_Y]           ; fall one row
        cmp     byte [item_table + bx + IT_Y], PIT_ROW
        jb      .out
        mov     byte [item_table + bx + IT_ACTIVE], 0   ; fell into a pit
        jmp     .out
.grounded:
        mov     ax, [item_table + bx + IT_X]
        cmp     byte [item_table + bx + IT_DIR], 0
        je      .go_left
        add     ax, MUSH_SPEED
        jmp     .moved
.go_left:
        sub     ax, MUSH_SPEED
.moved:
        cmp     ax, 0F000h
        jae     .turn
        cmp     ah, [item_table + bx + IT_X + 1]
        je      .commit
        mov     dl, ah
        xor     dh, dh                  ; DX = new column
        mov     cl, [item_table + bx + IT_Y]
        xor     ch, ch                  ; CX = row
        push    ax
        GETTILE dx, cx
        call    IsSolid
        pop     ax
        jc      .turn                   ; wall: turn around
.commit:
        mov     [item_table + bx + IT_X], ax
        jmp     .out
.turn:
        xor     byte [item_table + bx + IT_DIR], 1
.out:
        pop     dx
        pop     cx
        pop     ax
        ret

; ---------------------------------------------------------------------
; HeroVsItems
;   Purpose : Mario touches a mushroom / flower: +1000 points.
;             Small -> Super (HP 2).  Already Super: points only.
;             Flower (BONUS 5): Super -> Fire.
;   Input   : item_table, hero_*        Output : hero_form, hp, score
;   Changes : nothing
; ---------------------------------------------------------------------
HeroVsItems:
        SAVE_ALL
        xor     bx, bx
.next:
        cmp     bx, ITEM_COUNT * ITEM_SIZE
        jae     .done
        cmp     byte [item_table + bx + IT_ACTIVE], 0
        je      .skip
        push    word [item_table + bx + IT_X]
        call    HeroNear
        jnc     .skip
        mov     al, [item_table + bx + IT_Y]    ; row must be at Mario's body
        mov     ah, [hero_y + 1]                ; feet row
        cmp     al, ah
        ja      .skip
        mov     cl, ah
        cmp     byte [hero_form], 0
        je      .top
        dec     cl
.top:
        cmp     al, cl
        jb      .skip
        mov     byte [item_table + bx + IT_ACTIVE], 0   ; collected
        SCORE   1000
        SOUND   powerup
        cmp     byte [hero_form], 0
        jne     .already_super
        mov     byte [hero_form], 1                     ; Small -> Super
        mov     byte [hero_hp], 2
.already_super:
; ===== BONUS 5 : flower makes Fire Mario =============================
%ifdef BONUS_FIRE
        cmp     byte [item_table + bx + IT_KIND], 1
        jne     .skip
        mov     byte [hero_form], 2
        mov     byte [hero_hp], 2
%endif
; ===== END BONUS 5 ===================================================
.skip:
        add     bx, ITEM_SIZE
        jmp     .next
.done:
        RESTORE_ALL
        ret

; ---------------------------------------------------------------------
; CollectMapCoins
;   Purpose : coins lying on the map are collected when Mario overlaps
;             them (feet cell and, for Super, head cell): +200, coins+1.
;   Input   : hero_*, working map      Output : map, score, coins
;   Changes : nothing
; ---------------------------------------------------------------------
CollectMapCoins:
        SAVE_ALL
        mov     al, [hero_x + 1]
        xor     ah, ah
        mov     si, ax                  ; SI = column
        mov     al, [hero_y + 1]
        xor     ah, ah
        mov     di, ax                  ; DI = feet row
        GETTILE si, di
        cmp     al, T_COIN
        jne     .head
        call    TakeCoin
.head:
        cmp     byte [hero_form], 0
        je      .done
        dec     di
        GETTILE si, di
        cmp     al, T_COIN
        jne     .done
        call    TakeCoin
.done:
        RESTORE_ALL
        ret

; TakeCoin : SI = column, DI = row of a coin tile.
TakeCoin:
        SETTILE si, di, T_SKY
        call    AddCoin
        SCORE   200
        SOUND   coin
        ret

; ---------------------------------------------------------------------
; AddCoin
;   Purpose : coins + 1; the 100th coin gives an extra life and the
;             counter returns to 0 (no points for that).
; ---------------------------------------------------------------------
AddCoin:
        inc     word [coins]
        cmp     word [coins], 100
        jb      .done
        mov     word [coins], 0
        call    AddLife
.done:
        ret

;#####################################################################
;#  FILE: score_hud.asm
;#####################################################################
; =====================================================================
;  SCORE_HUD.ASM  --  Module 13 : score, lives and the HUD
;  Owner : Student 3
; =====================================================================
str_score       db "SCORE", 0
str_coins       db "COINS x", 0
str_world       db "WORLD 1-", 0
str_time        db "TIME", 0
str_lives       db "LIVES x", 0
str_hp          db "HP", 0

; ---------------------------------------------------------------------
; AddScore(lo, hi)
;   Purpose : the ONE procedure that adds points.  32-bit addition with
;             ADD / ADC, clamped to 999,999.
;   Input   : [bp+6] = low word, [bp+4] = high word of the points
;   Output  : score_lo / score_hi          Changes : nothing
;   Removes 4 bytes
; ---------------------------------------------------------------------
AddScore:
        push    bp
        mov     bp, sp
        push    ax
        mov     ax, [bp+6]
        add     [score_lo], ax
        mov     ax, [bp+4]
        adc     [score_hi], ax          ; carry from the low word
        cmp     word [score_hi], MAX_SCORE_HI
        jb      .ok
        ja      .clamp
        cmp     word [score_lo], MAX_SCORE_LO
        jbe     .ok
.clamp:
        mov     word [score_hi], MAX_SCORE_HI
        mov     word [score_lo], MAX_SCORE_LO
.ok:
        mov     ax, [bp+6]
        HOOK_POPUP_SPAWN                ; BONUS 6 (AX = points)
        pop     ax
        pop     bp
        ret     4

; ---------------------------------------------------------------------
; AddLife : lives + 1, never more than 99.
; ---------------------------------------------------------------------
AddLife:
        cmp     word [lives], MAX_LIVES
        jae     .done
        inc     word [lives]
        SOUND   oneup
.done:
        ret

; ---------------------------------------------------------------------
; DrawHUD
;   Purpose : the top row: score, coins, world, time, lives, hearts.
;   Input   : game variables       Output : none     Changes : nothing
; ---------------------------------------------------------------------
DrawHUD:
        SAVE_ALL
        FILL    0, 0, 80, 1, ' ', ATTR_HUD
        TEXT    1, 0, ATTR_HUD, str_score
        NUMBER  [score_lo], [score_hi], 6, 7, 0, ATTR_HUD
        TEXT    15, 0, ATTR_HUD, str_coins
        NUMBER  [coins], 0, 2, 22, 0, ATTR_HUD
        TEXT    27, 0, ATTR_HUD, str_world
        mov     al, [cur_level]
        add     al, '1'
        xor     ah, ah
        mov     bx, ax
        mov     dx, 35
        xor     cx, cx
        PCELL   dx, cx, bx, ATTR_HUD
        TEXT    39, 0, ATTR_HUD, str_time
        TIME_ATTR                       ; AL = colour (BONUS 7 blinks it)
        mov     bl, al
        xor     bh, bh
        NUMBER  [time_left], 0, 3, 44, 0, bx
        TEXT    50, 0, ATTR_HUD, str_lives
        mov     bx, ATTR_HUD
        NUMBER  [lives], 0, 2, 57, 0, bx
        TEXT    62, 0, ATTR_HUD, str_hp
        mov     dx, 65
        xor     cx, cx
        PCELL   dx, cx, GLYPH_HEART, ATTR_HUD_RED       ; heart 1: always
        mov     dx, 67
        mov     ax, ATTR_HUD_GREY
        cmp     byte [hero_hp], 2
        jb      .second
        mov     ax, ATTR_HUD_RED
.second:
        mov     bx, ax
        PCELL   dx, cx, GLYPH_HEART, bx                 ; heart 2: Super only
        HOOK_HISCORE_DRAW 1, 1
        HOOK_HURRY_DRAW
        RESTORE_ALL
        ret

;#####################################################################
;#  FILE: enemies.asm
;#####################################################################
; =====================================================================
;  ENEMIES.ASM  --  Module 11 : Goombas, Koopa Troopas and shells
;  Owner : Student 3
;  Enemies live in a table of fixed-size records (see config.asm):
;  type, state, x (8.8), y (row), direction, timer, speed (8.8).
;  A procedure walks through the table with BX = record offset.
; =====================================================================

; ---------------------------------------------------------------------
; ResetEnemies
;   Purpose : clear the table and fill it from the start list of the
;             current level (type, column, row ... 0).
;   Input   : cur_level          Output : enemy_table   Changes : nothing
; ---------------------------------------------------------------------
ResetEnemies:
        SAVE_ALL
        xor     bx, bx
.clear:
        mov     byte [enemy_table + bx], 0
        inc     bx
        cmp     bx, ENEMY_COUNT * ENEMY_SIZE
        jb      .clear
        mov     bl, [cur_level]
        xor     bh, bh
        add     bx, bx
        mov     si, [enemy_ptrs + bx]
        xor     bx, bx
.fill:
        mov     cl, [si]
        cmp     cl, 0
        je      .done
        cmp     bx, ENEMY_COUNT * ENEMY_SIZE
        jae     .done
        mov     [enemy_table + bx + EN_TYPE], cl
        mov     byte [enemy_table + bx + EN_STATE], ES_WAIT
        mov     dh, [si + 1]            ; column -> high byte of x
        xor     dl, dl
        mov     [enemy_table + bx + EN_X], dx
        mov     al, [si + 2]
        mov     [enemy_table + bx + EN_Y], al
        mov     byte [enemy_table + bx + EN_DIR], 0     ; walk left
        mov     byte [enemy_table + bx + EN_TIMER], 0
        mov     word [enemy_table + bx + EN_SPEED], GOOMBA_SPEED
        cmp     cl, TYPE_KOOPA
        jne     .next
        mov     word [enemy_table + bx + EN_SPEED], KOOPA_SPEED
.next:
        add     si, 3
        add     bx, ENEMY_SIZE
        jmp     .fill
.done:
        RESTORE_ALL
        ret

; ---------------------------------------------------------------------
; UpdateEnemies : update every record of the table.
; ---------------------------------------------------------------------
UpdateEnemies:
        push    bx
        mov     byte [enemy_active], 0
        xor     bx, bx
.next:
        cmp     bx, ENEMY_COUNT * ENEMY_SIZE
        jae     .done
        mov     [enemy_self], bx
        call    UpdateOneEnemy
        add     bx, ENEMY_SIZE
        jmp     .next
.done:
        pop     bx
        ret

; ---------------------------------------------------------------------
; UpdateOneEnemy
;   Purpose : waiting enemies start walking when they come within one
;             tile of the screen (at most 8 active).  A flat Goomba is
;             removed after 1 s.  Others fall, then walk / slide.  A
;             sliding shell kills every enemy it touches (+500).
;             Enemies far left of the camera are removed.
;   Input   : BX = record offset         Changes : nothing
; ---------------------------------------------------------------------
UpdateOneEnemy:
        push    ax
        push    dx
        cmp     byte [enemy_table + bx + EN_TYPE], 0
        je      .out
        mov     al, [enemy_table + bx + EN_STATE]
        cmp     al, ES_WAIT
        je      .waiting
        cmp     al, ES_FLAT
        je      .flat
        inc     byte [enemy_active]
        cmp     byte [enemy_table + bx + EN_TIMER], 0
        je      .no_timer
        dec     byte [enemy_table + bx + EN_TIMER]
.no_timer:
        mov     al, [enemy_table + bx + EN_X + 1]
        xor     ah, ah
        add     ax, 2
        cmp     ax, [camera_x]
        jae     .on_map
        mov     byte [enemy_table + bx + EN_TYPE], 0    ; left behind
        jmp     .out
.on_map:
        call    EnemyFall
        cmp     byte [enemy_table + bx + EN_TYPE], 0
        je      .out                    ; fell into a pit
        cmp     byte [enemy_table + bx + EN_STATE], ES_SHELL_STILL
        je      .out                    ; a stopped shell does not walk
        call    EnemyWalk
        cmp     byte [enemy_table + bx + EN_STATE], ES_SHELL_SLIDE
        jne     .out
        call    ShellKills
        jmp     .out
.waiting:
        mov     al, [enemy_table + bx + EN_X + 1]
        xor     ah, ah
        mov     dx, [camera_x]
        add     dx, SCREEN_COLS + 1     ; one tile beyond the screen
        cmp     ax, dx
        ja      .out
        cmp     byte [enemy_active], MAX_ACTIVE_ENEMIES
        jae     .out
        mov     byte [enemy_table + bx + EN_STATE], ES_WALK
        inc     byte [enemy_active]
        jmp     .out
.flat:
        dec     byte [enemy_table + bx + EN_TIMER]
        jnz     .out
        mov     byte [enemy_table + bx + EN_TYPE], 0
.out:
        pop     dx
        pop     ax
        ret

; ---------------------------------------------------------------------
; EnemyFall : if there is no solid tile below, fall one row; below the
;             map the enemy is removed.          Input : BX = record
; ---------------------------------------------------------------------
EnemyFall:
        push    ax
        push    dx
        mov     al, [enemy_table + bx + EN_X + 1]
        xor     ah, ah
        mov     dl, [enemy_table + bx + EN_Y]
        xor     dh, dh
        inc     dx
        GETTILE ax, dx
        call    IsSolid
        jc      .out
        inc     byte [enemy_table + bx + EN_Y]
        cmp     byte [enemy_table + bx + EN_Y], PIT_ROW
        jb      .out
        mov     byte [enemy_table + bx + EN_TYPE], 0
.out:
        pop     dx
        pop     ax
        ret

; ---------------------------------------------------------------------
; EnemyWalk
;   Purpose : move by speed in the facing direction.  Turn around at a
;             solid tile, at another walking enemy and (Koopa only) at
;             a platform edge.  A Goomba walks off ledges.  A sliding
;             shell bounces off walls.        Input : BX = record
; ---------------------------------------------------------------------
EnemyWalk:
        push    ax
        push    cx
        push    dx
        mov     ax, [enemy_table + bx + EN_X]
        mov     cx, [enemy_table + bx + EN_SPEED]
        cmp     byte [enemy_table + bx + EN_DIR], 0
        je      .left
        add     ax, cx
        jmp     .moved
.left:
        sub     ax, cx
.moved:
        cmp     ax, 0F000h              ; left the level
        jae     .turn
        cmp     ah, [enemy_table + bx + EN_X + 1]
        je      .commit                 ; same column: just move
        mov     dl, ah
        xor     dh, dh                  ; DX = new column
        mov     cl, [enemy_table + bx + EN_Y]
        xor     ch, ch                  ; CX = row
        push    ax
        GETTILE dx, cx
        call    IsSolid
        pop     ax
        jc      .turn                   ; wall
        cmp     byte [enemy_table + bx + EN_STATE], ES_WALK
        jne     .commit                 ; sliding shells are not stopped
        push    ax
        push    dx
        push    cx
        call    OtherEnemyAt
        pop     ax
        jc      .turn                   ; another enemy is there
        cmp     byte [enemy_table + bx + EN_TYPE], TYPE_KOOPA
        jne     .commit
        inc     cx                      ; Koopa: is there floor ahead?
        push    ax
        GETTILE dx, cx
        call    IsSolid
        pop     ax
        jnc     .turn
.commit:
        mov     [enemy_table + bx + EN_X], ax
        jmp     .out
.turn:
        xor     byte [enemy_table + bx + EN_DIR], 1
.out:
        pop     dx
        pop     cx
        pop     ax
        ret

; ---------------------------------------------------------------------
; OtherEnemyAt(col, row)
;   Purpose : is another enemy (not the one in enemy_self) standing in
;             this tile?
;   Input   : [bp+6] = column, [bp+4] = row
;   Output  : carry = 1 yes          Changes : flags     Removes 4 bytes
; ---------------------------------------------------------------------
OtherEnemyAt:
        push    bp
        mov     bp, sp
        push    ax
        push    si
        xor     si, si
.next:
        cmp     si, ENEMY_COUNT * ENEMY_SIZE
        jae     .none
        cmp     si, [enemy_self]
        je      .skip
        cmp     byte [enemy_table + si + EN_TYPE], 0
        je      .skip
        mov     al, [enemy_table + si + EN_STATE]
        cmp     al, ES_WALK
        jb      .skip
        cmp     al, ES_FLAT
        je      .skip
        mov     al, [enemy_table + si + EN_Y]
        xor     ah, ah
        cmp     ax, [bp+4]
        jne     .skip
        mov     al, [enemy_table + si + EN_X + 1]
        xor     ah, ah
        cmp     ax, [bp+6]
        je      .found
.skip:
        add     si, ENEMY_SIZE
        jmp     .next
.none:
        clc
        jmp     .out
.found:
        stc
.out:
        pop     si
        pop     ax
        pop     bp
        ret     4

; ---------------------------------------------------------------------
; ShellKills
;   Purpose : the sliding shell (record BX) removes every enemy in its
;             row that it touches: +500 each.
; ---------------------------------------------------------------------
ShellKills:
        push    ax
        push    si
        xor     si, si
.next:
        cmp     si, ENEMY_COUNT * ENEMY_SIZE
        jae     .done
        cmp     si, bx
        je      .skip
        cmp     byte [enemy_table + si + EN_TYPE], 0
        je      .skip
        cmp     byte [enemy_table + si + EN_STATE], ES_WAIT
        je      .skip
        mov     al, [enemy_table + si + EN_Y]
        cmp     al, [enemy_table + bx + EN_Y]
        jne     .skip
        mov     ax, [enemy_table + bx + EN_X]
        sub     ax, [enemy_table + si + EN_X]
        jns     .abs
        neg     ax
.abs:
        cmp     ax, HIT_WIDTH
        jae     .skip
        mov     byte [enemy_table + si + EN_TYPE], 0    ; defeated
        SCORE   500
        SOUND   kick
.skip:
        add     si, ENEMY_SIZE
        jmp     .next
.done:
        pop     si
        pop     ax
        ret

; ---------------------------------------------------------------------
; HeroVsEnemies : Mario against every enemy (step 5 of the frame).
; ---------------------------------------------------------------------
HeroVsEnemies:
        push    bx
        xor     bx, bx
.next:
        cmp     bx, ENEMY_COUNT * ENEMY_SIZE
        jae     .done
        call    HeroVsOneEnemy
        add     bx, ENEMY_SIZE
        jmp     .next
.done:
        pop     bx
        ret

; ---------------------------------------------------------------------
; HeroVsOneEnemy
;   Purpose : apply the collision outcomes of the manual:
;     stomp walking Goomba  -> flat, chain points, bounce
;     stomp walking Koopa   -> shell, chain points, bounce
;     stomp sliding shell   -> stops, chain points, bounce
;     touch / stomp a still shell -> kick (+400), it slides away
;     side contact with a walking enemy or sliding shell -> HurtHero
;   Input   : BX = record offset        Changes : nothing
; ---------------------------------------------------------------------
HeroVsOneEnemy:
        SAVE_ALL
        cmp     byte [enemy_table + bx + EN_TYPE], 0
        je      .out
        mov     al, [enemy_table + bx + EN_STATE]
        cmp     al, ES_WAIT
        je      .out
        cmp     al, ES_FLAT
        je      .out
        push    word [enemy_table + bx + EN_X]
        call    HeroNear
        jnc     .out
        mov     al, [enemy_table + bx + EN_Y]
        xor     ah, ah
        push    ax
        call    StompOrHurt             ; AL = 0 / 1 stomp / 2 side
        cmp     al, 1
        je      .stomp
        cmp     al, 2
        je      .side
        jmp     .out
.stomp:
        cmp     byte [enemy_table + bx + EN_STATE], ES_SHELL_STILL
        je      .kick_by_stomp
        call    AwardStomp
        cmp     byte [enemy_table + bx + EN_STATE], ES_SHELL_SLIDE
        je      .to_still
        cmp     byte [enemy_table + bx + EN_TYPE], TYPE_KOOPA
        je      .to_still
        mov     byte [enemy_table + bx + EN_STATE], ES_FLAT     ; Goomba
        mov     byte [enemy_table + bx + EN_TIMER], FLAT_FRAMES
        jmp     .bounce
.to_still:
        mov     byte [enemy_table + bx + EN_STATE], ES_SHELL_STILL
        mov     byte [enemy_table + bx + EN_TIMER], KICK_GRACE
        jmp     .bounce
.kick_by_stomp:
        cmp     byte [enemy_table + bx + EN_TIMER], 0
        jne     .out
        call    KickShell
        jmp     .bounce
.bounce:
        call    BounceHero
        SOUND   stomp
        jmp     .out
.side:
        mov     al, [enemy_table + bx + EN_STATE]
        cmp     al, ES_SHELL_STILL
        je      .touch_still
        cmp     al, ES_SHELL_SLIDE
        jne     .hurt
        cmp     byte [enemy_table + bx + EN_TIMER], 0
        jne     .out                    ; just kicked: ignore Mario
.hurt:
        call    HurtHero
        jmp     .out
.touch_still:
        cmp     byte [enemy_table + bx + EN_TIMER], 0
        jne     .out
        call    KickShell
.out:
        RESTORE_ALL
        ret

; ---------------------------------------------------------------------
; KickShell : the shell (BX) slides away from Mario, +400.
; ---------------------------------------------------------------------
KickShell:
        push    ax
        mov     ax, [hero_x]
        cmp     ax, [enemy_table + bx + EN_X]
        mov     byte [enemy_table + bx + EN_DIR], 1     ; Mario on the left
        jb      .set
        mov     byte [enemy_table + bx + EN_DIR], 0
.set:
        mov     byte [enemy_table + bx + EN_STATE], ES_SHELL_SLIDE
        mov     word [enemy_table + bx + EN_SPEED], SHELL_SPEED
        mov     byte [enemy_table + bx + EN_TIMER], KICK_GRACE
        SCORE   400
        SOUND   kick
        pop     ax
        ret

; ---------------------------------------------------------------------
; AwardStomp
;   Purpose : stomp chain.  hero_chain indexes stomp_points (a word
;             table: 100,200,400,500,800,1000,2000,4000,5000,8000).
;             The 11th stomp in one jump (and later) gives a life.
; ---------------------------------------------------------------------
AwardStomp:
        push    ax
        push    dx
        push    si
        mov     al, [hero_chain]
        cmp     al, 10
        jae     .oneup
        xor     ah, ah
        add     ax, ax                  ; word table
        mov     si, ax
        mov     ax, [stomp_points + si]
        xor     dx, dx
        push    ax
        push    dx
        call    AddScore
        inc     byte [hero_chain]
        jmp     .out
.oneup:
        call    AddLife
.out:
        pop     si
        pop     dx
        pop     ax
        ret

; ---------------------------------------------------------------------
; BounceHero : Mario bounces up after a stomp (higher if Space held).
; ---------------------------------------------------------------------
BounceHero:
        mov     word [hero_vy], STOMP_BOUNCE
        cmp     byte [key_state + KEY_SPACE], 0
        je      .done
        mov     word [hero_vy], STOMP_BOUNCE_UP
.done:
        mov     byte [hero_on_ground], 0
        ret

;#####################################################################
;#  FILE: levelflow.asm
;#####################################################################
; =====================================================================
;  LEVELFLOW.asm  --  Module 15 : death, win, restart
;  Owner : Student 3
; =====================================================================

; ---------------------------------------------------------------------
; HurtHero
;   Purpose : an enemy hurt Mario (rules of section 5.7).
;             invulnerable : nothing
;             Super / Fire : becomes Small (HP 1), blinks for 2 seconds
;             Small        : dies
; ---------------------------------------------------------------------
HurtHero:
        cmp     byte [hero_invuln], 0
        jne     .done
        cmp     byte [hero_form], 0
        je      .die
        mov     byte [hero_form], 0
        mov     byte [hero_hp], 1
        mov     byte [hero_invuln], INVULN_FRAMES
        SOUND   hurt
        jmp     .done
.die:
        call    StartDeath
.done:
        ret

; ---------------------------------------------------------------------
; StartDeath
;   Purpose : begin the DYING state: controls, enemies and clock freeze,
;             Mario hops up ~3 rows and then falls (no hop for a pit).
; ---------------------------------------------------------------------
StartDeath:
        cmp     byte [game_state], STATE_DYING
        je      .done
        mov     byte [game_state], STATE_DYING
        mov     word [state_timer], DEATH_FRAMES
        mov     word [hero_vx], 0
        mov     word [hero_vy], JUMP_START
        mov     byte [hero_on_ground], 0
        mov     byte [hero_invuln], 0
        cmp     byte [hero_y + 1], PIT_ROW
        jb      .sound
        mov     word [hero_vy], 0               ; pit: just keep falling
        mov     word [state_timer], PIT_DEATH_FRAMES
.sound:
        SOUND   die
.done:
        ret

; ---------------------------------------------------------------------
; CheckEndConditions
;   Purpose : step 7 of the frame: pit, clock = 0 and flag pole.
; ---------------------------------------------------------------------
CheckEndConditions:
        cmp     byte [game_state], STATE_PLAYING
        jne     .done
        cmp     byte [hero_y + 1], PIT_ROW
        jae     .die
        cmp     word [time_left], 0
        je      .die
        call    CheckFlagPole
        jnc     .done
        call    StartWin
        jmp     .done
.die:
        call    StartDeath
.done:
        ret

; ---------------------------------------------------------------------
; StartWin
;   Purpose : Mario touched the pole: add the flag points (by the row
;             of his feet), freeze the clock, snap him to the pole.
;             feet row 15-16: 5000, 17: 2000, 18: 800, 19-20: 400,
;             21: 100.
; ---------------------------------------------------------------------
StartWin:
        push    ax
        mov     ax, 100
        cmp     byte [hero_y + 1], 21
        jae     .award
        mov     ax, 400
        cmp     byte [hero_y + 1], 19
        jae     .award
        mov     ax, 800
        cmp     byte [hero_y + 1], 18
        jae     .award
        mov     ax, 2000
        cmp     byte [hero_y + 1], 17
        jae     .award
        mov     ax, 5000
.award:
        push    ax
        PUSHI   0
        call    AddScore
        mov     byte [game_state], STATE_WIN
        mov     byte [win_phase], 0
        mov     word [hero_vx], 0
        mov     word [hero_vy], 0
        mov     byte [hero_x], 0                ; snap to the pole column
        mov     byte [hero_y], 0
        mov     byte [hero_on_ground], 1
        SOUND   flag
        pop     ax
        ret

; ---------------------------------------------------------------------
; StartLevelComplete
;   Purpose : bonus = time left x 50 (MUL), added to the score.
; ---------------------------------------------------------------------
StartLevelComplete:
        push    ax
        push    cx
        push    dx
        mov     ax, [time_left]
        mov     cx, 50
        mul     cx                      ; DX:AX = time * 50
        mov     [bonus_lo], ax
        mov     [bonus_hi], dx
        push    ax
        push    dx
        call    AddScore
        HOOK_HISCORE_SAVE
        mov     byte [game_state], STATE_LEVELDONE
        pop     dx
        pop     cx
        pop     ax
        ret

; ---------------------------------------------------------------------
; ResetLevel
;   Purpose : prepare the current level for a (new) life: map restored
;             from the original, enemies and items reset, camera 0,
;             clock 300, Mario Small at the start.  Score, coins and
;             lives are NOT touched.
; ---------------------------------------------------------------------
ResetLevel:
        push    ax
        call    ResetMap
        call    ResetEnemies
        call    ResetItems
        HOOK_FIRE_RESET
        HOOK_POPUP_RESET
        mov     word [camera_x], 0
        mov     ah, START_COL
        xor     al, al
        mov     [hero_x], ax
        mov     ah, START_ROW
        mov     [hero_y], ax
        mov     word [hero_vx], 0
        mov     word [hero_vy], 0
        mov     byte [hero_dir], 1
        mov     byte [hero_on_ground], 1
        mov     byte [hero_form], 0
        mov     byte [hero_hp], 1
        mov     byte [hero_invuln], 0
        mov     byte [hero_chain], 0
        mov     byte [hero_falling], 0
        mov     byte [jump_ready], 1
        mov     word [time_left], LEVEL_TIME
        mov     byte [sec_ticks], 0
        call    ClearKeyHits
        pop     ax
        ret

; ---------------------------------------------------------------------
; NewGame : score 0, coins 0, lives 3, level 1, then ResetLevel.
; ---------------------------------------------------------------------
NewGame:
        mov     word [score_lo], 0
        mov     word [score_hi], 0
        mov     word [coins], 0
        mov     word [lives], START_LIVES
        mov     byte [cur_level], 0
        call    ResetLevel
        mov     byte [game_state], STATE_PLAYING
        ret

;#####################################################################
;#  FILE: states.asm
;#####################################################################
; =====================================================================
;  STATES.ASM  --  Module 14 : game states, screens and menus
;  Owner : Student 3
;  game_state is an index into state_table (a table of procedures).
;  RunState calls the handler of the current state once per frame.
; =====================================================================
state_table:
        dw      st_title, st_playing, st_paused, st_dying
        dw      st_lifelost, st_win, st_leveldone, st_gameover
        dw      st_exit

str_title1      db "S U P E R   M A R I O   E N G I N E", 0
str_title2      db "A platform game in x86 Assembly (NASM + DOSBox)", 0
str_start       db "  START GAME  ", 0
str_exit        db "     EXIT     ", 0
str_team        db "Student 1: 25F-XXXX    Student 2: 25F-XXXX    Student 3: 25F-XXXX", 0
str_ctrl1       db "ARROWS = move    SHIFT = run    SPACE = jump (hold = higher)", 0
str_ctrl2       db "P = pause    ESC = back / exit    X = fire (Fire Mario)", 0
str_ctrl3       db "Menu: UP/DOWN + ENTER    Debug: F1 time=5  F2 coins=99  F3 skip", 0
str_paused      db "PAUSED", 0
str_paused2     db "P = resume   ESC = title", 0
str_lifelost1   db "LIFE LOST", 0
str_lifelost2   db "WORLD 1-", 0
str_complete    db "LEVEL  COMPLETE!", 0
str_cscore      db "SCORE", 0
str_ccoins      db "COINS", 0
str_ctime       db "TIME LEFT", 0
str_cbonus      db "TIME BONUS  (x 50)", 0
str_enter_title db "Press ENTER to return to the title", 0
str_enter_next  db "Press ENTER for the next level", 0
str_gameover    db "G A M E   O V E R", 0
str_final       db "FINAL SCORE", 0

; ---------------------------------------------------------------------
; RunState : jump through state_table (indexed jump).
; ---------------------------------------------------------------------
RunState:
        push    ax
        push    bx
        mov     bl, [game_state]
        xor     bh, bh
        add     bx, bx
        call    [state_table + bx]
        pop     bx
        pop     ax
        ret

; ---------------------------------------------------------------------
; DrawPlayfield : steps 9-10 of the frame: background, tiles, items,
;                 enemies, Mario, HUD (all into the frame buffer).
; ---------------------------------------------------------------------
DrawPlayfield:
        call    DrawMap
        HOOK_CLOUDS
        call    DrawItems
        call    DrawEnemies
        HOOK_FIRE_DRAW
        call    DrawHero
        HOOK_POPUP_DRAW
        call    DrawHUD
        ret

; ---------------------------------------------------------------------
; DebugKeys (listed in the README):  F1 time = 5 s, F2 coins = 99,
;           F3 jump to the end of the level.
; ---------------------------------------------------------------------
DebugKeys:
        push    ax
        IF_HIT  KEY_F1, .no_f1
        mov     word [time_left], 5
        mov     byte [sec_ticks], 0
.no_f1:
        IF_HIT  KEY_F2, .no_f2
        mov     word [coins], 99
.no_f2:
        IF_HIT  KEY_F3, .no_f3
        mov     word [camera_x], CAMERA_MAX
        mov     ah, 200
        xor     al, al
        mov     [hero_x], ax
        mov     word [hero_vx], 0
.no_f3:
        pop     ax
        ret

; ---------------------------------------------------------------------
; st_playing : one PLAYING frame, in the order of section 5.13.
; ---------------------------------------------------------------------
st_playing:
        push    ax
        IF_HIT  KEY_ESC, .no_esc
        mov     byte [game_state], STATE_TITLE
        jmp     .out
.no_esc:
        IF_HIT  KEY_P, .no_pause
        mov     byte [game_state], STATE_PAUSED
        jmp     .out
.no_pause:
        call    DebugKeys
        call    UpdateHero              ; 3. Mario
        call    UpdateEnemies           ; 4. enemies, shells, mushrooms
        call    UpdateItems
        HOOK_FIRE_INPUT
        HOOK_FIRE_UPDATE
        call    CollectMapCoins         ; 5. resolve Mario against things
        call    HeroVsItems
        call    HeroVsEnemies
        call    UpdateClock             ; 6. clock and invulnerability
        cmp     byte [hero_invuln], 0
        je      .no_inv
        dec     byte [hero_invuln]
.no_inv:
        HOOK_POPUP_UPDATE
        call    CheckEndConditions      ; 7. death and flag pole
        call    UpdateCamera            ; 8. camera
        call    DrawPlayfield           ; 9-10. draw
.out:
        pop     ax
        ret

; ---------------------------------------------------------------------
; st_paused : frozen picture with "PAUSED" on it.
; ---------------------------------------------------------------------
st_paused:
        push    ax
        IF_HIT  KEY_ESC, .no_esc
        mov     byte [game_state], STATE_TITLE
        jmp     .out
.no_esc:
        IF_HIT  KEY_P, .still
        mov     byte [game_state], STATE_PLAYING
        jmp     .out
.still:
        FILL    26, 9, 28, 5, ' ', ATTR_SCREEN
        BOX     26, 9, 28, 5, ATTR_BORDER
        TEXT    37, 10, ATTR_TITLE, str_paused
        TEXT    28, 12, ATTR_TEXT, str_paused2
.out:
        pop     ax
        ret

; ---------------------------------------------------------------------
; st_title : title screen with the START GAME / EXIT menu.
; ---------------------------------------------------------------------
st_title:
        push    ax
        push    bx
        IF_HIT  KEY_UP, .no_up
        mov     byte [menu_sel], 0
.no_up:
        IF_HIT  KEY_DOWN, .no_down
        mov     byte [menu_sel], 1
.no_down:
        IF_HIT  KEY_ESC, .no_esc
        mov     byte [game_state], STATE_EXIT
        jmp     .out
.no_esc:
        IF_HIT  KEY_ENTER, .draw
        cmp     byte [menu_sel], 0
        jne     .exit
        call    NewGame
        jmp     .out
.exit:
        mov     byte [game_state], STATE_EXIT
        jmp     .out
.draw:
        CLEAR   ' ', ATTR_SCREEN
        BOX     4, 1, 72, 23, ATTR_BORDER
        TEXT    22, 4, ATTR_TITLE, str_title1
        TEXT    17, 6, ATTR_TEXT, str_title2
        mov     ax, ATTR_MENU_OFF
        mov     bx, ATTR_MENU_OFF
        cmp     byte [menu_sel], 0
        jne     .sel_done
        mov     ax, ATTR_MENU_ON
        jmp     .menu
.sel_done:
        mov     bx, ATTR_MENU_ON
.menu:
        call    DrawMenu
.out:
        pop     bx
        pop     ax
        ret

; DrawMenu : AX = attribute of START GAME, BX = attribute of EXIT,
;            then team names, controls and high score.
DrawMenu:
        push    ax
        push    bx
        push    cx
        push    dx
        mov     cx, ax                  ; keep the attributes
        mov     dx, bx
        PUSHI   33
        PUSHI   11
        push    cx
        PUSHI   str_start
        call    DrawString
        PUSHI   33
        PUSHI   13
        push    dx
        PUSHI   str_exit
        call    DrawString
        TEXT    7, 17, ATTR_TEXT, str_team
        TEXT    10, 19, ATTR_TEXT, str_ctrl1
        TEXT    10, 20, ATTR_TEXT, str_ctrl2
        TEXT    9, 21, ATTR_TEXT, str_ctrl3
        HOOK_HISCORE_DRAW 32, 15
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret

; ---------------------------------------------------------------------
; st_dying : death animation (no collisions), then lives - 1.
; ---------------------------------------------------------------------
st_dying:
        push    ax
        call    DrawPlayfield
        mov     ax, [hero_vy]
        add     ax, GRAVITY
        cmp     ax, MAX_FALL
        jle     .store
        mov     ax, MAX_FALL
.store:
        mov     [hero_vy], ax
        add     [hero_y], ax            ; no tile collision while dying
        dec     word [state_timer]
        jnz     .out
        dec     word [lives]
        jz      .gameover
        mov     byte [game_state], STATE_LIFELOST
        mov     word [state_timer], LIFELOST_FRAMES
        jmp     .out
.gameover:
        HOOK_HISCORE_SAVE
        mov     byte [game_state], STATE_GAMEOVER
.out:
        pop     ax
        ret

; ---------------------------------------------------------------------
; st_lifelost : "LIFE LOST" screen for about 2 seconds, then the level
;               restarts (map, enemies, clock, camera, Mario).
; ---------------------------------------------------------------------
st_lifelost:
        push    ax
        push    bx
        push    cx
        CLEAR   ' ', 07h
        TEXT    35, 8, 0Ch, str_lifelost1
        TEXT    33, 10, 0Fh, str_lifelost2
        mov     al, [cur_level]
        add     al, '1'
        xor     ah, ah
        mov     bx, 41
        mov     cx, 10
        PCELL   bx, cx, ax, 0Fh
        mov     bx, 35
        mov     cx, 13
        PCELL   bx, cx, GLYPH_STAND, 0Ch
        mov     bx, 37
        PCELL   bx, cx, 'x', 0Fh
        NUMBER  [lives], 0, 2, 39, 13, 0Fh
        dec     word [state_timer]
        jnz     .out
        call    ResetLevel
        mov     byte [game_state], STATE_PLAYING
.out:
        pop     cx
        pop     bx
        pop     ax
        ret

; ---------------------------------------------------------------------
; st_win : Mario slides down the pole (1 row per 2 frames), waits about
;          one second, then the Level Complete screen.
; ---------------------------------------------------------------------
st_win:
        push    ax
        push    bx
        call    DrawPlayfield
        cmp     byte [win_phase], 0
        jne     .wait
        test    byte [frame_count], 1
        jnz     .out
        mov     al, [hero_x + 1]
        xor     ah, ah
        mov     bl, [hero_y + 1]
        xor     bh, bh
        inc     bx
        GETTILE ax, bx
        call    IsSolid
        jc      .landed
        add     word [hero_y], 100h     ; one row down
        jmp     .out
.landed:
        mov     byte [win_phase], 1
        mov     word [state_timer], WIN_WAIT_FRAMES
        jmp     .out
.wait:
        dec     word [state_timer]
        jnz     .out
        call    StartLevelComplete
.out:
        pop     bx
        pop     ax
        ret

; ---------------------------------------------------------------------
; st_leveldone : Level Complete screen (score, coins, time bonus).
;                ENTER -> title (BONUS 3: level 1 -> level 2).
; ---------------------------------------------------------------------
st_leveldone:
        push    ax
        IF_HIT  KEY_ENTER, .draw
        mov     byte [game_state], STATE_TITLE
; ===== BONUS 3 : after level 1 go on to level 2 ======================
%ifdef BONUS_LEVEL2
        cmp     byte [cur_level], 0
        jne     .out
        mov     byte [cur_level], 1
        call    ResetLevel
        mov     byte [game_state], STATE_PLAYING
%endif
; ===== END BONUS 3 ===================================================
        jmp     .out
.draw:
        CLEAR   ' ', ATTR_SCREEN
        BOX     18, 3, 44, 19, ATTR_BORDER
        TEXT    32, 5, 0Ah, str_complete
        TEXT    26, 9, ATTR_TEXT, str_cscore
        NUMBER  [score_lo], [score_hi], 6, 46, 9, ATTR_TITLE
        TEXT    26, 11, ATTR_TEXT, str_ccoins
        NUMBER  [coins], 0, 2, 52, 11, ATTR_TEXT
        TEXT    26, 13, ATTR_TEXT, str_ctime
        NUMBER  [time_left], 0, 3, 51, 13, ATTR_TEXT
        TEXT    26, 15, ATTR_TEXT, str_cbonus
        NUMBER  [bonus_lo], [bonus_hi], 6, 46, 15, ATTR_TITLE
%ifdef BONUS_LEVEL2
        cmp     byte [cur_level], 0
        jne     .prompt_title
        TEXT    24, 19, ATTR_TEXT, str_enter_next
        jmp     .out
%endif
.prompt_title:
        TEXT    22, 19, ATTR_TEXT, str_enter_title
.out:
        pop     ax
        ret

; ---------------------------------------------------------------------
; st_gameover : Game Over screen with the final score.
; ---------------------------------------------------------------------
st_gameover:
        push    ax
        IF_HIT  KEY_ENTER, .draw
        mov     byte [game_state], STATE_TITLE
        jmp     .out
.draw:
        CLEAR   ' ', ATTR_SCREEN
        BOX     20, 5, 40, 14, 0Ch
        TEXT    32, 8, 0Ch, str_gameover
        TEXT    35, 11, ATTR_TEXT, str_final
        NUMBER  [score_lo], [score_hi], 6, 37, 13, ATTR_TITLE
        TEXT    22, 16, ATTR_TEXT, str_enter_title
.out:
        pop     ax
        ret

; st_exit : never runs (main loop leaves when the state is EXIT).
st_exit:
        ret

;#####################################################################
;#  FILE: bonus_fire.asm
;#####################################################################
; =====================================================================
;  BONUS_FIRE.ASM  --  BONUS 5 : Fire flower and fireballs
;  Owner : Student 3
;  To remove: comment out  %define BONUS_FIRE  in config.asm.
;  A "?" mushroom block gives a Fire flower when Mario is already
;  Super.  Fire Mario (form 2) shoots fireballs with the X key.  A
;  fireball flies straight, is stopped by walls and defeats any enemy
;  it touches (+100).  At most two fireballs exist at the same time.
; =====================================================================
%ifdef BONUS_FIRE
FB_COUNT        equ 2
FB_SIZE         equ 6
FB_ACTIVE       equ 0
FB_X            equ 1                   ; word, 8.8
FB_Y            equ 3                   ; row
FB_DIR          equ 4                   ; 0 = left, 1 = right
fire_table      times FB_COUNT*FB_SIZE db 0

; ResetFireballs : remove all fireballs.
ResetFireballs:
        push    bx
        xor     bx, bx
.clear:
        mov     byte [fire_table + bx], 0
        inc     bx
        cmp     bx, FB_COUNT * FB_SIZE
        jb      .clear
        pop     bx
        ret

; ---------------------------------------------------------------------
; FireInput : X pressed while Fire Mario -> launch a fireball.
; ---------------------------------------------------------------------
FireInput:
        push    ax
        push    bx
        IF_HIT  KEY_X, .out
        cmp     byte [hero_form], 2
        jne     .out
        xor     bx, bx
.find:
        cmp     bx, FB_COUNT * FB_SIZE
        jae     .out                    ; both fireballs in use
        cmp     byte [fire_table + bx + FB_ACTIVE], 0
        je      .use
        add     bx, FB_SIZE
        jmp     .find
.use:
        mov     ax, [hero_x]
        cmp     byte [hero_dir], 0
        je      .left
        add     ax, 100h                ; start one cell in front of Mario
        jmp     .place
.left:
        sub     ax, 100h
        cmp     ax, 0F000h
        jae     .out
.place:
        mov     [fire_table + bx + FB_X], ax
        mov     al, [hero_y + 1]
        mov     [fire_table + bx + FB_Y], al
        mov     al, [hero_dir]
        mov     [fire_table + bx + FB_DIR], al
        mov     byte [fire_table + bx + FB_ACTIVE], 1
        SOUND   fire
.out:
        pop     bx
        pop     ax
        ret

; ---------------------------------------------------------------------
; UpdateFireballs : move fireballs, stop at walls / screen edges and
;                   defeat enemies they touch.
; ---------------------------------------------------------------------
UpdateFireballs:
        push    bx
        xor     bx, bx
.next:
        cmp     bx, FB_COUNT * FB_SIZE
        jae     .done
        call    UpdateOneFireball
        add     bx, FB_SIZE
        jmp     .next
.done:
        pop     bx
        ret

UpdateOneFireball:                      ; BX = record offset
        push    ax
        push    cx
        push    dx
        push    si
        cmp     byte [fire_table + bx + FB_ACTIVE], 0
        je      .out
        mov     ax, [fire_table + bx + FB_X]
        cmp     byte [fire_table + bx + FB_DIR], 0
        je      .left
        add     ax, FIRE_SPEED
        jmp     .moved
.left:
        sub     ax, FIRE_SPEED
.moved:
        cmp     ax, 0F000h
        jae     .kill_fb
        mov     dl, ah
        xor     dh, dh                  ; DX = new column
        cmp     dx, [camera_x]
        jb      .kill_fb                ; left the screen
        mov     cx, [camera_x]
        add     cx, SCREEN_COLS
        cmp     dx, cx
        jae     .kill_fb                ; right of the screen
        mov     cl, [fire_table + bx + FB_Y]
        xor     ch, ch
        push    ax
        GETTILE dx, cx
        call    IsSolid
        pop     ax
        jc      .kill_fb                ; wall
        mov     [fire_table + bx + FB_X], ax
        ; --- hit an enemy? ---
        xor     si, si
.enemy:
        cmp     si, ENEMY_COUNT * ENEMY_SIZE
        jae     .out
        cmp     byte [enemy_table + si + EN_TYPE], 0
        je      .skip
        cmp     byte [enemy_table + si + EN_STATE], ES_WAIT
        je      .skip
        mov     al, [enemy_table + si + EN_Y]
        cmp     al, [fire_table + bx + FB_Y]
        jne     .skip
        mov     ax, [fire_table + bx + FB_X]
        sub     ax, [enemy_table + si + EN_X]
        jns     .abs
        neg     ax
.abs:
        cmp     ax, HIT_WIDTH
        jae     .skip
        mov     byte [enemy_table + si + EN_TYPE], 0
        SCORE   100
        SOUND   kick
        jmp     .kill_fb
.skip:
        add     si, ENEMY_SIZE
        jmp     .enemy
.kill_fb:
        mov     byte [fire_table + bx + FB_ACTIVE], 0
.out:
        pop     si
        pop     dx
        pop     cx
        pop     ax
        ret

; ---------------------------------------------------------------------
; DrawFireballs
; ---------------------------------------------------------------------
DrawFireballs:
        SAVE_ALL
        xor     bx, bx
.next:
        cmp     bx, FB_COUNT * FB_SIZE
        jae     .done
        cmp     byte [fire_table + bx + FB_ACTIVE], 0
        je      .skip
        mov     al, [fire_table + bx + FB_X + 1]
        xor     ah, ah
        sub     ax, [camera_x]
        mov     si, ax
        mov     al, [fire_table + bx + FB_Y]
        xor     ah, ah
        mov     di, ax
        DRAWSPR si, di, GLYPH_FIREBALL, FG_FIREBALL
.skip:
        add     bx, FB_SIZE
        jmp     .next
.done:
        RESTORE_ALL
        ret
%endif

;#####################################################################
;#  FILE: bonus_popups.asm
;#####################################################################
; =====================================================================
;  BONUS_POPUPS.ASM  --  BONUS 6 : score pop-ups above Mario
;  Owner : Student 3
;  To remove: comment out  %define BONUS_POPUPS  in config.asm.
;  Every AddScore call creates a small floating number above Mario
;  that rises for about one second.
; =====================================================================
%ifdef BONUS_POPUPS
PO_COUNT        equ 4
PO_SIZE         equ 6
PO_TIMER        equ 0                   ; frames left (0 = free)
PO_X            equ 1                   ; world column
PO_Y            equ 2                   ; row
PO_VAL          equ 3                   ; word, points
popup_table     times PO_COUNT*PO_SIZE db 0

ResetPopups:
        push    bx
        xor     bx, bx
.clear:
        mov     byte [popup_table + bx], 0
        inc     bx
        cmp     bx, PO_COUNT * PO_SIZE
        jb      .clear
        pop     bx
        ret

; ---------------------------------------------------------------------
; SpawnPopup
;   Purpose : new pop-up above Mario.   Input : AX = points
;   Changes : nothing
; ---------------------------------------------------------------------
SpawnPopup:
        push    bx
        push    cx
        xor     bx, bx
.find:
        cmp     bx, PO_COUNT * PO_SIZE
        jae     .steal
        cmp     byte [popup_table + bx + PO_TIMER], 0
        je      .use
        add     bx, PO_SIZE
        jmp     .find
.steal:
        xor     bx, bx                  ; table full: reuse the first slot
.use:
        mov     byte [popup_table + bx + PO_TIMER], POPUP_FRAMES
        mov     cl, [hero_x + 1]
        mov     [popup_table + bx + PO_X], cl
        mov     cl, [hero_y + 1]
        sub     cl, 2                   ; above the head
        cmp     cl, 3
        jae     .row_ok
        mov     cl, 3
.row_ok:
        mov     [popup_table + bx + PO_Y], cl
        mov     [popup_table + bx + PO_VAL], ax
        pop     cx
        pop     bx
        ret

; UpdatePopups : count down; rise one row every 4 frames.
UpdatePopups:
        push    bx
        xor     bx, bx
.next:
        cmp     bx, PO_COUNT * PO_SIZE
        jae     .done
        cmp     byte [popup_table + bx + PO_TIMER], 0
        je      .skip
        dec     byte [popup_table + bx + PO_TIMER]
        test    byte [popup_table + bx + PO_TIMER], 3
        jnz     .skip
        cmp     byte [popup_table + bx + PO_Y], 3
        jbe     .skip
        dec     byte [popup_table + bx + PO_Y]
.skip:
        add     bx, PO_SIZE
        jmp     .next
.done:
        pop     bx
        ret

; DrawPopups : the number is printed with 2, 3 or 4 digits.
DrawPopups:
        SAVE_ALL
        xor     bx, bx
.next:
        cmp     bx, PO_COUNT * PO_SIZE
        jae     .done
        cmp     byte [popup_table + bx + PO_TIMER], 0
        je      .skip
        mov     al, [popup_table + bx + PO_X]
        xor     ah, ah
        sub     ax, [camera_x]
        mov     si, ax                  ; screen column
        mov     al, [popup_table + bx + PO_Y]
        xor     ah, ah
        mov     di, ax                  ; row
        mov     cx, 2                   ; number of digits
        cmp     word [popup_table + bx + PO_VAL], 100
        jb      .have_digits
        mov     cx, 3
        cmp     word [popup_table + bx + PO_VAL], 1000
        jb      .have_digits
        mov     cx, 4
.have_digits:
        mov     dx, [popup_table + bx + PO_VAL]
        mov     ax, dx
        push    ax                      ; lo
        PUSHI   0                       ; hi
        push    cx
        push    si
        push    di
        PUSHI   ATTR_POPUP
        call    PrintNum32
.skip:
        add     bx, PO_SIZE
        jmp     .next
.done:
        RESTORE_ALL
        ret
%endif


; =====================================================================
;  Program start and main loop
; =====================================================================
start:
        call    SetTextMode
        call    InitTileTable
        HOOK_HISCORE_LOAD
        call    InstallKeyboard
        call    InstallTimer
        mov     byte [game_state], STATE_TITLE
        mov     ax, [tick_count]
        mov     [last_tick], ax

main_loop:
        call    WaitForTick             ; 1. one frame per timer tick
        inc     byte [frame_count]
        call    RunState                ; the current state does its frame
        call    FlipBuffer              ; show the finished picture
        HOOK_SOUND_UPDATE
        cmp     byte [game_state], STATE_EXIT
        jne     main_loop

; ---- clean exit: restore everything ----
        call    RestoreTimer
        call    RestoreKeyboard
        HOOK_SOUND_OFF
        mov     ax, 0003h               ; text mode again
        int     10h
        mov     ax, 4C00h               ; back to DOS
        int     21h

; =====================================================================
;  Uninitialised memory (not stored in MARIO.COM)
; =====================================================================
section .bss
map_work        resb MAP_SIZE           ; working copy of the level
screen_buf      resb SCREEN_CELLS * 2   ; off-screen frame buffer
