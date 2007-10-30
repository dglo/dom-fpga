/* megafunction wizard: %ARM-Based Excalibur%
   GENERATION: STANDARD
   VERSION: WM1.0
   MODULE: ARM-Based Excalibur
   PROJECT: dom
   ============================================================
   File Name: /work_lbnl/IceCubeCVS/dom-fpga/domapp/stripe.h
   Megafunction Name(s): ARM-Based Excalibur
   ============================================================

   ************************************************************
   THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
   ************************************************************/

#ifndef	DOM_H_INCLUDED
#define	DOM_H_INCLUDED

#define EXC_DEFINE_PROCESSOR_LITTLE_ENDIAN
#define EXC_DEFINE_BOOT_FROM_SERIAL

#define	EXC_INPUT_CLK_FREQUENCY (20000000)
#define	EXC_AHB1_CLK_FREQUENCY (80000000)
#define	EXC_AHB2_CLK_FREQUENCY (40000000)
#define	EXC_SDRAM_CLK_FREQUENCY (40000000)

/* Registers Block */
#define	EXC_REGISTERS_BASE (0x7fffc000)
#define	EXC_MODE_CTRL00_BASE (EXC_REGISTERS_BASE + 0x000)
#define	EXC_IO_CTRL00_BASE (EXC_REGISTERS_BASE + 0x040)
#define	EXC_MMAP00_BASE (EXC_REGISTERS_BASE + 0x080)
#define	EXC_PLD_CONFIG00_BASE (EXC_REGISTERS_BASE + 0x140)
#define	EXC_TIMER00_BASE (EXC_REGISTERS_BASE + 0x200)
#define	EXC_INT_CTRL00_BASE (EXC_REGISTERS_BASE + 0xc00)
#define	EXC_CLOCK_CTRL00_BASE (EXC_REGISTERS_BASE + 0x300)
#define	EXC_WATCHDOG00_BASE (EXC_REGISTERS_BASE + 0xa00)
#define	EXC_UART00_BASE (EXC_REGISTERS_BASE + 0x280)
#define	EXC_EBI00_BASE (EXC_REGISTERS_BASE + 0x380)
#define	EXC_SDRAM00_BASE (EXC_REGISTERS_BASE + 0x400)
#define	EXC_AHB12_BRIDGE_CTRL00_BASE (EXC_REGISTERS_BASE + 0x800)
#define	EXC_PLD_STRIPE_BRIDGE_CTRL00_BASE (EXC_REGISTERS_BASE + 0x100)
#define	EXC_STRIPE_PLD_BRIDGE_CTRL00_BASE (EXC_REGISTERS_BASE + 0x100)

#define	EXC_REGISTERS_SIZE (0x00004000)

/* EBI Block(s) */
#define	EXC_EBI_BLOCK0_BASE (0x40000000)
#define	EXC_EBI_BLOCK0_SIZE (0x00400000)
#define	EXC_EBI_BLOCK0_WIDTH (16)
#define	EXC_EBI_BLOCK0_NON_CACHEABLE
#define	EXC_EBI_BLOCK1_BASE (0x40400000)
#define	EXC_EBI_BLOCK1_SIZE (0x00400000)
#define	EXC_EBI_BLOCK1_WIDTH (16)
#define	EXC_EBI_BLOCK1_NON_CACHEABLE
#define	EXC_EBI_BLOCK2_BASE (0x50000000)
#define	EXC_EBI_BLOCK2_SIZE (0x00004000)
#define	EXC_EBI_BLOCK2_WIDTH (16)
#define	EXC_EBI_BLOCK2_NON_CACHEABLE
#define	EXC_EBI_BLOCK3_BASE (0x60000000)
#define	EXC_EBI_BLOCK3_SIZE (0x00010000)
#define	EXC_EBI_BLOCK3_WIDTH (16)
#define	EXC_EBI_BLOCK3_NON_CACHEABLE

/* SDRAM Block(s) */
#define	EXC_SDRAM_BLOCK0_BASE (0x00000000)
#define	EXC_SDRAM_BLOCK0_SIZE (0x01000000)
#define	EXC_SDRAM_BLOCK0_WIDTH (32)

/* Single Port SRAM Block(s) */
#define	EXC_SPSRAM_BLOCK0_BASE (0x10000000)
#define	EXC_SPSRAM_BLOCK0_SIZE (0x00010000)
#define	EXC_SPSRAM_BLOCK1_BASE (0x10040000)
#define	EXC_SPSRAM_BLOCK1_SIZE (0x00010000)

/* Dual Port SRAM Block(s) */
#define	EXC_DPSRAM_BLOCK0_BASE (0x80000000)
#define	EXC_DPSRAM_BLOCK0_SIZE (0x00008000)
#define	EXC_DPSRAM_BLOCK0_WIDTH (32)
#define	EXC_DPSRAM_BLOCK1_BASE (0x80040000)
#define	EXC_DPSRAM_BLOCK1_SIZE (0x00008000)
#define	EXC_DPSRAM_BLOCK1_WIDTH (32)

/* PLD Block(s) */
#define	EXC_PLD_BLOCK0_BASE (0x90000000)
#define	EXC_PLD_BLOCK0_SIZE (0x00004000)
#define	EXC_PLD_BLOCK0_NON_CACHEABLE

#endif
