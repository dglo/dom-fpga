-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : dead_time.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2007-03-23
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module does 
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2007-03-22              thorsten  
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Dead Time definition used in this module
-------------------------------------------------------------------------------
-- 1. A disabled ATWD is considered dead
-- 2. An ATWD/FADC is dead after the FADC finishes (6.4us) or after a LC abort.
--    One exception is flabby-lc where the FADC is part of the record kept. FOR
--    flabby-lc, the dead time starts at the end of the FADC even in the
--    presence of an LC abort.
-- 3. The DOM is considered dead is both ATWD/FADC are dead as per #1 and #2
-- 4. If the FADC finishes after 6.4us the DOM is dead for 50ns*
-- 5. If the ATWD/FADC is aborted due to LC the DOM is dead for 50ns*
--
-- * It takes 50ns for the FPGA to switch to the other ATWD/FADC. During this
--   time no launch can happen, no matter if the other ATWD/FADC is busy OR
--   not.
-- 
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

USE WORK.monitor_data_type.ALL;

ENTITY dead_time IS
    PORT (
        CLK         : IN  STD_LOGIC;
        RST         : IN  STD_LOGIC;
        -- inputs
        enable_AB   : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        dead_flag_A : IN  STD_LOGIC;
        dead_flag_B : IN  STD_LOGIC;
        -- status flags to rate meters
        dead_status : OUT DEAD_STATUS_STRUCT;
        -- test port
        TC          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END dead_time;

ARCHITECTURE dead_time_arch OF dead_time IS

    -- dead flag corrected for disabled ATWD
    SIGNAL dead_flag_A_int : STD_LOGIC;
    SIGNAL dead_flag_B_int : STD_LOGIC;

    -- dead flag stretch
    SIGNAL dead_A_SRG : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL dead_B_SRG : STD_LOGIC_VECTOR (1 DOWNTO 0);

    SIGNAL switch_dead_flag : STD_LOGIC;

    -- combined output signal
    SIGNAL dead_both : STD_LOGIC;
    
BEGIN  -- dead_time_arch

    -- A disbled ATWD is considered DEAD
    dead_flag_A_int <= dead_flag_A OR NOT enable_AB(0);
    dead_flag_B_int <= dead_flag_B OR NOT enable_AB(1);

    -- stretch dead flags to decode the channel switch dead TIME
    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            dead_A_SRG <= (OTHERS => '0');
            dead_B_SRG <= (OTHERS => '0');
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            dead_A_SRG <= dead_A_SRG(0) & dead_flag_A_int;
            dead_B_SRG <= dead_B_SRG(0) & dead_flag_B_int;
        END IF;
    END PROCESS;

    -- generate channel switch dead flag
    switch_dead_flag <= '1' WHEN (dead_flag_A_int = '1' AND dead_A_SRG(1) = '0')
                        OR (dead_flag_B_int = '1' AND dead_B_SRG(1) = '0') ELSE '0';

    -- combine channel switch dead flag with indivodual ATWD dead flags
    dead_both <= switch_dead_flag OR (dead_flag_A_int AND dead_flag_B_int);

    -- map output RECORD
    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            dead_status.dead_A    <= '0';
            dead_status.dead_B    <= '0';
            dead_status.dead_both <= '0';
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            dead_status.dead_A    <= dead_flag_A_int;
            dead_status.dead_B    <= dead_flag_B_int;
            dead_status.dead_both <= dead_both;
        END IF;
    END PROCESS;
    
END dead_time_arch;
