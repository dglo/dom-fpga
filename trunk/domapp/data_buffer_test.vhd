-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : data_buffer.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-10-06
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module bufferes the incomming ADC (FADC and ATWD) data for
--              for the compression and engineering events
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-08-25  V01-01-00   thorsten  
-- 2003-10-06              thorsten  changed to 2 16bit memorys for 32bit read
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE WORK.icecube_data_types.all;


ENTITY data_buffer IS
	GENERIC (
		FADC_WIDTH		: INTEGER := 10
		);
	PORT (
		CLK40		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- data input
		HEADER_we	: IN STD_LOGIC;
		header_w	: IN HEADER_VECTOR;
		ATWD_waddr	: IN STD_LOGIC_VECTOR (8 downto 0);
		ATWD_wdata	: IN STD_LOGIC_VECTOR (9 downto 0);
		ATWD_we		: IN STD_LOGIC;
		FADC_waddr	: IN STD_LOGIC_VECTOR (7 downto 0);
		FADC_wdata	: IN STD_LOGIC_VECTOR (15 downto 0);
		FADC_we		: IN STD_LOGIC;
		buffer_full	: OUT STD_LOGIC;
		-- data output
		data_available	: OUT STD_LOGIC;
		read_done	: IN STD_LOGIC;
		header_r	: OUT HEADER_VECTOR;
		ATWD_raddr	: IN STD_LOGIC_VECTOR (7 downto 0);
		ATWD_rdata	: OUT STD_LOGIC_VECTOR (31 downto 0);
		FADC_raddr	: IN STD_LOGIC_VECTOR (6 downto 0);
		FADC_rdata	: OUT STD_LOGIC_VECTOR (31 downto 0);
		-- test connector
		TC			: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END data_buffer;


ARCHITECTURE arch_data_buffer OF data_buffer IS

	COMPONENT ATWD_buffer IS
		PORT (
			data		: IN STD_LOGIC_VECTOR (15 downto 0);
			wraddress	: IN STD_LOGIC_VECTOR (8 downto 0);
			rdaddress	: IN STD_LOGIC_VECTOR (8 downto 0);
			wren		: IN STD_LOGIC;
			clock		: IN STD_LOGIC;
			q			: OUT STD_LOGIC_VECTOR (15 downto 0)
		);
	END COMPONENT;

	COMPONENT FADC_buffer IS
		PORT (
			data		: IN STD_LOGIC_VECTOR (15 downto 0);
			wraddress	: IN STD_LOGIC_VECTOR (7 downto 0);
			rdaddress	: IN STD_LOGIC_VECTOR (7 downto 0);
			wren		: IN STD_LOGIC;
			clock		: IN STD_LOGIC;
			q			: OUT STD_LOGIC_VECTOR (15 downto 0)
		);
	END COMPONENT;
	
	SIGNAL wr_ptr		: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL rd_ptr		: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL full			: STD_LOGIC_VECTOR (1 DOWNTO 0);
	signal full_flag	: STD_LOGIC;
	
	SIGNAL w_buffer		: STD_LOGIC;	-- selects the write buffer
	SIGNAL r_buffer		: STD_LOGIC;	-- selects the read buffer
	
	-- Header register
	SIGNAL header_0		: HEADER_VECTOR;
	SIGNAL header_1		: HEADER_VECTOR;
	
	SIGNAL ATWD_wr_data : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS=>'0');
--	SIGNAL FADC_wr_data : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS=>'0');
	
	SIGNAL ATWD_we_EVEN	: STD_LOGIC;
	SIGNAL ATWD_we_ODD	: STD_LOGIC;
	SIGNAL FADC_we_EVEN	: STD_LOGIC;
	SIGNAL FADC_we_ODD	: STD_LOGIC;
	
