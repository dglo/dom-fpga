-- Harolds code
-- ADD HEADER !!!!!

-- 11/30/2004  thorsten   changed CPU forced to flash on cs_ctrl.CS_CPU


LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
LIBRARY WORK;

USE WORK.ctrl_data_types.ALL;

ENTITY calibration_sources IS
    PORT (
        -- Common Inputs
        CLK20		: IN  STD_LOGIC;
        CLK40		: IN  STD_LOGIC;
        RST		: IN  STD_LOGIC;
        systime : IN  STD_LOGIC_VECTOR (47 DOWNTO 0); --&&&
        -- slaveregister
        cs_ctrl		: CS_STRUCT;
        cs_wf_data	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        cs_wf_addr	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        cs_flash_now	: OUT STD_LOGIC;
        cs_flash_time	: OUT STD_LOGIC_VECTOR (47 DOWNTO 0);
        --cs_enable	: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        --cs_mode		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        --cs_time		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        --cs_rate		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
	--cs_offset	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	--cs_cpu		: IN STD_LOGIC;
	--cs_fl_aux_reset	: IN STD_LOGIC;
	
        -- DAQ interface
        cs_daq_trigger	: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
        cs_daq_veto	: IN STD_LOGIC;
        -- I/O
        SingleLED_Trigger: OUT STD_LOGIC;
        FE_TEST_PULSE	: OUT STD_LOGIC;
        R2BUS		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        FE_PULSER_P	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        FE_PULSER_N	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        
        FL_Trigger	: OUT STD_LOGIC;
        FL_Trigger_bar	: OUT STD_LOGIC;
        FL_ATTN		: IN STD_LOGIC;
        FL_AUX_RESET	: OUT STD_LOGIC;
        --test
        TC		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END calibration_sources;

architecture ARCH_calibration_sources of calibration_sources is

signal ATWD_R2R : STD_LOGIC;

signal cs_time_start	: STD_LOGIC;
signal cs_wf_addr_int	: STD_LOGIC_VECTOR(7 downto 0);
signal CPU_forced_start	: STD_LOGIC;
signal fe_R2R		: STD_LOGIC; 

signal stretcher	: STD_LOGIC_VECTOR(4 downto 0);
signal flasher_board_out: STD_LOGIC;

signal led_out		: STD_LOGIC;
signal now		: STD_LOGIC;
signal now_action	: STD_LOGIC;
signal now_cs_trig	: STD_LOGIC;
signal now_cnt		: STD_LOGIC_VECTOR(3 downto 0);
signal rate_bit		: STD_LOGIC;
signal delay_bit	: STD_LOGIC;

--signal systime : STD_LOGIC_VECTOR(47 downto 0);  --&&&

begin

-- concurrent signals assignments
rate_bit <= systime(25 - conv_integer(CS_ctrl.CS_rate)); -- selects correct bit of systime for rate
FL_Trigger <= flasher_board_out;
FL_Trigger_bar <= not flasher_board_out;
SingleLED_Trigger <= led_out;

calibration_sources_now: process (CLK40, RST)
begin
	if RST = '1' then
		--systime <= (others => '0'); --&&&
		now_cnt <= (others => '0');
		now_action <= '0';
		cs_flash_now <= '0';
		cs_time_start <= '0';
		CPU_forced_start <= '0';
		
	elsif CLK40'event and CLK40 = '1' then
		--systime <= systime + '1'; --&&&
	
		case CS_ctrl.CS_mode  is --The mode defines the metering of the action
			when "000" => --OFF
				now <= '0';
				cs_time_start <= '0';
				CPU_forced_start <= '0';
		
			when "001" => --Repeating
				delay_bit <= rate_bit;
				now <= not delay_bit and rate_bit;
				cs_time_start <= '0';
				CPU_forced_start <= '0';
			
			when "010" => --Time match mode
				if systime(31 DOWNTO 0) = CS_ctrl.CS_time(31 DOWNTO 0) and cs_time_start = '0' then
					now <='1'; --may need more work to get 1 clk period
					cs_time_start <= '1';
				else now <= '0';
				end if;
				CPU_forced_start <= '0';
			
			when "011" => --CPU Forced
				-- We want a flash when CS_CPU is high, NOT when we switch to CPU Forced
				now	<= CS_ctrl.CS_CPU;
				--if  CPU_forced_start = '0' then
				--	now <='1'; --may need more work to get 1 clk period
				--	CPU_forced_start <= '1';
				--else
				--	now <= '0';
				--end if;
				cs_time_start <= '0';			
			
			when others => 
				now <= '0'; --undefined case
				cs_time_start <= '0';
				CPU_forced_start <= '0';		
		end case;
		
		if (now = '1' or now_cnt > 0) and now_cnt < 15 then
			now_cnt <= now_cnt + '1';
		else
			now_cnt <= (others => '0');
		end if;
		
		if now_cnt = CS_ctrl.CS_offset then
			now_cs_trig <= '1';
			--cs_daq_trigger <= CS_ctrl.CS_enable;
		else 
			now_cs_trig <= '0';
		end if;
				
		if now_cnt = "1000" then
			now_action <= ('1'and not cs_daq_veto); --check with thorsten
			cs_flash_time <= systime;
			cs_flash_now <= '1';
		else 
			now_action <= '0';
			cs_flash_now <= '0';			
		end if;
	end if;
end process calibration_sources_now;

cs_wf_addr <= cs_wf_addr_int;

calibration_sources_acton: process (CLK40, RST)  -- The enable defines which action to do
begin
	if RST = '1' then
		stretcher <= (others => '0');
		FE_TEST_PULSE <= '0';

		led_out <= '0';

		flasher_board_out <= '0';
		fe_R2R <= '0';
			
		cs_wf_addr_int <= (others => '0');
		FE_PULSER_P  <= (others => 'Z');
		FE_PULSER_N  <= (others => 'Z');
		ATWD_R2R <= '0';

		R2BUS  <= (others => 'Z');
		
	elsif CLK40'event and CLK40 = '1' then
			
		if CS_ctrl.CS_enable(0) = '1' and  now_action = '1' then --forced DAQ
			cs_daq_trigger <= CS_ctrl.CS_enable; --for one cycle
		else 
			cs_daq_trigger <= (others => '0');
		end if;
				
		
		if (CS_ctrl.CS_enable(1) = '1' or	CS_ctrl.CS_enable(2) = '1' or CS_ctrl.CS_enable(3) = '1') and now_action = '1' then
			stretcher <= stretcher + 1;
		elsif stretcher > 0 and stretcher < 30 then
			stretcher <= stretcher + 1;
		else
			stretcher <= (others => '0');
		end if;
		
		if CS_ctrl.CS_enable(1) = '1' and now_action = '1' then --on board LED
			FE_TEST_PULSE <= '1';
		elsif stretcher > 10 then --250ns pulse width
			FE_TEST_PULSE <= '0';
		end if;
		
		
		if CS_ctrl.CS_enable(2) = '1' and now_action = '1' then --on board LED
			led_out <= '1';
		elsif stretcher > 10 then --250ns pulse width
			led_out <= '0';
		end if;
		
		if CS_ctrl.CS_enable(3) = '1' and now_action = '1' then --flasher board
			flasher_board_out <= '1';
		elsif stretcher > 20 then --500ns pulse width
			flasher_board_out <= '0';
		end if;
		
		
		
		if ((CS_ctrl.CS_enable(4) = '1' and now_action = '1') or fe_R2R = '1')  and cs_wf_addr_int < 255 then
			fe_R2R <= '1';
			--cs_wf_addr_int <= cs_wf_addr_int +1; 
			FE_PULSER_P <= cs_wf_data(7 downto 4);
			FE_PULSER_N <= cs_wf_data(3 downto 0);
		elsif cs_wf_addr_int = 255 then
			fe_R2R <= '0';
			--cs_wf_addr_int <= (others => '0');
			FE_PULSER_P  <= (others => 'Z');
			FE_PULSER_N  <= (others => 'Z');
		end if;
		
			
	
		if ((CS_ctrl.CS_enable(5) = '1' and now_action = '1') or ATWD_R2R = '1') and cs_wf_addr_int < 255 then
			ATWD_R2R <= '1';
			--cs_wf_addr_int <= cs_wf_addr_int + 1; 
			R2BUS <= cs_wf_data;
		elsif cs_wf_addr_int = 255 then
			ATWD_R2R <= '0';
			--cs_wf_addr_int <= (others => '0');
			R2BUS  <= (others => 'Z');
		end if;	
		
		
		if (((CS_ctrl.CS_enable(4) = '1' or CS_ctrl.CS_enable(5) = '1') and now_action = '1') 
		or fe_R2R = '1' or ATWD_R2R = '1') and cs_wf_addr_int < 255 then	
			cs_wf_addr_int <= cs_wf_addr_int + 1;
		elsif cs_wf_addr_int = 255 then	
			cs_wf_addr_int <= (others => '0');
		end if;				 
	end if;		
			
end process calibration_sources_acton;
				
  -- <statements>
end ARCH_calibration_sources;




