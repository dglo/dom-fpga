// megafunction wizard: %RAM: 2-PORT%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altdpram 

// ============================================================
// File Name: dim_pole_buffer.v
// Megafunction Name(s):
// 			altdpram
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
module dim_pole_buffer (
	data,
	wraddress,
	rdaddress,
	wren,
	clock,
	q);

	input	[15:0]  data;
	input	[6:0]  wraddress;
	input	[6:0]  rdaddress;
	input	  wren;
	input	  clock;
	output	[15:0]  q;

	wire [15:0] sub_wire0;
	wire [15:0] q = sub_wire0[15:0];

	altdpram	altdpram_component (
				.wren (wren),
				.inclock (clock),
				.data (data),
				.rdaddress (rdaddress),
				.wraddress (wraddress),
				.q (sub_wire0)
				// synopsys translate_off
,
				.inclocken (),
				.rden (),
				.outclock (),
				.outclocken (),
				.aclr ()
				// synopsys translate_on

);
	defparam
		altdpram_component.intended_device_family = "EXCALIBUR_ARM",
		altdpram_component.width = 16,
		altdpram_component.widthad = 7,
		altdpram_component.indata_reg = "INCLOCK",
		altdpram_component.wraddress_reg = "INCLOCK",
		altdpram_component.wrcontrol_reg = "INCLOCK",
		altdpram_component.rdaddress_reg = "UNREGISTERED",
		altdpram_component.rdcontrol_reg = "UNREGISTERED",
		altdpram_component.outdata_reg = "UNREGISTERED",
		altdpram_component.indata_aclr = "OFF",
		altdpram_component.wraddress_aclr = "OFF",
		altdpram_component.wrcontrol_aclr = "OFF",
		altdpram_component.rdaddress_aclr = "OFF",
		altdpram_component.rdcontrol_aclr = "OFF",
		altdpram_component.outdata_aclr = "OFF",
		altdpram_component.lpm_type = "altdpram",
		altdpram_component.use_eab = "ON";


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: MEM_IN_BITS NUMERIC "0"
// Retrieval info: PRIVATE: OPERATION_MODE NUMERIC "2"
// Retrieval info: PRIVATE: UseDPRAM NUMERIC "1"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "EXCALIBUR_ARM"
// Retrieval info: PRIVATE: VarWidth NUMERIC "0"
// Retrieval info: PRIVATE: WIDTH_WRITE_A NUMERIC "16"
// Retrieval info: PRIVATE: WIDTH_WRITE_B NUMERIC "16"
// Retrieval info: PRIVATE: WIDTH_READ_A NUMERIC "16"
// Retrieval info: PRIVATE: WIDTH_READ_B NUMERIC "16"
// Retrieval info: PRIVATE: MEMSIZE NUMERIC "2048"
// Retrieval info: PRIVATE: Clock NUMERIC "0"
// Retrieval info: PRIVATE: rden NUMERIC "0"
// Retrieval info: PRIVATE: BYTE_ENABLE_A NUMERIC "0"
// Retrieval info: PRIVATE: BYTE_ENABLE_B NUMERIC "0"
// Retrieval info: PRIVATE: BYTE_SIZE NUMERIC "1"
// Retrieval info: PRIVATE: Clock_A NUMERIC "0"
// Retrieval info: PRIVATE: Clock_B NUMERIC "0"
// Retrieval info: PRIVATE: REGdata NUMERIC "1"
// Retrieval info: PRIVATE: REGwraddress NUMERIC "1"
// Retrieval info: PRIVATE: REGwren NUMERIC "1"
// Retrieval info: PRIVATE: REGrdaddress NUMERIC "0"
// Retrieval info: PRIVATE: REGrren NUMERIC "0"
// Retrieval info: PRIVATE: REGq NUMERIC "0"
// Retrieval info: PRIVATE: INDATA_REG_B NUMERIC "1"
// Retrieval info: PRIVATE: WRADDR_REG_B NUMERIC "1"
// Retrieval info: PRIVATE: OUTDATA_REG_B NUMERIC "1"
// Retrieval info: PRIVATE: CLRdata NUMERIC "0"
// Retrieval info: PRIVATE: CLRwren NUMERIC "0"
// Retrieval info: PRIVATE: CLRwraddress NUMERIC "0"
// Retrieval info: PRIVATE: CLRrdaddress NUMERIC "0"
// Retrieval info: PRIVATE: CLRrren NUMERIC "0"
// Retrieval info: PRIVATE: CLRq NUMERIC "0"
// Retrieval info: PRIVATE: BYTEENA_ACLR_A NUMERIC "0"
// Retrieval info: PRIVATE: INDATA_ACLR_B NUMERIC "0"
// Retrieval info: PRIVATE: WRCTRL_ACLR_B NUMERIC "0"
// Retrieval info: PRIVATE: WRADDR_ACLR_B NUMERIC "0"
// Retrieval info: PRIVATE: OUTDATA_ACLR_B NUMERIC "0"
// Retrieval info: PRIVATE: BYTEENA_ACLR_B NUMERIC "0"
// Retrieval info: PRIVATE: enable NUMERIC "0"
// Retrieval info: PRIVATE: CLOCK_ENABLE_INPUT_A NUMERIC "0"
// Retrieval info: PRIVATE: CLOCK_ENABLE_OUTPUT_A NUMERIC "0"
// Retrieval info: PRIVATE: CLOCK_ENABLE_INPUT_B NUMERIC "0"
// Retrieval info: PRIVATE: CLOCK_ENABLE_OUTPUT_B NUMERIC "0"
// Retrieval info: PRIVATE: ADDRESSSTALL_A NUMERIC "0"
// Retrieval info: PRIVATE: ADDRESSSTALL_B NUMERIC "0"
// Retrieval info: PRIVATE: READ_DURING_WRITE_MODE_MIXED_PORTS NUMERIC "0"
// Retrieval info: PRIVATE: BlankMemory NUMERIC "1"
// Retrieval info: PRIVATE: MIFfilename STRING ""
// Retrieval info: PRIVATE: UseLCs NUMERIC "0"
// Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
// Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "0"
// Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_A"
// Retrieval info: PRIVATE: MEGAFN_PORT_INFO_0 STRING "wren;data;wraddress;inclock;inclocken"
// Retrieval info: PRIVATE: MEGAFN_PORT_INFO_1 STRING "rden;rdaddress;outclock;outclocken;aclr"
// Retrieval info: PRIVATE: MEGAFN_PORT_INFO_2 STRING "q"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "EXCALIBUR_ARM"
// Retrieval info: CONSTANT: WIDTH NUMERIC "16"
// Retrieval info: CONSTANT: WIDTHAD NUMERIC "7"
// Retrieval info: CONSTANT: INDATA_REG STRING "INCLOCK"
// Retrieval info: CONSTANT: WRADDRESS_REG STRING "INCLOCK"
// Retrieval info: CONSTANT: WRCONTROL_REG STRING "INCLOCK"
// Retrieval info: CONSTANT: RDADDRESS_REG STRING "UNREGISTERED"
// Retrieval info: CONSTANT: RDCONTROL_REG STRING "UNREGISTERED"
// Retrieval info: CONSTANT: OUTDATA_REG STRING "UNREGISTERED"
// Retrieval info: CONSTANT: INDATA_ACLR STRING "OFF"
// Retrieval info: CONSTANT: WRADDRESS_ACLR STRING "OFF"
// Retrieval info: CONSTANT: WRCONTROL_ACLR STRING "OFF"
// Retrieval info: CONSTANT: RDADDRESS_ACLR STRING "OFF"
// Retrieval info: CONSTANT: RDCONTROL_ACLR STRING "OFF"
// Retrieval info: CONSTANT: OUTDATA_ACLR STRING "OFF"
// Retrieval info: CONSTANT: LPM_TYPE STRING "altdpram"
// Retrieval info: CONSTANT: USE_EAB STRING "ON"
// Retrieval info: USED_PORT: data 0 0 16 0 INPUT NODEFVAL data[15..0]
// Retrieval info: USED_PORT: q 0 0 16 0 OUTPUT NODEFVAL q[15..0]
// Retrieval info: USED_PORT: wraddress 0 0 7 0 INPUT NODEFVAL wraddress[6..0]
// Retrieval info: USED_PORT: rdaddress 0 0 7 0 INPUT NODEFVAL rdaddress[6..0]
// Retrieval info: USED_PORT: wren 0 0 0 0 INPUT VCC wren
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
// Retrieval info: CONNECT: @data 0 0 16 0 data 0 0 16 0
// Retrieval info: CONNECT: q 0 0 16 0 @q 0 0 16 0
// Retrieval info: CONNECT: @wraddress 0 0 7 0 wraddress 0 0 7 0
// Retrieval info: CONNECT: @rdaddress 0 0 7 0 rdaddress 0 0 7 0
// Retrieval info: CONNECT: @wren 0 0 0 0 wren 0 0 0 0
// Retrieval info: CONNECT: @inclock 0 0 0 0 clock 0 0 0 0
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: GEN_FILE: TYPE_NORMAL dim_pole_buffer.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL dim_pole_buffer.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dim_pole_buffer.cmp TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL dim_pole_buffer.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dim_pole_buffer_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dim_pole_buffer_bb.v TRUE
