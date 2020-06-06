
IFNDEF	RowStreamTileToVDP_MODULE

		DEFINE	RowStreamTileToVDP_MODULE

		INCLUDE "Bios.asm"

		MODULE RowStreamTileToVdp

		STRUCT	RowStreamTileToVdp_FIELDS
BANK_FACTOR						# 1		; 
ROW_OFFSET						# 1		; 
CURRENT_ROW_ID					# 2		; 
ROWSTREAM_ADDRESS				# 2		;  	
STATUS                          # 1     ;

		ENDS

		DEFINE	INSTANCE_SIZE					RowStreamTileToVdp_FIELDS
		DEFINE	IX_BANK_FACTOR					ix + RowStreamTileToVdp_FIELDS.BANK_FACTOR
		DEFINE	IX_ROW_OFFSET					ix + RowStreamTileToVdp_FIELDS.ROW_OFFSET
		DEFINE	IX_CURRENT_ROW_ID_LSB			ix + RowStreamTileToVdp_FIELDS.CURRENT_ROW_ID
		DEFINE	IX_CURRENT_ROW_ID_MSB			ix + RowStreamTileToVdp_FIELDS.CURRENT_ROW_ID + 1
		DEFINE	IX_ROWSTREAM_ADDRESS_LSB		ix + RowStreamTileToVdp_FIELDS.ROWSTREAM_ADDRESS
		DEFINE	IX_ROWSTREAM_ADDRESS_MSB		ix + RowStreamTileToVdp_FIELDS.ROWSTREAM_ADDRESS + 1
		DEFINE	IX_STATUS		                ix + RowStreamTileToVdp_FIELDS.STATUS

		MACRO RowStreamTileToVdp_New \
			kernelMemoryManagerAddress, \
			rowStreamAddress, \
			var_inittialRowId, \
			bankFactor, \
            instanceVarAddress 
			LD      ix, kernelMemoryManagerAddress
			LD      iy, rowStreamAddress
			LD      hl, (var_inittialRowId)
			LD      a, bankFactor
			CALL    RowStreamTileToVdp.new
            LD      (instanceVarAddress), ix
		ENDMACRO


;
; 
;   ix  --> Kernel Memory Manager Address
;   a   --> VRAM    bank [0..2] (Colors and patterns)
;                   bank = 0 --> Bank Factor = 0  (sería 256 * 0)
;                   bank = 1 --> Bank Factor = 8  (sería 256 * 1)
;                   bank = 2 --> Bank Factor = 16 (sería 256 * 2)
;                   Ej.     Si DE contiene la address de la VRAM del tile debe
;                           corregisrse para el bank actual:
;                           Bank0 --> DE + 0
;                           Bank1 --> DE + 2048 = D + 8
;                           Bank2 --> DE + 4096 = D + 16
;   hl  --> Initial RowId
;	iy  --> SOURCE rowStreamSourceAddress
; 
new
            KernelMemoryManager_alloc INSTANCE_SIZE
            ;       IX  <-- this instance address

            LD      (IX_BANK_FACTOR), a 
            LD      (IX_ROW_OFFSET), a 
            LD      (IX_CURRENT_ROW_ID_LSB), l 
            LD      (IX_CURRENT_ROW_ID_MSB), h 
			;   	Skip stream size
            INC     iy 
            INC     iy 
            LD      a, iyl 
            LD      (IX_ROWSTREAM_ADDRESS_LSB), a 
            LD      a,iyh 
            LD      (IX_ROWSTREAM_ADDRESS_MSB), a 
            LD      a, 0
            LD      (IX_STATUS), a
            RET      
 
transfer_one_row 
            ;       Check finished
            LD      a, (IX_STATUS)
            AND     a, 00000001b
            RET     NZ
			;   	Check offset
            LD      a, (IX_ROW_OFFSET) 
            AND     a 
            JR      Z, .check_for_rowid 
            DEC     a 
            LD      (IX_ROW_OFFSET), a 
            RET      

.check_for_rowid       
            LD      a, (IX_ROWSTREAM_ADDRESS_LSB) 
            LD      iyl,a 
            LD      a ,(IX_ROWSTREAM_ADDRESS_MSB) 
            LD      iyh,a 
			;   	LSB rowstream RowId
            LD      a, (iy + 0) 
            CP      (IX_CURRENT_ROW_ID_LSB) 
            JR      NZ, .dec_current_rowid 
			;   	MSB rowstream RowId
            LD      a, (iy + 1) 
            CP      (IX_CURRENT_ROW_ID_MSB) 
            JR      NZ, .dec_current_rowid 

.init_transfer        
			;   	Current RowId == Stream RowId
            INC     iy 
            INC     iy 
			; 		A <-- TileSet size for this Row
            LD      a, (iy + 0) 
            INC     iy 

.tile_loop       
            PUSH    af 

			; 		DE <-- VDP VRAM Target Patterns Address
            LD      e, (iy + 0) 
            LD      d, (iy + 1) 
			; 		DE <-- VDP VRAM Target Patterns Address with Bank adjustment
            LD      a, (IX_BANK_FACTOR) 
            ADD     a, d 
            LD      d, a 
			; 		HL <-- CPU RAM Source Patterns Address
            LD      l, (iy + 2) 
            LD      h, (iy + 3) 
            LD      bc, $0020 
			; 		Transfer patterns
            CALL    VdpLdirvm.fromRamToVram 
			; 		DE <-- VDP VRAM Target Colors Address
            LD      e, (iy + 4) 
            LD      d, (iy + 5) 
			; 		DE <-- VDP VRAM Target Colors Address with Bank adjustment
            LD      a, (IX_BANK_FACTOR) 
            ADD     a, d 
            LD      d, a 
			; 		HL <-- CPU RAM Source Colors Address
            LD      l, (iy + 6) 
            LD      h, (iy + 7) 
            LD      bc, $0020 
			; 		Transfer Colors
            CALL    VdpLdirvm.fromRamToVram  

            LD      bc, $0008 
            ADD     iy, bc 

            POP     af 
            DEC     a 
            JR      nz, .tile_loop 

			;		ld (ROWSTREAM_ADDRESS), iy
            LD      a, iyl 
            LD      (IX_ROWSTREAM_ADDRESS_LSB), a 
            LD      a, iyh 
            LD      (IX_ROWSTREAM_ADDRESS_MSB), a 
.dec_current_rowid
            LD      l, (IX_CURRENT_ROW_ID_LSB)
            LD      h, (IX_CURRENT_ROW_ID_MSB)
            LD      a, l
            OR      h
            JR      Z, .finished
            DEC     hl
            LD      (IX_CURRENT_ROW_ID_LSB), l  
            LD      (IX_CURRENT_ROW_ID_MSB), h 
            RET      

.finished
            LD      a, (IX_STATUS)
            OR      00000001b
            LD      (IX_STATUS), a
            RET

		ENDMODULE

ENDIF