-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : master_data_source.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-07-17
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module input data to test ahb_master.vhd
--              this module is for debugging only
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


ENTITY master_data_source IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- control signals
		enable		: IN STD_LOGIC;
		done		: OUT STD_LOGIC;
		berr		: OUT STD_LOGIC;
		addr_start	: IN STD_LOGIC_VECTOR(15 downto 0);
		-- local bus signals
		start_trans		: OUT	STD_LOGIC;
		address			: OUT	STD_LOGIC_VECTOR(31 downto 0);
		wdata			: OUT	STD_LOGIC_VECTOR(31 downto 0);
		wait_sig		: IN	STD_LOGIC;
		trans_length	: OUT	INTEGER;
		bus_error		: IN	STD_LOGIC
	);
END master_data_source;


ARCHITECTURE arch_master_data_source OF master_data_source IS
	CONSTANT LENGTH		: INTEGER := 256;
	SIGNAL start_trans_local	: STD_LOGIC;
BEGIN
	-- address			<= to_stdlogicvector(x"00800000");
	-- address			<= x"80000000";
	-- address			<= x"00800000";
	address(31 downto 16)	<= addr_start;
	address(15 downto 0)	<= (others=>'0');
	trans_length	<= LENGTH;
	start_trans		<= start_trans_local;
	
	PROCESS(CLK,RST)
		VARIABLE enable_old	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			enable_old	:= '0';
			start_trans_local	<= '0';
		ELSIF CLK'EVENT AND CLK='0' THEN
			IF enable_old='0' AND enable='1' THEN
				start_trans_local	<= '1';
			ELSE
				start_trans_local	<= '0';
			END IF;
			enable_old	:= enable;
		END IF;
	END PROCESS;
	
	PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			berr	<= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF start_trans_local='1' THEN
				berr	<= '0';
			ELSIF bus_error='1' THEN
				berr	<= '1';
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(CLK,RST)
		VARIABLE data	: STD_LOGIC_VECTOR(31 downto 0);
	BEGIN
		IF RST='1' THEN
			data	:= (others=>'0');
			done	<= '0';
		ELSIF CLK'EVENT AND CLK='0' THEN
			IF start_trans_local='1' THEN
				data	:= (others=>'0');
				done	<= '0';
			ELSIF data < CONV_INTEGER(LENGTH) THEN
				IF wait_sig='0' THEN
					data	:= data + 1;
				END IF;
			ELSE
				done	<= '1';
				data	:= (others=>'0');
			END IF;
	--		IF data(0)='0' THEN
				wdata	<= data;
	--		ELSE
	--			wdata	<= data XOR x"ffffffff";
	--		END IF;
		END IF;
	END PROCESS;
			

END;
