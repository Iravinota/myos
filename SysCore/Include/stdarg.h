#ifndef __STDARG_H
#define	__STDARG_H
//****************************************************************************
//**
//**    stdarg.h
//**    - [FILE DESCRIPTION]
//**
//****************************************************************************
//============================================================================
//    INTERFACE REQUIRED HEADERS
//============================================================================

#include "va_list.h"

//============================================================================
//    INTERFACE DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================

#ifdef __cplusplus
extern "C"
{
#endif

	/* width of stack == width of int */
#define	STACKITEM	int

/* Eric - Returns the size of the parameters pushed on the stack.
round up width of objects pushed on stack. The expression before the
& ensures that we get 0 for objects of size 0. */
#define	VA_SIZE(TYPE)					\
	((sizeof(TYPE) + sizeof(STACKITEM) - 1)	\
		& ~(sizeof(STACKITEM) - 1))

/* Eric - Returns the first position of the (...). For example, foo(int a, int b, ...),
   va_start returns the first position at ..., after int b.
   AP: a pointer to the parameter list of type va_list
   &(LASTARG): points to the LEFTMOST argument of the function call (before the ...) 
*/
#define	va_start(AP, LASTARG)	\
	(AP=((va_list)&(LASTARG) + VA_SIZE(LASTARG)))

/* nothing for va_end */
#define va_end(AP)

/*
Eric - Returns the next parameter in the parameter list.
*/
#define va_arg(AP, TYPE)	\
	(AP += VA_SIZE(TYPE), *((TYPE *)(AP - VA_SIZE(TYPE))))

#ifdef __cplusplus
}
#endif

//============================================================================
//    INTERFACE CLASS PROTOTYPES / EXTERNAL CLASS REFERENCES
//============================================================================
//============================================================================
//    INTERFACE STRUCTURES / UTILITY CLASSES
//============================================================================
//============================================================================
//    INTERFACE DATA DECLARATIONS
//============================================================================
//============================================================================
//    INTERFACE FUNCTION PROTOTYPES
//============================================================================
//============================================================================
//    INTERFACE OBJECT CLASS DEFINITIONS
//============================================================================
//============================================================================
//    INTERFACE TRAILING HEADERS
//============================================================================
//****************************************************************************
//**
//**    END stdarg.h
//**
//****************************************************************************

#endif

