-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : local_coincidence.vhd
-- Author     : yaver/thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-02-27
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module outputs the up and down local coincidence signals.
--              Inputs that stimulate the output are if the DOM got a hit or 
--              if the DOM received a local coincidence from its neighbor in 
--		which case it has to pass it on. Incoming hits are checked to 
--		see if they fall within a dynamically changing pre and post 
--		window. When a launch comes in a launch_cntr starts to time when the 
--		occured. This is compared to a pre and post window cnt
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
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
USE WORK.ctrl_data_types.ALL;


ENTITY local_coincidence IS
    PORT (
        -- Common Inputs
        CLK20                : IN  STD_LOGIC;
        CLK40                : IN  STD_LOGIC;
        CLK80                : IN  STD_LOGIC;
        RST                  : IN  STD_LOGIC;
        systime              : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
        -- slaveregister
        LC_ctrl              : IN  LC_STRUCT;
        -- DAQ interface
        lc_daq_trigger       : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- what do I do with this = got_p_up
        lc_daq_abort         : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        lc_daq_disc          : IN  STD_LOGIC_VECTOR (1 DOWNTO 0); --DOM got a hit
        lc_daq_launch        : IN  STD_LOGIC_VECTOR (1 DOWNTO 0); --static level indicating ATWD launch
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
END local_coincidence;

architecture ARCH_local_coincidence of local_coincidence is

--CONSTANT one_second  : INTEGER := (67108864 - 20000000 + 1); -- Counting up from this value 26th bit changes to 1

signal got_hit			 : STD_LOGIC;
signal got_hit_bit_down		: STD_LOGIC;
signal got_hit_bit_up		  : STD_LOGIC;

signal got_n_down	: STD_LOGIC;
signal got_p_down	: STD_LOGIC;
signal got_extinguish_down : STD_LOGIC;
signal n_down	: STD_LOGIC;
signal p_down	: STD_LOGIC;
signal got_n_down_delay	: STD_LOGIC;
signal got_p_down_delay	: STD_LOGIC;
signal n_down_delay	: STD_LOGIC_VECTOR( 1 downto 0);
signal p_down_delay	: STD_LOGIC_VECTOR( 1 downto 0);
signal extinguish_down :STD_LOGIC;

signal push_cnt_up 	: STD_LOGIC_VECTOR(3 downto 0);

signal once_up : STD_LOGIC;
signal once_down : STD_LOGIC;

signal got_n_up	: STD_LOGIC;
signal got_p_up	: STD_LOGIC;
signal got_n_up_delay	: STD_LOGIC;
signal got_p_up_delay	: STD_LOGIC;
signal n_up_delay	: STD_LOGIC_VECTOR( 1 downto 0);
signal p_up_delay	: STD_LOGIC_VECTOR( 1 downto 0);
signal got_extinguish_up : STD_LOGIC;
signal p_up		: STD_LOGIC;
signal n_up		: STD_LOGIC;
signal extinguish_up :STD_LOGIC;


signal push_cnt_down 	: STD_LOGIC_VECTOR(3 downto 0);

signal push_length   : STD_LOGIC_VECTOR(2 downto 0); --this is the number of DOMs used for con
signal temp_length   : STD_LOGIC_VECTOR(2 downto 0);

signal watch_cnt_up 	: STD_LOGIC_VECTOR(3 downto 0);  --Watch dog, if start coin is received but no stop then when this times out stop is sent
signal watch_cnt_down 	: STD_LOGIC_VECTOR(3 downto 0);

signal lc_wave_up_pos	: STD_LOGIC_VECTOR(15 downto 0); --Captures output of positive  up comparator in shift reg
signal lc_wave_up_neg	: STD_LOGIC_VECTOR(15 downto 0); --Captures output of negative up comparator in shift reg
signal lc_wave_down_pos	: STD_LOGIC_VECTOR(15 downto 0);--Captures output of positive down comparator in shift reg
signal lc_wave_down_neg	: STD_LOGIC_VECTOR(15 downto 0);--Captures output of negative down comparator in shift reg

signal ok_up	: STD_LOGIC;
signal ok_down	: STD_LOGIC;

signal check_end_up_0 : STD_LOGIC;
signal check_end_down_0 : STD_LOGIC;
signal check_abort_0 : STD_LOGIC;
signal launch_ok_0 : STD_LOGIC;

signal check_end_up_1 : STD_LOGIC;
signal check_end_down_1 : STD_LOGIC;
signal check_abort_1 : STD_LOGIC;
signal launch_ok_1 : STD_LOGIC;

--signal check_up_now : STD_LOGIC;

signal got_launch : STD_LOGIC;
signal got_launch_0 : STD_LOGIC;
signal got_launch_1 : STD_LOGIC;
signal launch_0_shift	: STD_LOGIC;
signal launch_1_shift	: STD_LOGIC;

-- SYMBOLIC ENCODED state machine: S_local_coincidence

type S_local_coincidence_type is (	idle,	--01
					drop_1,	--02
					out_end,  --04
					hit_coin, --08
					finish
						);
						
signal S_lc_up:   S_local_coincidence_type;
signal S_lc_down: S_local_coincidence_type;

TYPE DOM_DELAY IS ARRAY(0 TO 3) OF INTEGER RANGE 0 TO 127;
TYPE CABLE_LENGTH IS ARRAY(0 TO 1) OF DOM_DELAY;
TYPE COIN_LENGTH IS ARRAY(0 TO 3) OF CABLE_LENGTH;

--SIGNAL TEST_ARRAY_DATA : INTEGER RANGE 0 TO 127;
-- Using 6.5 clocks for Short cable delay rounded down
-- Using 14.5 clocks for long cable delay rounded down
-- Note: For locations that are not normaly accessed a value of 127 is entered
----------------------------------  Short  -------  Long---- (1DOM away, 2DOM away, 3DOM away, 4 DOM away)
constant ARRAY3D : COIN_LENGTH := (((15, 127, 127, 127), (23, 127, 127, 127)), --Push Length = 0
				  ((16, 39, 127, 127), (24, 39, 127, 127)), --Push Length = 1
				  ((17, 40, 54, 127),  (25, 40, 62, 127)), --Push Length = 2
				  ((18, 41, 55, 78),   (26, 41, 63, 78))); --Push Length = 3

signal launch_max_time_up   : INTEGER RANGE 0 TO 141;
signal launch_max_time_down : INTEGER RANGE 0 TO 141;


signal launch_cnt_up_pre_min : INTEGER RANGE -64 TO 127;
signal pre_window_cnt_up : INTEGER RANGE -64 TO 1;
signal launch_cnt_up_post_max : INTEGER RANGE 0 TO 141;
signal launch_cnt_up_limit : INTEGER RANGE 0 TO 127;

signal launch_cnt_down_pre_min : INTEGER RANGE -64 TO 127;
signal pre_window_cnt_down : INTEGER RANGE -64 TO 1;
signal launch_cnt_down_post_max : INTEGER RANGE 0 TO 141;
signal launch_cnt_down_limit : INTEGER RANGE 0 TO 127;

signal launch_cnt_down : STD_LOGIC_VECTOR(7 downto 0); --timer that starts at launch for down coinc
signal launch_cnt_end_down	: STD_LOGIC;

signal launch_cnt_up : STD_LOGIC_VECTOR(7 downto 0); --timer that starts at launch for up coinc
signal launch_cnt_end_up	: STD_LOGIC;

signal cnt_ss_up : STD_LOGIC_VECTOR(5 downto 0);
signal cnt_ss_up_done : STD_LOGIC;

signal cnt_ss_down : STD_LOGIC_VECTOR(5 downto 0);
signal cnt_ss_down_done : STD_LOGIC;

--signals converted from STD_LOGIC_VECTORS;
signal length : INTEGER RANGE 0 TO 3; --set coin length, number of DOMs in coin, 0=1DOM, 1=2DOM, 2=3DOM, 3=4DOM
signal cable_up : INTEGER RANGE 0 TO 1;
signal cable_down : INTEGER RANGE 0 TO 1;
signal post_window	: INTEGER RANGE 0 TO 63;
signal pre_window	: INTEGER RANGE 0 TO 63;

signal coin_ss_up : INTEGER RANGE 0 TO 3;	
signal coin_ss_down : INTEGER RANGE 0 TO 3;

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

signal wf_seq_up : STD_LOGIC_VECTOR(3 downto 0);
signal wf_seq_down : STD_LOGIC_VECTOR(3 downto 0);								

begin
--second_cnt <= conv_std_logic_vector (one_second,27);

length <= CONV_INTEGER(LC_ctrl.LC_length);
cable_up <= CONV_INTEGER (LC_ctrl.LC_cable_comp(0));
cable_down <= CONV_INTEGER (LC_ctrl.LC_cable_comp(1));
post_window <= CONV_INTEGER (LC_ctrl.LC_post_window);
pre_window <= CONV_INTEGER (LC_ctrl.LC_pre_window);

coin_ss_up <= 0 when cnt_ss_up > 44
	else CONV_INTEGER (cnt_ss_up(3 downto 2)); -- using the lower two bits to index array
coin_ss_down <= 0  when cnt_ss_down > 44
	else CONV_INTEGER (cnt_ss_down(3 downto 2)); -- usig need the lower two bits to index array
--			Push length		cable length   DOMs away
launch_max_time_down <= (ARRAY3D (length) (cable_down) (length)) + post_window;
launch_max_time_up <= (ARRAY3D (length) (cable_up) (length)) + post_window;

-- was  "launch_max_time_up <= (ARRAY3D (length) (cable_up) (3)) + post_window;"
	
launch_cnt_up_limit <= (ARRAY3D (length) (cable_up) (length - coin_ss_up)); -- Time in 40MHz clock counts that DOM is away	
launch_cnt_up_post_max <= (ARRAY3D (length) (cable_up) (length - coin_ss_up)) + post_window; --Maximum time from launch for post coinc 
launch_cnt_up_pre_min <= (ARRAY3D (length) (cable_up) (length - coin_ss_up)) - pre_window; -- Minimun time f

launch_cnt_down_post_max <= (ARRAY3D (length) (cable_down) (length - coin_ss_down)) + post_window;
launch_cnt_down_pre_min <= (ARRAY3D (length) (cable_down) (length - coin_ss_down)) - pre_window;
launch_cnt_down_limit <= (ARRAY3D (length) (cable_down) (length - coin_ss_down));

--got_p_down <= ((lc_wave_down_pos(5) and lc_wave_down_pos(4)) and lc_wave_down_neg(3) and lc_wave_down_neg(2)) or p_down;
--got_n_down <= ((lc_wave_down_pos(2) and lc_wave_down_pos(3)) and lc_wave_down_neg(4) and lc_wave_down_neg(5)) or n_down;
--got_extinguish_down <= (lc_wave_down_neg(5) and lc_wave_down_neg(4) and lc_wave_down_neg(3) and lc_wave_down_neg(2)) or extinguish_down;


--got_p_up <= ((lc_wave_up_pos(5) and lc_wave_up_pos(4)) and lc_wave_up_neg(3) and lc_wave_up_neg(2)) or p_up;
--got_n_up <= ((lc_wave_up_pos(2) and lc_wave_up_pos(3)) and lc_wave_up_neg(4) and lc_wave_up_neg(5)) or n_up;
--got_extinguish_up <= (lc_wave_up_neg(5) and lc_wave_up_neg(4) and lc_wave_up_neg(3) and lc_wave_up_neg(2)) or extinguish_up;

process(clk80,rst)
	variable nup,nupd,pup,pupd,ndown,ndownd,pdown,pdownd	: STD_LOGIC := '0';
begin
    if rst='1' then
    elsif clk80'event and clk80='1' then
    	pupd := pup;
	if (((wup_8 + wup_7 + wup_6 + wup_5) > 3) and ((wun_4 + wun_3 + wun_2 + wun_1) > 3)) or p_up = '1' then
		pup :='1';
	else
		pup:='0';
	end if;
	got_p_up <= pup or pupd;
	
	nupd := nup;
	if (((wun_8 + wun_7 + wun_6 + wun_5) > 3) and ((wup_4 + wup_3 + wup_2 + wup_1) > 2)) or n_up = '1' then
		nup := '1';
	else
	    	nup := '0';
	end if;
	got_n_up <= nup or nupd;
	
	
	pdownd := pdown;
	if (((wdp_8 + wdp_7 + wdp_6 + wdp_5) > 3) and ((wdn_4 + wdn_3 + wdn_2 + wdn_1) > 3)) or p_down = '1' then
		pdown := '1';
	else
		pdown := '0';
	end if;
	got_p_down <= pdown or pdownd;
	
	ndownd := ndown;
	if (((wdn_8 + wdn_7 + wdn_6 + wdn_5) > 3) and ((wdp_4 + wdp_3 + wdp_2 + wdp_1) > 2)) or n_down = '1' then
		ndown := '1';
	else
		ndown := '0';
	end if;
	got_n_down <= ndown or ndownd;
    end if;
end process;


got_launch <= (lc_daq_launch(0) and not launch_0_shift) or (lc_daq_launch(1) and not launch_1_shift);

got_launch_0 <= (lc_daq_launch(0) and not launch_0_shift); --generates leading edge of lc_launch(0)
got_launch_1 <= (lc_daq_launch(1) and not launch_1_shift); --generates leading edge of lc_launch(1)

lc_daq_trigger(0) <= got_p_down;
lc_daq_trigger(1) <= got_p_up;
	
got_hit <= (lc_daq_disc(0) and not LC_ctrl.LC_disc_source) or 
	(lc_daq_disc(1) and LC_ctrl.LC_disc_source);
	
	
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

lc_daq_abort(0) <= check_abort_0 and not(launch_ok_0) and lc_daq_launch(0);
lc_daq_abort(1) <= check_abort_1 and not(launch_ok_1) and lc_daq_launch(1);

temp_length(2) <= '0';
temp_length(1 downto 0) <= LC_ctrl.LC_length(1 downto 0);
push_length <= temp_length; --was "push_length <= temp_length + 1;"

--%post_end <= abort_post and (not abort_post_delay);
-- This process performs three funtions. It originates coincidence signals if the
-- DOM gets hit, it passes income coincidence signals, and it generates the outputs.
-- This process uses the detected start and stop coincidence signals to relay the 
-- coincidence signals from DOM to DOM. Each blank space between the start and stop
-- signals represents a DOM that is to be included in the coincidence. As the DOM 
-- passes the coincidence signal a blank space is removed. This occcurs in the 
-- "drop_1" state below. Eventually the signal is extinguished. 

-- If a hit comes in when a coincidence is being passed than the coincidence signal 
-- is stretched to what it would been if a hit orignated it. The total blank space is 
-- never more than the maximum for a hit unless the stop signal is missing. It this 
-- case a stop is force out after a watch_cnt times out.


local_coincidence_up: process (CLK20, RST)
begin	
	if RST = '1' then
		COINCIDENCE_OUT_UP <= 'Z';
		once_up <= '0';
		push_cnt_up <= (others => '0');
		watch_cnt_up <= (others => '0');
		wf_seq_up <= (others => '0');
		p_up_delay <= (others => '0');
		got_p_up_delay <= '0';
		n_up_delay <= (others => '0');
		got_n_up_delay <= '0';
		got_hit_bit_up <= '0';
		S_lc_up <= idle;
		
	elsif CLK20'event and CLK20 = '1' then
	
		if got_p_up = '1' or p_up_delay > 0 then
			p_up_delay <= p_up_delay + '1';
		end if;
	got_p_up_delay <= p_up_delay(1) and not p_up_delay(0) and LC_ctrl.LC_rx_enable(1);
		
		if got_n_up = '1' or n_up_delay > 0 then
			n_up_delay <= n_up_delay + '1';
		end if;
	got_n_up_delay <= n_up_delay(1) and not n_up_delay(0) and LC_ctrl.LC_rx_enable(1);
	
	case S_lc_up is
		when idle =>
			push_cnt_up <= (others => '0');
			watch_cnt_up <= (others => '0');	
			once_up <= '0';
			wf_seq_up <= (others => '0');
			got_hit_bit_up <= '0';
			if got_hit = '1' then
				if LC_ctrl.LC_tx_enable(0) = '1' then
				COINCIDENCE_OUT_UP <= '1'; --Beginning of start
				end if;
				push_cnt_up <= push_cnt_up + '1';
				S_lc_up <= hit_coin;
			elsif got_p_down_delay = '1' then
				--push_cnt_up <= push_cnt_up + '1';
				S_lc_up <= drop_1;
			else 	COINCIDENCE_OUT_UP <= 'Z';
				S_lc_up <= idle;
			end if;
			
		when drop_1 =>		--goes here when local coin comes in --///////////
			if got_hit = '1' then
				got_hit_bit_up <= '1';
			end if; 
			if got_hit = '1' and wf_seq_up = 0 then
				if LC_ctrl.LC_tx_enable(0) = '1' then
					COINCIDENCE_OUT_UP <= '1';
				end if;
				push_cnt_up <= push_cnt_up + '1';
				S_lc_up <= hit_coin;
			elsif got_n_down = '1' and wf_seq_up = 0 then
					S_lc_up <= idle;
			else		
				if LC_ctrl.LC_tx_enable(0) = '1' then
					wf_seq_up <= wf_seq_up + '1';
					if wf_seq_up = 0 or wf_seq_up = 1 then  -- finishing begin wave sequence
						COINCIDENCE_OUT_UP <= '1';
					elsif wf_seq_up = 2 then
						COINCIDENCE_OUT_UP <= '0';
						push_cnt_up <= push_cnt_up + '1';   
						watch_cnt_up <= watch_cnt_up + '1';
						S_lc_up <= out_end;
					end if;
				end if;
			end if;					--///////////
			
		when out_end =>
			if LC_ctrl.LC_tx_enable(0) = '1' and once_up = '0' then
				once_up <= '1';
				COINCIDENCE_OUT_UP <= '0';-- End of start
			else
				COINCIDENCE_OUT_UP <= 'Z';
			end if;
			if got_hit = '1' then
				got_hit_bit_up <= '1';
			end if; 
			watch_cnt_up <= watch_cnt_up + '1';
			--push_cnt_up <= push_cnt_up + '1';
			if (got_hit_bit_up = '1' or got_hit = '1') and once_up = '1' then
				wf_seq_up <= (others => '0');
				S_lc_up <= hit_coin;
			elsif got_n_down_delay = '1'then
				if LC_ctrl.LC_tx_enable(0) = '1' then
					COINCIDENCE_OUT_UP <= '0';-- Normal begining of stop for coin pass
					wf_seq_up <= (others => '0');
					S_lc_up <= finish;
				end if;
			elsif watch_cnt_up > 6 then
				if LC_ctrl.LC_tx_enable(0) = '1' then
					COINCIDENCE_OUT_UP <= '0';-- Forced stop is signal gets lost
					wf_seq_up <= (others => '0');
					S_lc_up <= finish;
				end if;
			else	
				S_lc_up <= out_end;
			end if;				
	
		
		when hit_coin =>	-- goes here when PMT got hit
			if LC_ctrl.LC_tx_enable(0) = '1' and once_up = '0' then
				wf_seq_up <= wf_seq_up + '1';
				if wf_seq_up = 0 then  -- finishing begin wave sequence
					COINCIDENCE_OUT_UP <= '1';
				elsif wf_seq_up = 1 or wf_seq_up = 2 then
					COINCIDENCE_OUT_UP <= '0';
				elsif wf_seq_up > 2 and push_cnt_up <= (push_length) then
					wf_seq_up <= (others => '0');
					once_up <= '1';
					COINCIDENCE_OUT_UP <= 'Z';
				elsif wf_seq_up > 2	then
					once_up <= '1';
					wf_seq_up <= "0001";
					COINCIDENCE_OUT_UP <= '0';
				end if;
				
			end if;
			if once_up = '1' then
				push_cnt_up <= push_cnt_up + '1';
			end if;					----??????
			if (push_cnt_up >= push_length) and (once_up = '1') and LC_ctrl.LC_tx_enable(0) = '1' then
				wf_seq_up <= wf_seq_up + '1';	
				if wf_seq_up = 0 or wf_seq_up = 1 then 	-- Normal begining of stop for hit pass
					COINCIDENCE_OUT_UP <= '0'; 	
				elsif wf_seq_up = 2 or wf_seq_up = 3 then
					COINCIDENCE_OUT_UP <= '1';  
				elsif wf_seq_up > 3 then
					COINCIDENCE_OUT_UP <= 'Z';
					S_lc_up <= idle; 
				else
					COINCIDENCE_OUT_UP <= 'Z';
				end if;
			end if; 
			if LC_ctrl.LC_tx_enable(0) = '0' then
				COINCIDENCE_OUT_UP <= 'Z'; 
				S_lc_up <= idle;
			end if;

		when finish =>
			wf_seq_up <= wf_seq_up + '1';	
			if wf_seq_up = 0 then 	-- Normal begining of stop for hit pass
				COINCIDENCE_OUT_UP <= '0'; 	
			elsif wf_seq_up = 1 or wf_seq_up = 2 then
				COINCIDENCE_OUT_UP <= '1';  
			elsif wf_seq_up > 2 then
				COINCIDENCE_OUT_UP <= 'Z';
				S_lc_up <= idle; 
			else
				COINCIDENCE_OUT_UP <= 'Z';
			end if;
		end case;
	end if;	
end process;

local_coincidence_down: process (CLK20, RST)
begin
	if RST = '1' then
		COINCIDENCE_OUT_DOWN <= 'Z';
		once_down <= '0';
		push_cnt_down <= (others => '0');
		watch_cnt_down <= (others => '0');
		wf_seq_down <= (others => '0');
		p_down_delay <= (others => '0');
		got_p_down_delay <= '0';
		n_down_delay <= (others => '0');
		got_n_down_delay <= '0';
		got_hit_bit_down <= '0';
		S_lc_down <= idle;
	elsif CLK20'event and CLK20 = '1' then
	
		if got_p_down = '1' or p_down_delay > 0 then
			p_down_delay <= p_down_delay + '1';
		end if;
	got_p_down_delay <= p_down_delay(1) and not p_down_delay(0) and LC_ctrl.LC_rx_enable(0);
		
		if got_n_down = '1' or n_down_delay > 0 then
			n_down_delay <= n_down_delay + '1';
		end if;
	got_n_down_delay <= n_down_delay(1) and not n_down_delay(0) and LC_ctrl.LC_rx_enable(0);
	
	case S_lc_down is
		when idle =>
			push_cnt_down <= (others => '0');
			watch_cnt_down <= (others => '0');
			once_down <= '0';
			wf_seq_down <= (others => '0');
			got_hit_bit_down <= '0';
			if got_hit = '1' then
				if LC_ctrl.LC_tx_enable(1) = '1' then
				COINCIDENCE_OUT_DOWN <= '1'; --Beginning of start
				end if;
				push_cnt_down <= push_cnt_down + '1';
				S_lc_down <= hit_coin;
			elsif got_p_up_delay = '1' then
				--push_cnt_down <= push_cnt_down + '1';
				S_lc_down <= drop_1;
			else 	COINCIDENCE_OUT_DOWN <= 'Z';
				S_lc_down <= idle;
			end if;
			
		when drop_1 =>		--goes here when local coin comes in
			if got_hit = '1' then
				got_hit_bit_down <= '1';
			end if; 
			if got_hit = '1' and wf_seq_down = 0 then
				if LC_ctrl.LC_tx_enable(1) = '1' then
					COINCIDENCE_OUT_DOWN <= '1';
				end if;
				push_cnt_down <= push_cnt_down + '1';
				S_lc_down <= hit_coin;
			elsif got_n_up = '1' and wf_seq_down = 0 then --or got_extinguish_up = '1'
					S_lc_down <= idle;
			else				
				if LC_ctrl.LC_tx_enable(1) = '1' then
					wf_seq_down <= wf_seq_down + '1';
					if wf_seq_down = 0 or wf_seq_down = 1 then  -- finishing begin wave sequence
						COINCIDENCE_OUT_DOWN <= '1';
					elsif wf_seq_down = 2 then
						COINCIDENCE_OUT_DOWN <= '0';
						push_cnt_down <= push_cnt_down + '1';   
						watch_cnt_down <= watch_cnt_down + '1';
						S_lc_down <= out_end;
					end if;
				end if;
			end if;
			
		when out_end =>
			if LC_ctrl.LC_tx_enable(1) = '1' and once_down = '0' then
				once_down <= '1';
				COINCIDENCE_OUT_DOWN <= '0';-- End of start
			else
				COINCIDENCE_OUT_DOWN <= 'Z';
			end if;
			if got_hit = '1' then
				got_hit_bit_down <= '1';
			end if; 
			watch_cnt_down <= watch_cnt_down + '1';
			--push_cnt_down <= push_cnt_down + '1';
			if (got_hit_bit_down = '1' or got_hit = '1')and once_down = '1' then
				wf_seq_down <= (others => '0');
				S_lc_down <= hit_coin;
			elsif got_n_up_delay = '1' then
				if LC_ctrl.LC_tx_enable(1) = '1' then
					COINCIDENCE_OUT_DOWN <= '0';-- Normal begining of stop for coin pass
					wf_seq_down <= (others => '0');
					S_lc_down <= finish;
				end if;
			elsif watch_cnt_down > 6 then
				if LC_ctrl.LC_tx_enable(1) = '1' then
					COINCIDENCE_OUT_DOWN <= '0';-- Forced stop is signal gets lost
					wf_seq_down <= (others => '0');
					S_lc_down <= finish;
				end if;
			else	
				S_lc_down <= out_end;
			end if;				
		
		when hit_coin =>	-- goes here when PMT got hit
			if LC_ctrl.LC_tx_enable(1) = '1' and once_down = '0' then
				wf_seq_down <= wf_seq_down + '1';
				if wf_seq_down = 0 then  -- finishing begin wave sequence
					COINCIDENCE_OUT_DOWN <= '1';
				elsif wf_seq_down = 1 or wf_seq_down = 2 then
					COINCIDENCE_OUT_DOWN <= '0';
				elsif wf_seq_down > 2 and push_cnt_down <= (push_length) then
					wf_seq_down <= (others => '0');
					once_down <= '1';
					COINCIDENCE_OUT_DOWN <= 'Z';
				elsif wf_seq_down > 2 then
					once_down <= '1';
					wf_seq_down <= "0001";
					COINCIDENCE_OUT_DOWN <= '0';							
				end if;
			end if;
			if once_down = '1' then
				push_cnt_down <= push_cnt_down + '1';
			end if;					----??????
			if (push_cnt_down >= push_length) and (once_down = '1') and LC_ctrl.LC_tx_enable(1) = '1' then
				wf_seq_down <= wf_seq_down + '1';	
				if wf_seq_down = 0 or wf_seq_down = 1 then 	-- Normal begining of stop for hit pass
					COINCIDENCE_OUT_DOWN <= '0'; 	
				elsif wf_seq_down = 2 or wf_seq_down = 3 then
					COINCIDENCE_OUT_DOWN <= '1';  
				elsif wf_seq_down > 3 then
					COINCIDENCE_OUT_DOWN <= 'Z';
					S_lc_down <= idle; 
				else
					COINCIDENCE_OUT_DOWN <= 'Z';
				end if;
			end if; 
			if LC_ctrl.LC_tx_enable(1) = '0' then
				COINCIDENCE_OUT_DOWN <= 'Z'; 
				S_lc_down <= idle;
			end if;
		when finish =>
			wf_seq_down <= wf_seq_down + '1';	
			if wf_seq_down = 0 then 	-- Normal begining of stop for hit pass
				COINCIDENCE_OUT_DOWN <= '0'; 	
			elsif wf_seq_down = 1 or wf_seq_down = 2 then
				COINCIDENCE_OUT_DOWN <= '1';  
			elsif wf_seq_down > 2 then
				COINCIDENCE_OUT_DOWN <= 'Z';
				S_lc_down <= idle; 
			else
				COINCIDENCE_OUT_DOWN <= 'Z';
			end if;
		end case;
	end if;	
end process;

---do_start_down <= '1' WHEN S_lc_down=drop_1 ELSE '0';


-- This process identifies the start and stop waveforms coming in the coincidence cable. 
-- The idle state of the incoming signal is tri-state. A start of coincidence is a two 
-- 40 MHz cycle wide '1' pulse followed by a two 40MHz cycle wide '0' pulse. The stop is 
-- the reverse polarity, that is a '0' followed by a '1'
-- The start and stop are identified by shifting the incoming coincidence waveform into 
-- a shift register a looking for pattern with the individual bits of the shift register.
-- 80MHz is used by the shift register to allow 8 samples of the start and stop. If 3 of 
-- the 4 '1' samples and 3 of the 4 '0' samples are received then the start / stop are
-- valid. There are two process, one for the up coincidence.and another for the down coincidence.


lc_wave_down: process (CLK80, RST,LC_ctrl.LC_rx_enable(1))  --use clock 80MHz
begin
	if LC_ctrl.LC_rx_enable(1)= '0' then
		null;
	elsif RST = '1' then
		lc_wave_down_pos <= (others => '0');
		lc_wave_down_neg <= (others => '0');
	elsif CLK80'event and CLK80 = '1' then
	
	--used to stretch got_p_down and got_n_down signals so they are one 40MHz cycle wide	
	if  ((wdp_8 + wdp_7 + wdp_6 + wdp_5) > 3) and  ((wdn_4 + wdn_3 + wdn_2 + wdn_1) > 3) then --!!!
		p_down <= '1';
	else
		p_down <= '0';
	end if;	
	
	if  ((wdn_8 + wdn_7 + wdn_6 + wdn_5) > 3) and  ((wdp_4 + wdp_3 + wdp_2 + wdp_1) > 2) then --!!!
		n_down <= '1';
	else
		n_down <= '0';
	end if;	

		--!!CAL_CHANGE!!--if LC_ctrl.LC_rx_enable(1)='1' then 
			lc_wave_down_pos(0) <=  COINC_DOWN_A;
			lc_wave_down_pos(15 downto 1) <= lc_wave_down_pos(14 downto 0);
			lc_wave_down_neg(0) <=  COINC_DOWN_B;
			lc_wave_down_neg(15 downto 1) <= lc_wave_down_neg(14 downto 0);		
	--p_down <= (lc_wave_down_pos(5) and lc_wave_down_pos(4)) and lc_wave_down_neg(3) and lc_wave_down_neg(2);
	--n_down <= (lc_wave_down_pos(2) and lc_wave_down_pos(3)) and lc_wave_down_neg(4) and lc_wave_down_neg(5);
	extinguish_down <= lc_wave_down_neg(5) and lc_wave_down_neg(4) and lc_wave_down_neg(3) and lc_wave_down_neg(2);
	end if;
end process;

lc_wave_up: process (CLK80, RST,LC_ctrl.LC_rx_enable(0))  --use clock 80MHz
begin
	if LC_ctrl.LC_rx_enable(0)= '0' then
		null;
	elsif RST = '1' then
		lc_wave_up_pos <= (others => '0');
		lc_wave_up_neg <= (others => '0');
	elsif CLK80'event and CLK80 = '1' then

	--used to stretch got_p_up and got_n_up signals so they are one 40MHz cycle wide	
	if  (wup_8 + wup_7 + wup_6 + wup_5) > 3 and  (wun_4 + wun_3 + wun_2 + wun_1) > 3 then --!!!
		p_up <= '1';
	else
		p_up <= '0';
	end if;	
	
	if  (wun_8 + wun_7 + wun_6 + wun_5) > 3 and  (wup_4 + wup_3 + wup_2 + wup_1) > 2  then --!!!
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
	--p_up <= (lc_wave_up_pos(5) and lc_wave_up_pos(4)) and lc_wave_up_neg(3) and lc_wave_up_neg(2);
	--n_up <= (lc_wave_up_pos(2) and lc_wave_up_pos(3)) and lc_wave_up_neg(4) and lc_wave_up_neg(5);
	extinguish_up <= lc_wave_up_neg(5) and lc_wave_up_neg(4) and lc_wave_up_neg(3) and lc_wave_up_neg(2);
	end if;
	
end process;

-- This process measures the number of 40MHz clock cycles between the start and stop of the incoming 
-- local coincidence. This is used to determine how far away the coincidence occured. The number of 
-- number of DOMs used in local coincidence minus this number, "length - cnt_ss_...", is how many 
-- DOMs away the coincidense occured. This is used to look up the time it took for the local coincidence
-- to arrive at the DOM.

cnt_start_stop_up: process (CLK80, RST) --measures length of coin signal in
begin
	if RST = '1' then
		cnt_ss_up <= "000000"; -- need to start at 12 because of 4 count offset
		cnt_ss_up_done <= '0';
	elsif CLK80'event and CLK80 = '1' then
		if got_n_up = '1' then
			cnt_ss_up_done <= '1';
		elsif cnt_ss_up_done = '0' and (got_p_up = '1' or cnt_ss_up /= 12)  then
			cnt_ss_up <= cnt_ss_up + '1';
		elsif cnt_ss_up_done = '1' then-- 9/2/04 was "elsif launch_cnt_end_up = '1' then"
			cnt_ss_up <= "000000"; -- need to start at 12 because of 4 cout offset
			cnt_ss_up_done <= '0';	
		end if;
	end if;
end process cnt_start_stop_up;

cnt_start_stop_down: process (CLK80, RST) --measures length of coin signal in
begin
	if RST = '1' then
		cnt_ss_down <= "000000"; -- need to start at 12 because of 4 count offset
		cnt_ss_down_done <= '0';
	elsif CLK80'event and CLK80 = '1' then
		if got_n_down = '1' then
			cnt_ss_down_done <= '1';
		elsif cnt_ss_down_done = '0' and (got_p_down = '1' or cnt_ss_down /= 12)  then
			cnt_ss_down <= cnt_ss_down + '1';
		elsif cnt_ss_down_done = '1' then-- 9/2/04 was "elsif launch_cnt_end_down = '1' then"
			cnt_ss_down <= "000000"; -- need to start at 12 because of 4 count offset
			cnt_ss_down_done <= '0';
		end if;
	end if;
end process cnt_start_stop_down;
-- This process times the relative time of the launch of an ATWD
-- A launch counter starts with the launch of an ATWD and continues until a maximum count is reached.
-- The maximum count is a variable that depends on the number of DOMs in a coincidence. The greater 
-- the number of DOMs then the further away the DOM could be which satisfies coincidence and the 
-- greater the maximum count of the launch timer is. There is a unique launch counter for the up and 
-- down direction of the incoming coincidences. This is required do to the different cable lengths 
-- used. (The alternating long and short cables.) Both launch counters start with the launch of the 
-- ATWD. However they have unique maximum count values, stopping points. When any coincidence comes in 
-- the launch count in this counter is compared to a count that equals the number of clocks away that 
-- the DOM is in which coincidence occured. When the maximum count is reached a launch_cnt_end signal
-- is set to a '1'. At this time the abort signal is determined.

--If this launch count is within the pre & post window of 
-- the number of clocks away then coincidence is satisfied and an "ok_up" or "ok_down" bit is set to 
-- '1' depending on if the coincidence was from a DOM above or below. 

launch_timer_down: process (CLK40, RST)
begin
	if RST = '1' then
		launch_cnt_down <= (others => '0');
		launch_cnt_end_down <= '0';
	elsif CLK40'event and CLK40 = '1' then
		if got_launch = '1'  or (launch_cnt_down > 0  and launch_cnt_down < launch_max_time_down) then
			launch_cnt_down <= launch_cnt_down + '1';
			launch_cnt_end_down <= '0';
		elsif launch_cnt_down >= launch_max_time_down then
			launch_cnt_end_down <= '1';
			launch_cnt_down <= (others => '0');
		else
			launch_cnt_end_down <= '0';
		end if;
	end if;
end process launch_timer_down;

--~~	elsif CLK40'event and CLK40 = '1' then
--~~		if got_launch = '1'  or (launch_cnt_down > 0  and launch_cnt_down < launch_max_time_down and launch_cnt_end_down = '0') then --9/2/04 "got_launch" was "got_hit"
--~~			launch_cnt_down <= launch_cnt_down + '1';
--~~		end if;
--~~		if launch_cnt_down > 0 and (got_n_down = '1' or launch_cnt_down >= launch_max_time_down) then --If got_n_down then counter has valid total delay
--~~			launch_cnt_end_down <= '1';
--~~		elsif launch_cnt_end_down = '1' then
--~~			launch_cnt_down <= (others => '0');
--~~			launch_cnt_end_down <= '0';
--~~		end if;
--~~	end if;
--~~end process launch_timer_down;

launch_timer_up: process (CLK40, RST)
begin
	if RST = '1' then
		--launch_cnt_up <= CONV_STD_LOGIC_VECTOR(-64, 8);
		launch_cnt_up <= (others => '0');
		launch_cnt_end_up <= '0';
	elsif CLK40'event and CLK40 = '1' then
		if got_launch = '1'  or (launch_cnt_up > 0  and launch_cnt_up < launch_max_time_up) then
			launch_cnt_up <= launch_cnt_up + '1';
			launch_cnt_end_up <= '0';
		elsif launch_cnt_up >= launch_max_time_up then
			launch_cnt_end_up <= '1';
			launch_cnt_up <= (others => '0');
		else
			launch_cnt_end_up <= '0';
		end if;
	end if;
end process launch_timer_up;

-- The pre_window range can exceed the cable delays. In this situation the "launch_cnt_up_pre_min" 
-- is negative. In other words a Local coincidence that can qualify a launch arrives at the DOM 
-- before the launch. In order to recover the interval of time before a valid launch occurs a 
-- "pre_window_cnt_up" is loaded with this negative "launch_cnt_up_pre_min" and if a launch occurs
-- before this count goes postive the "ok_up" bit is set which validated the launch.
pre_window_neg_up: process (CLK40, RST)
begin
	if RST = '1' then
		pre_window_cnt_up <= 1;
	elsif CLK40'event and CLK40 = '1' then
		if got_n_up = '1' and launch_cnt_up_pre_min <= 0 then
			pre_window_cnt_up <=launch_cnt_up_pre_min;
		elsif pre_window_cnt_up < 1 then
			pre_window_cnt_up <= pre_window_cnt_up + 1;
		end if;
	end if;
end process pre_window_neg_up;

pre_window_neg_down: process (CLK40, RST)
begin
	if RST = '1' then
		pre_window_cnt_down <= 1;
	elsif CLK40'event and CLK40 = '1' then
		if got_n_down = '1' and launch_cnt_down_pre_min <= 0 then
			pre_window_cnt_down <=launch_cnt_down_pre_min;
		elsif pre_window_cnt_down < 1 then
			pre_window_cnt_down <= pre_window_cnt_down + 1;
		end if;
	end if;
end process pre_window_neg_down;

-- A launch counter starts with the launch of an ATWD and continues until a maximum count is reached.
-- The maximum count is a variable that depends on the number of DOMs in a coincidence. The greater 
-- the number of DOMs then the further away the DOM could be which satisfies coincidence and the 
-- greater the maximum count of the launch timer is. At any time that the launch counter is counting 
-- incoming coincidences from neighboring DOMs are checked against pre and post count values that 
-- make up the window. As the launch counter is incrementing to its maximum value any incoming 
-- coincidences which satisfy the pre or post windows set an "ok" bit. This bit is cleared only after
-- the launch counter reaches its maximum count. At this time the abort conditon is checked for this 
-- particular launch and the "ok" bit is reset and ready for the next launch.

check_coin_window_down: process (CLK40, RST)
begin
	if RST = '1' then
		ok_down <= '0';
	elsif CLK40'event and CLK40 = '1' then
		if lc_daq_launch /= "00" and got_n_down = '1' then
			if (CONV_INTEGER(launch_cnt_down) < launch_cnt_down_post_max and CONV_INTEGER(launch_cnt_down) >= launch_cnt_down_limit)
			or ((launch_cnt_down_pre_min > 0 and CONV_INTEGER(launch_cnt_down) > launch_cnt_down_pre_min) and CONV_INTEGER(launch_cnt_down) <= launch_cnt_down_limit) then
				ok_down <= '1';	--set here reset at ent of launch_cnt
			--elsif ((launch_cnt_down_pre_min <= 0 and CONV_INTEGER(launch_cnt_down) > 0) and CONV_INTEGER(launch_cnt_down) <= launch_cnt_down_limit) then
			elsif ((launch_cnt_down_pre_min <= 0 and (got_launch = '1' or CONV_INTEGER(launch_cnt_down) > 0)) and CONV_INTEGER(launch_cnt_down) <= launch_cnt_down_limit) then	
				ok_down <= '1';	
			elsif launch_cnt_end_down = '1' then
		 		ok_down <= '0';
		 	end if;
		elsif pre_window_cnt_down<= 0 and got_launch = '1'  then
			ok_down <= '1';
		else
			ok_down <= '0';
		end if;
	end if;
end process check_coin_window_down;	

check_coin_window_up: process (CLK40, RST)--copied form above
begin
	if RST = '1' then
		ok_up <= '0';
	elsif CLK40'event and CLK40 = '1' then
		if lc_daq_launch /= "00" and got_n_up = '1' then
			if (CONV_INTEGER(launch_cnt_up) < launch_cnt_up_post_max and CONV_INTEGER(launch_cnt_up) >= launch_cnt_up_limit)
			or ((launch_cnt_up_pre_min > 0 and CONV_INTEGER(launch_cnt_up) > launch_cnt_up_pre_min) and  CONV_INTEGER(launch_cnt_up) <= launch_cnt_up_limit) then
				ok_up <= '1';	
			--elsif ((launch_cnt_up_pre_min <= 0 and CONV_INTEGER(launch_cnt_up) > 0) and CONV_INTEGER(launch_cnt_up) <= launch_cnt_up_limit) then
			elsif ((launch_cnt_up_pre_min <= 0 and (got_launch = '1' or CONV_INTEGER(launch_cnt_up) > 0)) and CONV_INTEGER(launch_cnt_up) <= launch_cnt_up_limit) then
				ok_up <= '1';	
			elsif launch_cnt_end_up = '1' then
		 		ok_up <= '0';
		 	end if;	
		elsif pre_window_cnt_up <= 0 and got_launch = '1'  then
			ok_up <= '1';	
		else
			ok_up <= '0';
		end if;
	end if;
end process check_coin_window_up;

launch_edge: process (CLK40, RST)
begin
	if RST = '1' then
		launch_0_shift <= '0';	
		launch_1_shift <= '0';	
	elsif CLK40'event and CLK40 = '1' then
		launch_0_shift <= lc_daq_launch(0);
		launch_1_shift <= lc_daq_launch(1);
	end if;
end process launch_edge;

-- This process generates the abort signal. There are two of these processes, one for each ATWD.
-- Either an up or down coincidence can validate a launch. This process waits for the both the up and
-- and the down launch counters to time out. That is launch_cnt_end_up = '1' and launch_cnt_end_down = '1'
-- because the counters time out at different times and the launch_end bits are narrow additional signals
-- are used to save the end of the up and down counters. These signals are check_end_up_0 and check_end_down_0
-- After they both timed out, "check_end_up_0 = '1' and check_end_down_0 = '1'" if either "ok_up" or
-- "ok_down" are '1' then coincidence is satisfied.

launch_end_0: process (CLK40, RST)-- waits for up and down windows to end before "check_abort_0 = 1"
begin
	if RST = '1' then
		check_end_up_0 <= '0';
		check_end_down_0 <= '0';
		check_abort_0 <= '0';
		launch_ok_0 <= '0';
	elsif CLK40'event and CLK40 = '1' then
		if lc_daq_launch(0) = '0' or check_abort_0 = '1' then
			check_end_up_0 <= '0';
			check_end_down_0 <= '0';
			check_abort_0 <= '0';
			launch_ok_0 <= '0';
		elsif lc_daq_launch(0)= '1' then
			if launch_cnt_end_up = '1' then
				check_end_up_0 <= '1';
			end if;
			if launch_cnt_end_down = '1' then
				check_end_down_0 <= '1';
			end if;
			if check_end_up_0 = '1' and check_end_down_0 = '1' then
				check_abort_0 <= '1'; --once this is '1' there's no more chance to satisfy coinc
			end if;
			if (ok_up = '1' or ok_down = '1') and check_abort_0 = '0' then
				launch_ok_0 <= '1';
			elsif check_abort_0 = '1' then
				launch_ok_0 <= '0';
			end if; 
		end if;
	end if;
end process launch_end_0;

launch_end_1: process (CLK40, RST)
begin
	if RST = '1' then
		check_end_up_1 <= '0';
		check_end_down_1 <= '0';
		check_abort_1 <= '0';
		launch_ok_1 <= '0';
	elsif CLK40'event and CLK40 = '1' then
		if lc_daq_launch(1) = '0' or check_abort_1 = '1' then
			check_end_up_1 <= '0';
			check_end_down_1 <= '0';
			check_abort_1 <= '0';
			launch_ok_1 <= '0';
		elsif lc_daq_launch(1)= '1' then
			if launch_cnt_end_up = '1' then
				check_end_up_1 <= '1';
			end if;
			if launch_cnt_end_down = '1' then
				check_end_down_1 <= '1';
			end if;
			if check_end_up_1 = '1' and check_end_down_1 = '1' then
				check_abort_1 <= '1'; --once this is '1' there's no more chance to satisfy coinc
			end if;
			if (ok_up = '1' or ok_down = '1') and check_abort_1 = '0' then
				launch_ok_1 <= '1';
			elsif check_abort_1 = '1' then
				launch_ok_1 <= '0';
			end if; 
		end if;
	end if;
end process launch_end_1;
		

  -- <statements>
end ARCH_local_coincidence;


