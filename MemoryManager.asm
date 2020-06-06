/*
	MEMORY MANAGER


	Implements a simple (as fast as possible) no disposable 
	memory manager with circular allocation -->
	when the heap space is consumed then the next allocation serves 
	at the begin of the heap.
 
	      Control	                       Heap Space
	<-------------------------><------------------------------>
	+-----+-------+------------+----------- ... --------------+
	|BEGIN|END    |FREE        |===ALLOCATED===|====FREE======|
	+-----+-------+------------+----------- ... --------------+
                                ^ BEGIN
                                                ^ FREE
                                                                ^ END

	BEGIN		(2 byte) Address of begin Heap Space 
	END 		(2 byte) Address of end Heap space
	FREE		(2 byte) Address of free Heap space


*/
IFNDEF	MEMORY_MANAGER

		DEFINE	MEMORY_MANAGER

		MODULE	MemoryManager

		MACRO MemoryManager_New pointer, size
			PUSH 	hl
			PUSH 	de
			LD 		hl, pointer
			LD 		de, size
			CALL 	MemoryManager.new
			POP 	de
			POP 	hl
		ENDMACRO

		MACRO MemoryManager_alloc size
			PUSH	de
			LD 		de, size
			CALL 	MemoryManager.alloc
			POP		de
		ENDMACRO

		MACRO MemoryManager_alloc_bc size
			PUSH	de
			LD 		de, size
			CALL 	MemoryManager.alloc_bc
			POP		de
		ENDMACRO

		STRUCT	MEMORY_MANAGER_FIELDS
BEGIN		# 2
END	        # 2
FREE		# 2
		ENDS

		DEFINE	IY_BEGIN_LSB	iy + MEMORY_MANAGER_FIELDS.BEGIN
		DEFINE	IY_BEGIN_MSB	iy + MEMORY_MANAGER_FIELDS.BEGIN + 1
		DEFINE	IY_END_LSB      iy + MEMORY_MANAGER_FIELDS.END
		DEFINE	IY_END_MSB      iy + MEMORY_MANAGER_FIELDS.END + 1
		DEFINE	IY_FREE_LSB     iy + MEMORY_MANAGER_FIELDS.FREE
		DEFINE	IY_FREE_MSB     iy + MEMORY_MANAGER_FIELDS.FREE + 1

/*
	IN
	==
	HL 	-> 	Heap memory address
	DE 	-> 	Heap memory size

	OUT
	===
	IY	->	 Memory Manager instance address

*/
new
		PUSH 	hl
        ; IY <- Heap address
		POP 	iy									
		PUSH 	hl
        ; Heap size
		PUSH 	de									
        ; MEMORY_MANAGER_FIELDS Size 
		LD 		de, MEMORY_MANAGER_FIELDS			
        ; HL <- BEGIN address
		ADD		hl, de								
		LD 		(IY_BEGIN_LSB), l
		LD 		(IY_BEGIN_MSB), h
		LD		(IY_FREE_LSB), l
		LD 		(IY_FREE_MSB), h
        ; Heap size
		POP		de									
        ; Heap address
		POP		hl									
        ; End Heap address
		ADD 	hl, de								
		LD 		(IY_END_LSB), l
		LD 		(IY_END_MSB), h
		RET

/*
	IN
	==
		IY 	-> 	 Memory Manager address instance
		DE 	-> 	14 Bits Size to alloc

	OUT
	===
		IX 	-> 	Pointer to allocated memory

*/
alloc
		PUSH 	hl	
		; 		HL 	<-- llocated memory address
		LD 		l, (IY_FREE_LSB)
		LD 		h, (IY_FREE_MSB)
		PUSH 	hl
		ADD		hl,de	
		;		HL	<-- next free block
		LD 		(IY_FREE_LSB), l
		LD 		(IY_FREE_MSB), h			
		LD 		e, (IY_END_LSB)
		LD 		d, (IY_END_MSB)			
		AND 	a
		SBC		hl,de
		POP		hl
		JR 		c, .correctSizeRequested
		JR 		z, .correctSizeRequested	
.overflow			
		LD 		l, (IY_BEGIN_LSB)
		LD 		h, (IY_BEGIN_MSB)
		LD 		(IY_FREE_LSB), l
		LD 		(IY_FREE_MSB), h			
.correctSizeRequested
		PUSH 	hl
		POP 	ix
		POP 	hl
		RET

alloc_bc 
		PUSH	ix
		CALL 	MemoryManager.alloc
		LD		c, ixl
		LD		b, ixh
		POP		ix
		RET
reset
		PUSH	af
		LD 		a, (IY_BEGIN_LSB)
		LD 		(IY_FREE_LSB), a
		LD 		a, (IY_BEGIN_MSB)
		LD 		(IY_FREE_MSB), a
		POP		af
		RET

		ENDMODULE


ENDIF