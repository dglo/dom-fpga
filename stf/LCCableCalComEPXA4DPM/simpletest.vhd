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
-- Description: This is the top level design for the STF without Kalle's
--              communications code (this allows testing of the communication
--              hardware)for the EPXA4
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten  
-- 2004-10-22              thorsten  added LC_abort
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
		COMM_RESET		: OUT STD_LOGIC;
		FPGA_LOADED		: OUT STD_LOGIC;
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
		-- FLASH ADC
		FLASH_AD_D		: IN STD_LOGIC_VECTOR (9 downto 0);
		-- FLASH_AD_CLK	: OUT STD_LOGIC;
		FLASH_AD_STBY	: OUT STD_LOGIC;
		FLASH_NCO		: IN STD_LOGIC;
		-- ATWD 0
		ATWD0_D			: IN STD_LOGIC_VECTOR (9 downto 0);
		ATWDTrigger_0	: OUT STD_LOGIC;
		TriggerComplete_0	: IN STD_LOGIC;
		OutputEnable_0	: OUT STD_LOGIC;
		CounterClock_0	: OUT STD_LOGIC;
		ShiftClock_0	: OUT STD_LOGIC;
		RampSet_0		: OUT STD_LOGIC;
		ChannelSelect_0	: OUT STD_LOGIC_VECTOR(1 downto 0);
		ReadWrite_0		: OUT STD_LOGIC;
		AnalogReset_0	: OUT STD_LOGIC;
		DigitalReset_0	: OUT STD_LOGIC;
		DigitalSet_0	: OUT STD_LOGIC;
		ATWD0VDD_SUP	: OUT STD_LOGIC;
		-- ATWD 1
		ATWD1_D			: IN STD_LOGIC_VECTOR (9 downto 0);
		ATWDTrigger_1	: OUT STD_LOGIC;
		TriggerComplete_1	: IN STD_LOGIC;
		OutputEnable_1	: OUT STD_LOGIC;
		CounterClock_1	: OUT STD_LOGIC;
		ShiftClock_1	: OUT STD_LOGIC;
		RampSet_1		: OUT STD_LOGIC;
		ChannelSelect_1	: OUT STD_LOGIC_VECTOR(1 downto 0);
		ReadWrite_1		: OUT STD_LOGIC;
		AnalogReset_1	: OUT STD_LOGIC;
		DigitalReset_1	: OUT STD_LOGIC;
		DigitalSet_1	: OUT STD_LOGIC;
		ATWD1VDD_SUP	: OUT STD_LOGIC;
		-- discriminator
		MultiSPE		: IN STD_LOGIC;
		OneSPE			: IN STD_LOGIC;
		MultiSPE_nl		: OUT STD_LOGIC;
		OneSPE_nl		: OUT STD_LOGIC;
		-- frontend testpulser (pulse)
		FE_TEST_PULSE	: OUT STD_LOGIC;
		-- frontend testpulser (R2R ladder into signal path)
		FE_PULSER_P		: OUT STD_LOGIC_VECTOR (3 downto 0);
		FE_PULSER_N		: OUT STD_LOGIC_VECTOR (3 downto 0);
		-- frontend testpulser (R2R ladder ATWD ch3 MUX)
		R2BUS			: OUT STD_LOGIC_VECTOR (6 downto 0);
		-- on board single LED flasher
		SingleLED_TRIGGER	: OUT STD_LOGIC;
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
		-- flasher board
		FL_Trigger			: OUT STD_LOGIC;
		FL_Trigger_bar		: OUT STD_LOGIC;
		FL_ATTN				: IN STD_LOGIC;
		FL_PRE_TRIG			: OUT STD_LOGIC;
		FL_TMS				: OUT STD_LOGIC;
		FL_TCK				: OUT STD_LOGIC;
		FL_TDI				: OUT STD_LOGIC;
		FL_TDO				: IN STD_LOGIC;
		-- A_nB switch
		A_nB				: IN STD_LOGIC;
		-- CPDL FPGA interface    currently used to show FPGA is confugured
		PDL_FPGA_D			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
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
	
	SIGNAL B_nA		: STD_LOGIC;
	
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
	SIGNAL dp0_portaaddr	: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL dp0_portadatain	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL dp0_portadataout	: STD_LOGIC_VECTOR(31 downto 0) := (OTHERS=>'0');
	SIGNAL dp1_3_portaclk	: STD_LOGIC;
	SIGNAL dp1_portawe		: STD_LOGIC;
	SIGNAL dp1_portaaddr	: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL dp1_portadatain	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL dp1_portadataout	: STD_LOGIC_VECTOR(31 downto 0);
	
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
	SIGNAL response_0	: STD_LOGIC_VECTOR(31 downto 0) := (OTHERS=>'0');
	SIGNAL command_1	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL response_1	: STD_LOGIC_VECTOR(31 downto 0) := (OTHERS=>'0');
	SIGNAL command_2	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL response_2	: STD_LOGIC_VECTOR(31 downto 0) := (OTHERS=>'0');
	SIGNAL command_3	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL response_3	: STD_LOGIC_VECTOR(31 downto 0) := (OTHERS=>'0');
	SIGNAL command_4	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL response_4	: STD_LOGIC_VECTOR(31 downto 0) := (OTHERS=>'0');
	SIGNAL command_5	: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL response_5	: STD_LOGIC_VECTOR(31 downto 0) := (OTHERS=>'0');
	
	
	-- local coincidence
	SIGNAL enable_coinc_up		: STD_LOGIC;
	SIGNAL enable_coinc_down	: STD_LOGIC;
	SIGNAL enable_coinc_newFF	: STD_LOGIC;
	SIGNAL coinc_down_high		: STD_LOGIC;
	SIGNAL coinc_down_low		: STD_LOGIC;
	SIGNAL coinc_up_high		: STD_LOGIC;
	SIGNAL coinc_up_low			: STD_LOGIC;
	SIGNAL coinc_latch			: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL coinc_disc			: STD_LOGIC_VECTOR(7 downto 0);
	-- simple LC
	SIGNAL LC_ATWD0				: STD_LOGIC;
	SIGNAL LC_ATWD1				: STD_LOGIC;
	SIGNAL enable_coinc_atwd	: STD_LOGIC;
	SIGNAL atwd0_LC_abort		: STD_LOGIC;
	SIGNAL atwd1_LC_abort		: STD_LOGIC;
	SIGNAL LC_rx_down_en		: STD_LOGIC;
	SIGNAL LC_rx_up_en		: STD_LOGIC;
	SIGNAL atwd0_trigger_delay	: STD_LOGIC;
	SIGNAL atwd0_trigger_latch	: STD_LOGIC;
	SIGNAL atwd1_trigger_delay	: STD_LOGIC;
	SIGNAL atwd1_trigger_latch	: STD_LOGIC;
	SIGNAL flash_adc_enable_lc	: STD_LOGIC;                                  
	
	-- AHB master
	SIGNAL start_trans		: STD_LOGIC;
	SIGNAL address			: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL wdata			: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL wait_sig			: STD_LOGIC;
	SIGNAL trans_length		: INTEGER;
	SIGNAL bus_error		: STD_LOGIC;
	SIGNAL master_addr_start	: STD_LOGIC_VECTOR(15 downto 0);
	
	-- kale communication
	SIGNAL com_tx_data		: STD_LOGIC_VECTOR (31 downto 0);
	SIGNAL com_rx_data		: STD_LOGIC_VECTOR (31 downto 0);
	SIGNAL com_tx_fifo		: STD_LOGIC_VECTOR (7 downto 0);
	SIGNAL com_rx_fifo		: STD_LOGIC_VECTOR (7 downto 0);
	SIGNAL com_ctrl			: STD_LOGIC_VECTOR (31 downto 0);
	SIGNAL com_status		: STD_LOGIC_VECTOR (31 downto 0);
	
	SIGNAL tx_fifo_wr		: STD_LOGIC;
	SIGNAL rx_fifo_rd		: STD_LOGIC;
	SIGNAL msg_rd			: STD_LOGIC;
	SIGNAL fifo_msg			: STD_LOGIC;
	SIGNAL rxrdef			: STD_LOGIC;
	SIGNAL txwraef			: STD_LOGIC;
	SIGNAL txwraff			: STD_LOGIC;
	SIGNAL msg_ct_q			: STD_LOGIC_VECTOR (7 downto 0);
	SIGNAL txrdef			: STD_LOGIC;
	SIGNAL rxwrff			: STD_LOGIC;
	SIGNAL rxwraff			: STD_LOGIC;
	SIGNAL temp_data		: STD_LOGIC_VECTOR (7 downto 0);
	SIGNAL RST_kalle		: STD_LOGIC;
