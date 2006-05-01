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
		FPGA_DA				: IN STD_LOGIC;
		FPGA_CE				: OUT STD_LOGIC;
		-- Test connector	THERE IS NO 11   I don't know why
		FPGA_D			: OUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- added for alternate LC pin test on 5.1 boards
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
	SIGNAL TC_1PPS	: STD_LOGIC_VECTOR (7 downto 0);
	
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
	
	-- com DAC test
	SIGNAL enable			: STD_LOGIC;
	SIGNAL enable_square	: STD_LOGIC;
	-- com ADC test
	SIGNAL com_adc_enable	: STD_LOGIC;
	SIGNAL com_adc_done		: STD_LOGIC;
	SIGNAL com_adc_wdata	: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL com_adc_rdata	: STD_LOGIC_VECTOR(15 downto 0) := (OTHERS=>'0');
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
	SIGNAL FE_pulse				: STD_LOGIC;
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
	SIGNAL enable_coinc_up_and_down	: STD_LOGIC;
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
	SIGNAL hit_counter_dead	: STD_LOGIC_VECTOR(3 DOWNTO 0);
	
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
	
	SIGNAL com_clev		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL com_clev_wr		: STD_LOGIC;
	SIGNAL com_thr_del		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL com_thr_del_wr	: STD_LOGIC;
			

	
	SIGNAL systime			: STD_LOGIC_VECTOR (47 DOWNTO 0);
	SIGNAL systime_1PPS		: STD_LOGIC_VECTOR (47 DOWNTO 0);
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
	
	COMPONENT ahb_master
	PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- connections to the stripe
			slavehclk		: IN	STD_LOGIC;
			slavehwrite		: OUT	STD_LOGIC;
			slavehreadyi	: OUT	STD_LOGIC;
			slavehselreg	: OUT	STD_LOGIC;
			slavehsel		: OUT	STD_LOGIC;
			slavehmastlock	: OUT	STD_LOGIC;
			slavehaddr		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			slavehtrans		: OUT	STD_LOGIC_VECTOR(1 downto 0);
			slavehsize		: OUT	STD_LOGIC_VECTOR(1 downto 0);
			slavehburst		: OUT	STD_LOGIC_VECTOR(2 downto 0);
			slavehwdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			slavehreadyo	: IN	STD_LOGIC;
			slavebuserrint	: IN	STD_LOGIC;
			slavehresp		: IN	STD_LOGIC_VECTOR(1 downto 0);
			slavehrdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
			-- local bus signals
			start_trans		: IN	STD_LOGIC;
			address			: IN	STD_LOGIC_VECTOR(31 downto 0);
			wdata			: IN	STD_LOGIC_VECTOR(31 downto 0);
			wait_sig		: OUT	STD_LOGIC;
			trans_length	: IN	INTEGER;
			bus_error		: OUT	STD_LOGIC
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
			com_clev		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			com_clev_wr		: OUT	STD_LOGIC;
			com_thr_del		: OUT	STD_LOGIC_VECTOR(31 downto 0);
			com_thr_del_wr	: OUT	STD_LOGIC;
			systime_1PPS	: IN	STD_LOGIC_VECTOR(47 DOWNTO 0);
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
	
--	COMPONENT rs486
--		PORT (
--			CLK			: IN STD_LOGIC;
--			RST			: IN STD_LOGIC;
--			-- control
--			enable		: IN STD_LOGIC;
--			-- manual control
--			rs486_ena	: IN STD_LOGIC_VECTOR(1 downto 0);
--			rs486_tx	: IN STD_LOGIC;
--			rs486_rx	: OUT STD_LOGIC;
--			-- Communications RS485
--			HDV_Rx		: IN STD_LOGIC;
--			HDV_RxENA	: OUT STD_LOGIC;
--			HDV_TxENA	: OUT STD_LOGIC;
--			HDV_IN		: OUT STD_LOGIC;
--			-- test connector
--			TC			: OUT STD_LOGIC_VECTOR(7 downto 0)
--		);
--	END COMPONENT;
	
