; megafunction wizard: %ARM-Based Excalibur%
; GENERATION: STANDARD
; VERSION: WM1.0
; MODULE: ARM-Based Excalibur
; PROJECT: configboot
; ============================================================
; File Name: /work_lbnl/IceCubeCVS/dom-fpga/configboot/epxa4DPM/stripe.s
; Megafunction Name(s): ARM-Based Excalibur
; ============================================================

; ************************************************************
; THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
; ************************************************************

EXC_DEFINE_PROCESSOR_LITTLE_ENDIAN EQU (1)
EXC_DEFINE_PROCESSOR_BIG_ENDIAN EQU (0)

EXC_DEFINE_BOOT_FROM_SERIAL EQU (1)
EXC_DEFINE_BOOT_FROM_FLASH EQU (0)

EXC_INPUT_CLK_FREQUENCY EQU (20000000)
EXC_AHB1_CLK_FREQUENCY EQU (40000000)
EXC_AHB2_CLK_FREQUENCY EQU (20000000)
EXC_SDRAM_CLK_FREQUENCY EQU (10000000)

; Registers Block
EXC_REGISTERS_BASE EQU (0x7fffc000)
EXC_MODE_CTRL00_BASE EQU (EXC_REGISTERS_BASE + 0x000)
EXC_IO_CTRL00_BASE EQU (EXC_REGISTERS_BASE + 0x040)
EXC_MMAP00_BASE EQU (EXC_REGISTERS_BASE + 0x080)
EXC_PLD_CONFIG00_BASE EQU (EXC_REGISTERS_BASE + 0x140)
EXC_TIMER00_BASE EQU (EXC_REGISTERS_BASE + 0x200)
EXC_INT_CTRL00_BASE EQU (EXC_REGISTERS_BASE + 0xc00)
EXC_CLOCK_CTRL00_BASE EQU (EXC_REGISTERS_BASE + 0x300)
EXC_WATCHDOG00_BASE EQU (EXC_REGISTERS_BASE + 0xa00)
EXC_UART00_BASE EQU (EXC_REGISTERS_BASE + 0x280)
EXC_EBI00_BASE EQU (EXC_REGISTERS_BASE + 0x380)
EXC_SDRAM00_BASE EQU (EXC_REGISTERS_BASE + 0x400)
EXC_AHB12_BRIDGE_CTRL00_BASE EQU (EXC_REGISTERS_BASE + 0x800)
EXC_PLD_STRIPE_BRIDGE_CTRL00_BASE EQU (EXC_REGISTERS_BASE + 0x100)
EXC_STRIPE_PLD_BRIDGE_CTRL00_BASE EQU (EXC_REGISTERS_BASE + 0x100)

EXC_REGISTERS_SIZE EQU (0x00004000)

; EBI Block(s)
EXC_EBI_BLOCK0_BASE EQU (0x40000000)
EXC_EBI_BLOCK0_SIZE EQU (0x00400000)
EXC_EBI_BLOCK0_WIDTH EQU (16)
EXC_EBI_BLOCK0_NON_CACHEABLE EQU (1)
EXC_EBI_BLOCK0_CACHEABLE EQU (0)
EXC_EBI_BLOCK1_BASE EQU (0x40400000)
EXC_EBI_BLOCK1_SIZE EQU (0x00400000)
EXC_EBI_BLOCK1_WIDTH EQU (16)
EXC_EBI_BLOCK1_NON_CACHEABLE EQU (1)
EXC_EBI_BLOCK1_CACHEABLE EQU (0)
EXC_EBI_BLOCK2_BASE EQU (0x50000000)
EXC_EBI_BLOCK2_SIZE EQU (0x00004000)
EXC_EBI_BLOCK2_WIDTH EQU (8)
EXC_EBI_BLOCK2_NON_CACHEABLE EQU (1)
EXC_EBI_BLOCK2_CACHEABLE EQU (0)

; Single Port SRAM Block(s)
EXC_SPSRAM_BLOCK0_BASE EQU (0x00000000)
EXC_SPSRAM_BLOCK0_SIZE EQU (0x00010000)
EXC_SPSRAM_BLOCK1_BASE EQU (0x00010000)
EXC_SPSRAM_BLOCK1_SIZE EQU (0x00010000)

; Dual Port SRAM Block(s)
EXC_DPSRAM_SEPERATE EQU (1)
EXC_DPSRAM_COMBINED EQU (0)

EXC_DPSRAM_BLOCK0_BASE EQU (0x80000000)
EXC_DPSRAM_BLOCK0_SIZE EQU (0x00008000)
EXC_DPSRAM_BLOCK0_WIDTH EQU (32)
EXC_DPSRAM_BLOCK1_BASE EQU (0x80008000)
EXC_DPSRAM_BLOCK1_SIZE EQU (0x00008000)
EXC_DPSRAM_BLOCK1_WIDTH EQU (32)

; PLD Block(s)
EXC_PLD_BLOCK0_BASE EQU (0x90000000)
EXC_PLD_BLOCK0_SIZE EQU (0x00004000)
EXC_PLD_BLOCK0_NON_CACHEABLE EQU (1)
EXC_PLD_BLOCK0_CACHEABLE EQU (0)

	END

