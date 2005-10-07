-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : coinc.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-07-17
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module provides a sileple test for the local coincidence
--              circuit. 
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten
-- 2004-09-29              thorsten  added simplified real LC
-- 2004-10-22              thorsten  added LC_abort
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY coinc IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- enable
		enable_coinc_down	: IN STD_LOGIC;
		enable_coinc_up		: IN STD_LOGIC;
		newFF				: IN STD_LOGIC := '0';
		enable_coinc_atwd	: IN STD_LOGIC := '0';
		-- simple LC
		OneSPE				: IN STD_LOGIC;
		LC_rx_down_en		: IN STD_LOGIC := '1';
		LC_rx_up_en			: IN STD_LOGIC := '1';
		LC_up_pre_window	: IN STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
		LC_up_post_window	: IN STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
		LC_down_pre_window	: IN STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
		LC_down_post_window	: IN STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
		LC_atwd_a			: buffer STD_LOGIC;
		LC_atwd_b			: buffer STD_LOGIC;
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
END coinc;



ARCHITECTURE arch_coinc OF coinc IS

	TYPE STATE_TYPE IS (idle, pos, neg);
	SIGNAL state	: STATE_TYPE;
	
	SIGNAL coinc_up_high_delay	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL coinc_up_low_delay	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL coinc_down_high_delay	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL coinc_down_low_delay	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	-- FPGA FF for comparators
	SIGNAL FF_down_a	: STD_LOGIC;
	SIGNAL FF_down_abar	: STD_LOGIC;
	SIGNAL FF_down_b	: STD_LOGIC;
	SIGNAL FF_down_bbar	: STD_LOGIC;
	SIGNAL FF_up_a	: STD_LOGIC;
	SIGNAL FF_up_abar	: STD_LOGIC;
	SIGNAL FF_up_b	: STD_LOGIC;
	SIGNAL FF_up_bbar	: STD_LOGIC;
	
	-- simplified real LC
	SIGNAL ATWD_A_launch	: STD_LOGIC;
	SIGNAL ATWD_B_launch	: STD_LOGIC;
	SIGNAL atwd0_trigger_old	: STD_LOGIC;
	SIGNAL atwd1_trigger_old	: STD_LOGIC;
	SIGNAL disc				: STD_LOGIC;
	TYPE ATWD_COINC_TYPE IS (IDLE, POS, NEG);
	SIGNAL atwd_coinc	: ATWD_COINC_TYPE;
	SIGNAL LC_down_a	: STD_LOGIC;
	SIGNAL LC_down_b	: STD_LOGIC;
	SIGNAL LC_up_a		: STD_LOGIC;
	SIGNAL LC_up_b		: STD_LOGIC;
	SIGNAL LC_down_a_rst	: STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL LC_down_b_rst	: STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL LC_up_a_rst		: STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL LC_up_b_rst		: STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL LC_RX_up			: STD_LOGIC;
	SIGNAL LC_RX_up_old		: STD_LOGIC;
	SIGNAL LC_RX_down		: STD_LOGIC;
	SIGNAL LC_RX_down_old	: STD_LOGIC;
	SIGNAL OneSPElatch		: STD_LOGIC;
	SIGNAL OneSPErst		: STD_LOGIC_VECTOR (2 DOWNTO 0);

	
