-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : slaveregister.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-12-03
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module provides the registers for the CPU inside the FPGA
--              the module is connected to ahb_slave.vhd
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
USE IEEE.numeric_std.all;

USE WORK.ctrl_data_types.all;

ENTITY slaveregister IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		systime		: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		-- connections to the stripe
		masterhclk		: OUT	STD_LOGIC;
		masterhready	: OUT	STD_LOGIC;
		masterhgrant	: OUT	STD_LOGIC;
		masterhrdata	: OUT	STD_LOGIC_VECTOR(31 downto 0);
		masterhresp		: OUT	STD_LOGIC_VECTOR(1 downto 0);
		masterhwrite	: IN	STD_LOGIC;
		masterhlock		: IN	STD_LOGIC;
		masterhbusreq	: IN	STD_LOGIC;
		masterhaddr		: IN	STD_LOGIC_VECTOR(31 downto 0);
		masterhburst	: IN	STD_LOGIC_VECTOR(2 downto 0);
		masterhsize		: IN	STD_LOGIC_VECTOR(1 downto 0);
		masterhtrans	: IN	STD_LOGIC_VECTOR(1 downto 0);
		masterhwdata	: IN	STD_LOGIC_VECTOR(31 downto 0);
		-- command register
		DAQ_ctrl		: OUT DAQ_STRUCT;
		CS_ctrl			: OUT CS_STRUCT;
		LC_ctrl			: OUT LC_STRUCT;
		RM_ctrl			: OUT RM_STRUCT;
		DOM_status		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		-- pointers
		LBM_ptr			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rm_sn_pointer	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		-- rate meters
		rm_rate_SPE		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		rm_rate_MPE		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- kale communication interface
		-- R2R ladder
		cs_wf_data		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		cs_wf_addr		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		-- ATWD A pedestal
		ATWD_ped_data_A	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		ATWD_ped_addr_A	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		-- ATWD B pedestal
		ATWD_ped_data_B	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		ATWD_ped_addr_B	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END slaveregister;

