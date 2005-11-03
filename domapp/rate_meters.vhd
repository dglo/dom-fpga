-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : rate_meters.vhd
-- Author     : yaver/thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-07-29
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module measures the hit rates for MPEs, SPEs, and SNs. SN  
--              data is output as a 32 bit word. The 16 MSBs is the time stamp 
--              and the lower 16 bits contain four consecutive 4 bit rates. The
--              lowest 4 bit is the earliest rate and so on.
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-10-23  V01-01-00   yaver/thorsten  
-------------------------------------------------------------------------------
LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
LIBRARY WORK;
USE WORK.ctrl_data_types.ALL;


ENTITY rate_meters IS
    PORT (
        -- Common Inputs
        CLK20          : IN  STD_LOGIC;
        CLK40          : IN  STD_LOGIC;
        RST            : IN  STD_LOGIC;
        systime        : IN  STD_LOGIC_VECTOR (47 DOWNTO 0); --&&&
        -- slaveregister
        RM_ctrl        : IN  RM_CTRL_STRUCT;
        RM_stat        : OUT RM_STAT_STRUCT;
        -- DAQ interface
        RM_daq_disc    : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- test
        TC             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END rate_meters;

architecture ARCH_rate_meters of rate_meters is

CONSTANT one_second  : INTEGER := (67108864 - 20000000 + 1); -- Counting up from this value 26th bit changes to 1


signal RM_rate_update : STD_LOGIC;
signal RM_rate_SPE    : STD_LOGIC_VECTOR (31 DOWNTO 0);
signal RM_rate_MPE    : STD_LOGIC_VECTOR (31 DOWNTO 0);
signal RM_sn_data	  : STD_LOGIC_VECTOR (31 DOWNTO 0);
signal sn_rate_update : STD_LOGIC;


--signal SPE_disc : STD_LOGIC;
signal rate_MPE_int 	: STD_LOGIC_VECTOR(31 downto 0);
signal rate_SPE_int 	: STD_LOGIC_VECTOR(31 downto 0);
signal rate_dead_int	: STD_LOGIC_VECTOR(10 downto 0);
signal lockout_MPE	: STD_LOGIC_VECTOR(9 downto 0);
signal lockout_SPE	: STD_LOGIC_VECTOR(9 downto 0);
signal second_cnt	: STD_LOGIC_VECTOR(26 downto 0);


signal delay_bit 	: STD_LOGIC;
signal lockout_sn 	: STD_LOGIC_VECTOR(8 downto 0);
signal RM_sn_data_int	: STD_LOGIC_VECTOR(31 downto 0);
signal sn_dead_int 	: STD_LOGIC_VECTOR(8 downto 0);
signal sn_rate 		: STD_LOGIC_VECTOR(3 downto 0);
--signal sn_rate_update : STD_LOGIC;
signal sn_t_cnt 	: STD_LOGIC_VECTOR(1 downto 0);
--signal sn_rate_vector : STD_LOGIC_VECTOR(31 downto 0);

--signal systime : STD_LOGIC_VECTOR(47 downto 0);

	-- stretch the RM_daq_disc signal to run the processes at 20MHz
	SIGNAL RM_daq_disc_20MHz	: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL RM_daq_disc_old		: STD_LOGIC_VECTOR (1 DOWNTO 0);

begin

RM_stat.RM_rate_update	<= RM_rate_update;
RM_stat.RM_rate_SPE		<= RM_rate_SPE;
RM_stat.RM_rate_MPE		<= RM_rate_MPE;
RM_stat.RM_sn_data		<= RM_sn_data;
RM_stat.sn_rate_update	<= sn_rate_update;



rate_dead_int(10 downto 1) <= RM_ctrl.RM_rate_dead(9 downto 0); --multiply dead time by 2 for 100ns intervals
rate_dead_int(0) <= '0';

sn_dead_int(8) <= '0';
sn_dead_int(7 downto 5) <= RM_ctrl.RM_sn_dead; ---&&& was (2 downto 0)
sn_dead_int(4 downto 0) <= "00000"; ---&&&

	PROCESS (CLK40, RST)
	BEGIN
		IF RST='1' THEN
			RM_daq_disc_old	<= "00";
		ELSIF CLK40'EVENT AND CLK40='1' THEN
			RM_daq_disc_old	<= RM_daq_disc;
		END IF;
	END PROCESS;
	RM_daq_disc_20MHz	<= RM_daq_disc OR RM_daq_disc_old;


rate_meters_machine: process (CLK20, RST)
begin
--conv_std_logic_vector (one_second,27);
	if RST = '1' then
		RM_rate_update <= '0';
		RM_rate_SPE <= (others => '0');
		rate_SPE_int <= (others => '0');
		lockout_SPE <= (others => '0');
		RM_rate_MPE <= (others => '0');
		rate_MPE_int <= (others => '0');
		lockout_MPE <= (others => '0');
		RM_sn_data <= (others => '0');
		TC <= (others => '0'); 
		--#second_cnt <= (others => '0');
		
		second_cnt <= conv_std_logic_vector (one_second,27);
		--delay_bit <= '0';
		lockout_sn  <= (others => '0');
--		sn_dead_int <= (others => '0');
		sn_rate  <= (others => '0');
		sn_rate_update <= '0';
		sn_t_cnt <= (others => '0');
		RM_sn_data_int <= (others => '0');
		--systime  <= (others => '0'); --&&&
		
		
	elsif CLK20'event and CLK20 = '1' then
	
		--systime  <= systime + 1; --&&&
		delay_bit <= systime(15);---&&& was systime(4)
	
		if RM_ctrl.RM_rate_enable(0) = '1' or RM_ctrl.RM_rate_enable(1) = '1' then
			second_cnt <= second_cnt + '1';
		else
			second_cnt <= conv_std_logic_vector (one_second,27);
		end if;
		
		if  second_cnt(26) = '1' then --Decimal 67108864 turns to one every second
		--was [if  second_cnt = 20000000 then]
		
			RM_rate_update <= '1';
			second_cnt <= conv_std_logic_vector (one_second,27);
			
			if RM_ctrl.RM_rate_enable(1) = '1' then  --MPE triggers at 1 second intervals
			RM_rate_MPE <= rate_MPE_int;
			--lockout_MPE <= (others => '0'); good for simulation stops odd/even effect
			rate_MPE_int <= (others => '0');
			end if;
			
			if RM_ctrl.RM_rate_enable(0) = '1' then  --SPE triggers at 1 second intervals
			RM_rate_SPE <= rate_SPE_int;
			--lockout_SPE <= (others => '0'); good for simulation stops odd/even effect
			rate_SPE_int <= (others => '0');
			end if;
			
		else
			RM_rate_update <= '0';
			
			if RM_ctrl.RM_rate_enable(1) = '1' and RM_daq_disc_20MHz(1) = '1' and lockout_MPE = 0 then
				rate_MPE_int <= rate_MPE_int + '1';
			end if;
		
			if RM_ctrl.RM_rate_enable(1) = '1' and (lockout_MPE > 0 or RM_daq_disc_20MHz(1) = '1') and lockout_MPE < rate_dead_int then 
				lockout_MPE <= lockout_MPE + '1';
			elsif RM_ctrl.RM_rate_enable(1) = '0' or lockout_MPE >= rate_dead_int then
				lockout_MPE <= (others => '0');
			end if;
			
			if RM_ctrl.RM_rate_enable(0) = '1' and RM_daq_disc_20MHz(0) = '1' and lockout_SPE = 0 then
				rate_SPE_int <= rate_SPE_int + '1';
			end if;
			
			--if RM_daq_disc_20MHz(0) = '1' and lockout_SPE < rate_dead_int then
			--	SPE_disc <= '1';
			--elsif lockout_MPE >=  rate_dead_int then
			--	SPE_disc <= '0';
			--end if;
		
			if RM_ctrl.RM_rate_enable(0) = '1' and (lockout_SPE > 0 or RM_daq_disc_20MHz(0) = '1') and lockout_SPE < rate_dead_int then 
				lockout_SPE <= lockout_SPE + '1';
			elsif RM_ctrl.RM_rate_enable(0) = '0' or lockout_SPE >= rate_dead_int then
				lockout_SPE <= (others => '0');
			end if;
			
			
		end if;	
			
		sn_rate_update <=not systime(15) and delay_bit and sn_t_cnt(0) and sn_t_cnt(1);---&&& was systime(15)
		
		if systime(15) = '0' and delay_bit = '1' then  ---&&& was systime(4)
			sn_t_cnt <= sn_t_cnt + '1';
			--lockout_SN <= (others => '0');
			if sn_t_cnt = 0 then
				RM_sn_data_int(31 downto 16) <= systime(31 downto 16);
				RM_sn_data_int(3 downto 0) <= sn_rate;
				sn_rate <= (others => '0');
			end if;
			if sn_t_cnt = 1 then
				RM_sn_data_int(7 downto 4) <= sn_rate;
				sn_rate <= (others => '0');
			end if;
			if sn_t_cnt = 2 then
				RM_sn_data_int(11 downto 8) <= sn_rate;
				sn_rate <= (others => '0');
			end if;
			if sn_t_cnt = 3 then
				RM_sn_data(15 downto 12) <= sn_rate;
				RM_sn_data(31 downto 16) <= RM_sn_data_int(31 downto 16);
				RM_sn_data(11 downto 0) <= RM_sn_data_int(11 downto 0);
				sn_rate <= (others => '0');
			end if;
		else 
			if (RM_ctrl.RM_sn_enable = "01" and (lockout_SN > 0 or RM_daq_disc_20MHz(0) = '1') and lockout_SN <= sn_dead_int) or
			   (RM_ctrl.RM_sn_enable = "10" and (lockout_SN > 0 or RM_daq_disc_20MHz(1) = '1') and lockout_SN <= sn_dead_int) 
				then 
				lockout_SN <= lockout_SN + '1';
			elsif
				RM_ctrl.RM_sn_enable(0) = '0' or RM_ctrl.RM_sn_enable(1) = '0' or lockout_SN >= sn_dead_int then
				lockout_SN <= (others => '0');
			end if;
			 	
			if ((RM_ctrl.RM_sn_enable = "10" and RM_daq_disc_20MHz(1) = '1') or (RM_ctrl.RM_sn_enable = "01" and RM_daq_disc_20MHz(0) = '1')) and lockout_SN = 0 and sn_rate < 15 then
				sn_rate <= sn_rate + '1';
			elsif RM_ctrl.RM_sn_enable = "00" then
				sn_rate <= (others => '0');
			end if;			
		end if;
	end if;
			
end process;
				
  -- <statements>
end ARCH_rate_meters;




