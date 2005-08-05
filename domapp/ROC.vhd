-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : ROC.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-07-17
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module provides a reset signal after the FPGA configures
--              I couldn't find a good way to do that
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY ROC IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: OUT STD_LOGIC
	);
END ROC;

ARCHITECTURE arch_ROC OF ROC IS

	TYPE STATE_TYPE IS (RST0, RST1, RUN);
	SIGNAL RST_state : STATE_TYPE;
	
BEGIN

	PROCESS(CLK)
	BEGIN
		IF CLK'EVENT AND CLK='1' THEN
			CASE RST_state IS
				WHEN RST0 =>
					RST <= '1';
					RST_state <= RST1;
				WHEN RST1 =>
					RST <= '1';
					RST_state <= RUN;
				WHEN RUN =>
					RST <= '0';
					RST_state <= RUN;
			END CASE;
		END IF;
	END PROCESS;

END;