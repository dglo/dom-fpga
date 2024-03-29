-- megafunction wizard: %LPM_OR%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: lpm_or 

-- ============================================================
-- File Name: my_or16b.vhd
-- Megafunction Name(s):
-- 			lpm_or
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 4.0 Build 214 3/25/2004 SP 1 SJ Full Version
-- ************************************************************


--Copyright (C) 1991-2004 Altera Corporation
--Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
--support information,  device programming or simulation file,  and any other
--associated  documentation or information  provided by  Altera  or a partner
--under  Altera's   Megafunction   Partnership   Program  may  be  used  only
--to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
--other  use  of such  megafunction  design,  netlist,  support  information,
--device programming or simulation file,  or any other  related documentation
--or information  is prohibited  for  any  other purpose,  including, but not
--limited to  modification,  reverse engineering,  de-compiling, or use  with
--any other  silicon devices,  unless such use is  explicitly  licensed under
--a separate agreement with  Altera  or a megafunction partner.  Title to the
--intellectual property,  including patents,  copyrights,  trademarks,  trade
--secrets,  or maskworks,  embodied in any such megafunction design, netlist,
--support  information,  device programming or simulation file,  or any other
--related documentation or information provided by  Altera  or a megafunction
--partner, remains with Altera, the megafunction partner, or their respective
--licensors. No other licenses, including any licenses needed under any third
--party's intellectual property, are provided herein.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.lpm_components.all;

ENTITY my_or16b IS
	PORT
	(
		data		: IN STD_LOGIC_2D (15 DOWNTO 0, 0 DOWNTO 0);
		result		: OUT STD_LOGIC 
	);
END my_or16b;


ARCHITECTURE SYN OF my_or16b IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (0 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC ;



	COMPONENT lpm_or
	GENERIC (
		lpm_size		: NATURAL;
		lpm_width		: NATURAL;
		lpm_type		: STRING
	);
	PORT (
			data	: IN STD_LOGIC_2D (15 DOWNTO 0, 0 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	sub_wire1    <= sub_wire0(0);
	result    <= sub_wire1;

	lpm_or_component : lpm_or
	GENERIC MAP (
		lpm_size => 16,
		lpm_width => 1,
		lpm_type => "LPM_OR"
	)
	PORT MAP (
		data => data,
		result => sub_wire0
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: nInput NUMERIC "16"
-- Retrieval info: PRIVATE: WidthInput NUMERIC "1"
-- Retrieval info: PRIVATE: CompactSymbol NUMERIC "0"
-- Retrieval info: PRIVATE: InputAsBus NUMERIC "1"
-- Retrieval info: PRIVATE: GateFunction NUMERIC "1"
-- Retrieval info: PRIVATE: MEGAFN_PORT_INFO_0 STRING "data;result"
-- Retrieval info: CONSTANT: LPM_SIZE NUMERIC "16"
-- Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "1"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_OR"
-- Retrieval info: USED_PORT: data 16 0 1 0 INPUT NODEFVAL data[15..0][0..0]
-- Retrieval info: USED_PORT: result 0 0 0 0 OUTPUT NODEFVAL result
-- Retrieval info: CONNECT: @data 16 0 1 0 data 16 0 1 0
-- Retrieval info: CONNECT: result 0 0 0 0 @result 0 0 1 0
-- Retrieval info: LIBRARY: lpm lpm.lpm_components.all
-- Retrieval info: GEN_FILE: TYPE_NORMAL my_or16b.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL my_or16b.inc TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL my_or16b.cmp FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL my_or16b.bsf TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL my_or16b_inst.vhd FALSE
