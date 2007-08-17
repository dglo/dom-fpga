-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : FADC_interface.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-08-27
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module 256 FADC samples into the data buffer
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-08-26  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

ENTITY FADC_interface IS
	GENERIC (
		FADC_WIDTH		: INTEGER := 10
	);
	PORT (
		CLK40			: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		-- enable
		FADC_enable		: IN STD_LOGIC;
		FADC_busy		: OUT STD_LOGIC;
		abort			: IN STD_LOGIC;
		trigger			: IN STD_LOGIC;
		-- FADC
		FADC_D			: IN STD_LOGIC_VECTOR (FADC_WIDTH-1 DOWNTO 0);
		FADC_NCO		: IN STD_LOGIC;
		-- buffer interface
		FADC_data		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		FADC_addr		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		FADC_we			: OUT STD_LOGIC;
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END FADC_interface;

ARCHITECTURE FADC_interface_arch OF FADC_interface IS

	SIGNAL triggered	: STD_LOGIC;
	SIGNAL wr_addr		: STD_LOGIC_VECTOR (7 DOWNTO 0);

BEGIN

	PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
		ELSIF CLK40'EVENT AND CLK40='0' THEN
			IF abort='1' THEN	-- local coincidence abort
				triggered <= '0';
				FADC_we	<= '0';
				wr_addr	<= (OTHERS=>'1'); -- -1
				FADC_busy	<= '0';
			ELSE
				IF (trigger='1' AND FADC_enable='1') OR triggered='1' THEN	-- acquire data
					IF wr_addr=x"FF" AND triggered='1' THEN	-- memory full
						triggered <= '0';
						FADC_we	<= '0';
						wr_addr	<= (OTHERS=>'1'); -- -1;
						FADC_busy	<= '0';
					ELSE	-- filling memory
						triggered <= '1';
						FADC_we	<= '1';
						wr_addr	<= wr_addr + 1;
						FADC_busy	<= '1';
					END IF;
				ELSE	-- idle
					triggered <= '0';
					FADC_we	<= '0';
					wr_addr	<= (OTHERS=>'1'); -- -1;
					FADC_busy	<= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	FADC_data(FADC_WIDTH-1 DOWNTO 0)	<= FADC_D;
	FADC_data(FADC_WIDTH)	<= FADC_NCO;
	FADC_data(15 DOWNTO FADC_WIDTH+1)	<= (OTHERS=>'0');
	
	FADC_addr	<= wr_addr;

END FADC_interface_arch;