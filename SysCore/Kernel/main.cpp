/*
======================================
	main.cpp
		-kernel startup code
======================================
*/

#include <Hal.h>
#include "DebugDisplay.h"

void _cdecl main () {

	int i=0x12;

	DebugClrScr (0x18);

	DebugGotoXY (0,4);
	DebugSetColor (0x17);
	DebugPrintf ("    +-----------------------------------------+\n");
	DebugPrintf ("    |    MOS 32 Bit C++ Kernel Executing!     |\n");
	DebugPrintf ("    +-----------------------------------------+\n\n");
	
	DebugSetColor (0x12);
	DebugPrintf ("\n    i as integer ........................");
	DebugSetColor (0x1F);
	DebugPrintf ("[%i]",i);
	DebugSetColor (0x12);
	//DebugPrintf ("\n    i in hex ............................");
	//DebugSetColor (0x1F);
	//DebugPrintf ("[0x%x]",i);

	//DebugGotoXY (4,16);
	//DebugSetColor (0x1F);
	//DebugPrintf ("I am preparing to load... Hold on, please... :)");

	//hal_initialize();

	//DebugPrintf ("\nhal initialized");
}
