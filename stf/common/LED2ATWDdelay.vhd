-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : LED2ATWDdelay.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-09-10
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module delays the on board LED tigger signal to use it to
--              launch the ATWD
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-09-10  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY LED2ATWDdelay IS
	PORT (
		CLK40		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		delay		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		LEDin		: IN STD_LOGIC;
		TRIGout		: OUT STD_LOGIC;
		-- test connector
		TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END LED2ATWDdelay;


ARCHITECTURE arch_LED2ATWDdelay OF LED2ATWDdelay IS

	SIGNAL SRG	: STD_LOGIC_VECTOR (15 DOWNTO 0);
			
BEGIN
	
	PROCESS (CLK40, RST)
	BEGIN
		IF RST='1' THEN
			SRG <= (OTHERS=>'0');
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			SRG(15 DOWNTO 1) <= SRG(14 DOWNTO 0);
			IF LEDin='1' AND SRG=0 THEN
				SRG(0) <= '1';
			ELSE
				SRG(0) <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	TRIGout <= SRG(CONV_INTEGER(delay));
	
END;