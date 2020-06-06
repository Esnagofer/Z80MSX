/*
	TileVShift2P
	Implements the Shift from tile A to tile B in 2 step pixels.
*/
IFNDEF	TileVShift2P_MODULE

		DEFINE      TileVShift2P_MODULE

		MODULE      TileVShift2P

        INCLUDE     "KernelSlotManager.asm"
        INCLUDE     "CallDynamic.asm"
        INCLUDE     "InstallCode.asm"

new_LABEL
        RET

		STRUCT TileVShift2P_VARS
INSTALLED_METHOD_BOTTOM         #   2
INSTALLED_METHOD_TOP            #   2

		ENDS

VAR_INSTALLED_METHOD_BOTTOM         EQU VAR_TileVShift2P_BEGIN - TileVShift2P_VARS.INSTALLED_METHOD_BOTTOM
VAR_INSTALLED_METHOD_TOP            EQU VAR_TileVShift2P_BEGIN - TileVShift2P_VARS.INSTALLED_METHOD_TOP

/**
    INPUT
        IX  <-- KMM service address
*/
initService
    PUSH    ix
    KernelMemoryManager_alloc_de installedVerticalBottomShift2Pixels_END - installedVerticalBottomShift2Pixels
    LD      (VAR_INSTALLED_METHOD_BOTTOM), ix
    LD 		hl, installedVerticalBottomShift2Pixels
    LD		de, (VAR_INSTALLED_METHOD_BOTTOM)	
    LD		bc, installedVerticalBottomShift2Pixels_END - installedVerticalBottomShift2Pixels
    CALL	InstallCode.exec
    POP     ix
    KernelMemoryManager_alloc_de installedVerticalTopShift2Pixels_END - installedVerticalTopShift2Pixels
    LD      (VAR_INSTALLED_METHOD_TOP), ix
    LD 		hl, installedVerticalTopShift2Pixels
    LD		de, (VAR_INSTALLED_METHOD_TOP)	
    LD		bc, installedVerticalTopShift2Pixels_END - installedVerticalTopShift2Pixels
    CALL	InstallCode.exec
    RET

/*
	INPUT
		HL -> Source Bottom Tile memory address
		IY -> Target memory address
	MODIFIES
		A
*/
verticalBottomShift2Pixels
    CallDynamic_exec VAR_INSTALLED_METHOD_BOTTOM
    RET

installedVerticalBottomShift2Pixels
    LD		a, (KernelSlotManager.VAR_SlotsAllRam)
    ;LD      a, 11110111b
    OUT		(0xA8), a
	INCLUDE "TileVShift2P.Bottom.inc.asm"
    LD		a, (KernelSlotManager.VAR_SlotsDefaults)
    ;LD      a, 11110100b
    OUT		(0xA8), a
	RET
installedVerticalBottomShift2Pixels_END

/*
	INPUT
		HL -> Source Top Tile memory address
		IY -> Target memory address
	MODIFIES
		A
*/
verticalTopShift2Pixels
    CallDynamic_exec VAR_INSTALLED_METHOD_TOP
    RET

installedVerticalTopShift2Pixels
    LD		a, (KernelSlotManager.VAR_SlotsAllRam)
    ;LD      a, 11110111b
    OUT		(0xA8), a
	INCLUDE "TileVShift2P.Top.inc.asm"
    LD		a, (KernelSlotManager.VAR_SlotsDefaults)
    ;LD      a, 11110100b
    OUT		(0xA8), a
	RET
installedVerticalTopShift2Pixels_END

		ENDMODULE


ENDIF