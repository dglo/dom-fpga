// Copyright (C) 1991-2004 Altera Corporation
// Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
// support information,  device programming or simulation file,  and any other
// associated  documentation or information  provided by  Altera  or a partner
// under  Altera's   Megafunction   Partnership   Program  may  be  used  only
// to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
// other  use  of such  megafunction  design,  netlist,  support  information,
// device programming or simulation file,  or any other  related documentation
// or information  is prohibited  for  any  other purpose,  including, but not
// limited to  modification,  reverse engineering,  de-compiling, or use  with
// any other  silicon devices,  unless such use is  explicitly  licensed under
// a separate agreement with  Altera  or a megafunction partner.  Title to the
// intellectual property,  including patents,  copyrights,  trademarks,  trade
// secrets,  or maskworks,  embodied in any such megafunction design, netlist,
// support  information,  device programming or simulation file,  or any other
// related documentation or information provided by  Altera  or a megafunction
// partner, remains with Altera, the megafunction partner, or their respective
// licensors. No other licenses, including any licenses needed under any third
// party's intellectual property, are provided herein.
// 

// Excalibur stripe memory map.

parameter REGISTERS_BASE_ADDRESS = 32'h7fffc000;
parameter REGISTERS_SIZE = 32'h00004000;
parameter DPSRAM0_BASE_ADDRESS = 32'h80000000;
parameter DPSRAM0_SIZE = 32'h00008000;
parameter DPSRAM1_BASE_ADDRESS = 32'h80010000;
parameter DPSRAM1_SIZE = 32'h00008000;
parameter SDRAM0_BASE_ADDRESS = 32'h00000000;
parameter SDRAM0_SIZE = 32'h00800000;
parameter SDRAM1_BASE_ADDRESS = 32'h00800000;
parameter SDRAM1_SIZE = 32'h00800000;
parameter EBI0_BASE_ADDRESS = 32'h40000000;
parameter EBI0_SIZE = 32'h00400000;
parameter EBI1_BASE_ADDRESS = 32'h40400000;
parameter EBI1_SIZE = 32'h00400000;
parameter EBI2_BASE_ADDRESS = 32'h50000000;
parameter EBI2_SIZE = 32'h00004000;
parameter EBI3_BASE_ADDRESS = 32'h60000000;
parameter EBI3_SIZE = 32'h00010000;
parameter PLD0_BASE_ADDRESS = 32'h90000000;
parameter PLD0_SIZE = 32'h00100000;
