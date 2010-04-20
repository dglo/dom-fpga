-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : ROC.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2009-04-17
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module provides a reset signal after the FPGA configures
--              I couldn't find a good way to do that
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten
-- 2009-04-16              thorsten  Changed reset to use plain (non PLL) 20MHz
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ROC IS
    PORT (
        CLK_EXT : IN  STD_LOGIC;
        CLK_PLL : IN  STD_LOGIC;
        RST     : OUT STD_LOGIC
        );
END ROC;

ARCHITECTURE arch_ROC OF ROC IS


    SIGNAL SRG_EXT     : STD_LOGIC_VECTOR (7 DOWNTO 0) := x"00";
    SIGNAL SRG_EXT_RST : STD_LOGIC;

    CONSTANT RST_CNT_MAX : INTEGER := 1023;
    SIGNAL   RST_CNT     : INTEGER RANGE -1 TO RST_CNT_MAX;
    SIGNAL   RST_CNT_RST : STD_LOGIC;

    SIGNAL RST_SYNC_SRG : STD_LOGIC_VECTOR (3 DOWNTO 0);

    ATTRIBUTE PRESERVE                 : BOOLEAN;
    ATTRIBUTE PRESERVE OF SRG_EXT      : SIGNAL IS true;
    ATTRIBUTE PRESERVE OF RST_CNT      : SIGNAL IS true;
    ATTRIBUTE PRESERVE OF RST_CNT_RST  : SIGNAL IS true;
    ATTRIBUTE PRESERVE OF RST_SYNC_SRG : SIGNAL IS true;

    
BEGIN

    START_UP_RESET : PROCESS (CLK_EXT)
    BEGIN  -- PROCESS START_UP_RESET
        IF CLK_EXT'EVENT AND CLK_EXT = '1' THEN  -- rising clock edge
            SRG_EXT <= '1' & SRG_EXT(7 DOWNTO 1);
        END IF;
    END PROCESS START_UP_RESET;
    SRG_EXT_RST <= NOT SRG_EXT (0);

    PLL_RESET_CNT : PROCESS (CLK_EXT, SRG_EXT_RST)
    BEGIN  -- PROCESS PLL_RESET_CNT
        IF SRG_EXT_RST = '1' THEN       -- asynchronous reset (active high)
            RST_CNT     <= RST_CNT_MAX;
            RST_CNT_RST <= '1';
        ELSIF CLK_EXT'EVENT AND CLK_EXT = '1' THEN  -- rising clock edge
            IF RST_CNT >= 0 THEN
                RST_CNT     <= RST_CNT - 1;
                RST_CNT_RST <= '1';
            ELSE
                RST_CNT     <= RST_CNT;
                RST_CNT_RST <= '0';
            END IF;
        END IF;
    END PROCESS PLL_RESET_CNT;

    RESET_SYNC : PROCESS (CLK_PLL, RST_CNT_RST)
    BEGIN  -- PROCESS RESET_SYNC
        IF RST_CNT_RST = '1' THEN       -- asynchronous reset (active high)
            RST_SYNC_SRG <= (OTHERS => '1');
            RST          <= '1';
        ELSIF CLK_PLL'EVENT AND CLK_PLL = '1' THEN  -- rising clock edge
            RST_SYNC_SRG <= RST_CNT_RST & RST_SYNC_SRG (3 DOWNTO 1);
            RST          <= RST_SYNC_SRG(0);
        END IF;
    END PROCESS RESET_SYNC;
END;



