/**	

      STRUCTURE of "rowStreamAddress"
      =====================================

	dw 1				; 	Size of row list

	dw 11				; 	Row Id
	db 2				; 	Size of this row pair (top,bottom) list
	dw 32, 64, 8, 16	;	
						;	TargetId	= 1
						;	TilePairId	= 1 [1*(8*4 Patterns + 8*4 Colors)]
						; 		BottomId	= 1
						;		TopId		= 2		
	dw 0, 128, 16, 8		;	
						;	TargetId	= 0
						;	TilePairId	= 2 [2*(8*4 Patterns + 8*4 Colors)]
						; 		BottomId	= 2
						;		TopId		= 1		


*/
IFNDEF	RowStreamTileVShift2P_MODULE

		DEFINE      RowStreamTileVShift2P_MODULE

		MODULE      RowStreamTileVShift2P

            INCLUDE     "TileVShift2P.asm"


/*
      PROCESO
      El espaciado en  "tilePairBaseAddress" es de 64 bytes (32 para patterns y 32 para colors)
      En cada ciclo de "map" sólo se procesa o bien "patterns" o bien "colors"
      Por tanto hacen falta dos ciclos de "map":

            1.- (hl, iy, bc) = (
                  rowStreamAddress, 
                  targetTilePairBaseAddress, 
                  patternSourceTilesBaseAddress
            )
            2.- (hl, iy, bc) = (
                  rowStreamAddress, 
                  targetTilePairBaseAddress + 32, 
                  colorSourceTilesBaseAddress
            )
      Tras los dos ciclos tenemos en "targetTilePairBaseAddress":
            # 32 * n          --> Tile pair "n" patters
            # 32 * (n + 1)    --> Tile pair "n" colors

	PARAMS_IN
	hl --> rowStreamAddress
	iy --> targetTilePairBaseAddress
	de --> sourceTilesBaseAddress

*/
map
            LD      c,(hl) 
            INC     hl 
            LD      b,(hl) 
            ;       BC <-- RowSize
            INC     hl 
.ROWLOOP             
            PUSH    bc 

            INC     hl 
            INC     hl 
            LD      a,(hl) 
            ;       A <-- TileSet size for this Row
            INC     hl 
.TILELOOP            
            PUSH    af 

            INC     hl 
            INC     hl 
            LD      c,(hl) 
            INC     hl 
            LD      b,(hl) 
            ;       BC <-- TileId Offset Address
            PUSH    iy 
            ADD     iy,bc 
            INC     hl 
            LD      c,(hl) 
            INC     hl 
            LD      b,(hl) 
            INC     hl 
            ;       BC <-- Tile Bottom Offset Address
            PUSH    hl 
            LD      l,c 
            LD      h,b 
            ADD     hl,de 
            ;       HL -> Source Bottom Tile memory address
            ;       IY -> Target memory address
            CALL    TileVShift2P.verticalBottomShift2Pixels 
            POP     hl 
            LD      c,(hl) 
            INC     hl 
            LD      b,(hl) 
            ;       BC -> PairId memory offset
            INC     hl 
            PUSH    hl 
            PUSH    bc 
            POP     hl 
            ADD     hl,de 
            ;       HL -> Source Top Tile memory address
            ;       IY -> Target memory address
            CALL    TileVShift2P.verticalTopShift2Pixels 
            POP     hl 
            POP     iy 
            POP     af 
            DEC     a 
            JR      nz, .TILELOOP 

            POP     bc 
            DEC     bc 
            LD      a,b 
            OR      c 
            JR      nz, .ROWLOOP 

            RET      

		ENDMODULE

ENDIF