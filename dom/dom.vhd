-------------------------------------------------
-- DOM top level VHDL file
-------------------------------------------------

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
		COM_TX_SLEEP	: OUT STD_LOGIC;
		COM_DB			: OUT STD_LOGIC_VECTOR (13 downto 6);
		-- Communications ADC
		COM_AD_D		: IN STD_LOGIC_VECTOR (9 downto 0);
		COM_AD_OTR		: IN STD_LOGIC;
		-- Communications RS485
		HDV_Rx			: IN STD_LOGIC;
		HDV_RxENA		: OUT STD_LOGIC;
		HDV_TxENA		: OUT STD_LOGIC;
		HDV_IN			: OUT STD_LOGIC;
		-- FLASH ADC
		FLASH_AD_D		: IN STD_LOGIC_VECTOR (9 downto 0);
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
	SIGNAL dp0_portaaddr	: STD_LOGIC_VECTOR(12 downto 0);
	SIGNAL dp0_portadatain	: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL dp0_portadataout	: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL dp2_portawe		: STD_LOGIC;
	SIGNAL dp2_portaaddr	: STD_LOGIC_VECTOR(12 downto 0);
	SIGNAL dp2_portadatain	: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL dp2_portadataout	: STD_LOGIC_VECTOR(7 downto 0);
	
	-- interrupts
	SIGNAL intpld	: STD_LOGIC_VECTOR(5 downto 0);
	-- GP stripe IO
	SIGNAL gpi		: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL gpo		: STD_LOGIC_VECTOR(3 downto 0);
	
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
	
	-- ATWD0
	SIGNAL atwd0_enable		: STD_LOGIC;
	SIGNAL atwd0_enable_disc	: STD_LOGIC;
	SIGNAL atwd0_done		: STD_LOGIC;
	SIGNAL atwd0_wdata		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL atwd0_rdata		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL atwd0_address	: STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL atwd0_write_en	: STD_LOGIC;
	
	-- ATWD1
	SIGNAL atwd1_enable		: STD_LOGIC;
	SIGNAL atwd1_enable_disc	: STD_LOGIC;
	SIGNAL atwd1_done		: STD_LOGIC;
	SIGNAL atwd1_wdata		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL atwd1_rdata		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL atwd1_address	: STD_LOGIC_VECTOR(8 downto 0);
	SIGNAL atwd1_write_en	: STD_LOGIC;
	
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
	
END simpletest_arch;