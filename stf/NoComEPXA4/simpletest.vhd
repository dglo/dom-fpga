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
	
	-- flash ADC test
	SIGNAL flash_adc_enable		: STD_LOGIC;
	SIGNAL flash_adc_enable_disc	: STD_LOGIC;
	SIGNAL flash_adc_done		: STD_LOGIC;
	SIGNAL flash_adc_wdata		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL flash_adc_rdata		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL flash_adc_address	: STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL flash_adc_write_en	: STD_LOGIC;
	
	-- frontend pulser
	SIGNAL fe_pulser_enable		: STD_LOGIC;
	SIGNAL fe_divider			: STD_LOGIC_VECTOR(3 downto 0);
	-- single LED
	SIGNAL single_led_enable	: STD_LOGIC;
	SIGNAL LEDtrig				: STD_LOGIC;
	SIGNAL SingleLED_TRIGGER_sig	: STD_LOGIC;
	SIGNAL LEDdelay				: STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL trigLED				: STD_LOGIC;
	SIGNAL trigLED_onboard		: STD_LOGIC;
	SIGNAL trigLED_flasher		: STD_LOGIC;
	
	-- local coincidence
	SIGNAL enable_coinc_up		: STD_LOGIC;
	SIGNAL enable_coinc_down	: STD_LOGIC;
	SIGNAL coinc_down_high		: STD_LOGIC;
	SIGNAL coinc_down_low		: STD_LOGIC;
	SIGNAL coinc_up_high		: STD_LOGIC;
	SIGNAL coinc_up_low			: STD_LOGIC;
	SIGNAL coinc_latch			: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL coinc_disc			: STD_LOGIC_VECTOR(7 downto 0);
	
	-- hit counter
	SIGNAL oneSPEcnt		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL multiSPEcnt		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL hitcounter_o		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL hitcounter_m		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL oneSPEcnt_ff		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL multiSPEcnt_ff	: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL hitcounter_o_ff	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL hitcounter_m_ff	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL hit_counter_gate	: STD_LOGIC;
	
	-- ATWD0
	SIGNAL atwd0_enable		: STD_LOGIC;
	SIGNAL atwd0_enable_disc	: STD_LOGIC;
	SIGNAL atwd0_enable_LED	: STD_LOGIC;
	SIGNAL atwd0_done		: STD_LOGIC;
	SIGNAL atwd0_wdata		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL atwd0_rdata		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL atwd0_address	: STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL atwd0_write_en	: STD_LOGIC;
	SIGNAL atwd0_trigger    : STD_LOGIC;
	SIGNAL atwd0_trig_doneB : STD_LOGIC;
	
	-- ATWD1
	SIGNAL atwd1_enable		: STD_LOGIC;
	SIGNAL atwd1_enable_disc	: STD_LOGIC;
	SIGNAL atwd1_enable_LED	: STD_LOGIC;
	SIGNAL atwd1_done		: STD_LOGIC;
	SIGNAL atwd1_wdata		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL atwd1_rdata		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL atwd1_address	: STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL atwd1_write_en	: STD_LOGIC;
	SIGNAL atwd1_trigger    : STD_LOGIC;
	SIGNAL atwd1_trig_doneB : STD_LOGIC;
	
	-- AHB master
	SIGNAL start_trans		: STD_LOGIC;
	SIGNAL address			: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL wdata			: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL wait_sig			: STD_LOGIC;
	SIGNAL trans_length		: INTEGER;
	SIGNAL bus_error		: STD_LOGIC;
	SIGNAL master_addr_start	: STD_LOGIC_VECTOR(15 downto 0);
	
	-- AHB master test
	SIGNAL master_enable	: STD_LOGIC;
	SIGNAL master_done		: STD_LOGIC;
	SIGNAL master_berr		: STD_LOGIC;
	
	-- R2R ladder at ATWDch3 input
	SIGNAL enable_r2r		: STD_LOGIC;
	-- R2R ladder at analog frontend
	SIGNAL enable_fe_r2r	: STD_LOGIC;
	
	-- flasher board
	SIGNAL fl_board			: STD_LOGIC_VECTOR (7 downto 0);
	SIGNAL fl_board_read	: STD_LOGIC_VECTOR (1 downto 0);
	SIGNAL enable_flasher	: STD_LOGIC;
	
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
	
	COMPONENT flash_ADC
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
			enable_disc	: IN STD_LOGIC;
			done		: OUT STD_LOGIC;
			-- disc
			OneSPE		: IN STD_LOGIC;
			-- communications ADC connections
			FLASH_AD_D		: IN STD_LOGIC_VECTOR (9 downto 0);
			FLASH_AD_CLK	: OUT STD_LOGIC;
			FLASH_AD_STBY	: OUT STD_LOGIC;
			FLASH_NCO		: IN STD_LOGIC;
			-- test connector
			TC				: OUT	STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT fe_testpulse
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- enable flasher
			enable		: IN STD_LOGIC;
			divider		: IN STD_LOGIC_VECTOR(3 downto 0);
			-- LED trigger
			FE_TEST_PULSE	: OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT single_led
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- enable flasher
			enable		: IN STD_LOGIC;
			-- LED trigger
			SingleLED_TRIGGER	: OUT STD_LOGIC;
			-- ATWD trigger
			trigLED		: OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT coinc
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- enable
			enable_coinc_down	: IN STD_LOGIC;
			enable_coinc_up		: IN STD_LOGIC;
			-- manual control
			coinc_up_high		: IN STD_LOGIC;
			coinc_up_low		: IN STD_LOGIC;
			coinc_down_high		: IN STD_LOGIC;
			coinc_down_low		: IN STD_LOGIC;
			coinc_latch			: IN STD_LOGIC_VECTOR(3 downto 0);
			coinc_disc			: OUT STD_LOGIC_VECTOR(7 downto 0);
			-- local coincidence
			COINCIDENCE_OUT_DOWN	: OUT STD_LOGIC;
			COINC_DOWN_ALATCH	: OUT STD_LOGIC;
			COINC_DOWN_ABAR		: IN STD_LOGIC;
			COINC_DOWN_A		: IN STD_LOGIC;
			COINC_DOWN_BLATCH	: OUT STD_LOGIC;
			COINC_DOWN_BBAR		: IN STD_LOGIC;
			COINC_DOWN_B		: IN STD_LOGIC;
			COINCIDENCE_OUT_UP	: OUT STD_LOGIC;
			COINC_UP_ALATCH		: OUT STD_LOGIC;
			COINC_UP_ABAR		: IN STD_LOGIC;
			COINC_UP_A			: IN STD_LOGIC;
			COINC_UP_BLATCH		: OUT STD_LOGIC;
			COINC_UP_BBAR		: IN STD_LOGIC;
			COINC_UP_B			: IN STD_LOGIC;
			-- test connector
			TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT hit_counter
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- setup
			gatetime	: IN STD_LOGIC := '0'; 
			-- discriminator input
			MultiSPE		: IN STD_LOGIC;
			OneSPE			: IN STD_LOGIC;
			-- discriminator reset
			MultiSPE_nl		: OUT STD_LOGIC;
			OneSPE_nl		: OUT STD_LOGIC;
			-- output
			multiSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
			oneSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
			-- test connector
			TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT hit_counter_ff
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- setup
			gatetime	: IN STD_LOGIC := '0'; 
			-- discriminator input
			MultiSPE		: IN STD_LOGIC;
			OneSPE			: IN STD_LOGIC;
			-- output
			multiSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
			oneSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
			-- test connector
			TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;

	COMPONENT atwd
		PORT (
			CLK20		: IN STD_LOGIC;
			CLK40		: IN STD_LOGIC;
			CLK80		: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- enable
			enable		: IN STD_LOGIC;
			enable_disc	: IN STD_LOGIC;
			enable_LED	: IN STD_LOGIC;
			done		: OUT STD_LOGIC;
			-- disc
			OneSPE		: IN STD_LOGIC;
			LEDtrig		: IN STD_LOGIC;
			-- stripe interface
			wdata		: IN STD_LOGIC_VECTOR (15 downto 0);
			rdata		: OUT STD_LOGIC_VECTOR (15 downto 0);
			address		: IN STD_LOGIC_VECTOR (8 downto 0);
			write_en	: IN STD_LOGIC;
			-- atwd
			ATWD_D			: IN STD_LOGIC_VECTOR (9 downto 0);
			ATWDTrigger		: OUT STD_LOGIC;
			TriggerComplete	: IN STD_LOGIC;
			OutputEnable	: OUT STD_LOGIC;
			CounterClock	: OUT STD_LOGIC;
			ShiftClock		: OUT STD_LOGIC;
			RampSet			: OUT STD_LOGIC;
			ChannelSelect	: OUT STD_LOGIC_VECTOR(1 downto 0);
			ReadWrite		: OUT STD_LOGIC;
			AnalogReset		: OUT STD_LOGIC;
			DigitalReset	: OUT STD_LOGIC;
			DigitalSet		: OUT STD_LOGIC;
			ATWD_VDD_SUP	: OUT STD_LOGIC;
			-- for ping-pong
            atwd_trig_doneB	: OUT STD_LOGIC;
			-- test connector
			TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT atwd_ping_pong
        PORT (
            CLK40		: IN STD_LOGIC;
            RST			: IN STD_LOGIC;
            -- single atwd discriminator enables from command register
            cmd_atwd0_enable_disc : IN STD_LOGIC;
            cmd_atwd1_enable_disc : IN STD_LOGIC;
            -- ping-pong mode from command register
            cmd_ping_pong         : IN STD_LOGIC;        
            -- CPU atwd read handshake
            cmd_atwd0_read_done   : IN STD_LOGIC;
            cmd_atwd1_read_done   : IN STD_LOGIC;
            -- atwd interface
            atwd0_trig_doneB      : IN STD_LOGIC;
            atwd1_trig_doneB      : IN STD_LOGIC;
            atwd0_enable_disc     : OUT STD_LOGIC;
            atwd1_enable_disc     : OUT STD_LOGIC;
			-- test connector
			TC					  : OUT STD_LOGIC_VECTOR(7 downto 0)
            );
    END COMPONENT;

	COMPONENT atwd_timestamp
        PORT (
            CLK40		: IN STD_LOGIC;
            RST			: IN STD_LOGIC;
            -- ATWD triggers
            atwd0_trigger   : IN    STD_LOGIC;
            atwd1_trigger   : IN    STD_LOGIC;        
            -- system time
            systime			: IN	STD_LOGIC_VECTOR(47 DOWNTO 0);
            -- timestamps
            atwd0_timestamp : OUT	STD_LOGIC_VECTOR(47 DOWNTO 0);
            atwd1_timestamp : OUT	STD_LOGIC_VECTOR(47 DOWNTO 0)
            );
    END COMPONENT;
	
	COMPONENT master_data_source
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
	END COMPONENT;
	
	COMPONENT r2r
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- enable for TX
			enable		: IN STD_LOGIC;
			-- communications DAC connections
			R2BUS		: OUT STD_LOGIC_VECTOR (6 downto 0);
			-- test connector
			TC			: OUT	STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT fe_r2r
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- enable for TX
			enable		: IN STD_LOGIC;
			-- communications DAC connections
			FE_PULSER_P		: OUT STD_LOGIC_VECTOR (3 downto 0);
			FE_PULSER_N		: OUT STD_LOGIC_VECTOR (3 downto 0);
			-- test connector
			TC			: OUT	STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT flasher_board
		PORT (
			CLK					: IN STD_LOGIC;
			RST					: IN STD_LOGIC;
			-- enable flasher board flash
			enable				: IN STD_LOGIC;
			-- control input
			fl_board			: IN STD_LOGIC_VECTOR(7 downto 0);
			fl_board_read		: OUT STD_LOGIC_VECTOR(1 downto 0);
			-- ATWD trigger
			trigLED		: OUT STD_LOGIC;
			-- flasher board
			FL_Trigger			: OUT STD_LOGIC;
			FL_Trigger_bar		: OUT STD_LOGIC;
			FL_ATTN				: IN STD_LOGIC;
			FL_PRE_TRIG			: OUT STD_LOGIC;
			FL_TMS				: OUT STD_LOGIC;
			FL_TCK				: OUT STD_LOGIC;
			FL_TDI				: OUT STD_LOGIC;
			FL_TDO				: IN STD_LOGIC;
			-- Test connector
			TC					: OUT STD_LOGIC_VECTOR (7 downto 0)
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
	response_1(4)	<= com_adc_done;
	-- RS485
	rs486_ena		<= command_1(10 downto 9);
	rs486_tx		<= command_1(8);
	response_1(8)	<= rs486_rx;
	enable_rs485	<= command_1(11);
	
	-- local coincidence
	enable_coinc_up		<= command_2(0);
	enable_coinc_down	<= command_2(1);
	coinc_down_high		<= command_2(8);
	coinc_down_low		<= command_2(9);
	coinc_up_high		<= command_2(10);
	coinc_up_low		<= command_2(11);
	coinc_latch			<= command_2(15 downto 12);
	response_2(15 downto 8)	<= coinc_disc;
	-- flasher board
	fl_board		<= command_2(31 downto 24);
	enable_flasher	<= command_2(24);
	response_2(24)	<= fl_board_read(0);
	response_2(28)	<= fl_board_read(1);
	
	-- LED 2 ATWD trigger delay
	LEDdelay	<= command_4(3 DOWNTO 0);
	
	
	response_0(31 downto 17)	<= (others=>'0');
	response_0(15 downto 9)		<= (others=>'0');
	response_0(7 downto 1)		<= (others=>'0');
	
	response_1(31 downto 9)	<= (others=>'0');
	response_1(8 downto 4)	<= (others=>'0');
	response_1(3 downto 0)	<= (others=>'0');
	
	response_2(31 downto 29)	<= (others=>'0');
	response_2(27 downto 25)	<= (others=>'0');
	response_2(23 downto 16)	<= (others=>'0');
	response_2(7 downto 0)		<= (others=>'0');
	
	response_4	<= (others=>'0');
	
	-- hit counter
	hit_counter_gate			<= command_4(8);
	hitcounter_o(15 downto 0)	<= oneSPEcnt;
	hitcounter_o(31 downto 16)	<= (others=>'0');
	hitcounter_m(15 downto 0)	<= multiSPEcnt;
	hitcounter_m(31 downto 16)	<= (others=>'0');
	hitcounter_o_ff(15 downto 0)	<= oneSPEcnt_ff;
	hitcounter_o_ff(31 downto 16)	<= (others=>'0');
	hitcounter_m_ff(15 downto 0)	<= multiSPEcnt_ff;
	hitcounter_m_ff(31 downto 16)	<= (others=>'0');
	
	
	
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
		
		
	inst_fe_testpulse : fe_testpulse
		PORT MAP (
			CLK			=> CLK20,
			RST			=> RST,
			-- enable flasher
			enable		=> fe_pulser_enable,
			divider		=> fe_divider,
			-- LED trigger
			FE_TEST_PULSE	=> FE_TEST_PULSE
		);
	
	inst_single_led : single_led
		PORT MAP (
			CLK			=> CLK20,
			RST			=> RST,
			-- enable flasher
			enable		=> single_led_enable,
			-- LED trigger
			SingleLED_TRIGGER	=> SingleLED_TRIGGER_sig,
			-- ATWD trigger
			trigLED		=> trigLED_onboard
		);
	SingleLED_TRIGGER <= SingleLED_TRIGGER_sig;
		
	inst_coinc : coinc
		PORT MAP (
			CLK					=> CLK20,
			RST					=> RST,
			-- enable
			enable_coinc_down	=> enable_coinc_down,
			enable_coinc_up		=> enable_coinc_up,
			-- manual control
			coinc_up_high		=> coinc_up_high,
			coinc_up_low		=> coinc_up_low,
			coinc_down_high		=> coinc_down_high,
			coinc_down_low		=> coinc_down_low,
			coinc_latch			=> coinc_latch,
			coinc_disc			=> coinc_disc,
			-- local coincidence
			COINCIDENCE_OUT_DOWN	=> COINCIDENCE_OUT_DOWN,
			COINC_DOWN_ALATCH	=> COINC_DOWN_ALATCH,
			COINC_DOWN_ABAR		=> COINC_DOWN_ABAR,
			COINC_DOWN_A		=> COINC_DOWN_A,
			COINC_DOWN_BLATCH	=> COINC_DOWN_BLATCH,
			COINC_DOWN_BBAR		=> COINC_DOWN_BBAR,
			COINC_DOWN_B		=> COINC_DOWN_B,
			COINCIDENCE_OUT_UP	=> COINCIDENCE_OUT_UP,
			COINC_UP_ALATCH		=> COINC_UP_ALATCH,
			COINC_UP_ABAR		=> COINC_UP_ABAR,
			COINC_UP_A			=> COINC_UP_A,
			COINC_UP_BLATCH		=> COINC_UP_BLATCH,
			COINC_UP_BBAR		=> COINC_UP_BBAR,
			COINC_UP_B			=> COINC_UP_B,
			-- test connector
			TC					=> TC
		);
		
	inst_hit_counter : hit_counter
		PORT MAP (
			CLK				=> CLK20,
			RST				=> RST,
			-- setup
			gatetime		=> hit_counter_gate,
			-- discriminator input
			MultiSPE		=> MultiSPE,
			OneSPE			=> OneSPE,
			-- discriminator reset
			MultiSPE_nl		=> MultiSPE_nl,
			OneSPE_nl		=> OneSPE_nl,
			-- output
			multiSPEcnt		=> multiSPEcnt,
			oneSPEcnt		=> oneSPEcnt,
			-- test connector
			TC				=> open
		);
		
	inst_hit_counter_ff : hit_counter_ff
		PORT MAP (
			CLK				=> CLK20,
			RST				=> RST,
			-- setup
			gatetime		=> hit_counter_gate,
			-- discriminator input
			MultiSPE		=> MultiSPE,
			OneSPE			=> OneSPE,
			-- output
			multiSPEcnt		=> multiSPEcnt_ff,
			oneSPEcnt		=> oneSPEcnt_ff,
			-- test connector
			TC				=> open
		);
		
	inst_atwd_ping_pong : atwd_ping_pong
        PORT MAP (
            CLK40                 => CLK40,
            RST                   => RST,
            -- single atwd discriminator enables from command register
            cmd_atwd0_enable_disc => command_0(1),
            cmd_atwd1_enable_disc => command_0(9),
            -- ping-pong mode from command register
            cmd_ping_pong         => command_0(15), 
            -- CPU atwd read handshake
            cmd_atwd0_read_done   => command_0(2),
            cmd_atwd1_read_done   => command_0(10),
            -- atwd interface
            atwd0_trig_doneB      => atwd0_trig_doneB,
            atwd1_trig_doneB      => atwd1_trig_doneB,
            atwd0_enable_disc     => atwd0_enable_disc,
            atwd1_enable_disc     => atwd1_enable_disc,
			-- test connector
			TC                    => open       
        );
	
    inst_atwd_timestamp : atwd_timestamp
        PORT MAP (
            CLK40                 => CLK40,
            RST                   => RST,
            -- ATWD triggers
            atwd0_trigger         => atwd0_trigger,
            atwd1_trigger         => atwd1_trigger,
            -- system time
            systime               => systime,
            -- timestamps
            atwd0_timestamp       => atwd0_timestamp,
            atwd1_timestamp       => atwd1_timestamp
        );
		
	atwd0 : atwd
		PORT MAP (
			CLK20		=> CLK20,
			CLK40		=> CLK40,
			CLK80		=> CLK80,
			RST			=> RST,
			-- enable
			enable		=> atwd0_enable,
			enable_disc	=> atwd0_enable_disc,
			enable_LED	=> atwd0_enable_LED,
			done		=> atwd0_done,
			-- disc
			OneSPE		=> OneSPE,
			LEDtrig		=> LEDtrig,
			-- stripe interface
			wdata		=> atwd0_wdata,
			rdata		=> atwd0_rdata,
			address		=> atwd0_address,
			write_en	=> atwd0_write_en,
			-- atwd
			ATWD_D			=> ATWD0_D,
			ATWDTrigger		=> atwd0_trigger,
			TriggerComplete	=> TriggerComplete_0,
			OutputEnable	=> OutputEnable_0,
			CounterClock	=> CounterClock_0,
			ShiftClock		=> ShiftClock_0,
			RampSet			=> RampSet_0,
			ChannelSelect	=> ChannelSelect_0,
			ReadWrite		=> ReadWrite_0,
			AnalogReset		=> AnalogReset_0,
			DigitalReset	=> DigitalReset_0,
			DigitalSet		=> DigitalSet_0,
			ATWD_VDD_SUP	=> ATWD0VDD_SUP,
			-- for ping-pong
            atwd_trig_doneB => atwd0_trig_doneB,
			-- test connector
			TC				=> open
		);
	ATWDTrigger_0 <= atwd0_trigger;
	
	atwd1 : atwd
		PORT MAP (
			CLK20		=> CLK20,
			CLK40		=> CLK40,
			CLK80		=> CLK80,
			RST			=> RST,
			-- enable
			enable		=> atwd1_enable,
			enable_disc	=> atwd1_enable_disc,
			enable_LED	=> atwd1_enable_LED,
			done		=> atwd1_done,
			-- disc
			OneSPE		=> OneSPE,
			LEDtrig		=> LEDtrig,
			-- stripe interface
			wdata		=> atwd1_wdata,
			rdata		=> atwd1_rdata,
			address		=> atwd1_address,
			write_en	=> atwd1_write_en,
			-- atwd
			ATWD_D			=> ATWD1_D,
			ATWDTrigger		=> atwd1_trigger,
			TriggerComplete	=> TriggerComplete_1,
			OutputEnable	=> OutputEnable_1,
			CounterClock	=> CounterClock_1,
			ShiftClock		=> ShiftClock_1,
			RampSet			=> RampSet_1,
			ChannelSelect	=> ChannelSelect_1,
			ReadWrite		=> ReadWrite_1,
			AnalogReset		=> AnalogReset_1,
			DigitalReset	=> DigitalReset_1,
			DigitalSet		=> DigitalSet_1,
			ATWD_VDD_SUP	=> ATWD1VDD_SUP,
			-- for ping-pong
            atwd_trig_doneB => atwd1_trig_doneB,
			-- test connector
			TC				=> open
		);
	ATWDTrigger_1 <= atwd1_trigger;
		
	inst_master_data_source : master_data_source
		PORT MAP (
			CLK			=> CLK20,
			RST			=> RST,
			-- control signals
			enable		=> master_enable,
			done		=> master_done,
			berr		=> master_berr,
			addr_start	=> master_addr_start,
			-- local bus signals
			start_trans		=> start_trans,
			address			=> address,
			wdata			=> wdata,
			wait_sig		=> wait_sig,
			trans_length	=> trans_length,
			bus_error		=> bus_error
		);
		
	inst_r2r : r2r
		PORT MAP (
			CLK			=> CLK20,
			RST			=> RST,
			-- enable for TX
			enable		=> enable_r2r,
			-- communications DAC connections
			R2BUS		=> R2BUS,
			-- test connector
			TC			=> open
		);
		
	inst_fe_r2r : fe_r2r
		PORT MAP (
			CLK			=> CLK20,
			RST			=> RST,
			-- enable for TX
			enable		=> enable_fe_r2r,
			-- communications DAC connections
			FE_PULSER_P	=> FE_PULSER_P,
			FE_PULSER_N	=> FE_PULSER_N,
			-- test connector
			TC			=> open
		);
		
	flasher_board_inst : flasher_board
		PORT MAP (
			CLK					=> CLK20,
			RST					=> RST,
			-- enable flasher board flash
			enable				=> enable_flasher,
			-- control input
			fl_board			=> fl_board,
			fl_board_read		=> fl_board_read,
			-- ATWD trigger
			trigLED				=> trigLED_flasher,
			-- flasher board
			FL_Trigger			=> FL_Trigger,
			FL_Trigger_bar		=> FL_Trigger_bar,
			FL_ATTN				=> FL_ATTN,
			FL_PRE_TRIG			=> FL_PRE_TRIG,
			FL_TMS				=> FL_TMS,
			FL_TCK				=> FL_TCK,
			FL_TDI				=> FL_TDI,
			FL_TDO				=> FL_TDO,
			-- Test connector
			TC					=> open
		);
	
	timer_inst : timer
		PORT MAP (
			CLK		=> CLK40,
			RST		=> RST,
			systime	=> systime
		);
		
	LED2ATWDdelay_inst : LED2ATWDdelay
		PORT MAP (
			CLK40		=> CLK40,
			RST			=> RST,
			delay		=> LEDdelay,
			LEDin		=> trigLED,
			TRIGout		=> LEDtrig,
			-- test connector
			TC			=> open
		);
	trigLED	<= trigLED_flasher OR trigLED_onboard;
	
	
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
