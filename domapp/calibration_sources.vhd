-- Harolds code
-- ADD HEADER !!!!!


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
LIBRARY WORK;

USE WORK.ctrl_data_types.ALL;

ENTITY calibration_sources IS
    PORT (
        -- Common Inputs
        CLK20         : IN  STD_LOGIC;
        CLK40         : IN  STD_LOGIC;
        RST           : IN  STD_LOGIC;
        systime       : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);  --&&&
        -- slaveregister
        cs_ctrl       :     CS_STRUCT;
        cs_wf_data    : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        cs_wf_addr    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        cs_flash_now  : OUT STD_LOGIC;
        cs_flash_time : OUT STD_LOGIC_VECTOR (47 DOWNTO 0);
        --cs_enable     : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        --cs_mode               : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        --cs_time               : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        --cs_rate               : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        --cs_offset     : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        --cs_cpu                : IN STD_LOGIC;
        --cs_fl_aux_reset       : IN STD_LOGIC;

        -- DAQ interface
        cs_daq_trigger    : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
        cs_daq_veto       : IN  STD_LOGIC;
        -- I/O
        SingleLED_Trigger : OUT STD_LOGIC;
        FE_TEST_PULSE     : OUT STD_LOGIC;
        R2BUS             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        FE_PULSER_P       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        FE_PULSER_N       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

        FL_Trigger     : OUT STD_LOGIC;
        FL_Trigger_bar : OUT STD_LOGIC;
        FL_ATTN        : IN  STD_LOGIC;
        FL_AUX_RESET   : OUT STD_LOGIC;
        --test
        TC             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END calibration_sources;

ARCHITECTURE ARCH_calibration_sources OF calibration_sources IS

    SIGNAL ATWD_R2R : STD_LOGIC;

    SIGNAL cs_time_start    : STD_LOGIC;
    SIGNAL cs_wf_addr_int   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL CPU_forced_start : STD_LOGIC;
    SIGNAL fe_R2R           : STD_LOGIC;

    SIGNAL stretcher         : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL flasher_board_out : STD_LOGIC;

    SIGNAL led_out     : STD_LOGIC;
    SIGNAL now         : STD_LOGIC;
    SIGNAL now_action  : STD_LOGIC;
--    SIGNAL now_cs_trig : STD_LOGIC;
    SIGNAL now_cnt     : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL rate_bit    : STD_LOGIC;
    SIGNAL delay_bit   : STD_LOGIC;

--signal systime : STD_LOGIC_VECTOR(47 downto 0);  --&&&

BEGIN

-- concurrent signals assignments
    rate_bit          <= systime(25 - conv_integer(CS_ctrl.CS_rate));  -- selects correct bit of systime for rate
    FL_Trigger        <= flasher_board_out;
    FL_Trigger_bar    <= NOT flasher_board_out;
    SingleLED_Trigger <= led_out;

    calibration_sources_now : PROCESS (CLK40, RST)
    BEGIN
        IF RST = '1' THEN
            --systime <= (others => '0'); --&&&
            now_cnt          <= "01000"; --(OTHERS => '0');
            now_action       <= '0';
            cs_flash_now     <= '0';
            cs_time_start    <= '0';
            CPU_forced_start <= '0';
            
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN
            --systime <= systime + '1'; --&&&
            
            CASE CS_ctrl.CS_mode IS  --The mode defines the metering of the action
                WHEN "000" =>           --OFF
                    now              <= '0';
                    cs_time_start    <= '0';
                    CPU_forced_start <= '0';
                    
                WHEN "001" =>           --Repeating
                    delay_bit        <= rate_bit;
                    now              <= NOT delay_bit AND rate_bit;
                    cs_time_start    <= '0';
                    CPU_forced_start <= '0';
                    
                WHEN "010" =>           --Time match mode
                    IF systime(31 DOWNTO 0) = CS_ctrl.CS_time(31 DOWNTO 0) AND cs_time_start = '0' THEN
                        now           <= '1';  --may need more work to get 1 clk period
                        cs_time_start <= '1';
                    ELSE now         <= '0';
                    END IF;
                    CPU_forced_start <= '0';
                    
                WHEN "011" =>           --CPU Forced
                    IF CPU_forced_start = '0' THEN
                        now              <= '1';  --may need more work to get 1 clk period
                        CPU_forced_start <= '1';
                    ELSE now      <= '0';
                    END IF;
                    cs_time_start <= '0';
                    
                WHEN OTHERS =>
                    now              <= '0';  --undefined case
                    cs_time_start    <= '0';
                    CPU_forced_start <= '0';
            END CASE;

