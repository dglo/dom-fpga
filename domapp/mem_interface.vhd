-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : mem_interface.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-10-16
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module reads the ATWD/FADC and the compressed data and
--              writes it to the SDRAM
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-10-07  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE WORK.constants.all;
USE WORK.icecube_data_types.all;


ENTITY mem_interface IS
	PORT (
		CLK20			: IN STD_LOGIC;
		CLK40			: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		-- enable
		LBM_mode		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		LBM_ptr			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		LBM_ptr_RST		: IN STD_LOGIC;
		COMPR_mode		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		-- cdata interface A (ping)
		data_avail_A	: IN STD_LOGIC;
		read_done_A		: OUT STD_LOGIC;
		compr_avail_A	: IN STD_LOGIC;
		compr_size_A	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		compr_addr_A	: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
		compr_data_A	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		HEADER_A		: IN HEADER_VECTOR;
		ATWD_addr_A		: OUT STD_LOGIC_VECTOR (7 downto 0);
		ATWD_data_A		: IN STD_LOGIC_VECTOR (31 downto 0);
		FADC_addr_A		: OUT STD_LOGIC_VECTOR (6 downto 0);
		FADC_data_A		: IN STD_LOGIC_VECTOR (31 downto 0);
		-- data interface B (pong)
		data_avail_B	: IN STD_LOGIC;
		read_done_B		: OUT STD_LOGIC;
		compr_avail_B	: IN STD_LOGIC;
		compr_size_B	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		compr_addr_B	: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
		compr_data_B	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		HEADER_B		: IN HEADER_VECTOR;
		ATWD_addr_B		: OUT STD_LOGIC_VECTOR (7 downto 0);
		ATWD_data_B		: IN STD_LOGIC_VECTOR (31 downto 0);
		FADC_addr_B		: OUT STD_LOGIC_VECTOR (6 downto 0);
		FADC_data_B		: IN STD_LOGIC_VECTOR (31 downto 0);
		-- ahb_master interface
		start_trans		: OUT	STD_LOGIC;
		abort_trans		: OUT	STD_LOGIC;
		address			: OUT	STD_LOGIC_VECTOR(31 downto 0);
		ahb_address		: IN	STD_LOGIC_VECTOR(31 downto 0);
		wdata			: OUT	STD_LOGIC_VECTOR(31 downto 0);
		wait_sig		: IN	STD_LOGIC;
		trans_length	: OUT	INTEGER;
		bus_error		: IN	STD_LOGIC;
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END mem_interface;

ARCHITECTURE mem_interface_arch OF mem_interface IS

	TYPE STATE_TYPE IS (IDLE, SET_MUX, ENG_HDR0, ENG_HDR1, ENG_HDR2, ENG_HDR3, ENG_FADC, ENG_ATWD, ENG_END, COMP_XFER, COMP_END, DONE);
	SIGNAL state	: STATE_TYPE;
	
	SIGNAL ATWD_data	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL FADC_data	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL compr_data	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL header		: HEADER_VECTOR;
	SIGNAL compr_avail	: STD_LOGIC;
	SIGNAL compr_size	: STD_LOGIC_VECTOR (8 DOWNTO 0);
	
	SIGNAL header0		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL header1		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL header2		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL header3		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL AnB		: STD_LOGIC;
	SIGNAL rdaddr	: STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL read_done	: STD_LOGIC;
	
	SIGNAL start_address	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
BEGIN

	address	<= (start_address	-- local address pointer (bigger than memory space)
				AND X"FFFFF800"	-- align to 2k data blocks
				AND CONV_STD_LOGIC_VECTOR((2**SDRAM_SIZE)-1,32)) -- high address to SDRAM space (-> will wrap around)
				+ SDRAM_BASE;	-- SDRAM base address for look back memory
				
	LBM_ptr	<= (start_address AND X"0FFFF800") OR (ahb_address AND X"000007FF"); 

	xfer_machine : PROCESS(CLK20,RST)
	BEGIN
		IF RST='1' THEN
			state	<= IDLE;
			AnB		<= '0';
			start_address	<= (OTHERS=>'0');
			start_trans		<= '0';
			abort_trans		<= '0';
			rdaddr			<= (OTHERS=>'0');
		ELSIF CLK20'EVENT AND CLK20='1' THEN
			CASE state IS
				WHEN IDLE =>
					start_trans		<= '0';
					IF data_avail_A='1' OR data_avail_B='1' THEN
						state	<= SET_MUX;
						start_trans		<= '1';
					END IF;
				WHEN SET_MUX =>
					-- at least one (A or B) has data available
					IF AnB='1' THEN	-- last A
						IF data_avail_B='1' THEN
							AnB	<= '0';
						ELSE	-- A must be available
							AnB	<= '1';
						END IF;
					ELSE	-- last B
						IF data_avail_A='1' THEN
							AnB	<= '1';
						ELSE	-- B must be available
							AnB	<= '0';
						END IF;
					END IF;
					
					-- engineering or compressed data
					IF COMPR_mode=COMPR_ON AND compr_avail='1' THEN
						state	<= COMP_XFER;
					ELSE	-- engineering data is always available
						state	<= ENG_HDR0;
					END IF;
					start_trans		<= '1';
					abort_trans		<= '0';
					rdaddr	<= (OTHERS=>'0');
				WHEN ENG_HDR0 =>
					IF wait_sig='0' THEN
						state	<= ENG_HDR1;
					END IF;
					start_trans		<= '1';
				WHEN ENG_HDR1 =>
					IF wait_sig='0' THEN
						state	<= ENG_HDR2;
					END IF;
					start_trans		<= '0';
				WHEN ENG_HDR2 =>
					IF wait_sig='0' THEN
						state	<= ENG_HDR3;
					END IF;
					start_trans		<= '0';
				WHEN ENG_HDR3 =>
					IF wait_sig='0' AND header.FADCavail='1' AND header.eventtype/=eventTimestamp THEN
						state	<= ENG_FADC;
					ELSIF wait_sig='0' THEN
						state	<= ENG_END;
					END IF;
					start_trans		<= '0';
					rdaddr	<= (OTHERS=>'0');
				WHEN ENG_FADC =>
					rdaddr	<= rdaddr+1;
					IF rdaddr(6 DOWNTO 0) = "1111111" THEN
						IF header.ATWDavail='1' THEN
							state	<= ENG_ATWD;
							rdaddr	<= (OTHERS=>'0');
						ELSE
							state	<= ENG_END;
						END IF;
					END IF;
					start_trans		<= '0';
				WHEN ENG_ATWD =>
					rdaddr	<= rdaddr+1;
					IF rdaddr(5 DOWNTO 0) = "111111" AND rdaddr(7 DOWNTO 6) = header.ATWDsize THEN
						state	<= ENG_END;
					END IF;
					start_trans		<= '0';
				WHEN ENG_END =>
					IF (COMPR_mode=COMPR_ON OR COMPR_mode=COMPR_BOTH) AND compr_avail='1' THEN --AND (LBM_not_full if LBM_mode=LBM_Stop) THEN
						state	<=COMP_XFER;
					ELSE
						state	<= DONE;
					END IF;
					rdaddr	<= (OTHERS=>'0');
					start_address	<= start_address + 2048;
					start_trans		<= '0';
					abort_trans		<= '1';
				WHEN COMP_XFER =>
					rdaddr	<= rdaddr+1;
					IF rdaddr=compr_size THEN
						state	<= COMP_END;
					END IF;
					start_trans		<= '0';
					abort_trans		<= '0';
				WHEN COMP_END =>
					state	<= DONE;
					rdaddr	<= (OTHERS=>'X');
					start_address	<= start_address + 2048;
					start_trans		<= '0';
					abort_trans		<= '1';
				WHEN DONE =>
					IF start_address(SDRAM_SIZE)='1' AND LBM_mode=LBM_STOP THEN
						NULL;
					ELSE
						state	<= IDLE;
					END IF;
					start_trans		<= '0';
					abort_trans		<= '0';
				WHEN OTHERS =>
					NULL;
			END CASE;
			
			IF LBM_ptr_RST='1' THEN
				start_address	<= (OTHERS=>'0');
			END IF;
		END IF;
	END PROCESS;
	
	-- abort_trans <= '1' WHEN state=ENG_END OR state=COMP_END ELSE '0';
	
	-- A/B multiplexer
	header	<= HEADER_A WHEN AnB='1' ELSE HEADER_B;
	ATWD_data	<= ATWD_data_A WHEN AnB='1' ELSE ATWD_data_B;
	FADC_data	<= FADC_data_A WHEN AnB='1' ELSE FADC_data_B;
	compr_data	<= compr_data_A WHEN AnB='1' ELSE compr_data_B;
	compr_avail	<= compr_avail_A WHEN AnB='1' ELSE compr_avail_B;
	compr_size	<= compr_size_A WHEN AnB='1' ELSE compr_size_B;
	
	read_done_a <= read_done WHEN AnB='1' ELSE '0';
	read_done_b <= read_done WHEN AnB='0' ELSE '0';
	
	-- engineering header
	header0(15 DOWNTO 0) <= CONV_STD_LOGIC_VECTOR(16+512*CONV_INTEGER(header.FADCavail)+256*CONV_INTEGER(header.ATWDsize),16);
	header0(31 DOWNTO 16) <= X"0001" WHEN header.eventtype=eventEngineering ELSE
						X"0002" WHEN header.eventtype=eventTimestamp ELSE
						X"0000";
	header1(0) <= header.ATWD_AB;
	header1(7 DOWNTO 1)	<= (OTHERS=>'0');
	header1(15 DOWNTO 8)	<= X"FF" WHEN header.FADCavail='1' ELSE X"00";	-- FADC
	header1(19 DOWNTO 16)	<= X"F" WHEN header.ATWDavail='1' ELSE X"0";	-- ATWD channel 0
	header1(23 DOWNTO 20)	<= X"F" WHEN header.ATWDavail='1' AND header.ATWDsize>=1 ELSE X"0";	-- ATWD channel 1
	header1(27 DOWNTO 24)	<= X"F" WHEN header.ATWDavail='1' AND header.ATWDsize>=2 ELSE X"0";	-- ATWD channel 2
	header1(31 DOWNTO 28)	<= X"F" WHEN header.ATWDavail='1' AND header.ATWDsize=3 ELSE X"0";	-- ATWD channel 3
-- have to define that part:	header2 <= ;
	header2(31 DOWNTO 16) <= header.timestamp(15 DOWNTO 0);
	header3 <= header.timestamp(47 DOWNTO 16);
	
	-- select data source
	wdata <= header0 WHEN state=ENG_HDR0 ELSE
			header1 WHEN state=ENG_HDR1 ELSE
			header2 WHEN state=ENG_HDR2 ELSE
			header3 WHEN state=ENG_HDR3 ELSE
			FADC_data WHEN state=ENG_FADC ELSE
			ATWD_data WHEN state=ENG_ATWD ELSE
			compr_data WHEN state=COMP_XFER ELSE
			(OTHERS=>'X'); --X"XXXXXXXX";
			
	-- memory addresses
	compr_addr_A	<= rdaddr (8 DOWNTO 0);
	ATWD_addr_A		<= rdaddr (7 DOWNTO 0);
	FADC_addr_A		<= rdaddr (6 DOWNTO 0);
	compr_addr_B	<= rdaddr (8 DOWNTO 0);
	ATWD_addr_B		<= rdaddr (7 DOWNTO 0);
	FADC_addr_B		<= rdaddr (6 DOWNTO 0);
	
	-- generate done dignal
	done_pulse : PROCESS (CLK40, RST)
		VARIABLE done_last	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			read_done	<= '0';
			done_last	:= '0';
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			IF state=DONE AND done_last='0' THEN
				read_done	<= '1';
			ELSE
				read_done	<= '0';
			END IF;
			IF state=DONE THEN
				done_last	:= '1';
			ELSE
				done_last	:= '0';
			END IF;
		END IF;
	END PROCESS;
	
END mem_interface_arch;