ARCHITECTURE arch_slaveregister OF slaveregister IS

	CONSTANT READBACK	: INTEGER := 1;	-- enable readbach of write registers

	COMPONENT ahb_slave
		PORT (
			CLK				: IN STD_LOGIC;
			RST				: IN STD_LOGIC;
			-- connections to the stripe
			masterhclk		: OUT	STD_LOGIC;
			masterhready	: OUT	STD_LOGIC;
			masterhgrant	: OUT	STD_LOGIC;
			masterhrdata	: OUT	STD_LOGIC_VECTOR(31 downto 0);
			masterhresp		: OUT	STD_LOGIC_VECTOR(1 downto 0);
			masterhwrite	: IN	STD_LOGIC;
			masterhlock		: IN	STD_LOGIC;
			masterhbusreq	: IN	STD_LOGIC;
			masterhaddr		: IN	STD_LOGIC_VECTOR(31 downto 0);
			masterhburst	: IN	STD_LOGIC_VECTOR(2 downto 0);
			masterhsize		: IN	STD_LOGIC_VECTOR(1 downto 0);
			masterhtrans	: IN	STD_LOGIC_VECTOR(1 downto 0);
			masterhwdata	: IN	STD_LOGIC_VECTOR(31 downto 0);
			-- local bus signals
			reg_write		: OUT	STD_LOGIC;
			reg_address		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			reg_wdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			reg_rdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
			reg_enable		: OUT	STD_LOGIC;
			reg_wait_sig	: IN	STD_LOGIC
		);
	END COMPONENT;
	
	SIGNAL reg_write	: STD_LOGIC;
	SIGNAL reg_address	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_wdata	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_rdata	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_enable	: STD_LOGIC;
	SIGNAL reg_wait_sig	: STD_LOGIC;

	-- rom interface
	SIGNAL rom_data		: STD_LOGIC_VECTOR (15 downto 0);
	
	COMPONENT version_rom
		PORT (
			address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
			q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT R2Rram
		PORT (
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			wraddress	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdaddress	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			wren		: IN STD_LOGIC;
			clock		: IN STD_LOGIC;
			q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT ATWDped
		PORT (
			data		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			wraddress	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			rdaddress	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			wren		: IN STD_LOGIC;
			clock		: IN STD_LOGIC;
			q			: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	END COMPONENT;
	
	SIGNAL DAQ_ctrl_local	: DAQ_STRUCT;
	SIGNAL CS_ctrl_local	: CS_STRUCT;
	SIGNAL RM_ctrl_local	: RM_STRUCT;
	
	-- memory write enable signals
	SIGNAL R2Rwe		: STD_LOGIC;
	SIGNAL ATWDApedwe	: STD_LOGIC;
	SIGNAL ATWDBpedwe	: STD_LOGIC;
	
BEGIN
	reg_wait_sig <= '1';


	-- Implementation comments:
	-- For read only registers it is not necessary to check the RW signal
	-- This saves resources. It doesn't matter if the read bus gets set.
	-- Actually we can do the same thing for RW registers to save resources.
	PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			DAQ_ctrl_local.LBM_ptr_RST	<= '0';
			CS_ctrl_local.CS_CPU		<= '0';
			DAQ_ctrl_local	<= ('0', "00", (OTHERS=>'0'), "00", "00", "00", "00", "00", '0');
			CS_ctrl_local	<= ((OTHERS=>'0'), "000", (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), '0', '0');
		ELSIF CLK'EVENT AND CLK='1' THEN
			CS_ctrl_local.CS_CPU	<= '0';
			reg_rdata <= (others=>'X');	-- to make sur ewe don't create a latch
			IF reg_enable = '1' THEN
				IF std_match( reg_address(13 downto 2) , "00000-------" ) THEN	-- version ROM
					reg_rdata(15 downto 0)	<= rom_data;
					reg_rdata(31 downto 16)	<= (OTHERS=>'0');
				ELSIF std_match( reg_address(13 downto 2) , "000100000000" ) THEN	-- Trigger Source
					IF reg_write = '1' THEN
						DAQ_ctrl_local.trigger_enable	<= reg_wdata(15 downto 0);
					END IF;
					IF READBACK=1 THEN
						reg_rdata(15 downto 0)	<= DAQ_ctrl_local.trigger_enable;
						reg_rdata(31 downto 16)	<= (OTHERS=>'0');
					ELSE
						reg_rdata(31 downto 0)	<= (OTHERS=>'0');
					END IF;
				ELSIF std_match( reg_address(13 downto 2) , "000100000001" ) THEN	-- Trigger Setup
					NULL;	-- no function defined yet
				ELSIF std_match( reg_address(13 downto 2) , "000100000010" ) THEN	-- DAQ
					IF reg_write = '1' THEN
						DAQ_ctrl_local.enable_DAQ	<= reg_wdata(0);
						DAQ_ctrl_local.enable_AB	<= reg_wdata(2 downto 1);
						DAQ_ctrl_local.DAQ_mode		<= reg_wdata(9 downto 8);
						DAQ_ctrl_local.ATWD_mode	<= reg_wdata(13 downto 12);
						DAQ_ctrl_local.LC_mode		<= reg_wdata(17 downto 16);
						DAQ_ctrl_local.LBM_mode		<= reg_wdata(21 downto 20);
						DAQ_ctrl_local.COMPR_mode	<= reg_wdata(25 downto 24);
					END IF;
					IF READBACK=1 THEN
						reg_rdata(31 downto 0)	<= (OTHERS=>'0');
						reg_rdata(0)			<= DAQ_ctrl_local.enable_DAQ;
						reg_rdata(2 downto 1)	<= DAQ_ctrl_local.enable_AB;
						reg_rdata(9 downto 8)	<= DAQ_ctrl_local.DAQ_mode;
						reg_rdata(17 downto 16)	<= DAQ_ctrl_local.LC_mode;
						reg_rdata(21 downto 20)	<= DAQ_ctrl_local.LBM_mode;
						reg_rdata(25 downto 24)	<= DAQ_ctrl_local.COMPR_mode;
					ELSE
						reg_rdata(31 downto 0)	<= (OTHERS=>'0');
					END IF;
				ELSIF std_match( reg_address(13 downto 2) , "000100000011" ) THEN	-- LBM control
					IF reg_write = '1' THEN
						DAQ_ctrl_local.LBM_ptr_RST	<= reg_wdata(0);
					END IF;
					IF READBACK=1 THEN
						reg_rdata(31 downto 0)	<= (OTHERS=>'0');
					ELSE
						reg_rdata(31 downto 0)	<= (OTHERS=>'0');
					END IF;
				ELSIF std_match( reg_address(13 downto 2) , "000100000100" ) THEN	-- LBM pointer
					reg_rdata(31 downto 0)	<= LBM_ptr;
				ELSIF std_match( reg_address(13 downto 2) , "000100000101" ) THEN	-- DOM status
					reg_rdata(31 downto 0)	<= DOM_status;
				ELSIF std_match( reg_address(13 downto 2) , "000100000110" ) THEN	-- systime LSB
					reg_rdata(31 downto 0)	<= systime (31 DOWNTO 0);
				ELSIF std_match( reg_address(13 downto 2) , "000100000111" ) THEN	-- systime MSB
					reg_rdata(15 downto 0)	<= systime (47 DOWNTO 32);
					reg_rdata(31 downto 16)	<= (OTHERS=>'0');
				ELSIF std_match( reg_address(13 downto 2) , "000100001000" ) THEN	-- Local Coincidence Control
				ELSIF std_match( reg_address(13 downto 2) , "000100001001" ) THEN	-- Calibration Source Control
					IF reg_write = '1' THEN
						CS_ctrl_local.CS_enable	<= reg_wdata(5 downto 0);
						CS_ctrl_local.CS_mode	<= reg_wdata(14 downto 12);
						CS_ctrl_local.CS_offset	<= reg_wdata(19 downto 16);
						CS_ctrl_local.CS_rate	<= reg_wdata(28 downto 24);
					END IF;
					IF READBACK=1 THEN
						reg_rdata(31 downto 0)	<= (OTHERS=>'0');
						reg_rdata(5 downto 0)	<= CS_ctrl_local.CS_enable;
						reg_rdata(14 downto 12)	<= CS_ctrl_local.CS_mode;
						reg_rdata(19 downto 16)	<= CS_ctrl_local.CS_offset;
						reg_rdata(28 downto 24)	<= CS_ctrl_local.CS_rate;
					ELSE
						reg_rdata(31 downto 0)	<= (OTHERS=>'0');
					END IF;
				ELSIF std_match( reg_address(13 downto 2) , "000100001010" ) THEN	-- Calibration Time
					IF reg_write = '1' THEN
						CS_ctrl_local.CS_time	<= reg_wdata(31 downto 0);
					END IF;
					IF READBACK=1 THEN
						reg_rdata(31 downto 0)	<= CS_ctrl_local.CS_time;
					ELSE
						reg_rdata(31 downto 0)	<= (OTHERS=>'0');
					END IF;
				ELSIF std_match( reg_address(13 downto 2) , "000100001011" ) THEN	-- Calibration CPU launch
					IF reg_write = '1' THEN
						IF reg_wdata(7 downto 0)=X"A5" THEN
							CS_ctrl_local.CS_CPU	<= '1';
						END IF;
					END IF;
					reg_rdata(31 downto 0)	<= (OTHERS=>'0');
				ELSIF std_match( reg_address(13 downto 2) , "000100001100" ) THEN	-- Rate Monitor Control
					IF reg_write = '1' THEN
						RM_ctrl_local.RM_rate_enable	<= reg_wdata(1 downto 0);
						RM_ctrl_local.RM_rate_dead		<= reg_wdata(25 downto 16);
					END IF;
					IF READBACK=1 THEN
						reg_rdata(1 downto 0)	<= RM_ctrl_local.RM_rate_enable;
						reg_rdata(15 downto 2)	<= (OTHERS=>'0');
						reg_rdata(25 downto 16)	<= RM_ctrl_local.RM_rate_dead;
						reg_rdata(31 downto 26)	<= (OTHERS=>'0');
					ELSE
						reg_rdata(31 downto 0)	<= (OTHERS=>'0');
					END IF;
				ELSIF std_match( reg_address(13 downto 2) , "000100001101" ) THEN	-- Rate Monitor SPE
					reg_rdata(31 downto 0)	<= rm_rate_SPE;
				ELSIF std_match( reg_address(13 downto 2) , "000100001110" ) THEN	-- Rate Monitor MPE
					reg_rdata(31 downto 0)	<= rm_rate_MPE;
				ELSIF std_match( reg_address(13 downto 2) , "000100001111" ) THEN	-- Supernove Meter Control
					IF reg_write = '1' THEN
						RM_ctrl_local.RM_sn_enable	<= reg_wdata(1 downto 0);
						RM_ctrl_local.RM_sn_dead		<= reg_wdata(18 downto 16);
					END IF;
					IF READBACK=1 THEN
						reg_rdata(1 downto 0)	<= RM_ctrl_local.RM_sn_enable;
						reg_rdata(15 downto 2)	<= (OTHERS=>'0');
						reg_rdata(18 downto 16)	<= RM_ctrl_local.RM_sn_dead;
						reg_rdata(31 downto 19)	<= (OTHERS=>'0');
					ELSE
						reg_rdata(31 downto 0)	<= (OTHERS=>'0');
					END IF;
				ELSIF std_match( reg_address(13 downto 2) , "000100010000" ) THEN	-- Supernove Pointer
					reg_rdata(31 downto 0)	<= rm_sn_pointer;
				-- ELSIF communication
				ELSIF std_match( reg_address(13 downto 2) , "000100010110" ) THEN	-- Compression Control
					NULL;	-- not defined yet
					
				ELSIF std_match( reg_address(13 downto 2) , "000101000000" ) THEN	-- Communication Control
					NULL;	-- not defined yet
				ELSIF std_match( reg_address(13 downto 2) , "000101000001" ) THEN	-- Communication Control Response
					NULL;	-- not defined yet
				ELSIF std_match( reg_address(13 downto 2) , "000101000010" ) THEN	-- Communication tx_dpr_wadr
					NULL;	-- not defined yet
				ELSIF std_match( reg_address(13 downto 2) , "000101000011" ) THEN	-- Communication tx_wadr_radr
					NULL;	-- not defined yet
				ELSIF std_match( reg_address(13 downto 2) , "000101000100" ) THEN	-- Communication rx_dpr_radr
					NULL;	-- not defined yet
				ELSIF std_match( reg_address(13 downto 2) , "000101000101" ) THEN	-- Communication rx_addr
					NULL;	-- not defined yet
				ELSIF std_match( reg_address(13 downto 2) , "000101000110" ) THEN	-- Communication Packets in RX buffer
					reg_rdata(31 downto 0)	<= (OTHERS=>'X');
				ELSIF std_match( reg_address(13 downto 2) , "000101000111" ) THEN	-- Communication Error
					reg_rdata(31 downto 0)	<= (OTHERS=>'X');
				ELSIF std_match( reg_address(13 downto 2) , "000101001000" ) THEN	-- DOM ID LSB
					reg_rdata(31 downto 0)	<= (OTHERS=>'X');
				ELSIF std_match( reg_address(13 downto 2) , "000101001001" ) THEN	-- DOM ID MSB
					reg_rdata(31 downto 0)	<= (OTHERS=>'X');
					
				ELSIF std_match( reg_address(13 downto 2) , "000100010110" ) THEN	-- PONG (just in case we want to implement a 3D PONG game with IceCubeA) 
					reg_rdata(31 downto 0) <= X"504F4E47";	-- ASCII PONG
				ELSIF std_match( reg_address(13 downto 2) , "000111111111" ) THEN	-- Firmware Debugging
					NULL;
				ELSIF std_match( reg_address(13 downto 2) , "0010--------" ) THEN	-- Supernova
				ELSIF std_match( reg_address(13 downto 2) , "0011--------" ) THEN	-- R2R Pattern
					NULL;
				ELSIF std_match( reg_address(13 downto 2) , "010---------" ) THEN	-- ATWD A pedestal
					NULL;
				ELSIF std_match( reg_address(13 downto 2) , "011---------" ) THEN	-- ATWD B pedestal
					NULL;
				ELSE
					reg_rdata(31 downto 0) <= (others=>'0');
				END IF;
			ELSE	-- reg_enable='0'
				reg_rdata <= (others=>'X');
			END IF;	-- reg_enable
		END IF;	-- CLK
	END PROCESS;


	-- map local signals to the ENTITY PORTS	
	DAQ_ctrl	<= DAQ_ctrl_local;
	CS_ctrl		<= CS_ctrl_local;
	
	-- create write enable for the memory blocks (pedestal & R2R)
	R2Rwe <= '1' WHEN reg_write='1' AND reg_enable = '1' AND std_match( reg_address(13 downto 2) , "0011--------" ) ELSE '0';
	ATWDApedwe <= '1' WHEN reg_write='1' AND reg_enable = '1' AND std_match( reg_address(13 downto 2) , "010---------" ) ELSE '0';
	ATWDBpedwe <= '1' WHEN reg_write='1' AND reg_enable = '1' AND std_match( reg_address(13 downto 2) , "011---------" ) ELSE '0';
	
	
	-- stripe interface
	inst_ahb_slave : ahb_slave
		PORT MAP (
			CLK				=> CLK,
			RST				=> RST,
			-- connections to the stripe
			masterhclk		=> masterhclk,
			masterhready	=> masterhready,
			masterhgrant	=> masterhgrant,
			masterhrdata	=> masterhrdata,
			masterhresp		=> masterhresp,
			masterhwrite	=> masterhwrite,
			masterhlock		=> masterhlock,
			masterhbusreq	=> masterhbusreq,
			masterhaddr		=> masterhaddr,
			masterhburst	=> masterhburst,
			masterhsize		=> masterhsize,
			masterhtrans	=> masterhtrans,
			masterhwdata	=> masterhwdata,
			-- local bus signals
			reg_write		=> reg_write,
			reg_address		=> reg_address,
			reg_wdata		=> reg_wdata,
			reg_rdata		=> reg_rdata,
			reg_enable		=> reg_enable,
			reg_wait_sig	=> reg_wait_sig
		);
	
	-- MEMORYs
	inst_version_rom : version_rom
		PORT MAP (
			address		=> reg_address(8 DOWNTO 2),
			q			=> rom_data
		);
		
	inst_R2R : R2Rram
		PORT MAP (
			data		=> reg_wdata(7 DOWNTO 0),
			wraddress	=> reg_address(9 DOWNTO 2),
			rdaddress	=> cs_wf_addr,
			wren		=> R2Rwe,
			clock		=> CLK,
			q			=> cs_wf_data
		);
	
	inst_ATWDAped : ATWDped
		PORT MAP (
			data		=> reg_wdata(9 DOWNTO 0),
			wraddress	=> reg_address(10 DOWNTO 2),
			rdaddress	=> ATWD_ped_addr_A,
			wren		=> ATWDApedwe,
			clock		=> CLK,
			q			=> ATWD_ped_data_A
		);
		
	inst_ATWDBped : ATWDped
		PORT MAP (
			data		=> reg_wdata(9 DOWNTO 0),
			wraddress	=> reg_address(10 DOWNTO 2),
			rdaddress	=> ATWD_ped_addr_B,
			wren		=> ATWDBpedwe,
			clock		=> CLK,
			q			=> ATWD_ped_data_B
		);
	
END;