--            IF (now = '1' OR now_cnt > 0) AND now_cnt < 15 THEN
--                now_cnt <= now_cnt + '1';
--            ELSE
--                now_cnt <= (OTHERS => '0');
--            END IF;
            IF now = '1' THEN
                now_cnt <= "11000";
            ELSIF now_cnt /= "01000" THEN
                now_cnt <= now_cnt + 1;
            END IF;

            IF now_cnt = CS_ctrl.CS_offset(3) & CS_ctrl.CS_offset THEN
                --now_cs_trig <= '1';
                cs_daq_trigger <= CS_ctrl.CS_enable;
            ELSE
                --now_cs_trig <= '0';
                cs_daq_trigger <= (OTHERS => '0');
            END IF;

            IF now_cnt = "00000" THEN
                now_action    <= ('1'AND NOT cs_daq_veto);  --check with thorsten
                cs_flash_time <= systime;
                cs_flash_now  <= '1';
            ELSE
                now_action   <= '0';
                cs_flash_now <= '0';
            END IF;
        END IF;
    END PROCESS calibration_sources_now;

    cs_wf_addr <= cs_wf_addr_int;

    calibration_sources_acton : PROCESS (CLK40, RST)  -- The enable defines which action to do
    BEGIN
        IF RST = '1' THEN
            stretcher     <= (OTHERS => '0');
            FE_TEST_PULSE <= '0';

            led_out <= '0';

            flasher_board_out <= '0';
            fe_R2R            <= '0';

            cs_wf_addr_int <= (OTHERS => '0');
            FE_PULSER_P    <= (OTHERS => 'Z');
            FE_PULSER_N    <= (OTHERS => 'Z');
            ATWD_R2R       <= '0';

            R2BUS <= (OTHERS => 'Z');
            
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN

--            IF now_cs_trig = '1' THEN   --forced DAQ
--                --      cs_daq_trigger <= CS_ctrl.CS_enable; --for one cycle
--            ELSE
--                --      cs_daq_trigger <= (others => '0');
--            END IF;


            IF (CS_ctrl.CS_enable(1) = '1' OR CS_ctrl.CS_enable(2) = '1' OR CS_ctrl.CS_enable(3) = '1') AND now_action = '1' THEN
                stretcher <= stretcher + 1;
            ELSIF stretcher > 0 AND stretcher < 30 THEN
                stretcher <= stretcher + 1;
            ELSE
                stretcher <= (OTHERS => '0');
            END IF;

            IF CS_ctrl.CS_enable(1) = '1' AND now_action = '1' THEN  --on board LED
                FE_TEST_PULSE <= '1';
            ELSIF stretcher > 10 THEN   --250ns pulse width
                FE_TEST_PULSE <= '0';
            END IF;

            IF CS_ctrl.CS_enable(2) = '1' AND now_action = '1' THEN  --on board LED
                led_out <= '1';
            ELSIF stretcher > 10 THEN   --250ns pulse width
                led_out <= '0';
            END IF;

            IF CS_ctrl.CS_enable(3) = '1' AND now_action = '1' THEN  --flasher board
                flasher_board_out <= '1';
            ELSIF stretcher > 20 THEN   --500ns pulse width
                flasher_board_out <= '0';
            END IF;



            IF ((CS_ctrl.CS_enable(4) = '1' AND now_action = '1') OR fe_R2R = '1') AND cs_wf_addr_int < 255 THEN
                fe_R2R      <= '1';
                --cs_wf_addr_int <= cs_wf_addr_int +1; 
                FE_PULSER_P <= cs_wf_data(7 DOWNTO 4);
                FE_PULSER_N <= cs_wf_data(3 DOWNTO 0);
            ELSIF cs_wf_addr_int = 255 THEN
                fe_R2R      <= '0';
                --cs_wf_addr_int <= (others => '0');
                FE_PULSER_P <= (OTHERS => 'Z');
                FE_PULSER_N <= (OTHERS => 'Z');
            END IF;



            IF ((CS_ctrl.CS_enable(5) = '1' AND now_action = '1') OR ATWD_R2R = '1') AND cs_wf_addr_int < 255 THEN
                ATWD_R2R <= '1';
                --cs_wf_addr_int <= cs_wf_addr_int + 1; 
                R2BUS    <= cs_wf_data;
            ELSIF cs_wf_addr_int = 255 THEN
                ATWD_R2R <= '0';
                --cs_wf_addr_int <= (others => '0');
                R2BUS    <= (OTHERS => 'Z');
            END IF;
            
            
            IF (((CS_ctrl.CS_enable(4) = '1' OR CS_ctrl.CS_enable(5) = '1') AND now_action = '1')
                OR fe_R2R = '1' OR ATWD_R2R = '1') AND cs_wf_addr_int < 255 THEN        
                cs_wf_addr_int <= cs_wf_addr_int + 1;
            ELSIF cs_wf_addr_int = 255 THEN
                cs_wf_addr_int <= (OTHERS => '0');
            END IF;
        END IF;
        
    END PROCESS calibration_sources_acton;

    -- <statements>
END ARCH_calibration_sources;




