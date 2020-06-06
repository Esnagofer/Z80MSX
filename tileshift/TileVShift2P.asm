/*
	TileVShift2P
	Implements the Shift from tile A to tile B in 2 step pixels.
*/
IFNDEF	TileVShift2P_MODULE

		DEFINE	TileVShift2P_MODULE

		MODULE TileVShift2P

initService
		RET
		
/*
	INPUT
	-----

	HL -> Source Bottom Tile memory address
	IY -> Target memory address

	OUTPUT
	------

	MODIFIES: A


*/
verticalBottomShift2Pixels
	INCLUDE "TileVShift2P.Bottom.inc.asm"
	RET

/*
	INPUT
	-----

	HL -> Source Top Tile memory address
	IY -> Target memory address

	OUTPUT
	------

	MODIFIES: A


*/
verticalTopShift2Pixels
	INCLUDE "TileVShift2P.Top.inc.asm"
	RET
	
		ENDMODULE


ENDIF