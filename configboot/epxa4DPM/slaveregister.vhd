-------------------------------------------------------------------------------
-- Title      : ConfigBoot
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : slaveregister.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-05-11
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module provides the registers for the CPU inside the FPGA
--              the module is connected to ahb_slave.vhd
-------------------------------------------------------------------------------
-- Copyright (c) 2004 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2004-05-11  V01-01-00   thorsten  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY slaveregister IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- connections to ahb_slave
		reg_write		: IN	STD_LOGIC;
		reg_address		: IN	STD_LOGIC_VECTOR(31 downto 0);
		reg_wdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
		reg_rdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		reg_enable		: IN	STD_LOGIC;
		reg_wait_sig	: OUT	STD_LOGIC;
		-- command register
		com_ctrl		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		com_status		: IN	STD_LOGIC_VECTOR(31 downto 0);
		tx_dpr_wadr		: OUT	STD_LOGIC_VECTOR(15 downto 0);
		tx_dpr_radr		: IN	STD_LOGIC_VECTOR(15 downto 0);
		rx_dpr_radr		: OUT	STD_LOGIC_VECTOR(15 downto 0);
		rx_addr			: IN	STD_LOGIC_VECTOR(15 downto 0);
		-- kale communication interface
		tx_pack_rdy			: OUT STD_LOGIC;
		rx_dpr_radr_stb		: OUT STD_LOGIC;
		-- test connector
		TC					: OUT	STD_LOGIC_VECTOR(7 downto 0)
	);
END slaveregister;

ARCHITECTURE arch_slaveregister OF slaveregister IS

	--
	SIGNAL com_ctrl_local		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL tx_dpr_wadr_local	: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL rx_dpr_radr_local	: STD_LOGIC_VECTOR (15 DOWNTO 0);
	
BEGIN
	reg_wait_sig <= '1';

	PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			reg_rdata	<= (others=>'0');
			
			com_ctrl_local		<= (others=>'0');
			tx_dpr_wadr_local	<= (others=>'0');
			rx_dpr_radr_local	<= (others=>'0');
			
		ELSIF CLK'EVENT AND CLK='1' THEN
			tx_pack_rdy	<= '0';
			rx_dpr_radr_stb	<= '0';
			reg_rdata <= (others=>'X');
			IF reg_enable = '1' THEN
				CASE reg_address(11 downto 2) IS
					WHEN "0101000000" =>	-- com control
						IF reg_write = '1' THEN
							com_ctrl_local <= reg_wdata;
						ELSE
							reg_rdata <= com_ctrl_local;
							reg_rdata(31 DOWNTO 1)	<= (OTHERS=>'0');
						END IF;
					WHEN "0101000001" => -- com status
						IF reg_write = '1' THEN
						ELSE
							reg_rdata <= com_status;
						END IF;
					WHEN "0101000010" =>	-- tx_dpr_wadr
						IF reg_write = '1' THEN
							tx_dpr_wadr_local <= reg_wdata (15 DOWNTO 0);
							tx_pack_rdy	<= '1';
						ELSE
							reg_rdata (15 DOWNTO 0)		<= tx_dpr_wadr_local;
							reg_rdata (31 DOWNTO 16)	<= (OTHERS=>'0');
						END IF;
					WHEN "0101000011" =>	-- tx_dpr_radr
						IF reg_write = '1' THEN
						ELSE
							reg_rdata (15 DOWNTO 0)		<= tx_dpr_radr;
							reg_rdata (31 DOWNTO 16)	<= (OTHERS=>'0');
						END IF;
					WHEN "0101000100" =>	-- rx_dpr_radr
						IF reg_write = '1' THEN
							rx_dpr_radr_stb	<= '1';
							rx_dpr_radr_local <= reg_wdata (15 DOWNTO 0);
						ELSE
							reg_rdata (15 DOWNTO 0)		<= rx_dpr_radr_local;
							reg_rdata (31 DOWNTO 16)	<= (OTHERS=>'0');
						END IF;
					WHEN "0101000101" =>	-- rx_addr
						IF reg_write = '1' THEN
						ELSE
							reg_rdata (15 DOWNTO 0)		<= rx_addr;
							reg_rdata (31 DOWNTO 16)	<= (OTHERS=>'0');
						END IF;
					WHEN OTHERS =>
						IF reg_write = '1' THEN
						ELSE
							reg_rdata <= (OTHERS=>'0');
						END IF;
				END CASE;
			ELSE	-- reg_enable='0'
				NULL;
			END IF;	-- reg_enable
		END IF;
	END PROCESS;
	
	com_ctrl	<= com_ctrl_local;
	tx_dpr_wadr	<= tx_dpr_wadr_local;
	rx_dpr_radr	<= rx_dpr_radr_local;
	
END;