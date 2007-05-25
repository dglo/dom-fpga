-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : rate_meters.vhd
-- Author     : yaver/thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2007-03-23
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
-- 2006-04-20              thorsten  Moved timestamp to last timeslot (Arthur)
-- 2007-03-22              thorsten  added ATWD dead time
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
LIBRARY WORK;
USE WORK.ctrl_data_types.ALL;
USE WORK.monitor_data_type.ALL;



ENTITY rate_meters IS
    PORT (
        -- Common Inputs
        CLK20       : IN  STD_LOGIC;
        CLK40       : IN  STD_LOGIC;
        RST         : IN  STD_LOGIC;
        systime     : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);  --&&&
        -- slaveregister
        RM_ctrl     : IN  RM_CTRL_STRUCT;
        RM_stat     : OUT RM_STAT_STRUCT;
        -- DAQ interface
        RM_daq_disc : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        dead_status : IN  DEAD_STATUS_STRUCT;
        -- test
        TC          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END rate_meters;

ARCHITECTURE ARCH_rate_meters OF rate_meters IS

    CONSTANT one_second : INTEGER := (67108864 - 20000000 + 1);  -- Counting up from this value 26th bit changes to 1


    SIGNAL RM_rate_update : STD_LOGIC;
    SIGNAL RM_rate_SPE    : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL RM_rate_MPE    : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL RM_sn_data     : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL sn_rate_update : STD_LOGIC;


--signal SPE_disc : STD_LOGIC;
    SIGNAL rate_MPE_int  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL rate_SPE_int  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL rate_dead_int : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL lockout_MPE   : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL lockout_SPE   : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL second_cnt    : STD_LOGIC_VECTOR(26 DOWNTO 0);


    SIGNAL delay_bit      : STD_LOGIC;
    SIGNAL lockout_sn     : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL RM_sn_data_int : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL sn_dead_int    : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL sn_rate        : STD_LOGIC_VECTOR(3 DOWNTO 0);
--signal sn_rate_update : STD_LOGIC;
    SIGNAL sn_t_cnt       : STD_LOGIC_VECTOR(1 DOWNTO 0);
--signal sn_rate_vector : STD_LOGIC_VECTOR(31 downto 0);

--signal systime : STD_LOGIC_VECTOR(47 downto 0);

    -- stretch the RM_daq_disc signal to run the processes at 20MHz
    SIGNAL RM_daq_disc_20MHz : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL RM_daq_disc_old   : STD_LOGIC_VECTOR (1 DOWNTO 0);

    -- dead time counter
    SIGNAL dead_cnt    : STD_LOGIC_VECTOR (25 DOWNTO 0);
    SIGNAL dead_flag   : STD_LOGIC;

BEGIN

    RM_stat.RM_rate_update <= RM_rate_update;
    RM_stat.RM_rate_SPE    <= RM_rate_SPE;
    RM_stat.RM_rate_MPE    <= RM_rate_MPE;
    RM_stat.RM_sn_data     <= RM_sn_data;
    RM_stat.sn_rate_update <= sn_rate_update;



    rate_dead_int(10 DOWNTO 1) <= RM_ctrl.RM_rate_dead(9 DOWNTO 0);  --multiply dead time by 2 for 100ns intervals
    rate_dead_int(0)           <= '0';

    --sn_dead_int(10)          <= '0';
    --sn_dead_int(9 DOWNTO 7) <= RM_ctrl.RM_sn_dead;  ---&&& was (2 downto 0)
    sn_dead_int(14)          <= '0';
    --sn_dead_int(13 DOWNTO 7) <= "1111111";  ---&&& was (2 downto 0)
    sn_dead_int(13 DOWNTO 7) <= RM_ctrl.RM_sn_dead;
    sn_dead_int(6 DOWNTO 0)  <= "1111111";  ---&&&
    --sn_dead_int(6 DOWNTO 0) <= "0000000";             ---&&&

    PROCESS (CLK40, RST)
    BEGIN
        IF RST = '1' THEN
            RM_daq_disc_old <= "00";
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN
            RM_daq_disc_old <= RM_daq_disc;
        END IF;
    END PROCESS;
    RM_daq_disc_20MHz <= RM_daq_disc OR RM_daq_disc_old;


    rate_meters_machine : PROCESS (CLK20, RST)
    BEGIN
