-- Copyright (C) 1991-2002 Altera Corporation
-- Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
-- support information,  device programming or simulation file,  and any other
-- associated  documentation or information  provided by  Altera  or a partner
-- under  Altera's   Megafunction   Partnership   Program  may  be  used  only
-- to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
-- other  use  of such  megafunction  design,  netlist,  support  information,
-- device programming or simulation file,  or any other  related documentation
-- or information  is prohibited  for  any  other purpose,  including, but not
-- limited to  modification,  reverse engineering,  de-compiling, or use  with
-- any other  silicon devices,  unless such use is  explicitly  licensed under
-- a separate agreement with  Altera  or a megafunction partner.  Title to the
-- intellectual property,  including patents,  copyrights,  trademarks,  trade
-- secrets,  or maskworks,  embodied in any such megafunction design, netlist,
-- support  information,  device programming or simulation file,  or any other
-- related documentation or information provided by  Altera  or a megafunction
-- partner, remains with Altera, the megafunction partner, or their respective
-- licensors. No other licenses, including any licenses needed under any third
-- party's intellectual property, are provided herein.
-- 

-- Excalibur stripe memory map.

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

package memmap is

CONSTANT REGISTERS_BASE_ADDRESS : std_logic_vector(31 downto 0) := "01111111111111111100000000000000";
CONSTANT REGISTERS_SIZE : std_logic_vector(31 downto 0) := "00000000000000000100000000000000";
CONSTANT SPSRAM0_BASE_ADDRESS : std_logic_vector(31 downto 0) := "00010000000000000000000000000000";
CONSTANT SPSRAM0_SIZE : std_logic_vector(31 downto 0) := "00000000000000000100000000000000";
CONSTANT SPSRAM1_BASE_ADDRESS : std_logic_vector(31 downto 0) := "00010000000001000000000000000000";
CONSTANT SPSRAM1_SIZE : std_logic_vector(31 downto 0) := "00000000000000000100000000000000";
CONSTANT DPSRAM0_BASE_ADDRESS : std_logic_vector(31 downto 0) := "10000000000000000000000000000000";
CONSTANT DPSRAM0_SIZE : std_logic_vector(31 downto 0) := "00000000000000010000000000000000";
CONSTANT SDRAM0_BASE_ADDRESS : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
CONSTANT SDRAM0_SIZE : std_logic_vector(31 downto 0) := "00000000100000000000000000000000";
CONSTANT SDRAM1_BASE_ADDRESS : std_logic_vector(31 downto 0) := "00000000100000000000000000000000";
CONSTANT SDRAM1_SIZE : std_logic_vector(31 downto 0) := "00000000100000000000000000000000";
CONSTANT EBI0_BASE_ADDRESS : std_logic_vector(31 downto 0) := "01000000000000000000000000000000";
CONSTANT EBI0_SIZE : std_logic_vector(31 downto 0) := "00000000010000000000000000000000";
CONSTANT EBI1_BASE_ADDRESS : std_logic_vector(31 downto 0) := "01000000010000000000000000000000";
CONSTANT EBI1_SIZE : std_logic_vector(31 downto 0) := "00000000010000000000000000000000";
CONSTANT EBI2_BASE_ADDRESS : std_logic_vector(31 downto 0) := "01010000000000000000000000000000";
CONSTANT EBI2_SIZE : std_logic_vector(31 downto 0) := "00000000000000000100000000000000";
CONSTANT EBI3_BASE_ADDRESS : std_logic_vector(31 downto 0) := "01100000000000000000000000000000";
CONSTANT EBI3_SIZE : std_logic_vector(31 downto 0) := "00000000000000010000000000000000";
CONSTANT PLD0_BASE_ADDRESS : std_logic_vector(31 downto 0) := "10010000000000000000000000000000";
CONSTANT PLD0_SIZE : std_logic_vector(31 downto 0) := "00000000000000000100000000000000";

end memmap;
