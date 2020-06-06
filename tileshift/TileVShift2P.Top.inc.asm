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
