
IFNDEF	RowStreamTileAddress_MODULE

		DEFINE	RowStreamTileAddress_MODULE

		MODULE RowStreamTileAddress

        DEFINE  TILE_SHIFTED_SIZE                   $20
        DEFINE  ROWID_TILE_SET_SIZE                 $08

        DEFINE  IX_RS_SIZE_LSB                      ix + 0 
        DEFINE  IX_RS_SIZE_MSB                      ix + 1 

        DEFINE  IX_RS_ROWID_SIZE                    ix + 0 

        DEFINE  IX_RS_VRAM_PATTERN_OFFSET_LSB       ix + 0 
        DEFINE  IX_RS_VRAM_PATTERN_OFFSET_MSB       ix + 1 
        DEFINE  IX_RS_CPU_PATTERN_OFFSET_LSB        ix + 2 
        DEFINE  IX_RS_CPU_PATTERN_OFFSET_MSB        ix + 3 

        DEFINE  IX_RS_VRAM_PATTERN_LSB              ix + 0 
        DEFINE  IX_RS_VRAM_PATTERN_MSB              ix + 1 
        DEFINE  IX_RS_CPU_PATTERN_LSB               ix + 2 
        DEFINE  IX_RS_CPU_PATTERN_MSB               ix + 3 

        DEFINE  IX_RS_VRAM_COLOR_LSB                ix + 4 
        DEFINE  IX_RS_VRAM_COLOR_MSB                ix + 5 
        DEFINE  IX_RS_CPU_COLOR_LSB                 ix + 6 
        DEFINE  IX_RS_CPU_COLOR_MSB                 ix + 7 

; 
;	ix --> SOURCE rowStreamSourceAddress
;	iy --> TARGET CPU RAM PairId Base Address
;	de --> TARGET VDP VRAM Patterns Base Address
;   bc --> TARGET VDP VRAM Colors Base Address
; 
remap                 
            ;       HL <-- RowStream Size
            LD      l, (IX_RS_SIZE_LSB) 
            LD      h, (IX_RS_SIZE_MSB) 
            INC     ix
            INC     ix
row_loop
            INC     ix
            INC     ix
            PUSH    hl
            ;       A <-- TileSet size for this Row
            LD      a, (IX_RS_ROWID_SIZE) 
            INC     ix
tile_loop      
            PUSH    af 
            PUSH    iy

            ;       HL <-- VPA VRAM Target Tile pattern Offset address
            LD      l, (IX_RS_VRAM_PATTERN_OFFSET_LSB)
            LD      h, (IX_RS_VRAM_PATTERN_OFFSET_MSB)
            PUSH    hl
            ;       HL <-- VDP VRAM tile pattern address for this TargetId
            ADD     hl, de
            LD      (IX_RS_VRAM_PATTERN_LSB), l
            LD      (IX_RS_VRAM_PATTERN_MSB), h
            POP     hl
            ADD     hl, bc
            ;       HL <-- VDP VRAM tile colors address for this TargetId
            LD      (IX_RS_VRAM_COLOR_LSB), l
            LD      (IX_RS_VRAM_COLOR_MSB), h
            PUSH    bc
            ;       BC <-- CPU RAM TilePairId Pattern Offset Memory 
            LD      c, (IX_RS_CPU_PATTERN_OFFSET_LSB) 
            LD      b, (IX_RS_CPU_PATTERN_OFFSET_MSB) 
            ;       iy <-- CPU RAM TilePairId Pattern Address
            ADD     iy, bc
            LD      a, iyl
            LD      (IX_RS_CPU_PATTERN_LSB), a
            LD      a, iyh
            LD      (IX_RS_CPU_PATTERN_MSB), a
            ;       ?? <-- VDP VRAM tile pattern address for this TargetId
            LD      bc, TILE_SHIFTED_SIZE
            ;       iy <-- VDP VRAM tile pattern colors for this TargetId
            ADD     iy, bc
            LD      a, iyl
            LD      (IX_RS_CPU_COLOR_LSB), a
            LD      a, iyh
            LD      (IX_RS_CPU_COLOR_MSB), a
            LD      bc, ROWID_TILE_SET_SIZE
            ADD     ix, bc
            POP     bc

            POP     iy
            POP     af 
            DEC     a 
            JR      nz, tile_loop 

            POP     hl
            DEC     hl 
            LD      a,l 
            OR      h 
            JR      nz, row_loop 
            
            RET      

		ENDMODULE

ENDIF