--	COMPONENT com_ADC_RC
--		PORT (
--			CLK			: IN STD_LOGIC;
--			CLK2x		: IN STD_LOGIC;
--			RST			: IN STD_LOGIC;
--			-- stripe interface
--			wdata		: IN STD_LOGIC_VECTOR (15 downto 0);
--			rdata		: OUT STD_LOGIC_VECTOR (15 downto 0);
--			address		: IN STD_LOGIC_VECTOR (8 downto 0);
--			write_en	: IN STD_LOGIC;
--			-- enable for RX
--			enable		: IN STD_LOGIC;
--			done		: OUT STD_LOGIC;
--			-- communications ADC connections
--			COM_AD_CLK	: OUT STD_LOGIC;
--			COM_AD_D	: IN STD_LOGIC_VECTOR (9 downto 0);
--			COM_AD_OTR	: IN STD_LOGIC;
--			-- test connector
--			TC			: OUT	STD_LOGIC_VECTOR(7 downto 0)
--		);
--	END COMPONENT;
	
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
			enable_coinc_up_and_down	: IN STD_LOGIC := '0';
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
	
	COMPONENT hit_counter
		PORT (
			CLK			: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			-- setup
			gatetime	: IN STD_LOGIC := '0';
			deadtime	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
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
			deadtime	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			-- discriminator input
			MultiSPE		: IN STD_LOGIC;
			OneSPE			: IN STD_LOGIC;
			-- output
			multiSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
			oneSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
			-- frontend pulser
			FE_pulse		: IN STD_LOGIC;
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
			deadtime	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			-- disc
			OneSPE		: IN STD_LOGIC;
			LEDtrig		: IN STD_LOGIC;
			-- LC interface
			LC_abort	: IN STD_LOGIC := '0';
			LC_enable	: IN STD_LOGIC := '0';
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
			-- frontend pulser
			FE_pulse			: IN STD_LOGIC := '0';
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
			divider				: IN STD_LOGIC_VECTOR(3 downto 0);
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
	
--	COMPONENT dcom
--		port (
--			CCLK :  IN  STD_LOGIC;
--			rs4_out :  IN  STD_LOGIC;
--			msg_rd :  IN  STD_LOGIC;
--			dom_A_sel_L :  IN  STD_LOGIC;
--			dom_B_sel_L :  IN  STD_LOGIC;
--			reset :  IN  STD_LOGIC;
--			tx_wrreq :  IN  STD_LOGIC;
--			rx_rdreq :  IN  STD_LOGIC;
--			drbt_req :  IN  STD_LOGIC;
--			rs485_not_dac :  IN  STD_LOGIC;
--			id_stb_L :  IN  STD_LOGIC;
--			id_stb_H :  IN  STD_LOGIC;
--			fc_adc :  IN  STD_LOGIC_VECTOR(11 downto 0);
--			id :  IN  STD_LOGIC_VECTOR(47 downto 0);
--			systime :  IN  STD_LOGIC_VECTOR(47 downto 0);
--			tx_fd :  IN  STD_LOGIC_VECTOR(7 downto 0);
--			txd :  OUT  STD_LOGIC;
--			last_byte :  OUT  STD_LOGIC;
--			dac_clk :  OUT  STD_LOGIC;
--			dac_slp :  OUT  STD_LOGIC;
--			rs4_in :  OUT  STD_LOGIC;
--			rs4_den :  OUT  STD_LOGIC;
--			msg_sent :  OUT  STD_LOGIC;
--			txwraef :  OUT  STD_LOGIC;
--			txrdef :  OUT  STD_LOGIC;
--			txwraff :  OUT  STD_LOGIC;
--			ctrl_sent :  OUT  STD_LOGIC;
--			rs4_ren :  OUT  STD_LOGIC;
--			adc_clk :  OUT  STD_LOGIC;
--			data_stb :  OUT  STD_LOGIC;
--			ctrl_stb :  OUT  STD_LOGIC;
--			ctrl_err :  OUT  STD_LOGIC;
--			rxwraff :  OUT  STD_LOGIC;
--			rxrdef :  OUT  STD_LOGIC;
--			stf_rcvd :  OUT  STD_LOGIC;
--			eof_rcvd :  OUT  STD_LOGIC;
--			bfstat_rcvd :  OUT  STD_LOGIC;
--			drreq_rcvd :  OUT  STD_LOGIC;
--			sysres_rcvd :  OUT  STD_LOGIC;
--			comres_rcvd :  OUT  STD_LOGIC;
--			msg_rcvd :  OUT  STD_LOGIC;
--			msg_err :  OUT  STD_LOGIC;
--			fifo_msg :  OUT  STD_LOGIC;
--			hl_edge :  OUT  STD_LOGIC;
--			lh_edge :  OUT  STD_LOGIC;
--			rxd :  OUT  STD_LOGIC;
--			drbt_gnt :  OUT  STD_LOGIC;
--			com_aval :  OUT  STD_LOGIC;
--			sys_res       : OUT STD_LOGIC;
--			tcal_rcvd :  OUT  STD_LOGIC;
--			pulse_rcvd :  OUT  STD_LOGIC;
--			pulse_sent :  OUT  STD_LOGIC;
--			idreq_rcvd :  OUT  STD_LOGIC;
--			max_ena       : OUT STD_LOGIC;
--			min_ena       : OUT STD_LOGIC;
--			find_dudt     : OUT STD_LOGIC;
--			dac_db :  OUT  STD_LOGIC_VECTOR(7 downto 0);
--			data :  OUT  STD_LOGIC_VECTOR(7 downto 0);
--			msg_ct_q :  OUT  STD_LOGIC_VECTOR(7 downto 0);
--			rev :  OUT  STD_LOGIC_VECTOR(15 downto 0);
--			rx_fq :  OUT  STD_LOGIC_VECTOR(7 downto 0)
--		);
--	END COMPONENT;

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
			tx_error :  OUT  STD_LOGIC_VECTOR(15 downto 0);
			com_thr_d	: IN STD_LOGIC_VECTOR(7 downto 0);
			dac_max_d	: IN STD_LOGIC_VECTOR(6 downto 5);
			rec_del_d	: IN STD_LOGIC_VECTOR(7 downto 0);
			send_del_d	: IN STD_LOGIC_VECTOR(7 downto 0);
			clev_min_d	: IN STD_LOGIC_VECTOR(9 downto 0);
			clev_max_d	: IN STD_LOGIC_VECTOR(9 downto 0);
			thr_del_wr	: IN STD_LOGIC;
			clev_wr		: IN STD_LOGIC
		);
	END COMPONENT;

	
	COMPONENT timer
		PORT (
			CLK     : IN  STD_LOGIC;
			RST     : IN  STD_LOGIC;
			systime : OUT STD_LOGIC_VECTOR (47 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT LED2ATWDdelay
		PORT (
			CLK40		: IN STD_LOGIC;
			RST			: IN STD_LOGIC;
			delay		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			LEDin		: IN STD_LOGIC;
			TRIGout		: OUT STD_LOGIC;
			-- test connector
			TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT CommonClock
    PORT (
        CLK20        : IN  STD_LOGIC;
        RST          : IN  STD_LOGIC;
        systime      : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
        PPS          : IN  STD_LOGIC;
        systime_1PPS : OUT STD_LOGIC_VECTOR (47 DOWNTO 0);
        TC           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
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
	
	-- ATWD0
	atwd0_enable	<= command_0(0);
	--atwd0_enable_disc	<= command_0(1);
	atwd0_enable_LED	<= command_0(3);
	response_0(0)	<= atwd0_done;
	response_0(1)	<= LC_ATWD0;
	-- ATWD1
	atwd1_enable	<= command_0(8);
	--atwd1_enable_disc	<= command_0(9);
	atwd1_enable_LED	<= command_0(11);
	response_0(8)	<= atwd1_done;
	response_0(9)	<= LC_ATWD1;
	-- flash ADC test
	flash_adc_enable		<= command_0(16);
	flash_adc_enable_disc	<= command_0(17);
	response_0(16)	<= flash_adc_done;
	-- frontend pulser
	fe_pulser_enable	<= command_0(24);
	fe_divider			<= command_1(19 downto 16);
	-- single LED
	single_led_enable	<= command_0(26);
	-- R2R ladder
	enable_r2r		<= command_0(28);	
	enable_fe_r2r	<= command_0(30);
	
	
	-- com DAC test
--	enable <= command_1(0);
--	enable_square	<= command_1(1);
	-- com ADC test
--	com_adc_enable	<= command_1(4);
--	response_1(4)	<= com_adc_done;
	-- RS485
--	rs486_ena		<= command_1(10 downto 9);
--	rs486_tx		<= command_1(8);
--	response_1(8)	<= rs486_rx;
--	enable_rs485	<= command_1(11);
	
	-- local coincidence
	enable_coinc_up		<= command_2(0);
	enable_coinc_down	<= command_2(1);
	enable_coinc_newFF	<= command_2(2);
	enable_coinc_atwd	<= command_2(3);
	LC_rx_down_en		<= command_2(4);
	LC_rx_up_en			<= command_2(5);
	enable_coinc_up_and_down	<= command_2(6);
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
	response_0(15 downto 10)		<= (others=>'0');
	response_0(7 downto 2)		<= (others=>'0');
	
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
	hit_counter_dead			<= command_4(15 DOWNTO 12);
	hitcounter_o(15 downto 0)	<= oneSPEcnt;
	hitcounter_o(31 downto 16)	<= (others=>'0');
	hitcounter_m(15 downto 0)	<= multiSPEcnt;
	hitcounter_m(31 downto 16)	<= (others=>'0');
	hitcounter_o_ff(15 downto 0)	<= oneSPEcnt_ff;
	hitcounter_o_ff(31 downto 16)	<= (others=>'0');
	hitcounter_m_ff(15 downto 0)	<= multiSPEcnt_ff;
	hitcounter_m_ff(31 downto 16)	<= (others=>'0');
	
	-- fake kallo communication reset
	-- com_status(2)	<= com_ctrl(2);
	
	-- AHB master test
--	master_enable	<= command_2(8);
--	response_2(8)	<= master_done;
--	response_2(9)	<= master_berr;
--	master_addr_start	<= command_3(15 downto 0);
	master_enable	<= low; --command_2(8);
	-- response_2(8)	<= master_done;
	-- response_2(9)	<= master_berr;
	master_addr_start	<= (others=>'0'); --command_3(15 downto 0);
	

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
		
	inst_ahb_master : ahb_master
	PORT MAP (
			CLK			=> CLK20,
			RST			=> RST,
			-- connections to the stripe
			slavehclk		=> slavehclk,
			slavehwrite		=> slavehwrite,
			slavehreadyi	=> slavehreadyi,
			slavehselreg	=> slavehselreg,
			slavehsel		=> slavehsel,
			slavehmastlock	=> slavehmastlock,
			slavehaddr		=> slavehaddr,
			slavehtrans		=> slavehtrans,
			slavehsize		=> slavehsize,
			slavehburst		=> slavehburst,
			slavehwdata		=> slavehwdata,
			slavehreadyo	=> slavehreadyo,
			slavebuserrint	=> slavebuserrint,
			slavehresp		=> slavehresp,
			slavehrdata		=> slavehrdata,
			-- local bus signals
			start_trans		=> start_trans,
			address			=> address,
			wdata			=> wdata,
			wait_sig		=> wait_sig,
			trans_length	=> trans_length,
			bus_error		=> bus_error
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
			hitcounter_o	=> hitcounter_o,
			hitcounter_m	=> hitcounter_m,
			hitcounter_o_ff	=> hitcounter_o_ff,
			hitcounter_m_ff	=> hitcounter_m_ff,
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
			com_clev		=> com_clev,
			com_clev_wr		=> com_clev_wr,
			com_thr_del		=> com_thr_del,
			com_thr_del_wr	=> com_thr_del_wr,
			systime_1PPS	=> systime_1PPS,
			-- COM ADC RX interface
			com_adc_wdata		=> com_adc_wdata,
			com_adc_rdata		=> com_adc_rdata,
			com_adc_address		=> com_adc_address,
			com_adc_write_en	=> com_adc_write_en,
			-- FLASH ADC RX interface
			flash_adc_wdata		=> flash_adc_wdata,
			flash_adc_rdata		=> flash_adc_rdata,
			flash_adc_address	=> flash_adc_address,
			flash_adc_write_en	=> flash_adc_write_en,
			-- ATWD0 interface
			atwd0_wdata			=> atwd0_wdata,
			atwd0_rdata			=> atwd0_rdata,
			atwd0_address		=> atwd0_address,
			atwd0_write_en		=> atwd0_write_en,
			-- ATWD1 interface
			atwd1_wdata			=> atwd1_wdata,
			atwd1_rdata			=> atwd1_rdata,
			atwd1_address		=> atwd1_address,
			atwd1_write_en		=> atwd1_write_en,
			-- kale communication interface
			tx_fifo_wr			=> tx_fifo_wr,
			rx_fifo_rd			=> rx_fifo_rd,
			tx_pack_rdy			=> tx_pack_rdy,
			rx_dpr_radr_stb		=> rx_dpr_radr_stb,
			com_reset_rcvd		=> com_reset_rcvd,
			-- test connector
			TC				=> open --TC
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
	
--	inst_rs486 : rs486
--		PORT MAP (
--			CLK			=> CLK20,
--			RST			=> RST,
--			-- control
--			enable		=> enable_rs485,
--			-- manual control
--			rs486_ena	=> rs486_ena,
--			rs486_tx	=> rs486_tx,
--			rs486_rx	=> rs486_rx,
--			-- Communications RS485
--			HDV_Rx		=> HDV_Rx,
--			HDV_RxENA	=> HDV_RxENA,
--			HDV_TxENA	=> HDV_TxENA,
--			HDV_IN		=> HDV_IN,
--			-- test connector
--			TC			=> open
--		);
		
--	inst_com_ADC_RC : com_ADC_RC
--		PORT MAP(
--			CLK			=> CLK20,
--			CLK2x		=> CLK40,
--			RST			=> RST,
--			-- stripe interface
--			wdata		=> com_adc_wdata,
--			rdata		=> com_adc_rdata,
--			address		=> com_adc_address,
--			write_en	=> com_adc_write_en,
--			-- enable for RX
--			enable		=> com_adc_enable,
--			done		=> com_adc_done,
--			-- communications ADC connections
--			COM_AD_CLK	=> open, --COM_AD_CLK,
--			COM_AD_D	=> COM_AD_D,
--			COM_AD_OTR	=> COM_AD_OTR,
--			-- test connector
--			TC			=> open
--		);
		
	inst_flash_ADC : flash_ADC
		PORT MAP (
			CLK			=> CLK40,
			CLK2x		=> CLK80,
			RST			=> RST,
			-- stripe interface
			wdata		=> flash_adc_wdata,
			rdata		=> flash_adc_rdata,
			address		=> flash_adc_address,
			write_en	=> flash_adc_write_en,
			-- enable for RX
			enable		=> flash_adc_enable_lc,
			enable_disc	=> flash_adc_enable_disc,
			done		=> flash_adc_done,
			-- disc
			OneSPE		=> OneSPE,
			-- communications ADC connections
			FLASH_AD_D		=> FLASH_AD_D,
			FLASH_AD_CLK	=> open, --FLASH_AD_CLK,
			FLASH_AD_STBY	=> FLASH_AD_STBY,
			FLASH_NCO		=> FLASH_NCO,
			-- test connector
			TC				=> open
		);
		
	inst_fe_testpulse : fe_testpulse
		PORT MAP (
			CLK			=> CLK20,
			RST			=> RST,
			-- enable flasher
			enable		=> fe_pulser_enable,
			divider		=> fe_divider,
			-- LED trigger
			FE_TEST_PULSE	=> FE_pulse
		);
	FE_TEST_PULSE <= FE_pulse;	
	
	
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
	
	COINCIDENCE_OUT_DOWN <= 'Z';
	COINCIDENCE_OUT_UP <= 'Z';	
	inst_coinc : coinc
		PORT MAP (
			CLK					=> CLK20,
			RST					=> RST,
			-- enable
			enable_coinc_down	=> enable_coinc_down,
			enable_coinc_up		=> enable_coinc_up,
			enable_coinc_up_and_down	=> enable_coinc_up_and_down,
			newFF				=> enable_coinc_newFF,	-- '1';
			enable_coinc_atwd	=> enable_coinc_atwd,
			-- simple LC
			OneSPE				=> OneSPE,
			LC_rx_down_en		=> LC_rx_down_en,
			LC_rx_up_en			=> LC_rx_up_en,
			LC_up_pre_window	=> command_5(5 DOWNTO 0),
			LC_up_post_window	=> command_5(13 DOWNTO 8),
			LC_down_pre_window	=> command_5(21 DOWNTO 16),
			LC_down_post_window	=> command_5(29 DOWNTO 24),
			LC_atwd_a			=> LC_ATWD0,
			LC_atwd_b			=> LC_ATWD1,
			atwd0_LC_abort		=> atwd0_LC_abort,
			atwd1_LC_abort		=> atwd1_LC_abort,
			atwd_a_enable_disc	=> atwd0_enable_disc,
			atwd_b_enable_disc	=> atwd1_enable_disc,
			atwd0_trigger		=> atwd0_trigger,
			atwd1_trigger		=> atwd1_trigger,
			-- manual control
			coinc_up_high		=> coinc_up_high,
			coinc_up_low		=> coinc_up_low,
			coinc_down_high		=> coinc_down_high,
			coinc_down_low		=> coinc_down_low,
			coinc_latch			=> coinc_latch,
			coinc_disc			=> coinc_disc,
			-- local coincidence
			COINCIDENCE_OUT_DOWN	=> FPGA_D(0), --COINCIDENCE_OUT_DOWN,
			COINC_DOWN_ALATCH	=> COINC_DOWN_ALATCH,
			COINC_DOWN_ABAR		=> COINC_DOWN_ABAR,
			COINC_DOWN_A		=> COINC_DOWN_A,
			COINC_DOWN_BLATCH	=> COINC_DOWN_BLATCH,
			COINC_DOWN_BBAR		=> COINC_DOWN_BBAR,
			COINC_DOWN_B		=> COINC_DOWN_B,
			COINCIDENCE_OUT_UP	=> FPGA_D(1), --COINCIDENCE_OUT_UP,
			COINC_UP_ALATCH		=> COINC_UP_ALATCH,
			COINC_UP_ABAR		=> COINC_UP_ABAR,
			COINC_UP_A			=> COINC_UP_A,
			COINC_UP_BLATCH		=> COINC_UP_BLATCH,
			COINC_UP_BBAR		=> COINC_UP_BBAR,
			COINC_UP_B			=> COINC_UP_B,
			-- test connector
			TC					=> TC
		);
	-- for simple local coincidence FADC launch
	--flash_adc_enable_disc_lc	<= flash_adc_enable_disc WHEN enable_coinc_atwd='0' ELSE flash_adc_enable_disc AND NOT (atwd0_LC_abort OR atwd1_LC_abort);
	flash_adc_enable_lc	<= flash_adc_enable WHEN enable_coinc_atwd='0' ELSE (((atwd0_trigger AND NOT atwd0_trigger_delay) OR atwd0_trigger_latch) OR ((atwd1_trigger AND NOT atwd1_trigger_delay) OR atwd1_trigger_latch)) AND flash_adc_enable;
	PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			-- ATWD 0
			atwd0_trigger_delay	<= atwd0_trigger;
			IF atwd0_trigger='1' AND atwd0_trigger_delay='0' THEN
				atwd0_trigger_latch <= '1';
			END IF;
			IF atwd0_LC_abort='1' OR flash_adc_enable='0' THEN
				atwd0_trigger_latch	<= '0';
			END IF;
			-- ATWD 1
			atwd1_trigger_delay	<= atwd1_trigger;
			IF atwd1_trigger='1' AND atwd1_trigger_delay='0' THEN
				atwd1_trigger_latch <= '1';
			END IF;
			IF atwd1_LC_abort='1' OR flash_adc_enable='0' THEN
				atwd1_trigger_latch	<= '0';
			END IF;
		END IF;
	END PROCESS;
		
	inst_hit_counter : hit_counter
		PORT MAP (
			CLK				=> CLK20,
			RST				=> RST,
			-- setup
			gatetime		=> hit_counter_gate,
			deadtime		=> hit_counter_dead,
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
			deadtime		=> hit_counter_dead,
			-- discriminator input
			MultiSPE		=> MultiSPE,
			OneSPE			=> OneSPE,
			-- output
			multiSPEcnt		=> multiSPEcnt_ff,
			oneSPEcnt		=> oneSPEcnt_ff,
			-- frontend pulser
			FE_pulse		=> FE_pulse,
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
			deadtime	=> hit_counter_dead,
			-- disc
			OneSPE		=> OneSPE,
			LEDtrig		=> LEDtrig,
			-- LC interface
			LC_abort	=> atwd0_LC_abort AND enable_coinc_atwd,
			LC_enable	=> enable_coinc_atwd,
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
			-- frontend pulser
			FE_pulse		=> FE_pulse,
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
			deadtime	=> hit_counter_dead,
			-- disc
			OneSPE		=> OneSPE,
			LEDtrig		=> LEDtrig,
			-- LC interface
			LC_abort	=> atwd1_LC_abort AND enable_coinc_atwd,
			LC_enable	=> enable_coinc_atwd,
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
			-- frontend pulser
			FE_pulse		=> FE_pulse,
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
			divider				=> fe_divider,
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
		
	B_nA	<= NOT A_nB;
	RST_kalle	<= RST OR com_ctrl(4);
	-- TC(0)	<= tx_fifo_wr;
	-- TC(0)	<= sys_reset;
	-- TC(1)	<= fifo_msg;
	-- TC(1)	<= com_aval;
	-- TC(2)	<= drbt_gnt;
	-- TC(3)	<= drbt_req;
	-- TC(3)	<= drbt_gnt;
--	dcom_inst : dcom
--		port MAP (
--			CCLK		=> CLK20,
--			rs4_out		=> HDV_Rx,
--			msg_rd		=> msg_rd,
--			dom_A_sel_L	=> B_nA,
--			dom_B_sel_L	=> A_nB,
--			reset		=> RST_kalle,
--			tx_wrreq	=> tx_fifo_wr,
--			rx_rdreq	=> rx_fifo_rd,
--			drbt_req 	=> drbt_req,
--			rs485_not_dac 	=> rs485_not_dac,
--			id_stb_L	=> high,
--			id_stb_H	=> dom_id(48),
--			fc_adc(11 DOWNTO 2)	=> COM_AD_D,
--			fc_adc(1 DOWNTO 0)	=> "00",
--			id			=> dom_id(47 downto 0),
--			systime		=> systime,
--			tx_fd		=> com_tx_fifo,
--			txd			=> open, --TC(6),
--			last_byte	=> open,
--			dac_clk		=> open,
--			dac_slp		=> COM_TX_SLEEP,
--			rs4_in		=> HDV_IN,
--			rs4_den		=> HDV_TxENA,
--			msg_sent	=> open,
--			txwraef		=> txwraef,
--			txrdef		=> txrdef,
--			txwraff		=> txwraff,
--			ctrl_sent	=> open, --TC(5),
--			rs4_ren		=> HDV_RxENA,
--			adc_clk		=> open,
--			data_stb	=> open, --TC(3),
--			ctrl_stb	=> open, --TC(4),
--			ctrl_err	=> ctrl_err,
--			rxwraff		=> rxwraff,
--			rxrdef		=> rxrdef,
--			stf_rcvd	=> open, --TC(1),
--			eof_rcvd	=> open, --TC(2),
--			bfstat_rcvd	=> open,
--			drreq_rcvd	=> open,
--			sysres_rcvd	=> open, --TC(1),
--			comres_rcvd	=> open, --TC(0),
--			msg_rcvd	=> open,
--			msg_err		=> open,
--			fifo_msg	=> fifo_msg,
--			hl_edge 	=> open, --TC(2),
--			lh_edge 	=> open,
--			rxd 		=> open,
--			drbt_gnt	=> drbt_gnt,
--			com_aval	=> com_aval,
--			sys_res     => sys_reset,
--			tcal_rcvd	=> open, --TC(0),
--			pulse_rcvd	=> open, --TC(1),
--			pulse_sent	=> open, --TC(2),
--			idreq_rcvd	=> open,
--			max_ena		=> open, --TC(3),
--			min_ena		=> open,
--			find_dudt	=> open,
--			dac_db		=> COM_DB,
--			data		=> temp_data,
--			msg_ct_q	=> msg_ct_q,
--			rev			=> open,
--			rx_fq		=> com_rx_fifo
--		);

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
			tx_error		=> tx_error,
			com_thr_d	=> com_thr_del (7 DOWNTO 0),
			dac_max_d	=> com_thr_del (9 DOWNTO 8),
			rec_del_d	=> com_thr_del (23 DOWNTO 16),
			send_del_d	=> com_thr_del (31 DOWNTO 24),
			clev_min_d	=> com_clev (9 DOWNTO 0),
			clev_max_d	=> com_clev (25 DOWNTO 16),
			thr_del_wr	=> com_thr_del_wr,
			clev_wr		=> com_clev_wr
		);
	com_rx_data(15 DOWNTO 0)	<= rx_error;
	com_rx_data(31 DOWNTO 16)	<= tx_error;
	
	CommonClock_inst : CommonClock
    PORT MAP (
        CLK20        => CLK20,
        RST          => RST,
        systime      => systime,
        PPS          => FPGA_DA,
        systime_1PPS => systime_1PPS,
        TC           => TC_1PPS
        );
	FPGA_CE <= TC_1PPS(0);

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
