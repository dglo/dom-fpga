-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : systimer.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-02-23
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module provides a 48 bit counter used for the DOMMB
--              system time
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-02-23  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY systimer IS
    
    PORT (
        CLK     : IN  STD_LOGIC;
        RST     : IN  STD_LOGIC;
        systime : OUT STD_LOGIC_VECTOR (47 DOWNTO 0)
        );

END systimer;


ARCHITECTURE systimer_arch OF systimer IS

    SIGNAL systime_cnt : STD_LOGIC_VECTOR (47 DOWNTO 0);
    
BEGIN  -- systimer_arch

    PROCESS (CLK, RST)
    BEGIN  -- PROCESS clock
        IF RST = '1' THEN
            systime_cnt <= (OTHERS => '0');
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            systime_cnt <= systime_cnt + 1;
        END IF;
    END PROCESS;
    systime <= systime_cnt;

END systimer_arch;












