-------------------------------------------------
-- ATWD control
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
LIBRARY WORK;
USE WORK.constants.ALL;


ENTITY ATWD_control IS
	PORT (
		CLK40		: IN STD_LOGIC;
		CLK80		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- control
		ATWD_busy	: OUT STD_LOGIC;
		ATWD_enable	: IN STD_LOGIC;
		ATWD_mode	: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		ATWD_n_chan	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		abort		: IN STD_LOGIC;
		-- atwd
		ATWDTrigger		: IN STD_LOGIC;
		TriggerComplete	: IN STD_LOGIC;
		OutputEnable	: OUT STD_LOGIC;
		CounterClock	: OUT STD_LOGIC;
		RampSet			: OUT STD_LOGIC;
		ChannelSelect	: OUT STD_LOGIC_VECTOR(1 downto 0);
		ReadWrite		: OUT STD_LOGIC;
		AnalogReset		: OUT STD_LOGIC;
		DigitalReset	: OUT STD_LOGIC;
		DigitalSet		: OUT STD_LOGIC;
		ATWD_VDD_SUP	: OUT STD_LOGIC;
		ShiftClock		: OUT STD_LOGIC;
		ATWD_D			: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		-- data
		ATWD_D_gray		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		ATWD_D_addr		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
		ATWD_D_we		: OUT STD_LOGIC;
		ATWD_D_bin		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END ATWD_control;


ARCHITECTURE arch_ATWD_control OF ATWD_control IS
	
	TYPE ATWD_state_type is (digitize, idle, init_digitize, next_channel, power_up_init1, power_up_init2, readout_L0, readout_L1, readout_H0, readout_H1, readout_end, settle, wait_trig_compl);
	SIGNAL state	: ATWD_state_type;
	
	SIGNAL settle_cnt	: INTEGER;
	SIGNAL digitize_cnt	: INTEGER;
	SIGNAL readout_cnt	: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL channel		: STD_LOGIC_VECTOR (1 downto 0);
	SIGNAL counterclk_low	: STD_LOGIC;
	SIGNAL counterclk_high	: STD_LOGIC;
	
	SIGNAL overflow		: STD_LOGIC;
	
	SIGNAL status		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	
BEGIN
	
	ATWD_VDD_SUP	<= '1';
	
	PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
			state	<= power_up_init1;
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			CASE state IS
				WHEN power_up_init1 =>
					state	<= power_up_init2;
					
					DigitalSet		<= '0';
					DigitalReset	<= '1';
					RampSet			<= '1';
					ReadWrite		<= '0';
					AnalogReset		<= '1';
					channel			<= "00";
					OutputEnable	<= '0';
					ShiftClock		<= '0';
					
					ATWD_busy		<= '1';
					counterclk_low	<= '1';
					counterclk_high	<= '0';
					ATWD_D_we			<= '0';
					readout_cnt		<= conv_std_logic_vector(-1,8); --(OTHERS=>'1'); -- -1
					ATWD_n_chan		<= "00";
				WHEN power_up_init2 =>
					state	<= idle;
					DigitalReset	<= '0';
				WHEN idle =>
					IF ATWDTrigger='1' AND ATWD_enable='1' THEN
						state	<= wait_trig_compl;
					END IF;
					ReadWrite		<= '0';
					DigitalSet		<= '0';
					DigitalReset	<= '1';
					channel			<= "00";
					
					ATWD_busy		<= '0';
					counterclk_low	<= '1';
					counterclk_high	<= '0';
					readout_cnt		<= (OTHERS=>'1'); -- -1
				WHEN wait_trig_compl =>
					IF TriggerComplete='0' THEN
						state	<= init_digitize;
					END IF;
					ATWD_busy		<= '1';
				WHEN init_digitize =>
					state	<= settle;
					AnalogReset		<= '0';
					counterclk_low	<= '1';
					counterclk_high	<= '0';
					settle_cnt		<= 0;
					digitize_cnt	<= 1; -- 0;
				WHEN settle =>
					IF settle_cnt=128 OR abort='1' THEN
						state	<= digitize;
					END IF;
					ReadWrite	<= '1';
					settle_cnt	<= settle_cnt+1;
				WHEN digitize =>
					DigitalReset	<= '0';
					RampSet			<= '0';
					counterclk_low	<= '0';
					counterclk_high	<= '0';
					digitize_cnt	<= digitize_cnt + 1;
					IF digitize_cnt=512 OR abort='1' THEN
						state	<= readout_L0;
						counterclk_high	<= '1';
					END IF;
				WHEN readout_L0 =>
					state	<= readout_L1;
					DigitalSet		<= '1';
					RampSet			<= '1';
					AnalogReset		<= '1';
					OutputEnable	<= '1';
					ShiftClock		<= '0';
					counterclk_low	<= '0';
					counterclk_high	<= '1';
					ATWD_D_we			<= '0';
				WHEN readout_L1 =>
					state	<= readout_H0;
					ShiftClock		<= '0';
				WHEN readout_H0 =>
					state	<= readout_H1;
					ShiftClock		<= '1';
					ATWD_D_gray	<= ATWD_D;
					readout_cnt	<= readout_cnt + 1;
				WHEN readout_H1 =>
					IF readout_cnt=127 OR abort='1' THEN
						state	<= readout_end;
					ELSE
						state	<= readout_L0;
					END IF;
					DigitalSet		<= '1';
					RampSet			<= '1';
					AnalogReset		<= '1';
					OutputEnable	<= '1';
					ShiftClock		<= '1';
					counterclk_low	<= '0';
					counterclk_high	<= '1';
					ATWD_D_we			<= '1';
				WHEN readout_end =>
					IF (ATWD_mode(1 DOWNTO 0)=ATWD_mode_ALL AND channel="11") OR	--we are done
					   (ATWD_mode(1 DOWNTO 0)=ATWD_mode_NORMAL AND overflow='0') OR
					   (ATWD_mode(1 DOWNTO 0)=ATWD_mode_NORMAL AND channel="10") OR
					   abort='1' THEN
						state	<= idle; --restart_ATWD;
					ELSE
						state	<= next_channel;
					END IF;
					DigitalSet		<= '1';
					RampSet			<= '1';
					AnalogReset		<= '1';
					OutputEnable	<= '0';
					ShiftClock		<= '0';
					counterclk_low	<= '1';
					counterclk_high	<= '0';
					ATWD_D_we		<= '0';
					ATWD_n_chan		<= channel;
				WHEN next_channel =>
					state	<= init_digitize;
					DigitalSet		<= '0';
					DigitalReset	<= '1';
					ReadWrite		<= '0';
					AnalogReset		<= '1';
					readout_cnt		<= conv_std_logic_vector(-1,8); --(OTHERS=>'1'); -- -1
					channel			<= channel + 1;
--				WHEN restart_ATWD =>
--					IF TriggerComplete='1' THEN
--						state	<= ATWDrecover;
--					END IF;
--					DigitalSet		<= '0';
--					DigitalReset	<= '1';
--					ReadWrite		<= '0';
--					reset_trig		<= '1';
--				WHEN ATWDrecover =>
--					state	<= idle;
			END CASE;
				
		END IF;
	END PROCESS;
	
	ChannelSelect	<= channel;
	ATWD_D_addr (6 DOWNTO 0)	<= readout_cnt (6 DOWNTO 0);
	ATWD_D_addr (8 DOWNTO 7)	<= channel;
	
	-- this process generates the CounterClock for the ATWD
	counter_clock : PROCESS(CLK80,RST)
		VARIABLE	cclk	: STD_LOGIC;
	BEGIN
		IF RST='1' THEN
			CounterClock	<= '0';
		ELSIF CLK80'EVENT AND CLK80='1' THEN
			IF counterclk_high='1' THEN
				cclk	:= '1';
			ELSIF counterclk_low='1' THEN
				cclk	:= '0';
			ELSE
				cclk	:= NOT cclk;
			END IF;
			CounterClock	<= cclk;
		END IF;
	END PROCESS;
	
	-- this process checks the ATWD data for an overflow
	overflow_flag : PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
			overflow	<= '0';
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			IF state=digitize THEN
				overflow	<= '0';
			ELSIF state=readout_H1 THEN
				IF ATWD_D_bin >= ov_threshold THEN
					overflow	<= '1';
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	status(0)	<= '1' WHEN state=IDLE ELSE '0';	-- idle
	status(1)	<= '1' WHEN state=wait_trig_compl ELSE '0';	-- acquire
	status(2)	<= '1' WHEN state=settle ELSE '0';	-- settle
	status(3)	<= '1' WHEN state=init_digitize OR state=init_digitize ELSE '0';	-- digitize
	status(4)	<= '1' WHEN state=readout_L0 OR state=readout_L1 OR state=readout_H0 OR state=readout_H1 OR state=readout_end ELSE '0';	-- readout
	status(5)	<= '1' WHEN state=power_up_init1 OR state=power_up_init2 OR state=next_channel ELSE '0';	-- misc
	status(7 DOWNTO 6)	<= "00";
	
END;
