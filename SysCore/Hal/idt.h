#ifndef _IDT_H
#define _IDT_H
//****************************************************************************
//**
//**    Idt.h
//**		Interrupt Descriptor Table. The IDT is responsible for providing
//**	the interface for managing interrupts, installing, setting, requesting,
//**	generating, and interrupt callback managing.
//**
//****************************************************************************

#ifndef ARCH_X86
#error "[idt.h for i86] requires i86 architecture. Define ARCH_X86"
#endif

// We can test new architecture here as needed

#include <stdint.h>

//============================================================================
//    INTERFACE REQUIRED HEADERS
//============================================================================
//============================================================================
//    INTERFACE DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================

//! i86 defines 256 possible interrupt handlers (0-255)
#define I86_MAX_INTERRUPTS		256

//! must be in the format 0000-D110, where D is descriptor type
#define I86_IDT_DESC_BIT16		0x06	//00000110  // 16-bit interrupt gate
#define I86_IDT_DESC_BIT32		0x0E	//00001110  // 32-bit interrupt gate
#define I86_IDT_DESC_RING1		0x40	//01000000
#define I86_IDT_DESC_RING2		0x20	//00100000
#define I86_IDT_DESC_RING3		0x60	//01100000
#define I86_IDT_DESC_PRESENT	0x80	//10000000

//! interrupt handler w/o error code
//! Note: interrupt handlers are called by the processor. The stack setup may change
//! so we leave it up to the interrupts' implimentation to handle it and properly return
typedef void (_cdecl *I86_IRQ_HANDLER)(void);

//============================================================================
//    INTERFACE CLASS PROTOTYPES / EXTERNAL CLASS REFERENCES
//============================================================================
//============================================================================
//    INTERFACE STRUCTURES / UTILITY CLASSES
//============================================================================

#ifdef _MSC_VER
#pragma pack (push, 1)
#endif

//! interrupt descriptor
struct idt_descriptor {

	//! bits 0-16 of interrupt routine (ir) address
	uint16_t		baseLo;     // bit 0-15

	//! code selector in gdt
	uint16_t		sel;        // bit 16-31

	//! reserved, shold be 0
	uint8_t			reserved;   // bit 32-39

	//! bit flags. Set with flags above. Eric - https://wiki.osdev.org/Interrupt_Descriptor_Table
	uint8_t			flags;      // bit 40-47: 40-43: Gate Type (0x6(0b0110) - 16-bit interrupt gate)
                                //                             (0x7(0b0111) - 16-bit trap gate)
                                //                             (0xE(0b1110) - 32-bit interrupt gate)
                                //                             (0xF(0b1111) - 32-bit trap gate)
                                //               44: Storage Segment, Set to 0 for interrupt and trap gates
                                //            45-46: Descriptor Privilege Level
                                //               47: Present, Set to 0 for unused interrupts

	//! bits 16-32 of ir address
	uint16_t		baseHi;     // bit 48-63
};

#ifdef _MSC_VER
#pragma pack (pop)
#endif

//============================================================================
//    INTERFACE DATA DECLARATIONS
//============================================================================
//============================================================================
//    INTERFACE FUNCTION PROTOTYPES
//============================================================================

//! returns interrupt descriptor
extern idt_descriptor* i86_get_ir (uint32_t i);

//! installs interrupt handler. When INT is fired, it will call this callback
extern int i86_install_ir (uint32_t i, uint16_t flags, uint16_t sel, I86_IRQ_HANDLER);

// initialize basic idt
extern int i86_idt_initialize (uint16_t codeSel);

//============================================================================
//    INTERFACE OBJECT CLASS DEFINITIONS
//============================================================================
//============================================================================
//    INTERFACE TRAILING HEADERS
//============================================================================
//****************************************************************************
//**
//**    END [idt.h]
//**
//****************************************************************************
#endif