BEGIN

	-- if write header: increment "full" counter; if read done: decrement full counter
	buffer_control : PROCESS(CLK40, RST)
	BEGIN
		IF RST='1' THEN
			wr_ptr	<= (OTHERS=>'0');
			rd_ptr	<= (OTHERS=>'0');
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			IF HEADER_we='1' THEN
				wr_ptr <= wr_ptr + 1;
			END IF;
			IF read_done='1' THEN
				rd_ptr <= rd_ptr + 1;
			END IF;			
		END IF;
	END PROCESS;
	full <= wr_ptr - rd_ptr;
	full_flag <= '1' WHEN full=2 ELSE '0';
	buffer_full	<= full_flag;
	data_available	<= '1' WHEN full/=0 ELSE '0';
	
	w_buffer	<= wr_ptr(0);
	r_buffer	<= rd_ptr(0);

	write_control : PROCESS(CLK40, RST)
	BEGIN
		IF RST='1' THEN
		ELSIF CLK40'EVENT AND CLK40='1' THEN
		END IF;
	END PROCESS;
	
	read_control : PROCESS(CLK40, RST)
	BEGIN
		IF RST='1' THEN
		ELSIF CLK40'EVENT AND CLK40='1' THEN
		END IF;
	END PROCESS;
	
	header_latch : PROCESS(CLK40, RST)
	BEGIN
		IF RST='1' THEN
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			IF HEADER_we='1' AND w_buffer='0' THEN	-- header for buffer 0
				header_0 <= HEADER_w;
			ELSE
			END IF;
			IF HEADER_we='1' AND w_buffer='1' THEN	-- header for buffer 1
				header_1 <= HEADER_w;
			ELSE
			END IF;
		END IF;
	END PROCESS;
	-- header read mux
	HEADER_r <= header_0 WHEN r_buffer='0' ELSE header_1;
	
	
	ATWD_we_EVEN	<= ATWD_we AND NOT ATWD_waddr(0);
	ATWD_we_ODD		<= ATWD_we AND ATWD_waddr(0);
	
	ATWD_wr_data(9 DOWNTO 0)	<= ATWD_wdata;
	ATWD_wr_data(15 DOWNTO 10)	<= "000000";

	inst_ATWD_buffer_even : ATWD_buffer
		PORT MAP (
			data				=> ATWD_wr_data,
			wraddress (8)		=> w_buffer,
			wraddress (7 DOWNTO 0)	=> ATWD_waddr (8 DOWNTO 1),
			rdaddress (8)		=> r_buffer,
			rdaddress (7 DOWNTO 0)	=> ATWD_raddr,
			wren				=> ATWD_we_EVEN,
			clock				=> CLK40,
			q					=> open --ATWD_rdata (15 DOWNTO 0)
		);
		
	inst_ATWD_buffer_odd : ATWD_buffer
		PORT MAP (
			data				=> ATWD_wr_data,
			wraddress (8)		=> w_buffer,
			wraddress (7 DOWNTO 0)	=> ATWD_waddr (8 DOWNTO 1),
			rdaddress (8)		=> r_buffer,
			rdaddress (7 DOWNTO 0)	=> ATWD_raddr,
			wren				=> ATWD_we_ODD,
			clock				=> CLK40,
			q					=> open --ATWD_rdata (31 DOWNTO 16)
			);
			
	readtestatwd : PROCESS(RST, CLK40)
	BEGIN
		IF RST='1' THEN
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			ATWD_rdata (7 DOWNTO 0)	<= ATWD_raddr;
			ATWD_rdata (31 DOWNTO 8)	<= (OTHERS=>'0');
			ATWD_rdata (30)	<= '1';
		END IF;
	END PROCESS;
			
	FADC_we_EVEN	<= FADC_we AND NOT FADC_waddr(0);
	FADC_we_ODD		<= FADC_we AND FADC_waddr(0);

	inst_FADC_buffer_even : FADC_buffer
		PORT MAP (
			data	=> FADC_wdata,
			wraddress (7)	=> w_buffer,
			wraddress (6 DOWNTO 0)	=> FADC_waddr (7 DOWNTO 1),
			rdaddress (7)	=> r_buffer,
			rdaddress (6 DOWNTO 0)	=> FADC_raddr,
			wren		=> FADC_we_EVEN,
			clock		=> CLK40,
			q			=> open --FADC_rdata (15 DOWNTO 0)
		);
		
	inst_FADC_buffer_odd : FADC_buffer
		PORT MAP (
			data	=> FADC_wdata,
			wraddress (7)	=> w_buffer,
			wraddress (6 DOWNTO 0)	=> FADC_waddr (7 DOWNTO 1),
			rdaddress (7)	=> r_buffer,
			rdaddress (6 DOWNTO 0)	=> FADC_raddr,
			wren		=> FADC_we_ODD,
			clock		=> CLK40,
			q			=> open --FADC_rdata (31 DOWNTO 16)
		);
		
	readtestfadc : PROCESS(RST, CLK40)
	BEGIN
		IF RST='1' THEN
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			FADC_rdata (6 DOWNTO 0)	<= FADC_raddr;
			FADC_rdata (31 DOWNTO 7)	<= (OTHERS=>'0');
			FADC_rdata (31)	<= '1';
		END IF;
	END PROCESS;
	
END;
