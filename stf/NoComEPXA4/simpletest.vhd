-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : simpletest.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-07-17
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This is the top level design for the STF modified for PSK tests
--              for the EPXA4
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

ENTITY simpletest IS
	PORT (
		-- stripe IO
		CLK_REF			: IN STD_LOGIC;
		nPOR			: IN STD_LOGIC;
		nRESET			: INOUT	STD_LOGIC;
		-- UART
		UARTRXD				: IN	STD_LOGIC;
		UARTDSRN			: IN	STD_LOGIC;
		UARTCTSN			: IN	STD_LOGIC;
		UARTRIN				: INOUT	STD_LOGIC;
		UARTDCDN			: INOUT	STD_LOGIC;
		UARTTXD				: OUT	STD_LOGIC;
		UARTRTSN			: OUT	STD_LOGIC;
		UARTDTRN			: OUT	STD_LOGIC;
		-- Part of EBI???
		INTEXTPIN			: IN	STD_LOGIC;
		-- EDI
		EBIACK				: IN	STD_LOGIC;
		EBIDQ				: INOUT	STD_LOGIC_VECTOR(15 downto 0);
		EBICLK				: OUT	STD_LOGIC;
		EBIWEN				: OUT	STD_LOGIC;
		EBIOEN				: OUT	STD_LOGIC;
		EBIADDR				: OUT	STD_LOGIC_VECTOR(24 downto 0);
		EBIBE				: OUT	STD_LOGIC_VECTOR(1 downto 0);
		EBICSN				: OUT	STD_LOGIC_VECTOR(3 downto 0);
		-- SDRAM
		SDRAMDQ			: INOUT	STD_LOGIC_VECTOR (31 downto 0);
		SDRAMDQS		: INOUT STD_LOGIC_VECTOR (3 downto 0);
		SDRAMCLK		: OUT STD_LOGIC;
		SDRAMCLKN		: OUT STD_LOGIC;
		SDRAMCLKE		: OUT STD_LOGIC;
		SDRAMWEN		: OUT STD_LOGIC;
		SDRAMCASN		: OUT STD_LOGIC;
		SDRAMRASN		: OUT STD_LOGIC;
		SDRAMADDR		: OUT STD_LOGIC_VECTOR (14 downto 0);
		SDRAMCSN		: OUT STD_LOGIC_VECTOR (1 downto 0);
		SDRAMDQM		: OUT STD_LOGIC_VECTOR (3 downto 0);
		-- general FPGA IO
		CLK1p			: IN STD_LOGIC;
		CLK2p			: IN STD_LOGIC;
		CLK3p			: IN STD_LOGIC;
		CLK4p			: IN STD_LOGIC;
		CLKLK_OUT2p		: OUT STD_LOGIC;	-- 40MHz outpout for FADC
		-- Communications DAC
		-- COM_DAC_CLK		: OUT STD_LOGIC;
		COM_TX_SLEEP	: OUT STD_LOGIC;
		COM_DB			: OUT STD_LOGIC_VECTOR (13 downto 6);
		-- Communications ADC
		-- COM_AD_CLK		: OUT STD_LOGIC;
		COM_AD_D		: IN STD_LOGIC_VECTOR (9 downto 0);
		COM_AD_OTR		: IN STD_LOGIC;
		-- Communications RS485
		HDV_Rx			: IN STD_LOGIC;
		HDV_RxENA		: OUT STD_LOGIC;
		HDV_TxENA		: OUT STD_LOGIC;
		HDV_IN			: OUT STD_LOGIC;
		-- Test connector	THERE IS NO 11   I don't know why
		PGM				: OUT STD_LOGIC_VECTOR (15 downto 0)
	);
END simpletest;