--	SIGNAL ctrl_err			: STD_LOGIC;
--	SIGNAL ctrl_err_cnt		: STD_LOGIC_VECTOR (7 downto 0);
	
	SIGNAL dudt				: STD_LOGIC_VECTOR (7 downto 0);
	SIGNAL drbt_req			: STD_LOGIC;
	SIGNAL drbt_gnt			: STD_LOGIC;
	SIGNAL com_aval			: STD_LOGIC;
	SIGNAL rs485_not_dac	: STD_LOGIC;
--	SIGNAL sys_reset		: STD_LOGIC;
	SIGNAL cal_thr			: STD_LOGIC_VECTOR (9 DOWNTO 0);
	
	-- new signals for DPM communicatios
	SIGNAL tx_alm_empty		: STD_LOGIC;
	SIGNAL tx_pack_sent		: STD_LOGIC;
	SIGNAL rx_pack_rcvd		: STD_LOGIC;
	SIGNAL com_reset_rcvd	: STD_LOGIC;
	SIGNAL rx_dpr_aff		: STD_LOGIC;
	SIGNAL com_avail		: STD_LOGIC;
	SIGNAL rx_addr			: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL rx_dpr_radr		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL tx_dpr_radr		: STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS=>'0');
	SIGNAL tx_dpr_wadr		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL COMM_nRESET		: STD_LOGIC;
	SIGNAL tx_pack_rdy		: STD_LOGIC;
	SIGNAL rx_dpr_radr_stb	: STD_LOGIC;
	SIGNAL rx_error			: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL tx_error			: STD_LOGIC_VECTOR (15 DOWNTO 0);
	
	
	-- LC cable length measurement
	SIGNAL DO_CAL			: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL CAL_TIME_UP		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL CAL_TIME_DOWN	: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL PING_DELAY		: STD_LOGIC;

	
	SIGNAL systime			: STD_LOGIC_VECTOR (47 DOWNTO 0);
	SIGNAL atwd0_timestamp  : STD_LOGIC_VECTOR (47 DOWNTO 0);
	SIGNAL atwd1_timestamp  : STD_LOGIC_VECTOR (47 DOWNTO 0);
	SIGNAL dom_id			: STD_LOGIC_VECTOR (63 DOWNTO 0);
	
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
			dp0_portaaddr		: IN	STD_LOGIC_VECTOR(12 downto 0);
			dp0_portadatain		: IN	STD_LOGIC_VECTOR(31 downto 0);
			dp0_portadataout	: OUT	STD_LOGIC_VECTOR(31 downto 0);
			dp1_3_portaclk		: IN	STD_LOGIC;
			dp1_portawe			: IN	STD_LOGIC;
			dp1_portaaddr		: IN	STD_LOGIC_VECTOR(12 downto 0);
			dp1_portadatain		: IN	STD_LOGIC_VECTOR(31 downto 0);
			dp1_portadataout	: OUT	STD_LOGIC_VECTOR(31 downto 0);
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
			atwd0_timestamp	: IN	STD_LOGIC_VECTOR(47 DOWNTO 0);
			atwd1_timestamp : IN	STD_LOGIC_VECTOR(47 DOWNTO 0);
			dom_id			: OUT	STD_LOGIC_VECTOR(63 DOWNTO 0);
			command_4		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			response_4		: IN	STD_LOGIC_VECTOR(31 downto 0);
			command_5		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			response_5		: IN	STD_LOGIC_VECTOR(31 downto 0);
			tx_dpr_wadr		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			tx_dpr_radr		: IN	STD_LOGIC_VECTOR(31 downto 0);
			rx_dpr_radr		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			rx_addr			: IN	STD_LOGIC_VECTOR(31 downto 0);
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
			tx_pack_rdy			: OUT STD_LOGIC;
			rx_dpr_radr_stb		: OUT STD_LOGIC;
			com_reset_rcvd		: IN STD_LOGIC;
			-- test connector
			TC				: OUT	STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT coinc
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- enable
			enable_coinc_down	: IN STD_LOGIC;
			enable_coinc_up		: IN STD_LOGIC;
			newFF				: IN STD_LOGIC;
			enable_coinc_atwd	: IN STD_LOGIC := '0';
			-- simple LC
			OneSPE				: IN STD_LOGIC;
			LC_rx_down_en		: IN STD_LOGIC := '1';
			LC_rx_up_en			: IN STD_LOGIC := '1';
			LC_up_pre_window	: IN STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
			LC_up_post_window	: IN STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
			LC_down_pre_window	: IN STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
			LC_down_post_window	: IN STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
			LC_atwd_a			: OUT STD_LOGIC;
			LC_atwd_b			: OUT STD_LOGIC;
			atwd0_LC_abort		: OUT STD_LOGIC;
			atwd1_LC_abort		: OUT STD_LOGIC;
			atwd_a_enable_disc	: IN STD_LOGIC := '0';
			atwd_b_enable_disc	: IN STD_LOGIC := '0';
			atwd0_trigger		: IN STD_LOGIC := '0';
			atwd1_trigger		: IN STD_LOGIC := '0';
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
	
	-- Kalle DPM

	COMPONENT dcom_ap
		port
		(
			tx_pack_rdy :  IN  STD_LOGIC;
			rx_dpr_radr_stb :  IN  STD_LOGIC;
			A_nB :  IN  STD_LOGIC;
			reboot_req :  IN  STD_LOGIC;
			id_avail :  IN  STD_LOGIC;
			HVD_Rx :  IN  STD_LOGIC;
			CLK20 :  IN  STD_LOGIC;
			RST :  IN  STD_LOGIC;
			COM_AD_D :  IN  STD_LOGIC_VECTOR(9 downto 0);
			id :  IN  STD_LOGIC_VECTOR(47 downto 0);
			rx_dpr_radr :  IN  STD_LOGIC_VECTOR(15 downto 0);
			systime :  IN  STD_LOGIC_VECTOR(47 downto 0);
			tc :  OUT  STD_LOGIC_VECTOR(7 downto 0);
			tx_dataout :  IN  STD_LOGIC_VECTOR(31 downto 0);
			tx_dpr_wadr :  IN  STD_LOGIC_VECTOR(15 downto 0);
			tx_pack_sent :  OUT  STD_LOGIC;
			rx_dpr_aff :  OUT  STD_LOGIC;
			rx_pack_rcvd :  OUT  STD_LOGIC;
			rx_we :  OUT  STD_LOGIC;
			HVD_RxENA :  OUT  STD_LOGIC;
			reboot_gnt :  OUT  STD_LOGIC;
			com_avail :  OUT  STD_LOGIC;
			COMM_RESET :  OUT  STD_LOGIC;
			COM_TX_SLEEP :  OUT  STD_LOGIC;
			HVD_IN :  OUT  STD_LOGIC;
			HVD_TxENA :  OUT  STD_LOGIC;
			tx_alm_empty :  OUT  STD_LOGIC;
			com_reset_rcvd :  OUT  STD_LOGIC;
			msg_rd :  OUT  STD_LOGIC;
			data_rcvd :  OUT  STD_LOGIC;
			COM_DB :  OUT  STD_LOGIC_VECTOR(7 downto 0);
			rev :  OUT  STD_LOGIC_VECTOR(15 downto 0);
			rx_addr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
			rx_datain :  OUT  STD_LOGIC_VECTOR(31 downto 0);
			rx_error :  OUT  STD_LOGIC_VECTOR(15 downto 0);
			tx_addr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
			tx_dpr_radr :  OUT  STD_LOGIC_VECTOR(15 downto 0);
			tx_error :  OUT  STD_LOGIC_VECTOR(15 downto 0)
		);
	END COMPONENT;

	
	COMPONENT timer
		PORT (
			CLK     : IN  STD_LOGIC;
			RST     : IN  STD_LOGIC;
			systime : OUT STD_LOGIC_VECTOR (47 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT cal_local_coincidence IS
	    PORT (
	        -- Common Inputs
	        CLK20                : IN  STD_LOGIC;
	        CLK40                : IN  STD_LOGIC;
	        CLK80                : IN  STD_LOGIC;
	        RST                  : IN  STD_LOGIC;
	        systime              : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
	        -- DAQ interface
	        DO_CAL			     : IN  STD_LOGIC_VECTOR (1 DOWNTO 0); --DOM got a hit
	        CAL_TIME_UP			     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
	        CAL_TIME_DOWN			     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			PING_DELAY			     : IN  STD_LOGIC;
	        -- I/O
	        COINCIDENCE_OUT_DOWN : OUT STD_LOGIC;  -- '1' for positve, '0' for negative, 'Z' for nothing
	        COINC_DOWN_ALATCH    : OUT STD_LOGIC;  --
	        COINC_DOWN_ABAR      : IN  STD_LOGIC;
	        COINC_DOWN_A         : IN  STD_LOGIC;  -- _A is positve discriminator 
	        COINC_DOWN_BLATCH    : OUT STD_LOGIC;
	        COINC_DOWN_BBAR      : IN  STD_LOGIC;
	        COINC_DOWN_B         : IN  STD_LOGIC;  -- _B is negative discriminator
	        COINCIDENCE_OUT_UP   : OUT STD_LOGIC;
	        COINC_UP_ALATCH      : OUT STD_LOGIC;  --
	        COINC_UP_ABAR        : IN  STD_LOGIC;
	        COINC_UP_A           : IN  STD_LOGIC;  -- _A is positve discriminator 
	        COINC_UP_BLATCH      : OUT STD_LOGIC;
	        COINC_UP_BBAR        : IN  STD_LOGIC;
	        COINC_UP_B           : IN  STD_LOGIC;  -- _B is negative discriminator
	        -- test
	        TC                   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
	END COMPONENT;
	

	
BEGIN
	-- general
	low		<= '0';
	high	<= '1';
	
--	CLK20	<= CLK1p;
--	CLK40	<= CLK1p;
	-- RST		<= '0';
	
	-- PLD to STRIPE bridge
	slavehclk		<= CLK20;
	-- slavehwrite		<= '0';
	-- slavehreadyi	<= '0';
	-- slavehselreg	<= '0';
	-- slavehsel		<= '0';
	-- slavehmastlock	<= '0';
	-- slavehaddr		<= (others=>'0');
	-- slavehtrans		<= (others=>'0');
	-- slavehsize		<= (others=>'0');
	-- slavehburst		<= (others=>'0');
	-- slavehwdata		<= (others=>'0');
	-- slavehreadyo	<= ;
	-- slavebuserrint	<= ;
	-- slavehresp		<= ;
	-- slavehrdata		<= ;
	
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
	--	dp0_portaaddr		<= (others=>'0');
	dp0_portadatain		<= (others=>'0');
	-- dp0_portadataout	<= ;
	dp1_3_portaclk		<= CLK20;
	--	dp1_portawe			<= '0';
	--	dp1_portaaddr		<= (others=>'0');
	--	dp1_portadatain		<= (others=>'0');
	-- dp2_portadataout	<= ;
	
	-- interrupts
	intpld	<= (others=>'0');
	
	-- GP stripe IO
	gpi(7 downto 0)		<= (others=>'0');
	-- gpo		<= ;
	
	
	-- LC cable length measurement
	DO_CAL						<= command_2 (1 DOWNTO 0);
	PING_DELAY					<= command_2 (2);
	TC(0)						<= PING_DELAY;
	response_2 (7 DOWNTO 0)		<= CAL_TIME_UP;
	response_2 (23 DOWNTO 16)	<= CAL_TIME_DOWN;
	
	
	response_0(31 downto 17)	<= (others=>'0');
	response_0(15 downto 10)		<= (others=>'0');
	response_0(7 downto 2)		<= (others=>'0');
	
	response_1(31 downto 9)	<= (others=>'0');
	response_1(8 downto 4)	<= (others=>'0');
	response_1(3 downto 0)	<= (others=>'0');
	
	response_2(31 downto 24)	<= (others=>'0');
	response_2(15 downto 8)	<= (others=>'0');
	
	response_4	<= (others=>'0');
	
	-- fake kallo communication reset
	-- com_status(2)	<= com_ctrl(2);
	
	
	-- kale communications
--	com_tx_fifo					<= com_tx_data(7 downto 0);
--	com_rx_data(7 downto 0)		<= com_rx_fifo;
--	com_rx_data(31 downto 8)	<= (others=>'1');
	PROCESS(CLK20,RST)
		VARIABLE old	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			msg_rd	<= '0';
			old		:= '0';
		ELSIF CLK20'EVENT AND CLK20='1' THEN
			IF com_ctrl(0)='1' AND old='0' THEN
				msg_rd	<= '1';
			ELSE
				msg_rd	<= '0';
			END IF;
			old := com_ctrl(0);
		END IF;
	END PROCESS;
--	com_status(0)	<= fifo_msg;
--	com_status(1)	<= rxrdef;
--	com_status(3)	<= com_aval;
--	com_status(6)	<= rxwraff;
--	com_status(7)	<= rxwrff;
--	com_status(15 downto 8)	<= msg_ct_q;
--	com_status(16)	<= txwraef;
--	com_status(17)	<= txwraff;
--	com_status(20)	<= txrdef;
--	drbt_req		<= com_ctrl(2);
--	dudt			<= com_ctrl(15 downto 8);
--	cal_thr			<= com_ctrl(25 downto 16);
--	rs485_not_dac	<= com_ctrl(3);
	com_status(0)	<= drbt_gnt;
	com_status(1)	<= tx_pack_sent;
	com_status(2)	<= tx_alm_empty;
	com_status(3)	<= rx_pack_rcvd;
	com_status(4)	<= com_reset_rcvd;
	com_status(5)	<= rx_dpr_aff;
	com_status(6)	<= com_avail;
	com_status(31 downto 7)	<= 	(OTHERS=>'0');
	drbt_req		<= com_ctrl(0);

	
--	PROCESS (RST,CLK20)
--	BEGIN
--		IF RST='1' THEN
--			com_status(31 downto 24)	<= (others=>'0');
--		ELSIF CLK20'EVENT AND CLK20='1' THEN
--			IF tx_fifo_wr='1' THEN
--				com_status(31 downto 24)	<= com_tx_fifo;
--			END IF;
--		END IF;
--	END PROCESS;
--	PROCESS (RST, CLK20)
--	BEGIN
--		IF RST='1' THEN
--			ctrl_err_cnt	<= (others=>'0');
--		ELSIF CLK20'EVENT AND CLK20='1' THEN
--			IF ctrl_err='1' THEN
--				ctrl_err_cnt <= ctrl_err_cnt + 1;
--			END IF;
--		END IF;
--	END PROCESS;
	-- com_status(31 downto 24)	<= 	ctrl_err_cnt;
	
	
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
			dp0_portaaddr		=> dp0_portaaddr(12 DOWNTO 0),
			dp0_portadatain		=> dp0_portadatain,
			dp0_portadataout	=> dp0_portadataout,
			dp1_3_portaclk		=> dp1_3_portaclk,
			dp1_portawe			=> dp1_portawe,
			dp1_portaaddr		=> dp1_portaaddr(12 DOWNTO 0),
			dp1_portadatain		=> dp1_portadatain,
			dp1_portadataout	=> open,
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
			com_tx_data		=> com_tx_data,
			com_rx_data		=> com_rx_data,
			hitcounter_o	=> (OTHERS=>'0'),
			hitcounter_m	=> (OTHERS=>'0'),
			hitcounter_o_ff	=> (OTHERS=>'0'),
			hitcounter_m_ff	=> (OTHERS=>'0'),
			systime			=> systime,
			atwd0_timestamp	=> atwd0_timestamp, 
			atwd1_timestamp	=> atwd1_timestamp,
			dom_id			=> dom_id,
			command_4		=> command_4,
			response_4		=> response_4,
			command_5		=> command_5,
			response_5		=> response_5,
			tx_dpr_wadr		=> tx_dpr_wadr,
			tx_dpr_radr		=> tx_dpr_radr,
			rx_dpr_radr		=> rx_dpr_radr,
			rx_addr			=> rx_addr,
			-- COM ADC RX interface
			com_adc_wdata		=> open,
			com_adc_rdata		=> (OTHERS=>'0'),
			com_adc_address		=> open,
			com_adc_write_en	=> open,
			-- FLASH ADC RX interface
			flash_adc_wdata		=> open,
			flash_adc_rdata		=> (OTHERS=>'0'),
			flash_adc_address	=> open,
			flash_adc_write_en	=> open,
			-- ATWD0 interface
			atwd0_wdata			=> open,
			atwd0_rdata			=> (OTHERS=>'0'),
			atwd0_address		=> open,
			atwd0_write_en		=> open,
			-- ATWD1 interface
			atwd1_wdata			=> open,
			atwd1_rdata			=> (OTHERS=>'0'),
			atwd1_address		=> open,
			atwd1_write_en		=> open,
			-- kale communication interface
			tx_fifo_wr			=> tx_fifo_wr,
			rx_fifo_rd			=> rx_fifo_rd,
			tx_pack_rdy			=> tx_pack_rdy,
			rx_dpr_radr_stb		=> rx_dpr_radr_stb,
			com_reset_rcvd		=> com_reset_rcvd,
			-- test connector
			TC				=> open --TC
		);
		

		
	B_nA	<= NOT A_nB;
	RST_kalle	<= RST OR com_ctrl(4);

-- Kalle DPM

	rx_addr (15 DOWNTO 0)	<= dp1_portaaddr;
	dcom_ap_inst : dcom_ap
		port MAP (
			tx_pack_rdy		=> tx_pack_rdy,
			rx_dpr_radr_stb	=> rx_dpr_radr_stb,
			A_nB			=> A_nB,
			reboot_req		=> drbt_req,
			id_avail		=> dom_id(48),
			HVD_Rx			=> HDV_Rx,
			CLK20			=> CLK20,
			RST				=> RST,
			COM_AD_D		=> COM_AD_D,
			id				=> dom_id(47 DOWNTO 0),
			rx_dpr_radr		=> rx_dpr_radr(15 DOWNTO 0),
			systime			=> systime,
			tc				=> open,
			tx_dataout		=> dp0_portadataout,
			tx_dpr_wadr		=> tx_dpr_wadr(15 DOWNTO 0),
			tx_pack_sent	=> tx_pack_sent,
			rx_dpr_aff		=> rx_dpr_aff,
			rx_pack_rcvd	=> rx_pack_rcvd,
			rx_we			=> dp1_portawe,
			HVD_RxENA		=> HDV_RxENA,
			reboot_gnt		=> drbt_gnt,
			com_avail		=> com_avail,
			COMM_RESET		=> COMM_nRESET,
			COM_TX_SLEEP	=> COM_TX_SLEEP,
			HVD_IN			=> HDV_IN,
			HVD_TxENA		=> HDV_TxENA,
			tx_alm_empty	=> tx_alm_empty,
			com_reset_rcvd	=> com_reset_rcvd,
			msg_rd			=> open,
			data_rcvd		=> open,
			COM_DB			=> COM_DB,
			rev				=> open,
			rx_addr			=> dp1_portaaddr,
			rx_datain		=> dp1_portadatain,
			rx_error		=> rx_error,
			tx_addr			=> dp0_portaaddr,
			tx_dpr_radr		=> tx_dpr_radr(15 DOWNTO 0),
			tx_error		=> tx_error
		);
	com_rx_data(15 DOWNTO 0)	<= rx_error;
	com_rx_data(31 DOWNTO 16)	<= tx_error;

	inst_cal_local_coincidence : cal_local_coincidence
	    PORT MAP (
	        -- Common Inputs
	        CLK20                => CLK20,
	        CLK40                => CLK40,
	        CLK80                => CLK80,
	        RST                  => RST,
	        systime              => systime,
	        -- DAQ interface
	        DO_CAL			     => DO_CAL,
	        CAL_TIME_UP			 => CAL_TIME_UP,
	        CAL_TIME_DOWN	     => CAL_TIME_DOWN,
			PING_DELAY			=> PING_DELAY,
	        -- I/O
	        COINCIDENCE_OUT_DOWN => COINCIDENCE_OUT_DOWN,
	        COINC_DOWN_ALATCH    => COINC_DOWN_ALATCH,
	        COINC_DOWN_ABAR      => COINC_DOWN_ABAR,
	        COINC_DOWN_A         => COINC_DOWN_A,
	        COINC_DOWN_BLATCH    => COINC_DOWN_BLATCH,
	        COINC_DOWN_BBAR      => COINC_DOWN_BBAR,
	        COINC_DOWN_B         => COINC_DOWN_B,
	        COINCIDENCE_OUT_UP   => COINCIDENCE_OUT_UP,
	        COINC_UP_ALATCH      => COINC_UP_ALATCH,
	        COINC_UP_ABAR        => COINC_UP_ABAR,
	        COINC_UP_A           => COINC_UP_A,
	        COINC_UP_BLATCH      => COINC_UP_BLATCH,
	        COINC_UP_BBAR        => COINC_UP_BBAR,
	        COINC_UP_B           => COINC_UP_B,
	        -- test
	        TC                   => open --TC
        );



	-- arthur debugg
--	dp0_portaaddr <= (OTHERS=>'0');
--	dp1_portaaddr <= (OTHERS=>'0');
--	dp0_portadatain <= X"05500AA0";
--	dp1_portadatain <= X"B00BF00D";
--	dp0_portawe			<= '1';
--	dp1_portawe			<= '1';

	-- house keeping because com_fifo is removed
	-- TC			<= (OTHERS=>'0');
	com_rx_fifo	<= (OTHERS=>'0');
	
	timer_inst : timer
		PORT MAP (
			CLK		=> CLK40,
			RST		=> RST,
			systime	=> systime
		);
		

	-- TC(0)	<= FE_pulse;
	
	-- PGM(15 downto 12) <= (others=>'0');
	PGM(15) <= '1';
	PGM(14) <= '0';
	PGM(13) <= '0';
	PGM(12) <= '1';
	PGM(11) <= 'Z';
	-- PGM(10 downto 8) <= (others=>'0');
	PGM(7 downto 0) <= TC;
	
	-- indicate FPGA is configured
	PDL_FPGA_D (5 DOWNTO 0)	<= "010101";
	PDL_FPGA_D (6) <= NOT COMM_nRESET;
	PDL_FPGA_D (7) <= '0';
	
	COMM_RESET	<= NOT COMM_nRESET;
	FPGA_LOADED	<= '0';
	
	
	process(CLK20)
		variable CNT	: STD_LOGIC_VECTOR(2 downto 0);
	begin
		IF CLK20'EVENT and CLK20='1' then
			CNT := CNT + 1;
	--		PGM(9 downto 8) <= CNT(1 downto 0);
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