--conv_std_logic_vector (one_second,27);
        IF RST = '1' THEN
            RM_rate_update <= '0';
            RM_rate_SPE    <= (OTHERS => '0');
            rate_SPE_int   <= (OTHERS => '0');
            lockout_SPE    <= (OTHERS => '0');
            RM_rate_MPE    <= (OTHERS => '0');
            rate_MPE_int   <= (OTHERS => '0');
            lockout_MPE    <= (OTHERS => '0');
            RM_sn_data     <= (OTHERS => '0');
            TC             <= (OTHERS => '0');
            --#second_cnt <= (others => '0');

            second_cnt     <= conv_std_logic_vector (one_second, 27);
            --delay_bit <= '0';
            lockout_sn     <= (OTHERS => '0');
--              sn_dead_int <= (others => '0');
            sn_rate        <= (OTHERS => '0');
            sn_rate_update <= '0';
            sn_t_cnt       <= (OTHERS => '0');
            RM_sn_data_int <= (OTHERS => '0');
            --systime  <= (others => '0'); --&&&
            
            
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN

            --systime  <= systime + 1; --&&&
            delay_bit <= systime(15);   ---&&& was systime(4)

            IF RM_ctrl.RM_rate_enable(0) = '1' OR RM_ctrl.RM_rate_enable(1) = '1' OR RM_ctrl.dead_cnt_en /= "00" THEN
                second_cnt <= second_cnt + '1';
            ELSE
                second_cnt <= conv_std_logic_vector (one_second, 27);
            END IF;

            IF second_cnt(26) = '1' THEN  --Decimal 67108864 turns to one every second
                --was [if  second_cnt = 20000000 then]
                
                RM_rate_update <= '1';
                second_cnt     <= conv_std_logic_vector (one_second, 27);

                IF RM_ctrl.RM_rate_enable(1) = '1' THEN  --MPE triggers at 1 second intervals
                    RM_rate_MPE  <= rate_MPE_int;
                    --lockout_MPE <= (others => '0'); good for simulation stops odd/even effect
                    rate_MPE_int <= (OTHERS => '0');
                END IF;

                IF RM_ctrl.RM_rate_enable(0) = '1' THEN  --SPE triggers at 1 second intervals
                    RM_rate_SPE  <= rate_SPE_int;
                    --lockout_SPE <= (others => '0'); good for simulation stops odd/even effect
                    rate_SPE_int <= (OTHERS => '0');
                END IF;
                
            ELSE
                RM_rate_update <= '0';

                IF RM_ctrl.RM_rate_enable(1) = '1' AND RM_daq_disc_20MHz(1) = '1' AND lockout_MPE = 0 THEN
                    rate_MPE_int <= rate_MPE_int + '1';
                END IF;

                IF RM_ctrl.RM_rate_enable(1) = '1' AND (lockout_MPE > 0 OR RM_daq_disc_20MHz(1) = '1') AND lockout_MPE < rate_dead_int THEN
                    lockout_MPE <= lockout_MPE + '1';
                ELSIF RM_ctrl.RM_rate_enable(1) = '0' OR lockout_MPE >= rate_dead_int THEN
                    lockout_MPE <= (OTHERS => '0');
                END IF;

                IF RM_ctrl.RM_rate_enable(0) = '1' AND RM_daq_disc_20MHz(0) = '1' AND lockout_SPE = 0 THEN
                    rate_SPE_int <= rate_SPE_int + '1';
                END IF;

                --if RM_daq_disc_20MHz(0) = '1' and lockout_SPE < rate_dead_int then
                --      SPE_disc <= '1';
                --elsif lockout_MPE >=  rate_dead_int then
                --      SPE_disc <= '0';
                --end if;

                IF RM_ctrl.RM_rate_enable(0) = '1' AND (lockout_SPE > 0 OR RM_daq_disc_20MHz(0) = '1') AND lockout_SPE < rate_dead_int THEN
                    lockout_SPE <= lockout_SPE + '1';
                ELSIF RM_ctrl.RM_rate_enable(0) = '0' OR lockout_SPE >= rate_dead_int THEN
                    lockout_SPE <= (OTHERS => '0');
                END IF;
                
                
            END IF;

            sn_rate_update <= NOT systime(15) AND delay_bit AND sn_t_cnt(0) AND sn_t_cnt(1);  ---&&& was systime(15)

            IF systime(15) = '0' AND delay_bit = '1' THEN  ---&&& was systime(4)
                sn_t_cnt <= sn_t_cnt + '1';
                --lockout_SN <= (others => '0');
                IF sn_t_cnt = 0 THEN
                    -- Moved timestamp to last timeslot after talking to Arthur
                    -- RM_sn_data_int(31 downto 16) <= systime(31 downto 16);
                    RM_sn_data_int(3 DOWNTO 0) <= sn_rate;
                    sn_rate                    <= (OTHERS => '0');
                END IF;
                IF sn_t_cnt = 1 THEN
                    RM_sn_data_int(7 DOWNTO 4) <= sn_rate;
                    sn_rate                    <= (OTHERS => '0');
                END IF;
                IF sn_t_cnt = 2 THEN
                    RM_sn_data_int(11 DOWNTO 8) <= sn_rate;
                    sn_rate                     <= (OTHERS => '0');
                END IF;
                IF sn_t_cnt = 3 THEN
                    RM_sn_data(15 DOWNTO 12) <= sn_rate;
                    -- Moved timestamp to last timeslot after talking to Arthur
                    -- RM_sn_data(31 downto 16) <= RM_sn_data_int(31 downto 16);
                    RM_sn_data(31 DOWNTO 16) <= systime(31 DOWNTO 16);
                    RM_sn_data(11 DOWNTO 0)  <= RM_sn_data_int(11 DOWNTO 0);
                    sn_rate                  <= (OTHERS => '0');
                END IF;
            ELSE
                IF (RM_ctrl.RM_sn_enable = "01" AND (lockout_SN > 0 OR RM_daq_disc_20MHz(0) = '1') AND lockout_SN <= sn_dead_int) OR
                    (RM_ctrl.RM_sn_enable = "10" AND (lockout_SN > 0 OR RM_daq_disc_20MHz(1) = '1') AND lockout_SN <= sn_dead_int) THEN
                    lockout_SN                                                                                     <= lockout_SN + '1';
                ELSIF RM_ctrl.RM_sn_enable(0) = '0' OR RM_ctrl.RM_sn_enable(1) = '0' OR lockout_SN >= sn_dead_int THEN
                    lockout_SN <= (OTHERS => '0');
                END IF;

                IF ((RM_ctrl.RM_sn_enable = "10" AND RM_daq_disc_20MHz(1) = '1') OR (RM_ctrl.RM_sn_enable = "01" AND RM_daq_disc_20MHz(0) = '1')) AND lockout_SN = 0 AND sn_rate < 15 THEN
                    sn_rate <= sn_rate + '1';
                ELSIF RM_ctrl.RM_sn_enable = "00" THEN
                    sn_rate <= (OTHERS => '0');
                END IF;
            END IF;
        END IF;
        
    END PROCESS;

    dead_flag <= dead_status.dead_A WHEN RM_ctrl.dead_cnt_en = "01" ELSE
                 dead_status.dead_B    WHEN RM_ctrl.dead_cnt_en = "10" ELSE
                 dead_status.dead_both WHEN RM_ctrl.dead_cnt_en = "11" ELSE
                 '0';
    PROCESS (CLK40, RST)
        VARIABLE edge_detect : STD_LOGIC;
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            RM_stat.dead_cnt <= (OTHERS => '0');
            dead_cnt    <= (OTHERS => '0');
            edge_detect := '0';
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            IF second_cnt(26) = '1' AND edge_detect = '0' THEN
                RM_stat.dead_cnt <= "000000" & dead_cnt;
                dead_cnt         <= (OTHERS => '0');
            ELSE
                IF dead_flag = '1' THEN
                    dead_cnt <= dead_cnt + 1;
                END IF;
            END IF;
            edge_detect := second_cnt(26);
        END IF;
    END PROCESS;

    -- <statements>
END ARCH_rate_meters;




