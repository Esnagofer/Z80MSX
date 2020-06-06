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
        ;		TileVShift2P.Bottom.begin
        push ix
        push hl
        pop ix
        // S0.0
        ld a, (ix + 0);
        ld (iy + 0), a
        ld (iy + 10), a
        ld (iy + 20), a
        ld (iy + 30), a
        // S0.1
        ld a, (ix + 1);
        ld (iy + 1), a
        ld (iy + 11), a
        ld (iy + 21), a
        ld (iy + 31), a
        // S1.0
        ld a, (ix + 2);
        ld (iy + 2), a
        ld (iy + 12), a
        ld (iy + 22), a
        // S1.1
        ld a, (ix + 3);
        ld (iy + 3), a
        ld (iy + 13), a
        ld (iy + 23), a
        // S2.0
        ld a, (ix + 4);
        ld (iy + 4), a
        ld (iy + 14), a
        // S2.1
        ld a, (ix + 5);
        ld (iy + 5), a
        ld (iy + 15), a
        // S3.0
        ld a, (ix + 6);
        ld (iy + 6), a
        // S3.1
        ld a, (ix + 7);
        ld (iy + 7), a
        pop ix
        ;		TileVShift2P.Bottom.end
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
        ;		TileVShift2P.Top.begin
        push ix
        push hl 
        pop ix
        // T3.0
        ld a, (ix + 6);
        ld (iy + 8), a
        ld (iy + 18), a
        ld (iy + 28), a
        // T3.1
        ld a, (ix + 7);
        ld (iy + 9), a
        ld (iy + 19), a
        ld (iy + 29), a
        // T2.0
        ld a, (ix + 4);
        ld (iy + 16), a
        ld (iy + 26), a
        // T2.1
        ld a, (ix + 5);
        ld (iy + 17), a
        ld (iy + 27), a
        // T1.0
        ld a, (ix + 2);
        ld (iy + 24), a
        // T1.1
        ld a, (ix + 3);
        ld (iy + 25), a
        pop ix
        ;		TileVShift2P.Top.end
        RET
	
		ENDMODULE


ENDIF