ARCHITECTURE simpletest_arch OF simpletest IS

	-- gerneal siganls
	SIGNAL low		: STD_LOGIC;
	SIGNAL high		: STD_LOGIC;
	
	SIGNAL CLK20	: STD_LOGIC;
	SIGNAL CLK40	: STD_LOGIC;
	SIGNAL CLK80	: STD_LOGIC;
	SIGNAL RST		: STD_LOGIC;
	
	SIGNAL TC		: STD_LOGIC_VECTOR (7 downto 0);
	
	-- PLD to STRIPE bridge
	SIGNAL slavehclk		: STD_LOGIC;
	SIGNAL slavehwrite		: STD_LOGIC;
	SIGNAL slavehreadyi		: STD_LOGIC;
	SIGNAL slavehselreg		: STD_LOGIC;
	SIGNAL slavehsel		: STD_LOGIC;
	SIGNAL slavehmastlock	: STD_LOGIC;
	SIGNAL slavehaddr		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL slavehtrans		: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL slavehsize		: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL slavehburst		: STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL slavehwdata		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL slavehreadyo		: STD_LOGIC;
	SIGNAL slavebuserrint	: STD_LOGIC;
	SIGNAL slavehresp		: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL slavehrdata		: STD_LOGIC_VECTOR(31 downto 0);
	
	-- STRIPE to PLD bridge
	SIGNAL masterhclk			: STD_LOGIC;
	SIGNAL masterhready		: STD_LOGIC;
	SIGNAL masterhgrant		: STD_LOGIC;
	SIGNAL masterhrdata		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL masterhresp			: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL masterhwrite		: STD_LOGIC;
	SIGNAL masterhlock			: STD_LOGIC;
	SIGNAL masterhbusreq		: STD_LOGIC;
	SIGNAL masterhaddr			: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL masterhburst		: STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL masterhsize			: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL masterhtrans		: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL masterhwdata		: STD_LOGIC_VECTOR(31 downto 0);
	
	-- DP SRAM
	SIGNAL dp0_2_portaclk	: STD_LOGIC;
	SIGNAL dp0_portawe		: STD_LOGIC;
	SIGNAL dp0_portaaddr	: STD_LOGIC_VECTOR(13 downto 0);
	SIGNAL dp0_portadatain	: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL dp0_portadataout	: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL dp2_portawe		: STD_LOGIC;
	SIGNAL dp2_portaaddr	: STD_LOGIC_VECTOR(13 downto 0);
	SIGNAL dp2_portadatain	: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL dp2_portadataout	: STD_LOGIC_VECTOR(7 downto 0);
	
	-- interrupts
	SIGNAL intpld	: STD_LOGIC_VECTOR(5 downto 0);
	-- GP stripe IO
	SIGNAL gpi		: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL gpo		: STD_LOGIC_VECTOR(7 downto 0);
	
	-- AHB_slave
	SIGNAL reg_write	: STD_LOGIC; 
	SIGNAL reg_address	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_wdata	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_rdata	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_enable	: STD_LOGIC;
	SIGNAL reg_wait_sig	: STD_LOGIC;
	
	-- commands to enable test functions
	SIGNAL command_0	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL response_0	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL command_1	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL response_1	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL command_2	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL response_2	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL command_3	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL response_3	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL command_4	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL response_4	: STD_LOGIC_VECTOR(31 downto 0);
	
	-- com DAC test
	SIGNAL enable			: STD_LOGIC;
	SIGNAL enable_square	: STD_LOGIC;
	-- com ADC test
	SIGNAL com_adc_enable	: STD_LOGIC;
	SIGNAL com_adc_done		: STD_LOGIC;
	SIGNAL com_adc_wdata	: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL com_adc_rdata	: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL com_adc_address	: STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL com_adc_write_en	: STD_LOGIC;
	-- com RS485 test
	SIGNAL rs486_ena	: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL rs486_tx		: STD_LOGIC;
	SIGNAL rs486_rx		: STD_LOGIC;
	SIGNAL enable_rs485	: STD_LOGIC;
	

	-- kale communication
	SIGNAL com_ctrl			: STD_LOGIC_VECTOR (31 downto 0);
	SIGNAL com_status		: STD_LOGIC_VECTOR (31 downto 0);
	
	SIGNAL systime			: STD_LOGIC_VECTOR (47 DOWNTO 0);
	SIGNAL atwd0_timestamp  : STD_LOGIC_VECTOR (47 DOWNTO 0);
	SIGNAL atwd1_timestamp  : STD_LOGIC_VECTOR (47 DOWNTO 0);
	
	COMPONENT ROC
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT pll2x
		PORT (
			inclock		: IN STD_LOGIC;
			locked		: OUT STD_LOGIC;
			clock0		: OUT STD_LOGIC;
			clock1		: OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT pll4x
		PORT (
			inclock		: IN STD_LOGIC;
			locked		: OUT STD_LOGIC;
			clock1		: OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT stripe
		PORT (
			clk_ref				: IN	STD_LOGIC;
			npor				: IN	STD_LOGIC;
			nreset				: INOUT	STD_LOGIC;
			uartrxd				: IN	STD_LOGIC;
			uartdsrn			: IN	STD_LOGIC;
			uartctsn			: IN	STD_LOGIC;
			uartrin				: INOUT	STD_LOGIC;
			uartdcdn			: INOUT	STD_LOGIC;
			uarttxd				: OUT	STD_LOGIC;
			uartrtsn			: OUT	STD_LOGIC;
			uartdtrn			: OUT	STD_LOGIC;
			intextpin			: IN	STD_LOGIC;
			ebiack				: IN	STD_LOGIC;
			ebidq				: INOUT	STD_LOGIC_VECTOR(15 downto 0);
			ebiclk				: OUT	STD_LOGIC;
			ebiwen				: OUT	STD_LOGIC;
			ebioen				: OUT	STD_LOGIC;
			ebiaddr				: OUT	STD_LOGIC_VECTOR(24 downto 0);
			ebibe				: OUT	STD_LOGIC_VECTOR(1 downto 0);
			ebicsn				: OUT	STD_LOGIC_VECTOR(3 downto 0);
			sdramdq				: INOUT	STD_LOGIC_VECTOR(31 downto 0);
			sdramdqs			: INOUT	STD_LOGIC_VECTOR(3 downto 0);
			sdramclk			: OUT	STD_LOGIC;
			sdramclkn			: OUT	STD_LOGIC;
			sdramclke			: OUT	STD_LOGIC;
			sdramwen			: OUT	STD_LOGIC;
			sdramcasn			: OUT	STD_LOGIC;
			sdramrasn			: OUT	STD_LOGIC;
			sdramaddr			: OUT	STD_LOGIC_VECTOR(14 downto 0);
			sdramcsn			: OUT	STD_LOGIC_VECTOR(1 downto 0);
			sdramdqm			: OUT	STD_LOGIC_VECTOR(3 downto 0);
			slavehclk			: IN	STD_LOGIC;
			slavehwrite			: IN	STD_LOGIC;
			slavehreadyi		: IN	STD_LOGIC;
			slavehselreg		: IN	STD_LOGIC;
			slavehsel			: IN	STD_LOGIC;
			slavehmastlock		: IN	STD_LOGIC;
			slavehaddr			: IN	STD_LOGIC_VECTOR(31 downto 0);
			slavehtrans			: IN	STD_LOGIC_VECTOR(1 downto 0);
			slavehsize			: IN	STD_LOGIC_VECTOR(1 downto 0);
			slavehburst			: IN	STD_LOGIC_VECTOR(2 downto 0);
			slavehwdata			: IN	STD_LOGIC_VECTOR(31 downto 0);
			slavehreadyo		: OUT	STD_LOGIC;
			slavebuserrint		: OUT	STD_LOGIC;
			slavehresp			: OUT	STD_LOGIC_VECTOR(1 downto 0);
			slavehrdata			: OUT	STD_LOGIC_VECTOR(31 downto 0);
			masterhclk			: IN	STD_LOGIC;
			masterhready		: IN	STD_LOGIC;
			masterhgrant		: IN	STD_LOGIC;
			masterhrdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
			masterhresp			: IN	STD_LOGIC_VECTOR(1 downto 0);
			masterhwrite		: OUT	STD_LOGIC;
			masterhlock			: OUT	STD_LOGIC;
			masterhbusreq		: OUT	STD_LOGIC;
			masterhaddr			: OUT	STD_LOGIC_VECTOR(31 downto 0);
			masterhburst		: OUT	STD_LOGIC_VECTOR(2 downto 0);
			masterhsize			: OUT	STD_LOGIC_VECTOR(1 downto 0);
			masterhtrans		: OUT	STD_LOGIC_VECTOR(1 downto 0);
			masterhwdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			intpld				: IN	STD_LOGIC_VECTOR(5 downto 0);
			dp0_2_portaclk		: IN	STD_LOGIC;
			dp0_portawe			: IN	STD_LOGIC;
			dp0_portaaddr		: IN	STD_LOGIC_VECTOR(13 downto 0);
			dp0_portadatain		: IN	STD_LOGIC_VECTOR(7 downto 0);
			dp0_portadataout	: OUT	STD_LOGIC_VECTOR(7 downto 0);
			dp2_portawe			: IN	STD_LOGIC;
			dp2_portaaddr		: IN	STD_LOGIC_VECTOR(13 downto 0);
			dp2_portadatain		: IN	STD_LOGIC_VECTOR(7 downto 0);
			dp2_portadataout	: OUT	STD_LOGIC_VECTOR(7 downto 0);
			gpi					: IN	STD_LOGIC_VECTOR(7 downto 0);
			gpo					: OUT	STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT ahb_slave
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- connections to the stripe
			masterhready		: OUT	STD_LOGIC;
			masterhgrant		: OUT	STD_LOGIC;
			masterhrdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			masterhresp			: OUT	STD_LOGIC_VECTOR(1 downto 0);
			masterhwrite		: IN	STD_LOGIC;
			masterhlock			: IN	STD_LOGIC;
			masterhbusreq		: IN	STD_LOGIC;
			masterhaddr			: IN	STD_LOGIC_VECTOR(31 downto 0);
			masterhburst		: IN	STD_LOGIC_VECTOR(2 downto 0);
			masterhsize			: IN	STD_LOGIC_VECTOR(1 downto 0);
			masterhtrans		: IN	STD_LOGIC_VECTOR(1 downto 0);
			masterhwdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
			-- local bus signals
			reg_write		: OUT	STD_LOGIC;
			reg_address		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			reg_wdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			reg_rdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
			reg_enable		: OUT	STD_LOGIC;
			reg_wait_sig	: IN	STD_LOGIC
		);
	END COMPONENT;
	
	
	COMPONENT slaveregister
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
			command_0		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			response_0		: IN	STD_LOGIC_VECTOR(31 downto 0);
			command_1		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			response_1		: IN	STD_LOGIC_VECTOR(31 downto 0);
			command_2		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			response_2		: IN	STD_LOGIC_VECTOR(31 downto 0);
			command_3		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			response_3		: IN	STD_LOGIC_VECTOR(31 downto 0);
			com_ctrl		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			com_status		: IN	STD_LOGIC_VECTOR(31 downto 0);
			com_tx_data		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			com_rx_data		: IN	STD_LOGIC_VECTOR(31 downto 0);
			hitcounter_o	: IN	STD_LOGIC_VECTOR(31 downto 0);
			hitcounter_m	: IN	STD_LOGIC_VECTOR(31 downto 0);
			hitcounter_o_ff	: IN	STD_LOGIC_VECTOR(31 downto 0);
			hitcounter_m_ff	: IN	STD_LOGIC_VECTOR(31 downto 0);
			systime			: IN	STD_LOGIC_VECTOR(47 DOWNTO 0);
			atwd0_timestamp : IN	STD_LOGIC_VECTOR(47 DOWNTO 0);
            atwd1_timestamp	: IN	STD_LOGIC_VECTOR(47 DOWNTO 0);                    
			command_4		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			response_4		: IN	STD_LOGIC_VECTOR(31 downto 0);
			-- COM ADC RX interface
			com_adc_wdata		: OUT STD_LOGIC_VECTOR (15 downto 0);
			com_adc_rdata		: IN STD_LOGIC_VECTOR (15 downto 0);
			com_adc_address		: OUT STD_LOGIC_VECTOR (8 downto 0);
			com_adc_write_en	: OUT STD_LOGIC;
			-- FLASH ADC RX interface
			flash_adc_wdata		: OUT STD_LOGIC_VECTOR (15 downto 0);
			flash_adc_rdata		: IN STD_LOGIC_VECTOR (15 downto 0);
			flash_adc_address	: OUT STD_LOGIC_VECTOR (8 downto 0);
			flash_adc_write_en	: OUT STD_LOGIC;
			-- ATWD0 interface
			atwd0_wdata			: OUT STD_LOGIC_VECTOR (15 downto 0);
			atwd0_rdata			: IN STD_LOGIC_VECTOR (15 downto 0);
			atwd0_address		: OUT STD_LOGIC_VECTOR (8 downto 0);
			atwd0_write_en		: OUT STD_LOGIC;
			-- ATWD1 interface
			atwd1_wdata			: OUT STD_LOGIC_VECTOR (15 downto 0);
			atwd1_rdata			: IN STD_LOGIC_VECTOR (15 downto 0);
			atwd1_address		: OUT STD_LOGIC_VECTOR (8 downto 0);
			atwd1_write_en		: OUT STD_LOGIC;
			-- kale communication interface
			tx_fifo_wr			: OUT STD_LOGIC;
			rx_fifo_rd			: OUT STD_LOGIC;
			-- test connector
			TC				: OUT	STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;

	COMPONENT com_DAC_TX
		PORT (
			CLK20        : IN  STD_LOGIC;
			CLK40        : IN  STD_LOGIC;
			RST          : IN  STD_LOGIC;
			-- enable for TX
			enable       : IN  STD_LOGIC;
			rate         : IN  STD_LOGIC_VECTOR (10 DOWNTO 0);
			gain         : IN  STD_LOGIC_VECTOR (2 DOWNTO 0);
			load_tx      : IN  STD_LOGIC;
			uart_tx      : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			-- communications DAC connections
			COM_TX_SLEEP : OUT STD_LOGIC;
			COM_DB       : OUT STD_LOGIC_VECTOR (13 DOWNTO 6);
			-- test connector
			TC           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;
	
--	COMPONENT com_DAC_TX
--		PORT (
--			CLK			: IN STD_LOGIC;
--			CLK2x		: IN STD_LOGIC;
--			RST			: IN STD_LOGIC;
--			-- enable for TX
--			enable		: IN STD_LOGIC;
--			enable_square	: IN STD_LOGIC;
--			-- communications DAC connections
--			COM_DAC_CLK		: OUT STD_LOGIC;
--			COM_TX_SLEEP	: OUT STD_LOGIC;
--			COM_DB			: OUT STD_LOGIC_VECTOR (13 downto 6);
--			-- test connector
--			TC				: OUT	STD_LOGIC_VECTOR(7 downto 0)
--		);
--	END COMPONENT;
	
	
	COMPONENT com_ADC_RX
		PORT (
			CLK20		: IN STD_LOGIC;
			CLK40		: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- enable for RX
			enable		: IN STD_LOGIC;
			rate		: IN  STD_LOGIC_VECTOR (10 DOWNTO 0);
			phase		: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
			-- Arthur
			Qout		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			Iout		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			THETAout	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			reg_updata	: OUT STD_LOGIC;
			-- communications ADC connections
			COM_AD_D	: IN STD_LOGIC_VECTOR (9 downto 0);
			COM_AD_OTR	: IN STD_LOGIC;
			-- test connector
			TC			: OUT	STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	
	COMPONENT timer
		PORT (
			CLK     : IN  STD_LOGIC;
			RST     : IN  STD_LOGIC;
			systime : OUT STD_LOGIC_VECTOR (47 DOWNTO 0)
		);
	END COMPONENT;
	
	
	SIGNAL sineenable	: STD_LOGIC;
	SIGNAL sinegain		: STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL sinerate		: STD_LOGIC_VECTOR (10 DOWNTO 0);
	SIGNAL load_tx		: STD_LOGIC;
	SIGNAL uart_tx		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	SIGNAL pskenable	: STD_LOGIC;
	SIGNAL pskphase		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL pskrate		: STD_LOGIC_VECTOR (10 DOWNTO 0);
	SIGNAL Q			: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL I			: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL THETA		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL pskupdate	: STD_LOGIC;
	
BEGIN
	-- general
	low		<= '0';
	high	<= '1';
	
	
	-- PLD to STRIPE bridge
	slavehclk		<= CLK20;
	
	-- STRIPE to PLD bridge
	 masterhclk			<= CLK20;
	-- masterhready		<= '0';
	-- masterhgrant		<= '0';
	-- masterhrdata		<= (others=>'0');
	-- masterhresp			<= (others=>'0');
	-- masterhwrite		<= ;
	-- masterhlock			<= ;
	-- masterhbusreq		<= ;
	-- masterhaddr			<= ;
	-- masterhburst		<= ;
	-- masterhsize			<= ;
	-- masterhtrans		<= ;
	-- masterhwdata		<= ;
	
	-- DP SRAM
	dp0_2_portaclk		<= CLK20;
	dp0_portawe			<= '0';
	dp0_portaaddr		<= (others=>'0');
	dp0_portadatain		<= (others=>'0');
	-- dp0_portadataout	<= ;
	dp2_portawe			<= '0';
	dp2_portaaddr		<= (others=>'0');
	dp2_portadatain		<= (others=>'0');
	-- dp2_portadataout	<= ;
	
	-- interrupts
	intpld	<= (others=>'0');
	
	-- GP stripe IO
	gpi(3 downto 0)		<= (others=>'0');
	-- gpo		<= ;
	
	
	
	-- com DAC test
	enable <= command_1(0);
	enable_square	<= command_1(1);
	-- com ADC test
	com_adc_enable	<= command_1(4);
	
	
	
	-- response_0(31 downto 0)	<= (others=>'0');
	-- response_1(31 downto 0)	<= (others=>'0');
	response_2(31 downto 0)	<= (others=>'0');
	response_4(31 downto 0)	<= (others=>'0');
	
	
	-- fake kallo communication reset
	response_0(1 downto 0)	<= (others=>'0');
	com_status(2)	<= com_ctrl(2);
	response_0(31 downto 3)	<= (others=>'0');
	
	
	inst_ROC : ROC
		PORT MAP (
			CLK			=> CLK20,
			RST			=> RST
		);
		
	inst_pll2x : pll2x
		PORT MAP (
			inclock		=> CLK2p,
			locked		=> open,
			clock0		=> CLK20,
			clock1		=> CLK40
		);
	
	inst_pll4x : pll4x
		PORT MAP (
			inclock		=> CLK1p,
			locked		=> open,
			clock1		=> CLK80
		);
	CLKLK_OUT2p	<= CLK40;	-- 40MHz output for FADC
	
	stripe_inst : stripe
		PORT MAP (
			clk_ref				=> CLK_REF,
			npor				=> nPOR,
			nreset				=> nRESET,
			uartrxd				=> UARTRXD,
			uartdsrn			=> UARTDSRN,
			uartctsn			=> UARTCTSN,
			uartrin				=> UARTRIN,
			uartdcdn			=> UARTDCDN,
			uarttxd				=> UARTTXD,
			uartrtsn			=> UARTRTSN,
			uartdtrn			=> UARTDTRN,
			intextpin			=> INTEXTPIN,
			ebiack				=> EBIACK,
			ebidq				=> EBIDQ,
			ebiclk				=> EBICLK,
			ebiwen				=> EBIWEN,
			ebioen				=> EBIOEN,
			ebiaddr				=> EBIADDR,
			ebibe				=> EBIBE,
			ebicsn				=> EBICSN,
			sdramdq				=> SDRAMDQ,
			sdramdqs			=> SDRAMDQS,
			sdramclk			=> SDRAMCLK,
			sdramclkn			=> SDRAMCLKN,
			sdramclke			=> SDRAMCLKE,
			sdramwen			=> SDRAMWEN,
			sdramcasn			=> SDRAMCASN,
			sdramrasn			=> SDRAMRASN,
			sdramaddr			=> SDRAMADDR,
			sdramcsn			=> SDRAMCSN,
			sdramdqm			=> SDRAMDQM,
			slavehclk			=> slavehclk,
			slavehwrite			=> slavehwrite,
			slavehreadyi		=> slavehreadyi,
			slavehselreg		=> slavehselreg,
			slavehsel			=> slavehsel,
			slavehmastlock		=> slavehmastlock,
			slavehaddr			=> slavehaddr,
			slavehtrans			=> slavehtrans,
			slavehsize			=> slavehsize,
			slavehburst			=> slavehburst,
			slavehwdata			=> slavehwdata,
			slavehreadyo		=> slavehreadyo,
			slavebuserrint		=> slavebuserrint,
			slavehresp			=> slavehresp,
			slavehrdata			=> slavehrdata,
			masterhclk			=> masterhclk,
			masterhready		=> masterhready,
			masterhgrant		=> masterhgrant,
			masterhrdata		=> masterhrdata,
			masterhresp			=> masterhresp,
			masterhwrite		=> masterhwrite,
			masterhlock			=> masterhlock,
			masterhbusreq		=> masterhbusreq,
			masterhaddr			=> masterhaddr,
			masterhburst		=> masterhburst,
			masterhsize			=> masterhsize,
			masterhtrans		=> masterhtrans,
			masterhwdata		=> masterhwdata,
			intpld				=> intpld,
			dp0_2_portaclk		=> dp0_2_portaclk,
			dp0_portawe			=> dp0_portawe,
			dp0_portaaddr		=> dp0_portaaddr,
			dp0_portadatain		=> dp0_portadatain,
			dp0_portadataout	=> open,
			dp2_portawe			=> dp2_portawe,
			dp2_portaaddr		=> dp2_portaaddr,
			dp2_portadatain		=> dp2_portadatain,
			dp2_portadataout	=> open,
			gpi					=> gpi,
			gpo					=> gpo
		);
		
	ahb_slave_inst : ahb_slave
		PORT MAP (
			CLK				=> CLK20,
			RST				=> RST,
			-- connections to the stripe
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
		
		
	slaveregister_inst : slaveregister
		PORT MAP (
			CLK				=> CLK20,
			RST				=> RST,
			-- connections to ahb_slave
			reg_write		=> reg_write,
			reg_address		=> reg_address,
			reg_wdata		=> reg_wdata,
			reg_rdata		=> reg_rdata,
			reg_enable		=> reg_enable,
			reg_wait_sig	=> reg_wait_sig,
			-- command register
			command_0		=> command_0,
			response_0		=> response_0,
			command_1		=> command_1,
			response_1		=> response_1,
			command_2		=> command_2,
			response_2		=> response_2,
			command_3		=> command_3,
			response_3		=> response_3,
			com_ctrl		=> com_ctrl,
			com_status		=> com_status,
			com_tx_data		=> uart_tx,
			com_rx_data		=> (others=>'0'),
			hitcounter_o	=> Q,
			hitcounter_m	=> I,
			hitcounter_o_ff	=> THETA,
			hitcounter_m_ff	=> X"00000000",
			systime			=> systime,
			atwd0_timestamp => X"000000000000",
            atwd1_timestamp => X"000000000000",
			command_4		=> command_4,
			response_4		=> response_4,
			-- COM ADC RX interface
			com_adc_wdata		=> open,
			com_adc_rdata		=> X"0000",
			com_adc_address		=> open,
			com_adc_write_en	=> open,
			-- FLASH ADC RX interface
			flash_adc_wdata		=> open,
			flash_adc_rdata		=> X"0000",
			flash_adc_address	=> open,
			flash_adc_write_en	=> '0',
			-- ATWD0 interface
			atwd0_wdata			=> open,
			atwd0_rdata			=> X"0000",
			atwd0_address		=> open,
			atwd0_write_en		=> open,
			-- ATWD1 interface
			atwd1_wdata			=> open,
			atwd1_rdata			=> X"0000",
			atwd1_address		=> open,
			atwd1_write_en		=> open,
			-- kale communication interface
			tx_fifo_wr			=> load_tx,
			rx_fifo_rd			=> open,
			-- test connector
			TC				=> open --TC
		);
		
	sineenable	<= command_0(0);
	sinegain	<= command_0(10 DOWNTO 8);
	sinerate	<= COMMAND_0(26 downto 16);
	
	response_0(31 downto 0)	<= (others=>'0');
		
	inst_com_DAC_TX : com_DAC_TX
		PORT MAP (
			CLK20        => CLK20,
			CLK40        => CLK40,
			RST          => RST,
			-- enable for TX
			enable       => sineenable,
			rate         => sinerate,
			gain         => sinegain,
			load_tx      => load_tx,
			uart_tx      => uart_tx,
			-- communications DAC connections
			COM_TX_SLEEP => COM_TX_SLEEP,
			COM_DB       => COM_DB,
			-- test connector
			TC           => open
		);

		
--	com_DAC_TX_inst : com_DAC_TX
--		PORT MAP (
--			CLK				=> CLK20,
--			CLK2x			=> CLK40,
--			RST				=> RST,
--			-- enable for TX
--			enable			=> enable,
--			enable_square	=> enable_square,
--			-- communications DAC connections
--			COM_DAC_CLK		=> open, --COM_DAC_CLK,
--			COM_TX_SLEEP	=> COM_TX_SLEEP,
--			COM_DB			=> COM_DB,
--			-- test connector
--			TC				=> open
--		);
	
	pskenable	<= command_1(0);
	pskphase	<= command_1(15 DOWNTO 8);
	pskrate		<= command_1(26 downto 16);

	response_1(0)			<= pskupdate;
	response_1(31 downto 1)	<= (others=>'0');
	inst_com_ADC_RX : com_ADC_RX
		PORT MAP(
			CLK20		=> CLK20,
			CLK40		=> CLK40,
			RST			=> RST,
			-- enable for RX
			enable		=> '1',
			rate		=> pskrate,
			phase		=> pskphase,
			-- Arthur
			Qout		=> Q,
			Iout		=> I,
			THETAout	=> THETA,
			reg_updata	=> pskupdate,
			-- communications ADC connections
			COM_AD_D	=> COM_AD_D,
			COM_AD_OTR	=> COM_AD_OTR,
			-- test connector
			TC			=> open
		);
		
		
	timer_inst : timer
		PORT MAP (
			CLK		=> CLK40,
			RST		=> RST,
			systime	=> systime
		);
		
	
	
	-- PGM(15 downto 12) <= (others=>'0');
	PGM(15) <= '1';
	PGM(14) <= '0';
	PGM(13) <= '0';
	PGM(12) <= '1';
	PGM(11) <= 'Z';
	-- PGM(10 downto 8) <= (others=>'0');
	PGM(7 downto 0) <= TC;
	
	
	process(CLK20)
		variable CNT	: STD_LOGIC_VECTOR(2 downto 0);
	begin
		IF CLK20'EVENT and CLK20='1' then
			CNT := CNT + 1;
			PGM(9 downto 8) <= CNT(1 downto 0);
		END IF;
	END PROCESS;
	
	process(CLK80)
		variable CNT	: STD_LOGIC_VECTOR(47 downto 0);
	begin
		IF CLK80'EVENT and CLK80='1' then
			CNT := CNT + 1;
			PGM(10) <= CNT(0);
		END IF;
	END PROCESS;
	
	
END;
