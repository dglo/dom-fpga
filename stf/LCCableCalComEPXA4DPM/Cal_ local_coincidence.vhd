-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : cal_local_coincidence.vhd
-- Author     : yaver/thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-11-10
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module measures the cable lengths between DOMs. 
--              The measurement is in 40MHz clock cycles. This is done by 
--              sending a local coincidence out to the neighbor DOM and the  
--		neighbor sending a coincidence back. A counter is started when  
--		the intiating DOM sends out a coincidence to its neighbor and 
--		the counter stops when it receives the coincidence back from 
--		the neighbor. The count of "CAL_TIME_UP" and "CAL_TIME_DOWN" 
--		minus a fix delay represents twice the cable length.
--              ****** The fixed delay is 15 for DELAY_PING = '0' ****** 
--		****** The fixed delay is 55 for DELAY_PING = '1' ******
--		Example: FOR DELAY_PING = '0' and a CAL_TIME_UP count of 31 
--		cable delay is (31 - 15)/2 = 8. Time is 8(25ns) = 200 ns.
-------------------------------------------------------------------------------
-- Copyright (c) 2004 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2004-03-22  V01-01-00   yaver/thorsten  
-------------------------------------------------------------------------------
LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
LIBRARY WORK;

ENTITY cal_local_coincidence IS
    PORT (
        -- Common Inputs
        CLK20                : IN  STD_LOGIC;
        CLK40                : IN  STD_LOGIC;
        CLK80                : IN  STD_LOGIC;
        RST                  : IN  STD_LOGIC;
        systime              : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
        -- DAQ interface
        DO_CAL			     : IN  STD_LOGIC_VECTOR (1 DOWNTO 0); --0 is up , 1 is down
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
END cal_local_coincidence;

architecture ARCH_cal_local_coincidence of cal_local_coincidence is

--CONSTANT one_second  : INTEGER := (67108864 - 20000000 + 1); -- Counting up from this value 26th bit changes to 1

signal got_n_down	: STD_LOGIC;
signal got_p_down	: STD_LOGIC;
signal got_extinguish_down : STD_LOGIC;
signal n_down	: STD_LOGIC;
signal p_down	: STD_LOGIC;
signal extinguish_down :STD_LOGIC;

signal push_cnt_up 	: STD_LOGIC_VECTOR(3 downto 0);

signal once_up : STD_LOGIC_VECTOR(3 downto 0);
signal once_down : STD_LOGIC_VECTOR(3 downto 0);

signal got_n_up	: STD_LOGIC;
signal got_p_up	: STD_LOGIC;
signal got_extinguish_up : STD_LOGIC;
signal p_up		: STD_LOGIC;
signal n_up		: STD_LOGIC;
signal extinguish_up :STD_LOGIC;

signal push_cnt_down 	: STD_LOGIC_VECTOR(3 downto 0);

signal push_length   : STD_LOGIC_VECTOR(3 downto 0); --this is the number of DOMs used for con
signal temp_length   : STD_LOGIC_VECTOR(2 downto 0);

signal watch_cnt_up 	: STD_LOGIC_VECTOR(2 downto 0);  --Watch dog, if start coin is received but no stop then when this times out stop is sent
signal watch_cnt_down 	: STD_LOGIC_VECTOR(2 downto 0);

signal lc_wave_up_pos	: STD_LOGIC_VECTOR(15 downto 0); --Captures output of positive  up comparator in shift reg
signal lc_wave_up_neg	: STD_LOGIC_VECTOR(15 downto 0); --Captures output of negative up comparator in shift reg
signal lc_wave_down_pos	: STD_LOGIC_VECTOR(15 downto 0);--Captures output of positive down comparator in shift reg
signal lc_wave_down_neg	: STD_LOGIC_VECTOR(15 downto 0);--Captures output of negative down comparator in shift reg

-- SYMBOLIC ENCODED state machine: S_cal_local_coincidence

type S_cal_local_coincidence_type is (	idle,	--01
					drop_1,	--02
					out_end,  --04
					hit_coin, --08
					finish,
					wait_10 --~~~~
						);
						
signal S_lc_up:   S_cal_local_coincidence_type;
signal S_lc_down: S_cal_local_coincidence_type;

signal cal_max_time_up			: INTEGER RANGE 0 TO 255; --!!CAL maybe use bit 7 and get rid of this signal
signal cal_max_time_down : INTEGER RANGE 0 TO 255;

signal cal_cnt_down : STD_LOGIC_VECTOR(7 downto 0); --timer that starts at launch for down coinc
signal cal_cnt_en_down	: STD_LOGIC;
signal do_cal_down: STD_LOGIC;

signal cal_cnt_up : STD_LOGIC_VECTOR(7 downto 0); --timer that starts at launch for up coinc
signal cal_cnt_en_up	: STD_LOGIC;
signal do_cal_up: STD_LOGIC;

signal DO_CAL_shift: STD_LOGIC_VECTOR(1 downto 0);

--signals converted from STD_LOGIC_VECTORS;
signal length : INTEGER RANGE 0 TO 3; --set coin length, number of DOMs in coin, 0=1DOM, 1=2DOM, 2=3DOM, 3=4DOM

signal coin_ss_up : INTEGER RANGE 0 TO 3;	
signal coin_ss_down : INTEGER RANGE 0 TO 3;

signal wait_cnt_up :	STD_LOGIC_VECTOR(7 downto 0);								
signal wait_cnt_down :	STD_LOGIC_VECTOR(7 downto 0);

signal lock_out_up :	STD_LOGIC_VECTOR(15 downto 0);
signal lock_out_down :	STD_LOGIC_VECTOR(15 downto 0);

signal wup_1 : INTEGER RANGE 0 TO 1;
signal wup_2 : INTEGER RANGE 0 TO 1;
signal wup_3 : INTEGER RANGE 0 TO 1;
signal wup_4 : INTEGER RANGE 0 TO 1;
signal wup_5 : INTEGER RANGE 0 TO 1;
signal wup_6 : INTEGER RANGE 0 TO 1;
signal wup_7 : INTEGER RANGE 0 TO 1;
signal wup_8 : INTEGER RANGE 0 TO 1;

signal wun_1 : INTEGER RANGE 0 TO 1;
signal wun_2 : INTEGER RANGE 0 TO 1;
signal wun_3 : INTEGER RANGE 0 TO 1;
signal wun_4 : INTEGER RANGE 0 TO 1;
signal wun_5 : INTEGER RANGE 0 TO 1;
signal wun_6 : INTEGER RANGE 0 TO 1;
signal wun_7 : INTEGER RANGE 0 TO 1;
signal wun_8 : INTEGER RANGE 0 TO 1;

signal wdp_1 : INTEGER RANGE 0 TO 1;
signal wdp_2 : INTEGER RANGE 0 TO 1;
signal wdp_3 : INTEGER RANGE 0 TO 1;
signal wdp_4 : INTEGER RANGE 0 TO 1;
signal wdp_5 : INTEGER RANGE 0 TO 1;
signal wdp_6 : INTEGER RANGE 0 TO 1;
signal wdp_7 : INTEGER RANGE 0 TO 1;
signal wdp_8 : INTEGER RANGE 0 TO 1;

signal wdn_1 : INTEGER RANGE 0 TO 1;
signal wdn_2 : INTEGER RANGE 0 TO 1;
signal wdn_3 : INTEGER RANGE 0 TO 1;
signal wdn_4 : INTEGER RANGE 0 TO 1;
signal wdn_5 : INTEGER RANGE 0 TO 1;
signal wdn_6 : INTEGER RANGE 0 TO 1;
signal wdn_7 : INTEGER RANGE 0 TO 1;
signal wdn_8 : INTEGER RANGE 0 TO 1;

begin
--second_cnt <= conv_std_logic_vector (one_second,27);

--length <= CONV_INTEGER(LC_ctrl.LC_length);

do_cal_up   <= DO_CAL(0) and not DO_CAL_shift(0);
do_cal_down <= DO_CAL(1) and not DO_CAL_shift(1);

CAL_TIME_UP   <= cal_cnt_up;
CAL_TIME_DOWN <= cal_cnt_down;

cal_max_time_up <= 128;
cal_max_time_down <= 128;

--got_p_down <= ((lc_wave_down_pos(5) and lc_wave_down_pos(4)) and lc_wave_down_neg(3) and lc_wave_down_neg(2)) or p_down;
--got_n_down <= ((lc_wave_down_pos(2) and lc_wave_down_pos(3)) and lc_wave_down_neg(4) and lc_wave_down_neg(5)) or n_down;
got_extinguish_down <= (lc_wave_down_neg(5) and lc_wave_down_neg(4) and lc_wave_down_neg(3) and lc_wave_down_neg(2)) or extinguish_down;

--got_p_up <= ((lc_wave_up_pos(5) and lc_wave_up_pos(4)) and lc_wave_up_neg(3) and lc_wave_up_neg(2)) or p_up;
--got_n_up <= ((lc_wave_up_pos(2) and lc_wave_up_pos(3)) and lc_wave_up_neg(4) and lc_wave_up_neg(5)) or n_up;
got_extinguish_up <= (lc_wave_up_neg(5) and lc_wave_up_neg(4) and lc_wave_up_neg(3) and lc_wave_up_neg(2)) or extinguish_up;

got_p_up <= '1' when (((wup_8 + wup_7 + wup_6 + wup_5) > 2) and ((wun_4 + wun_3 + wun_2 + wun_1) > 2)) or p_up = '1' else 
	    '0';	
got_n_up <= '1' when (((wun_8 + wun_7 + wun_6 + wun_5) > 2) and ((wup_4 + wup_3 + wup_2 + wup_1) > 2)) or n_up = '1' else 
	    '0';
	    
got_p_down <= '1' when (((wdp_8 + wdp_7 + wdp_6 + wdp_5) > 2) and ((wdn_4 + wdn_3 + wdn_2 + wdn_1) > 2)) or p_down = '1' else 
	      '0';	
got_n_down <= '1' when (((wdn_8 + wdn_7 + wdn_6 + wdn_5) > 2) and ((wdp_4 + wdp_3 + wdp_2 + wdp_1) > 2)) or n_down = '1' else 
	      '0';


wup_1 <= CONV_INTEGER (lc_wave_up_pos(2));
wup_2 <= CONV_INTEGER (lc_wave_up_pos(3));
wup_3 <= CONV_INTEGER (lc_wave_up_pos(4));
wup_4 <= CONV_INTEGER (lc_wave_up_pos(5));
wup_5 <= CONV_INTEGER (lc_wave_up_pos(6));
wup_6 <= CONV_INTEGER (lc_wave_up_pos(7));
wup_7 <= CONV_INTEGER (lc_wave_up_pos(8));
wup_8 <= CONV_INTEGER (lc_wave_up_pos(9));

wun_1 <= CONV_INTEGER (lc_wave_up_neg(2));
wun_2 <= CONV_INTEGER (lc_wave_up_neg(3));
wun_3 <= CONV_INTEGER (lc_wave_up_neg(4));
wun_4 <= CONV_INTEGER (lc_wave_up_neg(5));
wun_5 <= CONV_INTEGER (lc_wave_up_neg(6));
wun_6 <= CONV_INTEGER (lc_wave_up_neg(7));
wun_7 <= CONV_INTEGER (lc_wave_up_neg(8));
wun_8 <= CONV_INTEGER (lc_wave_up_neg(9));

wdp_1 <= CONV_INTEGER (lc_wave_down_pos(2));
wdp_2 <= CONV_INTEGER (lc_wave_down_pos(3));
wdp_3 <= CONV_INTEGER (lc_wave_down_pos(4));
wdp_4 <= CONV_INTEGER (lc_wave_down_pos(5));
wdp_5 <= CONV_INTEGER (lc_wave_down_pos(6));
wdp_6 <= CONV_INTEGER (lc_wave_down_pos(7));
wdp_7 <= CONV_INTEGER (lc_wave_down_pos(8));
wdp_8 <= CONV_INTEGER (lc_wave_down_pos(9));

wdn_1 <= CONV_INTEGER (lc_wave_down_neg(2));
wdn_2 <= CONV_INTEGER (lc_wave_down_neg(3));
wdn_3 <= CONV_INTEGER (lc_wave_down_neg(4));
wdn_4 <= CONV_INTEGER (lc_wave_down_neg(5));
wdn_5 <= CONV_INTEGER (lc_wave_down_neg(6));
wdn_6 <= CONV_INTEGER (lc_wave_down_neg(7));
wdn_7 <= CONV_INTEGER (lc_wave_down_neg(8));
wdn_8 <= CONV_INTEGER (lc_wave_down_neg(9));

-- disable comparators (transparent)
COINC_DOWN_ALATCH <= '0';
COINC_DOWN_BLATCH <= '0';
COINC_UP_ALATCH <= '0';
COINC_UP_BLATCH <= '0';

temp_length(2) <= '0';
--!!CAL_CHANGE!!--push_length <= temp_length + 1;
push_length <= "1000";

TC(0) <= got_p_up;
TC(1) <= got_n_up;
TC(2) <= got_p_down;
TC(3) <= got_n_down;
TC(4) <= lc_wave_up_pos(7);
TC(5) <= lc_wave_up_neg(7);
TC(6) <= lc_wave_down_pos(7);
TC(7) <= lc_wave_down_neg(7);

cal_local_coincidence_up: process (CLK40, RST)
begin	
	if RST = '1' then
		COINCIDENCE_OUT_UP <= 'Z';
		once_up <= (others => '0');
		push_cnt_up <= (others => '0');
		watch_cnt_up <= (others => '0');
		wait_cnt_up <= (others => '0'); 	--~~~~
		lock_out_up <= "0100000000000000";	--~~~~
		S_lc_up <= idle;
	elsif CLK40'event and CLK40 = '1' then
	case S_lc_up is
		when idle =>
			push_cnt_up <= (others => '0');
			watch_cnt_up <= (others => '0');	
			once_up <= (others => '0');
			if PING_DELAY = '0' then 
				wait_cnt_up <= (others => '0');
			else
				wait_cnt_up <= "11011000"; 	-- -40 --~~~~
			end if;
			if lock_out_up < 512 then  --~~~~
				lock_out_up <= lock_out_up + '1'; 	--~~~~
			end if;
			if do_cal_up = '1' then  --!!CAL_CHANGE!!--
				--if LC_ctrl.LC_tx_enable(0) = '1' then
				lock_out_up <=(others => '0'); 	--~~~~
				COINCIDENCE_OUT_UP <= '1'; --Beginning of start
				--end if;
				push_cnt_up <= push_cnt_up + '1';
				S_lc_up <= hit_coin;
			elsif got_p_up = '1' and lock_out_up > 256 then --~~~~ --!!CAL_CHANGE!!--
				push_cnt_up <= push_cnt_up + '1';
				S_lc_up <= wait_10; --~~~~ was "S_lc_up <= drop_1;"
				COINCIDENCE_OUT_UP <= 'Z';
			else 	
				COINCIDENCE_OUT_UP <= 'Z';
				S_lc_up <= idle;
			end if;
			
		when drop_1 =>		--goes here when local coin comes in 
			if do_cal_up = '1' then						--!!CAL_CHANGE OK to delete!!--
				--if LC_ctrl.LC_tx_enable(0) = '1' then 		--!!CAL_CHANGE OK to delete!!--
				COINCIDENCE_OUT_UP <= '1'; 					--!!CAL_CHANGE OK to delete!!--
				--end if; 					--!!CAL_CHANGE OK to delete!!--
				push_cnt_up <= push_cnt_up + '1';					--!!CAL_CHANGE OK to delete!!--
				S_lc_up <= hit_coin;					--!!CAL_CHANGE OK to delete!!--
			elsif got_n_up = '1' or got_extinguish_up = '1' then --!!CAL_CHANGE!!--
				S_lc_up <= idle;
			else 
				--if LC_ctrl.LC_tx_enable(0) = '1' then
				COINCIDENCE_OUT_UP <= '1';
				--end if;   
				watch_cnt_up <= watch_cnt_up + '1';
				S_lc_up <= out_end;
			end if;
			
		when out_end =>
			once_up <= once_up + '1';
			if once_up < 1 then --was "if LC_ctrl.LC_tx_enable(0) = '1' and once_up = '0' then"
				COINCIDENCE_OUT_UP <= '1';-- End of start
			elsif once_up < 3 then
				COINCIDENCE_OUT_UP <= '0';-- End of start
			else
				COINCIDENCE_OUT_UP <= 'Z';
			end if;
			watch_cnt_up <= watch_cnt_up + '1';
			push_cnt_up <= push_cnt_up + '1';
			if do_cal_up = '1' then
				S_lc_up <= hit_coin;
			elsif got_n_up = '1'then --!!CAL_CHANGE!!--
				--if LC_ctrl.LC_tx_enable(0) = '1' then
					COINCIDENCE_OUT_UP <= '0';-- Normal begining of stop for coin pass
					S_lc_up <= finish;
				--end if;
			elsif watch_cnt_up > 5 then
				--if LC_ctrl.LC_tx_enable(0) = '1' then
					COINCIDENCE_OUT_UP <= '0';-- Forced stop is signal gets lost
					S_lc_up <= finish;
				--end if;
				--S_lc_up <= finish;
			else	
				S_lc_up <= out_end;
			end if;	--##					
		
		when hit_coin =>	-- goes here when PMT got hit
			once_up <= once_up + '1';
			if once_up < 1 then --was "if LC_ctrl.LC_tx_enable(0) = '1' and once_up = '0' then"
				COINCIDENCE_OUT_UP <= '1';-- End of start
			elsif once_up < 3 then
				COINCIDENCE_OUT_UP <= '0';-- End of start
			elsif push_cnt_up <= push_length then
				COINCIDENCE_OUT_UP <= 'Z';
			else
				COINCIDENCE_OUT_UP <= '0'; -- Normal begining of stop for hit pass
				once_up <= (others => '0');
				S_lc_up <= finish;
			end if;
			--MISTAKE!!!!!!!!!! check lc_coincidene
			--!	else 			  !add to fix
			--!		S_lc_up <= finish !add to fix
				--end if;
			push_cnt_up <= push_cnt_up + '1';
		when finish =>
			once_up <= once_up + '1';
			if once_up < 1 then --was "if LC_ctrl.LC_tx_enable(0) = '1' and once_up = '0' then"
				COINCIDENCE_OUT_UP <= '0';-- End of start
			elsif once_up < 3 then
				COINCIDENCE_OUT_UP <= '1';--End of Stop
			else
				COINCIDENCE_OUT_UP <= 'Z';
				S_lc_up <= idle;
			end if;
		when wait_10 => 	--~~~~
			wait_cnt_up <= wait_cnt_up + '1'; 	--~~~~
			if wait_cnt_up = 0 or wait_cnt_up = 1 then 	--~~~~
				COINCIDENCE_OUT_UP <= '1'; 	--~~~~
			elsif wait_cnt_up = 2 or wait_cnt_up = 3 or wait_cnt_up = 4 or wait_cnt_up = 5 then				--~~~~
				COINCIDENCE_OUT_UP <= '0'; 	--~~~~
			elsif wait_cnt_up = 6 or wait_cnt_up = 7 then				--~~~~
				COINCIDENCE_OUT_UP <= '1'; 	--~~~~	
		 	elsif wait_cnt_up = 8 then				--~~~~  
				COINCIDENCE_OUT_UP <= 'Z'; 	--~~~~
				S_lc_up <= idle; 	--~~~~
			else COINCIDENCE_OUT_UP <= 'Z';
			end if; 	--~~~~
		end case;
	end if;	
end process;

cal_local_coincidence_down: process (CLK40, RST)
begin
	if RST = '1' then
		COINCIDENCE_OUT_DOWN <= 'Z';
		once_down <= (others => '0');
		push_cnt_down <= (others => '0');
		watch_cnt_down <= (others => '0');
		wait_cnt_down <= (others => '0'); 	--~~~~
		lock_out_down <= "0100000000000000";	--~~~~
		S_lc_down <= idle;
	elsif CLK40'event and CLK40 = '1' then
	
	case S_lc_down is
		when idle =>
			push_cnt_down <= (others => '0');
			watch_cnt_down <= (others => '0');
			once_down <= (others => '0');
			if PING_DELAY = '0' then 
				wait_cnt_down <= (others => '0');
			else
				wait_cnt_down <= "11011000"; 	-- -40
			end if;
			if lock_out_down < 512 then  --~~~~
				lock_out_down <= lock_out_down + '1'; 	--~~~~
			end if;
			if do_cal_down = '1' then --!!CAL_CHANGE!!--
				lock_out_down <=(others => '0'); 	--~~~~
				--if LC_ctrl.LC_tx_enable(1) = '1' then
				COINCIDENCE_OUT_DOWN <= '1'; --Beginning of start
				--end if;
				push_cnt_down <= push_cnt_down + '1';
				S_lc_down <= hit_coin;
			elsif got_p_down = '1' and lock_out_down > 256 then --~~~~ --!!CAL_CHANGE!!-- 
				push_cnt_down <= push_cnt_down + '1';
				S_lc_down <= wait_10; --~~~~ was "S_lc_down <= drop_1;"
				COINCIDENCE_OUT_DOWN <= 'Z';
			else 	COINCIDENCE_OUT_DOWN <= 'Z';
				S_lc_down <= idle;
			end if;
			
		when drop_1 =>		--goes here when local coin comes in 
			if do_cal_down = '1' then   						--!!CAL_CHANGE OK to delete!!--
				--if LC_ctrl.LC_tx_enable(1) = '1' then  	--!!CAL_CHANGE OK to delete!!--
				COINCIDENCE_OUT_DOWN <= '1';  					--!!CAL_CHANGE OK to delete!!--
				--end if;  					--!!CAL_CHANGE OK to delete!!--
				push_cnt_down <= push_cnt_down + '1';  	--!!CAL_CHANGE OK to delete!!--
				S_lc_down <= hit_coin;  					--!!CAL_CHANGE OK to delete!!--
			elsif got_n_down = '1' or got_extinguish_down = '1' then --!!CAL_CHANGE!!--
				S_lc_down <= idle;
			else 
				--if LC_ctrl.LC_tx_enable(1) = '1' then
				COINCIDENCE_OUT_DOWN <= '1';
				--end if;   
				watch_cnt_down <= watch_cnt_down + '1';
				S_lc_down <= out_end;
			end if;
			
		when out_end =>
			once_down <= once_down + '1';
			if once_down < 1 then --was "if LC_ctrl.LC_tx_enable(0) = '1' and once_up = '0' then"
				COINCIDENCE_OUT_DOWN <= '1';-- End of start
			elsif once_down < 3 then
				COINCIDENCE_OUT_DOWN <= '0';-- End of start
			else
				COINCIDENCE_OUT_DOWN <= 'Z';
			end if;
			watch_cnt_down <= watch_cnt_down + '1';
			push_cnt_down <= push_cnt_down + '1';
			if do_cal_down = '1' then --!!CAL_CHANGE!!--
				S_lc_down <= hit_coin;
			elsif got_n_down = '1'then --!!CAL_CHANGE!!--
				--if LC_ctrl.LC_tx_enable(1) = '1' then
					COINCIDENCE_OUT_DOWN <= '0';-- Normal begining of stop for coin pass
					S_lc_down <= finish;
				--end if;
			elsif watch_cnt_down > 5 then
				--if LC_ctrl.LC_tx_enable(1) = '1' then
					COINCIDENCE_OUT_DOWN <= '0';-- Forced stop is signal gets lost
					S_lc_down <= finish;
				--end if;
				--S_lc_down <= finish;
			else	
				S_lc_down <= out_end;
			end if;				
		
		when hit_coin =>	-- goes here when PMT got hit
			once_down <= once_down + '1';
			if once_down < 1 then --was "if LC_ctrl.LC_tx_enable(0) = '1' and once_up = '0' then"
				COINCIDENCE_OUT_DOWN <= '1';-- End of start
			elsif once_down < 3 then
				COINCIDENCE_OUT_DOWN <= '0';-- End of start
			elsif push_cnt_down <= push_length then
				COINCIDENCE_OUT_DOWN <= 'Z';
			else
				COINCIDENCE_OUT_DOWN <= '0';
				once_down <= (others => '0');
				S_lc_down <= finish;
				
			end if;
			push_cnt_down <= push_cnt_down + '1';
		when finish =>			
			once_down <= once_down  + '1';
			if once_down  < 1 then --was "if LC_ctrl.LC_tx_enable(0) = '1' and once_up = '0' then"
				COINCIDENCE_OUT_DOWN <= '0';-- End of start
			elsif once_down  < 3 then
				COINCIDENCE_OUT_DOWN <= '1';--End of Stop
			else
				COINCIDENCE_OUT_DOWN <= 'Z';
				S_lc_down <= idle;
			end if;
		when wait_10 => 	--~~~~
			wait_cnt_down <= wait_cnt_down + '1'; 	--~~~~
			if wait_cnt_down = 0 or wait_cnt_down = 1 then 	--~~~~
				COINCIDENCE_OUT_DOWN <= '1'; 	--~~~~
			elsif wait_cnt_down = 2 or wait_cnt_down = 3 or wait_cnt_down = 4 or wait_cnt_down = 5 then				--~~~~
				COINCIDENCE_OUT_DOWN <= '0'; 	--~~~~
			elsif wait_cnt_down = 6 or wait_cnt_down = 7 then				--~~~~
				COINCIDENCE_OUT_DOWN <= '1'; 	--~~~~  
			elsif wait_cnt_down = 8 then				--~~~~
				COINCIDENCE_OUT_DOWN <= 'Z'; 	--~~~~
				S_lc_down <= idle; 	--~~~~ 
			else COINCIDENCE_OUT_DOWN <= 'Z';
			end if; 	--~~~~
		end case;
	end if;	
end process;

lc_wave_down: process (CLK80, RST)  --use clock 80MHz
begin
	if RST = '1' then
		lc_wave_down_pos <= (others => '0');
		lc_wave_down_neg <= (others => '0');
	elsif CLK80'event and CLK80 = '1' then
	
	
	if  ((wdp_8 + wdp_7 + wdp_6 + wdp_5) > 1) and  ((wdn_4 + wdn_3 + wdn_2 + wdn_1) > 2) then
		p_down <= '1';
	else
		p_down <= '0';
	end if;	
	
	if  ((wdn_8 + wdn_7 + wdn_6 + wdn_5) > 1) and  ((wdp_4 + wdp_3 + wdp_2 + wdp_1) > 2) then
		n_down <= '1';
	else
		n_down <= '0';
	end if;	
	
	
		--!!CAL_CHANGE!!--if LC_ctrl.LC_rx_enable(1)='1' then 
			lc_wave_down_pos(0) <=  COINC_DOWN_A;
			lc_wave_down_pos(15 downto 1) <= lc_wave_down_pos(14 downto 0);
			lc_wave_down_neg(0) <=  COINC_DOWN_B;
			lc_wave_down_neg(15 downto 1) <= lc_wave_down_neg(14 downto 0);
		--!!CAL_CHANGE!!--end if;
		--used to stretch got_p_down and got_n_down signals so they are one 40MHz cycle wide
	--p_down <= (lc_wave_down_pos(5) and lc_wave_down_pos(4)) and lc_wave_down_neg(3) and lc_wave_down_neg(2);
	--n_down <= (lc_wave_down_pos(2) and lc_wave_down_pos(3)) and lc_wave_down_neg(4) and lc_wave_down_neg(5);
	extinguish_down <= lc_wave_down_neg(5) and lc_wave_down_neg(4) and lc_wave_down_neg(3) and lc_wave_down_neg(2);
	end if;
end process;

lc_wave_up: process (CLK80, RST)  --use clock 80MHz
begin
	if RST = '1' then
		lc_wave_up_pos <= (others => '0');
		lc_wave_up_neg <= (others => '0');
	elsif CLK80'event and CLK80 = '1' then
	
	if  ((wup_8 + wup_7 + wup_6 + wup_5) > 1) and  ((wun_4 + wun_3 + wun_2 + wun_1) > 2) then
		p_up <= '1';
	else
		p_up <= '0';
	end if;	
	
	if  ((wun_8 + wun_7 + wun_6 + wun_5) > 1) and  ((wup_4 + wup_3 + wup_2 + wup_1) > 2) then
		n_up <= '1';
	else
		n_up <= '0';
	end if;	
	
	
		--!!CAL_CHANGE!!--if LC_ctrl.LC_rx_enable(0)='1' then  
			lc_wave_up_pos(0) <=  COINC_UP_A;
			lc_wave_up_pos(15 downto 1) <= lc_wave_up_pos(14 downto 0);
			lc_wave_up_neg(0) <=  COINC_UP_B;
			lc_wave_up_neg(15 downto 1) <= lc_wave_up_neg(14 downto 0);
		--!!CAL_CHANGE!!--end if;
	--used to stretch got_p_up and got_n_up signals so they are one 40MHz cycle wide
	--p_up <= (lc_wave_up_pos(5) and lc_wave_up_pos(4)) and lc_wave_up_neg(3) and lc_wave_up_neg(2);
	--n_up <= (lc_wave_up_pos(2) and lc_wave_up_pos(3)) and lc_wave_up_neg(4) and lc_wave_up_neg(5);
	extinguish_up <= lc_wave_up_neg(5) and lc_wave_up_neg(4) and lc_wave_up_neg(3) and lc_wave_up_neg(2);
	end if;
	
end process;



cal_timer_up: process (CLK40, RST)
begin
	if RST = '1' then
		cal_cnt_up <= (others => '0');
		cal_cnt_en_up <= '0';
	elsif CLK40'event and CLK40 = '1' then
		if do_cal_up = '1' then
			cal_cnt_en_up <= '1';
			cal_cnt_up <= (others => '0');
		elsif	got_n_up = '1' then
			cal_cnt_en_up <= '0';
		end if;
		if cal_cnt_up < cal_max_time_up and cal_cnt_en_up = '1' then
			cal_cnt_up <= cal_cnt_up + '1';
		elsif cal_cnt_up >= cal_max_time_up or got_n_up = '1' then
			cal_cnt_en_up <= '0';
		end if;
	end if;
end process cal_timer_up;

cal_timer_down: process (CLK40, RST)
begin
	if RST = '1' then
		cal_cnt_down <= (others => '0');
		cal_cnt_en_down <= '0';
	elsif CLK40'event and CLK40 = '1' then
		if do_cal_down = '1' then
			cal_cnt_en_down <= '1';
			cal_cnt_down <= (others => '0');
		elsif	got_n_down = '1' then
			cal_cnt_en_down <= '0';
		end if;
		if cal_cnt_down < cal_max_time_down and cal_cnt_en_down = '1' then
			cal_cnt_down <= cal_cnt_down + '1';
		elsif cal_cnt_down >= cal_max_time_down or got_n_down = '1' then
			cal_cnt_en_down <= '0';
		end if;
	end if;
end process cal_timer_down;

DO_CAL_edge: process (CLK40, RST)
begin
	if RST = '1' then
		DO_CAL_shift <= "00";		
	elsif CLK40'event and CLK40 = '1' then
		DO_CAL_shift <= DO_CAL;
	end if;
end process DO_CAL_edge;

		
end ARCH_cal_local_coincidence;


