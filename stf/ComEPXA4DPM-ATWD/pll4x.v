// megafunction wizard: %ALTCLKLOCK%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altclklock 

// ============================================================
// File Name: pll4x.v
// Megafunction Name(s):
// 			altclklock
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 4.0 Build 214 3/25/2004 SP 1 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2004 Altera Corporation
//Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
//support information,  device programming or simulation file,  and any other
//associated  documentation or information  provided by  Altera  or a partner
//under  Altera's   Megafunction   Partnership   Program  may  be  used  only
//to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
//other  use  of such  megafunction  design,  netlist,  support  information,
//device programming or simulation file,  or any other  related documentation
//or information  is prohibited  for  any  other purpose,  including, but not
//limited to  modification,  reverse engineering,  de-compiling, or use  with
//any other  silicon devices,  unless such use is  explicitly  licensed under
//a separate agreement with  Altera  or a megafunction partner.  Title to the
//intellectual property,  including patents,  copyrights,  trademarks,  trade
//secrets,  or maskworks,  embodied in any such megafunction design, netlist,
//support  information,  device programming or simulation file,  or any other
//related documentation or information provided by  Altera  or a megafunction
//partner, remains with Altera, the megafunction partner, or their respective
//licensors. No other licenses, including any licenses needed under any third
//party's intellectual property, are provided herein.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module pll4x (
	inclock,
	locked,
	clock0,
	clock1);

	input	  inclock;
	output	  locked;
	output	  clock0;
	output	  clock1;

	wire  sub_wire0;
	wire  sub_wire1;
	wire  sub_wire2;
	wire  clock0 = sub_wire0;
	wire  clock1 = sub_wire1;
	wire  locked = sub_wire2;

	altclklock	altclklock_component (
				.inclock (inclock),
				.clock0 (sub_wire0),
				.clock1 (sub_wire1),
				.locked (sub_wire2)
				// synopsys translate_off
,
				.inclocken (),
				.fbin (),
				.clock2 (),
				.clock_ext ()
				// synopsys translate_on

);
	defparam
		altclklock_component.inclock_period = 50000,
		altclklock_component.clock0_boost = 3,
		altclklock_component.clock1_boost = 6,
		altclklock_component.operation_mode = "NORMAL",
		altclklock_component.intended_device_family = "EXCALIBUR_ARM",
		altclklock_component.valid_lock_cycles = 5,
		altclklock_component.invalid_lock_cycles = 5,
		altclklock_component.valid_lock_multiplier = 5,
		altclklock_component.invalid_lock_multiplier = 5,
		altclklock_component.clock0_divide = 1,
		altclklock_component.clock1_divide = 1,
		altclklock_component.outclock_phase_shift = 0,
		altclklock_component.lpm_type = "altclklock";


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: DISPLAY_FREQUENCY STRING "20.0"
// Retrieval info: PRIVATE: USING_FREQUENCY NUMERIC "0"
// Retrieval info: PRIVATE: DEVICE_FAMILY NUMERIC "4"
// Retrieval info: PRIVATE: FEEDBACK_SOURCE NUMERIC "1"
// Retrieval info: PRIVATE: PHASE_UNIT NUMERIC "0"
// Retrieval info: PRIVATE: USING_PROGRAMMABLE_PHASE_SHIFT NUMERIC "1"
// Retrieval info: PRIVATE: MEGAFN_PORT_INFO_0 STRING "inclock;inclocken;fbin;clock0;clock1"
// Retrieval info: PRIVATE: MEGAFN_PORT_INFO_1 STRING "locked;clock2;clock_ext"
// Retrieval info: CONSTANT: INCLOCK_PERIOD NUMERIC "50000"
// Retrieval info: CONSTANT: CLOCK0_BOOST NUMERIC "3"
// Retrieval info: CONSTANT: CLOCK1_BOOST NUMERIC "6"
// Retrieval info: CONSTANT: OPERATION_MODE STRING "NORMAL"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "EXCALIBUR_ARM"
// Retrieval info: CONSTANT: VALID_LOCK_CYCLES NUMERIC "5"
// Retrieval info: CONSTANT: INVALID_LOCK_CYCLES NUMERIC "5"
// Retrieval info: CONSTANT: VALID_LOCK_MULTIPLIER NUMERIC "5"
// Retrieval info: CONSTANT: INVALID_LOCK_MULTIPLIER NUMERIC "5"
// Retrieval info: CONSTANT: CLOCK0_DIVIDE NUMERIC "1"
// Retrieval info: CONSTANT: CLOCK1_DIVIDE NUMERIC "1"
// Retrieval info: CONSTANT: OUTCLOCK_PHASE_SHIFT NUMERIC "0"
// Retrieval info: CONSTANT: LPM_TYPE STRING "altclklock"
// Retrieval info: USED_PORT: inclock 0 0 0 0 INPUT NODEFVAL inclock
// Retrieval info: USED_PORT: locked 0 0 0 0 OUTPUT NODEFVAL locked
// Retrieval info: USED_PORT: clock0 0 0 0 0 OUTPUT NODEFVAL clock0
// Retrieval info: USED_PORT: clock1 0 0 0 0 OUTPUT NODEFVAL clock1
// Retrieval info: CONNECT: @inclock 0 0 0 0 inclock 0 0 0 0
// Retrieval info: CONNECT: locked 0 0 0 0 @locked 0 0 0 0
// Retrieval info: CONNECT: clock0 0 0 0 0 @clock0 0 0 0 0
// Retrieval info: CONNECT: clock1 0 0 0 0 @clock1 0 0 0 0
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: GEN_FILE: TYPE_NORMAL pll4x.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL pll4x.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL pll4x.cmp TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL pll4x.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL pll4x_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL pll4x_bb.v TRUE