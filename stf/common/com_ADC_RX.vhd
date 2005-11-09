-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : com_ADC_RX.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-07-17
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: thsi module interfaces the communications ADC and samples 512
--              samples on CPU trigger
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten
-- 2003-07-18              thorsten  input latch to negatice edge  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY com_ADC_RC IS
	PORT (
		CLK			: IN STD_LOGIC;
		CLK2x		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- stripe interface
		wdata		: IN STD_LOGIC_VECTOR (15 downto 0);
		rdata		: OUT STD_LOGIC_VECTOR (15 downto 0);
		address		: IN STD_LOGIC_VECTOR (8 downto 0);
		write_en	: IN STD_LOGIC;
		-- enable for RX
		enable		: IN STD_LOGIC;
		done		: OUT STD_LOGIC;
		-- communications ADC connections
		COM_AD_CLK		: OUT STD_LOGIC;
		COM_AD_D		: IN STD_LOGIC_VECTOR (9 downto 0);
		COM_AD_OTR		: IN STD_LOGIC;
		-- test connector
		TC				: OUT	STD_LOGIC_VECTOR(7 downto 0)
	);
END com_ADC_RC;



ARCHITECTURE arch_com_ADC_RC OF com_ADC_RC IS
	
	SIGNAL wraddress_sig	: STD_LOGIC_VECTOR (8 downto 0);
	SIGNAL wraddress		: STD_LOGIC_VECTOR (8 downto 0);
	SIGNAL data_sig			: STD_LOGIC_VECTOR (15 downto 0);
	SIGNAL wren				: STD_LOGIC;
	SIGNAL wren_sig			: STD_LOGIC;
	SIGNAL rden_sig			: STD_LOGIC;
	
	SIGNAL COM_AD_D_int		: STD_LOGIC_VECTOR (9 downto 0);
	SIGNAL COM_AD_OTR_int	: STD_LOGIC;
		
	COMPONENT com_adc_mem
		PORT
		(
			data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			wraddress	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			rdaddress	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			wren		: IN STD_LOGIC  := '1';
			rden	 	: IN STD_LOGIC  := '1';
			clock		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END COMPONENT;
	
BEGIN
	
	PROCESS(CLK2x,RST)
		VARIABLE toggle	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			COM_AD_CLK	<= '1';
			toggle		:= '1';
		ELSIF CLK2x'EVENT AND CLK2x='1' THEN
			toggle		:= NOT toggle;
			COM_AD_CLK	<= toggle;
		END IF;
	END PROCESS;

	PROCESS(CLK,RST)
		VARIABLE MEM_write_addr	: STD_LOGIC_VECTOR (9 downto 0);
	BEGIN
		IF RST='1' THEN
			wren	<= '0';
			done	<= '0';
			MEM_write_addr	:= (others=>'0');
			wraddress	<= (others=>'0');
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF enable = '0' THEN		-- do not take date
				wren	<= '0';
				done	<= '0';
				MEM_write_addr	:= (others=>'0');
			ELSE					-- take data
				IF MEM_write_addr(9)='1' THEN	-- memory is full
					wren	<= '0';
					done	<= '1';
				ELSE							-- memory is not full
					wren	<= '1';
					done	<= '0';
					wraddress			<= MEM_write_addr(8 downto 0);
		--			data_b(9 downto 0)	<= COM_AD_D;
		--			data_b(10)			<= COM_AD_OTR;
					MEM_write_addr		:= MEM_write_addr + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	input_latch : PROCESS (CLK,RST)
	BEGIN
		IF RST='1' THEN
			COM_AD_D_int	<= (others=>'0');
			COM_AD_OTR_int	<= '0';
		ELSIF CLK'EVENT AND CLK='0' THEN
			COM_AD_D_int	<= COM_AD_D;
			COM_AD_OTR_int	<= COM_AD_OTR;
		END IF;
	END PROCESS;
	
	
	data_sig(9 downto 0)	<= COM_AD_D_int WHEN write_en='0' ELSE wdata(9 downto 0);
	data_sig(10)			<= COM_AD_OTR_int WHEN write_en='0' ELSE wdata(10);
	data_sig(15 downto 11)	<= (others=>'0') WHEN write_en='0' ELSE wdata(15 downto 11);
	wraddress_sig	<= wraddress WHEN write_en='0' ELSE address;
	wren_sig		<= wren WHEN write_en='0' ELSE write_en;
	
	rden_sig		<= '1';
	
	inst_com_adc_mem : com_adc_mem
		PORT MAP (
			data	 => data_sig,
			wraddress	 => wraddress_sig,
			rdaddress	 => address,
			wren	 => wren_sig,
			rden	 => rden_sig,
			clock	 => CLK,
			q	 => rdata
		);

END;