BEGIN
	
	COINC_DOWN_ALATCH	<= '0' WHEN coinc_latch(0)='0' ELSE 'Z';
	COINC_DOWN_BLATCH	<= '0' WHEN coinc_latch(1)='0' ELSE 'Z';
	COINC_UP_ALATCH		<= '0' WHEN coinc_latch(2)='0' ELSE 'Z';
	COINC_UP_BLATCH		<= '0' WHEN coinc_latch(3)='0' ELSE 'Z';
	
	coinc_disc(0)	<= COINC_DOWN_A WHEN newFF='0' ELSE FF_down_a;
	coinc_disc(1)	<= COINC_DOWN_ABAR WHEN newFF='0' ELSE FF_down_abar;
	coinc_disc(2)	<= COINC_DOWN_B WHEN newFF='0' ELSE FF_down_b;
	coinc_disc(3)	<= COINC_DOWN_BBAR WHEN newFF='0' ELSE FF_down_bbar;
	coinc_disc(4)	<= COINC_UP_A WHEN newFF='0' ELSE FF_up_a;
	coinc_disc(5)	<= COINC_UP_ABAR WHEN newFF='0' ELSE FF_up_abar;
	coinc_disc(6)	<= COINC_UP_B WHEN newFF='0' ELSE FF_up_b;
	coinc_disc(7)	<= COINC_UP_BBAR WHEN newFF='0' ELSE FF_up_bbar;
	
	--TC(0)	<= COINC_DOWN_ABAR;
	--TC(1)	<= COINC_DOWN_A;
	--TC(2)	<= COINC_DOWN_BBAR;
	--TC(3)	<= COINC_DOWN_B;
	--TC(4)	<= COINC_UP_A;
	--TC(5)	<= COINC_UP_ABAR;
	--TC(6)	<= COINC_UP_BBAR;
	--TC(7)	<= COINC_UP_B;
	
	
	PROCESS(CLK,RST)
		VARIABLE cnt		: integer;
		VARIABLE wait_cnt	: integer;
		VARIABLE last_down_pol	: STD_LOGIC;
		VARIABLE last_up_pol	: STD_LOGIC;
		VARIABLE last_down		: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			COINCIDENCE_OUT_DOWN	<= 'Z';
			COINCIDENCE_OUT_UP		<= 'Z';
			state					<= idle;
			last_down_pol			:= '0';
			last_up_pol				:= '0';
			last_down				:= '0';
			cnt						:= 0;
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF enable_coinc_atwd='1' THEN -- simplified real LC
				CASE atwd_coinc IS
					WHEN IDLE =>
						COINCIDENCE_OUT_DOWN	<= 'Z';
						COINCIDENCE_OUT_UP		<= 'Z';
						IF disc='1' THEN
							atwd_coinc	<= POS;
						END IF;
					WHEN POS =>
						COINCIDENCE_OUT_DOWN	<= '1';
						COINCIDENCE_OUT_UP		<= '1';
						atwd_coinc	<= NEG;
					WHEN NEG =>
						COINCIDENCE_OUT_DOWN	<= '0';
						COINCIDENCE_OUT_UP		<= '0';
						atwd_coinc	<= IDLE;
					WHEN OTHERS =>
						atwd_coinc <= IDLE;
				END CASE;
			ELSIF enable_coinc_down='1' OR enable_coinc_up='1' THEN
				IF enable_coinc_down='0' THEN
					last_down := '1';
				ELSIF enable_coinc_up='0' THEN
					last_down := '0';
				END IF;
				
				CASE state IS
					WHEN idle =>
						COINCIDENCE_OUT_DOWN	<= 'Z';
						COINCIDENCE_OUT_UP		<= 'Z';
						IF cnt=2000 THEN -- 10kHz
							state <= pos;
							wait_cnt := 0;
						ELSE
							cnt := cnt+1;
						END IF;
					WHEN pos =>
						IF last_down='1' THEN	-- going up now
							COINCIDENCE_OUT_DOWN	<= 'Z';
							COINCIDENCE_OUT_UP		<= NOT last_up_pol;
						ELSE
							COINCIDENCE_OUT_DOWN	<= NOT last_down_pol;
							COINCIDENCE_OUT_UP		<= 'Z';
						END IF;
						IF wait_cnt=4 THEN
							state <= neg;
							wait_cnt := 0;
						ELSE
							wait_cnt := wait_cnt + 1;
						END IF;
					WHEN neg =>
						IF last_down='1' THEN	-- going up now
							COINCIDENCE_OUT_DOWN	<= 'Z';
							COINCIDENCE_OUT_UP		<= last_up_pol;
							IF wait_cnt=4 THEN
								state	<= idle;
								-- last_down	:=	'0';
								cnt		:= 0;
								last_up_pol := NOT last_up_pol;
								last_down	:= NOT last_down;
							ELSE
								wait_cnt := wait_cnt + 1;
							END IF;
						ELSE
							COINCIDENCE_OUT_DOWN	<= last_down_pol;
							COINCIDENCE_OUT_UP		<= 'Z';
							IF wait_cnt=4 THEN
								state	<= idle;
								-- last_down	:=	'0';
								cnt		:= 0;
								last_down_pol	:= NOT last_down_pol;
								last_down		:= NOT last_down;
							ELSE
								wait_cnt := wait_cnt + 1;
							END IF;
						END IF;
				END CASE;		
			ELSE	-- manual control
				IF coinc_up_high='1' AND coinc_up_high_delay(0)='0' THEN  --(2)
					COINCIDENCE_OUT_UP	<= '1';
				ELSIF coinc_up_low='1' AND coinc_up_low_delay(0)='0' THEN  --(2)
					COINCIDENCE_OUT_UP	<= '0';
				ELSE
					COINCIDENCE_OUT_UP	<= 'Z';
				END IF;
				IF coinc_down_high='1' AND coinc_down_high_delay(0)='0' THEN  --(2)
					COINCIDENCE_OUT_DOWN	<= '1';
				ELSIF coinc_down_low='1' AND coinc_down_low_delay(0)='0' THEN  --(2)
					COINCIDENCE_OUT_DOWN	<= '0';
				ELSE
					COINCIDENCE_OUT_DOWN	<= 'Z';
				END IF;
			END IF;
			coinc_up_high_delay(7 DOWNTO 1) <= coinc_up_high_delay(6 DOWNTO 0);
			coinc_up_high_delay(0) <= coinc_up_high;
			coinc_up_low_delay(7 DOWNTO 1) <= coinc_up_low_delay(6 DOWNTO 0);
			coinc_up_low_delay(0) <= coinc_up_low;
			coinc_down_high_delay(7 DOWNTO 1) <= coinc_down_high_delay(6 DOWNTO 0);
			coinc_down_high_delay(0) <= coinc_down_high;
			coinc_down_low_delay(7 DOWNTO 1) <= coinc_down_low_delay(6 DOWNTO 0);
			coinc_down_low_delay(0) <= coinc_down_low;
		END IF;
	END PROCESS;
	
	
	-- FPGA FFs for the comparator inputs
	DOWN_A : PROCESS (COINC_DOWN_A, coinc_latch(0))
	BEGIN
		IF coinc_latch(0)='0' THEN
			FF_down_a	<= '0';
		ELSIF COINC_DOWN_A'EVENT AND COINC_DOWN_A='1' THEN
			FF_down_a	<= '1';
		END IF;
	END PROCESS;
	DOWN_ABAR : PROCESS (COINC_DOWN_ABAR, coinc_latch(0))
	BEGIN
		IF coinc_latch(0)='0' THEN
			FF_down_abar	<= '1';
		ELSIF COINC_DOWN_ABAR'EVENT AND COINC_DOWN_ABAR='0' THEN
			FF_down_abar	<= '0';
		END IF;
	END PROCESS;
	DOWN_B: PROCESS (COINC_DOWN_B, coinc_latch(1))
	BEGIN
		IF coinc_latch(1)='0' THEN
			FF_down_b	<= '0';
		ELSIF COINC_DOWN_B'EVENT AND COINC_DOWN_B='1' THEN
			FF_down_b	<= '1';
		END IF;
	END PROCESS;
	DOWN_BBAR : PROCESS (COINC_DOWN_BBAR, coinc_latch(1))
	BEGIN
		IF coinc_latch(1)='0' THEN
			FF_down_bbar	<= '1';
		ELSIF COINC_DOWN_BBAR'EVENT AND COINC_DOWN_BBAR='0' THEN
			FF_down_bbar	<= '0';
		END IF;
	END PROCESS;
	
	UP_A : PROCESS (COINC_UP_A, coinc_latch(0))
	BEGIN
		IF coinc_latch(0)='0' THEN
			FF_up_a	<= '0';
		ELSIF COINC_UP_A'EVENT AND COINC_UP_A='1' THEN
			FF_up_a	<= '1';
		END IF;
	END PROCESS;
	UP_ABAR : PROCESS (COINC_UP_ABAR, coinc_latch(0))
	BEGIN
		IF coinc_latch(0)='0' THEN
			FF_up_abar	<= '1';
		ELSIF COINC_UP_ABAR'EVENT AND COINC_UP_ABAR='0' THEN
			FF_up_abar	<= '0';
		END IF;
	END PROCESS;
	UP_B: PROCESS (COINC_UP_B, coinc_latch(1))
	BEGIN
		IF coinc_latch(1)='0' THEN
			FF_up_b	<= '0';
		ELSIF COINC_UP_B'EVENT AND COINC_UP_B='1' THEN
			FF_up_b	<= '1';
		END IF;
	END PROCESS;
	UP_BBAR : PROCESS (COINC_UP_BBAR, coinc_latch(1))
	BEGIN
		IF coinc_latch(1)='0' THEN
			FF_up_bbar	<= '1';
		ELSIF COINC_UP_BBAR'EVENT AND COINC_UP_BBAR='0' THEN
			FF_up_bbar	<= '0';
		END IF;
	END PROCESS;
	
	
	--------------------------
	-- simplified real LC
	--------------------------
	-- discriminator FF
	
	-- RX FFs
	LCDOWN_A : PROCESS (COINC_DOWN_A, LC_down_a_rst(0))
	BEGIN
		IF LC_down_a_rst(0)='1' THEN
			LC_down_a	<= '0';
		ELSIF COINC_DOWN_A'EVENT AND COINC_DOWN_A='1' THEN
			LC_down_a	<= '1';
		END IF;
	END PROCESS;
	LCDOWN_B: PROCESS (COINC_DOWN_B, LC_down_b_rst(0))
	BEGIN
		IF LC_down_b_rst(0)='1' THEN
			LC_down_b	<= '0';
		ELSIF COINC_DOWN_B'EVENT AND COINC_DOWN_B='1' THEN
			LC_down_b	<= '1';
		END IF;
	END PROCESS;
	
	LCUP_A : PROCESS (COINC_UP_A, LC_up_a_rst(0))
	BEGIN
		IF LC_up_a_rst(0)='1' THEN
			LC_up_a	<= '0';
		ELSIF COINC_UP_A'EVENT AND COINC_UP_A='1' THEN
			LC_up_a	<= '1';
		END IF;
	END PROCESS;
	LCUP_B: PROCESS (COINC_UP_B, LC_up_b_rst(0))
	BEGIN
		IF LC_up_b_rst(0)='1' THEN
			LC_up_b	<= '0';
		ELSIF COINC_UP_B'EVENT AND COINC_UP_B='1' THEN
			LC_up_b	<= '1';
		END IF;
	END PROCESS;
	
	PROCESS (CLK,RST)
	BEGIN
		IF RST='1' THEN
			LC_RX_up_old	<= '0';
			LC_RX_down_old	<= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			-- SRG
			LC_down_a_rst(2)			<= LC_down_a;
			LC_down_a_rst(1 DOWNTO 0)	<= LC_down_a_rst(2 DOWNTO 1);
			IF LC_down_a_rst(0)='1' THEN
				LC_down_a_rst <= "000";
			END IF;
			LC_down_b_rst(2)			<= LC_down_b;
			LC_down_b_rst(1 DOWNTO 0)	<= LC_down_b_rst(2 DOWNTO 1);
			IF LC_down_b_rst(0)='1' THEN
				LC_down_b_rst <= "000";
			END IF;
			
			LC_up_a_rst(2)			<= LC_up_a;
			LC_up_a_rst(1 DOWNTO 0)	<= LC_up_a_rst(2 DOWNTO 1);
			IF LC_up_a_rst(0)='1' THEN
				LC_up_a_rst <= "000";
			END IF;
			LC_up_b_rst(2)			<= LC_up_b;
			LC_up_b_rst(1 DOWNTO 0)	<= LC_up_b_rst(2 DOWNTO 1);
			IF LC_up_b_rst(0)='1' THEN
				LC_up_b_rst <= "000";
			END IF;
			
			LC_RX_up_old	<= LC_RX_up;
			LC_RX_down_old	<= LC_RX_down;
		END IF;
	END PROCESS;
	
	LC_RX_up <= '1' WHEN (LC_up_a='1' AND LC_up_b='1') AND LC_RX_up_old ='0' ELSE '0';
	LC_RX_down <= '1' WHEN (LC_down_a='1' AND LC_down_b='1') AND LC_RX_down_old ='0' ELSE '0';
	

	-- LC test
	LCATWD : PROCESS(CLK,RST)
		VARIABLE ATWD_A_up_pre_cnt		: INTEGER RANGE 0 TO 63;
		VARIABLE ATWD_A_up_post_cnt		: INTEGER RANGE 0 TO 63;
		VARIABLE ATWD_A_down_pre_cnt	: INTEGER RANGE 0 TO 63;
		VARIABLE ATWD_A_down_post_cnt	: INTEGER RANGE 0 TO 63;
		VARIABLE ATWD_B_up_pre_cnt		: INTEGER RANGE 0 TO 63;
		VARIABLE ATWD_B_up_post_cnt		: INTEGER RANGE 0 TO 63;
		VARIABLE ATWD_B_down_pre_cnt	: INTEGER RANGE 0 TO 63;
		VARIABLE ATWD_B_down_post_cnt	: INTEGER RANGE 0 TO 63;
		CONSTANT MAX_WINDOW_CNT			: INTEGER := 63;
		VARIABLE atwd_a_enable_disc_old	: STD_LOGIC;
		VARIABLE atwd_b_enable_disc_old	: STD_LOGIC;
		
		VARIABLE edgeA		: STD_LOGIC;
		VARIABLE edgeAold	: STD_LOGIC;
		VARIABLE edgeB		: STD_LOGIC;
		VARIABLE edgeBold	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			ATWD_A_up_pre_cnt		:= 63;
			ATWD_A_up_post_cnt		:= 63;
			ATWD_A_down_pre_cnt		:= 63;
			ATWD_A_down_post_cnt	:= 63;
			ATWD_B_up_pre_cnt		:= 63;
			ATWD_B_up_post_cnt		:= 63;
			ATWD_B_down_pre_cnt		:= 63;
			ATWD_B_down_post_cnt	:= 63;
			LC_atwd_a <= '0';
			LC_atwd_b <= '0';
			atwd_a_enable_disc_old	:= '0';
			atwd_b_enable_disc_old	:= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			-- ATWD A
			IF LC_RX_up='1' THEN
				ATWD_A_up_pre_cnt := 0;
				IF ATWD_A_up_post_cnt < CONV_INTEGER(LC_up_post_window) THEN
					IF LC_rx_up_en = '1' THEN
						LC_atwd_a	<= '1';	-- we have LC
					END IF;
				END IF;
			END IF;
			IF LC_RX_down='1' THEN
				ATWD_A_down_pre_cnt := 0;
				IF ATWD_A_down_post_cnt < CONV_INTEGER(LC_down_post_window) THEN
					IF LC_rx_down_en = '1' THEN
						LC_atwd_a	<= '1';	-- we have LC
					END IF;
				END IF;
			END IF;
			
			IF ATWD_A_launch='1' THEN
				IF ATWD_A_up_pre_cnt < CONV_INTEGER(LC_up_pre_window) THEN
					IF LC_rx_up_en = '1' THEN
						LC_atwd_a	<= '1';	-- we have LC
					END IF;
				END IF;
				ATWD_A_down_post_cnt := 0;
			END IF;
			IF ATWD_A_launch='1' THEN
				IF ATWD_A_down_pre_cnt < CONV_INTEGER(LC_down_pre_window) THEN
					IF LC_rx_down_en = '1' THEN
						LC_atwd_a	<= '1';	-- we have LC
					END IF;
				END IF;
				ATWD_A_up_post_cnt := 0;
			END IF;
			
			IF atwd_a_enable_disc='0' AND atwd_a_enable_disc_old='1' THEN
				LC_atwd_a <= '0';
			END IF;
			atwd_a_enable_disc_old	:= atwd_a_enable_disc;
			
			IF ATWD_A_up_pre_cnt < MAX_WINDOW_CNT THEN
				ATWD_A_up_pre_cnt	:= ATWD_A_up_pre_cnt + 1;
			END IF;
			IF ATWD_A_up_post_cnt < MAX_WINDOW_CNT THEN
				ATWD_A_up_post_cnt	:= ATWD_A_up_post_cnt + 1;
			END IF;
			IF ATWD_A_down_pre_cnt < MAX_WINDOW_CNT THEN
				ATWD_A_down_pre_cnt	:= ATWD_A_down_pre_cnt + 1;
			END IF;
			IF ATWD_A_down_post_cnt < MAX_WINDOW_CNT THEN
				ATWD_A_down_post_cnt	:= ATWD_A_down_post_cnt + 1;
			END IF;
			
			-- ATWD B
			IF LC_RX_up='1' THEN
				ATWD_B_up_pre_cnt := 0;
				IF ATWD_B_up_post_cnt < CONV_INTEGER(LC_up_post_window) THEN
					IF LC_rx_up_en = '1' THEN
						LC_ATWD_B	<= '1';	-- we have LC
					END IF;
				END IF;
			END IF;
			IF LC_RX_down='1' THEN
				ATWD_B_down_pre_cnt := 0;
				IF ATWD_B_down_post_cnt < CONV_INTEGER(LC_down_post_window) THEN
					IF LC_rx_down_en = '1' THEN
						LC_ATWD_B	<= '1';	-- we have LC
					END IF;
				END IF;
			END IF;
			
			IF ATWD_B_launch='1' THEN
				IF ATWD_B_up_pre_cnt < CONV_INTEGER(LC_up_pre_window) THEN
					IF LC_rx_up_en = '1' THEN
						LC_ATWD_B	<= '1';	-- we have LC
					END IF;
				END IF;
				ATWD_B_down_post_cnt := 0;
			END IF;
			IF ATWD_B_launch='1' THEN
				IF ATWD_B_down_pre_cnt < CONV_INTEGER(LC_down_pre_window) THEN
					IF LC_rx_down_en = '1' THEN
						LC_ATWD_B	<= '1';	-- we have LC
					END IF;
				END IF;
				ATWD_B_up_post_cnt := 0;
			END IF;
			
			IF atwd_b_enable_disc='0' AND atwd_b_enable_disc_old='1' THEN
				LC_atwd_b <= '0';
			END IF;
			atwd_b_enable_disc_old	:= atwd_b_enable_disc;
			
			IF ATWD_B_up_pre_cnt < MAX_WINDOW_CNT THEN
				ATWD_B_up_pre_cnt	:= ATWD_B_up_pre_cnt + 1;
			END IF;
			IF ATWD_B_up_post_cnt < MAX_WINDOW_CNT THEN
				ATWD_B_up_post_cnt	:= ATWD_B_up_post_cnt + 1;
			END IF;
			IF ATWD_B_down_pre_cnt < MAX_WINDOW_CNT THEN
				ATWD_B_down_pre_cnt	:= ATWD_B_down_pre_cnt + 1;
			END IF;
			IF ATWD_B_down_post_cnt < MAX_WINDOW_CNT THEN
				ATWD_B_down_post_cnt	:= ATWD_B_down_post_cnt + 1;
			END IF;
			
			-- generate LC abort
			
			IF ATWD_A_up_post_cnt = MAX_WINDOW_CNT THEN
				edgeAold := edgeA;
				IF LC_atwd_a = '0' THEN -- no LC -> abort
					 edgeA := '1';
				END IF;
			ELSE
				edgeA		:= '0';
				edgeAold	:= '0';
			END IF;
			atwd0_LC_abort <= edgeA AND NOT edgeAold;
			
			IF ATWD_B_up_post_cnt = MAX_WINDOW_CNT THEN
				edgeBold := edgeB;
				IF LC_atwd_b = '0' THEN -- no LC -> abort
					 edgeB := '1';
				END IF;
			ELSE
				edgeB		:= '0';
				edgeBold	:= '0';
			END IF;
			atwd1_LC_abort <= edgeB AND NOT edgeBold;
			
		END IF;
	END PROCESS;
	
	ATWDlaunch : PROCESS (CLK,RST)
	BEGIN
		IF RST='1' THEN
			atwd0_trigger_old <= '0';
			atwd1_trigger_old <= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			atwd0_trigger_old <= atwd0_trigger;
			atwd1_trigger_old <= atwd1_trigger;
		END IF;
	END PROCESS;
	ATWD_A_launch <= '1' WHEN atwd0_trigger='1' AND atwd0_trigger_old='0' ELSE '0';
	ATWD_B_launch <= '1' WHEN atwd1_trigger='1' AND atwd1_trigger_old='0' ELSE '0';
	
	SPE_DISC : PROCESS(OneSPE, OneSPErst)
	BEGIN
		IF OneSPErst(0)='1' THEN
			OneSPElatch <= '0';
		ELSIF OneSPE'EVENT AND OneSPE='1' THEN
			OneSPElatch <= '1';
		END IF;
	END PROCESS;
	SPE_RESET : PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			OneSPErst <= "000";
		ELSIF CLK'EVENT AND CLK='1' THEN
			OneSPErst(2) <= OneSPElatch;
			OneSPErst(1 DOWNTO 0) <= OneSPErst(2 DOWNTO 1);
			IF OneSPErst(0)='1' THEN
				OneSPErst <= "000";
			END IF;
		END IF;
	END PROCESS;
	disc <= '1' WHEN OneSPErst(2)='1' AND OneSPErst(1)='0' ELSE '0';
	
	
	TC(0) <= LC_RX_up;
	TC(1) <= LC_RX_down;
	TC(2) <= ATWD_A_launch;
	TC(3) <= ATWD_B_launch;
END;
