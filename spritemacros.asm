;1 - Metasprite address
SpriteUpdate: MACRO
	ld a, [\1 + METASPRITE_ATR]
	or a
	jr z, .noflip\@
.flip\@
	SpriteUpdateFlip \1
	jr .end\@
.noflip\@
	SpriteUpdateNoFlip \1
.end\@
	ENDM
	
;1 - Metasprite address
SpriteUpdateNoFlip: MACRO
	ld a, [\1 + METASPRITE_W]
	ld b, a
	ld a, [\1 + METASPRITE_H]
	ld c, a
	ld hl, OAMBuf
	ld a, [\1 + METASPRITE_X]
	ld d, a
	ld a, [\1 + METASPRITE_Y]
	ld e, a
	ld a, [\1 + METASPRITE_START_TILE]
	ld [SPRITE_COUNTER], a
.loop\@
	ld a, e
	ld [HLI], a
	ld a, d
	ld [HLI], a
	ld a, SPRITE_SIZE
	add a, d
	ld d, a
	ld a, [SPRITE_COUNTER]
	ld [HLI], a
	inc a
	ld [SPRITE_COUNTER], a
	ld a, [\1 + METASPRITE_ATR]
	ld [HLI], a
	dec b
	jr z, .nextrow\@
	jr .loop\@
.nextrow\@
	ld a, SPRITE_SIZE
	add a, e
	ld e, a
	ld a, [\1 + METASPRITE_X]
	ld d, a
	ld a, [\1 + METASPRITE_W]
	ld b, a
	dec c
	jr z, .end\@
	jr .loop\@
.end\@
	ENDM
	
;1 - Metasprite address
SpriteUpdateFlip: MACRO
	ld a, [\1 + METASPRITE_START_TILE]
	ld b, a
	ld a, [\1 + METASPRITE_W]
	dec a
	add a, b
	ld [SPRITE_COUNTER], a
	ld a, [\1 + METASPRITE_W]
	ld b, a
	ld a, [\1 + METASPRITE_H]
	ld c, a
	ld hl, OAMBuf
	ld a, [\1 + METASPRITE_X]
	ld d, a
	ld a, [\1 + METASPRITE_Y]
	ld e, a
.loop\@
	ld a, e
	ld [HLI], a
	ld a, d
	ld [HLI], a
	ld a, SPRITE_SIZE
	add a, d
	ld d, a
	ld a, [SPRITE_COUNTER]
	ld [HLI], a
	dec a
	ld [SPRITE_COUNTER], a
	ld a, [\1 + METASPRITE_ATR]
	ld [HLI], a
	dec b
	jr z, .nextrow\@
	jr .loop\@
.nextrow\@
	ld a, SPRITE_SIZE
	add a, e
	ld e, a
	ld a, [\1 + METASPRITE_X]
	ld d, a
	ld a, [\1 + METASPRITE_W]
	ld b, a
	ld a, [SPRITE_COUNTER]
	add a, 6
	ld [SPRITE_COUNTER], a
	dec c
	jr z, .end\@
	jr .loop\@
.end\@
	ENDM

;1 - Metasprite address
;2 - Animation data address
;3 - Animation start
;4 - Animation end
;5 - Animation id
;a - 2 for no change, 1 for flipped, 0 for non-flipped
SpriteAnimStart: MACRO
	cp a, 2
	jr z, .cont\@
	or a
	jr z, .noflip\@
.flip\@
	ld a, OAMF_XFLIP
	ld [SPRITE_PLAYER + METASPRITE_ATR], a
	jr .cont\@
.noflip\@
	xor a
	ld [SPRITE_PLAYER + METASPRITE_ATR], a
.cont\@
	ld a, \3
	ld b, a
	ld a, \4
	ld c, a
	ld a, \5
	ld d, a
	ld a, [\2 + ANIM_ID]
	cp d
	jr z, .same\@
	ld a, d
	ld [\2 + ANIM_ID], a
	ld a, b
	ld [\2 + ANIM_START], a
	ld [\1 + METASPRITE_START_TILE], a
	ld a, c
	ld [\2 + ANIM_END], a
.same\@
	ENDM

;1 - Animation data address
;2 - Metasprite address
SpriteAnim: MACRO
	ld a, [\1 + ANIM_COUNTER]
	inc a
	cp ANIM_RATE
	jr z, .nextframe\@
	ld [\1 + ANIM_COUNTER], a
	jr .end\@
.nextframe\@
	xor a
	ld [\1 + ANIM_COUNTER], a
	ld a, [\1 + ANIM_END]
	ld b, a
	ld a, [\2 + METASPRITE_START_TILE]
	cp b
	jr z, .reset\@
	ld b, a
	ld a, [\2 + METASPRITE_WxH]
	add a, b
	ld [\2 + METASPRITE_START_TILE], a
	jr .end\@
.reset\@
	ld a, [\1 + ANIM_START]
	ld [\2 + METASPRITE_START_TILE], a
.end\@
	ENDM

PlayerWalkRightAnim: MACRO
	xor a
	SpriteAnimStart SPRITE_PLAYER, PLAYER_ANIM, PLAYER_ANIM_WALK_START, PLAYER_ANIM_WALK_END, PLAYER_ANIM_WALK
	ENDM
	
PlayerWalkLeftAnim: MACRO
	ld a, 1
	SpriteAnimStart SPRITE_PLAYER, PLAYER_ANIM, PLAYER_ANIM_WALK_START, PLAYER_ANIM_WALK_END, PLAYER_ANIM_WALK
	ENDM
	
PlayerIdleAnim: MACRO
	ld a, 2
	SpriteAnimStart SPRITE_PLAYER, PLAYER_ANIM, PLAYER_ANIM_IDLE_START, PLAYER_ANIM_IDLE_END, PLAYER_ANIM_IDLE
	ENDM
	
PlayerJumpAnim: MACRO
	ld a, 2
	SpriteAnimStart SPRITE_PLAYER, PLAYER_ANIM, PLAYER_ANIM_JUMP_START, PLAYER_ANIM_JUMP_END, PLAYER_ANIM_JUMP
	ENDM
	
;in: b - x movement
;    c - y movement
;1 - Metasprite address
	
SpriteMove: MACRO
	ld a, b
	or a
	jr z, .ymove\@
	bit 7, a
	jr z, .xadd\@
	jr .xsub\@
.xadd\@
	res 7, a
	ld b, a
	ld a, [\1 + METASPRITE_X]
	add a, b
	ld [\1 + METASPRITE_X], a
	jr .ymove\@
.xsub\@
	res 7, a
	ld b, a
	ld a, [\1 + METASPRITE_X]
	sub a, b
	ld [\1 + METASPRITE_X], a
.ymove\@
	ld a, c
	or a
	jr z, .end\@
	bit 7, a
	jr z, .yadd\@
	jr .ysub\@
.yadd\@
	res 7, a
	ld c, a
	ld a, [\1 + METASPRITE_Y]
	add a, c
	ld [\1 + METASPRITE_Y], a
	jr .end\@
.ysub\@
	res 7, a
	ld c, a
	ld a, [\1 + METASPRITE_Y]
	sub a, c
	ld [\1 + METASPRITE_Y], a
.end\@
	ENDM